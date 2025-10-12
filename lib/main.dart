import 'package:flutter/material.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/study_page.dart';
import 'pages/practice_page.dart';
import 'pages/assessment_page.dart';
import 'pages/result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
