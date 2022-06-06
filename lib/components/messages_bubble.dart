import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String textMessage;
  final String sender;
  final bool isMeTheLoggedInUser;

  const MessageBubble(
      {Key? key, required this.textMessage, required this.sender, required this.isMeTheLoggedInUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    BorderRadius messageOnRightBorderRadius = const BorderRadius.only(topLeft: Radius.circular(15.0),
        bottomRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0));

    BorderRadius messageOnLeftBorderRadius = const BorderRadius.only(topRight: Radius.circular(15.0),
        bottomRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0));

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMeTheLoggedInUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(color: Colors.black45),
          ),
          Material(
            borderRadius: isMeTheLoggedInUser ? messageOnRightBorderRadius : messageOnLeftBorderRadius,
            elevation: 10.0,
            color: isMeTheLoggedInUser ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Text(
                textMessage,
                style: TextStyle(
                    color: isMeTheLoggedInUser ? Colors.white : Colors.black54
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}