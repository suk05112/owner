// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_store_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateStorePost _$UpdateStorePostFromJson(Map<String, dynamic> json) =>
    UpdateStorePost(
      owner_id: (json['owner_id'] as num).toInt(),
      sotre_id: (json['sotre_id'] as num).toInt(),
      store_telephone: json['store_telephone'] as String?,
      store_description: json['store_description'] as String?,
      store_photo: json['store_photo'] as String?,
    );

Map<String, dynamic> _$UpdateStorePostToJson(UpdateStorePost instance) =>
    <String, dynamic>{
      'owner_id': instance.owner_id,
      'sotre_id': instance.sotre_id,
      'store_telephone': instance.store_telephone,
      'store_description': instance.store_description,
      'store_photo': instance.store_photo,
    };
