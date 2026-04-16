import 'package:cloud_firestore/cloud_firestore.dart';

class Option {
  String? optionId;
  String? name;
  int? price;
  String? description;

  Option({
    required this.optionId,
    required this.name,
    required this.price,
    this.description,
  });

  Option.fromJson(dynamic json) {
    optionId = json['optionId'];
    name = json['name'];
    price = json['price'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'optionId': optionId,
      'name': name,
      'price': price,
      'description': description,
    };
  }
}