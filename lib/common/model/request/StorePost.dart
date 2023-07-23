import 'package:http/http.dart' as http;
import 'dart:convert';

class StorePost {
  String? id;
  String? store_name;
  String? logo;
  String? open_yn;
  String? status;
  String? store_lat;
  String? store_lng;

  StorePost(
      {this.id,
      this.store_name,
      this.logo,
      this.open_yn,
      this.status,
      this.store_lat,
      this.store_lng});

  StorePost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    store_name = json['store_name'];
    logo = json['logo'];
    open_yn = json['open_yn'];
    status = json['status'];
    store_lat = json['store_lat'];
    store_lng = json['store_lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['store_name'] = this.store_name;
    data['logo'] = this.logo;
    data['open_yn'] = this.open_yn;
    data['status'] = this.status;
    data['store_lat'] = this.store_lat;
    data['store_lng'] = this.store_lng;

    return data;
  }
}
