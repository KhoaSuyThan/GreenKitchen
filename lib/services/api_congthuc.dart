import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class RecipeDetailService {
  static final translator = GoogleTranslator();
  static const String baseUrl = "https://www.themealdb.com/api/json/v1/1";

  /// Lấy chi tiết công thức dựa trên ID món ăn
  static Future<Map<String, dynamic>?> getRecipeById(String mealId) async {
    final url = Uri.parse("$baseUrl/lookup.php?i=$mealId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["meals"] == null) return null;

        // Lấy object món ăn đầu tiên
        Map<String, dynamic> meal = data["meals"][0];

        // Tiến hành dịch và xử lý dữ liệu
        return await _processAndTranslateRecipe(meal);
      }
    } catch (e) {
      print("Lỗi RecipeDetailService: $e");
    }
    return null;
  }

  /// Hàm nội bộ để dịch tên, hướng dẫn và gộp nguyên liệu
  static Future<Map<String, dynamic>> _processAndTranslateRecipe(
    Map<String, dynamic> meal,
  ) async {
    try {
      // 1. Dịch Tên món & Hướng dẫn (Chạy song song để tiết kiệm thời gian)
      final translations = await Future.wait([
        translator.translate(meal["strMeal"] ?? "", to: 'vi'),
        translator.translate(
          meal["strInstructions"] ?? "Không có hướng dẫn",
          to: 'vi',
        ),
      ]);

      meal["nameVi"] = translations[0].text;
      meal["instructionsVi"] = translations[1].text;

      // 2. Xử lý danh sách Nguyên liệu (Ingredients + Measure)
      List<Map<String, String>> ingredients = [];

      for (int i = 1; i <= 20; i++) {
        String? ingredient = meal["strIngredient$i"];
        String? measure = meal["strMeasure$i"];

        if (ingredient != null && ingredient.trim().isNotEmpty) {
          // Gộp: "250g" + "Beef" -> "250g Beef"
          String fullText = "${measure?.trim() ?? ""} ${ingredient.trim()}"
              .trim();

          var translated = await translator.translate(fullText, to: 'vi'); // Dịch nguyên liệu sang tiếng Việt

         
          ingredients.add({ // Lưu cả bản gốc và bản dịch để dễ debug
            "original": fullText,
            "translated": translated.text,
          });
        }
      }

      meal["ingredientsList"] = ingredients;

      // 3. Giữ lại link Video và Ảnh
      meal["videoUrl"] = meal["strYoutube"];
      meal["thumbnail"] = meal["strMealThumb"];

      return meal;
    } catch (e) {
      print("Lỗi xử lý dịch công thức: $e");
      return meal; // Trả về bản gốc nếu dịch lỗi
    }
  }
}
