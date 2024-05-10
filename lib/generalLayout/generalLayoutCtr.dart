import 'dart:async';
import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../main.dart';
import '../admin/userDetails.dart';
import '../bindings.dart';
import '../firebaseVoids.dart';
import '../models/request.dart';
import '../models/user.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../src/globals.dart';
import '../src/widgets/audio_bubble.dart';
import '../styles.dart';
import 'package:uuid/uuid.dart';

class LayoutCtr extends GetxController {
  String appBarText ='';//appbar title
  String selectedChatRoomID ='';
  String messageToSend ='';
  int  selectedScreen = 0;
  List<Widget> appBarBtns=[];



  List<ScUser> allUsers =[];
  List<ScUser> selectedFriends = [];
  List<ScUser> selectedUsers = [];
  ScUser selectedUser = ScUser();
  List<FrRequest> allRequests =[];

  List<ScUser> myFriends =[];
  List<ScUser> otherFriends =[];

  @override
  onInit() {
    super.onInit();
    print('## ## init LayoutCtr');
    Future.delayed(const Duration(milliseconds: 50), ()  async {
      refreshUsers();
      onScreenSelected(0);

    });
  }

  /// *************************************************************************************

  updateAppbar({String? title,List<Widget>? btns}){
    if(title!=null) appBarText = title;
    if(btns!=null) appBarBtns=btns;
    update();
  }
  onScreenSelected(int index){
    switch (index) {

      case 0:
        selectedScreen = 0;

        updateAppbar(title:'My Friends',btns:[
          GestureDetector(
            onTap: () {
              refreshUsers();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11.0),
              child: Center(
                child: Icon(
                  Icons.refresh,
                  color: appBarButtonsCol,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(cUser.name,style: TextStyle(color: blueCol),),
              ),
            ],
          )
        ]);
          selectedFriends = myFriends;
          update();
        break;

      case 1:
          updateAppbar(title:'Other users',btns:[]);
          selectedScreen = 1;
          selectedFriends = otherFriends;
          update();

        break;

      case 2:
        selectedScreen = 2;

        updateAppbar(title:'Requests',btns:[]);
        update();

        break;

    }
    print('## selected screen ($index) selectedFriends (${selectedFriends.length})');


  }
  /// *************************************************************************************


  //image +

  PickedFile? newItemImage;
  deleteImage() {
    newItemImage = null;
    update();
  }
  updateImage(image){
    if(image != null){
      newItemImage = image!;
      update();
    }
  }



  bool isTeacher(ScUser usr){
    if(usr.role==authCtr.roles[1]){//teacher
      return true;
    }else{
      return false;
    }
  }

  selectUser(userID){
    sharedPrefs!.reload();

    for (var usr in allUsers) {
      if (usr.id == userID) {
        selectedUser = usr;
      }
    }
    layCtr.seenMessages = sharedPrefs!.getInt('${selectedUser.id}')??0;

    print('## selected user <${userID}>');
    update();

  }

  Future<void> refreshUsers() async {
    print('## refreshing all users ...');

    authCtr.refreshCuser(); // refresh myself
    allUsers = await getAlldocsModelsFromFb<ScUser>( // refresh other users
        true, usersColl, (json) => ScUser.fromJson(json),
        localKey: '');
    selectedFriends.clear();
    myFriends.clear();
    otherFriends.clear();
    allUsers.removeWhere((user) => user.id == cUser.id);//remove myself from allUsers

    for (ScUser usr in allUsers) {
      if (cUser.friends.contains(usr.id)) {
        myFriends.add(usr);// user is in my friends list
      } else {
        otherFriends.add(usr);// user is ' NOT ' in my friends list
      }
    }
    if(selectedScreen==0) selectedFriends = myFriends;
    if(selectedScreen==1) selectedFriends = otherFriends;

    print('## all users (${allUsers.length}) // my friends (${myFriends.length}) // other friends (${otherFriends.length})');


    layCtr.update();
    authCtr.update();

  }

  removeFromFriends(ScUser usr) async {
    bool accept = await showNoHeader(txt: 'are you sure you want to remove ${usr.name} from your friends list ?',btnOkText: 'Remove');
    if(!accept) return;


    await removeElementsFromList([usr.id],'friends',cUser.id,usersCollName);//remove him from my list
    await removeElementsFromList([cUser.id],'friends',usr.id,usersCollName);//remove myself from his list
    refreshUsers();
    Future.delayed(const Duration(milliseconds: 2000), () async {
      refreshUsers();
    });


  }


  /// REQUESTS ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Future<bool> alreadySentReq() async {

    bool hasTargetId = false;
    usersColl.doc(selectedUser.id ).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> requests = documentSnapshot.get('requests');

        List<FrRequest> reqsFromMap = [];

        requests.forEach((key, req) {
          if (req is Map<String, dynamic>) {
            reqsFromMap.add(FrRequest.fromJson(req));
          }
        });


        hasTargetId = reqsFromMap.any((request) => request.senderID == cUser.id);

      }

        });


    return hasTargetId;


  }
  sendRequest()async{



    if(cUser.friends.contains(selectedUser.id)){
      showTos('You Are already a friend to this user',color: Colors.black87);
      return;
    }

    if(await alreadySentReq()){
      showTos('You already sent a friend request to this user',color: Colors.black87);
      return;
    }

    bool accept = false;
     accept = await showNoHeader(txt: 'are you sure you want to send a friend request to "${selectedUser.name}" ?',btnOkText: 'Send Request');
    if(!accept) {
      return;
    }



    try{
      String specificID = Uuid().v1();
      FrRequest newReq = FrRequest(
        id: specificID,
        senderID: cUser.id,
        senderName: cUser.name,
        date: todayToString(showHoursNminutes: true),
      );

      addToMap(
        coll: usersColl,
        docID: selectedUser.id,// add req to target 'requests'
        fieldMapName: 'requests',
        mapToAdd: newReq.toJson(),

      );

      Get.back(); //hide loading
      showTos('Your friend request has been sent!',color: Colors.green);

    }catch  (err){
      print('## cant send request  : $err');
    }

  }
  acceptReq(FrRequest req) async {

    // ACCEPT
   await addElementsToList([req.senderID],'friends',cUser.id,usersCollName,canAddExistingElements: false);//add to my friends
   await addElementsToList([cUser.id],'friends',req.senderID,usersCollName,canAddExistingElements: false);//add to his friends

   //delete after accepting
     await deleteFromMap(coll: usersColl,docID: cUser.id,fieldMapName: 'requests',targetInvID: req.senderID);/// 'targetInvID' is dynamic


   refreshUsers();
   Future.delayed(const Duration(milliseconds: 2000), () async {
     refreshUsers();
   });

  }
  declineReq(FrRequest req) async {
    //delete without accepting
    await deleteFromMap(coll: usersColl,docID: cUser.id,fieldMapName: 'requests',targetInvID: req.senderID);/// 'targetInvID' is dynamic
    refreshUsers();
    Future.delayed(const Duration(milliseconds: 2000), () async {
      refreshUsers();
    });
  }


  /// MESSAGING + notif ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  late  StreamSubscription<QuerySnapshot> streamSub;
  Map<String, dynamic> messages = {};
  List<Widget> messagesWidgets = [];
  int seenMessages = 0;
  int badgeCount = 0;
  bool isTyping = false;
  TextEditingController messagingTec = TextEditingController();
   ScrollController scrollController =ScrollController();


  Widget animatedMsgList = Container();
  void scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  Future<void> getChatRoomID() async {
    selectedChatRoomID = sumOfAscii('${cUser.id}${selectedUser.id}');


    bool roomExists = await checkIfDocExists(chatRoomsCollName, selectedChatRoomID);

    if (!roomExists) {
      chatRoomsColl.doc(selectedChatRoomID).set({
        'messages': {},
        'user_0': cUser.name,
        'user_1': selectedUser.name,
        'id':selectedChatRoomID})

          .then((_) => print('## new chatRoom added with <$selectedChatRoomID> ##'))
          .catchError((error) => print('## room creation failed: $error'));
    } else {
      print('## room Already Exists');
    }
  }


  Future<void> sendMessage(String msg) async {
    if (msg.isNotEmpty) {
      messageToSend =msg;
      bool isVoice = messageToSend.contains('ttps://firebasestorage.googleapi');
      String vMsg = '${cUser.name} sent a voice message';

        chatRoomsColl.doc(selectedChatRoomID).get().then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          //get existing raters of garage
          Map<String, dynamic> messages = documentSnapshot.get('messages');

          Map<String, dynamic> msgDetails = {
            'msg': msg,
            'sender': cUser.name,
            'time': todayToString(showHoursNminutes: true),
          };

          messages[messages.length.toString()] = msgDetails;

          await chatRoomsColl.doc(selectedChatRoomID).update({
            'messages': messages,
          }).then((value) async {
            isTyping =false;
            scrollToEnd();
            sendNotifToUser(isVoice?vMsg:messageToSend);//notification send
            messageToSend ='';
            messagingTec.clear();


            update();

          }).catchError((error) async {
            print('## messages failed to sent');
          });
        }
      }
      );
    } else {
      print('## message cant be empty');
      showSnack('message cant be empty');
    }
  }

  sendNotifToUser(notifBody){
       ntfCtr.sendPushMessage(
          receiverToken:selectedUser.deviceToken,
          title: cUser.name,
          body: notifBody,
        );
        print('## notif sent to "${selectedUser.name} <${selectedUser.email}>" ....');//
  }

  streamingDoc(){
    print('##_start_chat_Streaming');

    if(selectedChatRoomID!=''){
      streamSub  = chatRoomsColl.where('id', isEqualTo: selectedChatRoomID).snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          print('##_CHANGE_chat_Streaming (new message) ');
          var chatDoc = snapshot.docs.first;
          messages.clear();
          messagesWidgets.clear();
          messages = chatDoc.get('messages');

          print('##  animatedMsgList (${messages.length}) ');


          animatedMsgList = AnimatedList(
            reverse: false,
            padding: const EdgeInsets.symmetric(vertical: 15),

           // key: Globals.audioListKey,
            initialItemCount: messages.length,
            itemBuilder: (context, i, animation) {
              print('## msg $i');
              Map<String, dynamic> msg = messages[i.toString()];
              String msgText = msg['msg'];
              bool isVoice = msgText.contains('https://firebasestorage.googleapi');
              Widget widgetToAdd;
              bool showTail = true;
              bool isSender = cUser.name == msg['sender'];
              if (i < messages.length - 1) {
                Map<String, dynamic> nextMsg = messages[(i + 1).toString()];
                if (msg['sender'] == nextMsg['sender']) {
                  showTail = false;
                }
              }

              widgetToAdd = BblChat(
                isVoice: isVoice,
                widget: FadeTransition(
                  opacity: animation,
                  child: isVoice ? AudioBubble(
                    filepath: msgText,
                    key: ValueKey(msgText),
                  ) :
                  Text(msgText,
                    style: TextStyle(
                        color: Colors.white
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                color: blueCol,
                tail: showTail,
                isSender: isSender,
              );

              return widgetToAdd;
            },
          );


          if(layCtr.seenMessages<layCtr.messages.length){
            layCtr.badgeCount=layCtr.messages.length - layCtr.seenMessages;
          }

          Future.delayed(Duration(milliseconds: 20),(){
            update();
            print('## CHATROOM updated!! ##');

          });
        });
      });
    }else{
      print('##_no_ID_to_stream_yet');
    }



  }
  deleteMessages()async{
    bool accept = await showNoHeader(txt: 'are you sure you want to remove all these messages ? ',btnOkText: 'Remove');
    if(!accept) {
      return;
    }
    updateDoc(docID: selectedChatRoomID,coll: chatRoomsColl,fieldsMap: {'messages':{}});
    showTos('all "$selectedChatRoomID" messages have been deleted',color: Colors.black87);
    //Get.back();
  }
  stopStreamingDoc(){
    streamSub.cancel();
    print('##_stop_chat_Streaming');
  }
}

