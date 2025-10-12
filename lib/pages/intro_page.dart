// lib/pages/intro_page.dart
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          _page(context, '欢迎', '数理化任我行 — 用于学生学习与测评'),
          _page(context, '手写练习', '支持手写输入、练习、测评'),
          _page(context, '开始', '准备开始', end: true),
        ],
      ),
    );
  }

  Widget _page(BuildContext context, String title, String sub, {bool end = false}) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(sub),
        const SizedBox(height: 24),
        if (end)
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('开始使用'),
          )
      ]),
    );
  }
}
