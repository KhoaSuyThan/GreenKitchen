import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // THÊM thư viện Firestore
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/history_screen.dart';
import '../screens/AboutAppScreen.dart';
import '../screens/HelpCenterScreen.dart';
import '../screens/SettingsScreen.dart';

// ĐỔI TỪ StatelessWidget SANG StatefulWidget
class ProfileBody extends StatefulWidget {
  final Function(String) onHistoryMealTap;
  const ProfileBody({super.key, required this.onHistoryMealTap});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _localPhotoUrl; // Biến lưu tạm link ảnh để giao diện cập nhật ngay lập tức

  @override
  void initState() {
    super.initState();
    // Khởi tạo link ảnh hiện tại từ AuthService (nếu có)
    _localPhotoUrl = AuthService.currentUser?['photoUrl'];
  }

  // --- HÀM 1: CẬP NHẬT ẢNH LÊN FIRESTORE ---
 Future<void> _updateAvatarOnFirestore(String newUrl) async {
    final user = AuthService.currentUser;
    // Đổi kiểm tra 'uid' thành kiểm tra 'email'
    if (user == null || user['email'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Không tìm thấy Email người dùng!")));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 1. Quét tìm document trong 'users' có email khớp với email đang đăng nhập
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user['email'])
          .get();

      // Nếu không tìm thấy ai trùng email này
      if (querySnapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Tài khoản không tồn tại trên hệ thống!")));
        return;
      }

      // 2. Lấy ID thực sự của document đó và tiến hành update
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'photoUrl': newUrl,
      });

      if (!mounted) return;

      setState(() {
        _localPhotoUrl = newUrl; // Cập nhật biến cục bộ
        user['photoUrl'] = newUrl; // Cập nhật luôn vào AuthService
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã cập nhật ảnh đại diện thành công! 🥰"), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- HÀM 2: HIỂN THỊ POPUP NHẬP LINK ---
  void _showUrlInputDialog(BuildContext context) {
    _urlController.clear(); // Xóa khung nhập cũ

    showDialog(
      context: context,
      builder: (context) {
        String? previewUrl; // Biến xem trước ảnh trong popup

        return StatefulBuilder(
          builder: (context, setPopupState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              title: Center(child: Text("Set ảnh đại diện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Khung xem trước ảnh
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: (previewUrl != null && previewUrl!.isNotEmpty) ? NetworkImage(previewUrl!) : null,
                      child: (previewUrl == null || previewUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  // Khung nhập link
                  TextField(
                    controller: _urlController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: "Dán link ảnh (URL) vào đây...",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: Icon(Icons.link, color: Colors.green),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                    onChanged: (value) {
                      setPopupState(() { previewUrl = value.trim(); }); // Render lại ảnh xem trước
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (_urlController.text.trim().isNotEmpty) {
                      _updateAvatarOnFirestore(_urlController.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Lưu", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final String role = user?['role'] ?? 'user';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? Colors.black : Colors.grey.shade50,
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
                  colors: isDark 
                      ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                      : [Colors.green.shade600, Colors.green.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // --- VÙNG AVATAR ĐÃ NÂNG CẤP ---
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4), // Viền trắng/đen bọc ngoài
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          // Hiển thị ảnh nếu có link
                          backgroundImage: (_localPhotoUrl != null && _localPhotoUrl!.isNotEmpty)
                              ? NetworkImage(_localPhotoUrl!)
                              : null,
                          // Hiện Icon nếu không có link
                          child: (_localPhotoUrl == null || _localPhotoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 60, color: isDark ? Colors.greenAccent : Colors.green)
                              : null,
                        ),
                      ),

                      // Hiệu ứng loading khi đang lưu
                      if (_isLoading)
                        const Positioned.fill(
                          child: CircleAvatar(
                            radius: 54, // To bằng tổng kích thước viền
                            backgroundColor: Colors.black54,
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),

                      // Badge Quản trị viên (Góc phải)
                      if (role == 'admin')
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: const Icon(Icons.star, color: Colors.white, size: 18),
                          ),
                        ),

                      // Nút Tròn Camera để đổi Avatar (Góc phải dưới)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showUrlInputDialog(context), // Bật popup
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? Colors.black : Colors.white, width: 2), // Viền cho tách biệt
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
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

            // --- MENU LIST: Các tùy chọn (GIỮ NGUYÊN) ---
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
                    if (selectedId != null) widget.onHistoryMealTap(selectedId);
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
              color: isDark ? Colors.white : Colors.grey.shade700, 
            ),
          ),
        );
      }
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              if (!isDark) 
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, color: isDark ? Colors.greenAccent : Colors.green), 
            title: Text(
              title,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
            ), 
            trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white70 : Colors.grey),
            onTap: onTap,
          ),
        );
      }
    );
  }

  void _showLogoutDialog(BuildContext context) {
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