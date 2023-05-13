import 'package:App/authenticationModule/signin.dart';
import 'package:App/authenticationModule/signup.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({Key? key}) : super(key: key);

  @override
  State<AuthenticationPage> createState() => _AuthenticationPage();
}

class Button extends StatelessWidget {
  final int pageIndex;
  final Function animate;
  final int loginState;

  const Button(this.pageIndex, this.animate, this.loginState, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(
          Theme.of(context).buttonTheme.minWidth * 1.5,
          Theme.of(context).buttonTheme.height,
        )),
        backgroundColor: pageIndex == loginState
            ? const MaterialStatePropertyAll<Color>(Color(0xFFD3D3D3)) // grey
            : const MaterialStatePropertyAll<Color>(Colors.white), // white
      ),
      onPressed: () {
        animate();
      },
      child: pageIndex == 0
          ? const Text(
              'Log In',
              style: TextStyle(
                color: Colors.black,
              ),
            )
          : const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
    );
  }
}

class _AuthenticationPage extends State<AuthenticationPage> {
  int pageIndex = 0; // login page
  final PageController controller = PageController();

  void navigate(int p) {
    setState(() {
      pageIndex = p;
      controller.animateToPage(pageIndex,
          duration: const Duration(microseconds: 500), curve: Curves.linear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
                child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(0, () {
                    navigate(0);
                  }, pageIndex),
                  Button(1, () {
                    navigate(1);
                  }, pageIndex)
                ],
              ),
              Flexible(
                  fit: FlexFit.loose,
                  child: PageView(
                    controller: controller,
                    onPageChanged: (value) {
                      setState(() {
                        pageIndex = value;
                      });
                    },
                    children: const <Widget>[
                      SignInPage(),
                      SignUpPage(),
                    ],
                  )),
            ]))));
  }
}
