import 'package:flutter/material.dart';
import '../model/consultation_models.dart';
import 'plan_selection_screen.dart';

class ProviderListScreen extends StatelessWidget {
  final String type;
  final ProviderModel provider;

  const ProviderListScreen(
      {super.key, required this.type, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("اختيار الخطة",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/booking.jpg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(20),
            width: 340,
            height: 420,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                      backgroundImage: AssetImage(provider.avatar)),
                  title: Text(provider.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(provider.specialty),
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text("اختر خطة الاستشارة:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 20),
                _buildPlan(context, "استشارة فردية", 15),
                _buildPlan(context, "جلسة أسبوعية", 40),
                _buildPlan(context, "خطة شهرية", 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlan(BuildContext context, String title, double price) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text("$price \$",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlanSelectionScreen(
                type: type,
                provider: provider,
                planTitle: title,
                price: price,
              ),
            ),
          );
        },
      ),
    );
  }
}
