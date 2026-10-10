import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database/database_helper.dart';
import 'models/category_model.dart';
import 'models/transaction_model.dart';
import 'utils/formatters.dart';

/// Màn hình Thêm / Sửa giao dịch.
/// - Không truyền gì  -> chế độ Thêm
/// - Truyền existingTransaction -> chế độ Sửa (có nút xóa)
/// Khi lưu/xóa thành công sẽ pop(true) để màn trước tải lại dữ liệu.
class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;

  const TransactionFormScreen({super.key, this.existingTransaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  static const Color _blue = Color(0xFF2F6FED);
  static const Color _dark = Color(0xFF1B1B3A);
  static const Color _grey = Color(0xFF8A8FA3);
  static const Color _border = Color(0xFFD9DCE6);

  List<CategoryModel> _categories = [];
  bool _loading = true;
  late String _type;
  int? _categoryId;
  late DateTime _date;
  final TextEditingController _amountC = TextEditingController();
  final TextEditingController _noteC = TextEditingController();

  bool get _isEdit => widget.existingTransaction != null;

  List<CategoryModel> get _options =>
      _categories.where((c) => c.type == _type).toList();

  @override
  void initState() {
    super.initState();
    final t = widget.existingTransaction;
    _type = t?.type ?? 'expense';
    _date = t != null ? (DateTime.tryParse(t.date) ?? DateTime.now()) : DateTime.now();
    _categoryId = t?.categoryId;
    if (t != null) {
      _amountC.text = t.amount.round().toString();
      _noteC.text = t.note;
    }
    _load();
  }

  @override
  void dispose() {
    _amountC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cats = await DatabaseHelper.instance.getAllCategories();
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _loading = false;
      _ensureCategory();
    });
  }

  void _ensureCategory() {
    final ids = _options.map((c) => c.id).toList();
    if (_categoryId == null || !ids.contains(_categoryId)) {
      _categoryId = ids.isEmpty ? null : ids.first;
    }
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      _ensureCategory();
    });
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final amount = parseCurrencyInput(_amountC.text);
    if (amount <= 0) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')));
      return;
    }
    if (_categoryId == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }
    final model = TransactionModel(
      id: widget.existingTransaction?.id,
      type: _type,
      categoryId: _categoryId!,
      amount: amount,
      date: _iso(_date),
      note: _noteC.text.trim(),
    );
    final db = DatabaseHelper.instance;
    if (_isEdit) {
      await db.updateTransaction(model);
    } else {
      await db.insertTransaction(model);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok != true) return;
    final id = widget.existingTransaction?.id;
    if (id != null) await DatabaseHelper.instance.deleteTransaction(id);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  InputDecoration _deco(String hint, {String? suffix}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _grey, fontSize: 14),
      suffixText: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: b(_border),
      enabledBorder: b(_border),
      focusedBorder: b(_blue, 1.5),
    );
  }

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(s,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: _dark, fontSize: 14)),
  );

  Widget _typeButton(String label, String value, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setType(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? color : _border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF555B6E),
                  fontWeight: FontWeight.w600)),
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
        scrolledUnderElevation: 0,
        foregroundColor: _dark,
        centerTitle: true,
        title: Text(_isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              _typeButton('Chi tiêu', 'expense', const Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              _typeButton('Thu nhập', 'income', const Color(0xFF2ECC71)),
            ],
          ),
          _label('Danh mục'),
          DropdownButtonFormField<int>(
            value: _categoryId,
            decoration: _deco(''),
            icon: const Icon(Icons.keyboard_arrow_down, color: _grey),
            items: [
              for (final c in _options)
                DropdownMenuItem<int>(
                  value: c.id,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(c.color).withAlpha(35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          IconData(c.iconCode, fontFamily: 'MaterialIcons'),
                          color: Color(c.color),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(c.name),
                    ],
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          _label('Số tiền'),
          TextField(
            controller: _amountC,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _deco('Nhập số tiền', suffix: 'đ'),
          ),
          _label('Ngày giao dịch'),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(formatDate(_date),
                        style: const TextStyle(
                            color: _dark, fontSize: 15)),
                  ),
                  const Icon(Icons.calendar_today_outlined,
                      color: _grey, size: 18),
                ],
              ),
            ),
          ),
          _label('Ghi chú'),
          TextField(
            controller: _noteC,
            maxLines: 4,
            decoration: _deco('Nhập ghi chú (tùy chọn)'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Lưu',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}