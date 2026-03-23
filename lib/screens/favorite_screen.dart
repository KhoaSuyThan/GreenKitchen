import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart'; 

class FavoriteScreen extends StatefulWidget {
  final Function(String)? onMealTap;
  final VoidCallback? onFavoritesChanged; 

  const FavoriteScreen({super.key, this.onMealTap, this.onFavoritesChanged});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  List favorites = [];

  // SỬA: Lấy ID dạng String từ AuthService
  String? get currentUserId => AuthService.currentUser?['id']?.toString();

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void refreshFavorites() {
    loadFavorites();
  }

  void loadFavorites() async {
    // SỬA: Kiểm tra null thay vì so sánh với 0
    if (currentUserId == null) return; 

    final data = await FavoriteService.getFavorites(currentUserId!);
    
    if (!mounted) return;
    setState(() {
      favorites = data;
    });
  }

  // SỬA: Firebase cần cả UserId và MealId để xóa đúng bản ghi
  void _removeFavorite(String mealId) async {
    if (currentUserId == null) return;

    await FavoriteService.removeFavorite(currentUserId!, mealId);
    loadFavorites(); 

    if (widget.onFavoritesChanged != null) {
      widget.onFavoritesChanged!(); 
    }
  }

  void _removeAllFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa tất cả"),
        content: const Text("Bạn có chắc chắn muốn bỏ yêu thích tất cả món ăn không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (currentUserId != null) {
                await FavoriteService.removeAllFavorites(currentUserId!);
                loadFavorites(); 

                if (widget.onFavoritesChanged != null) {
                  widget.onFavoritesChanged!(); 
                }
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Món yêu thích"),
        backgroundColor: Colors.green,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              tooltip: "Xóa tất cả",
              onPressed: _removeAllFavorites,
            )
        ],
      ),
      body: currentUserId == null 
          ? const Center(
              child: Text("Vui lòng đăng nhập để xem món yêu thích"),
            )
          : favorites.isEmpty
          ? const Center(
              child: Text(
                "Chưa có món yêu thích ❤️",
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final meal = favorites[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(20), 
                  onTap: () {
                    if (widget.onMealTap != null) {
                      widget.onMealTap!(meal["meal_id"]);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Image.network(
                                meal["meal_thumb"] ?? "",
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeFavorite(meal["meal_id"]),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            meal["meal_name"] ?? "Món ăn",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}