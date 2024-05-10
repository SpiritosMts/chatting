
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../bindings.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';
import 'register.dart';

class RegisterChooseType extends StatefulWidget {

  @override
  State<RegisterChooseType> createState() => _RegisterChooseTypeState();
}

class _RegisterChooseTypeState extends State<RegisterChooseType> {

  Map gglMap = Get.arguments;







  roleButton(String role,String imgPath){
    return Container(
      width: 90.w,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          shadowColor: Color(0x2800000),
          elevation: 0.1,
          side: const BorderSide(width: 1.5, color: typeBtnColor),
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18.0),
            ),
          ),
        ),
        onPressed: () async {
          goRegister(role:role);
        },
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: Image.asset(
                  imgPath,
                  width: 30,
                )),
            Text(
              role,
              style: TextStyle(
                  fontSize: 16,
                  color: typeBtnColor,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: backGroundTemplate(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(height: 25,),

          // role image
          Container(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Column(children: [
                Image.asset(
                  "assets/images/role.png",
                  width: 38.w,
                ),
                SizedBox(height: 30),
              ])),

          animatedText('Please tell us who you are ?'.tr,21.sp ,150),
          SizedBox(height: 10.h,),

          //roles
          Column(
            children: [
              roleButton(authCtr.roles[0].tr,'assets/images/student.png'),
              roleButton(authCtr.roles[1].tr,'assets/images/teacher.png'),

            ],
          )
        ]),
      )
    );
  }
}
