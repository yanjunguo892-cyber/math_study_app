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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('登录', style: TextStyle(fontSize: 22)),
                  const SizedBox(height: 12),
                  TextField(controller: _user, decoration: const InputDecoration(labelText: '用户名')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pwd,
                    obscureText: !_show,
                    decoration: InputDecoration(
                      labelText: '密码',
                      suffixIcon: IconButton(icon: Icon(_show ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _show = !_show)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? true)), const Expanded(child: Text('我已同意协议'))]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_agree) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先同意协议')));
                          return;
                        }
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('last_user', _user.text.trim().isEmpty ? 'student' : _user.text.trim());
                        Navigator.pushReplacementNamed(context, '/study');
                      },
                      child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('登 录')),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
