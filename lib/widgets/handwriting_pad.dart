import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HandwritingPad extends StatefulWidget {
  final Function(String) onConfirmInput;

  const HandwritingPad({Key? key, required this.onConfirmInput}) : super(key: key);

  @override
  State<HandwritingPad> createState() => _HandwritingPadState();
}

class _HandwritingPadState extends State<HandwritingPad> {
  List<Offset?> _points = [];
  bool _isErasing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      padding: const EdgeInsets.all(8),
      color: const Color(0xFFF8F8F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("手写输入区", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    tooltip: "橡皮擦",
                    icon: Icon(
                      Icons.brush,
                      color: _isErasing ? Colors.red : Colors.grey[800],
                    ),
                    onPressed: () {
                      setState(() {
                        _isErasing = !_isErasing;
                      });
                    },
                  ),
                  IconButton(
                    tooltip: "删除重写",
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _points.clear();
                      });
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      // 模拟手写识别逻辑
                      widget.onConfirmInput("（识别结果：示例答案）");
                    },
                    child: const Text("确认输入"),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 5),

          // 手写画布
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                setState(() {
                  _points = List.from(_points)..add(localPosition);
                });
              },
              onPanEnd: (details) => _points.add(null),
              child: CustomPaint(
                painter: _HandwritingPainter(points: _points),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  final List<Offset?> points;

  _HandwritingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    // 边框
    final borderPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  @override
  bool shouldRepaint(_HandwritingPainter oldDelegate) => oldDelegate.points != points;
}
