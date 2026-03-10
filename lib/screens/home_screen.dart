import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../widgets/HomeBody.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các trang để chuyển đổi
  final List<Widget> _pages = [
    const HomeBody(),        // Trang Home cũ của bạn
    const FavoriteScreen(),  // Trang Yêu thích
    const Center(child: Text("Thêm món mới")),
    const Center(child: Text("Giỏ hàng")),
    const Center(child: Text("Cá nhân")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      
      // Dùng IndexedStack để giữ trạng thái các trang (không bị load lại khi chuyển tab)
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: _selectedIndex,
        backgroundColor: Colors.white,
        activeColor: Colors.green,
        color: Colors.grey,
        style: TabStyle.fixedCircle,
        items: const [
          TabItem(icon: Icons.grid_view_rounded, title: 'Danh mục'),
          TabItem(icon: Icons.favorite_border, title: 'Yêu thích'),
          TabItem(icon: Icons.add),
          TabItem(icon: Icons.shopping_bag_outlined, title: 'Giỏ hàng'),
          TabItem(icon: Icons.person_outline, title: 'Cá nhân'),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}