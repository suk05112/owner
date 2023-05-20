import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:owner/common/model/OperatingHours.dart';

import '../screen/RegisterStore.dart';
import 'model/CafeBasicInfo.dart';
import 'model/CafeInfo.dart';
import 'model/Menu.dart';
import 'model/Store.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addEmployee(Employee employeeData) async {
    await _db.collection("Employees").add(employeeData.toMap());
  }

  updateEmployee(Employee employeeData) async {
    await _db
        .collection("Employees")
        .doc(employeeData.id)
        .update(employeeData.toMap());
  }

  Future<void> deleteEmployee(String documentId) async {
    await _db.collection("Employees").doc(documentId).delete();
  }

  Future<List<Employee>> retrieveEmployees() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("Employees").get();
    return snapshot.docs
        .map((docSnapshot) => Employee.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  Future<List<CafeBasicInfo>> retrieveCafeBasicInfo() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("cafe").get();

    print("retreive 함수 호출");
    return snapshot.docs
        .map((docSnapshot) => CafeBasicInfo.fromSnapShot(docSnapshot))
        .toList();
  }

  Future<void> registerStore(String ownerId, Store store) async {
    AggregateQuerySnapshot _myDocCnt =
        await FirebaseFirestore.instance.collection('cafe').count().get();
    _db
        .collection('cafe')
        .doc("0000000".substring(7 - _myDocCnt.count) +
            _myDocCnt.count.toString())
        .set(store.toJson());
  }

  // Future<List<CafeBasicInfo>> retrieveCafeBasicInfo() async {
  // QuerySnapshot<Map<String, dynamic>> snapshot = await _db.collection("cafe").get();

  // return snapshot.docs.map((docSnapshot) => CafeBasicInfo.fromSnapShot(docSnapshot)).toList();
  // }

  Future<CafeInfo> retrieveCafeInfo(String cafeId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("cafe").doc(cafeId).get();

    print(
        "in retreive cafe info ${CafeInfo.fromSnapShot(snapshot).store_name}, ");
    return CafeInfo.fromSnapShot(snapshot);
  }

  Future<OperatingHours> retrieveOperatingHours(String operatingHourId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("OperatingHours").doc(operatingHourId).get();

    print(
        "in retreive cafe info ${OperatingHours.fromSnapShot(snapshot).startTime}, ");
    return OperatingHours.fromSnapShot(snapshot);
  }

  Future<List<Menu>> retrieveMenu(String storeId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection("Menu").doc(storeId).collection("Menu").get();

    print(snapshot.docs
        .map((docSnapshot) => Menu.fromSnapShot(docSnapshot))
        .toList()
        .first
        .description);
    print("menuretreive 함수 호출");
    return snapshot.docs
        .map((docSnapshot) => Menu.fromSnapShot(docSnapshot))
        .toList();
  }

  addMenu(Menu menu) async {
    print("메쥬 저장");
    print(menu.description);
    print(menu.storeId);
    print(menu.menuId);

    await _db
        .collection("Menu")
        .doc(menu.storeId)
        .collection("Menu")
        .doc(menu.menuId.toString())
        .set(menu.toFirestore());
  }
}
