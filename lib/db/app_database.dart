import 'dart:async';

class AppDatabase {
  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    // 模拟题库
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {"id": 1, "type": "填空", "content": "1+1=？"},
      {"id": 2, "type": "判断", "content": "2是质数。"},
      {"id": 3, "type": "选择", "content": "下列哪个数是偶数？A.3 B.5 C.8 D.9"},
      {"id": 4, "type": "应用", "content": "小明买了3个苹果，每个2元，一共多少钱？"},
    ];
  }
}
