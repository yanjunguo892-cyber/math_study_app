// lib/pages/practice_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/app_database.dart';
import '../widgets/handwriting_pad.dart';

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
  Map<int, String> _answers = {};
  bool _showHandwriting = false;

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

  void _submitAnswer() {
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ok ? '回答正确' : '回答错误'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!ok) Text('正确答案：$correct'),
          if ((q['explanation'] ?? '').toString().isNotEmpty) Text('解析：${q['explanation']}')
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
      ),
    );
  }

  Future<void> _onHandwritingSave(File f) async {
    // example: you can attach this image to user's answer or upload
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('草稿已保存：${f.path}')));
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
      body: Column(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(children: [
              Text('题目 ${_index + 1}/${_qs.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(q['question'] ?? '', style: const TextStyle(fontSize: 16)))),
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
            ]),
          ),
        ),

        // 底部：手写区（可折叠）+ 操作按钮
        Container(
          color: Colors.grey.shade50,
          child: Column(children: [
            // 折叠手写区的控制栏
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton.icon(
                icon: const Icon(Icons.brush),
                label: Text(_showHandwriting ? '隐藏手写区' : '显示手写区'),
                onPressed: () => setState(() => _showHandwriting = !_showHandwriting),
              ),
              Row(children: [
                ElevatedButton(onPressed: _index > 0 ? () => setState(() => _index -= 1) : null, child: const Text('上一题')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _submitAnswer, child: const Text('提交')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _index < _qs.length - 1 ? () => setState(() => _index += 1) : null, child: const Text('下一题')),
              ]),
            ]),
            if (_showHandwriting)
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: HandwritingPad(onSave: (file) async => _onHandwritingSave(file)),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}
