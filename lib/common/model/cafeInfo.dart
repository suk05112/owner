// import 'dart:ffi';
// import 'package:ffi/ffi.dart';
import 'package:json_annotation/json_annotation.dart';
// import 'package:retrofit/retrofit.dart';

part 'cafeInfo.g.dart';

@JsonSerializable()
class CafeInfo {
  String? logo;
  String? store_name;
  String? store_telephone;
  String? owner_id;
  bool? open_yn;
  String? operatingHourId;

  CafeInfo(
      {this.logo,
      this.store_name,
      this.store_telephone,
      this.owner_id,
      this.open_yn,
      this.operatingHourId});

  factory CafeInfo.fromJson(Map<String, dynamic> json) =>
      _$CafeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CafeInfoToJson(this);

  // CafeInfo.fromJson(dynamic json, this.reference) {
  //   logo = json['logo'];
  //   store_name = json['store_name'];
  //   store_telephone = json['store_telephone'];
  //   open_yn = json['opne_yn'];
  //   owner_id = json['owner_id'];
  //   operatingHourId = json['operatingHourId'];
  // }

  // CafeInfo.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapShot)
  //     : this.fromJson(snapShot.data(), snapShot.reference);

  // CafeInfo.fromQuerySnapshot(
  //     QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
  //     : this.fromJson(snapshot.data(), snapshot.reference);

  // Map<String, dynamic> toJson() {
  //   final map = <String, dynamic>{};
  //   map['logo'] = logo;
  //   map['store_name'] = store_name;
  //   map['store_telephone'] = store_telephone;
  //   map['opne_yn'] = open_yn;
  //   map['owner_id'] = owner_id;
  //   map['operatingHourId'] = operatingHourId;

  //   return map;
  // }
}
