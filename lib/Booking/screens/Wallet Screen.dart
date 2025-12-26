import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../Booking/utils/wallet_prefs.dart';
import '../../Colors/colors.dart';
import '../../SuperAdminScreens/Wallet/ReceiptModel.dart';
import 'MyReceiptsScreen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0.0;
  String? _imagePath; 
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final b = await WalletPrefs.getBalance();
    setState(() => balance = b);
  }

  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path; 
      });
    }
  }
  
  Future<void> _sendReceipt() async {
    if (_imagePath == null || amountController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار صورة وإدخال المبلغ")),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال مبلغ صحيح")),
      );
      return;
    }

    final receipt = Receipt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      parentPhone: "0999999999", 
      amount: amount,
      imagePath: _imagePath!,
    );

    await WalletPrefs.addReceipt(receipt);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم إرسال الإيصال بانتظار موافقة الإدارة")),
    );

    setState(() {
      _imagePath = null;
      amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  الخلفية
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          "المحفظة الإلكترونية",
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
                  const SizedBox(height: 20),

                  //  الرصيد الحالي
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "رصيدك الحالي",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$balance ل.س",
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //  إدخال المبلغ
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "المبلغ",
                      fillColor: Colors.white.withOpacity(0.9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  //  اختيار صورة الإيصال
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.skyBlue, width: 2.2),
                      ),
                      child: _imagePath == null
                          ? const Center(
                              child: Text(
                                "اضغط لاختيار صورة الإيصال",
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: kIsWeb
                                  ? Image.network(
                                      _imagePath!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_imagePath!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر إرسال الإيصال
                  ElevatedButton.icon(
                    onPressed: _sendReceipt,
                    icon: const Icon(Icons.upload),
                    label: const Text("إرسال الإيصال"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //  زر عرض الإيصالات
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyReceiptsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("عرض إيصالاتي"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.pinkAccent,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
