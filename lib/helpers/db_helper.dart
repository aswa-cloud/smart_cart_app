import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'smart_cart.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE master_products (
            id TEXT PRIMARY KEY,
            name TEXT,
            subtitle TEXT,
            price REAL,
            category TEXT,
            image_path TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE local_cart (
            id TEXT PRIMARY KEY,
            product_id TEXT,
            name TEXT,
            subtitle TEXT,
            price REAL,
            category TEXT,
            image_path TEXT,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  // --- CRUD Master Products ---
  Future<int> insertProduct(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('master_products', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final dbClient = await db;
    return await dbClient.query('master_products');
  }

  Future<int> updateProductImage(String id, String imagePath) async {
    final dbClient = await db;
    return await dbClient.update(
      'master_products',
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD Local Cart ---
  Future<int> insertCart(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('local_cart', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final dbClient = await db;
    return await dbClient.query('local_cart');
  }

  Future<int> updateCartQuantity(String id, int quantity) async {
    final dbClient = await db;
    return await dbClient.update(
      'local_cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCartItem(String id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'local_cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}