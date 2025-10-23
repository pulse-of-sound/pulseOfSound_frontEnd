import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorWalletPrefs {
  static const _balanceKey = "doctor_wallet_balance";
  static const _transactionsKey = "doctor_wallet_transactions";

  static Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 0.0;
  }

  static Future<void> setBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
  }

  static Future<void> addFunds(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    double current = prefs.getDouble(_balanceKey) ?? 0.0;
    current += amount;
    await prefs.setDouble(_balanceKey, current);

    await _addTransaction("إضافة رصيد", amount);
  }

  static Future<void> withdraw(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    double current = prefs.getDouble(_balanceKey) ?? 0.0;
    if (current >= amount) {
      current -= amount;
      await prefs.setDouble(_balanceKey, current);
      await _addTransaction("سحب رصيد", -amount);
    }
  }

  static Future<void> _addTransaction(String desc, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_transactionsKey);
    final List list = data == null ? [] : jsonDecode(data);

    list.insert(0, {
      "description": desc,
      "amount": amount,
      "date": DateTime.now().toString(),
    });

    await prefs.setString(_transactionsKey, jsonEncode(list));
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_transactionsKey);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
