// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pwd = TextEditingController();
  bool _show = false;
  bool _agree = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final last = p.getString('last_user') ?? '';
      _user.text = last;
    });
  }

  @override
  void dispose() {
    _user.dispose();
    _pwd.dispose();
    super.dispose();
  }

  void _doLogin(BuildContext context) async {
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先同意协议')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user', _user.text.trim().isEmpty ? 'student' : _user.text.trim());
    // 跳转到学习页
    Navigator.pushReplacementNamed(context, '/study');
  }

  @override
  Widget build(BuildContext context) {
    // Use SingleChildScrollView so keyboard won't cause overflow
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 6),
                              const Text('登录', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _user,
                                decoration: const InputDecoration(
                                  labelText: '用户名',
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _pwd,
                                obscureText: !_show,
                                decoration: InputDecoration(
                                  labelText: '密码',
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _show = !_show),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? true)),
                                  const Expanded(child: Text('我已阅读并同意《用户服务协议》《隐私政策》')),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _doLogin(context),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Text('登 录', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(onPressed: () {}, child: const Text('我要注册')),
                                  TextButton(onPressed: () {}, child: const Text('忘记密码')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
