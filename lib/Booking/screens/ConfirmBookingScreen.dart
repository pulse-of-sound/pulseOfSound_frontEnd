import 'package:flutter/material.dart';
import '../../api/appointment_api.dart';
import '../../api/wallet_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';
import '../../HomeScreens/bottomNavBar.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final String childId;
  final String providerId;
  final String providerName;
  final Map<String, dynamic> selectedPlan;

  const ConfirmBookingScreen({
    super.key,
    required this.childId,
    required this.providerId,
    required this.providerName,
    required this.selectedPlan,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  double _walletBalance = 0.0;
  bool _isLoadingBalance = false;
  bool _isProcessing = false;
  
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletBalance() async {
    setState(() => _isLoadingBalance = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final result = await WalletAPI.getWalletBalance(
        sessionToken: sessionToken,
      );

      if (!result.containsKey('error')) {
        setState(() {
          _walletBalance = (result['balance'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تحميل الرصيد: $e');
      }
    } finally {
      setState(() => _isLoadingBalance = false);
    }
  }

  Future<void> _confirmBooking() async {
    final planPrice = (widget.selectedPlan['price'] ?? 0.0).toDouble();

    // التحقق من الرصيد
    if (!APIHelpers.hasSufficientBalance(_walletBalance, planPrice)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('رصيد غير كافٍ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الرصيد الحالي: ${APIHelpers.formatCurrency(_walletBalance)}'),
              Text('المبلغ المطلوب: ${APIHelpers.formatCurrency(planPrice)}'),
              Text(
                'النقص: ${APIHelpers.formatCurrency(planPrice - _walletBalance)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue,
              ),
              child: const Text('شحن الرصيد'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    if (mounted) {
      APIHelpers.showLoadingDialog(context, message: 'جاري إرسال الطلب...');
    }

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      // إرسال طلب الموعد
      final result = await AppointmentAPI.requestPsychologistAppointment(
        sessionToken: sessionToken,
        childId: widget.childId,
        providerId: widget.providerId,
        appointmentPlanId: widget.selectedPlan['id'],
        note: _noteController.text,
      );

      if (mounted) {
        APIHelpers.hideLoadingDialog(context);
      }

      if (!result.containsKey('error')) {
        // نجح الحجز
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  const SizedBox(width: 10),
                  const Text('تم بنجاح!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تم إرسال طلب الموعد بنجاح',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('الحالة: بانتظار موافقة المتخصص'),
                  const SizedBox(height: 5),
                  Text('المبلغ: ${APIHelpers.formatCurrency(planPrice)}'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ملاحظة: سيتم خصم المبلغ من محفظتك عند موافقة المتخصص على الطلب',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BottomNavScreen(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                  ),
                  child: const Text('حسناً'),
                ),
              ],
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
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planPrice = (widget.selectedPlan['price'] ?? 0.0).toDouble();
    final hasSufficientBalance =
        APIHelpers.hasSufficientBalance(_walletBalance, planPrice);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("تأكيد الحجز"),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // عنوان
                    const Text(
                      "ملخص الحجز",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const Divider(height: 30),
                    
                    // معلومات الحجز
                    _buildInfoRow('المتخصص', widget.providerName),
                    _buildInfoRow('نوع الاستشارة', widget.selectedPlan['title'] ?? ''),
                    _buildInfoRow(
                      'المدة',
                      '${widget.selectedPlan['duration_minutes']} دقيقة',
                    ),
                    _buildInfoRow(
                      'السعر',
                      APIHelpers.formatCurrency(planPrice),
                      valueColor: Colors.green,
                    ),
                    
                    const Divider(height: 30),
                    
                    // معلومات المحفظة
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: hasSufficientBalance
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasSufficientBalance
                              ? Colors.green
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'رصيد المحفظة:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _isLoadingBalance
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(
                                      APIHelpers.formatCurrency(_walletBalance),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: hasSufficientBalance
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                            ],
                          ),
                          if (hasSufficientBalance) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('الرصيد المتبقي:'),
                                Text(
                                  APIHelpers.formatCurrency(
                                    APIHelpers.calculateRemainingBalance(
                                      _walletBalance,
                                      planPrice,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    if (!hasSufficientBalance) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'رصيدك غير كافٍ. يرجى شحن المحفظة أولاً.',
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // حقل الملاحظة
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'ملاحظة (اختياري)',
                        hintText: 'أضف أي ملاحظات للمتخصص...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // زر التأكيد
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        "تأكيد الحجز",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: (_isProcessing || !hasSufficientBalance)
                          ? null
                          : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.skyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
