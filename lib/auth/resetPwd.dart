import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../bindings.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../styles.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController forgotEmailCtr =  TextEditingController();




  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF75b0b5),
      child: Scaffold(
        body: backGroundTemplate(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),

                  // logo Image
                  Image.asset(
                    'assets/images/icons/reset-password.png',
                    fit: BoxFit.cover,
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 40),
                  animatedText('Forgot Your password ?'.tr,23 ,120),

                  SizedBox(
                    height: 20,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
                    child: Form(
                      key: formkey,
                      child: Column(
                        children: [

                          customTextField(
                            controller: forgotEmailCtr,
                            labelText: 'Email'.tr,
                            hintText: 'Enter your email'.tr,
                            icon: Icons.email,
                            isPwd: false,
                            obscure: false,
                            onSuffClick: (){},
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



                          SizedBox(
                            height: 30,
                          ),
                          /// forgot pwd (reset pwd)
                          customButton(
                            btnOnPress: () async {
                              if (formkey.currentState!.validate()) {
                                authCtr.ResetPss(forgotEmailCtr.text);
                              }
                              },

                            textBtn: 'Send'.tr,
                            btnWidth: 110,
                            icon: Icon(
                              Icons.login,
                              color: btnTextCol,
                              size: 19,
                            ),
                            reversed: true,

                          ),

                          SizedBox(
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
