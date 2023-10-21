import 'package:chat_with_me/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: ((context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('no messages'),
            );
          }
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text('something went wrong'),
            );
          }
          final loadMessages = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: EdgeInsets.only(left: 13, right: 13, bottom: 40),
              reverse: true,
              itemCount: loadMessages.length,
              itemBuilder: (context, index) {
                final ChatMessages = loadMessages[index].data();
                final nextMessage = index + 1 < loadMessages.length
                    ? loadMessages[index + 1].data()
                    : null;

                final currentUserId = ChatMessages['userId'];
                final nextUserId = nextMessage?['userId'];

                final nextUserSame = (currentUserId == nextUserId);
                if (nextUserSame) {
                  return MessageBubble.next(
                      message: ChatMessages['text'],
                      isMe: ChatMessages['userId'] == user.uid);
                } else {
                  return MessageBubble.first(
                      userImage: ChatMessages['userImage'],
                      username: ChatMessages['username'],
                      message: ChatMessages['text'],
                      isMe: ChatMessages['userId'] == user.uid);
                }
              });
        }));
  }
}
