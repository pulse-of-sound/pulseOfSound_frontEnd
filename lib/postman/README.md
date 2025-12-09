# API Documentation - نبض الصوت

هذا المجلد يحتوي على جميع ملفات API للاتصال بالسيرفر.

## البنية التنظيمية

### ملفات API الرئيسية:

1. **api_config.dart** - الإعدادات المشتركة (Base URL, Headers)
2. **user_api.dart** - إدارة المستخدمين (تسجيل الدخول، الأطباء، الأخصائيين، الأدمن)
3. **auth_api.dart** - المصادقة (OTP، تسجيل الدخول بالموبايل)
4. **appointment_api.dart** - المواعيد
5. **appointment_plan_api.dart** - خطط المواعيد
6. **wallet_api.dart** - المحافظ والمعاملات المالية
7. **charge_request_api.dart** - طلبات شحن الرصيد
8. **chat_api.dart** - المحادثات والرسائل
9. **child_api.dart** - ملفات الأطفال والمستويات
10. **research_api.dart** - الأبحاث والمقالات
11. **level_api.dart** - المستويات والمراحل
12. **placement_test_api.dart** - اختبارات تحديد المستوى
13. **stage_api.dart** - أسئلة المراحل
14. **invoice_api.dart** - الفواتير
15. **training_question_api.dart** - الأسئلة التدريبية
16. **user_stage_status_api.dart** - حالة مراحل المستخدم

## الإعدادات

### تغيير Base URL

افتح `api_config.dart` وغيّر `baseUrl`:

```dart
// للتطوير (Development)
static const String baseUrl = "http://localhost:1337/api/functions";

// للإنتاج (Production)
static const String baseUrl = "https://api.pulseofsound.com/api/functions";
```

## أمثلة الاستخدام

### 1. تسجيل الدخول

```dart
import 'package:pulse_of_sound/api/user_api.dart';

final result = await UserAPI.loginUser("username", "password");
if (result.containsKey("error")) {
  print("خطأ: ${result["error"]}");
} else {
  final sessionToken = result["sessionToken"];
  // حفظ sessionToken في SharedPrefsHelper
}
```

### 2. جلب جميع الأطباء

```dart
import 'package:pulse_of_sound/api/user_api.dart';
import 'package:pulse_of_sound/utils/shared_pref_helper.dart';

final sessionToken = await SharedPrefsHelper.getToken();
final doctors = await UserAPI.getAllDoctors(sessionToken!);
```

### 3. طلب موعد

```dart
import 'package:pulse_of_sound/api/appointment_api.dart';

final result = await AppointmentAPI.requestPsychologistAppointment(
  sessionToken: sessionToken,
  childId: "child123",
  providerId: "provider456",
  appointmentPlanId: "plan789",
  note: "ملاحظة اختيارية",
);
```

### 4. جلب رصيد المحفظة

```dart
import 'package:pulse_of_sound/api/wallet_api.dart';

final result = await WalletAPI.getWalletBalance(
  sessionToken: sessionToken,
);
final balance = result["balance"];
```

### 5. إرسال رسالة في المحادثة

```dart
import 'package:pulse_of_sound/api/chat_api.dart';

final result = await ChatMessageAPI.sendChatMessage(
  sessionToken: sessionToken,
  chatGroupId: "group123",
  message: "مرحبا",
  childId: "child123", // اختياري
);
```

## ملاحظات مهمة

1. **Session Token**: معظم الـ APIs تحتاج `sessionToken` الذي يتم الحصول عليه بعد تسجيل الدخول
2. **Error Handling**: جميع الـ APIs ترجع `Map` مع مفتاح `error` في حالة الفشل
3. **Lists**: الـ APIs التي ترجع قوائم ترجع `List<Map<String, dynamic>>` أو `[]` في حالة الفشل
4. **File Upload**: استخدام `multipart/form-data` لرفع الملفات (مثل الصور، PDF)

## الصلاحيات

- **Admin**: صلاحيات كاملة على النظام
- **Doctor/Specialist**: إرسال المقالات البحثية
- **Child**: الوصول إلى الاختبارات والمراحل

## الأمان

- جميع الطلبات تستخدم HTTPS في الإنتاج
- Session Token مطلوب لمعظم العمليات
- Parse Server Keys مطلوبة في جميع الطلبات

