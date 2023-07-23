// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorePostResponse _$StorePostResponseFromJson(Map<String, dynamic> json) =>
    StorePostResponse(
      statusCode: json['statusCode'] as int,
      storeId: json['storeId'] as int,
    );

Map<String, dynamic> _$StorePostResponseToJson(StorePostResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'storeId': instance.storeId,
    };
