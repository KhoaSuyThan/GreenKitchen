import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' as path_lib; 

import '../database/database_helper.dart'; 
import '../services/auth_service.dart'; 

class AddRecipeFormScreen extends StatefulWidget {
  const AddRecipeFormScreen({super.key});

  @override
  State<AddRecipeFormScreen> createState() => _AddRecipeFormScreenState();
}

class _AddRecipeFormScreenState extends State<AddRecipeFormScreen> {
  // 1. Tạo Controller để lấy dữ liệu text
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  // 2. Biến lưu file ảnh đã chọn
  File? _selectedImage; 
  final ImagePicker _picker = ImagePicker();

  // 3. Hàm xử lý chọn ảnh (từ thư viện)
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // Cập nhật UI
      });
    }
  }

  // 4. Hàm xử lý submit form
  void _submitForm() async {
    // Kiểm tra dữ liệu
    if (_titleController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên món và chọn ảnh!')));
      return;
    }

    try {
      // KIỂM TRA ĐĂNG NHẬP VÀ LẤY ID USER
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Bạn chưa đăng nhập!')));
        return;
      }
      
      final int loggedInUserId = currentUser['id']; // Lấy ID thật của User

      // 5. Lưu ảnh vào thư mục bộ nhớ của App
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path_lib.basename(_selectedImage!.path);
      final savedImagePath = '${appDir.path}/$fileName';
      
      // Copy file ảnh sang thư mục mới
      final savedImage = await _selectedImage!.copy(savedImagePath);

      // 6. Tạo Map dữ liệu để lưu vào SQLite
      Map<String, dynamic> newRecipe = {
        'user_id': loggedInUserId, // ĐÃ SỬA: Dùng ID thật thay vì số 1
        'title': _titleController.text,
        'ingredients': _ingredientsController.text,
        'instructions': _instructionsController.text,
        'image_path': savedImage.path, 
        'status': 'pending', 
      };

      // 7. Lưu vào SQLite
      await DatabaseHelper.instance.insertRecipe(newRecipe);

      // 8. Thông báo và đóng màn hình (Có kiểm tra mounted để không bị lỗi xanh)
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi món ăn! Đang chờ Admin duyệt.')));
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra: $e')));
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng controller khi hủy màn hình
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gửi công thức mới"), backgroundColor: Colors.green),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 9. KHU VỰC CHỌN VÀ HIỂN THỊ ẢNH
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover)) 
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey),
                          Text('Nhấn để chọn ảnh', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 15),
            
            // 10. Gán Controller vào TextField
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Tên món ăn", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _ingredientsController, decoration: const InputDecoration(labelText: "Nguyên liệu", border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 10),
            TextField(controller: _instructionsController, decoration: const InputDecoration(labelText: "Cách làm", border: OutlineInputBorder()), maxLines: 5),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _submitForm, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Gửi bài", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}