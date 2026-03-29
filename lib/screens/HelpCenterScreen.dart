import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // 1. Dữ liệu câu hỏi gốc
  final List<Map<String, String>> _allFaqs = [
    {
      "q": "Làm sao để đăng công thức nấu ăn?",
      "a": "Bạn vào tab Cá nhân, chọn mục 'Đăng bài mới' (nếu là Quản trị viên). Dữ liệu sẽ được lưu trực tiếp lên hệ thống Cloud Firebase."
    },
    {
      "q": "Tôi quên mật khẩu thì phải làm sao?",
      "a": "Tại màn hình đăng nhập, hãy chọn 'Quên mật khẩu' hoặc liên hệ trực tiếp với Khoa qua Hotline để được reset thủ công."
    },
    {
      "q": "App có sử dụng được khi không có mạng không?",
      "a": "Hiện tại App cần kết nối Internet để tải dữ liệu. Tuy nhiên, các món đã xem sẽ được lưu tạm (cache) để xem lại nhanh hơn."
    },
    {
      "q": "Làm thế nào để lưu món ăn yêu thích?",
      "a": "Tại mỗi món ăn, bạn nhấn vào biểu tượng Trái tim. Danh sách này sẽ xuất hiện ở tab 'Yêu thích' ở thanh menu dưới."
    },
    {
      "q": "Tôi muốn góp ý cải thiện ứng dụng?",
      "a": "Chúng tôi luôn lắng nghe! Bạn hãy gửi email về khoanv249@gmail.com. Mọi đóng góp của bạn là động lực để app hoàn thiện hơn."
    },
    {
      "q": "Làm sao để xóa lịch sử xem món?",
      "a": "Bạn vào mục 'Cá nhân' -> 'Lịch sử xem món'. Tại đó bạn có thể xem lại hoặc nhấn giữ để xóa các món đã xem."
    },
  ];

  // 2. Danh sách hiển thị sau khi lọc tìm kiếm
  List<Map<String, String>> _foundFaqs = [];

  @override
  void initState() {
    _foundFaqs = _allFaqs; // Mới vào thì hiện tất cả
    super.initState();
  }

  // 3. LOGIC TÌM KIẾM
  void _runFilter(String enteredKeyword) {
    List<Map<String, String>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFaqs;
    } else {
      results = _allFaqs
          .where((faq) =>
          faq["q"]!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundFaqs = results;
    });
  }

  // --- LOGIC GỌI ĐIỆN ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Lỗi gọi điện: $e');
    }
  }

  // --- LOGIC GỬI EMAIL ---
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Hỗ trợ App Công Thức&body=Chào Khoa, mình cần hỗ trợ về...',
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Lỗi gửi email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Trung tâm trợ giúp",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- HEADER SEARCH ---
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chúng tôi có thể giúp gì cho bạn?",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                TextField(
                  onChanged: (value) => _runFilter(value), // 👈 Kích hoạt tìm kiếm thật
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm vấn đề của bạn...",
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TIÊU ĐỀ: LIÊN HỆ (Đã sửa FontWeight.w900 cho cực đậm)
                  const Text("LIÊN HỆ TRỰC TIẾP",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(height: 15),

                  _buildContactCard(
                    icon: Icons.email_rounded,
                    title: "Gửi Email cho Khoa",
                    subtitle: "khoanv249@gmail.com",
                    color: Colors.blue.shade700,
                    onTap: () => _sendEmail("khoanv249@gmail.com"),
                  ),

                  _buildContactCard(
                    icon: Icons.phone_android_rounded,
                    title: "Hotline hỗ trợ (Zalo)",
                    subtitle: "0374 139 213",
                    color: Colors.orange.shade800,
                    onTap: () => _makePhoneCall("0374139213"),
                  ),

                  const SizedBox(height: 30),

                  // TIÊU ĐỀ: FAQ (Đã sửa FontWeight.w900)
                  const Text("CÂU HỎI THƯỜNG GẶP",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(height: 10),

                  // --- HIỂN THỊ DANH SÁCH FAQ SAU KHI LỌC ---
                  _foundFaqs.isNotEmpty
                      ? Column(
                    children: _foundFaqs
                        .map((faq) => _buildFAQItem(faq["q"]!, faq["a"]!))
                        .toList(),
                  )
                      : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Không tìm thấy kết quả nào!",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Card Liên hệ ---
  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // CHỮ ĐẬM HƠN
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
      ),
    );
  }

  // --- Widget FAQ ---
  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        iconColor: Colors.green,
        collapsedIconColor: Colors.black,
        title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 5),
            child: Text(
              answer,
              style: const TextStyle(
                  color: Colors.black87, // Đen đậm dễ nhìn
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600 // Tăng độ đậm nội dung
              ),
            ),
          ),
        ],
      ),
    );
  }
}