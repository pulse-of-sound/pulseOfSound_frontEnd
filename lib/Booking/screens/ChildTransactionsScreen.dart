import 'package:flutter/material.dart';
import '../../api/wallet_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';

class ChildTransactionsScreen extends StatefulWidget {
  const ChildTransactionsScreen({super.key});

  @override
  State<ChildTransactionsScreen> createState() => _ChildTransactionsScreenState();
}

class _ChildTransactionsScreenState extends State<ChildTransactionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final sessionToken = await APIHelpers.getSessionToken();
      //  Get Wallet ID first
      final balanceResult = await WalletAPI.getWalletBalance(sessionToken: sessionToken);
      if (balanceResult.containsKey('error')) {
         if(mounted) APIHelpers.showErrorDialog(context, balanceResult['error']);
         return;
      }
      final walletId = balanceResult['wallet_id'];

      if (walletId != null) {
        // Get Transactions
        final txs = await WalletTransactionAPI.getWalletTransactions(
          sessionToken: sessionToken,
          walletId: walletId,
        );
        if (mounted) {
          setState(() {
            _transactions = txs;
          });
        }
      }
    } catch (e) {
      if (mounted) APIHelpers.showErrorDialog(context, 'فشل تحميل الحركات: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/booking.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.1)), 
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "سجل الحركات المالية",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [Shadow(color: Colors.white, blurRadius: 10)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _transactions.isEmpty
                          ? const Center(
                              child: Text(
                                "لا توجد حركات مالية",
                                style: TextStyle(fontSize: 18, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final tx = _transactions[index];
                                final amount = (tx['amount'] ?? 0).toDouble();
                                final type = tx['type'] ?? 'unknown';
                                
                                // إصلاح جلب التاريخ من كائن Parse (Date Object)
                                String date = '';
                                if (tx['createdAt'] != null) {
                                  if (tx['createdAt'] is Map && tx['createdAt']['iso'] != null) {
                                    date = tx['createdAt']['iso'].toString().substring(0, 10);
                                  } else {
                                    date = tx['createdAt'].toString().substring(0, 10);
                                  }
                                }
                                
                                final isDeposit = (type == 'deposit');
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDeposit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isDeposit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                        color: isDeposit ? Colors.green : Colors.red,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      isDeposit ? 'إيداع رصيد' : (type == 'payment' ? 'دفع موعد' : type),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        date,
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${isDeposit ? "+" : "-"}${amount.toStringAsFixed(0)} ل.س',
                                          style: TextStyle(
                                            color: isDeposit ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          isDeposit ? 'وارد' : 'صادر',
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
