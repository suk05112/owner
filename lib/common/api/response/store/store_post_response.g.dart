// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_post_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorePhoto _$StorePhotoFromJson(Map<String, dynamic> json) => StorePhoto(
      image_key: json['image_key'] as String,
      put_url: json['put_url'] as String,
    );

Map<String, dynamic> _$StorePhotoToJson(StorePhoto instance) =>
    <String, dynamic>{
      'image_key': instance.image_key,
      'put_url': instance.put_url,
    };

StorePostResponse _$StorePostResponseFromJson(Map<String, dynamic> json) =>
    StorePostResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      store_id: (json['store_id'] as num).toInt(),
      store_logo_url: json['store_logo_url'] as String,
      store_photos: (json['store_photos'] as List<dynamic>)
          .map((e) => StorePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      bankBook_put_url: json['bankBook_put_url'] as String,
      business_put_url: json['business_put_url'] as String?,
    )..presignedUrl = json['presignedUrl'] == null
        ? null
        : PresignedUrl.fromJson(json['presignedUrl'] as Map<String, dynamic>);

Map<String, dynamic> _$StorePostResponseToJson(StorePostResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'store_id': instance.store_id,
      'store_logo_url': instance.store_logo_url,
      'store_photos': instance.store_photos,
      'presignedUrl': instance.presignedUrl,
      'bankBook_put_url': instance.bankBook_put_url,
      'business_put_url': instance.business_put_url,
    };

StoreUpdateResponse _$StoreUpdateResponseFromJson(Map<String, dynamic> json) =>
    StoreUpdateResponse(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      msg: json['msg'] as String,
      store_photos: (json['store_photos'] as List<dynamic>)
          .map((e) => StorePhoto.fromJson(e as Map<String, dynamic>))
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
      'store_photos': instance.store_photos,
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
