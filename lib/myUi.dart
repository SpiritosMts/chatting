
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatting/bindings.dart';
import 'package:chatting/models/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:badges/badges.dart' as badges;

import 'firebaseVoids.dart';
import 'main.dart';
import 'models/user.dart';
import 'myVoids.dart';
import 'styles.dart';

/// ****** THIS APP WIDGETS **************///////////////////////////////////////////////

ylwDivider() {
  return  Padding(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
    child: Divider(thickness: 2,color: normalTextCol.withOpacity(0.3)),
  );
}


userCard(ScUser user,i,{bool tappable = true,bool canDelete = true,    Function()? btnOnPress,}){
  double bottomProdName = 9;
  double bottomProdBuy = 6;

  return GestureDetector(
    onTap: () {
      if(tappable){
        btnOnPress!();
        layCtr.selectUser(user.id);
        if(cUser.isAdmin){
          openUser();
        }else{
          if(user.friends.contains(cUser.id)){//is friend
            openUser();

          }else{
            layCtr.sendRequest();
          }
        }
      }
    },
    child: Container(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: productBorderCol, width: 1.5), borderRadius: BorderRadius.circular(13)),
        color: productCardColor,
        child: Stack(
          children: [
            Container(
              padding : const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// image + name + buy + sell
                  Row(
                    children: [
                      /// IMAGE
              Image.asset(
                user.role == authCtr.roles[0] ? 'assets/images/student.png':'assets/images/teacher.png',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              )    ,
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(bottom: bottomProdName,top: 5),
                            child: Text('${user.name}',style: TextStyle(
                                color: normalTextCol,
                                fontWeight: FontWeight.w400,
                                fontSize: 17
                            )),
                          ),

                          ///email
                          Padding(
                            padding:  EdgeInsets.only(bottom: bottomProdBuy),
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(children: [
                                if (true)
                                  TextSpan(
                                      text: 'email:',
                                      style: GoogleFonts.almarai(
                                        height: 1,
                                        textStyle: TextStyle(color: transparentTextCol, fontSize: 13, fontWeight: FontWeight.w500),
                                      )),
                                TextSpan(
                                    text: '  ${user.email}',
                                    style: GoogleFonts.almarai(
                                      height: 1,
                                      textStyle: TextStyle(
                                          color: blueCol,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    )),

                              ]),
                            ),
                          ),
                          ///phone
                          Padding(
                            padding:  EdgeInsets.only(bottom: bottomProdBuy),
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(children: [
                                if (true)
                                  TextSpan(
                                      text: 'phone:',
                                      style: GoogleFonts.almarai(
                                        height: 1,
                                        textStyle: TextStyle(color: transparentTextCol, fontSize: 13, fontWeight: FontWeight.w500),
                                      )),
                                TextSpan(
                                    text: '  ${user.phone}',
                                    style: GoogleFonts.almarai(
                                      height: 1,
                                      textStyle: TextStyle(
                                          color: blueCol,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    )),

                              ]),
                            ),
                          ),
                          ///joined
                         user.role==authCtr.roles[0] ? Padding(
                            padding:  EdgeInsets.only(bottom: bottomProdBuy),
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(children: [
                                if (true)
                                  TextSpan(
                                      text: 'grade:',
                                      style: GoogleFonts.almarai(
                                        height: 1,
                                        textStyle: TextStyle(color: transparentTextCol, fontSize: 13, fontWeight: FontWeight.w500),
                                      )),
                                TextSpan(
                                    text: '  ${user.grade}',
                                    style: GoogleFonts.almarai(
                                      height: 1,
                                      textStyle: TextStyle(
                                          color: blueCol,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    )),

                              ]),
                            ),
                          ):Padding(
      padding:  EdgeInsets.only(bottom: bottomProdBuy),
      child: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(children: [
          if (true)
            TextSpan(
                text: 'speciality:',
                style: GoogleFonts.almarai(
                  height: 1,
                  textStyle: TextStyle(color: transparentTextCol, fontSize: 13, fontWeight: FontWeight.w500),
                )),
            TextSpan(
              text: '  ${user.speciality}',
              style: GoogleFonts.almarai(
                height: 1,
                textStyle: TextStyle(
                    color: blueCol,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              )),
        ]),
      ),
    ),
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
           if(canDelete && cUser.friends.contains(user.id)) Positioned(
              top: -4,
              right: -4,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.redAccent,
                splashRadius: 1,
                onPressed: () async {

                  layCtr.removeFromFriends(user);
                },
              ),
            ),

          ],
        ),
      ),
    ),
  );

}


requestCard(FrRequest req,i,{bool tappable = true,    Function()? btnOnPress,}){
  double bottomProdName = 9;
  double bottomProdBuy = 6;
  return GestureDetector(

    onTap: () {
      if(tappable){
        //btnOnPress!();

      }
    },
    child: Container(
      // padding :  EdgeInsets.symmetric(horizontal: horizontalPadd,vertical: verticalPadd),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: productBorderCol, width: 1.5), borderRadius: BorderRadius.circular(13)),
        color: productCardColor,
        child: Stack(
          children: [
            Container(
              padding : const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// image + name + buy + sell
                  Row(
                    children: [
                      /// IMAGE
                      Container(
                        width:60,

                          child: monthSquare(req.date,withSec: false))    ,
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(bottom: bottomProdName,top: 5),
                            child: Text('${req.senderName}',style: TextStyle(
                                color: normalTextCol,
                                fontWeight: FontWeight.w400,
                                fontSize: 17
                            )),
                          ),

                          ///email
                          Padding(
                            padding:  EdgeInsets.only(bottom: bottomProdBuy),
                            child: RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(children: [
                                if (true)
                                  TextSpan(
                                      text: 'Would like to send you a ',
                                      style: GoogleFonts.almarai(
                                        height: 1,
                                        textStyle: TextStyle(color: transparentTextCol, fontSize: 13, fontWeight: FontWeight.w500),
                                      )),
                                TextSpan(
                                    text: 'friend request',
                                    style: GoogleFonts.almarai(
                                      height: 1,
                                      textStyle: TextStyle(
                                          color: blueCol,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    )),

                              ]),
                            ),
                          ),
                          /// buttons
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                //cancel
                                TextButton(
                                  style: borderBtnStyle(),
                                  onPressed: () {
                                    layCtr.declineReq(req);
                                  },
                                  child: Text(
                                    "Decline",
                                    style: TextStyle(color: dialogBtnCancelTextCol),
                                  ),
                                ),
                                SizedBox(width: 15,),
                                //add
                                TextButton(
                                  style: filledBtnStyle(),
                                  onPressed: () async {
                                    layCtr.acceptReq(req);
                                  },
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(color: dialogBtnOkTextCol ),
                                  ),
                                ),
                              ],
                            ),
                          ),


                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
             if(false) Positioned(
              top: 7,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '# ${i+1}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.orange),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );



}



/// ****** DEFAULT WIDGETS **************///////////////////////////////////////////////


Widget customTextField(
    {Color? color,
    bool enabled = true,
    void Function(String)? onChanged,
    TextInputType? textInputType,
    String? hintText,
    String? labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscure = false,
    bool isPwd = false,
    bool isDense = false,
List<TextInputFormatter>? inputFormatters,
    Function()? onSuffClick,
    IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: Container(
      child: TextFormField(
        onChanged: onChanged,
        controller: controller,
        keyboardType: textInputType,
        textInputAction: TextInputAction.done,
        obscureText: obscure,
        inputFormatters: inputFormatters,


        ///pwd

        enabled: enabled,
        style: TextStyle(color: dialogFieldWriteCol, fontSize: 14.5),
        validator: validator,
        decoration: InputDecoration(
          //enabled: false,

          isDense: isDense,
          alignLabelWithHint: false,
          filled: false,
          isCollapsed: false,

          focusColor: color ?? Colors.white,
          fillColor: color ?? Colors.white,
          hoverColor: color ?? Colors.white,
          contentPadding: const EdgeInsets.only(bottom: 0, right: 20, top: 0),
          suffixIconConstraints: BoxConstraints(minWidth: 50),
          prefixIconConstraints: BoxConstraints(minWidth: 50),
          prefixIcon: Icon(
            icon,
            color: dialogFieldIconCol,
            size: 22,
          ),
          suffixIcon: isPwd
              ? IconButton(

                  ///pwd

                  icon: Icon(
                    !obscure ? Icons.visibility : Icons.visibility_off,
                    color: dialogFieldIconCol,
                  ),
                  onPressed: onSuffClick)
              : null,
          border: InputBorder.none,
          disabledBorder: InputBorder.none,

          hintText: hintText ?? '',
          hintStyle: TextStyle(color: dialogFieldHintCol, fontSize: 14.5),

          labelText: labelText!,
          labelStyle: TextStyle(color: dialogFieldLabelCol, fontSize: 14.5),

          errorStyle: TextStyle(color: dialogFieldErrorUnfocusBorderCol.withOpacity(.9), fontSize: 12, letterSpacing: 1),

          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: dialogFieldEnableBorderCol)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: dialogFieldDisableBorderCol)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: dialogFieldErrorUnfocusBorderCol)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide(color: dialogFieldErrorFocusBorderCol)),
        ),
      ),
    ),
  );
}

String getDayString(String time) {
  DateTime parsedDateTime = dateFormatHM.parse(time);
  String day = parsedDateTime.day.toString();

  return day;
}

getMonthString(String time) {
  return getMonthName(dateFormatHM.parse(time).month);
}

getYearString(String time) {
  return dateFormatHM.parse(time).year.toString();
}

elementNotFound(text,{double? top}){
return Padding(
  padding: EdgeInsets.only(top: top?? 35.h),
  child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.indieFlower(
    textStyle:  TextStyle(
        fontSize: 23  ,
        color: elementNotFoundColor,
        fontWeight: FontWeight.w700
    ),
  )),
);
}

Widget monthSquare(String date,{bool withSec = false}) {
  DateTime dateTime;
  if(withSec){
    dateTime = dateFormatHMS.parse(date);//withSec = true
  }else{
     dateTime = dateFormatHM.parse(date);//withSec = false
  }

  String day = dateTime.day.toString();
  String monthName = getMonthName(dateTime.month);
  String weekDayName = getWeekdayName(dateTime.weekday);
  String weekDay3Name = DateFormat('EEE').format(dateTime);
  String time = DateFormat("HH:mm").format(dateTime);

  return Container(
    // color: Colors.greenAccent,

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // week
          Text(
            weekDay3Name,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              height: 1,
              color: squareDateCol,
            ),
          ),
          SizedBox(height: 2),
          // month number
          Container(
            //color:Colors.redAccent,
            width: 40,
            height: 40,
            child: Text(
              day,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                height: 0,
                fontWeight: FontWeight.bold,
                color: squareDateCol,
              ),
            ),
          ),
          SizedBox(height: 2),

          // time
          Text(
            time,//15:06
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              height: 0,
              color: squareDateCol,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget indexSquare(String time, String index, verified) {
  String day = dateFormatHM.parse(time).day.toString();
  String monthName = getMonthName(dateFormatHM.parse(time).month);
  String timeString = DateFormat("HH:mm").format(dateFormatHM.parse(time));

  return Container(
    width: 70,
    height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      //color: Colors.white,
      // border: Border.all(
      //   color: Colors.white,
      //   width: 2,
      // ),
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Num°',
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              height: 0.5,
              color: Colors.white,
            ),
          ),
          Text(
            index,
            maxLines: 1,
            style: TextStyle(
              fontSize: 26,
              height: 1.3,
              fontWeight: FontWeight.bold,
              color: verified ? Colors.greenAccent : Color(0xFFFFF66B).withOpacity(.8),
            ),
          ),
          Text(
            timeString,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              height: 1,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget backGroundTemplate({Widget? child}) {
  return Container(
    //alignment: Alignment.topCenter,
    width: 100.w,
    height: 100.h,
    decoration: const BoxDecoration(
        // image: DecorationImage(
        //   //image: AssetImage("assets/images/bg.png"),
        //   image: NetworkImage("https://img.freepik.com/premium-vector/general-view-factorys-industrial-premises-from-inside_565173-3.jpg"),
        //   fit: BoxFit.cover,
        // ),
        ),
    child: child,
  );
}

Widget customButton(
    {bool reversed = false,
    bool disabled = false,
    Function()? btnOnPress,
    Widget? icon,
    String textBtn = 'button',
    double btnWidth = 200,
    Color? fillCol,
    Color? borderCol}) {
  List<Widget> buttonItems = [
    icon!,

    SizedBox(width: 10),
    Text(
      textBtn,
      style: TextStyle(
        color: btnTextCol,
        fontSize: 16,
      ),
    ),
    //Icon(Icons.send_rounded,  color: Colors.white,),
  ];

  return SizedBox(
    width: btnWidth,
    child: ElevatedButton(
      onPressed: btnOnPress!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: reversed ? buttonItems.reversed.toList() : buttonItems,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: !disabled ? fillCol ?? btnFillCol : disabledBtnFillCol,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
          color: !disabled ? borderCol ?? btnBorderCol : disabledBtnBorderCol,
          width: 2,
        ),
      ),
    ),
  );
}


Widget animatedText(String txt, double textSize, int speed) {
  return SizedBox(
    height: 40,
    child: AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(txt,
            textStyle: GoogleFonts.indieFlower(
              textStyle: TextStyle(fontSize: textSize, color: animatedTextCol, fontWeight: FontWeight.w800),
            ),
            speed: Duration(
              milliseconds: speed,
            )),
      ],
      onTap: () {
        //debugPrint("Welcome back!");
      },
      isRepeatingAnimation: true,
      totalRepeatCount: 40,
    ),
  );
}
