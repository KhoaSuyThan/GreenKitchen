import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

import 'recipe_details_screen.dart'; 

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  // Hàm tải danh sách bài đang chờ
  Future<List<Map<String, dynamic>>> _getPending() async {
    return await DatabaseHelper.instance.getPendingRecipes();
  }

  // Hàm xử lý khi Admin bấm Duyệt
  void _approve(int id) async {
    await DatabaseHelper.instance.updateRecipeStatus(id, 'approved');
    setState(() {}); // Load lại giao diện
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã duyệt món ăn!"))
      );
    }
  }

  // Hàm xử lý khi Admin bấm Xóa/Từ chối
  void _reject(int id) async {
    await DatabaseHelper.instance.updateRecipeStatus(id, 'rejected'); 
    setState(() {}); // Load lại giao diện
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã từ chối và xóa bài."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duyệt bài (Admin)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPending(),
        builder: (context, snapshot) {
          // 1. Đang tải dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          // 2. Nếu không có dữ liệu hoặc danh sách rỗng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Hiện không có món ăn nào cần duyệt.", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // 3. Có dữ liệu -> Hiển thị danh sách thật
          final recipes = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = recipes[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['image_path'] != null 
                    ? Image.file(File(item['image_path']), width: 60, height: 60, fit: BoxFit.cover)
                    : Container(
                        width: 60, height: 60, color: Colors.grey, 
                        child: Icon(Icons.fastfood, color: Colors.white)
                      ),
                ),
                title: Text(
                  item['title'] ?? "Không tên", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                subtitle: Text("Người đăng: ${item['username'] ?? "Ẩn danh"}"),
                
                // --- ĐOẠN QUAN TRỌNG: MỞ XEM CHI TIẾT CÔNG THỨC ---
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        // Truyền ID món ăn sang (phải là String)
                        mealId: item['id'].toString(), 
                      ),
                    ),
                  ).then((_) => setState(() {})); // Reload lại danh sách sau khi quay về (nếu cần)
                },
                // --------------------------------------------------

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                      onPressed: () => _approve(item['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                      onPressed: () => _reject(item['id']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}