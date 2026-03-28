import 'package:flutter/material.dart';
import '../database/firebase_service.dart';
import '../services/auth_service.dart';

class AdminAddRecipeScreen extends StatefulWidget {
  const AdminAddRecipeScreen({super.key});

  @override
  State<AdminAddRecipeScreen> createState() => _AdminAddRecipeScreenState();
}

class _AdminAddRecipeScreenState extends State<AdminAddRecipeScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isUploading = false;

  // Lấy ID Admin an toàn từ hệ thống
  String get currentUserId => AuthService.currentUser?['id']?.toString() ?? '-1';

  void _adminSubmit() async {
    // 1. Kiểm tra đầu vào tối thiểu: Tên và Ảnh
    if (_titleController.text.trim().isEmpty || _imageUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khoa ơi, điền đủ tên món và link ảnh nhé!')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 2. Chuẩn bị dữ liệu để đẩy lên Firebase
      Map<String, dynamic> adminRecipe = {
        'user_id': currentUserId,
        'username': 'Admin', // Định danh người đăng là Admin
        'title': _titleController.text.trim(),
        'ingredients': _ingredientsController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'image_path': _imageUrlController.text.trim(), // Link ảnh trực tiếp
        'status': 'approved', // ĐẶC QUYỀN: Đăng là hiển thị luôn
        'is_notified': 1,     // Đánh dấu đã gửi thông báo
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 3. Gọi Service để lưu vào Firestore
      await FirebaseService.instance.insertRecipe(adminRecipe);

      if (mounted) {
        Navigator.pop(context); // Quay lại màn hình trước
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚀 Tuyệt vời! Món ăn đã lên sóng trang chủ."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi hệ thống: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Nền màu cam rất nhạt
      appBar: AppBar(
        title: const Text("Admin: Thêm món ăn nhanh",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.orange,
        elevation: 2,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("XEM TRƯỚC HÌNH ẢNH",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 10),

                // --- KHU VỰC PREVIEW ẢNH MẠNG ---
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: _buildImagePreview(),
                ),

                const SizedBox(height: 20),

                // Ô nhập Link ảnh
                _buildTextField(_imageUrlController, "Dán link ảnh (https://...)", Icons.link),

                const Divider(height: 40, thickness: 1, color: Colors.orangeAccent),

                const Text("CHI TIẾT MÓN ĂN",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 15),

                _buildTextField(_titleController, "Tên món ăn", Icons.fastfood),
                const SizedBox(height: 15),
                _buildTextField(_ingredientsController, "Nguyên liệu", Icons.format_list_bulleted, maxLines: 3),
                const SizedBox(height: 15),
                _buildTextField(_instructionsController, "Cách chế biến", Icons.menu_book, maxLines: 5),

                const SizedBox(height: 30),

                // --- NÚT ĐĂNG BÀI ---
                _isUploading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : ElevatedButton.icon(
                  onPressed: _adminSubmit,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text("ĐĂNG BÀI NGAY",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Hiệu ứng Loading phủ toàn màn hình
          if (_isUploading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  // Widget hiển thị ảnh Preview từ Link
  Widget _buildImagePreview() {
    String url = _imageUrlController.text.trim();
    if (url.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text("Chưa có link ảnh", style: TextStyle(color: Colors.grey)),
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        // Xử lý khi link ảnh bị lỗi hoặc không tồn tại
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 40, color: Colors.red),
              Text("Link ảnh không hợp lệ!", style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget dùng chung cho các ô nhập liệu
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (val) {
        if (controller == _imageUrlController) setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }
}