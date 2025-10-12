import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _showPwd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(40),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('登录', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: '用户名'),
                ),
                TextField(
                  controller: _pwdController,
                  obscureText: !_showPwd,
                  decoration: InputDecoration(
                    labelText: '密码',
                    suffixIcon: IconButton(
                      icon: Icon(_showPwd
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() => _showPwd = !_showPwd),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/study');
                  },
                  child: const Text('登录'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
