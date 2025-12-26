import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/appointment_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = false;
  String _childId = '';

  @override
  void initState() {
    super.initState();
    _loadChildIdAndAppointments();
  }

  Future<void> _loadChildIdAndAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final childId = prefs.getString('userId') ?? '';
    setState(() => _childId = childId);
    
    if (childId.isNotEmpty) {
      await _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final result = await AppointmentAPI.getChildAppointments(
        sessionToken: sessionToken,
        childId: _childId,
      );

      setState(() {
        appointments = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'حدث خطأ أثناء تحميل الحجوزات: $e');
      }
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (mounted) APIHelpers.showLoadingDialog(context, message: 'جاري الإلغاء...');

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      final result = await AppointmentAPI.cancelAppointment(
        sessionToken: sessionToken,
        appointmentId: appointmentId,
      );

      if (mounted) APIHelpers.hideLoadingDialog(context);

      if (!result.containsKey('error')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء الموعد بنجاح'), backgroundColor: Colors.green),
          );
        }
        _loadAppointments();
      } else {
        if (mounted) APIHelpers.showErrorDialog(context, result['error']);
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.hideLoadingDialog(context);
        APIHelpers.showErrorDialog(context, 'حدث خطأ أثناء الإلغاء: $e');
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
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.white;
      case 'approved':
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("حجوزاتي"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/booking.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : appointments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'لا توجد حجوزات',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.skyBlue,
                            ),
                            child: const Text('احجز الآن'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAppointments,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final providerName = appointment['provider']['name'] ?? appointment['provider_name'] ?? 'متخصص'; 
    final planTitle = appointment['appointment_plan']['title'] ?? appointment['plan_title'] ?? 'استشارة';
    final status = appointment['status'] ?? 'pending';
    final date = appointment['created_at'] ?? appointment['appointment_date'] ?? ''; 
    final note = appointment['note'] ?? '';
    final id = appointment['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _getStatusColor(status).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      providerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
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

              // Plan Title
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    planTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Date
              if (date.toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      date.toString().substring(0, 10), // Show date only
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],

              // Note
              if (note.toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Cancel Button  ONLY if status is pending
              if (status == 'pending' || status == 'pending_provider_approval') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelAppointment(id),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    label: const Text('إلغاء الموعد', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
