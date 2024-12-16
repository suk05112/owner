// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorePostResponse _$StorePostResponseFromJson(Map<String, dynamic> json) =>
    StorePostResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      store_id: (json['store_id'] as num).toInt(),
      store_logo_url: json['store_logo_url'] as String,
      store_photo_urls: (json['store_photo_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    )..presignedUrl = json['presignedUrl'] == null
        ? null
        : PresignedUrl.fromJson(json['presignedUrl'] as Map<String, dynamic>);

Map<String, dynamic> _$StorePostResponseToJson(StorePostResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'store_id': instance.store_id,
      'store_logo_url': instance.store_logo_url,
      'store_photo_urls': instance.store_photo_urls,
      'presignedUrl': instance.presignedUrl,
    };

StoreUpdateResponse _$StoreUpdateResponseFromJson(Map<String, dynamic> json) =>
    StoreUpdateResponse(
      statusCode: (json['statusCode'] as num).toInt(),
      msg: json['msg'] as String,
      store_photo_urls: (json['store_photo_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      store_photo_get_urls: (json['store_photo_get_urls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$StoreUpdateResponseToJson(
        StoreUpdateResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'msg': instance.msg,
      'store_photo_urls': instance.store_photo_urls,
      'store_photo_get_urls': instance.store_photo_get_urls,
    };

PresignedUrl _$PresignedUrlFromJson(Map<String, dynamic> json) => PresignedUrl(
      logo: json['logo'] as String?,
      storePhoto: (json['storePhoto'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PresignedUrlToJson(PresignedUrl instance) =>
    <String, dynamic>{
      'logo': instance.logo,
      'storePhoto': instance.storePhoto,
    };
