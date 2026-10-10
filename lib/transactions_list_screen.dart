import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'filter_screen.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'transaction_screens.dart';
import 'utils/app_state.dart';
import 'widgets/transaction_tile.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  static const Color _primaryBlue = Color(0xFF2F6FED);

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<TransactionModel> _all = [];
  Map<int, CategoryModel> _categoryById = {};
  FilterOptions _filter = const FilterOptions();

  @override
  void initState() {
    super.initState();
    _loadData();
    dataVersion.addListener(_loadData);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_loadData);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final categories = await db.getAllCategories();
    final transactions = await db.getAllTransactions();

    if (!mounted) return;
    setState(() {
      _categoryById = {for (var c in categories) c.id!: c};
      _all = transactions;
      _isLoading = false;
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<TransactionModel> get _filtered {
    final query = _searchController.text.trim().toLowerCase();

    return _all.where((t) {
      if (_filter.type != 'all' && t.type != _filter.type) return false;

      if (_filter.categoryIds.isNotEmpty &&
          !_filter.categoryIds.contains(t.categoryId)) {
        return false;
      }

      final date = DateTime.tryParse(t.date);
      if (date != null) {
        if (_filter.fromDate != null &&
            date.isBefore(_dateOnly(_filter.fromDate!))) {
          return false;
        }
        if (_filter.toDate != null &&
            date.isAfter(_dateOnly(_filter.toDate!))) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final categoryName =
            _categoryById[t.categoryId]?.name.toLowerCase() ?? '';
        if (!categoryName.contains(query) &&
            !t.note.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.of(context).push<FilterOptions>(
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          initial: _filter,
          categories: _categoryById.values.toList(),
        ),
      ),
    );
    if (result != null) {
      setState(() => _filter = result);
    }
  }

  Future<void> _openEdit(TransactionModel transaction) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(existingTransaction: transaction),
      ),
    );
    if (changed == true) notifyDataChanged();
  }

  Widget _buildChip(String label, String type) {
    final selected = _filter.type == type;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _filter = _filter.copyWithType(type)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
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
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final filterActive = _filter.isActive;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Giao dịch',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B3A),
                ),
              ),
              const SizedBox(height: 16),

              // Ô tìm kiếm + nút bộ lọc
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm giao dịch...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF1F3F8),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _openFilter,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: filterActive
                            ? _primaryBlue.withOpacity(0.12)
                            : const Color(0xFFF1F3F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: filterActive ? _primaryBlue : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Chip Tất cả / Thu nhập / Chi tiêu
              Row(
                children: [
                  _buildChip('Tất cả', 'all'),
                  _buildChip('Thu nhập', 'income'),
                  _buildChip('Chi tiêu', 'expense'),
                ],
              ),

              const SizedBox(height: 8),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? Center(
                  child: Text(
                    'Không có giao dịch nào',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 68,
                    color: Color(0xFFEDEFF5),
                  ),
                  itemBuilder: (context, index) {
                    final t = items[index];
                    return TransactionTile(
                      transaction: t,
                      category: _categoryById[t.categoryId],
                      onTap: () => _openEdit(t),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}