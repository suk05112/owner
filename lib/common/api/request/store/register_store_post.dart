import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';

part 'register_store_post.g.dart';

@JsonSerializable()
class RegisterStorePost {
  int owner_id;

  String store_name;
  String store_logo;
  String store_telephone;
  String store_description;
  int store_photo_cnt;
  String store_address;
  double store_lat, store_lng;
  String business_registration;

  RegisterStorePost({
    required this.owner_id,
    required this.store_name,
    required this.store_logo,
    required this.store_telephone,
    required this.store_description,
    required this.store_photo_cnt,
    required this.store_address,
    required this.store_lat,
    required this.store_lng,
    required this.business_registration,
  });

  factory RegisterStorePost.fromJson(Map<String, dynamic> json) =>
      _$RegisterStorePostFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterStorePostToJson(this);
}
