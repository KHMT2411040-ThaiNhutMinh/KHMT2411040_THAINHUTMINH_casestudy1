import 'dart:math';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'utils/app_state.dart';
import 'utils/formatters.dart';

enum _Period { thisMonth, lastMonth, thisYear }

class _CategoryStat {
  final CategoryModel? category;
  final double amount;

  _CategoryStat(this.category, this.amount);

  Color get color => category != null ? Color(category!.color) : Colors.grey;
  String get name => category?.name ?? 'Khác';
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const Color _primaryBlue = Color(0xFF2F6FED);

  _Period _period = _Period.thisMonth;
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];
  Map<int, CategoryModel> _categoryById = {};

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

    if (!mounted) return;
    setState(() {
      _categoryById = {for (var c in categories) c.id!: c};
      _transactions = transactions;
      _isLoading = false;
    });
  }

  bool _inPeriod(DateTime d) {
    final now = DateTime.now();
    switch (_period) {
      case _Period.thisMonth:
        return d.year == now.year && d.month == now.month;
      case _Period.lastMonth:
        final last = DateTime(now.year, now.month - 1, 1);
        return d.year == last.year && d.month == last.month;
      case _Period.thisYear:
        return d.year == now.year;
    }
  }

  List<_CategoryStat> _computeStats() {
    final Map<int, double> sums = {};
    for (final t in _transactions) {
      if (t.type != 'expense') continue;
      final date = DateTime.tryParse(t.date);
      if (date == null || !_inPeriod(date)) continue;
      sums[t.categoryId] = (sums[t.categoryId] ?? 0) + t.amount;
    }

    final stats = sums.entries
        .map((e) => _CategoryStat(_categoryById[e.key], e.value))
        .toList();
    stats.sort((a, b) => b.amount.compareTo(a.amount));
    return stats;
  }

  Widget _periodChip(String label, _Period period) {
    final selected = _period == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _period = period),
        child: Container(
          margin: EdgeInsets.only(right: period == _Period.thisYear ? 0 : 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _primaryBlue : const Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _computeStats();
    final total = stats.fold<double>(0, (sum, s) => sum + s.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B3A),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _periodChip('Tháng này', _Period.thisMonth),
                  _periodChip('Tháng trước', _Period.lastMonth),
                  _periodChip('Năm nay', _Period.thisYear),
                ],
              ),

              const SizedBox(height: 24),

              // Biểu đồ tròn
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: _DonutPainter(
                          values: stats.map((s) => s.amount).toList(),
                          colors: stats.map((s) => s.color).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatCurrency(total),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B1B3A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tổng chi tiêu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (stats.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Chưa có chi tiêu trong kỳ này',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (final s in stats)
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1B1B3A),
                                  ),
                                ),
                              ),
                              Text(
                                '${(s.amount / total * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                formatCurrency(s.amount),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B1B3A),
                                ),
                              ),
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

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final total = values.fold<double>(0, (sum, v) => sum + v);

    if (total <= 0) {
      final emptyPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0xFFE6E9F2);
      canvas.drawArc(rect, 0, 2 * pi, false, emptyPaint);
      return;
    }

    double startAngle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = colors[i];
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}