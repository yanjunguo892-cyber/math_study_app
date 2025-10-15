import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final bool isTeacher; // ✅ 是否教师端
  final int points;
  final double hours;
  final String subject;
  final Function(String)? onMenuSelect;

  const CustomHeader({
    super.key,
    required this.username,
    this.isTeacher = false, // 默认学生端
    this.points = 0,
    this.hours = 0,
    this.subject = "数学",
    this.onMenuSelect,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // ✅ 顶部系统状态栏保持默认灰色
        Container(
          height: statusBarHeight,
          color: Colors.grey[100],
        ),

        // ✅ 蓝色渐变标题栏（上到下）
        Container(
          height: 48,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ---------- 左侧：用户名 + 平台名称 ----------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$username | 数理化任我行",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ✅ 学生端才显示积分/学时
                  if (!isTeacher) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          "积分",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "$points",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "学时",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "${hours.toStringAsFixed(1)}",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              // ---------- 右侧：数学 + 菜单 ----------
              Row(
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.white, size: 22),
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    onSelected: (value) {
                      if (onMenuSelect != null) onMenuSelect!(value);
                    },
                    itemBuilder: (context) {
                      if (isTeacher) {
                        // ✅ 教师端菜单
                        return const [
                          PopupMenuItem(
                              value: 'add_knowledge', child: Text('录入知识点')),
                          PopupMenuItem(
                              value: 'add_exercise', child: Text('录入习题')),
                          PopupMenuItem(
                              value: 'review_tests', child: Text('审核测评')),
                          PopupMenuItem(value: 'logout', child: Text('退出登录')),
                        ];
                      } else {
                        // ✅ 学生端菜单
                        return const [
                          PopupMenuItem(
                              value: 'knowledge', child: Text('知识点')),
                          PopupMenuItem(
                              value: 'mistakes', child: Text('错题本')),
                          PopupMenuItem(value: 'notes', child: Text('笔记本')),
                          PopupMenuItem(
                              value: 'save_exit', child: Text('保存退出')),
                        ];
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
