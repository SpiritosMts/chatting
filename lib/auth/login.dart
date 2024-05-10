import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:line_icons/line_icons.dart';


import '../bindings.dart';
import '../myUi.dart';
import '../myVoids.dart';
import '../privateData.dart';
import '../styles.dart';
import 'resetPwd.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailTec = TextEditingController();
  final TextEditingController passwordTec = TextEditingController();
  bool _isPwdObscure = true;
  Map creMap = Get.arguments??{}; //passed email,pwd


  login() async {
    if (_loginFormKey.currentState!.validate()) {
      authCtr.signIn(
          emailTec.text,
          passwordTec.text,
          onSignIn: () async {///account Found
            await authCtr.getUserInfoByEmail(emailTec.text);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if(creMap.isEmpty) return;
      setState(() {
        emailTec.text= creMap['email']??'';
        passwordTec.text= creMap['pwd']??'';
      });
      //streamingDoc(usersColl,authCtr.cUser.id!);
    });

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
        body:  SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),

                // logo Image
                Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                animatedText('Welcome to $appDisplayName'.tr,26,150),
                SizedBox(
                  height: 7.h,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [

                        //email field
                        customTextField(
                          controller: emailTec,
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
                        SizedBox(height: 25),

                        //pwd field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            customTextField(
                              controller: passwordTec,
                              labelText: 'Password'.tr,
                              hintText: 'Enter your password'.tr,
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
                                  return "password can't be empty"  .tr;
                                }
                                if (!regex.hasMatch(value)) {
                                  return ('Enter a valid password of at least 6 characters'.tr);
                                } else {
                                  return null;
                                }
                              },
                            ),
                            GestureDetector(
                              onTap: (){
                                Get.to(()=>ForgotPassword());
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
                                child: Text('forgot password ?'.tr,style: TextStyle(
                                  color: normalTextCol,
                                  fontWeight: FontWeight.w400,
                                ),),
                              ),
                            ),
                          ],
                        ),


                        SizedBox(
                          height: 30,
                        ),

                        /// 'email' signIn
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [




                            SizedBox(width: 10,),

                            ///signIn
                            customButton(
                              reversed: true,
                              btnOnPress: () async {
                                login();
                              },
                              textBtn: 'Login'.tr,
                              btnWidth: 130,
                              icon: Icon(
                                LineIcons.arrowCircleRight,
                                color: btnIconCol,
                                size: 19,
                              ),
                            ),


                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        /// register sugg
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('you have no account ?'.tr,style: TextStyle(
                              color: normalTextCol,
                              fontWeight: FontWeight.w500,
                            ),),
                            TextButton(
                              onPressed: (() {
                                goChooseAccountType();

                              }),
                              child: Text(
                                'Sign Up'.tr,
                                style: const TextStyle(
                                  color: orangeCol,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if(false)...[
                        SizedBox(
                          height: 15,
                        ),
                        /// divider
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: loginUsingCol,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Login using',
                                style: TextStyle(
                                  color: loginUsingCol,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: loginUsingCol,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        /// 'google + facebook' signIn
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ///facebook
                           if(facebook_login_access) IconButton(
                              onPressed: ()async {
                                //await authCtr.signInWithFacebook();

                              },
                              icon: CircleAvatar(
                                radius: 25,
                                child: Image.asset(
                                    'assets/images/icons/facebook.png'),
                              ),
                            ),
                            ///google
                            if(google_login_access) IconButton(
                              onPressed: ()async {
                                //await authCtr.signInWithGoogle();

                              },
                              icon: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.transparent,
                                child: Image.asset('assets/images/icons/google.png'),
                              ),
                            ),
                            ///linkedIn
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: CircleAvatar(
                            //     radius: 25,
                            //     child: Image.asset(
                            //         'assets/images/icons/linkedin.png'),
                            //   ),
                            // ),
                          ],
                        )]
                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        )
      ),
    );
  }
}
