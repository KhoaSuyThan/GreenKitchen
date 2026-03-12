import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // 3 bộ điều khiển cho 3 ô nhập
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  void _handleChangePassword() async {
    final oldP = _oldPassController.text.trim();
    final newP = _newPassController.text.trim();
    final confirmP = _confirmPassController.text.trim();
    final user = AuthService.currentUser;

    // Bước 1: Kiểm tra trống
    if (oldP.isEmpty || newP.isEmpty || confirmP.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ các trường");
      return;
    }

    // Bước 2: Kiểm tra mật khẩu mới và xác nhận có khớp nhau không
    if (newP != confirmP) {
      _showSnackBar("Mật khẩu mới và xác nhận không khớp!");
      return;
    }

    // Bước 3: Kiểm tra độ dài mật khẩu (Ví dụ tối thiểu 6 ký tự)
    if (newP.length < 6) {
      _showSnackBar("Mật khẩu mới phải từ 6 ký tự trở lên");
      return;
    }

    // Bước 4: Gọi Service để xử lý dưới Database
    if (user != null) {
      final error = await AuthService.changePassword(
        userId: user['id'],
        oldPassword: oldP,
        newPassword: newP,
      );

      if (mounted) {
        if (error != null) {
          // Hiện lỗi nếu mật khẩu cũ sai
          _showSnackBar(error);
        } else {
          // Thành công
          _showSnackBar("Đổi mật khẩu thành công! ✅");
          Navigator.pop(context);
        }
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPasswordField(_oldPassController, "Mật khẩu hiện tại"),
              const SizedBox(height: 15),
              _buildPasswordField(_newPassController, "Mật khẩu mới"),
              const SizedBox(height: 15),
              _buildPasswordField(_confirmPassController, "Xác nhận mật khẩu mới"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("CẬP NHẬT", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget dùng chung cho các ô nhập mật khẩu
  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock_outline),
      ),
    );
  }
}