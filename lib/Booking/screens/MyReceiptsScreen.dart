import 'dart:io';
import 'package:flutter/material.dart';
import '../../Booking/utils/wallet_prefs.dart';
import '../../SuperAdminScreens/Wallet/ReceiptModel.dart';

class MyReceiptsScreen extends StatelessWidget {
  const MyReceiptsScreen({super.key});

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
          Container(color: Colors.white.withOpacity(0.25)),
          SafeArea(
            child: Column(
              children: [
                //  زر الرجوع + العنوان
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "إيصالاتي",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 10),

                //  قائمة الإيصالات
                Expanded(
                  child: FutureBuilder<List<Receipt>>(
                    future: _loadMyReceipts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "لا يوجد إيصالات بعد",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        );
                      }

                      final receipts = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: receipts.length,
                        itemBuilder: (context, index) {
                          final r = receipts[index];
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildReceiptImage(r.imagePath),
                              ),
                              title: Text("المبلغ: ${r.amount} ل.س"),
                              subtitle: Text(
                                _getStatusText(r.status),
                                style: TextStyle(
                                  color: _getStatusColor(r.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
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

  ///  تحميل الإيصالات مع معالجة آمنة
  Future<List<Receipt>> _loadMyReceipts() async {
    final data = await WalletPrefs.loadReceipts();

    if (data == null || data is! List) {
      return [];
    }

    final List<dynamic> list = List<dynamic>.from(data);

    return list.map<Receipt>((dynamic m) {
      try {
        if (m is Receipt) return m;
        if (m is Map<String, dynamic>) return Receipt.fromMap(m);
        if (m is Map) return Receipt.fromMap(Map<String, dynamic>.from(m));
      } catch (e) {
        debugPrint(" خطأ في تحويل الإيصال: $e");
      }

      return Receipt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        parentPhone: "unknown",
        amount: 0.0,
        imagePath: "",
        status: "pending",
      );
    }).toList();
  }

  ///  عرض الصورة (ملف أو أصول)
  Widget _buildReceiptImage(String path) {
    if (path.isEmpty) {
      return const Icon(Icons.receipt_long, color: Colors.blueAccent, size: 45);
    }
    if (path.startsWith('/')) {
      // صورة من الجهاز
      return Image.file(
        File(path),
        width: 55,
        height: 55,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.receipt, color: Colors.blueAccent, size: 40),
      );
    } else {
      // صورة من مجلد الصور داخل المشروع
      return Image.asset(
        path,
        width: 55,
        height: 55,
        fit: BoxFit.cover,
      );
    }
  }

  ///  النصوص والألوان حسب الحالة
  String _getStatusText(String status) {
    switch (status) {
      case "approved":
        return "تمت الموافقة";
      case "rejected":
        return "مرفوض";
      default:
        return "قيد المراجعة";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orangeAccent;
    }
  }
}
