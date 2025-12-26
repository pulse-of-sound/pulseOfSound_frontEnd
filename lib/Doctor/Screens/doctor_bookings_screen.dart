import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/appointment_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';
import 'doctor_chat_room.dart';

class DoctorBookingsScreen extends StatefulWidget {
  const DoctorBookingsScreen({super.key});

  @override
  State<DoctorBookingsScreen> createState() => _DoctorBookingsScreenState();
}

class _DoctorBookingsScreenState extends State<DoctorBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = false;
  String _providerId = '';

  @override
  void initState() {
    super.initState();
    _loadProviderIdAndBookings();
  }

  Future<void> _loadProviderIdAndBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final providerId = prefs.getString('userId') ?? '';
    setState(() => _providerId = providerId);
    
    if (providerId.isNotEmpty) {
      await _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final result = await AppointmentAPI.getProviderAppointments(
        sessionToken: sessionToken,
        providerId: _providerId,
      );

      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'حدث خطأ: $e');
      }
    }
  }

  Future<void> _handleAppointment(String appointmentId, String decision) async {
    if (mounted) {
      APIHelpers.showLoadingDialog(context, message: 'جاري المعالجة...');
    }

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final result = await AppointmentAPI.handleAppointmentDecision(
        sessionToken: sessionToken,
        appointmentId: appointmentId,
        decision: decision,
      );

      if (mounted) {
        APIHelpers.hideLoadingDialog(context);
      }

      if (!result.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decision == 'approve' ? 'تمت الموافقة' : 'تم الرفض'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadBookings();
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

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
      case 'confirmed':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orangeAccent;
      case 'approved':
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
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
          child: Column(children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    "إدارة الحجوزات",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadBookings,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : bookings.isEmpty
                      ? const Center(
                          child: Text(
                            "لا توجد حجوزات حالياً",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final b = bookings[index];
                              final status = b["status"] ?? "pending";
                              final child = b["child"] ?? {};
                              final plan = b["appointment_plan"] ?? {};

                              return Card(
                                color: Colors.white.withOpacity(0.9),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 6,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              child["name"] ?? "طفل",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(status),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _getStatusText(status),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Plan
                                      Text(
                                        "الخطة: ${plan["title"] ?? "غير محددة"}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),

                                      // Price
                                      Text(
                                        "السعر: ${plan["price"] ?? 0} ل.س",
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),

                                      // Note
                                      if (b["note"] != null && b["note"].toString().isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          "ملاحظة: ${b["note"]}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],

                                      // Actions
                                      if (status.toLowerCase() == "pending") ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () => _handleAppointment(b["id"], "approve"),
                                              icon: const Icon(Icons.check_circle, size: 18),
                                              label: const Text("قبول"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton.icon(
                                              onPressed: () => _handleAppointment(b["id"], "reject"),
                                              icon: const Icon(Icons.cancel, size: 18),
                                              label: const Text("رفض"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.redAccent,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if ((status.toLowerCase() == "confirmed" || status.toLowerCase() == "paid") && b["chat_group_id"] != null) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => DoctorPrivateChatRoom(
                                                    parentId: b["requestedBy"]["id"] ?? "",
                                                    parentName: b["requestedBy"]["name"] ?? "ولي أمر",
                                                    appointmentId: b["id"] ?? "",
                                                    durationMinutes: plan["duration_minutes"] ?? 30,
                                                    chatGroupId: b["chat_group_id"] ?? "",
                                                    childName: child != null ? (child["name"] ?? "غير محدد") : "غير محدد",
                                                    childId: child != null ? child["id"] : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.chat),
                                            label: const Text("بدء المحادثة"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.skyBlue,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ]),
        ),
      ]),
    );
  }
}
