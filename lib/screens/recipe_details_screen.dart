import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Dùng load ảnh URL
import '../services/api_congthuc.dart';
import '../services/auth_service.dart';
import '../services/history_service.dart';
import 'package:flutter/services.dart';
// ĐỔI: Dùng FirebaseService thay vì DatabaseHelper
import '../database/firebase_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;
  final VoidCallback? onBack;

  const RecipeDetailScreen({super.key, required this.mealId, this.onBack});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipeData;
  bool isLoading = true;
  String errorMessage = "";
  bool isFirebaseMeal = false; // Cờ kiểm tra món ăn từ Cloud
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
  }

  // Hàm lấy chi tiết công thức
  Future<void> _fetchRecipeDetail() async {
    // ✅ BƯỚC QUAN TRỌNG NHẤT: Reset lại mọi thứ để không bị "dính" món cũ
    if (mounted) {
      setState(() {
        isLoading = true;     // Bật vòng xoay loading lên
        recipeData = null;    // Xóa sạch dữ liệu món cũ
        errorMessage = "";    // Xóa thông báo lỗi cũ
      });
    }

    try {
      print("🔍 Đang tìm món ăn với ID: ${widget.mealId}");

      // 1. KIỂM TRA FIREBASE TRƯỚC
      final fbData = await FirebaseService.instance.getRecipeById(widget.mealId);

      if (fbData != null) {
        if (mounted) {
          setState(() {
            recipeData = {
              'idMeal': fbData['id'],
              'nameVi': fbData['title'],
              'thumbnail': fbData['image_path'],
              'ingredientsList': [
                {"original": fbData['ingredients'], "translated": fbData['ingredients']}
              ],
              'instructionsVi': fbData['instructions'],
            };
            isFirebaseMeal = true;
            isLoading = false; // Tắt loading sau khi đã có dữ liệu
          });
          _saveHistory(recipeData!);
        }
        return;
      }

      // 2. NẾU KHÔNG CÓ TRÊN FIREBASE, GỌI API
      final apiData = await RecipeDetailService.getRecipeById(widget.mealId);
      if (mounted) {
        setState(() {
          recipeData = apiData;
          isFirebaseMeal = false;
          isLoading = false; // Tắt loading
        });

        if (apiData != null) {
          _saveHistory(apiData);
        }
      }
    } catch (e) {
      print("❌ Lỗi Fetch: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Lỗi kết nối server. Vui lòng thử lại.";
        });
      }
    }
  }

  Future<void> _saveHistory(Map<String, dynamic> data) async {
    final user = AuthService.currentUser;
    if (user != null) {
      // Đảm bảo user['id'] là String để khớp với Firebase
      await HistoryService.addHistory(user['id'].toString(), {
        'idMeal': widget.mealId,
        'strMeal': data['nameVi'] ?? data['nameEn'] ?? "Món ăn",
        'strMealThumb': data['thumbnail'] ?? "",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
    }

    if (errorMessage.isNotEmpty || recipeData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lỗi")),
        body: Center(child: Text(errorMessage)),
      );
    }

    final ingredients = recipeData!["ingredientsList"] as List;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: Colors.orange,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3), // Nền đen mờ để nút back luôn nổi bật
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!(); // Gọi callback nếu có
                    } else {
                      Navigator.pop(context); // Mặc định quay về trang trước
                    }
                  },
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipeData!["nameVi"] ?? "Chi tiết",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: CachedNetworkImage(
                imageUrl: recipeData!["thumbnail"] ?? "",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nguyên liệu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: ingredients.map((ing) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, size: 18, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ing["translated"] ?? ing["original"] ?? "",
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Hướng dẫn cách làm", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    recipeData!["instructionsVi"] ?? "Chưa có hướng dẫn cụ thể.",
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}