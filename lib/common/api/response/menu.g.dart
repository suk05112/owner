// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuGetResponse _$MenuGetResponseFromJson(Map<String, dynamic> json) =>
    MenuGetResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      menuList: (json['menuList'] as List<dynamic>)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MenuGetResponseToJson(MenuGetResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'menuList': instance.menuList,
    };

MenuPostResponse _$MenuPostResponseFromJson(Map<String, dynamic> json) =>
    MenuPostResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      menu_id: (json['menu_id'] as num).toInt(),
      menu_put_url: json['menu_put_url'] as String,
      menu_get_url: json['menu_get_url'] as String,
    );

Map<String, dynamic> _$MenuPostResponseToJson(MenuPostResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'menu_id': instance.menu_id,
      'menu_put_url': instance.menu_put_url,
      'menu_get_url': instance.menu_get_url,
    };

MenuUpdateResponse _$MenuUpdateResponseFromJson(Map<String, dynamic> json) =>
    MenuUpdateResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      msg: json['msg'] as String,
      menu_put_url: json['menu_put_url'] as String,
      menu_get_url: json['menu_get_url'] as String,
    );

Map<String, dynamic> _$MenuUpdateResponseToJson(MenuUpdateResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'msg': instance.msg,
      'menu_put_url': instance.menu_put_url,
      'menu_get_url': instance.menu_get_url,
    };

MenuDeleteResponse _$MenuDeleteResponseFromJson(Map<String, dynamic> json) =>
    MenuDeleteResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$MenuDeleteResponseToJson(MenuDeleteResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'msg': instance.msg,
    };

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
      menu_id: (json['menu_id'] as num).toInt(),
      store_id: (json['store_id'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      menu_image_url: json['menu_image_url'] as String,
      description: json['description'] as String,
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
      'menu_id': instance.menu_id,
      'store_id': instance.store_id,
      'name': instance.name,
      'price': instance.price,
      'menu_image_url': instance.menu_image_url,
      'description': instance.description,
      'status': instance.status,
    };
