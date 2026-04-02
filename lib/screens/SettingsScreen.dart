import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Đừng quên import provider
import 'package:doanapp/widgets/ThemeApp.dart'; // Đảm bảo đường dẫn này đúng với file của bạn

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gọi themeNotifier để lắng nghe trạng thái và điều khiển đổi theme
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        // Nếu muốn AppBar đổi màu theo theme, bạn có thể bỏ backgroundColor cứng 
        // hoặc dùng: themeNotifier.isDarkMode ? Colors.black87 : Colors.green
      ),
      body: ListView(
        children: [

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Chế độ tối"),
            // Lấy giá trị từ ThemeNotifier
            value: themeNotifier.isDarkMode, 
            onChanged: (val) {
              // Gọi hàm đổi theme khi gạt switch
              themeNotifier.toggleTheme(val);
            },
            activeColor: Colors.tealAccent, // Màu khi bật cho đẹp
          ),
        ],
      ),
    );
  }
}