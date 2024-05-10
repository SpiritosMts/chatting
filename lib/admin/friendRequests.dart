import 'package:chatting/auth/authCtr.dart';
import 'package:chatting/bindings.dart';
import 'package:chatting/generalLayout/generalLayoutCtr.dart';
import 'package:chatting/models/request.dart';
import 'package:chatting/myVoids.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../myUi.dart';
import '../styles.dart';

class AllJoinsRequests extends StatefulWidget {
  const AllJoinsRequests({super.key});

  @override
  State<AllJoinsRequests> createState() => _AllJoinsRequestsState();
}

class _AllJoinsRequestsState extends State<AllJoinsRequests> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgCol,
      child: GetBuilder<AuthController>(builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 20,),
              Expanded(
                child: Container(
                  child:cUser.requests.isNotEmpty? ListView.builder(
                    //  physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                        right: 0,
                        left: 0,
                      ),
                      //itemExtent: 100,// card height
                      itemCount: cUser.requests.length,
                      itemBuilder: (BuildContext context, int index) {
                        FrRequest req = (cUser.requests[index]);
                        return requestCard(req, index,tappable: true,);
                      }
                  ):Center(child: Text('No requests to show',style: TextStyle(fontSize: 16)),),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
