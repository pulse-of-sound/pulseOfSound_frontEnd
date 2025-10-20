import 'package:flutter/material.dart';
import '../model/consultation_models.dart';
import 'ConfirmBookingScreen.dart';

class PlanSelectionScreen extends StatelessWidget {
  final String type;
  final ProviderModel provider;
  final String planTitle;
  final double price;

  const PlanSelectionScreen({
    super.key,
    required this.type,
    required this.provider,
    required this.planTitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("تأكيد الحجز"),
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
                Text("الخطة: $planTitle",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("الطبيب: ${provider.name}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("السعر: $price \$",
                    style: const TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmBookingScreen(
                          type: type,
                          provider: provider,
                          planTitle: planTitle,
                          price: price,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("متابعة",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
