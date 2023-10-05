// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuGetResponse _$MenuGetResponseFromJson(Map<String, dynamic> json) =>
    MenuGetResponse(
      statusCode: json['statusCode'] as int,
      menuList: (json['menuList'] as List<dynamic>)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MenuGetResponseToJson(MenuGetResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'menuList': instance.menuList,
    };

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
      menu_Id: json['menu_Id'] as int,
      name: json['name'] as String,
      price: json['price'] as int,
      description: json['description'] as String,
      status: json['status'] as int,
    );

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
      'menu_Id': instance.menu_Id,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
      'status': instance.status,
    };
