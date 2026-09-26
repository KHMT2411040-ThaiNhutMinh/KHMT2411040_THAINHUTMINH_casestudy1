import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class TransactionFormScreen extends StatefulWidget {
  final String appBarTitle;
  final TransactionType initialType;
  final String initialCategory;
  final String initialAmount;
  final DateTime initialDate;
  final String initialNote;

  const TransactionFormScreen({
    super.key,
    required this.appBarTitle,
    this.initialType = TransactionType.expense,
    this.initialCategory = 'Ăn uống',
    this.initialAmount = '',
    required this.initialDate,
    this.initialNote = '',
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  static const Color _primaryBlue = Color(0xFF2F6FED);
  static const Color _accentRed = Color(0xFFFF6B6B);

  late TransactionType _selectedType;
  late String _selectedCategory;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;
  late DateTime _selectedDate;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Ăn uống', 'icon': Icons.restaurant},
    {'name': 'Di chuyển', 'icon': Icons.directions_car},
    {'name': 'Mua sắm', 'icon': Icons.shopping_bag},
    {'name': 'Giải trí', 'icon': Icons.movie},
    {'name': 'Hóa đơn', 'icon': Icons.receipt_long},
    {'name': 'Khác', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategory = widget.initialCategory;
    _amountController = TextEditingController(text: widget.initialAmount);
    _noteController = TextEditingController(text: widget.initialNote);
    _selectedDate = widget.initialDate;
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
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

  InputDecoration _fieldDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue),
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
        title: Text(
          widget.appBarTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Chi tiêu / Thu nhập
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == TransactionType.expense
                              ? _accentRed
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Chi tiêu',
                          style: TextStyle(
                            color: _selectedType == TransactionType.expense
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedType == TransactionType.income
                              ? _accentRed
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            color: _selectedType == TransactionType.income
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danh mục
            _buildLabel('Danh mục'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['name'] as String,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _accentRed.withOpacity(0.15),
                            child: Icon(cat['icon'] as IconData,
                                size: 16, color: _accentRed),
                          ),
                          const SizedBox(width: 10),
                          Text(cat['name'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Số tiền
            _buildLabel('Số tiền'),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(
                hint: 'Nhập số tiền',
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 12, top: 14),
                  child: Text('đ',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Ngày giao dịch
            _buildLabel('Ngày giao dịch'),
            TextField(
              readOnly: true,
              onTap: _pickDate,
              controller: _dateController,
              decoration: _fieldDecoration(
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
            ),

            const SizedBox(height: 20),

            // Ghi chú
            _buildLabel('Ghi chú'),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _fieldDecoration(hint: 'Nhập ghi chú (tùy chọn)'),
            ),

            const SizedBox(height: 32),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: xử lý lưu giao dịch
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(
      appBarTitle: 'Thêm giao dịch',
      initialType: TransactionType.expense,
      initialCategory: 'Ăn uống',
      initialAmount: '',
      initialDate: DateTime(2025, 4, 12),
      initialNote: '',
    );
  }
}

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(
      appBarTitle: 'Sửa giao dịch',
      initialType: TransactionType.expense,
      initialCategory: 'Ăn uống',
      initialAmount: '100.000',
      initialDate: DateTime(2025, 4, 12),
      initialNote: 'Ăn trưa',
    );
  }
}