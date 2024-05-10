import 'package:chatting/bindings.dart';
import 'package:chatting/generalLayout/generalLayoutCtr.dart';
import 'package:chatting/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../myUi.dart';
import '../styles.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgCol,
      child: GetBuilder<LayoutCtr>(builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 20,),
              Expanded(
                child: Container(
                  child:layCtr.selectedFriends.isNotEmpty? ListView.builder(
                    //  physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                        right: 0,
                        left: 0,
                      ),
                      //itemExtent: 100,// card height
                      itemCount: layCtr.selectedFriends.length,
                      itemBuilder: (BuildContext context, int index) {
                        ScUser usr = (layCtr.selectedFriends[index]);
                        return userCard(usr, index,tappable: true,btnOnPress: (){

                        });
                      }
                  ):Center(child: Text('No Friends to show',style: TextStyle(fontSize: 16)),),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
