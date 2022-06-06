import 'package:chat_app/components/rounded_button.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  static String id = "registration_screen";

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? email;
  String? password;
  final _auth = FirebaseAuth.instance;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? showProgressCircle()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Flexible(
                    child: Hero(
                      tag: "logo",
                      transitionOnUserGestures: true,
                      child: SizedBox(
                        height: 200.0,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: textFieldDecoration.copyWith(
                          hintText: "Enter your email")),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                      textAlign: TextAlign.center,
                      obscureText: true,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: textFieldDecoration.copyWith(
                          hintText: "Enter your password")),
                  const SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                      buttonColor: Colors.blueAccent,
                      onPressed: () {
                        registerNewUser();
                      },
                      buttonText: "Register"),
                ],
              ),
            ),
    );
  }

  Future registerNewUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email!, password: password!);

      if (!mounted) return;
      if (newUser != null) {
        setState(() {
          isLoading = false;
        });
        await Navigator.pushNamed(context, ChatScreen.id);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Widget showProgressCircle() {
    return SpinKitFadingCircle(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.red : Colors.green,
          ),
        );
      },
    );
  }
}
