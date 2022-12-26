import 'package:flutter/material.dart';
import 'Form/login_form.dart';
import 'adminView/admin_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //function to navigate to other screens
  void nextScreen(bool checkLogin, String checkUser, String adminName) {
    if (checkUser == 'Admin') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => adminPage(adminName: adminName)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 40,
                ),
              ),
              LoginForm(
                nextPage: nextScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
