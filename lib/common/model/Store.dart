import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:owner/screen/cafelist/cafelist_page.dart';
import 'dart:ffi';

class Store {
  String? logo;
  String? store_name;
  String? store_telephone;
  String? owner_id;
  bool? open_yn;
  String? operatingHourId;
  String? introduce;
  DocumentReference? reference;

  Store(
      {required this.logo,
      required this.store_name,
      required this.store_telephone,
      required this.owner_id,
      required this.open_yn,
      required this.operatingHourId,
      required this.introduce,
      this.reference});

  Store.fromJson(dynamic json, this.reference) {
    logo = json['logo'];
    store_name = json['store_name'];
    store_telephone = json['store_telephone'];
    open_yn = json['opne_yn'];
    owner_id = json['owner_id'];
    operatingHourId = json['operatingHourId'];
    introduce = json['introduce'];
  }

  Store.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapShot)
      : this.fromJson(snapShot.data(), snapShot.reference);

  Store.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['logo'] = logo;
    map['store_name'] = store_name;
    map['store_telephone'] = store_telephone;
    map['opne_yn'] = open_yn;
    map['owner_id'] = owner_id;
    map['operatingHourId'] = operatingHourId;
    map['introduce'] = introduce;

    return map;
  }
}
