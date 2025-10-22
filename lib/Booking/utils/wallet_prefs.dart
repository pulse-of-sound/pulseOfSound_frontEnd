import 'package:shared_preferences/shared_preferences.dart';

class WalletPrefs {
  static const _keyImage = "wallet_receipt_image";
  static const _keyBalance = "wallet_balance";

  // 🔹 حفظ إيصال التحويل البنكي (بانتظار موافقة الأدمن)
  static Future<void> setReceiptImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyImage, path);
  }

  static Future<String?> getReceiptImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyImage);
  }

  // 🔹 تعيين الرصيد (يستخدمها الأدمن فقط عند الموافقة)
  static Future<void> setBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBalance, amount);
  }

  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBalance) ?? 0.0;
  }

  // 🔹 خصم المبلغ عند قبول الحجز من قبل الطبيب
  static Future<bool> deduct(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final balance = prefs.getDouble(_keyBalance) ?? 0.0;

    if (balance >= amount) {
      await prefs.setDouble(_keyBalance, balance - amount);
      return true; // تم الخصم بنجاح
    } else {
      return false; // لا يوجد رصيد كافٍ
    }
  }
}
