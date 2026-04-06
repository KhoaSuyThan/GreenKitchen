import 'package:flutter/material.dart';

// ==========================================
// MÀN HÌNH CHÍNH SÁCH QUYỀN RIÊNG TƯ
// ==========================================
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLegalLayout(
      context: context,
      title: "Chính sách quyền riêng tư",
      content: """
Cập nhật lần cuối: Tháng 4, 2026

Chào mừng bạn đến với Bếp Xanh. Việc bảo vệ thông tin cá nhân của bạn là ưu tiên hàng đầu của chúng tôi. Chính sách này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ dữ liệu của bạn.

1. Thông tin chúng tôi thu thập
Khi bạn tạo tài khoản, chúng tôi thu thập các thông tin cơ bản bao gồm: Địa chỉ Email, Tên hiển thị và UID (được quản lý an toàn bởi Firebase Authentication). Chúng tôi cũng lưu trữ dữ liệu tương tác của bạn như: Lịch sử xem món, Danh sách yêu thích và Công thức do bạn đóng góp.

2. Cách chúng tôi sử dụng thông tin
Dữ liệu của bạn được sử dụng riêng cho các mục đích:
• Đồng bộ hóa trải nghiệm cá nhân của bạn trên nhiều thiết bị.
• Gợi ý các công thức nấu ăn phù hợp với sở thích.
• Quản trị viên (Admin) sử dụng dữ liệu để kiểm duyệt nội dung đóng góp nhằm xây dựng cộng đồng an toàn.

3. Bảo mật dữ liệu
Toàn bộ dữ liệu của bạn được lưu trữ trên hạ tầng điện toán đám mây của Google (Firebase Cloud Firestore). Chúng tôi cam kết KHÔNG bán, trao đổi hoặc chia sẻ thông tin cá nhân của bạn cho bất kỳ bên thứ ba nào vì mục đích thương mại.

4. Quyền của người dùng
Bạn có quyền yêu cầu trích xuất hoặc xóa toàn bộ dữ liệu cá nhân (bao gồm tài khoản và các công thức đã đăng) bất kỳ lúc nào bằng cách liên hệ với bộ phận hỗ trợ.
      """,
    );
  }
}

// ==========================================
// MÀN HÌNH ĐIỀU KHOẢN SỬ DỤNG
// ==========================================
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLegalLayout(
      context: context,
      title: "Điều khoản sử dụng",
      content: """
Cập nhật lần cuối: Tháng 4, 2026

Bằng việc tải xuống, cài đặt và sử dụng ứng dụng Bếp Xanh, bạn đồng ý bị ràng buộc bởi các Điều khoản sử dụng dưới đây:

1. Trách nhiệm cộng đồng
• Bạn chịu trách nhiệm hoàn toàn về các công thức nấu ăn, hình ảnh và bình luận mà bạn đăng tải.
• Nghiêm cấm chia sẻ nội dung phản cảm, sai lệch, hoặc vi phạm bản quyền trí tuệ của người khác. 
• Quản trị viên (Admin) có quyền gỡ bỏ nội dung hoặc khóa vĩnh viễn các tài khoản vi phạm mà không cần báo trước.

2. Quyền sở hữu trí tuệ
Các công thức do hệ thống cung cấp thuộc bản quyền của Bếp Xanh. Đối với công thức do người dùng đóng góp, bạn giữ quyền sở hữu nhưng cấp cho Bếp Xanh quyền hiển thị và phân phối miễn phí trong phạm vi ứng dụng.

3. Khước từ trách nhiệm y tế & an toàn
Các công thức nấu ăn trên ứng dụng chỉ mang tính chất tham khảo. Chúng tôi không chịu trách nhiệm về các vấn đề liên quan đến dị ứng thực phẩm, ngộ độc, hay các sự cố an toàn nhà bếp phát sinh trong quá trình bạn thực hành theo công thức. Hãy luôn kiểm tra kỹ nguyên liệu nếu bạn có tiền sử dị ứng.

4. Cập nhật điều khoản
Chúng tôi có quyền thay đổi các điều khoản này bất kỳ lúc nào. Những thay đổi quan trọng sẽ được thông báo qua ứng dụng.
      """,
    );
  }
}

// ==========================================
// WIDGET KHUNG DÙNG CHUNG ĐỂ TRÁNH LẶP CODE
// ==========================================
Widget _buildLegalLayout({required BuildContext context, required String title, required String content}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Scaffold(
    backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
    appBar: AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      backgroundColor: Colors.green,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Text(
        content.trim(),
        style: TextStyle(
          fontSize: 15,
          height: 1.8, // Dãn dòng rộng ra cho giống văn bản luật
          color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}