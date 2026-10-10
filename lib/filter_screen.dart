import 'package:flutter/material.dart';
import 'models/category_model.dart';
import 'utils/formatters.dart';

/// Các điều kiện lọc giao dịch
class FilterOptions {
  final String type; // 'all' | 'income' | 'expense'
  final Set<int> categoryIds;
  final DateTime? fromDate;
  final DateTime? toDate;

  const FilterOptions({
    this.type = 'all',
    this.categoryIds = const {},
    this.fromDate,
    this.toDate,
  });

  bool get isActive =>
      type != 'all' ||
          categoryIds.isNotEmpty ||
          fromDate != null ||
          toDate != null;

  FilterOptions copyWithType(String newType) {
    return FilterOptions(
      type: newType,
      categoryIds: categoryIds,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}

class FilterScreen extends StatefulWidget {
  final FilterOptions initial;
  final List<CategoryModel> categories;

  const FilterScreen({
    super.key,
    required this.initial,
    required this.categories,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const Color _primaryBlue = Color(0xFF2F6FED);

  late String _type;
  late Set<int> _categoryIds;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _categoryIds = {...widget.initial.categoryIds};
    _from = widget.initial.fromDate;
    _to = widget.initial.toDate;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final current = (isFrom ? _from : _to) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }

  void _reset() {
    setState(() {
      _type = 'all';
      _categoryIds = {};
      _from = null;
      _to = null;
    });
  }

  void _apply() {
    if (_from != null && _to != null && _from!.isAfter(_to!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày bắt đầu phải trước hoặc bằng ngày kết thúc'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      FilterOptions(
        type: _type,
        categoryIds: _categoryIds,
        fromDate: _from,
        toDate: _to,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B1B3A),
        ),
      ),
    );
  }

  Widget _typeOption(String label, String value) {
    return InkWell(
      onTap: () => setState(() => _type = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: _type == value,
              activeColor: _primaryBlue,
              onChanged: (_) => setState(() => _type = value),
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required String hint,
    required DateTime? value,
    required bool isFrom,
  }) {
    return InkWell(
      onTap: () => _pickDate(isFrom: isFrom),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? hint : formatDate(value),
                style: TextStyle(
                  fontSize: 14,
                  color: value == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Loại giao dịch'),
                  _typeOption('Tất cả', 'all'),
                  _typeOption('Thu nhập', 'income'),
                  _typeOption('Chi tiêu', 'expense'),

                  const SizedBox(height: 20),

                  _buildLabel('Danh mục'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.categories.map((cat) {
                      final selected = _categoryIds.contains(cat.id);
                      return FilterChip(
                        label: Text(cat.name),
                        selected: selected,
                        selectedColor: _primaryBlue.withOpacity(0.15),
                        checkmarkColor: _primaryBlue,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? _primaryBlue
                              : const Color(0xFFE0E0E0),
                        ),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _categoryIds.add(cat.id!);
                            } else {
                              _categoryIds.remove(cat.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  _buildLabel('Từ ngày'),
                  _dateField(hint: 'Chọn ngày bắt đầu', value: _from, isFrom: true),

                  const SizedBox(height: 16),

                  _buildLabel('Đến ngày'),
                  _dateField(hint: 'Chọn ngày kết thúc', value: _to, isFrom: false),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Đặt lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}