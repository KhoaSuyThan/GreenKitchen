import 'package:flutter/material.dart';

import '../database/firebase_service.dart';
import '../services/auth_service.dart';

class AddRecipeFormScreen extends StatefulWidget {
  const AddRecipeFormScreen({super.key});

  @override
  State<AddRecipeFormScreen> createState() => _AddRecipeFormScreenState();
}

class _AddRecipeFormScreenState extends State<AddRecipeFormScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _imageUrlController = TextEditingController(); //  THÊM

  bool _isUploading = false;

  void _submitForm() async {
    //  CHECK
    if (_titleController.text.isEmpty ||
        _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tên món và link ảnh!')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn chưa đăng nhập!')),
        );
        return;
      }

      final String userId = currentUser['id'].toString();

      String imageUrl = _imageUrlController.text.trim();

      Map<String, dynamic> newRecipe = {
        'user_id': userId,
        'title': _titleController.text,
        'ingredients': _ingredientsController.text,
        'instructions': _instructionsController.text,
        'image_path': imageUrl, //  LINK ẢNH
        'status': 'pending',
        'is_notified': 0,
      };

      await FirebaseService.instance.insertRecipe(newRecipe);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi món ăn!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
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
    _imageUrlController.dispose(); //  THÊM
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gửi công thức (Link ảnh)"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ///  NHẬP LINK ẢNH
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: "Link ảnh (https://...)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                /// 👉 PREVIEW ẢNH
                if (_imageUrlController.text.isNotEmpty)
                  Image.network(
                    _imageUrlController.text,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
                  ),

                const SizedBox(height: 15),

                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Tên món ăn",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                    labelText: "Nguyên liệu",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: "Cách làm",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),

                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize:
                              const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Gửi bài",
                          style: TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
              ],
            ),
          ),

          if (_isUploading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}