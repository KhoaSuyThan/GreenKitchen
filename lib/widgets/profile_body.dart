import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/history_screen.dart';
import '../screens/AboutAppScreen.dart';
import '../screens/HelpCenterScreen.dart';
import '../screens/SettingsScreen.dart';

class ProfileBody extends StatelessWidget {
  final Function(String) onHistoryMealTap;
  const ProfileBody({super.key, required this.onHistoryMealTap});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final String role = user?['role'] ?? 'user';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // BỌC CONTAINER ÉP MÀU NỀN TẠI ĐÂY ĐỂ TRÁNH BỊ LỖI NỀN TRẮNG TỪ TRANG MAIN
    return Container(
      color: isDark ? Colors.black : Colors.grey.shade50, // Nền đen tuyệt đối khi Dark Mode
      child: SingleChildScrollView(
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
                  // Đổi màu Gradient: Tối thì dùng xanh lục đậm (rất sang), Sáng dùng xanh lá tươi
                  colors: isDark 
                      ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)] // Xanh lục đậm
                      : [Colors.green.shade600, Colors.green.shade400],
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
                        backgroundColor: isDark ? Colors.black : Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            // Đổi icon màu xanh neon cho nổi bật trên nền tối
                            color: isDark ? Colors.greenAccent : Colors.green, 
                          ),
                        ),
                      ),
                      if (role == 'admin')
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    user?['username'] ?? "Khách",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Luôn trắng tinh
                    ),
                  ),
                  Text(
                    user?['email'] ?? "Chưa cập nhật email",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (role == 'admin')
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "QUẢN TRỊ VIÊN",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                  }),
                  _buildMenuItem(Icons.history, "Lịch sử xem món", () async {
                    final String? selectedId = await Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                    if (selectedId != null) onHistoryMealTap(selectedId);
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
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
      ),
    );
  }

  // TIÊU ĐỀ: ÉP CHỮ TRẮNG TINH
  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade700, // Trắng tinh khi dark mode
            ),
          ),
        );
      }
    );
  }

  // CÁC NÚT MENU: NỀN XÁM, CHỮ TRẮNG
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white, // Nền xám đậm cho nút
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (!isDark) // Chỉ đổ bóng ở chế độ sáng
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: isDark ? Colors.greenAccent : Colors.green, // Màu xanh sáng hơn xíu cho dễ nhìn
            ), 
            title: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87, // ÉP CHỮ TRẮNG TINH
                fontWeight: FontWeight.w500, // Cho chữ đậm lên 1 xíu để không bị chìm
              ),
            ), 
            trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white70 : Colors.grey),
            onTap: onTap,
          ),
        );
      }
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // ... Giữ nguyên như cũ ...
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
        title: Text("Xác nhận", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        content: Text("Bạn có chắc chắn muốn đăng xuất không?", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            child: const Text("Đăng xuất", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}