import 'package:chatting/myVoids.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../bindings.dart';
import '../../generalLayout/generalLayoutCtr.dart';
import '../../styles.dart';
import 'audio_bubble.dart';

class StreamingDocWidget extends StatefulWidget {

  StreamingDocWidget();

  @override
  State<StreamingDocWidget> createState() => _StreamingDocWidgetState();
}

class _StreamingDocWidgetState extends State<StreamingDocWidget> {



  @override
  void initState() {
    super.initState();


  }

  @override
  void dispose() {

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return  GetBuilder<LayoutCtr>(
        initState: (_){
        print('## ## "START streaming" ## ## ');
        layCtr.scrollController = ScrollController();
        layCtr.messagingTec = TextEditingController();
        Future.delayed(const Duration(milliseconds: 300), () {

          layCtr.scrollToEnd();

        });

      },
        dispose: (_){
        print('## ## "STOP streaming" ## ## ');
        layCtr.scrollController.dispose();
        layCtr.messagingTec.dispose();
      },

    builder: (_) {
        return StreamBuilder(
          stream: chatRoomsColl.where('id', isEqualTo: layCtr.selectedChatRoomID).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              }            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Send your first message'));
            }

            var chatDoc = snapshot.data!.docs.first;
            Map<String, dynamic> messages = chatDoc.get('messages');

            print('## messages : ${messages.length}');
            if(layCtr.seenMessages<messages.length){
              layCtr.badgeCount= messages.length - layCtr.seenMessages;
            }

            if(messages.isEmpty){
              return Center(child: Text('Send your first message'));
            }
            // Create an AnimatedList to display the chat messages
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 15),
              itemCount: messages.length,
              controller: layCtr.scrollController,

              itemBuilder: (context, i,) {
                Map<String, dynamic> msg = messages[i.toString()];
                String msgText = msg['msg'];
                bool isVoice = msgText.contains('https://firebasestorage.googleapi');
                bool isSender = cUser.name == msg['sender'];
                bool showTail = true;

                if (i < messages.length - 1) {
                  Map<String, dynamic> nextMsg = messages[(i + 1).toString()];
                  if (msg['sender'] == nextMsg['sender']) {
                    showTail = false;
                  }
                }


                return BblChat(
                  isVoice: isVoice,
                  widget: isVoice
                      ? AudioBubble(
                    filepath: msgText,
                    key: ValueKey(msgText),
                  )
                      : Text(
                    msgText,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                  color: blueCol, // You need to provide the 'blueCol' color
                  tail: showTail,
                  isSender: isSender,
                );

              },
            );
          },
        );
      }
    );
  }
}
/*
                return BblChat(
                  isVoice: isVoice,
                  widget: FadeTransition(
                    opacity: animation,
                    child: isVoice
                        ? AudioBubble(
                      filepath: msgText,
                      key: ValueKey(msgText),
                    )
                        : Text(
                      msgText,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  color: blueCol, // You need to provide the 'blueCol' color
                  tail: showTail,
                  isSender: isSender,
                );

*/