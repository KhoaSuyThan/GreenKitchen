import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_congthuc.dart';
import '../services/auth_service.dart';
import '../services/history_service.dart';
import 'package:flutter/services.dart';
// Import DatabaseHelper để lấy món ăn Local
import '../database/database_helper.dart';

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
  bool isLocalMeal = false; // Cờ kiểm tra xem món ăn này có phải từ SQLite không
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
  }

  @override
  void didUpdateWidget(covariant RecipeDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mealId != oldWidget.mealId) {
      setState(() {
        isLoading = true;
        recipeData = null;
        isLocalMeal = false;
      });
      _fetchRecipeDetail();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  Future<void> _fetchRecipeDetail() async {
    try {
      // 1. KIỂM TRA SQLITE TRƯỚC (MÓN CỘNG ĐỒNG)
      int? localId = int.tryParse(widget.mealId); // Nếu parse được sang số (ID nhỏ)
      if (localId != null) {
        final localData = await DatabaseHelper.instance.getRecipeById(localId);
        
        if (localData != null) {
          if (mounted) {
            setState(() {
              // Chuyển đổi dữ liệu SQLite sang cấu trúc giống API để UI không bị lỗi
              recipeData = {
                'idMeal': localData['id'].toString(),
                'nameVi': localData['title'],
                'thumbnail': localData['image_path'],
                // Món local nguyên liệu thường là 1 string dài, ta bọc nó vào List giống API
                'ingredientsList': [
                  {"original": localData['ingredients'], "translated": localData['ingredients']}
                ],
                'instructionsVi': localData['instructions'],
              };
              isLocalMeal = true;
              isLoading = false;
            });
            _saveHistory(recipeData!); // Lưu lịch sử
          }
          return; // Dừng hàm lại, không gọi API nữa
        }
      }

      // 2. NẾU KHÔNG CÓ TRONG SQLITE, GỌI API (MÓN QUỐC TẾ)
      final data = await RecipeDetailService.getRecipeById(widget.mealId);
      if (mounted) {
        setState(() {
          recipeData = data;
          isLocalMeal = false;
          isLoading = false;
        });

        if (data != null) {
          _saveHistory(data); // Lưu lịch sử
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Không thể tải dữ liệu. Vui lòng thử lại.";
        });
      }
    }
  }

  // Hàm phụ trợ lưu lịch sử tách riêng cho gọn
  Future<void> _saveHistory(Map<String, dynamic> data) async {
    final user = AuthService.currentUser;
    if (user != null) {
      await HistoryService.addHistory(user['id'], {
        'idMeal': widget.mealId,
        'strMeal': data['nameVi'] ?? data['nameEn'] ?? "Món ăn",
        'strMealThumb': data['thumbnail'] ?? "",
      });
      print("✅ Đã lưu lịch sử: ${data['nameVi']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage.isNotEmpty || recipeData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thông báo")),
        body: Center(child: Text(errorMessage)),
      );
    }

    final ingredients = recipeData!["ingredientsList"] as List;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header với ảnh món ăn và nút Back
          SliverAppBar(
            expandedHeight: 300.0,
            toolbarHeight: 60,
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            pinned: true,
            backgroundColor: Colors.orange,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!(); // Quay lại Tab Danh mục
                    } else {
                      Navigator.pop(context); // Quay
                    }
                  },
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipeData!["nameVi"] ?? "Chi tiết",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              background: isLocalMeal
                  // Phân biệt cách hiển thị ảnh: Local dùng Image.file, API dùng Image.network
                  ? Image.file(
                      File(recipeData!["thumbnail"]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                    )
                  : Image.network(
                      recipeData!["thumbnail"],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                    ),
            ),
          ),

          // Nội dung chi tiết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nguyên liệu",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
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
                            // Căn chỉnh lên trên để nếu nguyên liệu dài rớt dòng, icon vẫn ở trên cùng
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2), // Cân bằng vị trí icon với chữ
                                child: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ing["translated"] != null &&
                                          ing["translated"].isNotEmpty
                                      ? ing["translated"]
                                      : ing["original"],
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
                  const Text(
                    "Hướng dẫn cách làm",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipeData!["instructionsVi"] ??
                        "Chưa có hướng dẫn tiếng Việt.",
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