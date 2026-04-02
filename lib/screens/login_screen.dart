import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
// ĐỔI: Dùng FirebaseService thay vì DatabaseHelper
import '../database/firebase_service.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Thêm biến loading để trải nghiệm tốt hơn

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Thực hiện đăng nhập qua AuthService (Service này sẽ gọi FirebaseService.login)
      bool success = await AuthService.login(email, pass);

      if (success) {
        if (!mounted) return;

        final user = AuthService.currentUser;

        // 2. KIỂM TRA THÔNG BÁO NẾU LÀ USER
        if (user != null && user['role'] == 'user') {
          // ĐỔI: ID của Firebase là String
          final String userId = user['id'].toString();

          // Lấy danh sách thông báo từ Firestore
          List<Map<String, dynamic>> notifications = 
              await FirebaseService.instance.getUnreadNotifications(userId);

          if (notifications.isNotEmpty && mounted) {
            // 3. HIỂN THỊ DIALOG THÔNG BÁO
            await showDialog(
              context: context,
              barrierDismissible: false, 
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Color(0xFF2E7D32)),
                    SizedBox(width: 10),
                    Text("Thông báo mới", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      String statusText = item['status'] == 'approved' ? "đã được DUYỆT" : "bị TỪ CHỐI";
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "• Món '${item['title']}' của bạn $statusText.",
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // 4. Đánh dấu đã xem trên Firestore
                      await FirebaseService.instance.markAsNotified(userId);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text("Xác nhận", style: TextStyle(color: Color(0xFF81C784), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        }

        // 5. CHUYỂN VÀO HOMESCREEN
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sai email hoặc mật khẩu!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi hệ thống: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_rounded, size: 80, color: Color(0xFF81C784)),
              const SizedBox(height: 16),
              const Text(
                "Bếp Xanh",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32)),
              ),
              const Text(
                "Nơi lưu giữ công thức hạnh phúc",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 50),
              _buildInputWrapper(
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Email/Username",
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF81C784)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputWrapper(
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Mật khẩu",
                    prefixIcon: Icon(Icons.lock_open_rounded, color: Color(0xFF81C784)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Đăng nhập",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                ),
                child: const Text(
                  "Chưa có tài khoản? Đăng ký ngay",
                  style: TextStyle(color: Color(0xFF66BB6A), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}