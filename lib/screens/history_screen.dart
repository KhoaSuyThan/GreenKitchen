import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Hàm hiện Dialog xác nhận
  Future<bool?> _showConfirmDialog(BuildContext context, String mealName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Khoa có chắc muốn xóa '$mealName' khỏi lịch sử không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("XÓA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ID user an toàn từ AuthService
    final dynamic rawId = AuthService.currentUser?['id'];
    if (rawId == null) return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    final int userId = int.parse(rawId.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đã xem"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await _showConfirmDialog(context, "tất cả lịch sử");
              if (confirm == true) {
                await HistoryService.clearAllHistory(userId);
                setState(() {}); // Load lại danh sách trắng
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: HistoryService.getHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text("Lịch sử trống 🧐"));
          }

          final list = snapshot.data as List;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) => _HistoryTile(
              item: list[index],
              onDelete: () async {
                final confirm = await _showConfirmDialog(context, list[index]['meal_name']);
                if (confirm == true) {
                  await HistoryService.deleteHistoryItem(int.parse(list[index]['id'].toString()));
                  setState(() {}); // Cập nhật lại UI sau khi xóa
                }
              },
              onTap: () {
                // Trả về meal_id để MainScreen nhảy tab Công thức
                Navigator.pop(context, list[index]['meal_id']);
              },
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET RIÊNG CHO MỖI DÒNG LỊCH SỬ (HỖ TRỢ VUỐT HIỆN NÚT XÓA CỐ ĐỊNH) ---
class _HistoryTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onDelete, required this.onTap});

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  final double _buttonWidth = 80.0; // Độ rộng của nút xóa màu đỏ

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
      // Giới hạn: Chỉ cho vuốt sang trái, tối đa là bằng độ rộng nút xóa
      if (_dragExtent > 0) _dragExtent = 0;
      if (_dragExtent < -_buttonWidth) _dragExtent = -_buttonWidth;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Logic "hít": Vuốt quá 1/2 nút thì mở hẳn, không thì đóng lại
    if (_dragExtent < -_buttonWidth / 2) {
      setState(() => _dragExtent = -_buttonWidth);
    } else {
      setState(() => _dragExtent = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LỚP DƯỚI: Nút xóa màu đỏ nằm chờ sẵn
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                widget.onDelete(); // Gọi hàm xác nhận xóa
                setState(() => _dragExtent = 0); // Đóng tile lại
              },
              child: Container(
                width: _buttonWidth,
                color: Colors.red,
                alignment: Alignment.center,
                child: const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
        // LỚP TRÊN: Nội dung hiển thị món ăn
        Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: widget.onTap,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.item['meal_thumb'],
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood),
                  ),
                ),
                title: Text(
                    widget.item['meal_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Text("Xem lúc: ${widget.item['viewed_at']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}