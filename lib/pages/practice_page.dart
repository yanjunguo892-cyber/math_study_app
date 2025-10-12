// lib/pages/practice_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/app_database.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late Map<String, dynamic> kp;
  List<Map<String, dynamic>> _qs = [];
  int _index = 0;
  final TextEditingController _ctrl = TextEditingController();
  String? _selectedOption;
  Map<int, String> _answers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null && arg is Map<String, dynamic>) {
      kp = arg;
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    _qs = await db.getQuestionsByKnowledge(kp['id'] as int);
    setState(() {});
  }

  void _submit() {
    if (_qs.isEmpty) return;
    final q = _qs[_index];
    final type = q['type'];
    String userAns = '';
    if (type == '判断' || type == '选择') {
      userAns = _answers[_index] ?? '';
    } else {
      userAns = _ctrl.text.trim();
    }
    final correct = (q['answer'] ?? '').toString().trim();
    final ok = userAns.isNotEmpty && userAns == correct;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(ok ? '回答正确' : '回答错误'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!ok) Text('正确答案：$correct'),
        if ((q['explanation'] ?? '').toString().isNotEmpty) Text('解析：${q['explanation']}')
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_qs.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text('练习 - ${kp['title'] ?? ''}')), body: const Center(child: CircularProgressIndicator()));
    }
    final q = _qs[_index];
    List<String> opts = [];
    if ((q['options'] ?? '').toString().isNotEmpty) {
      try {
        opts = List<String>.from(jsonDecode(q['options']));
      } catch (_) {}
    }
    _ctrl.text = _answers[_index] ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('练习 - ${kp['title'] ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text('题目 ${_index + 1}/${_qs.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(q['question'] ?? ''))),
          const SizedBox(height: 12),
          if (q['type'] == '判断')
            Row(children: [
              ElevatedButton(onPressed: () => setState(() => _answers[_index] = '正确'), child: const Text('正确')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => setState(() => _answers[_index] = '错误'), child: const Text('错误')),
              const SizedBox(width: 12),
              Text('你的选择：${_answers[_index] ?? ''}'),
            ])
          else if (q['type'] == '选择')
            Column(children: opts.map((o) => RadioListTile<String>(
              value: o,
              groupValue: _answers[_index],
              title: Text(o),
              onChanged: (v) => setState(() => _answers[_index] = v ?? ''),
            )).toList())
          else
            Column(children: [
              TextField(controller: _ctrl, decoration: const InputDecoration(labelText: '请输入答案')),
            ]),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(onPressed: _index > 0 ? () => setState(() => _index -= 1) : null, child: const Text('上一题')),
            ElevatedButton(onPressed: _submit, child: const Text('提交')),
            ElevatedButton(onPressed: _index < _qs.length - 1 ? () => setState(() => _index += 1) : null, child: const Text('下一题')),
          ])
        ]),
      ),
    );
  }
}
