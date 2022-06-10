import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../components/messages_bubble.dart';


late String userName;

class ChatScreen extends StatefulWidget {
  static String id = "chat_screen";
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;

  TextEditingController textEditingController = TextEditingController();

  String? textMessage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                showLogoutDialog(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                // reverse: true,
                shrinkWrap: true,
                children: const [MessagesStream()],
              ),
            ),
            Container(
              decoration: messageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        textMessage = value;
                      },
                      decoration: messageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      uploadMessage();
                      textEditingController.clear();
                    },
                    child: const Text(
                      'Send',
                      style: sendButtonTextStyle,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showLogoutDialog(BuildContext context) {

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Log Out"),
      onPressed:  () async {
        Navigator.of(context).pop();
        await _auth.signOut();
        if (!mounted) return;
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void uploadMessage() {

    DateTime presentTime = DateTime.now();

    _firestore
        .collection("messages")
        .add({"text": textMessage, "sender": userName, "time": presentTime});
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        userName = loggedInUser.email!.split("@").first;
      }
    } catch (e) {
      print(e);
    }
  }

}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Stream<QuerySnapshot> collectionStream =
    //     FirebaseFirestore.instance.collection('messages').snapshots();

    Stream<QuerySnapshot> collectionStream =
    FirebaseFirestore.instance.collection('messages').
    orderBy("time", descending: true).snapshots();

    return StreamBuilder<QuerySnapshot>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!.docs.reversed;
            List<MessageBubble> messageBubbles = [];

            for (var element in messages) {
              final messageText = element['text'];
              final String messageSender = element['sender'];

              final messageBubble = MessageBubble(
                  textMessage: messageText, sender: messageSender,
                isMeTheLoggedInUser: userName == messageSender,
              );
              messageBubbles.add(messageBubble);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: messageBubbles,
            );
          } else {
            return showProgressCircle();
          }
        },
        stream: collectionStream);
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
