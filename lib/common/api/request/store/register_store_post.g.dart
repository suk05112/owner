// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_store_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterStorePost _$RegisterStorePostFromJson(Map<String, dynamic> json) =>
    RegisterStorePost(
      owner_id: json['owner_id'] as int,
      store_name: json['store_name'] as String,
      store_logo: json['store_logo'] as String,
      store_telephone: json['store_telephone'] as String,
      store_description: json['store_description'] as String,
      store_photo_cnt: json['store_photo_cnt'] as int,
      store_address: json['store_address'] as String,
      store_lat: (json['store_lat'] as num).toDouble(),
      store_lng: (json['store_lng'] as num).toDouble(),
      business_registration: json['business_registration'] as String,
    );

Map<String, dynamic> _$RegisterStorePostToJson(RegisterStorePost instance) =>
    <String, dynamic>{
      'owner_id': instance.owner_id,
      'store_name': instance.store_name,
      'store_logo': instance.store_logo,
      'store_telephone': instance.store_telephone,
      'store_description': instance.store_description,
      'store_photo_cnt': instance.store_photo_cnt,
      'store_address': instance.store_address,
      'store_lat': instance.store_lat,
      'store_lng': instance.store_lng,
      'business_registration': instance.business_registration,
    };
