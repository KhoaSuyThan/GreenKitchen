import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // Lấy chính xác tone màu từ giao diện tham khảo của bạn
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF9F9F9); // Nền xám rất nhẹ giống hình

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final error = await AuthService.changePassword(
          userId: user['id'],
          oldPassword: _oldPassController.text,
          newPassword: _newPassController.text,
        );

        if (mounted) {
          if (error != null) {
            _showCustomSnackBar(error, isError: true);
          } else {
            _showCustomSnackBar("Đổi mật khẩu thành công! ✅", isError: false);
            Navigator.pop(context);
          }
        }
      }


      // Mô phỏng loading
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _showCustomSnackBar("Đổi mật khẩu thành công! ✅", isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      _showCustomSnackBar("Có lỗi xảy ra: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCustomSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : backgroundColor;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Đổi mật khẩu",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.white),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white, // Màu nút Back
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header minh họa
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_person_rounded, size: 50, color: primaryGreen),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Tạo mật khẩu mới",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vui lòng điền thông tin bên dưới để\ncập nhật mật khẩu của bạn.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Form nhập liệu
                Text("MẬT KHẨU HIỆN TẠI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black54)),
                const SizedBox(height: 8),
                CustomPasswordField(
                  controller: _oldPassController,
                  hintText: "Nhập mật khẩu đang dùng",
                  validator: (value) => (value == null || value.isEmpty) ? "Vui lòng nhập mật khẩu cũ" : null,
                ),

                const SizedBox(height: 20),

                Text("MẬT KHẨU MỚI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black54)),
                const SizedBox(height: 8),
                CustomPasswordField(
                  controller: _newPassController,
                  hintText: "Nhập mật khẩu mới (tối thiểu 6 ký tự)",
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Vui lòng nhập mật khẩu mới";
                    if (value.length < 6) return "Mật khẩu phải từ 6 ký tự trở lên";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text("XÁC NHẬN MẬT KHẨU", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black54)),
                const SizedBox(height: 8),
                CustomPasswordField(
                  controller: _confirmPassController,
                  hintText: "Nhập lại mật khẩu mới",
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value != _newPassController.text) return "Mật khẩu xác nhận không khớp";
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Nút Cập nhật đồng bộ style
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0, // Bỏ bóng đổ để phẳng giống các item của bạn
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Bo góc 15 giống các thẻ menu
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Text(
                      "CẬP NHẬT MẬT KHẨU",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget tách rời: Quản lý ẩn/hiện mật khẩu
class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Style đồng bộ với hình ảnh của bạn
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15), // Bo góc giống hệt thẻ menu
      borderSide: BorderSide.none, // Bỏ viền đen thô cứng
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Bóng đổ cực nhẹ giống menu
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          filled: true,
          fillColor: Colors.transparent, // Lấy màu của Container
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5), // Viền xanh khi bấm vào
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22, color: Colors.black45),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.black45,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }
}