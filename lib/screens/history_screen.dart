import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Hàm hiện Dialog xác nhận xóa
  Future<bool?> _showConfirmDialog(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có chắc muốn xóa $title không?"),
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
    // Lấy ID user an toàn (Dạng String từ Firebase)
    final String? userId = AuthService.currentUser?['id']?.toString();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

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
                setState(() {}); // Load lại danh sách rỗng
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // ✅ CHỈ TRUYỀN userId (Bỏ đoạn DateTime.now() cũ)
        future: HistoryService.getHistory(userId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("Lịch sử trống 🧐", style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) => _HistoryTile(
              item: list[index],
              onDelete: () async {
                final confirm = await _showConfirmDialog(context, "'${list[index]['meal_name']}'");
                if (confirm == true) {
                  await HistoryService.deleteHistoryItem(list[index]['id'].toString());
                  setState(() {}); // Reload UI
                }
              },
              onTap: () {
                if (list[index]['meal_id'] != null) {
                  Navigator.pop(context, list[index]['meal_id']);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onDelete, required this.onTap});

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  double _dragExtent = 0;
  final double _buttonWidth = 80.0;

  // Định dạng thời gian từ Firebase Timestamp
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      DateTime dt = date.toDate();
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return "Vừa xong";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lớp dưới: Nút xóa
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                widget.onDelete();
                setState(() => _dragExtent = 0);
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
        // Lớp trên: Nội dung ListTile có thể vuốt
        Transform.translate(
          offset: Offset(_dragExtent, 0),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragExtent += details.primaryDelta!;
                if (_dragExtent > 0) _dragExtent = 0;
                if (_dragExtent < -_buttonWidth) _dragExtent = -_buttonWidth;
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() => _dragExtent = (_dragExtent < -_buttonWidth / 2) ? -_buttonWidth : 0);
            },
            onTap: widget.onTap,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.item['meal_thumb'] ?? "",
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 30),
                  ),
                ),
                title: Text(
                  widget.item['meal_name'] ?? "Không tên",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text("Xem lúc: ${_formatDate(widget.item['viewed_at'])}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}