import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../SuperAdminScreens/Wallet/ReceiptModel.dart';

class WalletPrefs {
  static const String _balanceKey = "wallet_balance";
  static const String _receiptsKey = "wallet_receipts";

  ///  تحميل الرصيد الحالي
  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 0.0;
  }

  ///  حفظ الرصيد
  static Future<void> _setBalance(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, value);
  }

  ///  زيادة الرصيد (عند موافقة الأدمن على الإيصال)
  static Future<void> addFunds(double amount) async {
    final current = await getBalance();
    await _setBalance(current + amount);
  }

  ///  خصم الرصيد (مثلاً عند قبول حجز)
  static Future<bool> deduct(double amount) async {
    final current = await getBalance();
    if (current >= amount) {
      await _setBalance(current - amount);
      return true;
    }
    return false;
  }

  ///  تحميل الإيصالات (الكل)
  static Future<List<Map<String, dynamic>>> loadReceipts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_receiptsKey);
    if (data == null || data.isEmpty) return [];
    final List decoded = json.decode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  ///  حفظ الإيصالات
  static Future<void> _saveReceipts(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_receiptsKey, json.encode(list));
  }

  ///  إضافة إيصال جديد (من الأهل)
  static Future<void> addReceipt(Receipt receipt) async {
    final list = await loadReceipts();
    list.add(receipt.toMap());
    await _saveReceipts(list);
  }

  ///  تحديث حالة إيصال (يستخدمها الأدمن للموافقة أو الرفض)
  static Future<void> updateReceiptStatus(String id, String newStatus) async {
    final list = await loadReceipts();
    final index = list.indexWhere((r) => r["id"] == id);
    if (index != -1) {
      list[index]["status"] = newStatus;
      await _saveReceipts(list);
    }
  }

  ///  تحميل إيصالات مستخدم معيّن (حسب رقم الموبايل)
  static Future<List<Receipt>> loadReceiptsForParent(String parentPhone) async {
    final all = await loadReceipts();
    final filtered = all
        .where((r) => r["parentPhone"] == parentPhone)
        .map((r) => Receipt.fromMap(Map<String, dynamic>.from(r)))
        .toList();
    return filtered;
  }
}
