import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:chatting/bindings.dart';
import 'package:chatting/generalLayout/generalLayoutCtr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../main.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../src/widgets/chat_box.dart';
import '../src/widgets/chat_list.dart';
import '../src/widgets/record_button.dart';
import '../styles.dart';

double size = 55;

class ClubMessages extends StatefulWidget {
  const ClubMessages({super.key});

  @override
  State<ClubMessages> createState() => _ClubMessagesState();
}

class _ClubMessagesState extends State<ClubMessages> with SingleTickerProviderStateMixin {
  //SingleTickerProviderStateMixin
  //TickerProviderStateMixin

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

  }


  @override
  void dispose() {
    controller.dispose();
    layCtr.isTyping=false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: btnsMsgCol,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: btnsMsgCol,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Container(
              color: btnsMsgCol,
              height: 2.0,
            )),
        actions: [
          if (cUser.isAdmin) ...[
            //refresh
            GestureDetector(
              onTap: () {
                layCtr.deleteMessages();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Center(
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Container(
        color: bgCol,
        child: GetBuilder<LayoutCtr>(
          dispose: (_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              layCtr.badgeCount = 0;
              layCtr.update();
              layCtr.seenMessages = layCtr.messages.length;
              sharedPrefs!.setInt('${layCtr.selectedUser.id}', layCtr.seenMessages);

              print('## setInt seenMessages = ${layCtr.seenMessages} ');
              layCtr.selectUser(layCtr.selectedUser.id);
              sharedPrefs!.reload();
            });
          },
          builder: (ctr) {
            return Column(
              children: [
                ///AudioList
                //Expanded(child: layCtr.animatedMsgList),
                Expanded(child: StreamingDocWidget()),
                /// TExt field + button
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0,top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(width: 10),

                      ChatBox(controller: controller),

                      const SizedBox(width: 0),
                     !layCtr.isTyping ?  RecordButton(controller: controller) : GestureDetector(
                       onTap: () {
                         String msg = layCtr.messagingTec.text;
                         print('## sending message: $msg');
                         layCtr.sendMessage(msg);
                       },
                       child: Container(
                        child: const Icon(Icons.send,color: Colors.white,),
                        height: size,
                        width: size,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: btnsMsgCol,
                        ),
                    ),
                     ),
                      const SizedBox(width: 15),


                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
