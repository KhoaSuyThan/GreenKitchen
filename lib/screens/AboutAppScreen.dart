import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Về ứng dụng", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.restaurant_menu_rounded, size: 60, color: Colors.green),
                  ),
                  const SizedBox(height: 15),
                  const Text("BẾP XANH",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                  const Text("Phiên bản 1.0.5 (Stable)",
                      style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PHẦN 2: GIỚI THIỆU ---
                  const Text("GIỚI THIỆU",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.1)),
                  const SizedBox(height: 10),
                  const Text(
                    "Ứng dụng được thiết kế nhằm mang lại trải nghiệm nấu ăn thông minh, giúp người dùng tìm kiếm, lưu trữ và chia sẻ công thức nấu ăn một cách dễ dàng nhất trên nền tảng Cloud Firebase.",
                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.6, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 30),

                  // --- PHẦN 3: ĐỘI NGŨ PHÁT TRIỂN (KHOA & NHẤT NAM) ---
                  const Text("ĐỘI NGŨ PHÁT TRIỂN",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(height: 15),

                  _buildDevCard(
                    name: "Nguyễn Võ Lê Khoa",
                    role: "Software Engineer & Leader",
                    github: "KhoaSuyThan",
                    onTap: () => _launchURL("https://github.com/KhoaSuyThan"),
                  ),

                  _buildDevCard(
                    name: "Nguyễn Thành Nhất Nam",
                    role: "Flutter Developer",
                    github: "nguyennhatnam213654-creator",
                    onTap: () => _launchURL("https://github.com/nguyennhatnam213654-creator"),
                  ),

                  _buildDevCard(
                    name: "Trần Đức Huy",
                    role: "Flutter Developer",
                    github: "J4H-225",
                    onTap: () => _launchURL("https://github.com/J4H-225"),
                  ),

                  const SizedBox(height: 30),

                  // --- PHẦN 4: LIÊN KẾT & PHÁP LÝ ---
                  const Text("LIÊN KẾT KHÁC",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(height: 10),
                  _buildLinkItem(Icons.policy_outlined, "Chính sách quyền riêng tư"),
                  _buildLinkItem(Icons.description_outlined, "Điều khoản sử dụng"),
                  _buildLinkItem(Icons.star_outline, "Đánh giá ứng dụng"),

                  const SizedBox(height: 40),
                  const Center(
                    child: Text("© 2026 Cooking Team. All Rights Reserved.",
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
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
  Widget _buildDevCard({required String name, required String role, required String github, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.green.shade100, child: const Icon(Icons.code, color: Colors.green)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(role, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.link, color: Colors.blue),
            onPressed: onTap,
          )
        ],
      ),
    );
  }

  // Widget Dòng link
  Widget _buildLinkItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }
}