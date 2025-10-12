// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/study_page.dart';
import 'pages/practice_page.dart';
import 'pages/assessment_page.dart';
import 'pages/result_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.getInstance();
  runApp(MyApp(database: db));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp({required this.database, super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AppDatabase>.value(
      value: database,
      child: MaterialApp(
        title: '数理化任我行',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (_) => const IntroPage(),
          '/login': (_) => const LoginPage(),
          '/study': (_) => const StudyPage(),
          '/practice': (_) => const PracticePage(),
          '/assessment': (_) => const AssessmentPage(),
          '/result': (_) => const ResultPage(),
        },
      ),
    );
  }
}
