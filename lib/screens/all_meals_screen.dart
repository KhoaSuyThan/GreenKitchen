import 'package:doanapp/screens/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/meal_card.dart';

class AllMealsScreen extends StatelessWidget {
  final List meals;

  const AllMealsScreen({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Món ăn phổ biến")),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: meals.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.55,
        ),

        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: MealCard(
                meal: meals[index],
                onTap: () {
                  // Chuyển sang màn hình chi tiết khi nhấn vào card
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        mealId: meals[index]["idMeal"], // Truyền ID của món ăn qua
                      ),
                    ),
                  );
                }
            ),
          );
        },
      ),
    );
  }
}
