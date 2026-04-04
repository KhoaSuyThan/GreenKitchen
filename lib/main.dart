import 'package:doanapp/widgets/ThemeApp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Thêm dòng này
import 'screens/login_screen.dart';

void main() async {
  // 1. Đảm bảo các dịch vụ của Flutter được khởi tạo trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase với cấu hình mặc định cho từng nền tảng
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Thêm dòng này để "lắng nghe" sự thay đổi từ Switch
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',

      // 2. Theme sáng (mặc định)
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),

      // 3. THÊM DÒNG NÀY: Định nghĩa màu cho chế độ tối
      darkTheme: ThemeData(
        brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212), // Ép nền toàn app màu đen xám
  cardColor: const Color(0xFF1E1E1E), // Ép các ô nội dung màu xám đậm
  canvasColor: const Color(0xFF121212), // Thêm dòng này để fix các phần menu bị trắng
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1F1F)),
      ),

      // 4. THÊM DÒNG NÀY: Quyết định dùng theme nào dựa trên biến isDarkMode
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const LoginScreen(),
    );
  }
}
