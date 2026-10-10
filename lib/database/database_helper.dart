import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'expense_manager.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Danh mục mặc định
    final defaults = <CategoryModel>[
      CategoryModel(
          name: 'Ăn uống',
          type: 'expense',
          iconCode: Icons.restaurant.codePoint,
          color: 0xFFFF6B6B),
      CategoryModel(
          name: 'Mua sắm',
          type: 'expense',
          iconCode: Icons.shopping_cart.codePoint,
          color: 0xFF29B6F6),
      CategoryModel(
          name: 'Đi lại',
          type: 'expense',
          iconCode: Icons.directions_car.codePoint,
          color: 0xFF7E7BEA),
      CategoryModel(
          name: 'Học tập',
          type: 'expense',
          iconCode: Icons.menu_book.codePoint,
          color: 0xFFA66CFF),
      CategoryModel(
          name: 'Hóa đơn',
          type: 'expense',
          iconCode: Icons.receipt_long.codePoint,
          color: 0xFFFFB74D),
      CategoryModel(
          name: 'Giải trí',
          type: 'expense',
          iconCode: Icons.movie.codePoint,
          color: 0xFF26A69A),
      CategoryModel(
          name: 'Lương',
          type: 'income',
          iconCode: Icons.account_balance_wallet.codePoint,
          color: 0xFF2ECC71),
      CategoryModel(
          name: 'Thưởng',
          type: 'income',
          iconCode: Icons.card_giftcard.codePoint,
          color: 0xFF43A047),
    ];
    final ids = <String, int>{};
    for (final c in defaults) {
      final map = c.toMap()..remove('id');
      ids[c.name] = await db.insert('categories', map);
    }

    // Giao dịch mẫu (ngày tính theo hôm nay)
    final today = DateTime.now();
    Future<void> sample(String cat, String type, double amount, int daysAgo) {
      final d = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: daysAgo));
      return db.insert('transactions', {
        'type': type,
        'category_id': ids[cat],
        'amount': amount,
        'date': _iso(d),
        'note': '',
      });
    }

    await sample('Ăn uống', 'expense', 100000, 0);
    await sample('Mua sắm', 'expense', 500000, 2);
    await sample('Lương', 'income', 10000000, 5);
    await sample('Đi lại', 'expense', 200000, 7);
    await sample('Học tập', 'expense', 300000, 9);
    await sample('Hóa đơn', 'expense', 3900000, 10);
  }

  // ---------------- Categories ----------------
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  // ---------------- Transactions ----------------
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<double> getTotalByType(String type) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM transactions WHERE type = ?',
      [type],
    );
    final v = rows.first['total'];
    return v == null ? 0.0 : (v as num).toDouble();
  }

  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    final map = t.toMap()..remove('id');
    return db.insert('transactions', map);
  }

  Future<int> updateTransaction(TransactionModel t) async {
    final db = await database;
    final map = t.toMap()..remove('id');
    return db.update('transactions', map, where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}