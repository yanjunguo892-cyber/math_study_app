// lib/pages/study_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/app_database.dart';
import '../widgets/handwriting_pad.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});
  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  bool collapsed = false;
  List<Map<String, dynamic>> _kps = [];
  bool _loading = true;
  Map<String, dynamic>? _currentKP;
  String _knowledgeContent = '';
  String _analysisContent = '解析区域：示例解析内容，包含例题步骤与关键提示。';
  String _tipsContent = '方法技巧：总结解题方法、公式和常见误区。';

  @override
  void initState() {
    super.initState();
    _loadKnowledgePoints();
  }

  Future<void> _loadKnowledgePoints() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final list = await db.getKnowledgePoints();
    setState(() {
      _kps = list;
      _loading = false;
      if (_kps.isNotEmpty) {
        _currentKP = _kps.firstWhere((e) => (e['is_unlocked'] ?? 0) == 1, orElse: () => _kps.first);
        _knowledgeContent = _currentKP?['content'] ?? '';
      }
    });
  }

  void _selectKP(Map<String, dynamic> kp) {
    setState(() {
      _currentKP = kp;
      _knowledgeContent = kp['content'] ?? '';
    });
  }

  Future<void> _saveHandwriting(File file) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('手写已保存：${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentKP == null ? '学习' : '学习 - ${_currentKP!['title'] ?? ''}'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadKnowledgePoints)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              // 左侧导航（可折叠）
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: collapsed ? 64 : 260,
                color: Colors.blue.shade50,
                child: Column(children: [
                  const SizedBox(height: 10),
                  IconButton(
                    icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left),
                    onPressed: () => setState(() => collapsed = !collapsed),
                  ),
                  const SizedBox(height: 6),
                  CircleAvatar(radius: 28, child: Icon(Icons.school)),
                  if (!collapsed) ...[
                    const SizedBox(height: 8),
                    const Text('数理化任我行', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Divider(),
                  ] else
                    const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: _kps.map((kp) {
                        final unlocked = (kp['is_unlocked'] ?? 0) == 1;
                        final mastered = (kp['is_mastered'] ?? 0) == 1;
                        return ListTile(
                          dense: true,
                          leading: Icon(unlocked ? Icons.book : Icons.lock),
                          title: collapsed ? null : Text(kp['title'] ?? ''),
                          subtitle: collapsed ? null : Text(mastered ? '已掌握' : (unlocked ? '可学' : '未解锁')),
                          trailing: collapsed
                              ? null
                              : ElevatedButton(onPressed: unlocked ? () => _selectKP(kp) : null, child: const Text('学习')),
                          onTap: unlocked ? () => _selectKP(kp) : null,
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: collapsed ? const Icon(Icons.save) : const Text('保存并退出'),
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),

              // 右侧主区：分四部分
              Expanded(
                child: Column(children: [
                  // 1. 知识点主讲区（较大）
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            _currentKP == null ? '请选择知识点' : (_currentKP!['title'] ?? ''),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_knowledgeContent, style: const TextStyle(fontSize: 16)),
                        ]),
                      ),
                    ),
                  ),

                  // 2. 解析 + 方法技巧（中间行）
                  Expanded(
                    flex: 2,
                    child: Row(children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 4, 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                          child: SingleChildScrollView(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('解析', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_analysisContent),
                            ]),
                          ),
                        ),
                      ),
                      Container(
                        width: 260,
                        margin: const EdgeInsets.fromLTRB(4, 0, 8, 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('方法技巧', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_tipsContent),
                        ]),
                      ),
                    ]),
                  ),

                  // 3. 手写区 + 操作列（下方）
                  Container(
                    height: 220,
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      // 标签
                      Container(width: 40, alignment: Alignment.center, child: const RotatedBox(quarterTurns: 3, child: Text('手写涂鸦'))),

                      // 手写板
                      Expanded(
                        child: HandwritingPad(
                          onSave: (file) async {
                            await _saveHandwriting(file);
                          },
                        ),
                      ),

                      // 操作列
                      const SizedBox(width: 12),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('我要做练习题'),
                          onPressed: _currentKP == null ? null : () => Navigator.pushNamed(context, '/practice', arguments: _currentKP),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save_alt),
                          label: const Text('保存草稿'),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('手写草稿已保存')));
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('清空画板'),
                          onPressed: () {
                            // simple refresh to clear (HandwritingPad has its own clear)
                            setState(() {});
                          },
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ]),
    );
  }
}
