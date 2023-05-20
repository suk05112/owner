import 'package:cloud_firestore/cloud_firestore.dart';

class OperatingHours {
  String? startTime;
  String? endTime;
  String? storeId;
  DocumentReference? reference;

  OperatingHours({this.startTime, this.endTime, this.storeId, this.reference});

  OperatingHours.fromJson(dynamic json, this.reference) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    storeId = json['storeId'];
  }

  OperatingHours.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapShot)
      : this.fromJson(snapShot.data(), snapShot.reference);

  OperatingHours.fromQuerySnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['startTime'] = startTime;
    map['endTime'] = endTime;
    map['storeId'] = storeId;

    return map;
  }
}
