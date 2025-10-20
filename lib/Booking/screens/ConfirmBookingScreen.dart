import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/consultation_models.dart';
import '../utils/bookings_prefs.dart';

class ConfirmBookingScreen extends StatelessWidget {
  final String type;
  final ProviderModel provider;
  final String planTitle;
  final double price;

  const ConfirmBookingScreen({
    super.key,
    required this.type,
    required this.provider,
    required this.planTitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentName: "ولي الأمر",
      phone: "09XXXXXXXX",
      type: type,
      provider: provider,
      plan: planTitle,
      price: price,
      date: date,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("تأكيد الاستشارة"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/booking.jpg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("هل ترغب بتأكيد حجز هذه الاستشارة؟",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 25),
                Text("الطبيب: ${provider.name}"),
                Text("الخطة: $planTitle"),
                Text("السعر: $price \$"),
                Text("النوع: $type"),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    await BookingsPrefs.add(booking);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ تم إرسال طلب الحجز بنجاح!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("تأكيد الحجز",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
