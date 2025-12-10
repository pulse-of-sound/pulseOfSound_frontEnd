// ✅ الكود الصحيح لـ loginUser function
// استبدل الـ loginUser method الحالي بهذا:

@CloudFunction({
  methods: ['POST'],
  validation: {
    requireUser: false,
    fields: {
      username: {
        required: true,
        type: String,
      },
      password: {
        required: true,
        type: String,
      },
    },
  },
})
async loginUser(req: Parse.Cloud.FunctionRequest) {
  const {username, password} = req.params;
  console.log('🔐 loginUser: Attempting login for', username);

  let [error, user] = await catchError<Parse.User>(
    User.logIn(username, password, {
      installationId: generateRandomString(10),
    })
  );

  if (error || !user) {
    throw new Parse.Error(Parse.Error.OTHER_CAUSE, error?.message || 'Login failed');
  }
  
  console.log('✅ loginUser: User logged in successfully');
  
  // ⬇️ احفظ sessionToken الآن قبل أي شيء آخر
  const sessionToken = user.getSessionToken();
  console.log('✅ loginUser: sessionToken captured:', sessionToken?.substring(0, 20) + '...');
  
  // جلب role مع include
  const userQuery = new Parse.Query(Parse.User);
  userQuery.include('role');
  const freshUser = await userQuery.get(user.id, {useMasterKey: true});
  
  // تحديث المرجع لكن احتفظ بالـ sessionToken
  user = freshUser;
  
  const roleQuery = new Parse.Query(Parse.Role);
  roleQuery.equalTo('users', user);
  const roles = await roleQuery.find({useMasterKey: true});

  const validRoleNames = Object.values(UserRoles);
  const matchedRoles = roles.filter(role =>
    validRoleNames.includes(role.get('name'))
  );

  const selectedRole = matchedRoles[0];
  const userJson = User.map(user as User, selectedRole) as any;

  // تحديد الـ role
  const roleName = selectedRole ? selectedRole.get('name') : null;
  
  let finalRole = roleName;
  if (!finalRole) {
    const userRole = user.get('role');
    if (userRole) {
      if (userRole.get) {
        finalRole = userRole.get('name');
      } else if (userRole.name) {
        finalRole = userRole.name;
      }
    }
  }
  
  if (!finalRole) {
    const usernameStr = user.get('username') || '';
    if (usernameStr.toLowerCase().includes('superadmin') || usernameStr.toLowerCase().includes('super_admin')) {
      finalRole = SystemRoles.SUPER_ADMIN;
    } else if (usernameStr.toLowerCase().includes('admin') && !usernameStr.toLowerCase().includes('super')) {
      finalRole = SystemRoles.ADMIN;
    }
  }

  // ✅ أضف sessionToken والـ role في الـ response
  console.log('✅ loginUser: Returning response with sessionToken and role:', finalRole);
  return {
    ...userJson,
    sessionToken: sessionToken,  // ⬅️ استخدم الـ sessionToken المحفوظ
    role: finalRole || 'User',
  };
}


// ==========================================
// البديل: إذا كان لديك مشكلة مستمرة، جرب هذا النسخة المبسطة:
// ==========================================

@CloudFunction({
  methods: ['POST'],
  validation: {
    requireUser: false,
    fields: {
      username: {
        required: true,
        type: String,
      },
      password: {
        required: true,
        type: String,
      },
    },
  },
})
async loginUserSimplified(req: Parse.Cloud.FunctionRequest) {
  const {username, password} = req.params;
  
  // استخدام Parse.User.logIn الذي يرجع sessionToken تلقائياً
  const user = await Parse.User.logIn(username, password, {
    installationId: generateRandomString(10),
  });
  
  if (!user) {
    throw new Parse.Error(Parse.Error.OTHER_CAUSE, 'Login failed');
  }
  
  // احفظ sessionToken مباشرة
  const sessionToken = user.getSessionToken();
  
  // جلب الـ role
  await user.fetch({useMasterKey: true, include: ['role']});
  
  // تحديد الـ role
  let roleName = user.get('role')?.get('name') || 'User';
  
  // محاولة من Parse.Role relation
  if (roleName === 'User') {
    const roleQuery = new Parse.Query(Parse.Role);
    roleQuery.equalTo('users', user);
    const roles = await roleQuery.find({useMasterKey: true});
    if (roles.length > 0) {
      roleName = roles[0].get('name');
    }
  }
  
  // محاولة من username
  if (roleName === 'User') {
    const usernameStr = user.get('username') || '';
    if (usernameStr.toLowerCase().includes('superadmin')) {
      roleName = SystemRoles.SUPER_ADMIN;
    } else if (usernameStr.toLowerCase().includes('admin')) {
      roleName = SystemRoles.ADMIN;
    }
  }
  
  // أرجع البيانات مع sessionToken
  return {
    id: user.id,
    objectId: user.id,
    username: user.get('username'),
    fullName: user.get('fullName'),
    mobileNumber: user.get('mobileNumber'),
    email: user.get('email'),
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    sessionToken: sessionToken,  // ⬅️ صريح وواضح
    role: roleName,
  };
}
