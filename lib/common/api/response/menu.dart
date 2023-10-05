import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class MenuGetResponse {
  int statusCode;
  List<Menu> menuList;

  MenuGetResponse({required this.statusCode, required this.menuList});

  factory MenuGetResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuGetResponseToJson(this);
}

@JsonSerializable()
class Menu {
  int menu_Id;
  String name;
  int price;
  String description;
  int status;

  Menu(
      {required this.menu_Id,
      required this.name,
      required this.price,
      required this.description,
      required this.status});

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
