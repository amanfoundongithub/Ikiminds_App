import 'package:flutter/material.dart';
import 'package:App/profile/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetailsPage extends StatelessWidget {
  final String email;
  final String password;

  const DetailsPage(this.email, this.password, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    // print(isSmallScreen);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isSmallScreen
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _Logo(),
                        _FormContent(email, password),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(32.0),
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          const Expanded(child: _Logo()),
                          Expanded(
                            child: Center(child: _FormContent(email, password)),
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
          child: Text(
            "Please Enter\n Your Personal Details",
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
  final String email;
  final String password;

  const _FormContent(this.email, this.password, {Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  final _storage = const FlutterSecureStorage();

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  bool agree = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<int> infoHandler() async {
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/parent/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': widget.email,
        'password': widget.password,
        'name': name.text,
        'mobile_no': int.parse(phone.text),
      }),
    );

    if (response.statusCode == 200) {
      await _storage.write(key: "KEY_USERNAME", value: widget.email);
      await _storage.write(key: "KEY_PASSWORD", value: widget.password);
      return 1;
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // add name validation
                if (value == null || value.isEmpty) {
                  return 'Name field cannot be empty';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your Name',
                border: OutlineInputBorder(),
              ),
              controller: name,
            ),
            _gap(),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is Required';
                } else if (num.tryParse(value) == null) {
                  return 'Phone number contains must contain digits only';
                } else if (value.length != 10) {
                  return 'Phone number must be of 10 digits';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              controller: phone,
            ),
            _gap(),
            CheckboxListTile(
              value: agree,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  agree = value;
                });
              },
              title: const Text(
                  'I assure that details provided are best of my knowledge'),
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
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    infoHandler().then((value) {
                      if (value == 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(widget.email)));
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Error during Sign up'),
                                content: const Text('Enter valid information'),
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
