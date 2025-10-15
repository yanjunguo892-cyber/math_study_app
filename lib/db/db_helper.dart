import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String dbPath = join(await getDatabasesPath(), 'math_study.db');
    var database = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE knowledge_points(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        knowledge_id INTEGER,
        type TEXT,
        question TEXT,
        optionA TEXT,
        optionB TEXT,
        optionC TEXT,
        optionD TEXT,
        answer TEXT
      )
    ''');

    // 初始化10个知识点
    List<String> knowledgeTitles = [
      "分数的基本概念",
      "小数与分数互化",
      "比例与比",
      "一元一次方程",
      "平行四边形面积",
      "三角形性质",
      "圆的半径与直径",
      "立体图形表面积",
      "统计图与平均数",
      "应用题综合练习"
    ];

    for (var title in knowledgeTitles) {
      await db.insert('knowledge_points', {'title': title});
    }

    // 为每个知识点添加测试题
    for (int i = 1; i <= 10; i++) {
      for (var type in ["填空题", "判断题", "选择题", "应用题"]) {
        for (int j = 1; j <= 5; j++) {
          await db.insert('questions', {
            'knowledge_id': i,
            'type': type,
            'question': '（知识点$i-$type-$j）这是一个示例题目内容',
            'optionA': 'A选项内容',
            'optionB': 'B选项内容',
            'optionC': 'C选项内容',
            'optionD': 'D选项内容',
            'answer': j % 2 == 0 ? 'B' : 'A'
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    var dbClient = await db;
    return await dbClient.query('questions');
  }

  Future<void> clearAll() async {
    var dbClient = await db;
    await dbClient.delete('knowledge_points');
    await dbClient.delete('questions');
  }
}
