import 'package:doanapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/legal_screens.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  // Hàm mở link (Github, Facebook...)
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Không thể mở liên kết: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          "Về ứng dụng",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PHẦN 1: BRANDING HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "BẾP XANH",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Phiên bản 1.0.5 (Stable)",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PHẦN 2: GIỚI THIỆU ---
                  Text(
                    "GIỚI THIỆU",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ứng dụng được thiết kế nhằm mang lại trải nghiệm nấu ăn thông minh, giúp người dùng tìm kiếm, lưu trữ và chia sẻ công thức nấu ăn một cách dễ dàng nhất trên nền tảng Cloud Firebase.",
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- PHẦN 3: ĐỘI NGŨ PHÁT TRIỂN (KHOA & NHẤT NAM) ---
                  Text(
                    "ĐỘI NGŨ PHÁT TRIỂN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildDevCard(
                    name: "Nguyễn Võ Lê Khoa",
                    role: "Software Engineer & Leader",
                    github: "KhoaSuyThan",
                    isDark: isDark,
                    onTap: () => _launchURL("https://github.com/KhoaSuyThan"),
                  ),

                  _buildDevCard(
                    name: "Nguyễn Thành Nhất Nam",
                    role: "Flutter Developer",
                    github: "nguyennhatnam213654-creator",
                    isDark: isDark,
                    onTap: () => _launchURL(
                      "https://github.com/nguyennhatnam213654-creator",
                    ),
                  ),

                  _buildDevCard(
                    name: "Trần Đức Huy",
                    role: "Flutter Developer",
                    github: "J4H-225",
                    isDark: isDark,
                    onTap: () => _launchURL("https://github.com/J4H-225"),
                  ),

                  const SizedBox(height: 30),

                  // --- PHẦN 4: LIÊN KẾT & PHÁP LÝ ---
                  Text(
                    "LIÊN KẾT KHÁC",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ĐÃ SỬA: Gắn link vào 3 nút này
                  _buildLinkItem(
                    Icons.policy_outlined,
                    "Chính sách quyền riêng tư",
                    isDark,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),

                  _buildLinkItem(
                    Icons.description_outlined,
                    "Điều khoản sử dụng",
                    isDark,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsOfUseScreen(),
                      ),
                    ),
                  ),
                  _buildLinkItem(
                    Icons.star_outline,
                    "Đánh giá ứng dụng",
                    isDark,
                    () => _showRatingDialog(context),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "© 2026 Cooking Team. All Rights Reserved.",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Thẻ Developer
  Widget _buildDevCard({
    required String name,
    required String role,
    required String github,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.code, color: Colors.green),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.link, color: Colors.blue),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  // ĐÃ SỬA: Thêm tham số VoidCallback onTap vào hàm này
  Widget _buildLinkItem(
    IconData icon,
    String title,
    bool isDark,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: isDark ? Colors.white : Colors.black,
      ),
      onTap: onTap, // Gọi hàm khi người dùng nhấn vào
    );
  }

void _showRatingDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Center(
          child: Text(
            "Đánh giá Bếp Xanh",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Bạn thấy ứng dụng nấu ăn này thế nào?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            
            FittedBox(
              fit: BoxFit.scaleDown, // Tự động thu nhỏ nếu màn hình quá chật
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0), // Ép khoảng cách giữa các sao nhỏ lại
                    constraints: const BoxConstraints(), // Bỏ giới hạn kích thước tàng hình mặc định của nút
                    icon: const Icon(Icons.star, color: Colors.amber, size: 36),
                    onPressed: () async {
                      int ratingValue = index + 1; 
                      final user = AuthService.currentUser;
                      Navigator.pop(context); 
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Cảm ơn bạn đã đánh giá $ratingValue sao! 🥰", 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      try {
                        await FirebaseFirestore.instance.collection('app_ratings').add({
                          'userId': user?['uid'] ?? 'guest',
                          'email': user?['email'] ?? 'Khách vãng lai',
                          'username': user?['username'] ?? 'Ẩn danh',
                          'rating': ratingValue,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      } catch (e) {
                        debugPrint("Lỗi khi lưu đánh giá: $e");
                      }
                    },
                  );
                }),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
