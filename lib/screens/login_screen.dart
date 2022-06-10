import 'dart:async';

import 'package:chat_app/constants.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../components/rounded_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static String id = "login_screen";
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  bool isLoading = false;

  bool isEmailVerified = false;
  var currentUser = FirebaseAuth.instance.currentUser;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = currentUser?.emailVerified ?? false;

    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkEmailVerifiedOrNot();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }


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
                          hintText: "Enter you email")),
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
                          hintText: "Enter you password")),
                  const SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                      buttonColor: Colors.lightBlueAccent,
                      onPressed: () {
                        authenticateUser();
                      },
                      buttonText: "Log In"),

                      RichText(
                      text: TextSpan(
                      style: const TextStyle(color: Colors.black87),
                      children: <TextSpan>[
                        const TextSpan(text: '\nDid not recieve verification email? check spam folder'),
                        TextSpan(
                            text: ' or resend',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                sendVerificationEmail();
                              }),
                      ],
                    ),
                    )

                ],
              ),
            ),
    );
  }

  void showSnackBar(String message){
    var snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future sendVerificationEmail() async {
    try {
      await currentUser?.sendEmailVerification();
      showSnackBar("Verification email sent");
    }catch(e){
      showSnackBar(e.toString());
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

  Future checkEmailVerifiedOrNot() async {

    await currentUser!.reload();
    setState((){
      isEmailVerified = currentUser!.emailVerified;
    });
    if(isEmailVerified){
      timer!.cancel();
    }
  }

  Future authenticateUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.toString(), password: password.toString());
      if (!mounted) return;
      if (credential != null && currentUser!.emailVerified) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushNamed(context, ChatScreen.id);
      }else if(!currentUser!.emailVerified){
        setState(() {
          isLoading = false;
        });
        showSnackBar("Email is not verified");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      if (e.code == 'user-not-found') {
        showSnackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar('Wrong password provided for that user.');
      } else{
        showSnackBar(e.toString());
      }
    }
  }

}
