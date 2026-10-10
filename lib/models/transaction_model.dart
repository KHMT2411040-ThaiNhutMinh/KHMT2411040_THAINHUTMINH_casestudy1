class TransactionModel {
  final int? id;
  final String type; // 'income' | 'expense'
  final int categoryId;
  final double amount;
  final String date; // yyyy-MM-dd
  final String note;

  const TransactionModel({
    this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'category_id': categoryId,
    'amount': amount,
    'date': date,
    'note': note,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'] as int?,
    type: m['type'] as String,
    categoryId: m['category_id'] as int,
    amount: (m['amount'] as num).toDouble(),
    date: m['date'] as String,
    note: (m['note'] as String?) ?? '',
  );
}