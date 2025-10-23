import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../Booking/utils/wallet_prefs.dart';
import '../../Booking/utils/bookings_prefs.dart';
import '../../SuperAdminScreens/Wallet/ReceiptModel.dart';
import 'utils/doctor_booking_prefs.dart';
import 'utils/doctor_chat_service.dart';
import 'utils/doctor_wallet_prefs.dart';

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

  Future<void> _approveBooking(int index) async {
    final booking = bookings[index];
    final double price = booking["price"] ?? 0.0;

    // 🔹 محاولة خصم من محفظة الأهل
    final success = await WalletPrefs.deduct(price);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("رصيد الأهل غير كافٍ")),
      );
      return;
    }

    // 🔹 إضافة للطبيب
    await DoctorWalletPrefs.addFunds(price);

    // 🔹 تحديث الحالة
    booking["status"] = "accepted";
    await DoctorBookingPrefs.update(booking);

    // 🔹 إنشاء محادثة تلقائية بين الطبيب والأهل
    await DoctorChatService.addMessage(
      booking["id"].toString(),
      "system",
      "تمت الموافقة على الاستشارة. يمكنكم البدء بالمحادثة الآن.",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تمت الموافقة على الحجز وإنشاء المحادثة")),
    );
    _loadBookings();
  }

  Future<void> _rejectBooking(int index) async {
    final booking = bookings[index];
    booking["status"] = "rejected";
    await DoctorBookingPrefs.update(booking);
    _loadBookings();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم رفض الحجز")),
    );
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
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
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
                                "${b["type"]} مع ${b["parentName"] ?? "أحد الأهالي"}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("السعر: ${b["price"]} ل.س"),
                                  Text(
                                    "الحالة: ${status == "pending" ? "قيد المراجعة" : status == "accepted" ? "مقبولة" : "مرفوضة"}",
                                    style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: status == "pending"
                                  ? Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.green),
                                          onPressed: () =>
                                              _approveBooking(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.redAccent),
                                          onPressed: () =>
                                              _rejectBooking(index),
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
            ],
          ),
        ),
      ]),
    );
  }
}
