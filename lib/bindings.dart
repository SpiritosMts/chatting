

import 'package:get/get.dart';
import 'auth/authCtr.dart';
import 'generalLayout/generalLayoutCtr.dart';
import 'notif/notifCtr.dart';


AuthController authCtr = AuthController.instance;
LayoutCtr get layCtr => Get.find<LayoutCtr>();
FirebaseMessagingCtr get ntfCtr => Get.find<FirebaseMessagingCtr>();





class GetxBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(FirebaseMessagingCtr());

    //Get.lazyPut<FirebaseMessagingCtr>(() => FirebaseMessagingCtr(),fenix: true);
    Get.lazyPut<LayoutCtr>(() => LayoutCtr(),fenix: true);


  }
}