# اختبار تسجيل الدخول كسوبر أدمن في Postman

## الخطوات التفصيلية

### 1. إعداد الطلب في Postman

#### Method & URL
```
POST http://localhost:1337/api/functions/loginUser
```

#### Headers
أضف هذه الـ Headers:

| Key | Value |
|-----|-------|
| `Content-Type` | `application/json` |
| `X-Parse-Application-Id` | `cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7` |
| `X-Parse-Client-Key` | `null` |
| `X-Parse-Master-Key` | `He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY` |

#### Body (JSON)
```json
{
  "username": "your_super_admin_username",
  "password": "your_super_admin_password",
  "platform": "flutter",
  "locale": "ar"
}
```

**مثال:**
```json
{
  "username": "super_admin",
  "password": "super_admin_password",
  "platform": "flutter",
  "locale": "ar"
}
```

---

### 2. Response المتوقع (نجاح)

```json
{
  "id": "4kekaH7EAB",
  "email": "superadmin@test.com",
  "username": "super_admin",
  "fullName": "سوبر أدمن",
  "sessionToken": "r:bb7ab24db8fcbf70a178571736d9f889",
  "role": "SUPER_ADMIN"
}
```

**أو:**
```json
{
  "id": "4kekaH7EAB",
  "email": "superadmin@test.com",
  "username": "super_admin",
  "fullName": "سوبر أدمن",
  "sessionToken": "r:bb7ab24db8fcbf70a178571736d9f889",
  "role": "Admin"
}
```

**ملاحظة:** إذا كان الدور `Admin` أو `SUPER_ADMIN`، يمكنك الوصول إلى جميع وظائف الأدمن.

---

### 3. Response في حالة الخطأ

#### خطأ في اسم المستخدم أو كلمة المرور:
```json
{
  "error": "Invalid username/password."
}
```

#### خطأ في الاتصال:
```json
{
  "error": "تعذر الاتصال بالسيرفر: ..."
}
```

---

### 4. حفظ Session Token تلقائياً

#### أضف Test Script في Postman:

1. افتح الطلب في Postman
2. اذهب إلى تبويب **Tests**
3. أضف هذا الكود:

```javascript
// حفظ Session Token تلقائياً
const response = pm.response.json();

if (response.sessionToken) {
    // حفظ في Environment Variable
    pm.environment.set("session_token", response.sessionToken);
    
    // حفظ في Collection Variable
    pm.collectionVariables.set("session_token", response.sessionToken);
    
    console.log("✅ Session Token saved:", response.sessionToken);
    console.log("✅ Role:", response.role);
    console.log("✅ User ID:", response.id);
}

// التحقق من الدور
if (response.role === "SUPER_ADMIN" || response.role === "Admin") {
    console.log("✅ تم تسجيل الدخول كأدمن/سوبر أدمن بنجاح!");
} else {
    console.log("⚠️ الدور:", response.role);
}
```

---

### 5. استخدام Session Token في الطلبات التالية

بعد تسجيل الدخول، أضف هذا الـ Header في جميع الطلبات:

| Key | Value |
|-----|-------|
| `X-Parse-Session-Token` | `{{session_token}}` |

**أو يدوياً:**
```
X-Parse-Session-Token: r:bb7ab24db8fcbf70a178571736d9f889
```

---

### 6. اختبار الصلاحيات بعد تسجيل الدخول

#### اختبار 1: جلب جميع الأدمن (SUPER_ADMIN فقط)
```
GET http://localhost:1337/api/functions/getAllAdmins
```

**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Session-Token: {{session_token}}
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Response المتوقع (إذا كنت SUPER_ADMIN):**
```json
[
  {
    "id": "usr128",
    "fullName": "مدير النظام",
    "username": "admin_user",
    "email": "admin@example.com",
    "mobile": "0999111222",
    "role": "Admin"
  }
]
```

**Response في حالة عدم وجود صلاحيات:**
```json
{
  "code": 141,
  "error": "Access denied. Only SUPER_ADMIN can view admins."
}
```

---

#### اختبار 2: حذف أدمن (SUPER_ADMIN فقط)
```
DELETE http://localhost:1337/api/functions/deleteAdmin
```

**Body (JSON):**
```json
{
  "adminId": "usr128"
}
```

---

### 7. Pre-request Script (اختياري)

لإضافة Session Token تلقائياً لجميع الطلبات:

1. في Collection Settings → Pre-request Script
2. أضف:

```javascript
// إضافة Session Token تلقائياً إذا كان موجوداً
const sessionToken = pm.environment.get("session_token") || pm.collectionVariables.get("session_token");

if (sessionToken) {
    pm.request.headers.add({
        key: "X-Parse-Session-Token",
        value: sessionToken
    });
}
```

---

### 8. مثال كامل للطلب في Postman

#### Request Details:
```
Method: POST
URL: http://localhost:1337/api/functions/loginUser
```

#### Headers Tab:
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Client-Key: null
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

#### Body Tab (raw JSON):
```json
{
  "username": "super_admin",
  "password": "your_password_here",
  "platform": "flutter",
  "locale": "ar"
}
```

#### Tests Tab:
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has sessionToken", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('sessionToken');
});

pm.test("User is Admin or SUPER_ADMIN", function () {
    var jsonData = pm.response.json();
    var role = jsonData.role;
    pm.expect(role === "Admin" || role === "SUPER_ADMIN").to.be.true;
});

// حفظ Session Token
const response = pm.response.json();
if (response.sessionToken) {
    pm.environment.set("session_token", response.sessionToken);
    console.log("✅ Session Token saved:", response.sessionToken);
}
```

---

### 9. التحقق من النجاح

بعد إرسال الطلب، تحقق من:

1. ✅ Status Code = `200`
2. ✅ Response يحتوي على `sessionToken`
3. ✅ Response يحتوي على `role` = `"Admin"` أو `"SUPER_ADMIN"`
4. ✅ Session Token تم حفظه في Environment Variables

---

### 10. اختبارات إضافية بعد تسجيل الدخول

بعد تسجيل الدخول كسوبر أدمن، اختبر:

- [ ] ✅ `GET /getAllAdmins` - يجب أن يعمل
- [ ] ✅ `DELETE /deleteAdmin` - يجب أن يعمل
- [ ] ✅ `GET /getAllDoctors` - يجب أن يعمل
- [ ] ✅ `POST /addEditAdmin` - يجب أن يعمل
- [ ] ✅ جميع وظائف الأدمن الأخرى

---

### 11. استكشاف الأخطاء

#### المشكلة: Status Code 401
**السبب:** اسم المستخدم أو كلمة المرور خاطئة  
**الحل:** تحقق من بيانات تسجيل الدخول

#### المشكلة: Status Code 400
**السبب:** البيانات المرسلة غير صحيحة  
**الحل:** تحقق من Body (JSON format)

#### المشكلة: لا يمكن جلب الأدمن
**السبب:** المستخدم ليس SUPER_ADMIN  
**الحل:** تأكد أن الدور في Response هو `SUPER_ADMIN` أو `Admin`

#### المشكلة: Session Token لا يعمل
**السبب:** Token منتهي الصلاحية أو غير صحيح  
**الحل:** سجّل الدخول مرة أخرى واحصل على token جديد

---

### 12. نصائح مهمة

1. **احفظ Session Token فوراً:** بعد تسجيل الدخول، احفظ `sessionToken` للاستخدام في الطلبات التالية
2. **تحقق من الدور:** تأكد أن `role` في Response هو `SUPER_ADMIN` أو `Admin`
3. **استخدم Environment Variables:** لتسهيل التبديل بين البيئات (Development/Production)
4. **اختبر الصلاحيات:** بعد تسجيل الدخول، اختبر `getAllAdmins` للتأكد من الصلاحيات

---

## مثال سريع (Copy & Paste)

### Request في Postman:

**URL:**
```
POST http://localhost:1337/api/functions/loginUser
```

**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Client-Key: null
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Body:**
```json
{
  "username": "super_admin",
  "password": "your_password",
  "platform": "flutter",
  "locale": "ar"
}
```

**Send** → تحقق من Response → احفظ `sessionToken` → استخدمه في الطلبات التالية!

---

## Checklist للاختبار

- [ ] ✅ إعداد Postman (Headers صحيحة)
- [ ] ✅ إدخال بيانات تسجيل الدخول (username, password)
- [ ] ✅ إرسال الطلب
- [ ] ✅ التحقق من Status Code = 200
- [ ] ✅ التحقق من وجود sessionToken في Response
- [ ] ✅ التحقق من Role = "Admin" أو "SUPER_ADMIN"
- [ ] ✅ حفظ sessionToken
- [ ] ✅ اختبار getAllAdmins للتأكد من الصلاحيات
- [ ] ✅ اختبار deleteAdmin للتأكد من الصلاحيات

---

**ملاحظة:** تأكد أن السيرفر يعمل على `http://localhost:1337` قبل الاختبار!

