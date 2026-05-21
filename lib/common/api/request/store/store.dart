import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'store.g.dart';

@JsonSerializable()
class Store {
  int owner_id;
  int store_id;
  String store_name;
  String? store_logo;
  String store_telephone;
  String store_description;
  List<String> store_photo_urls;
  int? image_count;
  String store_address;
  double store_lat, store_lng;
  String? region_code;
  String? district_code;
  // @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? updated_time;

  @JsonKey(fromJson: _fileFromJson, toJson: _fileToJson)
  File? business_registration;

  @JsonKey(fromJson: _fileFromJson, toJson: _fileToJson)
  File? bank_book;
  String? inspection_msg;
  @JsonKey(fromJson: _inspectionStatusFromJson, toJson: _inspectionStatusToJson)
  int? inspection_status;
  String? status;
  String? open_yn;
  String? created_at;
  String? updated_at;

  Store(
      {this.owner_id = 0,
      this.store_id = 0,
      this.store_name = "",
      this.store_logo,
      this.store_telephone = "",
      this.store_description = "",
      this.store_photo_urls = const [],
      this.image_count,
      this.store_address = "",
      this.store_lat = 0,
      this.store_lng = 0,
      this.region_code,
      this.district_code,
      this.business_registration,
      this.bank_book,
      this.updated_time,
      this.inspection_msg,
      this.inspection_status,
      this.status,
      this.open_yn,
      this.created_at,
      this.updated_at});

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

  static int? _inspectionStatusFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      switch (value.toUpperCase()) {
        case 'PENDING':
          return 0;
        case 'APPROVED':
        case 'APPROVE':
          return 1;
        case 'REJECTED':
        case 'REJECT':
          return 2;
        default:
          return null;
      }
    }
    return null;
  }

  static String? _inspectionStatusToJson(int? value) {
    if (value == null) return null;
    switch (value) {
      case 0:
        return 'PENDING';
      case 1:
        return 'APPROVED';
      case 2:
        return 'REJECTED';
      default:
        return null;
    }
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
  @JsonKey(defaultValue: 0)
  int owner_id;
  @JsonKey(defaultValue: 0)
  int store_count;
  @JsonKey(name: 'stores', defaultValue: [])
  List<Store> store;

  StoreListResponse({
    required this.owner_id,
    required this.store_count,
    required this.store,
  });

  factory StoreListResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreListResponseToJson(this);
}

@JsonSerializable()
class StoreResponse {
  Store store;

  StoreResponse({required this.store});

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
