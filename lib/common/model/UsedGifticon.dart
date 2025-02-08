import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart';
import 'dart:ffi';

part 'UsedGifticon.g.dart';

@JsonSerializable()
class UsedGifticon {
  int id;
  DateTime used_time;
  String menu_name;
  int price;

  UsedGifticon({
    required this.id,
    required this.used_time,
    required this.menu_name,
    required this.price,
  });

  factory UsedGifticon.fromJson(Map<String, dynamic> json) =>
      _$UsedGifticonFromJson(json);
  Map<String, dynamic> toJson() => _$UsedGifticonToJson(this);
}

@JsonSerializable()
class UsedGifticonList {
  List<UsedGifticon> gifticonList;

  UsedGifticonList({required this.gifticonList});

  factory UsedGifticonList.fromJson(Map<String, dynamic> json) =>
      _$UsedGifticonListFromJson(json);
  Map<String, dynamic> toJson() => _$UsedGifticonListToJson(this);
}

@JsonSerializable()
class OwnerStore {
  int store_id;
  String store_name;

  OwnerStore({
    required this.store_id,
    required this.store_name,
  });

  factory OwnerStore.fromJson(Map<String, dynamic> json) =>
      _$OwnerStoreFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerStoreToJson(this);
}

@JsonSerializable()
class OwnerStoreList {
  List<OwnerStore> ownerStoreList;

  OwnerStoreList({required this.ownerStoreList});

  factory OwnerStoreList.fromJson(Map<String, dynamic> json) =>
      _$OwnerStoreListFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerStoreListToJson(this);
}
