import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final accent = category != null ? Color(category!.color) : Colors.grey;
    final IconData icon = category != null
        ? IconData(category!.iconCode, fontFamily: 'MaterialIcons')
        : Icons.category;
    final amountColor =
    isIncome ? const Color(0xFF2E9E5B) : const Color(0xFFE53935);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Khác',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1B1B3A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isoToDisplayDate(transaction.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}