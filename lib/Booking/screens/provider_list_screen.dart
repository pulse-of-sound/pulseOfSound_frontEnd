import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../model/consultation_models.dart';
import 'plan_selection_screen.dart';

class PlanStaticSelectionScreen extends StatelessWidget {
  final String type;
  final ProviderModel provider;

  const PlanStaticSelectionScreen({
    super.key,
    required this.type,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> plans = [
      {
        "title": "استشارة سلوكية",
        "description": "جلسة تقييم سلوكي لمدة نصف ساعة.",
        "duration": 30,
        "price": 150
      },
      {
        "title": "تدريب لغوي",
        "description": "جلسة تدريب لغوي مكثفة لمدة 45 دقيقة.",
        "duration": 45,
        "price": 200
      },
      {
        "title": "جلسة تقييم شامل",
        "description": "تقييم شامل للحالة لمدة ساعة كاملة.",
        "duration": 60,
        "price": 250
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("اختيار نوع الاستشارة",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 340,
            height: 440,
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 6),
                const Text("اختر نوع الاستشارة:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),

                ///  فقط هذا الجزء قابل للسكرول:
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: plans.map((plan) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.pinkAccent.withOpacity(0.8),
                                width: 1.2),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            title: Text(plan["title"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(plan["description"]),
                                const SizedBox(height: 4),
                                Text("المدة: ${plan["duration"]} دقيقة",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            trailing: Text(
                              "${plan["price"]} ل.س",
                              style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlanSelectionScreen(
                                    type: type,
                                    provider: provider,
                                    planTitle: plan["title"]!,
                                    price:
                                        double.parse(plan["price"].toString()),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
