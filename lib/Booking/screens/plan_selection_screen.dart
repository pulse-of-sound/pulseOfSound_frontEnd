import 'package:flutter/material.dart';
import '../../api/appointment_plan_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';
import 'ConfirmBookingScreen.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String childId;
  final String providerId;
  final String providerName;

  const PlanSelectionScreen({
    super.key,
    required this.childId,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  List<Map<String, dynamic>> plans = [];
  bool isLoading = false;
  Map<String, dynamic>? selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      
      final result = await AppointmentPlanAPI.getAvailableAppointmentPlans(
        sessionToken: sessionToken,
      );

      setState(() {
        plans = result;
      });
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تحميل الخطط: $e');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("اختر خطة الاستشارة"),
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
          child: Container(
            width: 380,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // معلومات الطبيب
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.skyBlue,
                        radius: 25,
                        child: Text(
                          widget.providerName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المتخصص',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              widget.providerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  "اختر نوع الاستشارة:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // قائمة الخطط
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : plans.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد خطط متاحة',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: plans.length,
                              itemBuilder: (context, index) {
                                final plan = plans[index];
                                final isSelected = selectedPlan?['id'] == plan['id'];
                                
                                return GestureDetector(
                                  onTap: () => setState(() => selectedPlan = plan),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.skyBlue.withOpacity(0.2)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.skyBlue
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: plan['id'],
                                          groupValue: selectedPlan?['id'],
                                          onChanged: (value) {
                                            setState(() => selectedPlan = plan);
                                          },
                                          activeColor: AppColors.skyBlue,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plan['title'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'المدة: ${plan['duration_minutes']} دقيقة',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              if (plan['description'] != null &&
                                                  plan['description'].isNotEmpty)
                                                Text(
                                                  plan['description'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          APIHelpers.formatCurrency(
                                            (plan['price'] ?? 0.0).toDouble(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                
                const SizedBox(height: 20),
                
                // زر المتابعة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedPlan == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfirmBookingScreen(
                                  childId: widget.childId,
                                  providerId: widget.providerId,
                                  providerName: widget.providerName,
                                  selectedPlan: selectedPlan!,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      "متابعة",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
