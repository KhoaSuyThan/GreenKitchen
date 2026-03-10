import 'package:flutter/material.dart';
import '../services/api_congthuc.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;

  const RecipeDetailScreen({super.key, required this.mealId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipeData;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
  }

  // Hàm gọi API
  Future<void> _fetchRecipeDetail() async {
    try {
      final data = await RecipeDetailService.getRecipeById(widget.mealId);
      if (mounted) {
        setState(() {
          recipeData = data;
          isLoading = false;
          if (data == null) {
            errorMessage = "Không tìm thấy công thức món ăn này.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Đã xảy ra lỗi khi tải dữ liệu.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Trạng thái đang tải
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Đang tải và dịch công thức..."),
            ],
          ),
        ),
      );
    }

    // 2. Trạng thái lỗi hoặc không có dữ liệu
    if (errorMessage.isNotEmpty || recipeData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lỗi")),
        body: Center(child: Text(errorMessage)),
      );
    }

    // 3. Trạng thái hiển thị dữ liệu thành công
    final ingredients = recipeData!["ingredientsList"] as List;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Phần Header có ảnh món ăn kéo dãn được
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipeData!["nameVi"] ?? "Chi tiết món ăn",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                ),
              ),
              background: Image.network(
                recipeData!["thumbnail"],
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Phần nội dung cuộn bên dưới
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- NGUYÊN LIỆU ---
                  const Text(
                    "Nguyên liệu",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: ingredients.map((ing) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ing["original"],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- HƯỚNG DẪN NẤU ---
                  const Text(
                    "Hướng dẫn cách làm",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipeData!["instructionsVi"] ?? "Không có dữ liệu hướng dẫn.",
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 40), // Khoảng trống ở cuối trang
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}