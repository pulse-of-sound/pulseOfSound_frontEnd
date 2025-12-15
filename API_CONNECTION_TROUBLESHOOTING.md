# 🔗 دليل اختبار ربط APIs بين الفرونت والباك

## 📋 المشكلة
عند تشغيل التطبيق، لا تظهر APIs الخاصة بـ `ChildLevel` و `Level` و `LevelGame` مربوطة بين الفرونت والباك.

## 🔍 الخطوات للتحقق من الربط

### 1️⃣ التحقق من تسجيل Cloud Functions في الباك إند

#### أ. تشغيل الباك إند
```bash
cd c:\Users\LAPTOP KING\Desktop\PulseOfSound\pulsofsound_backend
npm run dev
```

#### ب. البحث في اللوج عن رسائل التسجيل
عند تشغيل الباك إند، يجب أن ترى رسائل مثل:
```
Registered cloud function: assignChildLevelIfPassed
Registered cloud function: getCurrentStageForChild
Registered cloud function: advanceOrRepeatStage
Registered cloud function: getLevelCompletionStatus
Registered cloud function: getStageCompletionStatus
Registered cloud function: addLevelByAdmin
Registered cloud function: getAllLevels
Registered cloud function: getLevelById
Registered cloud function: deleteLevel
Registered cloud function: addLevelGameByAdmin
Registered cloud function: getLevelGamesForLevel
Registered cloud function: getNextStageOrder
```

**⚠️ إذا لم تظهر هذه الرسائل:**
- المشكلة في تسجيل الـ Cloud Functions
- تحقق من أن ملف `functions.ts` يتم استيراده بشكل صحيح

---

### 2️⃣ اختبار APIs باستخدام Postman أو cURL

#### اختبار 1: جلب جميع المستويات (GET)
```bash
curl -X GET http://localhost:1337/api/functions/getAllLevels \
  -H "Content-Type: application/json" \
  -H "X-Parse-Application-Id: PulseOfSound"
```

**النتيجة المتوقعة:**
```json
{
  "message": "All levels fetched successfully",
  "levels": [...]
}
```

#### اختبار 2: جلب المرحلة الحالية للطفل (POST)
```bash
curl -X POST http://localhost:1337/api/functions/getCurrentStageForChild \
  -H "Content-Type: application/json" \
  -H "X-Parse-Application-Id: PulseOfSound" \
  -H "X-Parse-Session-Token: YOUR_SESSION_TOKEN" \
  -d '{"child_id": "CHILD_ID_HERE"}'
```

#### اختبار 3: جلب مراحل مستوى معين (POST)
```bash
curl -X POST http://localhost:1337/api/functions/getLevelGamesForLevel \
  -H "Content-Type: application/json" \
  -H "X-Parse-Application-Id: PulseOfSound" \
  -d '{"level_id": "LEVEL_ID_HERE"}'
```

---

### 3️⃣ اختبار من الفرونت إند (Flutter)

#### تشغيل سكريبت الاختبار
```bash
cd c:\Users\LAPTOP KING\Desktop\PulseOfSound\pulse_of_sound
dart test_child_level_api.dart
```

**قبل التشغيل:**
1. افتح ملف `test_child_level_api.dart`
2. تأكد من تحديث:
   - `baseUrl` (عادة `http://localhost:1337/api/functions`)
   - `masterKey` إذا كنت تريد اختبار Admin APIs

---

## 🐛 الأسباب المحتملة لعدم عمل الربط

### السبب 1: الـ Cloud Functions غير مسجلة
**الحل:**
تحقق من أن `CloudFunctionRegistry.initialize()` يتم استدعاؤه في `app.ts` (السطر 257).

### السبب 2: ملفات الـ modules لم يتم استيرادها
**الحل:**
تحقق من أن `main.ts` يستورد جميع الـ modules:
```typescript
const mainModulesPath = join(__dirname, 'modules');
importFiles(mainModulesPath);
```

### السبب 3: الباك إند لم يتم إعادة بناؤه بعد التعديلات
**الحل:**
```bash
cd c:\Users\LAPTOP KING\Desktop\PulseOfSound\pulsofsound_backend
npm run build
npm run dev
```

### السبب 4: خطأ في عنوان URL في الفرونت إند
**الحل:**
تحقق من `api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = "http://YOUR_IP:1337/api/functions";
  // تأكد من أن الـ IP صحيح
}
```

### السبب 5: مشكلة في الـ CORS
**الحل:**
تحقق من أن CORS مفعّل في `app.ts`:
```typescript
app.use(cors());
```

---

## ✅ قائمة التحقق النهائية

- [ ] الباك إند يعمل بدون أخطاء
- [ ] رسائل "Registered cloud function" تظهر في اللوج
- [ ] اختبار APIs باستخدام cURL أو Postman ينجح
- [ ] `api_config.dart` يحتوي على عنوان URL الصحيح
- [ ] الفرونت إند يستخدم الـ Session Token الصحيح للـ APIs المحمية
- [ ] لا توجد أخطاء في console الفرونت إند

---

## 📞 الخطوات التالية

إذا استمرت المشكلة بعد التحقق من كل ما سبق:

1. **افحص لوج الباك إند** عند محاولة استدعاء API من الفرونت:
   ```bash
   npm run dev
   ```
   ثم راقب اللوج عند تشغيل التطبيق

2. **افحص console الفرونت إند** للبحث عن أخطاء HTTP:
   - افتح Flutter DevTools
   - راقب Network requests

3. **تأكد من أن الـ API يصل للباك إند**:
   - استخدم `print()` في `level_api.dart` و `child_api.dart`
   - تحقق من أن الـ requests تُرسل بالفعل

---

## 🔧 أدوات مساعدة

### فحص Cloud Functions المسجلة
أضف هذا الكود في `app.ts` بعد السطر 257:
```typescript
CloudFunctionRegistry.initialize();

// طباعة جميع الـ Cloud Functions المسجلة
const registeredFunctions = CloudFunctionRegistry.getFunctions();
console.log('\n📋 Registered Cloud Functions:');
registeredFunctions.forEach(fn => {
  console.log(`  ✓ ${fn.name}`);
});
console.log('');
```

### تفعيل Verbose Logging
في `parseConfig` في `app.ts`:
```typescript
logLevel: 'verbose',
verbose: true,
```

---

## 📝 ملاحظات

- جميع APIs الخاصة بـ ChildLevel موجودة في `child_api.dart`
- جميع APIs الخاصة بـ Level و LevelGame موجودة في `level_api.dart`
- تأكد من استخدام Session Token صحيح للـ APIs التي تتطلب `requireUser: true`
