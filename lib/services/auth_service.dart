import '../database/database_helper.dart';

class AuthService {
  // Biến static để lưu user đang đăng nhập hiện tại trong toàn app
  static Map<String, dynamic>? currentUser;

  // Đăng ký
  static Future<int> register(String username, String email, String password) async {
    final db = await DatabaseHelper.instance.database;

    // Kiểm tra email tồn tại chưa (tự làm thêm)

    return await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'role': 'user' // Mặc định là user thường
    });
  }

  // Đăng nhập
  static Future<bool> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      currentUser = maps.first; // Lưu thông tin người dùng vào session
      return true;
    }
    return false;
  }

  static Future<String?> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Kiểm tra mật khẩu cũ có khớp với id này không
    final List<Map<String, dynamic>> userRecord = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, oldPassword],
    );

    if (userRecord.isEmpty) {
      return "Mật khẩu cũ không chính xác.";
    }

    // 2. Nếu khớp, tiến hành cập nhật mật khẩu mới
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );

    // 3. Cập nhật lại mật khẩu trong "biến tạm" currentUser để đồng bộ app
    if (currentUser != null) {
      currentUser = Map<String, dynamic>.from(currentUser!)..['password'] = newPassword;
    }

    return null; // Trả về null tức là thành công
  }

  // Đăng xuất
  static void logout() {
    currentUser = null;
  }

  // Kiểm tra quyền Admin
  static bool isAdmin() {
    return currentUser?['role'] == 'admin';
  }
}