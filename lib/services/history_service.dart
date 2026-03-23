import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. LƯU LỊCH SỬ (Cập nhật nếu đã tồn tại)
  // ==========================================
  static Future<void> addHistory(String userId, Map<String, dynamic> meal) async {
    try {
      // Tìm xem món này đã có trong lịch sử của User này chưa
      final query = await _db
          .collection('viewed_history')
          .where('user_id', isEqualTo: userId)
          .where('meal_id', isEqualTo: meal['idMeal'])
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // ✅ Đã tồn tại -> Cập nhật thời gian xem mới nhất để đẩy lên đầu
        await query.docs.first.reference.update({
          'viewed_at': FieldValue.serverTimestamp(),
        });
      } else {
        // ✅ Chưa có -> Thêm mới bản ghi
        await _db.collection('viewed_history').add({
          'user_id': userId,
          'meal_id': meal['idMeal'],
          'meal_name': meal['strMeal'],
          'meal_thumb': meal['strMealThumb'],
          'viewed_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Lỗi lưu lịch sử: $e");
    }
  }

  // ==========================================
  // 2. LẤY LỊCH SỬ (Sắp xếp tại Client để tránh lỗi Index)
  // ==========================================
  static Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      final snapshot = await _db
          .collection('viewed_history')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> list = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Lưu ID document để xóa
        return data;
      }).toList();

      // ✅ Sắp xếp tại Client: Món mới xem (viewed_at lớn nhất) lên đầu
      list.sort((a, b) {
        final aTime = (a['viewed_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bTime = (b['viewed_at'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return list;
    } catch (e) {
      print("Lỗi getHistory: $e");
      return [];
    }
  }

  // ==========================================
  // 3. XÓA 1 MỤC LỊCH SỬ
  // ==========================================
  static Future<void> deleteHistoryItem(String id) async {
    try {
      await _db.collection('viewed_history').doc(id).delete();
    } catch (e) {
      print("Lỗi deleteHistoryItem: $e");
    }
  }

  // ==========================================
  // 4. XÓA TẤT CẢ LỊCH SỬ CỦA USER
  // ==========================================
  static Future<void> clearAllHistory(String userId) async {
    try {
      final snapshot = await _db
          .collection('viewed_history')
          .where('user_id', isEqualTo: userId)
          .get();

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print("Lỗi clearAllHistory: $e");
    }
  }
}