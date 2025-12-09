# دليل سريع: إنشاء سوبر أدمن جديد

## الطريقة السريعة (Postman)

### 1. استيراد Postman Collection

1. افتح Postman
2. اضغط على **Import**
3. اختر الملف: `CREATE_SUPER_ADMIN_POSTMAN.json`
4. اضغط **Import**

---

### 2. تنفيذ الخطوات بالترتيب

#### ✅ الخطوة 1: إنشاء أدمن جديد

1. في Postman، افتح: **الخطوة 1: إنشاء أدمن جديد** → **Create Admin (بدون Session Token)**
2. اضغط **Send**
3. تحقق من Response:
   ```json
   {
     "message": "Admin created and logged in successfully",
     "userId": "APaVtwFzQI",
     "username": "super_admin",
     "role": "Admin"
   }
   ```
4. **احفظ `userId`** - سيتم حفظه تلقائياً في Variables

**⚠️ ملاحظة:** الدور الحالي هو "Admin" وليس "SUPER_ADMIN". يجب تعيين دور SUPER_ADMIN في الخطوة التالية.

---

#### ✅ الخطوة 2: تعيين دور SUPER_ADMIN (من Parse Dashboard)

**هذه الخطوة يجب تنفيذها من Parse Dashboard:**

1. افتح Parse Dashboard: `http://localhost:1337/parse`
2. اذهب إلى: **Core** → **Users**
3. ابحث عن المستخدم: `super_admin`
4. اضغط على المستخدم لفتح تفاصيله
5. في قسم **Roles**، أضف دور: `SUPER_ADMIN` أو `SuperAdmin`
6. احفظ التغييرات

**بديل:** يمكنك استخدام Parse REST API (متقدم)

---

#### ✅ الخطوة 3: التحقق من المستخدم

1. في Postman، افتح: **الخطوة 2: التحقق من المستخدم** → **Get User Details (with role)**
2. **تأكد من أن `user_id` موجود في Variables** (يتم حفظه تلقائياً من الخطوة 1)
3. اضغط **Send**
4. تحقق من Response:
   ```json
   {
     "objectId": "APaVtwFzQI",
     "role": {
       "name": "SUPER_ADMIN"
     },
     "username": "super_admin"
   }
   ```

**✅ إذا كان `role.name = "SUPER_ADMIN"` → تم بنجاح!**  
**❌ إذا كان `role.name = "Admin"` → يجب تعيين دور SUPER_ADMIN من Parse Dashboard**

---

#### ✅ الخطوة 4: تسجيل الدخول

1. في Postman، افتح: **الخطوة 3: تسجيل الدخول** → **Login as Super Admin**
2. **تعديل Body إذا لزم الأمر:**
   ```json
   {
     "username": "super_admin",
     "password": "SuperAdmin123",
     "platform": "flutter",
     "locale": "ar"
   }
   ```
3. اضغط **Send**
4. تحقق من Response:
   ```json
   {
     "id": "APaVtwFzQI",
     "username": "super_admin",
     "sessionToken": "r:3e5c7ca90621a1bb4292b8556c1d4e09"
   }
   ```
5. **سيتم حفظ `sessionToken` تلقائياً** في Variables

---

#### ✅ الخطوة 5: اختبار الصلاحيات

**اختبار 1: جلب قائمة الأدمن**

1. في Postman، افتح: **الخطوة 4: اختبار الصلاحيات** → **Test: Get All Admins**
2. اضغط **Send**
3. **Expected Response:**
   ```json
   [
     {
       "id": "...",
       "fullName": "...",
       "username": "...",
       "role": "Admin"
     }
   ]
   ```
4. **إذا ظهر خطأ "Access denied"** → الدور غير صحيح، أعد الخطوة 2

**اختبار 2: حذف طبيب**

1. في Postman، افتح: **Test: Delete Doctor**
2. **استبدل `doctor_id_here`** بـ ID طبيب موجود
3. اضغط **Send**
4. **Expected Response:**
   ```json
   {
     "message": "Doctor deleted successfully"
   }
   ```
5. **إذا ظهر خطأ "You do not have the authority"** → الدور غير صحيح

---

## الطريقة اليدوية (بدون Postman Collection)

### الخطوة 1: إنشاء أدمن

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
  "password": "SuperAdmin123",
  "mobile": "0999999999",
  "email": "superadmin@test.com"
}
```

**احفظ `userId` من Response**

---

### الخطوة 2: تعيين دور SUPER_ADMIN

من Parse Dashboard:
1. افتح: `http://localhost:1337/parse`
2. **Core** → **Users** → ابحث عن `super_admin`
3. أضف دور `SUPER_ADMIN` في قسم **Roles**
4. احفظ

---

### الخطوة 3: تسجيل الدخول

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

**Body:**
```json
{
  "username": "super_admin",
  "password": "SuperAdmin123",
  "platform": "flutter",
  "locale": "ar"
}
```

**احفظ `sessionToken` من Response**

---

## استكشاف الأخطاء

### ❌ المشكلة: "Access denied. Only SUPER_ADMIN can view admins."

**السبب:** الدور غير صحيح  
**الحل:**
1. تحقق من Parse Dashboard - يجب أن يكون role = "SUPER_ADMIN"
2. أعد تعيين الدور
3. أعد تسجيل الدخول

---

### ❌ المشكلة: "You do not have the authority to delete the doctor."

**السبب:** نفس المشكلة - الدور غير صحيح  
**الحل:** نفس الحل أعلاه

---

### ❌ المشكلة: لا يمكن العثور على دور SUPER_ADMIN في Parse Dashboard

**السبب:** الدور غير موجود في النظام  
**الحل:**
1. من Parse Dashboard: **Core** → **Roles**
2. اضغط **Add a row**
3. أدخل name = "SUPER_ADMIN"
4. احفظ

---

## Checklist

قبل البدء:
- [ ] ✅ Backend يعمل على `http://localhost:1337`
- [ ] ✅ Parse Dashboard متاح
- [ ] ✅ Postman Collection مستورد (اختياري)

بعد الخطوة 1:
- [ ] ✅ تم إنشاء الأدمن بنجاح
- [ ] ✅ تم حفظ `userId`

بعد الخطوة 2:
- [ ] ✅ تم تعيين دور SUPER_ADMIN من Parse Dashboard
- [ ] ✅ تم التحقق من الدور (Get User Details)

بعد الخطوة 3:
- [ ] ✅ تم تسجيل الدخول بنجاح
- [ ] ✅ تم حفظ `sessionToken`

بعد الخطوة 4:
- [ ] ✅ يمكن جلب قائمة الأدمن
- [ ] ✅ يمكن حذف طبيب
- [ ] ✅ يمكن حذف أدمن

---

## نصائح

1. **استخدم Postman Collection:** يوفر الوقت ويحفظ Variables تلقائياً
2. **احفظ Session Token:** بعد تسجيل الدخول، احفظ `sessionToken` للاستخدام في الطلبات التالية
3. **تحقق من Parse Dashboard:** إذا استمرت المشاكل، تحقق من Parse Dashboard مباشرة
4. **اختبر دورياً:** اختبر صلاحيات سوبر أدمن بشكل دوري

---

## الخلاصة

**الخطوات الأساسية:**
1. ✅ أنشئ أدمن جديد (`addEditAdmin`)
2. ✅ عيّن دور SUPER_ADMIN (من Parse Dashboard)
3. ✅ سجّل الدخول (`loginUser`)
4. ✅ اختبر الصلاحيات

**الوقت المتوقع:** 5-10 دقائق

---

## الملفات المرجعية

- `CREATE_SUPER_ADMIN.md` - دليل شامل ومفصل
- `CREATE_SUPER_ADMIN_POSTMAN.json` - Postman Collection
- `SUPER_ADMIN_TROUBLESHOOTING.md` - حل المشاكل الشائعة

