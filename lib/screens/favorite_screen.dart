import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart'; 

class FavoriteScreen extends StatefulWidget {
  final Function(String)? onMealTap;
  // khi thay đổi yêu thích, sẽ gọi callback này để thông báo ra ngoài 
  final VoidCallback? onFavoritesChanged; 

  const FavoriteScreen({super.key, this.onMealTap, this.onFavoritesChanged});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  List favorites = [];
  int get currentUserId => AuthService.currentUser?['id'] ?? 0;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void refreshFavorites() {
    loadFavorites();
  }

  void loadFavorites() async {
    if (currentUserId == 0) return; 

    final data = await FavoriteService.getFavorites(currentUserId);
    
    if (!mounted) return;
    setState(() {
      favorites = data;
    });
  }

  // Hàm xử lý xóa 1 món
  void _removeFavorite(String mealId) async {
    await FavoriteService.removeFavorite(mealId);
    loadFavorites(); // Cập nhật lại list ở màn hình này

   
    if (widget.onFavoritesChanged != null) {
      widget.onFavoritesChanged!(); 
    }
  }

  // Hàm xử lý xóa tất cả có cảnh báo
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
              await FavoriteService.removeAllFavorites(currentUserId);
              loadFavorites(); // Cập nhật lại list ở màn hình này 


              if (widget.onFavoritesChanged != null) {
                widget.onFavoritesChanged!(); 
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
      body: currentUserId == 0 
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
                                meal["meal_thumb"],
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
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
                            meal["meal_name"],
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