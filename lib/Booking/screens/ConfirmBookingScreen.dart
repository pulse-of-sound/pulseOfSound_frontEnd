import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse_of_sound/HomeScreens/bottomNavBar.dart';
import '../model/consultation_models.dart';
import '../utils/bookings_prefs.dart';

class ConfirmBookingScreen extends StatefulWidget {
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

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  Future<void> _confirmBooking() async {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentId: "user_001",
      parentName: "ولي الأمر",
      phone: "0999999999",
      type: widget.type,
      provider: widget.provider,
      plan: widget.planTitle,
      price: widget.price,
      date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      status: BookingStatus.pending,
    );

    await BookingsPrefs.add(booking);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(" تم إرسال طلب الحجز بنجاح!"),
        backgroundColor: Colors.green,
      ),
    );

    if (!mounted) return;

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
                  Text("النوع: ${widget.type}", textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text("المختص: ${widget.provider.name}", textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text("الخطة: ${widget.planTitle}", textAlign: TextAlign.right),
                  const SizedBox(height: 8),
                  Text("السعر: ${widget.price} \$", textAlign: TextAlign.right),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("تأكيد الحجز"),
                      onPressed: _confirmBooking,
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
