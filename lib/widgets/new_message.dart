import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final msg = messageController.text;
    if (msg.trim().isEmpty) return;
    messageController.clear();
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    print(user);
    print(userData.data());
    final msgObj = await FirebaseFirestore.instance.collection('chat').add({
      'text': msg,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()?['userName'],
      'userImage': userData.data()?['imageUrl']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 1, left: 15, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(labelText: 'send a message...'),
          )),
          IconButton(
              onPressed: sendMessage,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ))
        ],
      ),
    );
  }
}
