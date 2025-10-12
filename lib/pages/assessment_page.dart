// lib/pages/assessment_page.dart
import 'package:flutter/material.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('测评')),
      body: Center(
        child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/result'), child: const Text('提交测评并查看结果')),
      ),
    );
  }
}
