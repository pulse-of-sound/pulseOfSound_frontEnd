import 'package:flutter/material.dart';
import '../../api/wallet_api.dart';
import '../../utils/api_helpers.dart';
import '../../Colors/colors.dart';

class WalletTransactionsScreen extends StatefulWidget {
  final String walletId;

  const WalletTransactionsScreen({
    super.key,
    required this.walletId,
  });

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _selectedType;

  final List<String> _transactionTypes = [
    'الكل',
    'payment',
    'refund',
    'reversal',
    'charge',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  /// تحميل المعاملات
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final sessionToken = await APIHelpers.getSessionToken();

      final transactions = await WalletTransactionAPI.getWalletTransactions(
        sessionToken: sessionToken,
        walletId: widget.walletId,
        type: _selectedType == 'الكل' ? null : _selectedType,
      );

      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      if (mounted) {
        APIHelpers.showErrorDialog(context, 'حدث خطأ أثناء تحميل المعاملات: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع المعاملات'),
        backgroundColor: AppColors.skyBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر نوع المعاملة
          _buildFilterSection(),

          // قائمة المعاملات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  /// قسم الفلتر
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصفية حسب النوع:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _transactionTypes.map((type) {
              final isSelected = _selectedType == type ||
                  (_selectedType == null && type == 'الكل');
              return ChoiceChip(
                label: Text(
                  type == 'الكل' ? type : APIHelpers.getTransactionTypeText(type),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = type == 'الكل' ? null : type;
                  });
                  _loadTransactions();
                },
                selectedColor: AppColors.skyBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// حالة فارغة
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد معاملات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedType != null
                ? 'لا توجد معاملات من هذا النوع'
                : 'لم تقم بأي معاملات بعد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// قائمة المعاملات
  Widget _buildTransactionsList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  /// بطاقة معاملة واحدة
  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] ?? 0.0).toDouble();
    final type = transaction['type'] ?? '';
    final date = APIHelpers.parseDateTime(transaction['createdAt']);
    final isOutgoing = transaction['from_wallet_id'] == widget.walletId;
    final appointmentId = transaction['appointment_id'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة نوع المعاملة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: APIHelpers.getTransactionTypeColor(type)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                      color: APIHelpers.getTransactionTypeColor(type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // معلومات المعاملة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          APIHelpers.getTransactionTypeText(type),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date != null ? APIHelpers.formatDateTime(date) : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // المبلغ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isOutgoing ? '-' : '+'} ${APIHelpers.formatCurrency(amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOutgoing ? Colors.red : Colors.green,
                          fontSize: 18,
                        ),
                      ),
                      if (appointmentId != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'موعد',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              // معلومات إضافية
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    'من',
                    transaction['from_wallet_id'] ?? '',
                    Icons.account_balance_wallet,
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                  _buildInfoChip(
                    'إلى',
                    transaction['to_wallet_id'] ?? '',
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// معلومات صغيرة
  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value.length > 10 ? '${value.substring(0, 10)}...' : value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض تفاصيل المعاملة
  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تفاصيل المعاملة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            _buildDetailRow('رقم المعاملة', transaction['transaction_id'] ?? ''),
            _buildDetailRow(
              'النوع',
              APIHelpers.getTransactionTypeText(transaction['type'] ?? ''),
            ),
            _buildDetailRow(
              'المبلغ',
              APIHelpers.formatCurrency(
                  (transaction['amount'] ?? 0.0).toDouble()),
            ),
            _buildDetailRow('من محفظة', transaction['from_wallet_id'] ?? ''),
            _buildDetailRow('إلى محفظة', transaction['to_wallet_id'] ?? ''),
            if (transaction['appointment_id'] != null)
              _buildDetailRow('رقم الموعد', transaction['appointment_id']),
            if (transaction['note'] != null)
              _buildDetailRow('ملاحظة', transaction['note']),
            _buildDetailRow(
              'التاريخ',
              APIHelpers.formatDateTime(
                APIHelpers.parseDateTime(transaction['createdAt']) ??
                    DateTime.now(),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  /// صف تفاصيل
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
