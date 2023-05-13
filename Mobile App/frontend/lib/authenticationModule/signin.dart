import 'package:App/authenticationModule/forgotPassword.dart';
import 'package:App/profile/profile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    // print(isSmallScreen);

    return Container(
      child: isSmallScreen
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                _Logo(),
                _FormContent(),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: const [
                  Expanded(child: _Logo()),
                  Expanded(
                    child: Center(child: _FormContent()),
                  ),
                ],
              ),
            ),
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
        FlutterLogo(size: isSmallScreen ? 50 : 100),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Welcome,\n Please Sign In!",
            textAlign: TextAlign.center,
            style: isSmallScreen
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.black),
          ),
        )
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  final _storage = const FlutterSecureStorage();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Now the action that button performs
  Future<int> loginHandler() async {
    // Write values
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/parent/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email.text,
        'password': password.text,
      }),
    );

    if (response.statusCode == 200) {
      await _storage.write(key: "KEY_USERNAME", value: email.text);
      await _storage.write(key: "KEY_PASSWORD", value: password.text);
      return 1;
    } else if (response.statusCode == 401) {
      // email does not exist
      return 2;
    } else if (response.statusCode == 403) {
      // invalid credentials
      return 3;
    } else {
      // error connecting with database
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Widget build(BuildContext context) {
    // for Forget Password

    TextStyle defaultStyle = const TextStyle(color: Colors.black, fontSize: 16);
    TextStyle linkStyle = const TextStyle(color: Colors.blue);

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              validator: (value) {
                // add email validation
                if (value == null || value.isEmpty) {
                  return 'Email field cannot be empty';
                }

                bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Please enter a valid email';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              controller: email,
            ),
            _gap(),
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
                  hintText: 'Enter your password',
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
            CheckboxListTile(
              value: _rememberMe,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _rememberMe = value;
                });
              },
              title: const Text(
                  'By Signing up, I agree to the terms and conditions of this website.'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: const EdgeInsets.all(0),
            ),
            _gap(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: !_rememberMe
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          loginHandler().then((value) {
                            if (value == 1) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                            email.text,
                                          )));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Error During Sign In'),
                                      content: value == 2
                                          ? const Text(
                                              "Email does not exist! Proceed to Sign Up")
                                          : const Text(
                                              'Invalid Credentials Try Again'),
                                      actions: [
                                        OutlinedButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            })
                                      ],
                                    );
                                  });
                            }
                          });
                        }
                      },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            _gap(),
            RichText(
              // for clickable text property
              text: TextSpan(
                style: defaultStyle,
                children: <TextSpan>[
                  const TextSpan(text: 'Forgotten your password?'),
                  TextSpan(
                      text: 'Click here',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPassword()));
                        }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
