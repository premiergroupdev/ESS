import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'survey_form_view.dart';

class ProductDatabase {
  static final ProductDatabase _instance = ProductDatabase._internal();
  factory ProductDatabase() => _instance;
  ProductDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'products.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT UNIQUE,
        product_name TEXT,
        last_updated INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_metadata(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Create indexes for faster search
    await db.execute('''
      CREATE INDEX idx_product_name ON products(product_name)
    ''');

    await db.execute('''
      CREATE INDEX idx_product_id ON products(product_id)
    ''');
  }

  // Save products to database
  Future<void> saveProducts(List<SurveyDropdownItem> products) async {
    final db = await database;
    final batch = db.batch();

    for (var product in products) {
      batch.insert(
        'products',
        {
          'product_id': product.id,
          'product_name': product.value,
          'last_updated': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);

    // Update cache timestamp
    await db.insert(
      'cache_metadata',
      {
        'key': 'last_updated',
        'value': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Saved ${products.length} products to local cache');
  }

  // Get all products from cache
  Future<List<SurveyDropdownItem>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return SurveyDropdownItem(
        id: maps[i]['product_id'].toString(),
        value: maps[i]['product_name'].toString(),
      );
    });
  }

  // Get products with pagination
  Future<List<SurveyDropdownItem>> getProductsChunk(int start, int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      limit: limit,
      offset: start,
      orderBy: 'product_name',
    );

    return List.generate(maps.length, (i) {
      return SurveyDropdownItem(
        id: maps[i]['product_id'].toString(),
        value: maps[i]['product_name'].toString(),
      );
    });
  }

  // Search products locally
  Future<List<SurveyDropdownItem>> searchProducts(String query, {int limit = 100}) async {
    final db = await database;

    if (query.isEmpty) {
      return await getProductsChunk(0, limit);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'product_name LIKE ?',
      whereArgs: ['%$query%'],
      limit: limit,
      orderBy: 'product_name',
    );

    return List.generate(maps.length, (i) {
      return SurveyDropdownItem(
        id: maps[i]['product_id'].toString(),
        value: maps[i]['product_name'].toString(),
      );
    });
  }

  // Get cache age
  Future<DateTime?> getCacheAge() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cache_metadata',
      where: 'key = ?',
      whereArgs: ['last_updated'],
    );

    if (maps.isEmpty) return null;

    final timestamp = int.tryParse(maps[0]['value'].toString());
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  // Check if cache is stale (older than 7 days)
  Future<bool> isCacheStale() async {
    final cacheAge = await getCacheAge();
    if (cacheAge == null) return true;

    final now = DateTime.now();
    final difference = now.difference(cacheAge);
    return difference.inDays > 7; // Cache valid for 7 days
  }

  // Get cached products count
  Future<int> getCachedCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products'),
    );
    return count ?? 0;
  }

  // Clear cache
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('products');
    await db.delete('cache_metadata');
  }
}