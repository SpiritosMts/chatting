



import 'dart:convert';

import 'package:http/http.dart';

import 'request.dart';



class ScUser {


  //personal
  String id;
  String email;
  String name ;
  String pwd;
  String phone;
  String address;
  String deviceToken;
  String role;
  String speciality;
  String grade;

  bool isAdmin;
  bool verified;
  List<FrRequest> requests;
  List<String> friends;

  //time
  String joinTime;



  ScUser({
    this.id = '',
    this.email = '',
    this.name = '',
    this.pwd = '',
    this.phone = '',
    this.address = '',
    this.grade = '',
    this.speciality = '',
    this.role = '',
    this.deviceToken = '',
    this.isAdmin = false,
    this.verified = false,
    this.requests = const [],
    this.friends = const [],

    this.joinTime = '',

  });



  // Convert ScUser object to JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> requestsToMap = {};

    for (var req in requests) { //map
        requestsToMap[req.id] = req.toJson();
    }

    return {
      'id': id,
      'email': email,
      'name': name,
      'pwd': pwd,
      'deviceToken': deviceToken,
      'phone': phone,
      'address': address,
      'isAdmin': isAdmin,
      'role': role,
      'verified': verified,
      'speciality': speciality,
      'grade': grade,
      'requests': requestsToMap,
      'friends': friends,
      'joinTime': joinTime,
    };
  }

  // Create ScUser object from JSON
  factory ScUser.fromJson(Map<String, dynamic> json) {


    List<FrRequest> reqsFromMap = [];
    if (json.containsKey('requests') && json['requests'] != null) {
      (json['requests'] as Map<String, dynamic>).forEach((key, eventJson) {
        if (eventJson is Map<String, dynamic>) {
          reqsFromMap.add(FrRequest.fromJson(eventJson));
        }
      });
    }


    return ScUser(

      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pwd: json['pwd'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      role: json['role'] ?? '',
      speciality: json['speciality'] ?? '',
      phone: json['phone'] ?? '',
      grade: json['grade'] ?? '',
      address: json['address'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      verified: json['verified'] ?? false,
      requests: reqsFromMap,
      friends: List<String>.from(json['friends'] ?? []),
      joinTime: json['joinTime'] ?? '',
    );
  }
}
