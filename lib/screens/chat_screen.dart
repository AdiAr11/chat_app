import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';

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
    }catch(e){
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

  Future messagesStream() async {
    var snapshots = _firestore.collection("messages").snapshots();
    await for(var snapshot in snapshots){
      // for(var message in snapshot.docs)
    }

    StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                return Text(doc['name']);
              });
        } else {
          return Text("No data");
        }
      },
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: (){
                        uploadMessage();
                      },
                      child: const Text(
                        'Send',
                        style: kSendButtonTextStyle,
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
    _firestore.collection("messages").add({
      "text": textMessage,
      "sender": userName
    });
  }
}
