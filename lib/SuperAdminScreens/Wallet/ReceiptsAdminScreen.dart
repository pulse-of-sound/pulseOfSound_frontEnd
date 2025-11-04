import 'dart:io';
import 'package:flutter/material.dart';
import '../../Booking/utils/wallet_prefs.dart';
import '../../Colors/colors.dart';
import 'ReceiptModel.dart';

class ReceiptsAdminScreen extends StatefulWidget {
  const ReceiptsAdminScreen({super.key});

  @override
  State<ReceiptsAdminScreen> createState() => _ReceiptsAdminScreenState();
}

class _ReceiptsAdminScreenState extends State<ReceiptsAdminScreen> {
  List<Receipt> receipts = [
    Receipt(
      id: "1",
      parentPhone: "0999999999",
      amount: 50.0,
      imagePath: "images/electric-bill.jpg",
    ),
    Receipt(
      id: "2",
      parentPhone: "0988888888",
      amount: 30.0,
      imagePath: "images/electric-bill.jpg",
    ),
  ];

  void _approveReceipt(int index) async {
    final receipt = receipts[index];
    await WalletPrefs.addFunds(receipt.amount);
    setState(() => receipt.status = "approved");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تمت الموافقة على الإيصال وإضافة الرصيد")),
    );
  }

  void _rejectReceipt(int index) {
    setState(() => receipts[index].status = "rejected");
  }

  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  /// 🔹 دالة آمنة لعرض الصورة سواء من asset أو ملف
  Widget _buildReceiptImage(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      } else {
        return Image.asset(
          path,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long,
              color: Colors.blueAccent, size: 40),
        );
      }
    } catch (_) {
      return const Icon(Icons.receipt_long, color: Colors.blueAccent, size: 40);
    }
  }

  ///  فتح الصورة بالحجم الكامل داخل حوار منبثق
  void _showFullImage(String path) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black87,
          insetPadding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 3.0,
              child: _buildLargeImage(path),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLargeImage(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      } else {
        return Image.asset(path, fit: BoxFit.contain);
      }
    } catch (_) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/Admin.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              //  العنوان العلوي
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "إدارة الإيصالات",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 10),

              //  قائمة الإيصالات
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: receipts.length,
                  itemBuilder: (context, index) {
                    final receipt = receipts[index];
                    return Card(
                        color: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: GestureDetector(
                            onTap: () => _showFullImage(receipt.imagePath),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildReceiptImage(receipt.imagePath),
                            ),
                          ),
                          title: Text(
                            "رقم الموبايل: ${receipt.parentPhone}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("المبلغ: ${receipt.amount} ل.س"),
                              Text(
                                "الحالة: ${receipt.status == "pending" ? "قيد المراجعة" : receipt.status == "approved" ? "مقبول" : "مرفوض"}",
                                style: TextStyle(
                                    color: _statusColor(receipt.status),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: receipt.status == "pending"
                              ? Column(
                                  mainAxisSize:
                                      MainAxisSize.min, //  الحل الأساسي
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: IconButton(
                                        icon: const Icon(Icons.check_circle,
                                            color: Colors.green, size: 28),
                                        tooltip: "قبول الإيصال",
                                        onPressed: () => _approveReceipt(index),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.redAccent, size: 26),
                                      tooltip: "رفض الإيصال",
                                      onPressed: () => _rejectReceipt(index),
                                    ),
                                  ],
                                )
                              : Icon(Icons.verified,
                                  color: _statusColor(receipt.status)),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
