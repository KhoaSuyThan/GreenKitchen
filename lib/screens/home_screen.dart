import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../widgets/HomeBody.dart';
import 'favorite_screen.dart';
import 'recipe_details_screen.dart';
import '../services/auth_service.dart';
import '../widgets/profile_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? selectedMealId;

  // ⭐ key đúng phải là FavoriteScreenState
  final GlobalKey<FavoriteScreenState> favoriteKey =
      GlobalKey<FavoriteScreenState>();

  // chuyển sang tab công thức
  void openRecipeTab(String mealId) {
    setState(() {
      selectedMealId = mealId;
      _selectedIndex = 3;
    });
  }

  // danh sách trang
  // Trong _HomeScreenState
  List<Widget> get _pages {
    bool admin = AuthService.isAdmin();

    return [
      HomeBody(onMealTap: openRecipeTab),
      FavoriteScreen(key: favoriteKey),
      // Nếu là admin thì cho vào trang quản lý, nếu không thì hiện thông báo
      admin
          ? const Center(child: Text("Màn hình Quản lý của Admin"))
          : const Center(child: Text("Bạn cần quyền Admin để thêm món")),
      selectedMealId == null
          ? const Center(child: Text("Chọn món để xem công thức"))
          : RecipeDetailScreen(
            mealId: selectedMealId!,
            onBack: () {
              setState(() {
                _selectedIndex = 0; // Chuyển về Tab Danh mục (Index 0)
              });
            },
          ),
      const ProfileBody(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: ConvexAppBar(
        key: ValueKey(_selectedIndex),
        initialActiveIndex: _selectedIndex,
        backgroundColor: Colors.white,
        activeColor: Colors.green,
        color: Colors.grey,
        style: TabStyle.fixedCircle,
        items: const [
          TabItem(icon: Icons.grid_view_rounded, title: 'Danh mục'),
          TabItem(icon: Icons.favorite_border, title: 'Yêu thích'),
          TabItem(icon: Icons.add),
          TabItem(icon: Icons.menu_book_outlined, title: 'Công thức'),
          TabItem(icon: Icons.person_outline, title: 'Cá nhân'),
        ],

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // ⭐ mở tab yêu thích thì reload
          if (index == 1) {
            favoriteKey.currentState?.refreshFavorites();
          }
        },
      ),
    );
  }
}