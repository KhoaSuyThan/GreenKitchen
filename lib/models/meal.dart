class Meal {
  final String id;
  final String name;
  final String? nameVietnamese; // Lưu tên đã dịch
  final String thumb;
  final String? category;

  Meal({
    required this.id,
    required this.name,
    this.nameVietnamese,
    required this.thumb,
    this.category,
  });

  // Chuyển từ JSON của API sang Object
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      thumb: json['strMealThumb'],
      category: json['strCategory'],
    );
  }

  // Tạo bản sao với tên tiếng Việt
  Meal copyWithVietnamese(String translatedName) {
    return Meal(
      id: id,
      name: name,
      nameVietnamese: translatedName,
      thumb: thumb,
      category: category,
    );
  }
}