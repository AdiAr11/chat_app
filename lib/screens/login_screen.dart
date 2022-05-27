import 'package:chat_app/constants.dart';
import 'package:flutter/material.dart';

import '../components/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static String id = "login_screen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: "logo",
              child: SizedBox(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                //Do something with the user input.
              },
              decoration: kFieldDecoration.copyWith(
                hintText: "Enter you email"
              )
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                obscureText: true,
              onChanged: (value) {
                //Do something with the user input.
              },
              decoration: kFieldDecoration.copyWith(
                  hintText: "Enter you password"
              )
            ),
            const SizedBox(
              height: 24.0,
            ),
            RoundedButton(
                buttonColor: Colors.lightBlueAccent,
                onPressed: (){},
                buttonText: "Log In"
            ),
          ],
        ),
      ),
    );
  }
}
