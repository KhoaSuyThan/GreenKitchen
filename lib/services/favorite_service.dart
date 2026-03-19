import '../database/database_helper.dart';

class FavoriteService {

  /// thêm món yêu thích
  static Future<void> addFavorite(
      int userId,
      String mealId,
      String mealName,
      String mealThumb
      ) async {

    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'favorites',
      {
        'user_id': userId,
        'meal_id': mealId,
        'meal_name': mealName,
        'meal_thumb': mealThumb,
      },
    );
  }

  /// lấy danh sách yêu thích
  static Future<List<Map<String, dynamic>>> getFavorites(int userId) async {

    final db = await DatabaseHelper.instance.database;

    return await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// xóa yêu thích
  static Future<void> removeFavorite(String mealId) async {

    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'favorites',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );
  }

  /// xóa TẤT CẢ yêu thích của 1 user
  static Future<void> removeAllFavorites(int userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// kiểm tra đã favorite chưa
  static Future<bool> isFavorite(String mealId) async {

    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'favorites',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );

    return result.isNotEmpty;
  }
}