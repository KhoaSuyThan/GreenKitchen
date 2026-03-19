import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  final Function(String)? onMealTap;
  const FavoriteScreen({super.key, this.onMealTap});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {

  List favorites = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }


  void refreshFavorites() {
    loadFavorites();
  }

  void loadFavorites() async {

    final data = await FavoriteService.getFavorites(1);

    if (!mounted) return;

    setState(() {
      favorites = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Món yêu thích"),
        backgroundColor: Colors.green,
      ),

      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "Chưa có món yêu thích ❤️",
                style: TextStyle(fontSize: 16),
              ),
            )

          : GridView.builder(

              padding: const EdgeInsets.all(20),

              itemCount: favorites.length,

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.78,
              ),

              itemBuilder: (context, index) {

                final meal = favorites[index];


                return InkWell(
                  borderRadius: BorderRadius.circular(20), // Bo góc hiệu ứng nhấn
                  onTap: () {
                    // Gọi hàm chuyển tab từ HomeScreen truyền xuống
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
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            meal["meal_thumb"],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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