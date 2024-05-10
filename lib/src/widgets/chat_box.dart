import 'package:chatting/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../bindings.dart';
import '../../styles.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AnimationController controller;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 55,

        child:  Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(

            onChanged: (msg){
              if(msg=='') {
                layCtr.isTyping = false;
              }else{
                layCtr.isTyping = true;
              }

              //print('## ($msg) isTyping: ${layCtr.isTyping}');
              layCtr.update();

            },
            cursorColor: btnsMsgCol, // Change the cursor color to red

            style: TextStyle(color: dialogFieldWriteCol, fontSize: 14.5),
            controller: layCtr.messagingTec,
            maxLines: null,
            decoration: InputDecoration(
              //enabled: false,

              isDense: false,
              alignLabelWithHint: false,
              filled: false,
              isCollapsed: false,
              focusColor: Colors.white,
              fillColor:  Colors.white,
              hoverColor: Colors.white,
              contentPadding: const EdgeInsets.only(bottom: 0, right: 15, top: 0,left: 15),
              suffixIconConstraints: BoxConstraints(minWidth: 50),
              prefixIconConstraints: BoxConstraints(minWidth: 50),

              suffixIcon: null,
              border: InputBorder.none,
              disabledBorder: InputBorder.none,

              hintText: 'Your message ...',
              hintStyle: TextStyle(color: dialogFieldHintCol, fontSize: 14.5),
              labelStyle: TextStyle(color: dialogFieldLabelCol, fontSize: 14.5),
              errorStyle: TextStyle(color: dialogFieldErrorUnfocusBorderCol.withOpacity(.9), fontSize: 12, letterSpacing: 1),


              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: Colors.black87)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: btnsMsgCol)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: dialogFieldErrorUnfocusBorderCol)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: dialogFieldErrorFocusBorderCol)),
            ),

          ),
        ),
      ),
    );
  }
}
