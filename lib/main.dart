import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Thêm dòng này
import 'screens/login_screen.dart';


void main() async {
  // 1. Đảm bảo các dịch vụ của Flutter được khởi tạo trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase với cấu hình mặc định cho từng nền tảng
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Giữ nguyên màn hình đăng nhập làm màn hình chính
      home: const LoginScreen(),
    );
  }
}