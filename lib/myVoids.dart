

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:alarm/alarm.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'admin/userDetails.dart';
import 'auth/registerSelectType.dart';
import 'auth/verifyAccount.dart';
import 'generalLayout/generalLayout.dart';
import '../main.dart';
import 'auth/login.dart';
import 'auth/register.dart';
import 'bindings.dart';
import 'models/user.dart';
import 'styles.dart';

ScUser get cUser => authCtr.cUser;
FirebaseAuth get firebaseAuth => FirebaseAuth.instance;


String appDisplayName = 'Chatting';

String snapshotErrorMsg = 'check Connexion';


CollectionReference usersColl = FirebaseFirestore.instance.collection('users');
CollectionReference chatRoomsColl = FirebaseFirestore.instance.collection('rooms');
String usersCollName = 'users';
String chatRoomsCollName = 'rooms';

CollectionReference prDataColl = FirebaseFirestore.instance.collection('prData');

DateFormat dateFormatHM = DateFormat('dd-MM-yyyy HH:mm');
DateFormat dateFormatHMS = DateFormat('dd-MM-yyyy HH:mm:ss');

double awesomeDialogWidth =90.sp;



Future<void> goLogin({String email='',String pwd=''}) async{
  await Get.offAll(() => Login(),arguments:  {'email': email,'pwd':pwd});
  authCtr.cUser = ScUser();

}

void goChooseAccountType({Map passedMap =const {}}){
  Get.to(() => RegisterChooseType(),arguments: passedMap);
}

void goRegister({required String role}){
  Get.to(()=>RegisterForm(),arguments: {'newUserRole': '$role',});

}
goVerify()  {

    Get.offAll(() => Login());
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.to(() => VerificationScreen());

    });
}

goHome(){
  Get.offAll(() => GeneralLayout(), transition: Transition.leftToRight, duration: const Duration(milliseconds: 500),);
}
openUser(){
  Get.to(()=>UserDetails());
}







//maps-lists
String getLastIndex(Map<String, dynamic> fieldMap, {String? cr,  bool afterLast = false}) {
  int newItemIndex = 0;
  Map<String, dynamic>  map = cr !=null? removeSubstringFromKeys(cr, fieldMap):fieldMap;
  if (map.isNotEmpty) {
    newItemIndex = map.keys.map((key) => int.parse(key)).reduce((value, element) => value > element ? value : element) + 0;
  }

  if (afterLast) {
    newItemIndex++;
  }
  return newItemIndex.toString();
}
Map<String, dynamic> removeSubstringFromKeys(String substring, Map<String, dynamic> originalMap) {
  Map<String, dynamic> modifiedMap = {};

  originalMap.forEach((key, value) {
    String modifiedKey = key.replaceAll(substring, '');
    modifiedMap[modifiedKey] = value;
  });

  return modifiedMap;
}



//json
printJson(json) {
  final encoder = JsonEncoder.withIndent('  '); // Set the indentation to 2 spaces
  final prettyPrintedJson = encoder.convert(json);
  print("## ##");
  debugPrint(prettyPrintedJson);
  print("## ##");
}




//date-time

bool isDateToday(String dateString) {
  // Create a DateFormat instance to parse the date string

  // Parse the date string to a DateTime object
  DateTime date = dateFormatHM.parse(dateString);

  // Get the current date
  DateTime currentDate = DateTime.now();

  // Compare the day of the parsed date with the day of the current date
  return date.day == currentDate.day && date.month == currentDate.month && date.year == currentDate.year;
}
String getMonthName(int monthNumber) {
  switch (monthNumber) {
    case 1:
      return "January";
    case 2:
      return "February";
    case 3:
      return "March";
    case 4:
      return "April";
    case 5:
      return "May";
    case 6:
      return "June";
    case 7:
      return "July";
    case 8:
      return "August";
    case 9:
      return "September";
    case 10:
      return "October";
    case 11:
      return "November";
    case 12:
      return "December";
    default:
      return "Unknown";
  }
}
String getWeekdayName(int weekdayIndex) {
  switch (weekdayIndex) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return '';
  }
}
String todayToString({bool showDay = false, bool showHoursNminutes = false, bool showSeconds = false}) {
  //final formattedStr = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy, ' ', HH, ':' nn]);
  //DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");

  if (showDay) {
    dateFormat = DateFormat("dd-MM-yyyy");
  }
  if (showHoursNminutes) {
    dateFormat = DateFormat("dd-MM-yyyy HH:mm");
  }
  if (showSeconds) {
    dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
  }
  return dateFormat.format(DateTime.now());
}


String sumOfAscii(String x) {
  int sum = 0;

  // Iterate through each character in the string
  for (int i = 0; i < x.length; i++) {
    // Get the ASCII value of the character at index i
    int asciiValue = x.codeUnitAt(i);

    // Add the ASCII value to the sum
    sum += asciiValue;
  }

  return sum.toString();
}


showShouldVerify({bool isLoadingScreen =false}) {
  return AwesomeDialog(
    dialogBackgroundColor: dialogBgCol,
    width: awesomeDialogWidth,

    autoDismiss: true,
    context: navigatorKey.currentContext!,

    showCloseIcon: true,
    dismissOnTouchOutside: true,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.info,
    title: 'Verification'.tr,
    desc: 'Your email is not verified\nVerify now?'.tr,
    btnOkText: 'Verify'.tr,
    btnCancelText: 'cancel'.tr,
    btnOkColor: Colors.blue,
    btnOkIcon: Icons.send,
    btnOkOnPress: ()async {
      //await goLogin(email: authCtr.cUser.email,pwd: authCtr.cUser.pwd);
      goVerify();
    },
    // btnCancelOnPress: (){
    //   authCtr.signOut();
    //   goLogin(email: authCtr.cUser.email,pwd: authCtr.cUser.pwd);
    // },
    onDismissCallback: (_){
      //authCtr.signOut(shouldGoLogin: true);
      //goLogin();
      print('## verification dialog Closed');


    },
    padding: EdgeInsets.symmetric(vertical: 20.0),
  ).show();
}



//dialogs
 showAnimDialog(Widget? child, {DialogTransitionType? animationType, int? milliseconds}) {
  showAnimatedDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return child ?? Container();
    },
    animationType: animationType ?? DialogTransitionType.slideFromTop,
    curve: Curves.fastOutSlowIn,
    duration: Duration(milliseconds: milliseconds ?? 500),
  );
}
//aesome dialogs
showVerifyConnexion(){
  AwesomeDialog(
    context: navigatorKey.currentContext!,
    width: awesomeDialogWidth,

    dialogBackgroundColor: dialogBgCol,
    autoDismiss: true,
    dismissOnTouchOutside: true,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.info,
    btnOkColor: Colors.blueAccent,
    // btnOkColor: yellowColHex

    //showCloseIcon: true,
    padding: EdgeInsets.symmetric(vertical: 15.0),
    titleTextStyle: TextStyle(fontSize: 17.sp, color: dialogAweInfoCol),
    descTextStyle: TextStyle(fontSize: 15.sp,color: dialogDescCol),
    buttonsTextStyle: TextStyle(fontSize: 14.sp),

    title: 'Failed to Connect',
    desc: 'please verify network',

    btnOkText: 'Retry',
    btnOkOnPress: () {},
    onDismissCallback: (type) {
      print('Dialog Dissmiss from callback $type');
    },
    //btnOkIcon: Icons.check_circle,
  ).show();
}
showLoading({required String text}) {
  return AwesomeDialog(
    dialogBackgroundColor: dialogBgCol,
    width: awesomeDialogWidth,
    dismissOnBackKeyPress: true,
    //change later to false
    autoDismiss: true,
    customHeader: Transform.scale(
      scale: .7,
      child: const LoadingIndicator(
        indicatorType: Indicator.ballClipRotate,
        colors: [loadingDialogCol],
        strokeWidth: 10,
      ),
    ),
    titleTextStyle: TextStyle(fontSize: 18.sp, color: dialogTitleCol),
    descTextStyle: TextStyle(fontSize: 16.sp, height: 1.5,color: normalTextCol),



    buttonsTextStyle: TextStyle(fontSize: 15.sp),
    context: navigatorKey.currentContext!,
    dismissOnTouchOutside: false,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dialogType: DialogType.noHeader,

    //padding: EdgeInsets.all(8),


    title: text,
    desc: 'Please wait',
  ).show();
}
Future<bool> showNoHeader({String? txt, String? btnOkText, Color btnOkColor = errorColor, IconData? icon}) async {
  bool shouldDelete = false;

  await AwesomeDialog(
    context: navigatorKey.currentContext!,
    width: awesomeDialogWidth,

    dialogBackgroundColor: dialogBgCol,
    //default :themeData
    autoDismiss: true,
    isDense: true,
    dismissOnTouchOutside: true,
    showCloseIcon: false,
    headerAnimationLoop: false,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    btnCancelIcon: Icons.arrow_back_ios_sharp,
    btnCancelColor: Colors.transparent,
    btnOkIcon: icon ?? Icons.delete,
    //btnOkColor: btnOkColor ?? Colors.red,

    btnCancel: TextButton(
      style: borderBtnStyle(),
      onPressed: () {
        shouldDelete = false;
        Get.back();
      },
      child: Text(
        "Cancel",
        style: TextStyle(color: dialogBtnCancelTextCol),
      ),
    ),
    btnOk: TextButton(
      style: filledBtnStyle(),
      onPressed: () {
        shouldDelete = true;
        Get.back();
      },
      child: Text(
        btnOkText ?? 'delete',
        style: TextStyle(color: dialogBtnOkTextCol),
      ),
    ),
    titleTextStyle: TextStyle(fontSize: 18.sp, color: dialogTitleCol),
    descTextStyle: TextStyle(fontSize: 16.sp),
    buttonsTextStyle: TextStyle(fontSize: 15.sp),

    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    // texts
    title: 'Verification',
    desc: txt ?? 'Are you sure you want to delete this image',
    btnCancelText: 'cancel',
    btnOkText: btnOkText ?? 'delete',

    // buttons functions
    btnOkOnPress: () {
      shouldDelete = true;
    },
    btnCancelOnPress: () {
      shouldDelete = false;
    },
  ).show();
  return shouldDelete;
}


showTos(txt, {Color color = Colors.black87, bool withPrint = false}) async {
  Fluttertoast.showToast(
      msg: txt,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
  if (withPrint) print(txt);
}
showSnack(txt, {Color? color}) {
  Get.snackbar(
    txt,
    '',
    messageText: Container(),
    colorText: Colors.white,
    backgroundColor: color ?? snackBarNormal,
    snackPosition: SnackPosition.BOTTOM,
  );
}


//network
Future<bool> canConnectToInternet() async {
  bool canConnect = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    /// connected to internet
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      //is connected
      canConnect = true;
    }
    /// failed to connect to internet
  } on SocketException catch (_) {
    // not connected

  }
  return canConnect;
}

Future<PickedFile>  showImageChoiceDialog()async  {

  Future<PickedFile> selectImage(ImageSource source) async {
    final pickedFile = await ImagePicker().getImage(
      source: source,
    );
    Get.back();
    return pickedFile!;
  }

  PickedFile? image ;

  await  showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) {
        return AlertDialog(
          backgroundColor: dialogBgCol,
          title:  Text(
            "Choose source",
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Divider(
                  height: 1,
                ),
                ListTile(
                  onTap: () async{
                    image = await selectImage(ImageSource.gallery);
                  },
                  title: Text("Gallery"),
                  leading: const Icon(
                    Icons.image,
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                ListTile(
                  onTap: () async {
                    image = await selectImage(ImageSource.camera);
                  },
                  title: Text("Camera"),
                  leading: const Icon(
                    Icons.camera,
                  ),
                ),
              ],
            ),
          ),
        );
      });


  return image!;

}

