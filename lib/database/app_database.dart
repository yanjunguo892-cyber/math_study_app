// lib/database/app_database.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;
  static AppDatabase? _instance;
  AppDatabase._();

  static Future<AppDatabase> getInstance() async {
    if (_instance != null) return _instance!;
    _instance = AppDatabase._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final docs = await getApplicationDocumentsDirectory();
    final path = p.join(docs.path, 'study_app.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    // If empty, insert initial data
    final cnt = Sqflite.firstIntValue(await _db!.rawQuery('SELECT COUNT(*) FROM knowledge_points')) ?? 0;
    if (cnt == 0) {
      await _insertInitialData();
    }
  }

  Future<void> _onCreate(Database db, int v) async {
    await db.execute('''
      CREATE TABLE knowledge_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        order_index INTEGER,
        is_unlocked INTEGER DEFAULT 0,
        is_mastered INTEGER DEFAULT 0
      );
    ''');
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        knowledge_id INTEGER,
        knowledge_title TEXT,
        type TEXT,
        question TEXT,
        options TEXT,
        answer TEXT,
        explanation TEXT
      );
    ''');
  }

  // Insert 10 knowledge points, each with 20 sample questions
  Future<void> _insertInitialData() async {
    final titles = [
      '一元一次方程',
      '二次函数',
      '勾股定理',
      '相似三角形',
      '分式方程',
      '平行四边形性质',
      '圆的周长与面积',
      '概率初步',
      '数据统计与分析',
      '函数的单调性'
    ];
    for (int i = 0; i < titles.length; i++) {
      final id = await _db!.insert('knowledge_points', {
        'title': titles[i],
        'content': '这是关于 ${titles[i]} 的要点与示例。',
        'order_index': i + 1,
        'is_unlocked': i == 0 ? 1 : 0,
        'is_mastered': 0
      });
      await _insertSampleQuestionsFor(id, titles[i]);
    }
  }

  Future<void> _insertSampleQuestionsFor(int knowledgeId, String ktitle) async {
    final rand = Random();
    // 5 填空
    for (int i = 1; i <= 5; i++) {
      await _db!.insert('questions', {
        'knowledge_id': knowledgeId,
        'knowledge_title': ktitle,
        'type': '填空',
        'question': '填空题 $i：关于 $ktitle 的练习（答案是数字）',
        'options': '',
        'answer': '$i',
        'explanation': '填空解析 $i：...'
      });
    }
    // 5 判断
    for (int i = 1; i <= 5; i++) {
      final ans = i % 2 == 0 ? '错误' : '正确';
      await _db!.insert('questions', {
        'knowledge_id': knowledgeId,
        'knowledge_title': ktitle,
        'type': '判断',
        'question': '判断题 $i：关于 $ktitle 的陈述是否正确？',
        'options': '',
        'answer': ans,
        'explanation': '判断解析 $i：...'
      });
    }
    // 5 选择
    for (int i = 1; i <= 5; i++) {
      final opts = ['A: 选项1', 'B: 选项2', 'C: 选项3', 'D: 选项4'];
      final correct = opts[rand.nextInt(opts.length)];
      await _db!.insert('questions', {
        'knowledge_id': knowledgeId,
        'knowledge_title': ktitle,
        'type': '选择',
        'question': '选择题 $i：关于 $ktitle 的描述，选择最合适的一项。',
        'options': jsonEncode(opts),
        'answer': correct,
        'explanation': '选择解析 $i：正确是 $correct'
      });
    }
    // 5 应用
    for (int i = 1; i <= 5; i++) {
      await _db!.insert('questions', {
        'knowledge_id': knowledgeId,
        'knowledge_title': ktitle,
        'type': '应用',
        'question': '应用题 $i：基于 $ktitle 的实际问题，请计算（示例）。',
        'options': '',
        'answer': '${i * 2}',
        'explanation': '应用解析 $i：...'
      });
    }
  }

  Future<List<Map<String, dynamic>>> getKnowledgePoints() async {
    return await _db!.query('knowledge_points', orderBy: 'order_index ASC');
  }

  Future<Map<String, dynamic>?> getKnowledgeById(int id) async {
    final r = await _db!.query('knowledge_points', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : r.first;
  }

  Future<List<Map<String, dynamic>>> getQuestionsByKnowledge(int knowledgeId) async {
    return await _db!.query('questions', where: 'knowledge_id=?', whereArgs: [knowledgeId]);
  }

  Future<void> markKnowledgeMastered(int knowledgeId) async {
    await _db!.update('knowledge_points', {'is_mastered': 1}, where: 'id=?', whereArgs: [knowledgeId]);
  }

  // export DB file to app documents or download folder; returns exported path or null
  Future<String?> exportDatabase() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docs.path, 'study_app.db');
      final dest = p.join(docs.path, 'study_app_exported.db');
      await File(dbPath).copy(dest);
      return dest;
    } catch (e) {
      return null;
    }
  }
}
