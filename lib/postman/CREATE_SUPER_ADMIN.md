# كيفية إنشاء سوبر أدمن جديد

هذا الدليل يشرح كيفية إنشاء حساب سوبر أدمن جديد خطوة بخطوة.

---

## الطريقة 1: استخدام Postman (موصى به)

### الخطوة 1: إنشاء أدمن جديد

**Request:**
```
POST http://localhost:1337/api/functions/addEditAdmin
```

**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Body (JSON):**
```json
{
  "fullName": "سوبر أدمن",
  "username": "super_admin",
  "password": "SuperAdmin123",
  "mobile": "0999999999",
  "email": "superadmin@test.com"
}
```

**Expected Response:**
```json
{
  "message": "Admin created and logged in successfully",
  "userId": "APaVtwFzQI",
  "username": "super_admin",
  "role": "Admin"
}
```

**ملاحظة:** في هذه المرحلة، المستخدم لديه role "Admin" وليس "SUPER_ADMIN". يجب تعيين دور SUPER_ADMIN في الخطوة التالية.

---

### الخطوة 2: تعيين دور SUPER_ADMIN

هناك طريقتان لتعيين دور SUPER_ADMIN:

#### الطريقة أ: من Parse Dashboard (أسهل)

1. **افتح Parse Dashboard:**
   - افتح المتصفح واذهب إلى: `http://localhost:1337/parse`
   - أو الرابط الخاص بـ Parse Dashboard الخاص بك

2. **اذهب إلى Core → Users:**
   - من القائمة الجانبية، اختر "Core"
   - ثم اختر "Users"

3. **ابحث عن المستخدم:**
   - ابحث عن المستخدم `super_admin` الذي أنشأته في الخطوة 1
   - اضغط على المستخدم لفتح تفاصيله

4. **أضف دور SUPER_ADMIN:**
   - في قسم "Roles" أو "ACL"، ابحث عن حقل "roles"
   - أضف دور `SUPER_ADMIN` أو `SuperAdmin`
   - احفظ التغييرات

#### الطريقة ب: من خلال API (متقدم)

إذا كنت تريد تعيين الدور من خلال API، يمكنك استخدام Parse REST API:

**Request:**
```
PUT http://localhost:1337/parse/roles/SUPER_ADMIN
```

**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Body (JSON):**
```json
{
  "users": {
    "__op": "AddRelation",
    "objects": [
      {
        "__type": "Pointer",
        "className": "_User",
        "objectId": "APaVtwFzQI"
      }
    ]
  }
}
```

**ملاحظة:** استبدل `APaVtwFzQI` بـ `userId` الذي حصلت عليه من الخطوة 1.

---

### الخطوة 3: التحقق من تسجيل الدخول

**Request:**
```
POST http://localhost:1337/api/functions/loginUser
```

**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Body (JSON):**
```json
{
  "username": "super_admin",
  "password": "SuperAdmin123",
  "platform": "flutter",
  "locale": "ar"
}
```

**Expected Response:**
```json
{
  "id": "APaVtwFzQI",
  "email": "superadmin@test.com",
  "username": "super_admin",
  "createdAt": {
    "__type": "Date",
    "iso": "2025-12-08T23:42:29.429Z"
  },
  "updatedAt": {
    "__type": "Date",
    "iso": "2025-12-08T23:42:29.429Z"
  },
  "fullName": "سوبر أدمن",
  "sessionToken": "r:3e5c7ca90621a1bb4292b8556c1d4e09"
}
```

**التحقق من Role:**
بعد تسجيل الدخول، تحقق من role المستخدم:

**Request:**
```
GET http://localhost:1337/parse/classes/_User/APaVtwFzQI?include=role
```

**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Expected Response:**
```json
{
  "objectId": "APaVtwFzQI",
  "role": {
    "objectId": "FyUuwunrqH",
    "name": "SUPER_ADMIN",
    "createdAt": "2025-09-21T16:58:30.360Z",
    "updatedAt": "2025-12-08T23:42:29.527Z",
    "__type": "Object",
    "className": "_Role"
  },
  "username": "super_admin",
  "fullName": "سوبر أدمن",
  "mobile": "0999999999",
  "email": "superadmin@test.com"
}
```

**ملاحظة:** يجب أن يكون `role.name` = `"SUPER_ADMIN"` أو `"SuperAdmin"`.

---

## الطريقة 2: استخدام Flutter App

يمكنك أيضاً إنشاء سوبر أدمن من خلال التطبيق نفسه:

### الخطوة 1: تسجيل الدخول كأدمن عادي

استخدم حساب أدمن موجود لديه صلاحيات إضافة أدمن.

### الخطوة 2: إضافة أدمن جديد

1. افتح التطبيق
2. اذهب إلى "إدارة الأدمن"
3. اضغط على زر "+" لإضافة أدمن جديد
4. أدخل البيانات:
   - **الاسم الكامل:** سوبر أدمن
   - **اسم المستخدم:** super_admin
   - **كلمة المرور:** SuperAdmin123
   - **رقم الموبايل:** 0999999999
   - **البريد الإلكتروني:** superadmin@test.com
5. اضغط "إضافة الأدمن"

### الخطوة 3: تعيين دور SUPER_ADMIN

بعد إنشاء الأدمن، يجب تعيين دور SUPER_ADMIN من Parse Dashboard (كما في الطريقة 1، الخطوة 2).

---

## الطريقة 3: إنشاء سوبر أدمن مباشرة من Parse Dashboard

### الخطوة 1: إنشاء مستخدم جديد

1. افتح Parse Dashboard
2. اذهب إلى Core → Users
3. اضغط "Add a row"
4. أدخل البيانات:
   - **username:** super_admin
   - **password:** SuperAdmin123
   - **email:** superadmin@test.com
   - **fullName:** سوبر أدمن
   - **mobile:** 0999999999
5. احفظ المستخدم

### الخطوة 2: تعيين دور SUPER_ADMIN

1. في نفس صفحة المستخدم، ابحث عن قسم "Roles"
2. أضف دور `SUPER_ADMIN` أو `SuperAdmin`
3. احفظ التغييرات

---

## التحقق من نجاح العملية

بعد إنشاء سوبر أدمن وتعيين الدور، اختبر الصلاحيات:

### ✅ اختبار 1: تسجيل الدخول
- يجب أن يعمل تسجيل الدخول بنجاح
- يجب أن يعود `sessionToken`

### ✅ اختبار 2: جلب قائمة الأدمن
```
GET http://localhost:1337/api/functions/getAllAdmins
Headers: X-Parse-Session-Token: [sessionToken]
```
- يجب أن تعمل بدون خطأ "Access denied"

### ✅ اختبار 3: حذف طبيب
```
DELETE http://localhost:1337/api/functions/deleteDoctor
Body: {"doctorId": "..."}
Headers: X-Parse-Session-Token: [sessionToken]
```
- يجب أن يعمل بدون خطأ "You do not have the authority"

### ✅ اختبار 4: حذف أدمن
```
DELETE http://localhost:1337/api/functions/deleteAdmin
Body: {"adminId": "..."}
Headers: X-Parse-Session-Token: [sessionToken]
```
- يجب أن يعمل بدون خطأ

---

## استكشاف الأخطاء

### المشكلة: "Access denied. Only SUPER_ADMIN can view admins."
**السبب:** الدور لم يتم تعيينه بشكل صحيح  
**الحل:** 
1. تحقق من أن role.name = "SUPER_ADMIN" أو "SuperAdmin"
2. أعد تعيين الدور من Parse Dashboard
3. أعد تسجيل الدخول

### المشكلة: "You do not have the authority to delete the doctor."
**السبب:** نفس المشكلة - الدور غير صحيح  
**الحل:** نفس الحل أعلاه

### المشكلة: لا يمكن العثور على دور SUPER_ADMIN في Parse Dashboard
**السبب:** الدور غير موجود في النظام  
**الحل:** 
1. أنشئ دور SUPER_ADMIN من Parse Dashboard:
   - اذهب إلى Core → Roles
   - اضغط "Add a row"
   - أدخل name = "SUPER_ADMIN"
   - احفظ

---

## ملاحظات مهمة

1. **الأمان:** 
   - استخدم كلمة مرور قوية لسوبر أدمن
   - لا تشارك بيانات تسجيل الدخول
   - احفظ Master Key بشكل آمن

2. **البيئة:**
   - تأكد من أن Backend يعمل (`http://localhost:1337`)
   - تأكد من أن Parse Dashboard متاح

3. **الأدوار:**
   - قد يكون اسم الدور `SUPER_ADMIN` أو `SuperAdmin` حسب إعدادات Backend
   - تحقق من الاسم الصحيح من Backend

---

## مثال كامل في Postman

### Collection Structure:
```
1. Create Admin
   POST /api/functions/addEditAdmin
   
2. Assign SUPER_ADMIN Role (من Parse Dashboard)
   
3. Login as Super Admin
   POST /api/functions/loginUser
   
4. Get User Role
   GET /parse/classes/_User/{userId}?include=role
   
5. Test: Get All Admins
   GET /api/functions/getAllAdmins
   
6. Test: Delete Doctor
   DELETE /api/functions/deleteDoctor
```

---

## نصائح إضافية

1. **احفظ Session Token:** بعد تسجيل الدخول، احفظ `sessionToken` للاستخدام في الطلبات التالية

2. **استخدم Environment Variables:** في Postman، احفظ:
   - `base_url`: `http://localhost:1337`
   - `app_id`: `cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7`
   - `master_key`: `He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY`
   - `session_token`: (بعد تسجيل الدخول)

3. **اختبار دوري:** اختبر صلاحيات سوبر أدمن بشكل دوري للتأكد من أن كل شيء يعمل

---

## الخلاصة

لإنشاء سوبر أدمن جديد:
1. ✅ أنشئ أدمن جديد باستخدام `addEditAdmin` API
2. ✅ عيّن دور `SUPER_ADMIN` من Parse Dashboard
3. ✅ اختبر تسجيل الدخول والصلاحيات

إذا واجهت أي مشاكل، راجع قسم "استكشاف الأخطاء" أعلاه.

