import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/consultation_models.dart';
import 'wallet_prefs.dart';

class BookingsPrefs {
  static const String _key = "app_bookings";

  static Future<List<Booking>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];
    final list = json.decode(data) as List;
    return list
        .map((e) => Booking.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> save(List<Booking> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, json.encode(list.map((e) => e.toMap()).toList()));
  }

  static Future<void> add(Booking b) async {
    final list = await load();
    list.insert(0, b);
    await save(list);
  }

  static Future<void> update(Booking b) async {
    final list = await load();
    final i = list.indexWhere((x) => x.id == b.id);
    if (i != -1) list[i] = b;
    await save(list);
  }

  // 🔹 دالة الطبيب لقبول الحجز مع خصم الرصيد
  static Future<bool> approveBooking(Booking booking) async {
    final success = await WalletPrefs.deduct(booking.price);
    if (success) {
      booking.status = BookingStatus.accepted;
      await update(booking);
    }
    return success;
  }

  static Future<int> pendingCount() async {
    final list = await load();
    return list
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.processing)
        .length;
  }
}
