import 'dart:io';
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart';

class MealCard extends StatefulWidget {
  final dynamic meal;
  final VoidCallback onTap;
  final bool isHome;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.isHome = false,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final user = AuthService.currentUser;
    if (user != null) {
      // Lấy ID linh hoạt (id từ Firestore hoặc idMeal từ API)
      final String mealId = (widget.meal["id"] ?? widget.meal["idMeal"] ?? "").toString();
      
      if (mealId.isNotEmpty) {
        bool favorited = await FavoriteService.isFavorite(
          user['id'].toString(), 
          mealId
        );
        if (mounted) setState(() => isFavorite = favorited);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    // --- LOGIC MAP DỮ LIỆU TỪ 2 NGUỒN ---
    final bool isFromFirestore = meal['image_path'] != null; 
    final String title = (isFromFirestore ? meal['title'] : meal['strMeal']) ?? "Không có tên";
    final String imageUrl = (isFromFirestore ? meal['image_path'] : meal['strMealThumb']) ?? "";
    final String mealId = (meal["id"] ?? meal["idMeal"] ?? "").toString();
    final String area = isFromFirestore ? "Cộng đồng" : (meal["strArea"] ?? "Quốc tế");

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. PHẦN HÌNH ẢNH (Xử lý link ngoài)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImageWidget(imageUrl),
                ),

                /// NÚT YÊU THÍCH
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      final user = AuthService.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng đăng nhập!")),
                        );
                        return;
                      }

                      setState(() => isFavorite = !isFavorite);

                      if (isFavorite) {
                        await FavoriteService.addFavorite(
                          user['id'].toString(),
                          mealId,
                          title,
                          imageUrl,
                        );
                      } else {
                        await FavoriteService.removeFavorite(
                          user['id'].toString(), 
                          mealId
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// 2. PHẦN THÔNG TIN
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.public, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        area,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// HÀM HIỂN THỊ ẢNH THÔNG MINH (Link ngoài & Local)
  Widget _buildImageWidget(String path) {
    if (path.isEmpty) return _buildErrorPlaceholder();

    // Nếu là Link URL ngoài (Bắt đầu bằng http)
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey[100],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } 
    
    // Nếu là đường dẫn File trong máy (Dành cho ảnh vừa chụp)
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }

    return _buildErrorPlaceholder();
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
    );
  }
}