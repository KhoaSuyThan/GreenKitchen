import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category_model.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import '../screens/all_meals_screen.dart';
// THÊM: Import DatabaseHelper để lấy món từ SQLite
import '../database/database_helper.dart';

class HomeBody extends StatefulWidget {
  final Function(String) onMealTap;

  const HomeBody({super.key, required this.onMealTap});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<dynamic> meals = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final int popularLimit = 6; // Tăng nhẹ limit để hiện được cả món cộng đồng

  @override
  void initState() {
    super.initState();
    loadDefaultMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // CẬP NHẬT: Hàm tải món ăn kết hợp cả API và SQLite
  void loadDefaultMeals() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    // 1. Lấy dữ liệu từ API (Vietnamese Meals)
    var apiData = await ApiService.fetchVietnameseMeals() ?? [];
    
    // 2. Lấy dữ liệu từ SQLite (Các bài đã được Admin duyệt)
    var localData = await DatabaseHelper.instance.getApprovedRecipes();

    // 3. Chuẩn hóa dữ liệu SQLite sang format của API để MealCard dùng chung được
    List<Map<String, dynamic>> formattedLocalData = localData.map((item) {
      return {
        "idMeal": item['id'].toString(), 
        "strMeal": item['title'],
        "strMealThumb": item['image_path'], // Đây là đường dẫn file trong máy
        "strArea": "Cộng đồng",             // Dùng để hiển thị Badge
        "isLocal": true,                   // Cờ hiệu nhận biết món từ User
      };
    }).toList();

    if (mounted) {
      setState(() {
        // Gộp lại: Ưu tiên hiển thị món cộng đồng lên trước
        meals = [...formattedLocalData, ...apiData];
        isLoading = false;
      });
    }
  }

  // CẬP NHẬT: Tìm kiếm trên cả 2 nguồn
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (query.isEmpty) {
        loadDefaultMeals();
        return;
      }

      if (mounted) {
        setState(() => isLoading = true);
      }

      // Tìm trên API
      var apiResults = await ApiService.searchMeals(query) ?? [];
      
      // Tìm trên Local (SQLite)
      var allLocal = await DatabaseHelper.instance.getApprovedRecipes();
      var localResults = allLocal.where((m) => 
        m['title'].toString().toLowerCase().contains(query.toLowerCase())
      ).map((item) => {
        "idMeal": item['id'].toString(),
        "strMeal": item['title'],
        "strMealThumb": item['image_path'],
        "strArea": "Cộng đồng",
        "isLocal": true,
      }).toList();

      if (mounted) {
        setState(() {
          meals = [...localResults, ...apiResults];
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// HEADER (Giữ nguyên cấu trúc của bạn)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Bộ sưu tập"),
                  const SizedBox(height: 15),
                  _buildCategoryList(),
                  const SizedBox(height: 30),
                  _buildSectionHeader(
                    _searchController.text.isEmpty
                        ? "Món ăn phổ biến"
                        : "Kết quả tìm kiếm",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllMealsScreen(
                            meals: meals,
                            onMealTap: widget.onMealTap,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          /// LOADING
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            )
          /// EMPTY
          else if (meals.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text("Không tìm thấy món nào 😢")),
            )
          /// MEALS (Giữ nguyên cấu trúc của bạn)
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MealCard(
                      meal: meals[index],
                      isHome: _searchController.text.isEmpty,
                      onTap: () {
                        // mealId đã được chuẩn hóa ở trên nên cứ truyền vào
                        widget.onMealTap(meals[index]["idMeal"]);
                      },
                    );
                  },
                  childCount: _searchController.text.isEmpty
                      ? (meals.length > popularLimit
                          ? popularLimit
                          : meals.length)
                      : meals.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  /// CÁC HÀM BUILD WIDGET PHỤ (Giữ nguyên 100% code của bạn)
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
          onSearchChanged(value);
        },
        decoration: InputDecoration(
          hintText: "Tìm kiếm món ăn...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    onSearchChanged("");
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Row(
              children: [
                Text(
                  "Xem tất cả",
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.green),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              _searchController.text = cat.label;
              onSearchChanged(cat.name);
              setState(() {});
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 90,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: cat.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 5),
                  Text(
                    cat.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
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