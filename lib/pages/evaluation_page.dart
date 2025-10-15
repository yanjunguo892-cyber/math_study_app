import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../widgets/custom_header.dart';
import '../widgets/handwriting_pad.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({Key? key}) : super(key: key);

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  String _recognizedText = '';
  bool _isLoading = true;
  late DBHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DBHelper();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await _dbHelper.getQuestions();
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _recognizedText = '';
        _currentIndex++;
      });
    } else {
      _submitEvaluation();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _recognizedText = '';
        _currentIndex--;
      });
    }
  }

  void _submitEvaluation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("测评完成"),
        content: const Text("恭喜你，完成全部测评试题！系统正在计算测评结果..."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final questionType = currentQuestion['type'] ?? '';
    final questionText = currentQuestion['question'] ?? '';
    final optionA = currentQuestion['optionA'] ?? '';
    final optionB = currentQuestion['optionB'] ?? '';
    final optionC = currentQuestion['optionC'] ?? '';
    final optionD = currentQuestion['optionD'] ?? '';

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(
            username: '学生A',
            points: 120,
            hours: 2.5,
            subject: '数学',
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // ===== 上部：题目区 =====
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "数学知识全面测评",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "题型：$questionType   （第 ${_currentIndex + 1} / ${_questions.length} 题）",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            questionText,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),

                          if (questionType == "选择题" || questionType == "判断题")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("A. $optionA"),
                                Text("B. $optionB"),
                                if (questionType == "选择题") ...[
                                  Text("C. $optionC"),
                                  Text("D. $optionD"),
                                ],
                              ],
                            ),

                          const SizedBox(height: 10),
                          if (_recognizedText.isNotEmpty)
                            Text(
                              "识别结果：$_recognizedText",
                              style: const TextStyle(
                                  color: Colors.blue, fontWeight: FontWeight.bold),
                            ),

                          const Spacer(),

                          // ===== 按钮区 =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_currentIndex > 0)
                                ElevatedButton(
                                  onPressed: _previousQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text("上一题"),
                                ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _nextQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: Text(
                                  _currentIndex == _questions.length - 1
                                      ? "提交测评"
                                      : "下一题",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== 下部：手写区 =====
                  Expanded(
                    flex: 4,
                    child: HandwritingPad(
                      onConfirmInput: (result) {
                        setState(() {
                          _recognizedText = result;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
