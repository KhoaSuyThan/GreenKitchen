import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._init();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseService._init();

  // ==========================================
  // 1. AUTH
  // ==========================================

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      QuerySnapshot res = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (res.docs.isNotEmpty) {
        Map<String, dynamic> data =
            res.docs.first.data() as Map<String, dynamic>;
        data['id'] = res.docs.first.id;
        return data;
      }
    } catch (e) {
      print("Lỗi login: $e");
    }
    return null;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      await _db.collection('users').add({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi register: $e");
    }
  }

  // ==========================================
  // 2. RECIPES
  // ==========================================

  Future<void> insertRecipe(Map<String, dynamic> row) async {
    try {
      row['created_at'] = FieldValue.serverTimestamp();
      row['status'] = row['status'] ?? 'pending';
      row['is_notified'] = row['is_notified'] ?? 0;

      await _db.collection('recipes').add(row);
    } catch (e) {
      print("Lỗi insertRecipe: $e");
    }
  }

  // ✅ FIX: Không dùng orderBy → tránh lỗi index
  Future<List<Map<String, dynamic>>> getPendingRecipes() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('recipes')
          .where('status', isEqualTo: 'pending')
          .get();

      List<Map<String, dynamic>> list = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort local
      list.sort((a, b) {
        final aTime = a['created_at']?.toDate() ?? DateTime(2000);
        final bTime = b['created_at']?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return list;
    } catch (e) {
      print("Lỗi getPendingRecipes: $e");
      return [];
    }
  }

  Future<void> updateRecipeStatus(String id, String status) async {
    try {
      await _db.collection('recipes').doc(id).update({
        'status': status,
        'is_notified': 0,
      });
    } catch (e) {
      print("Lỗi update status: $e");
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _db.collection('recipes').doc(id).delete();
    } catch (e) {
      print("Lỗi delete: $e");
    }
  }

  // ✅ FIX CHÍNH: bỏ orderBy → không cần index
  Future<List<Map<String, dynamic>>> getApprovedRecipes() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('recipes')
          .where('status', isEqualTo: 'approved')
          .get();

      List<Map<String, dynamic>> list = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort local
      list.sort((a, b) {
        final aTime = a['created_at']?.toDate() ?? DateTime(2000);
        final bTime = b['created_at']?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return list;
    } catch (e) {
      print("Lỗi getApprovedRecipes: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRecipeById(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection('recipes').doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
    } catch (e) {
      print("Lỗi getRecipeById: $e");
    }
    return null;
  }

  // ==========================================
  // 3. NOTIFICATIONS
  // ==========================================

  Future<List<Map<String, dynamic>>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('recipes')
          .where('user_id', isEqualTo: userId)
          .where('is_notified', isEqualTo: 0)
          .where('status', whereIn: ['approved', 'rejected'])
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Lỗi notification: $e");
      return [];
    }
  }

  Future<void> markAsNotified(String userId) async {
    try {
      var snapshots = await _db
          .collection('recipes')
          .where('user_id', isEqualTo: userId)
          .where('is_notified', isEqualTo: 0)
          .get();

      for (var doc in snapshots.docs) {
        await doc.reference.update({'is_notified': 1});
      }
    } catch (e) {
      print("Lỗi markAsNotified: $e");
    }
  }
}
