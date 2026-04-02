import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  // Biến static để lưu user đang đăng nhập hiện tại trong toàn app
  // Giữ nguyên cấu trúc Map<String, dynamic> như cũ
  static Map<String, dynamic>? currentUser;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. ĐĂNG KÝ (Firebase Firestore)
  // Đổi kiểu trả về từ Future<int> sang Future<void> vì Firebase dùng ID String tự sinh
  static Future<void> register(String username, String email, String password) async {
    try {
      // Kiểm tra xem email đã tồn tại trên Firestore chưa
      final existingUser = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception("Email này đã được đăng ký!");
      }

      // Thêm user mới vào collection 'users'
      await _db.collection('users').add({
        'username': username,
        'email': email,
        'password': password,
        'role': 'user', // Mặc định là user thường
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow; // Đẩy lỗi ra ngoài để RegisterScreen hiển thị SnackBar
    }
  }

  // 2. ĐĂNG NHẬP (Firebase Firestore)
  static Future<bool> login(String email, String password) async {
    try {
      // Truy vấn tìm user có email và password khớp
      final QuerySnapshot result = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        // Lấy dữ liệu document đầu tiên
        final doc = result.docs.first;
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        
        // QUAN TRỌNG: Gán ID của Firestore vào Map để các màn hình khác sử dụng (ID là String)
        userData['id'] = doc.id;
        
        currentUser = userData; // Lưu vào session app
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi đăng nhập Firebase: $e");
      return false;
    }
  }

  // 3. ĐỔI MẬT KHẨU (Firebase Firestore)
  // Đổi tham số userId từ int sang String
  static Future<String?> changePassword({
      required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // 1. Kiểm tra mật khẩu cũ trên Firestore
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();

      if (!userDoc.exists || userDoc.get('password') != oldPassword) {
        return "Mật khẩu cũ không chính xác.";
      }

      // 2. Cập nhật mật khẩu mới
      await _db.collection('users').doc(userId).update({
        'password': newPassword,
      });

      // 3. Đồng bộ lại biến tạm currentUser
      if (currentUser != null) {
        currentUser = Map<String, dynamic>.from(currentUser!)..['password'] = newPassword;
      }

      return null; // Thành công
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  // 4. ĐĂNG XUẤT
  static void logout() {
    currentUser = null;
  }

  // 5. KIỂM TRA QUYỀN ADMIN (Giữ nguyên)
  static bool isAdmin() {
    return currentUser?['role'] == 'admin';
  }
}