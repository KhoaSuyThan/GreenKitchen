import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            itemBuilder: (context, index) => ListTile(
              leading: Image.network(list[index]['meal_thumb'], width: 50),
              title: Text(list[index]['meal_name']),
              subtitle: Text("Xem lúc: ${list[index]['viewed_at']}"),
            ),
          );
        },
      ),
    );
  }
}