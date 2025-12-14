import {CloudFunction} from '../../utils/Registry/decorators';
import PlacementTestQuestion from '../../models/PlacementTestQuestion';
import PlacementTestCorrectAnswer from '../../models/PlacementTestCorrectAnswer';

async function ensureUser(req: Parse.Cloud.FunctionRequest): Promise<any> {
  let user = req.user;
  
  if (!user) {
    const sessionToken = (req as any).headers?.['x-parse-session-token'] || (req as any).headers?.['X-Parse-Session-Token'];
    
    if (sessionToken) {
      try {
        const sessionQuery = new Parse.Query(Parse.Session);
        sessionQuery.equalTo('sessionToken', sessionToken);
        const session = await sessionQuery.include('user').first({useMasterKey: true});
        
        if (session) {
          user = session.get('user');
          if (user) {
            return user;
          }
        }
      } catch (error) {
        console.error('Error extracting user:', error);
      }
    }
  }
  
  return user;
}

class PlacementTestFunctions {
  @CloudFunction({
    methods: ['GET'],
    validation: {
      requireUser: false,
      fields: {},
    },
  })
  async getPlacementTestQuestions(req: Parse.Cloud.FunctionRequest) {
    try {
      const user = await ensureUser(req);
      if (!user) {
        throw {codeStatus: 103, message: 'User context is missing'};
      }

      const rolePointer = user.get('role');
      const role = await new Parse.Query(Parse.Role)
        .equalTo('objectId', rolePointer?.id)
        .first({useMasterKey: true});

      const roleName = role?.get('name');
      if (roleName !== 'Child') {
        throw {codeStatus: 102, message: 'User is not a Child'};
      }

      const query = new Parse.Query(PlacementTestQuestion);
      query.ascending('createdAt');
      const results = await query.find({useMasterKey: true});

      const formatted = results.map(q => {
        const qImg = q.get('question_image_url');
        const aImg = q.get('option_a_image_url');
        const bImg = q.get('option_b_image_url');
        const cImg = q.get('option_c_image_url');
        const dImg = q.get('option_d_image_url');
        
        return {
          id: q.id,
          question_image_url: `http://localhost:1337/api/files/${qImg?.name ? qImg.name() : qImg}`,
          options: {
            A: `http://localhost:1337/api/files/${aImg?.name ? aImg.name() : aImg}`,
            B: `http://localhost:1337/api/files/${bImg?.name ? bImg.name() : bImg}`,
            C: `http://localhost:1337/api/files/${cImg?.name ? cImg.name() : cImg}`,
            D: `http://localhost:1337/api/files/${dImg?.name ? dImg.name() : dImg}`,
          },
        };
      });

      return formatted;
    } catch (error: any) {
      console.error('Error in getPlacementTestQuestions:', error);
      throw {
        codeStatus: error.codeStatus || 1000,
        message: error.message || 'Failed to retrieve placement test questions',
      };
    }
  }

  @CloudFunction({
    methods: ['POST'],
    validation: {
      requireUser: false,
    },
  })
  async getPlacementTestQuestionByIndex(req: Parse.Cloud.FunctionRequest) {
    try {
      const user = await ensureUser(req);
      const index = req.params.index;

      if (!user) {
        throw {codeStatus: 103, message: 'User context is missing'};
      }

      const rolePointer = user.get('role');
      const role = await new Parse.Query(Parse.Role)
        .equalTo('objectId', rolePointer?.id)
        .first({useMasterKey: true});

      const roleName = role?.get('name');
      if (roleName !== 'Child') {
        throw {codeStatus: 102, message: 'User is not a Child'};
      }

      const query = new Parse.Query(PlacementTestQuestion);
      query.ascending('createdAt');
      query.skip(index);
      query.limit(1);
      const result = await query.first({useMasterKey: true});
      if (!result) {
        throw {codeStatus: 104, message: 'No question found at this index'};
      }

      const rImg = result.get('question_image_url');
      const raImg = result.get('option_a_image_url');
      const rbImg = result.get('option_b_image_url');
      const rcImg = result.get('option_c_image_url');
      const rdImg = result.get('option_d_image_url');
      
      return {
        id: result.id,
        question_image_url: `http://localhost:1337/api/files/${rImg?.name ? rImg.name() : rImg}`,
        options: {
          A: `http://localhost:1337/api/files/${raImg?.name ? raImg.name() : raImg}`,
          B: `http://localhost:1337/api/files/${rbImg?.name ? rbImg.name() : rbImg}`,
          C: `http://localhost:1337/api/files/${rcImg?.name ? rcImg.name() : rcImg}`,
          D: `http://localhost:1337/api/files/${rdImg?.name ? rdImg.name() : rdImg}`,
        },
      };
    } catch (error: any) {
      console.error('Error in getPlacementTestQuestionByIndex:', error);
      throw {
        codeStatus: error.codeStatus || 1000,
        message: error.message || 'Failed to retrieve question by index',
      };
    }
  }

  @CloudFunction({
    methods: ['POST'],
    validation: {
      requireUser: false,
      fields: {
        answers: {type: Array, required: true},
      },
    },
  })
  async submitPlacementTestAnswers(req: Parse.Cloud.FunctionRequest) {
    const user = await ensureUser(req);
    if (!user) throw new Error('User is not logged in');

    const {answers} = req.params;
    let correctCount = 0;

    for (const {questionId, selectedOption} of answers) {
      const questionPointer = new Parse.Object('PlacementTestQuestion');
      questionPointer.id = questionId;

      const answerQuery = new Parse.Query(PlacementTestCorrectAnswer);
      answerQuery.equalTo('question', questionPointer);
      const correctAnswer = await answerQuery.first({useMasterKey: true});

      const isCorrect =
        correctAnswer?.get('correct_option')?.trim().toUpperCase() ===
        selectedOption.trim().toUpperCase();

      if (isCorrect) correctCount++;
    }

    const score = Math.round((correctCount / answers.length) * 100);
    const passed = score >= 70;

    user.set('placement_test_score', score);
    await user.save(null, {useMasterKey: true});

    return {correctCount, score, passed};
  }
}

export default new PlacementTestFunctions();
