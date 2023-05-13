import 'package:App/authenticationModule/authenMain.dart';
import 'package:App/authenticationModule/changePassword.dart';
import 'package:App/authenticationModule/details.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'dart:convert';

// Create an input widget that takes only one digit

class OtpPage extends StatefulWidget {
  final String email;
  final String password;
  const OtpPage(this.email, this.password, {Key? key}) : super(key: key);
  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  // 4 text editing controllers that associate with the 4 input fields
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();

  int OTP = 0;

  // Add timer to page
  Duration myDur = const Duration(minutes: 2); // 2 minutes for testing purposes

  bool stopTimer = false;

  // Entered otp which is displayed in text widget
  String? _otp;
  String email = '';
  // Email

  Future<void> sendOTP() async {
    // send OTP to email and fetch it from backend
    final response = await http.post(
      Uri.parse('http://192.168.174.180:5000/parent/sendOTP'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
      }),
    );
    if (response.statusCode == 200) {
      OTP = jsonDecode(response.body)["OTP"];
    } else {
      throw Exception("OTP not sent");
    }
  }

  @override
  void initState() {
    sendOTP();
    email = widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Email ID Verification',
                style: TextStyle(
                  fontFamily: AutofillHints.birthday,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(
              height: 30,
            ),
            Text('Enter the OTP sent to $email',
                style: const TextStyle(
                  fontFamily: AutofillHints.birthday,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OtpInput(_fieldOne, true), // auto focus
                OtpInput(_fieldTwo, false),
                OtpInput(_fieldThree, false),
                OtpInput(_fieldFour, false),
                OtpInput(_fieldFive, false),
                OtpInput(_fieldSix, false),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _otp = _fieldOne.text +
                        _fieldTwo.text +
                        _fieldThree.text +
                        _fieldFour.text +
                        _fieldFive.text +
                        _fieldSix.text;
                    // stopTimer = !stopTimer;
                  });
                  if (_otp == OTP.toString()) {
                    setState(() {
                      stopTimer = true;
                    });
                    Navigator.push(
                        // Redirect to the Personal Details Page
                        context,
                        MaterialPageRoute(
                            builder: (context) => widget.password ==
                                    'HiNikunjGarg6636!'
                                ? ChangePassword(widget.email)
                                : DetailsPage(widget.email, widget.password)));
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('OTP validation failed'),
                            content: const Text('OTP enterd is invalid!'),
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
                },
                child: const Text('Submit')),
            const SizedBox(
              height: 30,
            ),
            stopTimer == false
                ? const Text('OTP will expire in: ')
                : const SizedBox(),
            stopTimer == false
                ? TimerCountdown(
                    endTime: DateTime.now().add(myDur),
                    format: CountDownTimerFormat.minutesSeconds,
                    onEnd: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Session Timeout'),
                              content: const Text(
                                  'Oops! Looks like your session has expired.'),
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
                    },
                  )
                : const SizedBox(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _otp = _fieldOne.text +
                      _fieldTwo.text +
                      _fieldThree.text +
                      _fieldFour.text +
                      _fieldFive.text +
                      _fieldSix.text;
                });
                setState(() {
                  myDur = const Duration(minutes: 2);
                  stopTimer = false;
                });
                sendOTP();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('OTP Regeneration Request'),
                        content: const Text(
                            'OTP has been successfully sent to your email\n'),
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
              },
              style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll<Color>(Colors.lightBlue),
              ),
              child: const Text('Request Another OTP',
                  style: TextStyle(
                    color: Colors.black,
                  )),
            ),
            // Display the entered OTP code
            Text(
              _otp?.length == 6 ? '' : 'Please enter OTP',
              style: const TextStyle(fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}

// Create an input widget that takes only one digit
class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: '',
            hintStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
