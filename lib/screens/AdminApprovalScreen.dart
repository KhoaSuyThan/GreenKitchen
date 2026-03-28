import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database/firebase_service.dart';
import 'recipe_details_screen.dart';
import 'AdminAddRecipeScreen.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  Future<List<Map<String, dynamic>>> _getPending() async {
    return await FirebaseService.instance.getPendingRecipes();
  }

  void _approve(String id) async {
    await FirebaseService.instance.updateRecipeStatus(id, 'approved');
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔥 Đã duyệt món ăn lên hệ thống!"))
      );
    }
  }

  void _reject(String id) async {
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
        title: const Text("Quản lý bài viết", // Đổi tên cho bao quát hơn
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Nút refresh để Admin kiểm tra bài mới nhanh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),

      // 👉 MỚI: Thêm nút nổi để Admin up thẳng công thức
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Khi bấm vào sẽ mở màn hình thêm bài (Mình đã độ lại status: approved)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminAddRecipeScreen()),
          ).then((_) => setState(() {})); // Load lại nếu cần
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Đăng bài mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  Icon(Icons.done_all, size: 80, color: Colors.green),
                  SizedBox(height: 10),
                  Text("Tuyệt vời! Không còn bài nào chờ duyệt.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 20),
                  Text("Admin có thể bấm nút dưới để đăng bài mới!",
                      style: TextStyle(color: Colors.orange, fontSize: 14)),
                ],
              ),
            );
          }

          final recipes = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.only(top: 10, bottom: 80), // Cách đáy để không bị đè nút FAB
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = recipes[index];
              final String docId = item['id'];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['image_path'] != null && item['image_path'].toString().startsWith('http')
                      ? CachedNetworkImage(
                    imageUrl: item['image_path'],
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                      : Container(width: 60, height: 60, color: Colors.grey[300], child: const Icon(Icons.fastfood)),
                ),
                title: Text(item['title'] ?? "Không tên", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Người đăng: ${item['username'] ?? "User"}"),
                onTap: () {
                  final String docId = recipes[index]['id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecipeDetailScreen(key: UniqueKey(), mealId: docId)),
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