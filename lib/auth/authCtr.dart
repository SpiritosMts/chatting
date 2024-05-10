

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../main.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../privateData.dart';
import '../bindings.dart';
import '../firebaseVoids.dart';
import '../models/user.dart';
import '../myVoids.dart';





class AuthController extends GetxController {
  static AuthController instance = Get.find();
  ScUser cUser = ScUser();
  late Rx<User?> firebaseUser;
  late  Worker worker;
  List<String> roles = [
    "Student",
    "Teacher",
  ];

  late  StreamSubscription<QuerySnapshot> streamSub;



  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 0), () {
      //listenToChat();
      //listenToAppoi();
      //streamingDoc(usersColl,'Y1nMifjP7ga7lTNW4pZd');
    });
  }
  @override
  void onClose() {
    super.onClose();


  }

  /// ************************************************************************************************************







  void fetchUser() {
    print('## AuthController fetching User ...');


    firebaseUser = Rx<User?>(firebaseAuth.currentUser);


    // its not called and not being disposed so if we click ggl signIn it detect a google user cz its always listening and give widget error
    // googleSignInAccount.bindStream(googleSign.onCurrentUserChanged);
    // workerGgl = ever(googleSignInAccount, _setInitialScreenGoogle);

    // this detect google and not-google users
    firebaseUser.bindStream(firebaseAuth.userChanges());
    worker = ever(firebaseUser, _setInitialScreen);

  }


  _setInitialScreen(User? user) async {
    worker.dispose();

    if (user == null) {//no user found (not already signed in)
      print('## no user already registered => go login_page');
      await goLogin();


    } else {//user found (already signed in)


      if(user.email == null || user.email == '') {
        print('## user already logged in but email is <NULL>');
        authCtr.signOutUser(shouldGoLogin: true);//user already logged in but email is <NULL> or empty
        return;
      }

      print('## user<${user.email}> already signed in =>try go home_page if its verified');
      await getUserInfoByEmail(user.email,isLoadingScreen: true).then((value) {//while fetching...
      });

    }
  }

  /// ************************ VERIFICATION CHECK ****************************************
  checkVerification({bool isGoogle =false,bool isLoadingScreen =false,bool updateIsLoggedIn =false}) async {
    print('## checking account verification state ...');
    bool accountVerified = cUser.verified || isGoogle;

    if (accountVerified) {//verified
      print('## account<${cUser.email}> verified ');

      //hace access
      ntfCtr.streamUserToken();//get & start token streaming
      showTos('Welcome ${cUser.name}',color: Colors.green);
      goHome();

    }
    else {//not verified
      print('## account<${cUser.email}> NOT verified ');

      if(isLoadingScreen){// detect not verified => while fetching
        await goLogin(email: cUser.email,);
        signOutUser();//user already signed in but not verified

      }else{// detect not verified => while pressing login
        showShouldVerify();

      }

    }
  }



  ///  EMAIL 'signIn' + 'signUp'
  signIn(String _email, String _password,  {Function()? onSignIn}) async {
    try {
      print('## Email signing In ...');

      //try signIn
      await firebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      ).then((value)  {//account found
        onSignIn!();//imn parameter
        print('## user credential available => ${value.user.toString()}');
      });

      // signIn error
    } on FirebaseAuthException catch (e) {
      //Get.back();

      print('## error signIn, msg:<${e.message}>, code:<${e.code}>, credential:<${e.credential}>');
      if (e.code == 'user-not-found') {
        showTos('User not found'.tr);
      } else if (e.code == 'wrong-password') {
        showTos('Wrong password'.tr);
      }
      else{
        showTos('There was an issue verifying the information you provided.'.tr);
      }
    } catch (e) {
      //Get.back();
      print('## catch err in signIn user_auth: $e');
    }
  }
  signUp(String _email, String _password, {Function()? onSignUp}) async {
    try {
      print('## Email signing In ...');

      await firebaseAuth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      )
          .then((value) {
        onSignUp!();
      });

    } on FirebaseAuthException catch (e) {
      print('## error signUp, msg:<${e.message}>, code:<${e.code}>, credential:<${e.credential}>');
      //Get.back();

      if (e.code == 'weak-password') {
        showTos('Weak password'.tr);
      } else if (e.code == 'email-already-in-use') {
        showTos('Email already in use'.tr);
      }
      else{
        showTos('Please verify your credentials and try again.'.tr);
      }
    } catch (e) {
      //Get.back();

      print('## catch err in signUp user_auth: $e');
    }
  }
  /// ///////




  /// Forgot Pwd
  void ResetPss(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email).then((uid) {
        showTos('A password reset link has been sent to your email address.'.tr);
        //Get.back();
      });

    } on FirebaseAuthException catch (e) {
      print('## error resetPwd, msg:<${e.message}>, code:<${e.code}>, credential:<${e.credential}>');

      showTos('connection error'.tr);

    }catch (e) {
      //Get.back();

      print('## catch err in resetPwd user_auth: $e');
    }
  }

  void signOutUser({bool shouldGoLogin = false,bool dbLogOut = false,}) async {
    try {
      print('## signing Out . . . ');

      // Sign out from Firebase, Google, and Facebook
      final signOutTasks = [
         firebaseAuth.signOut(),
        // googleSignIn.signOut(),
        // facebookAuth.logOut(),
      ];

      // Wait for all sign-out tasks to complete
      await Future.wait(signOutTasks);

      // If dbLogOut is true, update isLoggedIn field in Firestore
      if (dbLogOut) {
        updateFieldInFirestore(
          usersCollName,
          authCtr.cUser.id,
          'isLoggedIn',
          false,
          addSuccess: () async {
            sharedPrefs!.setBool('localLogin', false);


          },
        );
      }
      if (shouldGoLogin) {
        await goLogin(email: authCtr.cUser.email);
      }
      // Reset the user state
      authCtr.cUser = ScUser();
      print('## signed Out ');



    } catch (e) {
      print('## Sign-out failed: $e');
    }
  }


  /// refresh user props from database
  refreshCuser() async {
    print('## refreshing cUser ...');
    getUserInfoByEmail(cUser.email,withVerif: false);//refresh

  }


  /// GET-USER-INFO VY PROP
  Future<void> getUserInfoByEmail(userEmail,{bool isLoadingScreen = false,bool withVerif = true}) async {
    print('## getting user info by email < $userEmail > . ..');

    await usersColl.where('email', isEqualTo: userEmail).get().then((event) async {
      var userDoc = event.docs.single;
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>; // Explicit casting
        cUser = ScUser.fromJson(userData);

        printJson(cUser.toJson());
      } else {
        print('## user doc with email < $userEmail >  dont exist ');
      }

      if(withVerif) checkVerification(isLoadingScreen: isLoadingScreen);//register btn


    }).catchError((e) {
      print("## cant find user in db (email_search): $e");
      if(isLoadingScreen) signOutUser(shouldGoLogin: true);// go login if you cant get your user model

    });


  }






}