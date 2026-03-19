import '../database/database_helper.dart';

class HistoryService {
  // Lưu lịch sử (Nếu món đó đã xem rồi thì xóa cũ thêm mới để đẩy lên đầu)
  static Future<void> addHistory(int userId, Map<String, dynamic> meal) async {
    final db = await DatabaseHelper.instance.database;

    // Xóa nếu đã tồn tại để tránh trùng
    await db.delete('viewed_history', where: 'user_id = ? AND meal_id = ?', whereArgs: [userId, meal['idMeal']]);

    await db.insert('viewed_history', {
      'user_id': userId,
      'meal_id': meal['idMeal'],
      'meal_name': meal['strMeal'],
      'meal_thumb': meal['strMealThumb'],
    });
  }

  static Future<List<Map<String, dynamic>>> getHistory(int userId) async {
    final db = await DatabaseHelper.instance.database;
    // Sắp xếp ID DESC để món mới xem hiện lên đầu
    return await db.query(
        'viewed_history',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'id DESC'
    );
  }

  static Future<int> deleteHistoryItem(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'viewed_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 2. Xóa toàn bộ lịch sử của một người dùng
  static Future<int> clearAllHistory(int userId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'viewed_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}