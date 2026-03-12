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

  @override
  void didUpdateWidget(covariant RecipeDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mealId != widget.mealId) {
      setState(() {
        isLoading = true;
        recipeData = null;
      });

      _fetchRecipeDetail();
    }
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
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Đang tải và dịch công thức..."),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty || recipeData == null) {
      return Center(child: Text(errorMessage));
    }

    final ingredients = recipeData!["ingredientsList"] as List;

    return CustomScrollView(
      slivers: [
        SliverAppBar( 
          // Hiển thị ảnh nền và tên món ăn
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(recipeData!["thumbnail"], fit: BoxFit.cover),

                // nền mờ cho chữ
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                ),

                Positioned(
                  //hiển thị tên món ăn ở dưới cùng
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Text(
                    recipeData!["nameVi"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nguyên liệu",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          ing["translated"].isNotEmpty
                              ? ing["translated"]
                              : ing["original"],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Hướng dẫn cách làm",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Text(
                  recipeData!["instructionsVi"] ?? "",
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
