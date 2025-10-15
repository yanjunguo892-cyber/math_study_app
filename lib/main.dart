import 'package:flutter/material.dart';
import 'pages/evaluation_page.dart';
import 'db/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().initDb(); // 初始化数据库
  runApp(const MathStudyApp());
}

class MathStudyApp extends StatelessWidget {
  const MathStudyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '数理化任我行',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const EvaluationPage(),
    );
  }
}
