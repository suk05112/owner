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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_name'] = store_name;
    data['logo'] = logo;
    data['open_yn'] = open_yn;
    data['status'] = status;
    data['store_lat'] = store_lat;
    data['store_lng'] = store_lng;

    return data;
  }
}
