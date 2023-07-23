import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Body2 {
  List<Store> store;

  Body2({required this.store});

  factory Body2.fromJson(Map<String, dynamic> json) => _$Body2FromJson(json);
  Map<String, dynamic> toJson() => _$Body2ToJson(this);
}

@JsonSerializable()
class StoreListResponse {
  int statusCode;
  Body2 body;

  StoreListResponse({required this.statusCode, required this.body});

  factory StoreListResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreListResponseToJson(this);
}

@JsonSerializable()
class Store {
  int owner_id;
  int store_id;
  String store_name;
  String store_telephone;
  String store_description;
  String? store_photo;
  String store_logo;
  int? status;
  int inspection_status;
  int? open_yn;
  double? store_lat;
  double? store_lng;

  Store({
    required this.owner_id,
    required this.store_id,
    required this.store_name,
    required this.store_telephone,
    required this.store_description,
    required this.store_photo,
    required this.store_logo,
    required this.status,
    required this.inspection_status,
    required this.open_yn,
    required this.store_lat,
    required this.store_lng,
  });

  @override
  String toString() {
    return '''{
      owner_id: $owner_id, 
      store_id: $store_id, 
      store_name: $store_name,  
      store_telephone: $store_telephone,
      store_description: $store_description,
      store_photo: $store_photo,
      store_logo: $store_logo,
      status: $status,
      inspection_status: $inspection_status,
      open_yn: $open_yn,
      store_lat: $store_lat,
      store_lng: $store_lng
      }''';
  }

  // int owner_id, store_id;
  // int? status;

  // String store_name;
  // String store_logo;
  // String store_telephone;
  // String store_description;
  // String store_photo;
  // String store_address;
  // String? open_yn;

  // String? store_lng;
  // String? store_lat;
  // String business_registration;

  // Store({
  //   required this.owner_id,
  //   required this.store_id,
  //   required this.status,
  //   required this.store_name,
  //   required this.store_logo,
  //   required this.store_telephone,
  //   required this.store_description,
  //   required this.store_photo,
  //   required this.store_address,
  //   required this.business_registration,
  // });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);
}

@JsonSerializable()
class StoreCard {
  int status;
  String store_name;
  String store_logo;

  StoreCard({
    required this.status,
    required this.store_name,
    required this.store_logo,
  });

  factory StoreCard.fromJson(Map<String, dynamic> json) =>
      _$StoreCardFromJson(json);
  Map<String, dynamic> toJson() => _$StoreCardToJson(this);
}
