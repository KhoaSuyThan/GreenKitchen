import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/auth_service.dart'; 
import 'package:translator/translator.dart';

class FavoriteScreen extends StatefulWidget {
  final Function(String)? onMealTap;
  final VoidCallback? onFavoritesChanged; 

  const FavoriteScreen({super.key, this.onMealTap, this.onFavoritesChanged});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  List favorites = [];
  final translator = GoogleTranslator(); // KHỞI TẠO BỘ DỊCH

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
    if (currentUserId == null) return; 

    final data = await FavoriteService.getFavorites(currentUserId!);
    
    if (!mounted) return;
    setState(() {
      favorites = data;
    });
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF2E7D32) : Colors.green;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50, // Nền đồng bộ
      appBar: AppBar(
        title: const Text("Món yêu thích", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
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
          ? Center(child: Text("Vui lòng đăng nhập để xem món yêu thích", style: TextStyle(color: isDark ? Colors.white : Colors.black)))
          : favorites.isEmpty
          ? Center(
              child: Text(
                "Chưa có món yêu thích ❤️",
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
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
                final String mealName = meal["meal_name"] ?? "Món ăn";

                return InkWell(
                  borderRadius: BorderRadius.circular(20), 
                  onTap: () {
                    if (widget.onMealTap != null) {
                      widget.onMealTap!(meal["meal_id"]);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: FutureBuilder(
                            // --- THỰC HIỆN DỊCH TÊN MÓN ĂN ---
                            future: translator.translate(mealName, from: 'en', to: 'vi'),
                            builder: (context, snapshot) {
                              String displayText = mealName;
                              if (snapshot.hasData) {
                                displayText = snapshot.data!.text;
                              }
                              return Text(
                                displayText,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? Colors.white : Colors.black87, // Sửa màu chữ theo giao diện
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
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