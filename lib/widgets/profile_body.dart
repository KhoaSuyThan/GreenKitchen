import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/history_screen.dart';
import '../screens/AboutAppScreen.dart';
import '../screens/HelpCenterScreen.dart';
import '../screens/SettingsScreen.dart';

class ProfileBody extends StatelessWidget {

  final Function(String) onHistoryMealTap; // Khai báo hàm nhận vào lịch sử
  const ProfileBody({super.key, required this.onHistoryMealTap});


  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final String role = user?['role'] ?? 'user';



    return SingleChildScrollView(
      child: Column(
        children: [
          // --- HEADER: Thông tin cá nhân ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade700, Colors.green.shade400],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 60, color: Colors.green),
                      ),
                    ),
                    // Badge cho Admin
                    if (role == 'admin')
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: const Icon(Icons.star, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  user?['username'] ?? "Khách",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  user?['email'] ?? "Chưa cập nhật email",
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                ),
                if (role == 'admin')
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("QUẢN TRỊ VIÊN", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // --- MENU LIST: Các tùy chọn ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Tài khoản"),
                _buildMenuItem(Icons.lock_outline, "Đổi mật khẩu", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen())
                  );
                }),
                _buildMenuItem(Icons.history, "Lịch sử xem món", () async {
                  final String? selectedId = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen())
                  );

                  // 2. Nếu có ID trả về (người dùng đã chọn một món)
                  if (selectedId != null) {
                    onHistoryMealTap(selectedId); // Gọi hàm để HomeScreen nhảy Tab
                  }
                }),

                const SizedBox(height: 20),
                _buildSectionTitle("Cài đặt & Hỗ trợ"),
                _buildMenuItem(Icons.settings_outlined, "Cài đặt ứng dụng", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                }),

                _buildMenuItem(Icons.help_outline, "Trung tâm trợ giúp", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                }),

                _buildMenuItem(Icons.info_outline, "Về ứng dụng", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutAppScreen()));
                }),

                const SizedBox(height: 30),
                // Nút Đăng xuất
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Trung tâm trợ giúp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.green),
                title: const Text("Gửi Email hỗ trợ"),
                subtitle: const Text("support@doanapp.com"),
                onTap: () {}, // Khoa có thể dùng url_launcher để mở app mail
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text("Hotline hỗ trợ"),
                subtitle: const Text("1900 xxxx"),
                onTap: () {}, // Khoa có thể dùng url_launcher để gọi điện
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "App Công Thức Nấu Ăn",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(Icons.restaurant_menu, size: 50, color: Colors.green),
      children: [
        const Text("Dự án được phát triển bởi Khoa và Team. Chuyên ngành Công nghệ phần mềm."),
        const SizedBox(height: 10),
        const Text("Chúc bạn có những trải nghiệm nấu ăn tuyệt vời!"),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tính năng Cài đặt đang được phát triển 🛠️"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Widget con cho tiêu đề mục
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // Widget con cho từng hàng menu
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Đổi sang màu trắng
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.green.shade600, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}