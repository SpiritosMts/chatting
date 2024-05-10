
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../privateData.dart';
import '../bindings.dart';
import '../firebaseVoids.dart';
import '../models/user.dart';
import '../myUi.dart';
import '../myVoids.dart';
import 'package:uuid/uuid.dart';

import '../styles.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {

  bool _isPwdObscure = true;

  final ownerNameTec = TextEditingController();
  final emailTec = TextEditingController();
  final passwordTec = TextEditingController();
  final phoneTec = TextEditingController();
  final addressTec = TextEditingController();

  final specialityTec = TextEditingController();
  final gradeTec = TextEditingController();



  GlobalKey<FormState> _registerFormkey = GlobalKey<FormState>();

  double spaceFields= 25;

  String newUserRole = Get.arguments['newUserRole'];


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
    });

  }


  addNewUser() async {
     String  userEmail = emailTec.text;

      ScUser newUser= ScUser(
          name: ownerNameTec.text,
          email: emailTec.text,
          pwd: passwordTec.text,
          phone:phoneTec.text ,
          address:  addressTec.text,
speciality:specialityTec.text ,
grade:gradeTec.text ,

        role: newUserRole,
        verified: autoVerifyEmails  ? true:  false,
          joinTime: todayToString(showHoursNminutes: true),
      );

    Future<void> addUserDoc() async {
      try{
        String specificID = Uuid().v1();

        var value = await addDocument(
          specificID: specificID,
          fieldsMap: newUser.toJson(),
          coll: usersColl,

        );
        Get.back(); //hide loading
        Future.delayed(const Duration(milliseconds: 3000), () async {
          await authCtr.getUserInfoByEmail(userEmail);

          if ( autoVerifyEmails) {
            //showSuccess(sucText: 'your account has been created successfully'.tr, btnOkPress: () {});
            goHome();
          } else {
            goVerify();
          }
        });
      }catch  (err){
        print('## cant create user account : $err');
      }
    }


    if (_registerFormkey.currentState!.validate()) {
      showLoading(text: 'Connecting'.tr);


        authCtr.signUp(userEmail, passwordTec.text, onSignUp: () {
          addUserDoc();
        });


    }
  }




  // /////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: backGroundTemplate(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Form(
            key: _registerFormkey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50,),
                  Container(
                    child:  Text(
                      'Register'.tr,
                      style: TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 35,
                          color: registerTitleColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: Text(
                      newUserRole.tr,
                      style: const TextStyle(
                          fontFamily: 'Segoe UI',
                          fontSize: 30,
                          color: registerSubtitleColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 40,),

                  /// /////////////////////////////////


                  SizedBox(height: spaceFields),
                  // name
                  customTextField(
                    controller: ownerNameTec,
                    labelText: 'Name'.tr,
                    //hintText: 'Enter your business name'.tr,
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "owner name can't be empty".tr;
                      }
                     else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(height: spaceFields),
                  //email
                  customTextField(
                    controller: emailTec,
                    labelText: 'Email'.tr,
                    //hintText: 'Enter your email'.tr,
                    icon: Icons.email,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "email can't be empty".tr;
                      }
                      if (!EmailValidator.validate(value)) {
                        return ("Enter a valid email".tr);
                      } else {
                        return null;
                      }
                    },
                  ),
                  if(true)...[
                    SizedBox(height: spaceFields),

                    customTextField(
                      controller: passwordTec,
                      labelText: 'Password'.tr,
                      //hintText: 'Enter your password'.tr,
                      icon: Icons.lock,
                      isPwd: true,
                      obscure: _isPwdObscure,
                      onSuffClick: (){
                        setState(() {
                          _isPwdObscure = !_isPwdObscure;
                        });
                      },
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return "password can't be empty".tr;
                        }
                        if (!regex.hasMatch(value)) {
                          return ('Enter a valid password of at least 6 characters'.tr);
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],

                  SizedBox(height: spaceFields),
                  customTextField(//phone
                    textInputType: TextInputType.number,

                    controller: phoneTec,
                    labelText: 'Phone'.tr,
                    //hintText: 'Enter your number'.tr,
                    icon: Icons.phone,
                    isPwd: false,
                    obscure: false,
                    onSuffClick: (){},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "number can't be empty".tr;
                      }
                      else {
                        return null;
                      }
                    },
                  ),

                  SizedBox(height: spaceFields),
                  customTextField(//address
                    controller: addressTec,
                    labelText: 'Address'.tr,
                    //hintText: 'Enter your address'.tr,
                    icon: Icons.home,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "address can't be empty".tr;
                      }
                     else {
                        return null;
                      }
                    },
                  ),

                  SizedBox(height: spaceFields),

                 newUserRole == authCtr.roles[1] ? customTextField(//address
                    controller: specialityTec,
                    labelText: 'Speciality'.tr,
                    //hintText: 'Enter your address'.tr,
                    icon: Icons.account_circle_outlined,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "speciality can't be empty".tr;
                      }
                     else {
                        return null;
                      }
                    },
                  ):customTextField(//address
                    controller: gradeTec,
                    labelText: 'Grade'.tr,
                    //hintText: 'Enter your address'.tr,
                    icon: Icons.school_rounded,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "grade can't be empty".tr;
                      }
                     else {
                        return null;
                      }
                    },
                  ),

                  SizedBox(height: spaceFields),


                  /// ----------  Button signUp --------------------
                  Container(
                    //color: Colors.red,
                    width: 90.w,
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: registerBtnCol,
                        shadowColor: Color(0x2800000),
                        elevation: 0.1,
                        side: const BorderSide(width: 1.5, color: registerBtnBorderCol),
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        addNewUser();
                      },
                      child:  Text(
                        "Create account".tr,
                        style: TextStyle(
                            fontSize: 16,
                            color: btnTextCol,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

}
