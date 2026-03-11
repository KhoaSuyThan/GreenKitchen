import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class ApiService {
  static final translator = GoogleTranslator();
  static const String baseUrl = "https://www.themealdb.com/api/json/v1/1";

  /// Tìm kiếm món ăn (Dịch Việt -> Anh rồi mới search)
  static Future<List<dynamic>> searchMeals(String keyword) async {
    try {
      var translation = await translator.translate(keyword, from: 'vi', to: 'en');
      String englishKeyword = translation.text;

      final url = Uri.parse("$baseUrl/search.php?s=$englishKeyword");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> meals = data["meals"] ?? [];
        // PHẢI GỌI HÀM DỊCH Ở ĐÂY
        return await _translateMealList(meals);
      }
    } catch (e) {
      print("Lỗi searchMeals: $e");
    }
    return [];
  }

  /// 3. Lọc theo danh mục (Sửa lỗi ấn "Bánh" ko ra gì)

  /// 4. Món ăn Việt Nam 
  static Future<List<dynamic>> fetchVietnameseMeals() async {

  final response = await http.get(
    Uri.parse(
      "https://www.themealdb.com/api/json/v1/1/filter.php?a=Vietnamese",
    ),
  );

  if (response.statusCode == 200) {

    final data = json.decode(response.body);

    return data["meals"] ?? [];
  }

  return [];
}

  /// 4. Hàm phụ trợ: Dịch tên món ăn và lọc các từ khóa "ngáo"
  static Future<List<dynamic>> _translateMealList(List<dynamic> meals) async {
    // Từ điển sửa lỗi dịch sai
    final Map<String, String> manualDictionary = {
      "Ezme": "Salad Ezme",
      "Migas": "Món Migas",
      "Kebab": "Thịt nướng Kebab",
      "Flan": "Bánh Flan",
      "Kabse": "Cơm Kabse",
    };

    // Chặn từ phi thực phẩm
    final blacklist = ['dầu khí', 'nghiền', 'máy móc', 'hệ thống', 'dữ liệu'];
    

    int limit = meals.length > 12 ? 12 : meals.length;

    for (int i = 0; i < limit; i++) {
      try {
        String originalName = meals[i]["strMeal"];

        // Ưu tiên từ điển thủ công
        if (manualDictionary.containsKey(originalName)) {
          meals[i]["strMealVietnamese"] = manualDictionary[originalName];
          continue; 
        }

        // Dịch tự động
        var t = await translator.translate(originalName, to: 'vi');
        String translatedName = t.text;

        // Kiểm tra blacklist
        if (blacklist.any((word) => translatedName.toLowerCase().contains(word))) {
          meals[i]["strMealVietnamese"] = originalName; 
        } else {
          meals[i]["strMealVietnamese"] = translatedName;
        }
      } catch (e) {
        meals[i]["strMealVietnamese"] = meals[i]["strMeal"];
      }
    }
    return meals;
  }
}