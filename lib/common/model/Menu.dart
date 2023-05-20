import 'package:cloud_firestore/cloud_firestore.dart';

class Menu {
  String? name;
  String? menuId;
  String? storeId;
  String? description;
  int? price;
  String? status;
  String? categoryId;
  DocumentReference? reference;

  Menu(
      {required this.name,
      required this.menuId,
      required this.storeId,
      required this.description,
      required this.price,
      required this.status,
      required this.categoryId,
      this.reference});

  Menu.fromJson(dynamic json, this.reference) {
    name = json['name'];
    menuId = json['menuId'];
    storeId = json['storeId'];
    description = json['description'];
    price = json['price'];
    status = json['status'];
    categoryId = json['categoryId'];
  }

  Menu.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapShot)
      : this.fromJson(snapShot.data(), snapShot.reference);

  Menu.fromQuerySnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  factory Menu.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Menu(
        name: data['name'],
        menuId: data['menuId'],
        storeId: data['storeId'],
        description: data['description'],
        price: data['price'],
        status: data['status'],
        categoryId: data['categoryId']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (menuId != null) "menuId": menuId,
      if (storeId != null) "storeId": storeId,
      if (description != null) "description": description,
      if (price != null) "price": price,
      if (status != null) "status": status,
      if (categoryId != null) "categoryId": categoryId,
    };
  }
}
