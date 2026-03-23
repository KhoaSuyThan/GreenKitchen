class Meal {
  final String id; // Firebase dùng String ID
  final String name;
  final String? nameVietnamese; 
  final String thumb;
  final String? category;

  Meal({
    required this.id,
    required this.name,
    this.nameVietnamese,
    required this.thumb,
    this.category,
  });

  // 1. Giữ nguyên hàm này nếu bạn vẫn dùng API để lấy món ăn bên ngoài
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'].toString(), // Ép kiểu sang String để đồng bộ
      name: json['strMeal'],
      thumb: json['strMealThumb'],
      category: json['strCategory'],
    );
  }

  // 2. THÊM MỚI: Hàm này để lấy dữ liệu từ FIREBASE (Firestore)
  factory Meal.fromFirestore(Map<String, dynamic> json, String docId) {
    return Meal(
      id: docId, // Lấy ID tự động của Document trên Firebase
      name: json['name'] ?? json['title'] ?? '', // Bạn check lại key 'title' hay 'name' ở Database cũ nhé
      nameVietnamese: json['nameVietnamese'],
      thumb: json['image_path'] ?? json['thumb'] ?? '', // Firestore thường dùng image_path
      category: json['category'],
    );
  }

  // 3. THÊM MỚI: Hàm để đẩy dữ liệu lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameVietnamese': nameVietnamese,
      'thumb': thumb,
      'category': category,
    };
  }

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