import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/category_model.dart';
import '../services/api_service.dart';
import '../widgets/meal_card.dart';
import '../screens/all_meals_screen.dart';
import '../database/firebase_service.dart';

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

  final int popularLimit = 6; 

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

  void loadDefaultMeals() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Chạy song song cả API và Firebase để tối ưu tốc độ
      final results = await Future.wait([
        ApiService.fetchVietnameseMeals(),
        FirebaseService.instance.getApprovedRecipes(),
      ]);

      final List apiData = (results[0] as List?) ?? [];
      final List firebaseData = (results[1] as List?) ?? [];

      List<Map<String, dynamic>> formattedFirebaseData = firebaseData.map((item) {
        return {
          "idMeal": item['id'].toString(),
          "strMeal": item['title'] ?? "Món ăn cộng đồng",
          "strMealThumb": item['image_path'] ?? "", 
          "strArea": "Cộng đồng", 
          "isLocal": true, 
        };
      }).toList();

      if (mounted) {
        setState(() {
          meals = [...formattedFirebaseData, ...apiData];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi load trang chủ: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      // SỬA LỖI: Kiểm tra query trống chính xác hơn và thoát hàm sớm
      final cleanQuery = query.trim();
      if (cleanQuery.isEmpty) {
        loadDefaultMeals();
        return; // Dừng lại, không chạy code search bên dưới
      }

      if (mounted) setState(() => isLoading = true);

      try {
        final searchResults = await Future.wait([
          ApiService.searchMeals(cleanQuery),
          FirebaseService.instance.getApprovedRecipes(),
        ]);

        final List apiResults = (searchResults[0] as List?) ?? [];
        final List allApproved = (searchResults[1] as List?) ?? [];

        final filteredCloud = allApproved.where((m) => 
          m['title'].toString().toLowerCase().contains(cleanQuery.toLowerCase())
        ).map((item) => {
          "idMeal": item['id'].toString(),
          "strMeal": item['title'] ?? "Không tên",
          "strMealThumb": item['image_path'] ?? "",
          "strArea": "Cộng đồng",
          "isLocal": true,
        }).toList();

        if (mounted) {
          setState(() {
            meals = [...filteredCloud, ...apiResults];
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Lỗi tìm kiếm: $e");
        if (mounted) setState(() => isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                    _searchController.text.isEmpty ? "Món ăn phổ biến" : "Kết quả tìm kiếm",
                    onTap: meals.isEmpty ? null : () {
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

          if (isLoading)
            const SliverFillRemaining(
              hasScrollBody: false, // SỬA LỖI: Tránh lỗi render trong sliver
              child: Center(child: CircularProgressIndicator(color: Colors.green)),
            )
          else if (meals.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text("Không tìm thấy món nào 😢")),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MealCard(
                      meal: meals[index],
                      isHome: _searchController.text.isEmpty,
                      onTap: () => widget.onMealTap(meals[index]["idMeal"]),
                    );
                  },
                  childCount: _searchController.text.isEmpty
                      ? (meals.length > popularLimit ? popularLimit : meals.length)
                      : meals.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- HÀM BUILD GIỮ NGUYÊN ---
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
        onChanged: onSearchChanged,
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
        Text(title, style: GoogleFonts.beVietnamPro(fontSize: 22, fontWeight: FontWeight.bold)),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Row(
              children: [
                Text("Xem tất cả", style: TextStyle(color: Colors.green, fontSize: 13)),
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
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 5),
                  Text(cat.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}