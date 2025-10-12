// lib/pages/study_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/app_database.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});
  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  List<Map<String, dynamic>> _kps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final list = await db.getKnowledgePoints();
    setState(() {
      _kps = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习主页'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              Container(
                width: 220,
                color: Colors.blue.shade50,
                child: ListView(
                  children: [
                    const SizedBox(height: 12),
                    const ListTile(title: Text('知识点列表')),
                    for (var kp in _kps)
                      ListTile(
                        title: Text(kp['title'] ?? ''),
                        subtitle: Text(kp['is_mastered'] == 1 ? '已掌握' : (kp['is_unlocked'] == 1 ? '未掌握/可学' : '未解锁')),
                        trailing: ElevatedButton(
                          onPressed: kp['is_unlocked'] == 1 ? () => Navigator.pushNamed(context, '/practice', arguments: kp) : null,
                          child: const Text('学习'),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Center(child: const Text('请选择左侧知识点开始学习（点击学习进入练习）')),
              )
            ]),
    );
  }
}
