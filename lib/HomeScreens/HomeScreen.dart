import 'package:flutter/material.dart';
import 'package:pulse_of_sound/HomeScreens/drawer.dart';

import '../Levels/utils/child_progress_prefs.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<Map<String, dynamic>> evaluations = [];

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    final data = await ChildProgressPrefs.loadEvaluations();
    setState(() => evaluations = data.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/booking.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    "تقييمات الطفل الأخيرة ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: evaluations.isEmpty
                      ? const Center(
                          child: Text("لا توجد تقييمات بعد",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
                        )
                      : ListView.builder(
                          itemCount: evaluations.length,
                          itemBuilder: (context, i) {
                            final e = evaluations[i];
                            final date = DateTime.parse(e["date"]);
                            return Card(
                              color: Colors.white.withOpacity(0.9),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: const Icon(Icons.star,
                                    color: Colors.pinkAccent),
                                title: Text(
                                  "المستوى ${e["level"]}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "النتيجة: ${e["score"]}\n${e["feedback"]}"),
                                trailing: Text(
                                  "${date.day}/${date.month}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
