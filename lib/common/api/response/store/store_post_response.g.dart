// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorePostResponse _$StorePostResponseFromJson(Map<String, dynamic> json) =>
    StorePostResponse(
      statusCode: json['statusCode'] as int,
      storeId: json['store_id'] as int,
      store_logo_url: json['store_logo_url'] as String,
    )..presignedUrl = json['presignedUrl'] == null
        ? null
        : PresignedUrl.fromJson(json['presignedUrl'] as Map<String, dynamic>);

Map<String, dynamic> _$StorePostResponseToJson(StorePostResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'store_id': instance.storeId,
      'store_logo_url': instance.store_logo_url,
      'presignedUrl': instance.presignedUrl,
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
