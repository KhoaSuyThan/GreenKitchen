import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Dùng để load ảnh từ URL mượt hơn
import '../database/firebase_service.dart'; // Đổi từ DatabaseHelper
import 'recipe_details_screen.dart'; 

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  // 1. Hàm tải danh sách bài đang chờ từ Firebase
  Future<List<Map<String, dynamic>>> _getPending() async {
    return await FirebaseService.instance.getPendingRecipes();
  }

  // 2. Hàm xử lý Duyệt (Dùng String ID)
  void _approve(String id) async {
    await FirebaseService.instance.updateRecipeStatus(id, 'approved');
    setState(() {}); // Load lại giao diện
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔥 Đã duyệt món ăn lên hệ thống!"))
      );
    }
  }

  // 3. Hàm xử lý Từ chối (Dùng String ID)
  void _reject(String id) async {
    // Bạn có thể chọn delete hẳn hoặc đổi status sang 'rejected'
    await FirebaseService.instance.updateRecipeStatus(id, 'rejected'); 
    setState(() {}); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Đã từ chối bài viết này."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duyệt bài (Firebase Admin)", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPending(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Sạch sẽ! Không còn bài nào cần duyệt.", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final recipes = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = recipes[index];
              // Firestore ID là String
              final String docId = item['id']; 

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // ĐỔI: Dùng CachedNetworkImage vì image_path giờ là URL Firebase
                  child: item['image_path'] != null && item['image_path'].toString().startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: item['image_path'],
                        width: 60, height: 60, fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : Container(
                        width: 60, height: 60, color: Colors.grey[300], 
                        child: const Icon(Icons.fastfood, color: Colors.white)
                      ),
                ),
                title: Text(
                  item['title'] ?? "Không tên", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                subtitle: Text("Người đăng: ${item['username'] ?? "User mới"}"),
                
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        mealId: docId, // Đã là String
                      ),
                    ),
                  ).then((_) => setState(() {})); 
                },

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                      onPressed: () => _approve(docId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                      onPressed: () => _reject(docId),
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