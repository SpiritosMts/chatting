import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../bindings.dart';
import '../firebaseVoids.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';

// ther is 2 verificatioùn methods
// 1 /in user credential (authentication tab in fb has '_auth.currentUser.emailVerified' bool ) which i check every 7 sec in verification screen
// 2 /in user doc (firestore tab in fb 'cUser.verified' bool) ,i ckeck this every time user connect
// we can access all user data even his not verified

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer? _verificationTimer;
  Timer? _resendTimer;
  bool _resendAvailable = false;
  int _canResendEvery = 30;
  DateTime? lastResendTime; // Variable to track the last resend time

  @override
  void initState() {
    super.initState();

    _sendVerificationEmail();
    _startVerificationTimer();// auto verif check
    _startResendTimer();// manual resend verif email
  }

  int calculateRemainingTime() {
    if (lastResendTime != null) {
      int elapsedSeconds = DateTime.now().difference(lastResendTime!).inSeconds;
      return _canResendEvery - elapsedSeconds;
    }
    return _canResendEvery;
  }

  void _startVerificationTimer() {
    _verificationTimer = Timer.periodic(Duration(seconds: 7), (timer) {
      _checkEmailVerified();
    });
  }


  void _startResendTimer() {
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _resendAvailable = calculateRemainingTime() <= 0;
      });
    });
  }


  Future<void> _sendVerificationEmail() async {
    User? user = firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {//not verified yet
      setState(() {
        _resendAvailable = false;
        lastResendTime = DateTime.now();

      });
      ///send verification Email
      await user.sendEmailVerification().then((value) {
        showTos('Verification email sent');
      }).catchError((e){
        //showTos("Failed to send verification email: $e");
        showTos("Failed to send verification email: Try again later");

      });
    }else{//already verified
      verifyUserAccount();

    }
  }

  void  verifyUserAccount(){

    updateFieldInFirestore(usersCollName,cUser.id,'verified',true,addSuccess: () async {
      print('### Account verified in FB');
      //authCtr.refreshCuser();
      User? user = firebaseAuth.currentUser;

      if(user!=null) {
        authCtr.signOutUser();
      }
      // showSuccess(
      //     sucText: 'Congratulations! Your account has been verified. Welcome aboard!'.tr,
      //     btnOkPress: () {
      //       goLogin(email: authCtr.cUser.email,pwd: authCtr.cUser.pwd);
      //     });
      showTos('Congratulations! Your account has been verified. Welcome aboard!'.tr);

      await goLogin(email: authCtr.cUser.email);
    });

  }

  void _onResendButtonPressed() {
    if (_resendAvailable) {
      _sendVerificationEmail();

    }else{
      showTos('You can resend verification email after ${calculateRemainingTime()} seconds.');
    }
  }

  Future<void> _checkEmailVerified() async {
    User? user = firebaseAuth.currentUser;
    await user?.reload();
    user = firebaseAuth.currentUser;
    if (user != null && user.emailVerified) {//verified
     // _verificationTimer?.cancel(); // Stop the timer if email is verified

      // verif user in firestore
      verifyUserAccount();


    }else{//not verified

    }
  }

  @override
  void dispose() {
    _verificationTimer?.cancel(); // Cancel timer to avoid memory leaks
    _resendTimer?.cancel(); // Cancel timer to avoid memory leaks
    print('## timers cancelled');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),

            // logo Image
            Image.asset(
              'assets/images/icons/mail verif.png',
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
            SizedBox(height: 40),

            animatedText('Waiting for Email Verification . . . '.tr,22 ,120),
           // Text('time remaining : ${calculateRemainingTime()}'),
            SizedBox(height: 20),
            Center(
              child:  Container(
                //padding: EdgeInsets.all(40.0),
                  //padding: EdgeInsets.all(30),
                  child: Text('${authCtr.cUser.email}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        color: logoBlue80
                      //height: 5,

                    ),

                  )
              ),
            ),
            //SizedBox(height: 20),

           // CircularProgressIndicator(),
            SizedBox(height: 50),

            ///resend
            customButton(
              disabled: !_resendAvailable,
              reversed: true,
              btnOnPress: ()  {
                _onResendButtonPressed();
              },
              textBtn: 'Resend'.tr,

              btnWidth: 140,
              icon: Icon(
                LineIcons.arrowCircleRight,
                color: btnIconCol,
                size: 19,
              ),

            ),
          ],
        ),
      ),
    );
  }
}
