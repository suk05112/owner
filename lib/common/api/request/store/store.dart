import 'dart:ffi';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Store {
  int owner_id;
  int store_id;
  String store_name;
  String store_logo;
  String store_telephone;
  String store_description;
  List<String> store_photo_urls;
  int store_photo_cnt;
  String store_address;
  double store_lat, store_lng;
  // @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? updated_time;

  @JsonKey(fromJson: _fileFromJson, toJson: _fileToJson)
  File? business_registration;

  @JsonKey(fromJson: _fileFromJson, toJson: _fileToJson)
  File? bank_book;

  Store({
    this.owner_id = 0,
    this.store_id = 0,
    this.store_name = "",
    this.store_logo = "",
    this.store_telephone = "",
    this.store_description = "",
    this.store_photo_urls = const [],
    this.store_photo_cnt = 0,
    this.store_address = "",
    this.store_lat = 0,
    this.store_lng = 0,
    this.business_registration,
    this.bank_book,
    this.updated_time,
  });

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);

  static File? _fileFromJson(String? filePath) {
    if (filePath == null) {
      return null;
    }
    return File(filePath);
  }

  static String? _fileToJson(File? file) {
    return file?.path;
  }

  // static DateTime? _dateTimeFromJson(String? date) {
  //   return date != null ? DateTime.parse(date) : null;
  // }

  // static String? _dateTimeToJson(DateTime? date) {
  //   return date?.toIso8601String();
  // }
}

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
  List<Store> store;

  StoreListResponse({required this.statusCode, required this.store});

  factory StoreListResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreListResponseToJson(this);
}

@JsonSerializable()
class StoreResponse {
  int statusCode;
  Store store;

  StoreResponse({required this.statusCode, required this.store});

  factory StoreResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreResponseToJson(this);
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
