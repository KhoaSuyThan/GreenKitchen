import 'dart:io';

import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

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
    _checkFavoriteStatus(); // Kiểm tra trạng thái ngay khi hiện card
  }

  // Hàm kiểm tra trong DB
  void _checkFavoriteStatus() async {
    bool favorited = await FavoriteService.isFavorite(widget.meal["idMeal"]);
    if (mounted) {
      setState(() {
        isFavorite = favorited;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return GestureDetector(
      onTap: widget.onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: meal['isLocal'] == true
                      ? Image.file(
                          File(meal['strMealThumb']),
                          fit: BoxFit.cover,
                        ) // Ảnh từ SQLite (file máy)
                      : Image.network(
                          meal['strMealThumb'],
                          fit: BoxFit.cover,
                        ), // Ảnh từ API (link web)
                ),

                /// FAVORITE
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () async {
                      final meal = widget.meal;

                      setState(() {
                        isFavorite = !isFavorite;
                      });

                      if (isFavorite) {
                        await FavoriteService.addFavorite(
                          1,
                          meal["idMeal"],
                          meal["strMeal"],
                          meal["strMealThumb"],
                        );
                      } else {
                        await FavoriteService.removeFavorite(meal["idMeal"]);
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(6),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                          ),
                        ],
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

            /// INFO
            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Text(
                    meal["strMeal"],
                    //   maxLines: 1,
                    //  overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// ORIGIN
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        
                        meal['isLocal'] == true 
                            ? "Cộng đồng" 
                            : (meal["strArea"]?.toString() ?? "Quốc tế"),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
}
