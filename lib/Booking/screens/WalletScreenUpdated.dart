import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/wallet_api.dart';
import '../../api/charge_request_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';
import 'MyReceiptsScreen.dart';
import 'ChildTransactionsScreen.dart';

class WalletScreenUpdated extends StatefulWidget {
  const WalletScreenUpdated({super.key});

  @override
  State<WalletScreenUpdated> createState() => _WalletScreenUpdatedState();
}

class _WalletScreenUpdatedState extends State<WalletScreenUpdated> {
  double balance = 0.0;
  String _walletId = '';
  bool _isLoading = false;
  
  String? _imagePath;
  File? _receiptImage;
  Uint8List? _webImage;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  
  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final walletResult = await WalletAPI.getWalletBalance(
        sessionToken: sessionToken,
      );

      if (!walletResult.containsKey('error')) {
        setState(() {
          balance = (walletResult['balance'] ?? 0.0).toDouble();
          _walletId = walletResult['wallet_id'] ?? '';
        });
      } else {
        if (mounted) {
          APIHelpers.showErrorDialog(context, walletResult['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'حدث خطأ أثناء تحميل البيانات: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _imagePath = image.path;
          });
        } else {
          setState(() {
            _receiptImage = File(image.path);
            _imagePath = image.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل اختيار الصورة: $e');
      }
    }
  }

  
  Future<void> _sendReceipt() async {
    if (amountController.text.isEmpty) {
      APIHelpers.showErrorDialog(context, 'الرجاء إدخال المبلغ');
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      APIHelpers.showErrorDialog(context, 'الرجاء إدخال مبلغ صحيح');
      return;
    }

   

    if (mounted) {
      APIHelpers.showLoadingDialog(context, message: 'جاري إرسال الطلب...');
    }

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final result = await ChargeRequestAPI.createChargeRequest(
        sessionToken: sessionToken,
        amount: amount,
        note: _noteController.text,
        receiptImage: _receiptImage,
      );

      if (mounted) {
        APIHelpers.hideLoadingDialog(context);
      }

      if (!result.containsKey('error')) {
        // نجح الإرسال
        amountController.clear();
        _noteController.clear();
        setState(() {
          _imagePath = null;
          _receiptImage = null;
          _webImage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم إرسال الإيصال بانتظار موافقة الإدارة"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          APIHelpers.showErrorDialog(context, result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.hideLoadingDialog(context);
        APIHelpers.showErrorDialog(context, 'حدث خطأ: $e');
      }
    }
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  زر الرجوع العنوان
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
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        onPressed: _loadBalance,
                      ),
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
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                "${balance.toStringAsFixed(0)} ل.س",
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

                  //  إدخال ملاحظة (اختياري)
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: "ملاحظة (اختياري)",
                      fillColor: Colors.white.withOpacity(0.9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    maxLines: 2,
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
                                "اضغط لاختيار صورة الإيصال (اختياري)",
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: kIsWeb
                                  ? (_webImage != null
                                      ? Image.memory(
                                          _webImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image))
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

                  // 🧾 زر عرض الإيصالات
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
                  const SizedBox(height: 12),
                  //  زر سجل الحركات
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChildTransactionsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("سجل الحركات"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey,
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
