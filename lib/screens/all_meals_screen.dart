import 'package:flutter/material.dart';
import '../widgets/meal_card.dart';

class AllMealsScreen extends StatelessWidget {
  final List meals;
  final Function(String) onMealTap;

  const AllMealsScreen({
    super.key,
    required this.meals,
    required this.onMealTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Món ăn phổ biến"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          // FIX LỖI OVERFLOW: Ép tỷ lệ xuống 0.48 để thẻ dài ra, chứa đủ 2 dòng chữ
          childAspectRatio: 0.48, 
        ),

        itemBuilder: (context, index) {
          return MealCard(
            meal: meals[index],
            // SỬA Ở ĐÂY: Chuyển thành false để không bị gán cứng chữ "Vietnamese" nữa
            isHome: false, 
            onTap: () {
              // Ép kiểu ID sang String để tránh lỗi khi click vào món Local (ID là số)
              onMealTap(meals[index]["idMeal"].toString());
              Navigator.pop(context); // Đóng màn hình lưới
            },
          );
        },
      ),
    );
  }
}