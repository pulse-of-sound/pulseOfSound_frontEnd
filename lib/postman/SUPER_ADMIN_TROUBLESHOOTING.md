# حل مشكلة تسجيل دخول السوبر أدمن

## المشكلة: Invalid username/password

إذا ظهر هذا الخطأ:
```json
{
  "code": -1,
  "error": "Invalid username/password."
}
```

### الأسباب المحتملة:

1. ❌ **اسم المستخدم غير صحيح**
2. ❌ **كلمة المرور غير صحيحة**
3. ❌ **حساب السوبر أدمن غير موجود**
4. ❌ **الدور غير صحيح في قاعدة البيانات**

---

## الحلول:

### الحل 1: التحقق من بيانات تسجيل الدخول

#### في Postman:
1. تحقق من **username** - يجب أن يكون مطابقاً تماماً (حساس لحالة الأحرف)
2. تحقق من **password** - يجب أن يكون مطابقاً تماماً
3. تأكد من عدم وجود مسافات إضافية

**مثال صحيح:**
```json
{
  "username": "admin_test2",
  "password": "exact_password_here",
  "platform": "flutter",
  "locale": "ar"
}
```

---

### الحل 2: إنشاء سوبر أدمن جديد

إذا لم يكن لديك حساب سوبر أدمن، يمكنك إنشاءه بطريقتين:

#### الطريقة 1: من Parse Dashboard

1. افتح Parse Dashboard
2. اذهب إلى **Core** → **Users**
3. أنشئ مستخدم جديد أو عدّل مستخدم موجود
4. في **Roles**، أضف دور `SUPER_ADMIN` أو `Admin`

#### الطريقة 2: من Backend API

استخدم `addEditAdmin` مع Master Key:

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

**Body:**
```json
{
  "fullName": "سوبر أدمن",
  "username": "super_admin",
  "password": "123456",
  "mobile": "0999999999",
  "email": "superadmin@test.com"
}
```

**ملاحظة:** بعد الإنشاء، يجب تعيين الدور `SUPER_ADMIN` من Parse Dashboard.

---

### الحل 3: استخدام حساب أدمن موجود

إذا كان لديك حساب أدمن عادي، جرب تسجيل الدخول به:

**Body:**
```json
{
  "username": "admin_test2",
  "password": "your_admin_password",
  "platform": "flutter",
  "locale": "ar"
}
```

**ملاحظة:** حساب `admin_test2` الذي ظهر في الـ logs قد يكون أدمن عادي وليس سوبر أدمن.

---

### الحل 4: التحقق من قاعدة البيانات مباشرة

#### من Parse Dashboard:

1. افتح Parse Dashboard
2. اذهب إلى **Core** → **Users**
3. ابحث عن المستخدم
4. تحقق من:
   - ✅ **username** صحيح
   - ✅ **password** (لن تراه، لكن يمكنك إعادة تعيينه)
   - ✅ **Roles** يحتوي على `SUPER_ADMIN` أو `Admin`

---

### الحل 5: إعادة تعيين كلمة المرور

إذا نسيت كلمة المرور:

#### من Parse Dashboard:

1. افتح Parse Dashboard
2. اذهب إلى **Core** → **Users**
3. اختر المستخدم
4. عدّل **password** (سيكون مشفراً، لكن يمكنك تغييره)

#### أو استخدم Parse REST API:

```
PUT http://localhost:1337/api/classes/_User/USER_ID
```

**Headers:**
```
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
Content-Type: application/json
```

**Body:**
```json
{
  "password": "new_password_here"
}
```

---

## خطوات استكشاف المشكلة:

### 1. اختبر تسجيل الدخول بحساب أدمن عادي

```json
{
  "username": "admin_test2",
  "password": "password_here",
  "platform": "flutter",
  "locale": "ar"
}
```

إذا نجح → المشكلة في حساب السوبر أدمن  
إذا فشل → المشكلة في بيانات تسجيل الدخول

---

### 2. تحقق من Response بالتفصيل

في Postman، افتح **Console** (View → Show Postman Console) لرؤية التفاصيل الكاملة.

---

### 3. اختبر مع Master Key مباشرة

إذا كان لديك Master Key، يمكنك:

```
GET http://localhost:1337/api/classes/_User?where={"username":"super_admin"}
```

**Headers:**
```
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

---

## إنشاء سوبر أدمن جديد (خطوة بخطوة)

### الخطوة 1: إنشاء مستخدم أدمن

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

**Body:**
```json
{
  "fullName": "سوبر أدمن الرئيسي",
  "username": "super_admin_main",
  "password": "SuperAdmin123!",
  "mobile": "0999999999",
  "email": "superadmin@test.com"
}
```

### الخطوة 2: تعيين دور SUPER_ADMIN

من Parse Dashboard:
1. اذهب إلى **Core** → **Users**
2. ابحث عن المستخدم الذي أنشأته
3. اذهب إلى **Roles**
4. أضف دور `SUPER_ADMIN`

### الخطوة 3: تسجيل الدخول

```json
{
  "username": "super_admin_main",
  "password": "SuperAdmin123!",
  "platform": "flutter",
  "locale": "ar"
}
```

---

## نصائح مهمة:

1. **استخدم Master Key:** عند إنشاء سوبر أدمن، استخدم Master Key في Headers
2. **تحقق من Parse Dashboard:** تأكد من وجود المستخدم والدور
3. **اختبر بحساب أدمن عادي أولاً:** للتأكد من أن المشكلة ليست في الاتصال
4. **تحقق من Console:** في Postman، افتح Console لرؤية التفاصيل

---

## مثال كامل لإنشاء سوبر أدمن:

### 1. إنشاء المستخدم:

```
POST http://localhost:1337/api/functions/addEditAdmin

Headers:
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY

Body:
{
  "fullName": "سوبر أدمن",
  "username": "super_admin_new",
  "password": "Super123456",
  "mobile": "0999111222",
  "email": "super@test.com"
}
```

### 2. من Parse Dashboard:
- اذهب إلى Users → ابحث عن `super_admin_new`
- أضف دور `SUPER_ADMIN`

### 3. تسجيل الدخول:

```
POST http://localhost:1337/api/functions/loginUser

Body:
{
  "username": "super_admin_new",
  "password": "Super123456",
  "platform": "flutter",
  "locale": "ar"
}
```

---

## Checklist للتحقق:

- [ ] ✅ المستخدم موجود في Parse Dashboard
- [ ] ✅ Username صحيح (بدون مسافات)
- [ ] ✅ Password صحيح
- [ ] ✅ الدور `SUPER_ADMIN` أو `Admin` مضاف
- [ ] ✅ السيرفر يعمل على `localhost:1337`
- [ ] ✅ Headers صحيحة في Postman
- [ ] ✅ Body format صحيح (JSON)

---

**إذا استمرت المشكلة:** تحقق من Parse Dashboard مباشرة للتأكد من وجود المستخدم وبياناته.

