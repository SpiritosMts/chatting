import 'package:chatting/generalLayout/generalLayoutCtr.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:badges/badges.dart' as badges;

import '../bindings.dart';
import '../styles.dart';
import 'chatRoom.dart';


class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LayoutCtr>(
        initState: (_){
           Future.delayed(const Duration(milliseconds: 400), () async {

             await layCtr.getChatRoomID();/// GET ROOM ID
            // layCtr.streamingDoc();///   START

           });


        },
        dispose: (_){
          Future.delayed(const Duration(milliseconds: 50), () {
            layCtr.refreshUsers();
           // layCtr.stopStreamingDoc();///   STOP
          });

        },
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: appBarBgColor,
            title: Text(
              '${layCtr.selectedUser.name}\'s Info',style: TextStyle(
              fontWeight: FontWeight.w500,
              color: appBarTitleColor,
             ),
            ),
            bottom: appBarUnderline(),
            leading:IconButton(
              icon: Icon(Icons.arrow_back_outlined,color: appBarNotificationBellColor,),
              onPressed: () {
                Get.back();
                },
            ),
            actions: [

                //messages
               if(true) badges.Badge(
                  showBadge: layCtr.badgeCount > 0 ? true:false,
                  badgeStyle: badges.BadgeStyle(),
                  badgeContent: Text(layCtr.badgeCount.toString(),style: TextStyle(color: Colors.white)),
                  position: badges.BadgePosition.custom(top: 0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(()=>ClubMessages());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11.0),
                      child: Center(
                        child: Icon(
                          Icons.message,
                          color: appBarButtonsCol,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
          ),

          body: Container(
            color: bgCol,
            child:  Padding(
              padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                layCtr.selectedUser.name, // Replace with actual name
                style: TextStyle(
                  color: normalTextCol,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40.0),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// IMAGE
                    RandomAvatar(
                      DateTime.now().toIso8601String(),
                      height: 80,
                      width: 80,
                    ),
                    SizedBox(width: 20.0),
                    //friends
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Friends:',
                            style: TextStyle(
                              fontSize: 23.0,
                              color: normalTextCol.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          RichText(
                            textAlign: TextAlign.start,
                            softWrap: true,
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${layCtr.selectedUser.friends.length}',
                                style: GoogleFonts.almarai(
                                  fontSize: 26.sp,
                                  color: blueCol.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' '),
                             if(false) TextSpan(
                                  text: '  Pts',
                                  style: GoogleFonts.almarai(
                                    height: 1,
                                    textStyle:
                                    const TextStyle(color: transparentTextCol, fontSize: 20, fontWeight: FontWeight.w500),
                                  )),
                            ]),
                          ),
                          SizedBox(height: 5.0),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /// about
//               if(false) Padding(
//                 padding:  EdgeInsets.only(bottom: 10,left: 20,top: 10),
//                 child: RichText(
//                   overflow: TextOverflow.ellipsis,
// maxLines: 5,
//                   textAlign: TextAlign.start,
//                   text: TextSpan(children: [
//                     if (true)
//                       TextSpan(
//                           text: 'about:',
//                           style: GoogleFonts.almarai(
//                             height: 1,
//                             textStyle: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
//                           )),
//                     TextSpan(
//                         text: '  ${layCtr.selectedUser.desc}',
//
//                         style: GoogleFonts.almarai(
//                           height: 1.2,
//                           textStyle: TextStyle(
//                               color: Colors.black45,
//                               fontSize: 17,
//                               fontWeight: FontWeight.w400),
//                         )),
//
//                   ]),
//                 ),
//               ),

              SizedBox(
                height: 25,
              ),
// if(false)...[
//               CustomDivider(
//                 text: '  Events (${layCtr.selectedEvents.length}) ',
//               ),
//               SizedBox(height: 20,),
//               layCtr.selectedEvents.isEmpty?Padding(
//                   padding: const EdgeInsets.only(top: 100),
//                   child: Center(child: Text('No events to show', style: TextStyle(
//                       fontSize: 17
//                   ),),)): Expanded(
//                 child: Container(
//                   child: ListView.builder(
//                     //  physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.only(
//                         top: 10,
//                         bottom: 20,
//                         right: 0,
//                         left: 0,
//                       ),
//                       //itemExtent: 100,// card height
//                       itemCount: layCtr.selectedEvents.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         ClubEvent ev = (layCtr.selectedEvents[index]);
//                         return eventCard(ev, index);
//                       }),
//                 ),
//               ),]
            ],
          ),
        ),
          ),
        );
      }
    );
  }
}

class CustomDivider extends StatelessWidget {
  final String text;

  const CustomDivider({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.orange,
            height: 3,
            thickness: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.orange,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.orange,
            height: 3,
            thickness: 2,

          ),
        ),
      ],
    );
  }
}
