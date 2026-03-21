import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipe1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Nâng lên version 4 để thêm cột is_notified
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'user'");
          } catch (e) {
            print("Cột 'role' đã có sẵn!");
          }
        }
        if (oldVersion < 3) {
          await _createRecipesTable(db);
        }
        // Nâng cấp lên version 4: Thêm cột thông báo cho user
        if (oldVersion < 4) {
          try {
            await db.execute("ALTER TABLE recipes ADD COLUMN is_notified INTEGER DEFAULT 0");
          } catch (e) {
            print("Cột 'is_notified' đã có sẵn!");
          }
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      email TEXT,
      password TEXT,
      role TEXT DEFAULT 'user'
    )
    ''');

    await db.execute('''
    CREATE TABLE favorites(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      meal_id TEXT,
      meal_name TEXT,
      meal_thumb TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE search_history(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      keyword TEXT,
      time TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE viewed_history(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      meal_id TEXT,
      meal_name TEXT,
      meal_thumb TEXT,
      viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''');

    await _createRecipesTable(db);
  }

  Future _createRecipesTable(Database db) async {
    await db.execute('''
    CREATE TABLE recipes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      title TEXT,
      ingredients TEXT,
      instructions TEXT,
      image_path TEXT, 
      status TEXT DEFAULT 'pending', 
      is_notified INTEGER DEFAULT 0, -- 0: Chưa báo cho user, 1: Đã báo
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''');
  }

  // ==========================================
  // CÁC HÀM XỬ LÝ DỮ LIỆU (CONTROLLER LOGIC)
  // ==========================================

  // 1. Dành cho User: Gửi bài
  Future<int> insertRecipe(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('recipes', row);
  }

  // 2. Dành cho Admin: Lấy danh sách chờ duyệt kèm tên User
  Future<List<Map<String, dynamic>>> getPendingRecipes() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT recipes.*, users.username 
      FROM recipes 
      JOIN users ON recipes.user_id = users.id 
      WHERE recipes.status = ?
      ORDER BY recipes.created_at DESC
    ''', ['pending']);
  }

  // 3. Dành cho Admin: Duyệt bài
  Future<int> updateRecipeStatus(int id, String status) async {
    Database db = await instance.database;
    return await db.update(
      'recipes', 
      {'status': status},
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // 4. Dành cho Admin: Xóa bài
  Future<int> deleteRecipe(int id) async {
    Database db = await instance.database;
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  // 5. Lấy danh sách món ăn đã được duyệt cho HomeBody
  Future<List<Map<String, dynamic>>> getApprovedRecipes() async {
    Database db = await instance.database;
    return await db.query(
      'recipes',
      where: 'status = ?',
      whereArgs: ['approved'],
      orderBy: 'created_at DESC',
    );
  }

  // 6. Hiển thị chi tiết công thức
  Future<Map<String, dynamic>?> getRecipeById(int id) async {
    Database db = await instance.database;
    final results = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // 7. DÀNH CHO THÔNG BÁO KHI ĐĂNG NHẬP
  // Lấy các bài vừa được duyệt/từ chối mà user chưa xem thông báo
  Future<List<Map<String, dynamic>>> getUnreadNotifications(int userId) async {
    Database db = await instance.database;
    return await db.query(
      'recipes',
      where: 'user_id = ? AND is_notified = 0 AND (status = ? OR status = ?)',
      whereArgs: [userId, 'approved', 'rejected'],
    );
  }

  // Đánh dấu đã xem thông báo
  Future<int> markAsNotified(int userId) async {
    Database db = await instance.database;
    return await db.update(
      'recipes',
      {'is_notified': 1},
      where: 'user_id = ? AND is_notified = 0',
      whereArgs: [userId],
    );
  }

  // Hàm hỗ trợ Login để lấy role và ID
  Future<Map<String, dynamic>?> login(String username, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty ? res.first : null;
  }
}