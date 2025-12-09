# كيفية تسجيل الدخول كسوبر أدمن (SUPER_ADMIN)

## معلومات تسجيل الدخول

لتسجيل الدخول كسوبر أدمن، استخدم نفس شاشة تسجيل الدخول للأدمن/الدكتور:

**المسار:** `lib/LoginScreens/loginForAdmin&Dr.dart`

## الخطوات:

1. افتح التطبيق
2. اختر "تسجيل الدخول للأدمن / الدكتور"
3. أدخل بيانات السوبر أدمن:
   - **اسم المستخدم:** (username الخاص بالسوبر أدمن)
   - **كلمة المرور:** (password الخاص بالسوبر أدمن)

## ملاحظات مهمة:

- السوبر أدمن هو نوع خاص من الأدمن له صلاحيات أعلى
- بعد تسجيل الدخول، إذا كان الدور `Admin` أو `SUPER_ADMIN`، سيتم توجيهك إلى `AdminHome`
- السوبر أدمن يمكنه:
  - عرض جميع الأدمن (`getAllAdmins`)
  - حذف الأدمن (`deleteAdmin`)
  - جميع صلاحيات الأدمن العادي

## في الكود:

تم تحديث `loginForAdmin&Dr.dart` لدعم `SUPER_ADMIN`:

```dart
if (role == "Admin" || role == "SUPER_ADMIN") {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const AdminHome()),
  );
}
```

## إنشاء سوبر أدمن:

يجب إنشاء سوبر أدمن من خلال Backend أو Parse Dashboard مباشرة، حيث يتم تعيين الدور `SUPER_ADMIN` للمستخدم.

