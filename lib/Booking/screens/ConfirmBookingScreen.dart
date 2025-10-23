import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse_of_sound/HomeScreens/bottomNavBar.dart';
import '../model/consultation_models.dart';
import '../utils/bookings_prefs.dart';
import 'consultation_flow.dart';

class ConfirmBookingScreen extends StatelessWidget {
  final ProviderModel provider;
  final String type;
  final String planTitle;
  final double price;

  const ConfirmBookingScreen({
    super.key,
    required this.provider,
    required this.type,
    required this.planTitle,
    required this.price,
  });

  Future<void> _confirmBooking(BuildContext context) async {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentId: "user_001", //  لاحقاً تستبدلها بـ id المستخدم من prefs
      parentName: "ولي الأمر",
      phone: "0999999999",
      type: type,
      provider: provider,
      plan: planTitle,
      price: price,
      date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      status: BookingStatus.pending,
    );

    await BookingsPrefs.add(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(" تم إرسال طلب الحجز بنجاح!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => const BottomNavScreen(
                initialIndex: 1,
              )),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("تأكيد الحجز"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(0.9),
            margin: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("النوع: $type", textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text("المختص: ${provider.name}", textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text("الخطة: $planTitle", textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text("السعر: $price \$", textAlign: TextAlign.right),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("تأكيد الحجز"),
                      onPressed: () => _confirmBooking(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
