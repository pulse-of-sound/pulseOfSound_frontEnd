# دليل اختبار APIs في Postman - نبض الصوت

## الإعدادات الأساسية

### 1. Base URL
```
http://localhost:1337/api/functions
```

### 2. Headers المشتركة
جميع الطلبات تحتاج هذه الـ Headers:

```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

### 3. Session Token
بعد تسجيل الدخول، احفظ `sessionToken` من الـ Response وأضفه في Header:
```
X-Parse-Session-Token: r:your_session_token_here
```

---

## 1. اختبارات User APIs

### ✅ 1.1 Health Check (اختياري)
**Method:** GET  
**URL:** `http://localhost:1337/api/health`  
**Headers:** فقط `X-Parse-Application-Id`

**Expected Response:**
```json
{
  "status": "ok"
}
```

---

### ✅ 1.2 تسجيل الدخول (Login)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/loginUser`  
**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Client-Key: null
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Body (JSON):**
```json
{
  "username": "admin_test2",
  "password": "your_password",
  "platform": "flutter",
  "locale": "ar"
}
```

**Expected Response:**
```json
{
  "id": "4kekaH7EAB",
  "email": "admin2@test.com",
  "username": "admin_test2",
  "fullName": "مدير النظام",
  "sessionToken": "r:bb7ab24db8fcbf70a178571736d9f889",
  "role": "Admin"
}
```

**⚠️ مهم:** احفظ `sessionToken` للاستخدام في الطلبات التالية!

---

### ✅ 1.3 جلب جميع الأطباء
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getAllDoctors`  
**Headers:**
```
Content-Type: application/json
X-Parse-Application-Id: cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7
X-Parse-Session-Token: r:your_session_token_here
X-Parse-Master-Key: He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY
```

**Expected Response:**
```json
[
  {
    "id": "9wmq1qrbhU",
    "fullName": "د. أحمد علي",
    "username": "doctor_test",
    "email": "doctor@test.com",
    "mobile": "0988888888",
    "role": "Doctor"
  }
]
```

---

### ✅ 1.4 إضافة/تعديل طبيب
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/addEditDoctor`  
**Headers:** (نفس headers جلب الأطباء + Session Token)

**Body (JSON):**
```json
{
  "fullName": "د. محمد أحمد",
  "username": "dr_mohammad",
  "password": "123456",
  "mobile": "0999999999",
  "email": "dr_mohammad@test.com"
}
```

**Expected Response (نجاح):**
```json
{
  "message": "Doctor created and logged in successfully",
  "userId": "mi59Yv9HuO",
  "username": "dr_mohammad",
  "role": "Doctor"
}
```

---

### ✅ 1.5 حذف طبيب
**Method:** DELETE  
**URL:** `http://localhost:1337/api/functions/deleteDoctor`  
**Headers:** (نفس headers جلب الأطباء + Session Token)

**Body (JSON):**
```json
{
  "doctorId": "9wmq1qrbhU"
}
```

**Expected Response (نجاح):**
```json
{
  "message": "The doctor was successfully deleted."
}
```

**Expected Response (خطأ - لا صلاحية):**
```json
{
  "code": 141,
  "error": "You do not have the authority to delete the doctor."
}
```

---

### ✅ 1.6 جلب جميع الأخصائيين
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getAllSpecialists`  
**Headers:** (نفس headers جلب الأطباء)

---

### ✅ 1.7 إضافة/تعديل أخصائي
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/addEditSpecialist`  
**Body (JSON):**
```json
{
  "fullName": "د. خالد",
  "username": "khaled_specialist",
  "password": "123456",
  "mobile": "0999888777",
  "email": "khaled@example.com"
}
```

---

### ✅ 1.8 حذف أخصائي
**Method:** DELETE  
**URL:** `http://localhost:1337/api/functions/deleteSpecialist`  
**Body (JSON):**
```json
{
  "specialistId": "usr127"
}
```

---

### ✅ 1.9 جلب جميع الأدمن (SUPER_ADMIN فقط)
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getAllAdmins`  
**Headers:** (يحتاج Session Token لسوبر أدمن)

**Expected Response (إذا كنت SUPER_ADMIN):**
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

**Expected Response (إذا لم تكن SUPER_ADMIN):**
```json
{
  "code": 141,
  "error": "Access denied. Only SUPER_ADMIN can view admins."
}
```

---

### ✅ 1.10 إضافة/تعديل أدمن
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/addEditAdmin`  
**Body (JSON):**
```json
{
  "fullName": "مدير النظام",
  "username": "admin_user",
  "password": "123456",
  "mobile": "0999111222",
  "email": "admin@example.com"
}
```

---

### ✅ 1.11 حذف أدمن (SUPER_ADMIN فقط)
**Method:** DELETE  
**URL:** `http://localhost:1337/api/functions/deleteAdmin`  
**Body (JSON):**
```json
{
  "adminId": "usr128"
}
```

---

### ✅ 1.12 تحديث حسابي
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/updateMyAccount`  
**Body (JSON):**
```json
{
  "fullName": "نور محمد",
  "username": "nour_user",
  "fcm_token": "fcm_token_value",
  "birthDate": "2005-01-01",
  "fatherName": "محمد"
}
```

---

### ✅ 1.13 تسجيل الخروج
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/logout`  
**Headers:** (Session Token فقط)

**Body (JSON):**
```json
{}
```

---

## 2. اختبارات Appointment APIs

### ✅ 2.1 طلب موعد مع أخصائي
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/requestPsychologistAppointment`  
**Body (JSON):**
```json
{
  "child_id": "ch123",
  "provider_id": "usr456",
  "appointment_plan_id": "plan789",
  "note": "أريد جلسة متابعة"
}
```

---

### ✅ 2.2 جلب مواعيد طفل
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/getChildAppointments`  
**Body (JSON):**
```json
{
  "child_id": "ch123"
}
```

---

### ✅ 2.3 جلب تفاصيل موعد
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/getAppointmentDetails`  
**Body (JSON):**
```json
{
  "appointment_id": "app001"
}
```

---

### ✅ 2.4 جلب المواعيد المعلّقة للمزوّد
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/getPendingAppointmentsForProvider`  
**Body (JSON):**
```json
{}
```

---

### ✅ 2.5 التحقق من إمكانية الوصول لتقييم طفل
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/canAccessChildEvaluation`  
**Body (JSON):**
```json
{
  "child_id": "ch123"
}
```

**Expected Response:**
```json
{
  "canAccess": true,
  "message": "Access granted: Provider has a valid appointment with this child"
}
```

---

### ✅ 2.6 اتخاذ قرار بخصوص موعد (موافقة/رفض)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/handleAppointmentDecision`  
**Body (JSON) - موافقة:**
```json
{
  "appointment_id": "app001",
  "decision": "approve"
}
```

**Body (JSON) - رفض:**
```json
{
  "appointment_id": "app001",
  "decision": "reject"
}
```

---

## 3. اختبارات Appointment Plan APIs

### ✅ 3.1 إنشاء خطة موعد (Admin only)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/createAppointmentPlan`  
**Body (JSON):**
```json
{
  "title": "جلسة فردية",
  "duration_minutes": 60,
  "price": 200,
  "description": "جلسة فردية مع الأخصائي النفسي"
}
```

---

### ✅ 3.2 جلب جميع خطط المواعيد
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getAvailableAppointmentPlans`

---

## 4. اختبارات Wallet APIs

### ✅ 4.1 جلب رصيد المحفظة
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getWalletBalance`

**Expected Response:**
```json
{
  "message": "Wallet balance retrieved successfully",
  "balance": 150,
  "wallet_id": "wlt001"
}
```

---

### ✅ 4.2 إنشاء معاملة محفظة
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/createWalletTransaction`  
**Body (JSON):**
```json
{
  "from_wallet_id": "wlt001",
  "to_wallet_id": "wlt002",
  "amount": 100,
  "type": "payment",
  "appointment_id": "app001"
}
```

---

### ✅ 4.3 جلب معاملات محفظة
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getWalletTransactions?wallet_id=wlt001&type=payment`

---

## 5. اختبارات Charge Request APIs

### ✅ 5.1 إنشاء طلب شحن (مع ملف)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/createChargeRequest`  
**Headers:** (تغيير Content-Type)
```
Content-Type: multipart/form-data
X-Parse-Application-Id: ...
X-Parse-Session-Token: ...
X-Parse-Master-Key: ...
```

**Body (form-data):**
- `amount`: 500
- `note`: "إيداع رصيد جديد"
- `receipt_image`: (اختر ملف)

---

### ✅ 5.2 الموافقة على طلب شحن (Admin only)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/approveChargeRequest`  
**Body (JSON):**
```json
{
  "charge_request_id": "cr001"
}
```

---

### ✅ 5.3 رفض طلب شحن (Admin only)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/rejectChargeRequest`  
**Body (JSON):**
```json
{
  "charge_request_id": "cr001",
  "rejection_note": "المستند غير واضح"
}
```

---

## 6. اختبارات Chat APIs

### ✅ 6.1 إنشاء مجموعة محادثة لموعد
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/createChatGroupForAppointment`  
**Body (JSON):**
```json
{
  "appointment_id": "app001"
}
```

---

### ✅ 6.2 إرسال رسالة
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/sendChatMessage`  
**Body (JSON):**
```json
{
  "chat_group_id": "cg001",
  "message": "مرحبا دكتور، كيف حالك؟",
  "child_id": "ch123"
}
```

---

### ✅ 6.3 جلب رسائل مجموعة
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getChatMessages?chat_group_id=cg001`

---

## 7. اختبارات Child APIs

### ✅ 7.1 جلب ملف الطفل الخاص بي
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getMyChildProfile`

---

### ✅ 7.2 إنشاء/تحديث ملف طفل
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/createOrUpdateChildProfile`  
**Body (JSON):**
```json
{
  "childId": "usr111",
  "name": "نور",
  "fatherName": "أحمد",
  "birthdate": "2015-01-01",
  "gender": "Female",
  "medical_info": "No issues"
}
```

---

## 8. اختبارات Research APIs

### ✅ 8.1 إرسال مقال بحثي (Doctor/Specialist only)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/submitResearchPost`  
**Body (JSON):**
```json
{
  "title": "أثر العلاج السلوكي على الأطفال",
  "body": "هذا البحث يناقش أثر العلاج السلوكي...",
  "category_name": "علم النفس",
  "keywords": "سلوك, أطفال, علاج"
}
```

---

### ✅ 8.2 جلب المقالات المنشورة
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getPublishedResearchPosts`

---

### ✅ 8.3 الموافقة/رفض مقال (Admin only)
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/approveOrRejectPost`  
**Body (JSON) - نشر:**
```json
{
  "post_id": "rp001",
  "action": "publish"
}
```

**Body (JSON) - رفض:**
```json
{
  "post_id": "rp002",
  "action": "reject",
  "rejection_reason": "المحتوى غير كافٍ"
}
```

---

## 9. اختبارات Level APIs

### ✅ 9.1 جلب جميع المستويات
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getAllLevels`

---

### ✅ 9.2 إضافة مستوى جديد
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/addLevelByAdmin`  
**Body (JSON):**
```json
{
  "name": "Level 1",
  "description": "Introductory level",
  "order": 1
}
```

---

## 10. اختبارات Placement Test APIs

### ✅ 10.1 جلب أسئلة اختبار المستوى
**Method:** GET  
**URL:** `http://localhost:1337/api/functions/getPlacementTestQuestions`

---

### ✅ 10.2 إرسال إجابات اختبار المستوى
**Method:** POST  
**URL:** `http://localhost:1337/api/functions/submitPlacementTestAnswers`  
**Body (JSON):**
```json
{
  "answers": [
    {"questionId": "q001", "selectedOption": "A"},
    {"questionId": "q002", "selectedOption": "C"},
    {"questionId": "q003", "selectedOption": "B"}
  ]
}
```

---

## نصائح للاختبار في Postman

### 1. إنشاء Environment
أنشئ Environment في Postman يحتوي على:
- `base_url`: `http://localhost:1337/api/functions`
- `session_token`: (سيتم تحديثه بعد تسجيل الدخول)
- `app_id`: `cDUPSpkhbmD0e1TFND3rYkw7TrrdHXqNyXgoOa3PpLPSd5NJb7`
- `master_key`: `He98Mcsc7cTEjut5eE59Oy2gs2dowaNoGWv5QhpzvA7GC3NShY`

### 2. استخدام Pre-request Script
أضف هذا السكريبت لاستخراج sessionToken تلقائياً:

```javascript
// في Pre-request Script للطلبات التي تحتاج Session Token
const sessionToken = pm.environment.get("session_token");
if (sessionToken) {
    pm.request.headers.add({
        key: "X-Parse-Session-Token",
        value: sessionToken
    });
}
```

### 3. استخدام Tests Script
أضف هذا السكريبت لحفظ sessionToken تلقائياً بعد تسجيل الدخول:

```javascript
// في Tests Script لطلب تسجيل الدخول
const response = pm.response.json();
if (response.sessionToken) {
    pm.environment.set("session_token", response.sessionToken);
    console.log("Session Token saved:", response.sessionToken);
}
```

### 4. ترتيب الاختبارات
1. ✅ تسجيل الدخول أولاً
2. ✅ حفظ Session Token
3. ✅ اختبار باقي الـ APIs

---

## أمثلة على أخطاء شائعة

### خطأ 401 - Unauthorized
**السبب:** Session Token غير صحيح أو منتهي الصلاحية  
**الحل:** سجّل الدخول مرة أخرى واحصل على sessionToken جديد

### خطأ 403 - Forbidden
**السبب:** لا تملك الصلاحيات المطلوبة  
**الحل:** تأكد أنك مسجل دخول بحساب له الصلاحيات المطلوبة (Admin, SUPER_ADMIN, etc.)

### خطأ 400 - Bad Request
**السبب:** البيانات المرسلة غير صحيحة  
**الحل:** تحقق من Body وHeaders

---

## Checklist للاختبار الكامل

- [ ] تسجيل الدخول
- [ ] جلب الأطباء
- [ ] إضافة طبيب
- [ ] تعديل طبيب
- [ ] حذف طبيب
- [ ] جلب الأخصائيين
- [ ] إضافة أخصائي
- [ ] تعديل أخصائي
- [ ] حذف أخصائي
- [ ] جلب الأدمن (SUPER_ADMIN فقط)
- [ ] إضافة أدمن
- [ ] تعديل أدمن
- [ ] حذف أدمن (SUPER_ADMIN فقط)
- [ ] طلب موعد
- [ ] جلب المواعيد
- [ ] الموافقة/رفض موعد
- [ ] جلب رصيد المحفظة
- [ ] إنشاء طلب شحن
- [ ] إرسال رسالة
- [ ] جلب الرسائل

---

**ملاحظة:** تأكد أن السيرفر يعمل على `http://localhost:1337` قبل البدء بالاختبار!

