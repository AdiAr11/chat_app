import 'dart:async';

import 'package:chat_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  static String id = "verify_email";
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {

  bool isEmailVerified = false;
  var currentUser = FirebaseAuth.instance.currentUser;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = currentUser!.emailVerified;
    if(!isEmailVerified){
      sendVerificationEmail();
    }

    timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
    return isEmailVerified ? LoginScreen() :
        Scaffold(
          appBar: AppBar(
            title: const Text("Verify email"),
          ),
        );
  }

  Future sendVerificationEmail() async {
    try {
      await currentUser?.sendEmailVerification();
    }catch(e){
      showSnackBar(e.toString());
    }
  }

  void showSnackBar(String message){
    var snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

}
