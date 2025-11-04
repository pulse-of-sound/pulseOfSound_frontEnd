import 'package:flutter/material.dart';
import '../model/consultation_models.dart';
import 'provider_list_screen.dart';

class ConsultationTypeScreen extends StatefulWidget {
  const ConsultationTypeScreen({super.key});

  @override
  State<ConsultationTypeScreen> createState() => _ConsultationTypeScreenState();
}

class _ConsultationTypeScreenState extends State<ConsultationTypeScreen> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("احجز استشارتك",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(20),
            width: selectedType == null ? 300 : 350,
            height: selectedType == null ? 220 : 480,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("اختر نوع الاستشارة:",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTypeButton("طبية"),
                    _buildTypeButton("نفسية"),
                  ],
                ),
                const SizedBox(height: 25),
                if (selectedType != null)
                  Expanded(
                    child: ListView(
                      children: [
                        const Text("المتخصصون المتاحون:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 15),
                        ..._getProviders(selectedType!).map((p) => ListTile(
                              leading: CircleAvatar(
                                  backgroundImage: AssetImage(p.avatar)),
                              title: Text(p.name),
                              subtitle: Text(p.specialty),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 18, color: Colors.pinkAccent),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlanStaticSelectionScreen(
                                        type: selectedType!, provider: p),
                                  ),
                                );
                              },
                            )),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type) {
    final bool isSelected = selectedType == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
      ),
      onPressed: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Text(type,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  List<ProviderModel> _getProviders(String type) {
    if (type == "طبية") {
      return [
        ProviderModel(
            id: "1",
            name: "د. أحمد سليمان",
            specialty: "أخصائي أنف وأذن وحنجرة",
            avatar: "images/doctor1.jpeg"),
        ProviderModel(
            id: "2",
            name: "د. سارة الخطيب",
            specialty: "جراحة سمعية",
            avatar: "images/doctor.jpg"),
      ];
    } else {
      return [
        ProviderModel(
            id: "3",
            name: "أ. منى العبدالله",
            specialty: "أخصائية نطق ولغة",
            avatar: "images/doctor.jpg"),
        ProviderModel(
            id: "4",
            name: "أ. خليل الرفاعي",
            specialty: "علاج سلوكي",
            avatar: "images/doctor1.jpeg"),
      ];
    }
  }
}
