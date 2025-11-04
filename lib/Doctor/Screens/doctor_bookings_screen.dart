import 'dart:async';
import 'package:flutter/material.dart';
import '../../Booking/utils/wallet_prefs.dart';
import '../../Colors/colors.dart';
import '../utils/doctor_booking_prefs.dart';
import '../utils/doctor_chat_prefs.dart';
import '../utils/doctor_wallet_prefs.dart';
// محفظة الأهل

class DoctorBookingsScreen extends StatefulWidget {
  const DoctorBookingsScreen({super.key});

  @override
  State<DoctorBookingsScreen> createState() => _DoctorBookingsScreenState();
}

class _DoctorBookingsScreenState extends State<DoctorBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final data = await DoctorBookingPrefs.load();
    setState(() => bookings = data);
  }

  /// ✅ قبول الحجز وإنشاء محادثة خاصة + مؤقت انتهاء الجلسة
  Future<void> _approveBooking(int index) async {
    final booking = bookings[index];
    final double price = booking["price"] ?? 0.0;
    final String chatId = booking["id"].toString();

    // 🔹 التحقق من وجود خطة زمنية (نصف ساعة / ساعة...)
    int durationMinutes = 30; // افتراضي 30 دقيقة
    if (booking["plan"] != null) {
      final plan = booking["plan"].toString().toLowerCase();
      if (plan.contains("ساعة")) durationMinutes = 60;
      if (plan.contains("نصف")) durationMinutes = 30;
    }

    // 🔹 خصم المبلغ من محفظة وليّ الأمر
    final success = await WalletPrefs.deduct(price);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("رصيد وليّ الأمر غير كافٍ")),
      );
      return;
    }

    // 🔹 إضافة المبلغ لمحفظة الطبيب
    await DoctorWalletPrefs.addFunds(price);

    // 🔹 تحديث حالة الحجز
    booking["status"] = "accepted";
    await DoctorBookingPrefs.update(booking);

    // 🔹 إنشاء محادثة خاصة جديدة بين الطبيب ووليّ الأمر
    await DoctorChatService.createPrivateChat(
      chatId: chatId,
      doctorId: booking["doctorId"] ?? "unknown",
      parentId: booking["parentId"] ?? "",
      parentName: booking["parentName"] ?? "وليّ الأمر",
      durationMinutes: durationMinutes,
    );

    // 🔹 إرسال أول رسالة تلقائية
    await DoctorChatService.addPrivateMessage(
      chatId,
      "system",
      "✅ تمت الموافقة على الاستشارة.\n"
          "⏱ المدة المتاحة: $durationMinutes دقيقة.\n"
          "يمكنكم الآن بدء المحادثة.",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("تمت الموافقة على الحجز وإنشاء المحادثة الخاصة")),
    );

    _loadBookings();
  }

  /// ❌ رفض الحجز
  Future<void> _rejectBooking(int index) async {
    final booking = bookings[index];
    booking["status"] = "rejected";
    await DoctorBookingPrefs.update(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم رفض الحجز")),
    );

    _loadBookings();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/doctorsBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "إدارة الحجوزات",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: bookings.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد حجوزات حالياً",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        final status = b["status"] ?? "pending";

                        return Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              "${b["type"]} مع ${b["parentName"] ?? "وليّ الأمر"}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("السعر: ${b["price"]} ل.س"),
                                Text(
                                  "الخطة: ${b["plan"] ?? "غير محددة"}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "الحالة: ${status == "pending" ? "قيد المراجعة" : status == "accepted" ? "مقبولة" : "مرفوضة"}",
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: status == "pending"
                                ? Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check_circle,
                                            color: Colors.green),
                                        onPressed: () => _approveBooking(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.redAccent),
                                        onPressed: () => _rejectBooking(index),
                                      ),
                                    ],
                                  )
                                : Icon(Icons.verified,
                                    color: _statusColor(status)),
                          ),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ]),
    );
  }
}
