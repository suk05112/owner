import 'package:cloud_firestore/cloud_firestore.dart';

class CafeDetailInfo {
  String id;
  String storeName;
  String storeTelephone;
  String logo;
  int menuId;
  bool openYn;
  int operatingHourId;

  CafeDetailInfo(
      {required this.id,
      required this.storeName,
      required this.storeTelephone,
      required this.logo,
      required this.menuId,
      required this.openYn,
      required this.operatingHourId});

  // DocumentSnapshot을 CafeInfo 모델 클래스로 변환하는 factory 생성자
  factory CafeDetailInfo.fromSnapShot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return CafeDetailInfo(
      id: snapshot.id,
      storeName: snapshot.data()?['store_name'],
      storeTelephone: snapshot.data()?['store_telephone'],
      logo: snapshot.data()?['logo'],
      menuId: snapshot.data()?['menuId'],
      openYn: snapshot.data()?['open_yn'],
      operatingHourId: snapshot.data()?['operatingHourId'],
    );
  }
}
