import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 1. Thêm món yêu thích lên Firebase
  static Future<void> addFavorite(
      String userId, // Đổi int -> String
      String mealId,
      String mealName,
      String mealThumb
      ) async {

    await _db.collection('favorites').add({
      'user_id': userId,
      'meal_id': mealId,
      'meal_name': mealName,
      'meal_thumb': mealThumb,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// 2. Lấy danh sách yêu thích của một User từ Firebase
  static Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final querySnapshot = await _db
        .collection('favorites')
        .where('user_id', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      data['id'] = doc.id; // Lưu ID document nếu cần xóa sau này
      return data;
    }).toList();
  }

  /// 3. Xóa yêu thích (Dựa trên mealId và userId để chính xác)
  static Future<void> removeFavorite(String userId, String mealId) async {
    final snapshot = await _db
        .collection('favorites')
        .where('user_id', isEqualTo: userId)
        .where('meal_id', isEqualTo: mealId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 4. Xóa TẤT CẢ yêu thích của 1 user
  static Future<void> removeAllFavorites(String userId) async {
    final snapshot = await _db
        .collection('favorites')
        .where('user_id', isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 5. Kiểm tra món này đã nằm trong danh sách yêu thích của User chưa
  static Future<bool> isFavorite(String userId, String mealId) async {
    final result = await _db
        .collection('favorites')
        .where('user_id', isEqualTo: userId)
        .where('meal_id', isEqualTo: mealId)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }
}