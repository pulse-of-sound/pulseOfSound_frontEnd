import 'package:flutter/material.dart';
import '../../Colors/colors.dart';
import '../../api/wallet_api.dart';
import '../../utils/api_helpers.dart';

class DoctorWalletScreen extends StatefulWidget {
  const DoctorWalletScreen({super.key});

  @override
  State<DoctorWalletScreen> createState() => _DoctorWalletScreenState();
}

class _DoctorWalletScreenState extends State<DoctorWalletScreen> {
  double balance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? walletId;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => isLoading = true);
    try {
      final sessionToken = await APIHelpers.getSessionToken();
      
      //  Get Wallet Balance
      final balanceResult = await WalletAPI.getWalletBalance(sessionToken: sessionToken);
      
      if (balanceResult.containsKey('error')) {
        if (mounted) APIHelpers.showErrorDialog(context, balanceResult['error']);
        setState(() => isLoading = false);
        return;
      }
      
      final fetchedBalance = (balanceResult['balance'] ?? 0).toDouble();
      final fetchedWalletId = balanceResult['wallet_id'];

      //  Get Transactions if walletId available
      List<Map<String, dynamic>> fetchedTransactions = [];
      if (fetchedWalletId != null) {
        fetchedTransactions = await WalletTransactionAPI.getWalletTransactions(
          sessionToken: sessionToken,
          walletId: fetchedWalletId,
        );
      }

      setState(() {
        balance = fetchedBalance;
        walletId = fetchedWalletId;
        transactions = fetchedTransactions;
        isLoading = false;
      });

    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, 'حدث خطأ في تحميل المحفظة: $e');
      setState(() => isLoading = false);
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
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadWalletData,
                ),
              ]),
              const SizedBox(height: 20),
              
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
              else
                Expanded(
                  child: Column(
                    children: [
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
                                  final amount = (t["amount"] ?? 0).toDouble();
                                 
                                  
                                  final isIncoming = t['to_wallet_id'] == walletId || (t['to_wallet_id']?['objectId'] == walletId);
                               
                                  
                                  final type = t['type'] ?? 'transaction';
                                  
                                  return Card(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)),
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      child: ListTile(
                                          leading: Icon(
                                              Icons.monetization_on, // Generic icon
                                              color: AppColors.skyBlue),
                                          title: Text(t["description"] ?? type),
                                          subtitle: Text(
                                              (t["created_at"] ?? t["createdAt"] ?? "").toString().substring(0, 16)),
                                          trailing: Text(
                                            "${amount.toStringAsFixed(0)} ل.س",
                                            style: const TextStyle(
                                                color:  Colors.black87,
                                                fontWeight: FontWeight.bold),
                                          )));
                                }),
                      ),
                    ],
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}
