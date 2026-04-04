import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../widgets/HomeBody.dart';
import 'favorite_screen.dart';
import 'recipe_details_screen.dart';
import '../services/auth_service.dart';
import '../widgets/profile_body.dart';
// Import 2 màn hình mới 
import 'AdminApprovalScreen.dart';
import 'AddRecipeFormScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? selectedMealId;

  final GlobalKey<FavoriteScreenState> favoriteKey = GlobalKey<FavoriteScreenState>();
  Key _homeBodyKey = UniqueKey();

  void openRecipeTab(String mealId) {
    setState(() {
      selectedMealId = mealId;
      _selectedIndex = 3;
    });
  }

  void _refreshHomeBody() {
    setState(() {
      _homeBodyKey = UniqueKey();
    });
  }

  List<Widget> get _pages {
    return [
      HomeBody(key: _homeBodyKey, onMealTap: openRecipeTab),
      FavoriteScreen(
        key: favoriteKey,
        onMealTap: openRecipeTab,
        onFavoritesChanged: _refreshHomeBody,
      ),
      // Index 2: Placeholder vì nút giữa dùng Navigator.push
      const Center(child: CircularProgressIndicator()), 
      selectedMealId == null
          ? const Center(child: Text("Chọn món để xem công thức"))
          : RecipeDetailScreen(
                key: ValueKey(selectedMealId),
              mealId: selectedMealId!,
              onBack: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
      ProfileBody(onHistoryMealTap: openRecipeTab),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // THÊM DÒNG NÀY: Kiểm tra xem app đang ở chế độ Sáng hay Tối
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // SỬA DÒNG NÀY: Đổi nền Scaffold sang đen khi ở Dark Mode
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xffF8F8F8),
      
      body: IndexedStack(index: _selectedIndex, children: _pages),
      
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: _selectedIndex,
        
        // SỬA DÒNG NÀY: Đổi màu nền của thanh Menu dưới cùng
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        
        activeColor: Colors.green,
        
        // SỬA DÒNG NÀY: Chữ/Icon khi không chọn sáng hơn 1 chút ở Dark Mode để dễ nhìn
        color: isDark ? Colors.grey.shade400 : Colors.grey,
        
        style: TabStyle.fixedCircle,
        items: const [
          TabItem(icon: Icons.grid_view_rounded, title: 'Danh mục'),
          TabItem(icon: Icons.favorite_border, title: 'Yêu thích'),
          TabItem(icon: Icons.add),
          TabItem(icon: Icons.menu_book_outlined, title: 'Công thức'),
          TabItem(icon: Icons.person_outline, title: 'Cá nhân'),
        ],
        onTap: (index) {
          // XỬ LÝ RIÊNG CHO NÚT GIỮA (INDEX 2)
          if (index == 2) {
            bool admin = AuthService.isAdmin();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => admin 
                    ? const AdminApprovalScreen() 
                    : const AddRecipeFormScreen(),
              ),
            ).then((_) => setState(() {})); // Refresh lại nếu cần sau khi quay về
            return; // Dừng lại, không chạy xuống setState(_selectedIndex) bên dưới
          }

          // CÁC TAB KHÁC GIỮ NGUYÊN
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            favoriteKey.currentState?.refreshFavorites();
          }
          if (index == 0) {
            _refreshHomeBody();
          }
        },
      ),
    );
  }
}