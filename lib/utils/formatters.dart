String formatCurrency(num amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs().round();
  final str = absAmount.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }

  return '${isNegative ? '-' : ''}${buffer.toString()} đ';
}

double parseCurrencyInput(String input) {
  final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) return 0;
  return double.parse(digitsOnly);
}

/// DateTime -> dd/MM/yyyy
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

/// Chuỗi yyyy-MM-dd (lưu trong database) -> dd/MM/yyyy để hiển thị
String isoToDisplayDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  return parsed == null ? iso : formatDate(parsed);
}