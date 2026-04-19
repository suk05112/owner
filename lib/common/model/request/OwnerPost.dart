import 'package:http/http.dart' as http;
import 'dart:convert';

class OwnerPost {
  String? id;
  String? uid;
  String? password;
  String? phone;
  String? name;
  String? bankbook;

  OwnerPost(
      {this.id, this.uid, this.password, this.phone, this.name, this.bankbook});

  OwnerPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    password = json['password'];
    phone = json['phone'];
    name = json['name'];
    bankbook = json['bankbook'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['password'] = password;
    data['phone'] = phone;
    data['name'] = name;
    data['bankbook'] = bankbook;
    return data;
  }
}