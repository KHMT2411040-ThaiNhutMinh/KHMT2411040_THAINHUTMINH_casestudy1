import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'transaction_screens.dart';
import 'utils/app_state.dart';
import 'utils/formatters.dart';
import 'widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  /// Gọi khi bấm "Xem tất cả" (chuyển sang tab Giao dịch)
  final VoidCallback? onSeeAll;

  const DashboardScreen({super.key, this.onSeeAll});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _primaryBlue = Color(0xFF2F6FED);

  bool _isLoading = true;
  List<TransactionModel> _transactions = [];
  Map<int, CategoryModel> _categoryById = {};
  double _totalIncome = 0;
  double _totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    dataVersion.addListener(_loadData);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final categories = await db.getAllCategories();
    final transactions = await db.getAllTransactions();
    final income = await db.getTotalByType('income');
    final expense = await db.getTotalByType('expense');

    if (!mounted) return;
    setState(() {
      _categoryById = {for (var c in categories) c.id!: c};
      _transactions = transactions;
      _totalIncome = income;
      _totalExpense = expense;
      _isLoading = false;
    });
  }

  Future<void> _openEditScreen(TransactionModel transaction) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(existingTransaction: transaction),
      ),
    );
    if (changed == true) notifyDataChanged();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final balance = _totalIncome - _totalExpense;
    final recent = _transactions.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header xanh + thẻ số dư đè lên
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding:
                    EdgeInsets.fromLTRB(20, topPadding + 16, 20, 80),
                    decoration: const BoxDecoration(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hôm nay là một ngày tốt lành!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0x33FFFFFF),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.fromLTRB(16, topPadding + 100, 16, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Số dư hiện tại',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatCurrency(balance),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B1B3A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: _primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thu nhập / Chi tiêu
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Thu nhập',
                            amount: formatCurrency(_totalIncome),
                            icon: Icons.arrow_downward,
                            color: const Color(0xFF2E9E5B),
                            background: const Color(0xFFE3F5EA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Chi tiêu',
                            amount: formatCurrency(_totalExpense),
                            icon: Icons.arrow_upward,
                            color: const Color(0xFFE53935),
                            background: const Color(0xFFFDE8E8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chi tiêu gần đây',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B3A),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onSeeAll,
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(
                              fontSize: 13,
                              color: _primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (recent.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Chưa có giao dịch nào',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            for (int i = 0; i < recent.length; i++) ...[
                              TransactionTile(
                                transaction: recent[i],
                                category:
                                _categoryById[recent[i].categoryId],
                                onTap: () => _openEditScreen(recent[i]),
                              ),
                              if (i != recent.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: 68,
                                  color: Color(0xFFEDEFF5),
                                ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color background;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}