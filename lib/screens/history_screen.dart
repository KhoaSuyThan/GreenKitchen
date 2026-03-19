import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();

  @override
  Widget build(BuildContext context) {
    final int userId = int.parse(AuthService.currentUser!['id'].toString());
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đã xem")),
      body: FutureBuilder(
        future: HistoryService.getHistory(AuthService.currentUser!['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            // Nếu không có dữ liệu, phải hiện thông báo này thì mình mới biết là nó chạy rồi nhưng trống
            return const Center(child: Text("Bạn chưa xem món ăn nào 🧐"));
          }
          final list = snapshot.data as List;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final meal = list[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal['meal_thumb'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    // Xử lý nếu ảnh lỗi để không làm trắng màn hình
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood),
                  ),
                ),
                title: Text(
                  meal['meal_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Xem lúc: ${meal['viewed_at']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16), // Thêm mũi tên cho đẹp
                onTap: () {
                  Navigator.pop(context, list[index]['meal_id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy ID user hiện tại từ AuthService của bạn
    final int userId = AuthService.currentUser!['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đã xem"),
        actions: [
          // Nút xóa tất cả trên thanh công cụ
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () => _showDeleteAllDialog(userId),
          ),
        ],
      ),
      body: FutureBuilder(
        future: HistoryService.getHistory(userId), // Hàm lấy danh sách cũ của bạn
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data as List;
          if (list.isEmpty) return const Center(child: Text("Lịch sử trống 🧐"));

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final int recordId = int.parse(item['id'].toString());


              // --- TÍNH NĂNG VUỐT ĐỂ XÓA ---
              return Dismissible(
                key: Key(recordId.toString()), // ID duy nhất từ SQL
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // Xử lý khi vuốt xong
                onDismissed: (direction) async {
                  await HistoryService.deleteHistoryItem(recordId);
                  // Thông báo nhỏ dưới màn hình
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã xóa ${item['meal_name']} khỏi lịch sử")),
                  );
                },
                child: ListTile(
                  leading: Image.network(item['meal_thumb'], width: 50),
                  title: Text(item['meal_name']),
                  subtitle: Text("Xem lúc: ${item['viewed_at']}"),
                  onTap: () {
                    // Trả về ID để nhảy sang tab công thức như đã làm ở bước trước
                    Navigator.pop(context, item['meal_id']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hàm hiện hộp thoại xác nhận xóa sạch lịch sử
  void _showDeleteAllDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa toàn bộ?"),
        content: const Text("Bạn có chắc chắn muốn xóa tất cả lịch sử đã xem không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              await HistoryService.clearAllHistory(userId);
              Navigator.pop(context); // Đóng dialog
              setState(() {}); // Làm mới danh sách
            },
            child: const Text("Xóa sạch", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}