import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_app/components/rounded_button.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = "welcome_screen";
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

//for single ticker -> SingleTickerProviderStateMixin
//for multiple -> TickerProviderStateMixin
class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  late AnimationController animationController;
  late Animation logoAnimation;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(seconds: 2),
    );

    logoAnimation = CurvedAnimation(parent: animationController, curve: Curves.bounceInOut);
    // animation.addStatusListener((status) {
    //   if( status == AnimationStatus.completed){
    //     animationController.reverse(from: 1.0);
    //   }else if(status == AnimationStatus.dismissed){
    //     animationController.forward();
    //     animationController.stop();
    //   }
    // });

    animation = ColorTween(begin: Colors.purple, end: Colors.pinkAccent).animate(animationController);

    animationController.forward();
    animationController.addListener(() {
      setState((){});
    });
  }


  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: "logo",
                  child: SizedBox(
                    height: logoAnimation.value * 70,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.orange
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                      animatedTexts: [
                        TypewriterAnimatedText("Flash Chat")
                      ]
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundedButton(
                buttonColor: Colors.lightBlueAccent,
                onPressed: (){Navigator.pushNamed(context, LoginScreen.id);},
                buttonText: "Log In"
            ),
            RoundedButton(
                buttonColor: Colors.blueAccent,
                onPressed: (){Navigator.pushNamed(context, RegistrationScreen.id);},
                buttonText: "Register"
            )
          ],
        ),
      ),
    );
  }
}
