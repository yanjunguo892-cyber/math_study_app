// lib/pages/result_page.dart
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('测评结果')),
      body: Center(
        child: ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/study'), child: const Text('返回学习')),
      ),
    );
  }
}
