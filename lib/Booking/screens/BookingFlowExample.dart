import 'package:flutter/material.dart';
import '../../api/appointment_api.dart';
import '../../api/appointment_plan_api.dart';
import '../../api/invoice_api.dart';
import '../../api/wallet_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';

class BookingFlowExample extends StatefulWidget {
  final String childId;
  final String providerId;

  const BookingFlowExample({
    super.key,
    required this.childId,
    required this.providerId,
  });

  @override
  State<BookingFlowExample> createState() => _BookingFlowExampleState();
}

class _BookingFlowExampleState extends State<BookingFlowExample> {
  int _currentStep = 0;
  bool _isLoading = false;

  // البيانات
  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _selectedPlan;
  double _walletBalance = 0.0;
  String _walletId = '';
  String? _appointmentId;
  String? _invoiceId;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// الخطوة 1: تحميل الخطط المتاحة
  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final plans = await AppointmentPlanAPI.getAvailableAppointmentPlans(
        sessionToken: sessionToken,
      );

      setState(() {
        _plans = plans;
      });
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تحميل الخطط: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// الخطوة 2: تحميل رصيد المحفظة
  Future<void> _loadWalletBalance() async {
    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final result = await WalletAPI.getWalletBalance(
        sessionToken: sessionToken,
      );

      if (!result.containsKey('error')) {
        setState(() {
          _walletBalance = (result['balance'] ?? 0.0).toDouble();
          _walletId = result['wallet_id'] ?? '';
        });
      } else {
        if (mounted) {
          APIHelpers.showErrorDialog(context, result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تحميل الرصيد: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// الخطوة 3: إنشاء الموعد
  Future<void> _createAppointment() async {
    if (_selectedPlan == null) {
      APIHelpers.showErrorDialog(context, 'يرجى اختيار خطة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final result = await AppointmentAPI.requestPsychologistAppointment(
        sessionToken: sessionToken,
        childId: widget.childId,
        providerId: widget.providerId,
        appointmentPlanId: _selectedPlan!['id'],
        note: _noteController.text,
      );

      if (!result.containsKey('error')) {
        setState(() {
          _appointmentId = result['appointment']['objectId'];
        });

        // الانتقال للخطوة التالية
        await _createInvoice();
      } else {
        if (mounted) {
          APIHelpers.showErrorDialog(context, result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل إنشاء الموعد: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// الخطوة 4: إنشاء الفاتورة
  Future<void> _createInvoice() async {
    if (_appointmentId == null) return;

    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final result = await InvoiceAPI.createInvoiceForAppointment(
        sessionToken: sessionToken,
        appointmentId: _appointmentId!,
      );

      if (!result.containsKey('error')) {
        setState(() {
          _invoiceId = result['invoice']['objectId'];
          _currentStep = 2; // الانتقال لخطوة الدفع
        });
      } else {
        if (mounted) {
          APIHelpers.showErrorDialog(context, result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل إنشاء الفاتورة: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// الخطوة 5: تأكيد الدفع
  Future<void> _confirmPayment() async {
    if (_invoiceId == null) return;

    final planPrice = (_selectedPlan?['price'] ?? 0.0).toDouble();

    // التحقق من كفاية الرصيد
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
                // الانتقال لشاشة شحن الرصيد
                // Navigator.push(context, MaterialPageRoute(...));
              },
              child: const Text('شحن الرصيد'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final result = await InvoiceAPI.confirmInvoicePayment(
        sessionToken: sessionToken,
        invoiceId: _invoiceId!,
      );

      if (!result.containsKey('error')) {
        setState(() {
          _currentStep = 3; // الانتقال لخطوة النجاح
        });

        if (mounted) {
          APIHelpers.showSuccessDialog(
            context,
            'تم الدفع بنجاح!\nتم إرسال الطلب للمزود',
            onDismiss: () {
              // العودة للصفحة الرئيسية أو صفحة المواعيد
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        }
      } else {
        if (mounted) {
          APIHelpers.showErrorDialog(context, result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تأكيد الدفع: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد'),
        backgroundColor: AppColors.skyBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (_currentStep < 3)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.skyBlue,
                          ),
                          child: Text(_currentStep == 2 ? 'تأكيد الدفع' : 'التالي'),
                        ),
                      const SizedBox(width: 12),
                      if (_currentStep > 0 && _currentStep < 3)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('السابق'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // الخطوة 1: اختيار الخطة
                Step(
                  title: const Text('اختر الخطة'),
                  content: _buildPlanSelection(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),

                // الخطوة 2: إضافة ملاحظة
                Step(
                  title: const Text('ملاحظات'),
                  content: _buildNoteSection(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),

                // الخطوة 3: الدفع
                Step(
                  title: const Text('الدفع'),
                  content: _buildPaymentSection(),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                ),

                // الخطوة 4: النجاح
                Step(
                  title: const Text('تم'),
                  content: _buildSuccessSection(),
                  isActive: _currentStep >= 3,
                  state: _currentStep == 3 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
    );
  }

  /// اختيار الخطة
  Widget _buildPlanSelection() {
    if (_plans.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('لا توجد خطط متاحة'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _plans.map((plan) {
        final isSelected = _selectedPlan?['id'] == plan['id'];
        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? AppColors.skyBlue.withOpacity(0.1) : null,
          child: ListTile(
            leading: Radio<String>(
              value: plan['id'],
              groupValue: _selectedPlan?['id'],
              onChanged: (value) {
                setState(() {
                  _selectedPlan = plan;
                });
              },
            ),
            title: Text(
              plan['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المدة: ${plan['duration_minutes']} دقيقة'),
                if (plan['description'] != null && plan['description'].isNotEmpty)
                  Text(plan['description']),
              ],
            ),
            trailing: Text(
              APIHelpers.formatCurrency((plan['price'] ?? 0.0).toDouble()),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedPlan = plan;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  /// قسم الملاحظات
  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'أضف ملاحظة للمزود (اختياري)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'اكتب ملاحظتك هنا...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// قسم الدفع
  Widget _buildPaymentSection() {
    final planPrice = (_selectedPlan?['price'] ?? 0.0).toDouble();
    final hasSufficientBalance =
        APIHelpers.hasSufficientBalance(_walletBalance, planPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ملخص الدفع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Divider(),
                _buildSummaryRow('الخطة', _selectedPlan?['title'] ?? ''),
                _buildSummaryRow(
                  'المبلغ',
                  APIHelpers.formatCurrency(planPrice),
                ),
                const Divider(),
                _buildSummaryRow(
                  'رصيد المحفظة',
                  APIHelpers.formatCurrency(_walletBalance),
                  valueColor: hasSufficientBalance ? Colors.green : Colors.red,
                ),
                if (hasSufficientBalance)
                  _buildSummaryRow(
                    'الرصيد المتبقي',
                    APIHelpers.formatCurrency(
                      APIHelpers.calculateRemainingBalance(_walletBalance, planPrice),
                    ),
                    valueColor: Colors.blue,
                  ),
              ],
            ),
          ),
        ),
        if (!hasSufficientBalance) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'رصيدك غير كافٍ. يرجى شحن المحفظة أولاً.',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// صف ملخص
  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  /// قسم النجاح
  Widget _buildSuccessSection() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 80,
        ),
        const SizedBox(height: 16),
        const Text(
          'تم حجز الموعد بنجاح!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تم إرسال الطلب للمزود وسيتم إشعارك عند الموافقة',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
          ),
          child: const Text('العودة للرئيسية'),
        ),
      ],
    );
  }

  /// الانتقال للخطوة التالية
  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_selectedPlan == null) {
        APIHelpers.showErrorDialog(context, 'يرجى اختيار خطة');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      _loadWalletBalance().then((_) {
        _createAppointment();
      });
    } else if (_currentStep == 2) {
      _confirmPayment();
    }
  }

  /// العودة للخطوة السابقة
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }
}
