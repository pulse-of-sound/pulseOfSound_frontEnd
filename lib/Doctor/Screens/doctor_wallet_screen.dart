import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../utils/doctor_wallet_prefs.dart';

class DoctorWalletScreen extends StatefulWidget {
  const DoctorWalletScreen({super.key});

  @override
  State<DoctorWalletScreen> createState() => _DoctorWalletScreenState();
}

class _DoctorWalletScreenState extends State<DoctorWalletScreen> {
  double balance = 0.0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final b = await DoctorWalletPrefs.getBalance();
    final t = await DoctorWalletPrefs.getTransactions();
    setState(() {
      balance = b;
      transactions = t;
    });
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "محفظتي",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 6)
                        ]),
                  ),
                ),
                const SizedBox(width: 40),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Text("رصيدك الحالي",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    "$balance ل.س",
                    style: const TextStyle(
                        fontSize: 30,
                        color: AppColors.skyBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              const Text("المعاملات المالية",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(
                        child: Text("لا يوجد معاملات بعد",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          final amount = t["amount"] as double;
                          final isAdd = amount > 0;
                          return Card(
                              color: Colors.white.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                  leading: Icon(
                                      isAdd
                                          ? Icons.add_circle
                                          : Icons.remove_circle,
                                      color: isAdd
                                          ? Colors.green
                                          : Colors.redAccent),
                                  title: Text(t["description"]),
                                  subtitle: Text(
                                      t["date"].toString().substring(0, 16)),
                                  trailing: Text(
                                    "${isAdd ? '+' : ''}${amount.toStringAsFixed(0)} ل.س",
                                    style: TextStyle(
                                        color: isAdd
                                            ? Colors.green
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.bold),
                                  )));
                        }),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
