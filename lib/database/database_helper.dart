// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart' as sql; // PERBAIKAN: Memberi nama panggilan 'sql'
import 'package:path/path.dart';
import '../models/menu_item.dart';
import '../models/transaction.dart';
import '../models/transaction_detail.dart';
import '../models/restaurant_table.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static sql.Database? _database; // PERBAIKAN: Menggunakan tipe data dari 'sql'

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<sql.Database> get database async { // PERBAIKAN: Menggunakan tipe data dari 'sql'
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async { // PERBAIKAN: Menggunakan tipe data dari 'sql'
    String path = join(await sql.getDatabasesPath(), 'kasir.db'); // PERBAIKAN: Menggunakan 'sql'
    return await sql.openDatabase( // PERBAIKAN: Menggunakan 'sql'
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async { // PERBAIKAN: Menggunakan tipe data dari 'sql'
    // Create menu_items table
    await db.execute('''
      CREATE TABLE menu_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        image_path TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount INTEGER NOT NULL,
        cash_received INTEGER NOT NULL,
        change_given INTEGER NOT NULL,
        table_name TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create transaction_details table
    await db.execute('''
      CREATE TABLE transaction_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        menu_item_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price_per_item INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id),
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // Create restaurant_tables table
    await db.execute('''
      CREATE TABLE restaurant_tables(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Insert default tables
    await db.insert('restaurant_tables', {'name': 'Meja 1', 'status': 'Kosong'});
    await db.insert('restaurant_tables', {'name': 'Meja 2', 'status': 'Kosong'});
  }

  // Menu Items CRUD
  Future<int> insertMenuItem(MenuItem item) async {
    final db = await database;
    return await db.insert('menu_items', item.toMap());
  }

  Future<List<MenuItem>> getMenuItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('menu_items');
    return List.generate(maps.length, (i) => MenuItem.fromMap(maps[i]));
  }

  Future<int> updateMenuItem(MenuItem item) async {
    final db = await database;
    return await db.update(
      'menu_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteMenuItem(int id) async {
    final db = await database;
    return await db.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PERBAIKAN: Semua penggunaan Transaction dari sqflite sekarang menggunakan 'sql.Transaction'
  // Transactions CRUD
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Transaction Details CRUD
  Future<int> insertTransactionDetail(TransactionDetail detail) async {
    final db = await database;
    return await db.insert('transaction_details', detail.toMap());
  }

  Future<List<TransactionDetail>> getTransactionDetails(int transactionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_details',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    return List.generate(maps.length, (i) => TransactionDetail.fromMap(maps[i]));
  }

  // Restaurant Tables CRUD
  Future<int> insertTable(RestaurantTable table) async {
    final db = await database;
    return await db.insert('restaurant_tables', table.toMap());
  }

  Future<List<RestaurantTable>> getTables() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('restaurant_tables');
    return List.generate(maps.length, (i) => RestaurantTable.fromMap(maps[i]));
  }

  Future<int> updateTable(RestaurantTable table) async {
    final db = await database;
    return await db.update(
      'restaurant_tables',
      table.toMap(),
      where: 'id = ?',
      whereArgs: [table.id],
    );
  }

  Future<int> deleteTable(int id) async {
    final db = await database;
    return await db.delete(
      'restaurant_tables',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Financial reporting queries
  Future<Map<String, dynamic>> getFinancialSummary() async {
    final db = await database;

    // Get total sales
    final totalSalesResult =
        await db.rawQuery('SELECT SUM(total_amount) as total_sales FROM transactions');
    final totalSales = totalSalesResult.first['total_sales'] ?? 0;

    // Get total transactions count
    final transactionCountResult =
        await db.rawQuery('SELECT COUNT(*) as transaction_count FROM transactions');
    final transactionCount = transactionCountResult.first['transaction_count'] ?? 0;

    // Get most sold items
    final topItemsResult = await db.rawQuery('''
      SELECT mi.name, SUM(td.quantity) as total_quantity
      FROM transaction_details td
      JOIN menu_items mi ON td.menu_item_id = mi.id
      GROUP BY mi.id, mi.name
      ORDER BY total_quantity DESC
      LIMIT 5
    ''');

    return {
      'total_sales': totalSales,
      'transaction_count': transactionCount,
      'top_items': topItemsResult,
    };
  }
}