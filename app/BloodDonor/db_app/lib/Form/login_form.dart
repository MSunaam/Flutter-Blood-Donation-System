import '../sql/dbSql.dart';
import '../global.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  void Function(bool, String, String) nextPage;
  bool? isLoggedIn;
  LoginForm({super.key, required this.nextPage});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController(text: 'muhammadSunaam');
  final passwordController = TextEditingController(text: 'sanTaClause2002@');
  List login_types = ['Admin', 'Patient', 'Donor'];
  var selectedUser = 'Admin';
  bool submitPressed = false;
  bool isPasswordVisible = false;
  bool inCorrectLogin = false;

  Future<bool?> login({
    required MySql db,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    required String userType,
    required void Function(bool, String, String) nextScreen,
  }) async {
    db.getConnection().then((conn) async {
      var results =
          await conn.query('select Username, Password from ${userType}Login');
      if (results.isEmpty) {
        setState(() {
          inCorrectLogin = true;
        });
      } else {
        nextScreen(true, userType, usernameController.text);
      }
    });
    return null;
  }

  Widget loginCheck() {
    if (submitPressed && inCorrectLogin) {
      // usernameController.clear();
      inCorrectLogin = false;
      return Container(
          alignment: Alignment.center,
          child: const Text(
            'Invalid Username or Password',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ));
    }
    return const Text('');
  }

  final db = MySql();

  @override
  void dispose() {
    //delete controller when form ends
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validatePassword(String value) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Enter valid password';
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: TextFormField(
              controller: usernameController,
              onChanged: (value) {
                setState(() {
                  submitPressed = false;
                  inCorrectLogin = false;
                });
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Username',
                  label: Text('Username'),
                  icon: Icon(Icons.person)),
              validator: ((value) {
                if (value == null || value.isEmpty || value.length < 5) {
                  return 'Please enter valid username';
                } else {
                  return null;
                }
              }),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 30),
            child: TextFormField(
              controller: passwordController,
              onChanged: (value) {
                setState(() {
                  submitPressed = false;
                  inCorrectLogin = false;
                });
              },
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Password',
                  label: const Text('Password'),
                  icon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  )),
              validator: ((value) {
                return validatePassword(value!);
              }),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...login_types.map((data) {
                return Flexible(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                    child: RadioListTile(
                      title: Text(data),
                      value: data,
                      groupValue: selectedUser,
                      onChanged: (value) {
                        setState(() {
                          selectedUser = value;
                          inCorrectLogin = false;
                          submitPressed = false;
                        });
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 30),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  var temp = await login(
                      nextScreen: widget.nextPage,
                      db: db,
                      usernameController: usernameController,
                      userType: selectedUser,
                      passwordController: passwordController);

                  setState(() {
                    submitPressed = true;
                    inCorrectLogin = inCorrectLogin;
                  });
                }
              },
              child: const Text('Login'),
            ),
          ),
          loginCheck()
        ],
      ),
    );
  }
}
