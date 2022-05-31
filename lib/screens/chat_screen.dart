import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  late String? userName;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchMessages();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        userName = loggedInUser.email?.split("@").first;
      }
    } catch (e) {
      print(e);
    }
  }

  Future fetchMessages() async {
    _firestore.collection("messages").get().then(
      (QuerySnapshot querySnapshot) {
        for (var message in querySnapshot.docs) {
          print(message["text"]);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _auth.signOut();
                if (!mounted) return;
                Navigator.pop(context);
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
              child: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[MessagesStream()],
                ),
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

  void uploadMessage() {
    _firestore
        .collection("messages")
        .add({"text": textMessage, "sender": userName});
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> collectionStream =
        FirebaseFirestore.instance.collection('messages').snapshots();

    return StreamBuilder<QuerySnapshot>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!.docs;
            List<MessageBubble> messageBubbles = [];

            for (var element in messages) {
              final messageText = element['text'];
              final messageSender = element['sender'];

              final messageBubble = MessageBubble(
                  textMessage: messageText, sender: messageSender);
              messageBubbles.add(messageBubble);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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

class MessageBubble extends StatelessWidget {
  final String textMessage;
  final String sender;

  const MessageBubble(
      {Key? key, required this.textMessage, required this.sender})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: const TextStyle(color: Colors.black45),
          ),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: 10.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Text(
                textMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
