import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt"), backgroundColor: Colors.green),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text("Thông báo"),
            subtitle: const Text("Nhận thông báo về món ăn mới"),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Ngôn ngữ"),
            trailing: const Text("Tiếng Việt"),
            onTap: () {},
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Chế độ tối"),
            value: false,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}