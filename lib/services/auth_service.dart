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

  // Đăng xuất
  static void logout() {
    currentUser = null;
  }

  // Kiểm tra quyền Admin
  static bool isAdmin() {
    return currentUser?['role'] == 'admin';
  }
}