# دليل سريع: اختبار تسجيل دخول سوبر أدمن في Postman

## 🚀 الخطوات السريعة (5 دقائق)

### الخطوة 1: إعداد الطلب

1. افتح Postman
2. أنشئ Request جديد
3. اختر Method: **POST**
4. أدخل URL:
```
http://localhost:1337/api/functions/loginUser
```

---

### الخطوة 2: إضافة Headers

اذهب إلى تبويب **Headers** وأضف:

| Key | Value |
|-----|-------|
| `Content-Type` | `application/json` |
| `X-Parse-Application-Id` | `cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7` |
| `X-Parse-Client-Key` | `null` |
| `X-Parse-Master-Key` | `He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY` |

---

### الخطوة 3: إضافة Body

اذهب إلى تبويب **Body**:
1. اختر **raw**
2. اختر **JSON** من القائمة المنسدلة
3. أدخل:

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
  "password": "123456",
  "platform": "flutter",
  "locale": "ar"
}
```

---

### الخطوة 4: إضافة Test Script (اختياري لكن مفيد)

اذهب إلى تبويب **Tests** وأضف:

```javascript
// التحقق من نجاح الطلب
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

const response = pm.response.json();

// حفظ Session Token تلقائياً
if (response.sessionToken) {
    pm.environment.set("session_token", response.sessionToken);
    pm.collectionVariables.set("session_token", response.sessionToken);
    
    console.log("✅ Session Token:", response.sessionToken);
    console.log("✅ Role:", response.role);
    console.log("✅ Username:", response.username);
    
    // التحقق من أن المستخدم أدمن أو سوبر أدمن
    if (response.role === "SUPER_ADMIN" || response.role === "Admin") {
        console.log("✅ تم تسجيل الدخول كأدمن/سوبر أدمن بنجاح!");
    }
}
```

---

### الخطوة 5: إرسال الطلب

اضغط **Send** ✅

---

### الخطوة 6: التحقق من النتيجة

**Response المتوقع (نجاح):**
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
  "username": "admin_test2",
  "fullName": "مدير النظام",
  "sessionToken": "r:bb7ab24db8fcbf70a178571736d9f889",
  "role": "Admin"
}
```

---

### الخطوة 7: اختبار الصلاحيات

بعد تسجيل الدخول، اختبر:

#### اختبار 1: جلب جميع الأدمن
```
GET http://localhost:1337/api/functions/getAllAdmins
```

**Headers:**
- أضف `X-Parse-Session-Token: r:your_token_here`

**إذا نجح:** أنت سوبر أدمن ✅  
**إذا فشل (400):** أنت لست سوبر أدمن ❌

---

## 📋 Checklist سريع

- [ ] ✅ URL صحيح: `http://localhost:1337/api/functions/loginUser`
- [ ] ✅ Method: POST
- [ ] ✅ Headers: 4 headers (Content-Type, App-Id, Client-Key, Master-Key)
- [ ] ✅ Body: JSON مع username و password
- [ ] ✅ Status Code = 200
- [ ] ✅ Response يحتوي على `sessionToken`
- [ ] ✅ Response يحتوي على `role` = "Admin" أو "SUPER_ADMIN"
- [ ] ✅ Session Token تم حفظه

---

## 🔍 استكشاف الأخطاء

### ❌ Status Code 401
**المشكلة:** اسم المستخدم أو كلمة المرور خاطئة  
**الحل:** تحقق من بيانات تسجيل الدخول

### ❌ Status Code 400
**المشكلة:** Body غير صحيح  
**الحل:** تحقق من JSON format

### ❌ لا يمكن جلب getAllAdmins
**المشكلة:** المستخدم ليس SUPER_ADMIN  
**الحل:** تأكد أن `role` في Response هو `SUPER_ADMIN`

---

## 💡 نصيحة

**احفظ Session Token فوراً!** بعد تسجيل الدخول، انسخ `sessionToken` من Response واستخدمه في جميع الطلبات التالية.

---

## 📸 مثال كامل للطلب

```
POST http://localhost:1337/api/functions/loginUser

Headers:
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Client-Key: null
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY

Body (JSON):
{
  "username": "super_admin",
  "password": "your_password",
  "platform": "flutter",
  "locale": "ar"
}
```

**Send** → تحقق من Response → احفظ `sessionToken` → ابدأ الاختبار! 🎉

