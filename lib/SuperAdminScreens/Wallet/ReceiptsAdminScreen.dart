import 'dart:io';
import 'package:flutter/material.dart';
import '../../api/charge_request_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';

class ReceiptsAdminScreen extends StatefulWidget {
  const ReceiptsAdminScreen({super.key});

  @override
  State<ReceiptsAdminScreen> createState() => _ReceiptsAdminScreenState();
}

class _ReceiptsAdminScreenState extends State<ReceiptsAdminScreen> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = false;
  String _selectedFilter = 'pending'; // pending, approved, rejected, all

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();
      
      final requests = await ChargeRequestAPI.getChargeRequests(
        sessionToken: sessionToken,
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      setState(() {
        _requests = requests;
      });
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل تحميل الطلبات: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(String requestId, int index) async {
    try {
      final sessionToken = await APIHelpers.getSessionToken();
      
      final result = await ChargeRequestAPI.approveChargeRequest(
        sessionToken: sessionToken,
        chargeRequestId: requestId,
      );

      if (result.containsKey('error')) {
        if (mounted) {
          APIHelpers.showErrorDialog(context, result['error']);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت الموافقة على الطلب! الرصيد تم إضافته للمحفظة.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadRequests(); // تحديث القائمة
      }
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'فشل الموافقة على الطلب: $e');
      }
    }
  }

  Future<void> _rejectRequest(String requestId, int index) async {
    // عرض حوار لإدخال سبب الرفض
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'سبب الرفض',
            hintText: 'أدخل سبب رفض الطلب',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        final sessionToken = await APIHelpers.getSessionToken();
        
        final result = await ChargeRequestAPI.rejectChargeRequest(
          sessionToken: sessionToken,
          chargeRequestId: requestId,
          rejectionNote: reasonController.text,
        );

        if (result.containsKey('error')) {
          if (mounted) {
            APIHelpers.showErrorDialog(context, result['error']);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم رفض الطلب.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          _loadRequests(); // تحديث القائمة
        }
      } catch (e) {
        if (mounted) {
          APIHelpers.showErrorDialog(context, 'فشل رفض الطلب: $e');
        }
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return '';
      
      // إذا كان Object من Parse
      if (dateValue is Map && dateValue.containsKey('iso')) {
        final isoString = dateValue['iso'] as String;
        final date = DateTime.parse(isoString);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      
      // إذا كان String
      if (dateValue is String) {
        final date = DateTime.parse(dateValue);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      
      return dateValue.toString();
    } catch (e) {
      return '';
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
                image: AssetImage("images/Admin.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // العنوان العلوي
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "إدارة طلبات الشحن",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadRequests,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // فلتر الحالة
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterChip('الكل', 'all'),
                      _buildFilterChip('قيد المراجعة', 'pending'),
                      _buildFilterChip('مقبول', 'approved'),
                      _buildFilterChip('مرفوض', 'rejected'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // قائمة الطلبات
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : _requests.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'لا توجد طلبات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) {
                                final request = _requests[index];
                                return _buildRequestCard(request, index);
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _loadRequests();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.skyBlue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, int index) {
    final requestId = request['charge_request_id'] ?? '';
    final username = request['username'] ?? 'غير معروف';
    final amount = request['amount'] ?? 0;
    final status = request['status'] ?? 'pending';
    final note = request['note'] ?? '';
    final createdAt = request['createdAt'] ?? '';

    return Card(
      color: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المستخدم: $username',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المبلغ: ${APIHelpers.formatCurrency(amount.toDouble())}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.skyBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _statusColor(status)),
                  ),
                  child: Text(
                    _statusText(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'الملاحظة: $note',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            if (createdAt != null && createdAt.toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'التاريخ: ${_formatDate(createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRequest(requestId, index),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('موافقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectRequest(requestId, index),
                      icon: const Icon(Icons.cancel),
                      label: const Text('رفض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
