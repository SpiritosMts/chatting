

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../bindings.dart';
import '../main.dart';
import '../firebaseVoids.dart';
import '../firebase_options.dart';
import '../myVoids.dart';


//in bindings.dart (initialize ctr)
//in main.dart (initilize Fcm)
//after verify user and get its data (get token)
// in api & cre enable "cloud messaging"
// add permission in manifest
class FirebaseMessagingCtr extends GetxController {



  int messageCount = 0;
  String serverKey = 'AAAA8rq3bgY:APA91bF5Z_hpAAQxQTcEkBTCBEg7u0e_dE8fJMHMwKj2BHNr5dTuGL3Uz4oZ_I1O0sA42S4Qp_9fCAQRq6PxPgdcFUob0Jv9vh-mDHkeobW4ks7cJGgFueRxvgyaVjZgYWLXyXZUh34t';
  static const vapidKey = "PufpwIEZ9FgXv603od-GaoVMk25r1iitOY9_Lr71lVk";
  // used to pass messages from event handler to the UI
  String lastMessage = "";
  String? initialMessage;
  bool resolved = false;
  bool isNotifActive = true;


  ///TOKEN
  String token = "";
  late Stream<String> _tokenStream ;
  streamUserToken(){
    FirebaseMessaging.instance.getToken(vapidKey:vapidKey).then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }
  void setToken(String? _token) {
    print('## this device FCM Token: $_token');
    token = _token!;
    updateFieldInFirestore(usersCollName,cUser.id,'deviceToken',_token,addSuccess: (){
      //print('## user_deviceToken in fb updated  <');
    });
  }


  @override
  onInit() {
    super.onInit();
    print('## init FirebaseMessagingCtr');

    reqFcmPermission();

    // open when terminated ()
    FirebaseMessaging.instance.getInitialMessage().then((value) {
          resolved = true;
          initialMessage = value?.data.toString();

          update();
        });

    //foreground receive
    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    // open when not terminated (foregroung / background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('## A new onMessageOpenedApp event was published! ##');

    });
  }




  /// CAll this to send notification (provide user device token which is stored in user info )
  Future<void> sendPushMessage({String receiverToken='',String title='',String body='',String imageUrl='',Map<String,dynamic> data= const{} }) async {
    if (receiverToken == '') {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
    String constructFCMPayload(String? token) {
      messageCount++;
      return jsonEncode({
        //'token': token,
        'to': token,
        'data': data,
        'notification': {
          'title': title,
          'body': body,
          "image": imageUrl,
        },
      });
    }

    try {
      // Make the HTTP POST request
      final response =await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey',
        },
        body: constructFCMPayload(receiverToken),
      );
      // Check the HTTP status code
      if (response.statusCode == 200) {
        // Request was successful
        print('## FCM request for device sent!');
        print('##Response body: ${response.body}');
      } else {
        // Request failed
        print('## Request failed with status code: ${response.statusCode}');
        print('##Response body: ${response.body}');
      }


    } catch (e) {
      print('## error try send fcm: $e');
    }
  }

}

/// NOtification initilize
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
 FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
Future<void> setupFlutterNotifications() async {
  print('## setupFlutterNotifications ## ');

  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
      'Notif-ID', // id
      'Notif Channel', // title
      description: 'This channel is used for products advertisement', // description
      importance: Importance.max,
     // sound: RawResourceAndroidNotificationSound('notif_sound'),//android/app/src/main/res/raw
      showBadge: true,
      playSound: true,
      enableVibration: true

  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // Initialize the local notifications plugin with a callback function
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');;
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin!.initialize(
    initializationSettings,
  );
  isFlutterLocalNotificationsInitialized = true;
}
Future<void> reqFcmPermission() async {

  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    print('## Fcm Permission granted: ${settings.authorizationStatus}');
  }
}
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initFirebase();
  await setupFlutterNotifications();
  showFlutterNotification(message);

  print('## Handling a background message ${message.messageId}');
}
Future<void> showFlutterNotification(RemoteMessage message) async {
  print('## showFlutterNotification ##');

  RemoteNotification? notification = message.notification;
  Map<String, dynamic> data = message.data;
  AndroidNotification? android = message.notification?.android;
  String notificationImageUrl = message.notification?.android!.imageUrl??'';
  // final largeIconPath = await downloadImage(notificationImageUrl, notificationImageUrl);
  BigPictureStyleInformation? bigPictureStyleInformation ;
  if(notificationImageUrl != ''){
    final http.Response response = await http.get(Uri.parse(notificationImageUrl));
    bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)));

  }

  print('## notificationImage: "$notificationImageUrl"');



  if (notification != null && android != null && !kIsWeb) {

    if(ntfCtr.isNotifActive) flutterLocalNotificationsPlugin!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        //iOS: ,
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.max,
          //sound: RawResourceAndroidNotificationSound('notif_sound'),//android/app/src/main/res/raw
          //icon: 'ic_notif_belaaraby',
          color: Colors.yellow,
          playSound: true,
          enableVibration: true,
          styleInformation: bigPictureStyleInformation,
        ),
      ),

    );

  }

}
