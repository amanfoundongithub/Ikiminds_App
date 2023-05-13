import 'package:App/authenticationModule/authenMain.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePassword extends StatelessWidget {
  final String email;
  const ChangePassword(this.email, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: const Text('Change Password')),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isSmallScreen
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Logo(),
                        _FormContent(email),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(32.0),
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          const Expanded(child: _Logo()),
                          Expanded(
                            child: Center(child: _FormContent(email)),
                          ),
                        ],
                      ),
                    ),
            ],
          )),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FlutterLogo(size: isSmallScreen ? 50 : 100),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Expanded(
            child: Text(
              "New Password",
              textAlign: TextAlign.center,
              style: isSmallScreen
                  ? Theme.of(context).textTheme.headlineSmall
                  : Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  final String email;
  const _FormContent(this.email, {Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool _isPasswordVisible = false;
  String email = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Now the action that button performs
  Future<int> passwordChangeHandler() async {
    final response = await http.put(
      Uri.parse('http://192.168.174.180:5000/parent/changePassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
        'password': password.text,
      }),
    );

    if (response.statusCode == 200) {
      // password changed successfully
      return 1;
    } else if (response.statusCode == 400) {
      // not updated
      return 0;
    } else {
      // error connecting to database
      throw Exception("Database connection failed");
    }
  }

  @override
  void initState() {
    email = widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password field cannot be empty';
                }
                // if (value.length < 8) {
                //   return 'Password must be at least 8 characters';
                // }
                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create new password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
              controller: password,
            ),
            _gap(),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password field cannot be empty';
                }

                if (password.text != confirmPassword.text) {
                  return 'Passwords does not match';
                }

                return null;
              },
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )),
              controller: confirmPassword,
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Change',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    passwordChangeHandler().then((value) {
                      if (value == 1) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Password Change'),
                                content: Text(
                                    'Password changed successfully for $email'),
                                actions: [
                                  OutlinedButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const AuthenticationPage()));
                                      })
                                ],
                              );
                            });
                        return;
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('error'),
                                content: const Text('Email does not exist'),
                                actions: [
                                  OutlinedButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      })
                                ],
                              );
                            });
                        return;
                      }
                    });

                    /// do something
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
