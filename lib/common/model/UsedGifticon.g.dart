// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UsedGifticon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsedGifticon _$UsedGifticonFromJson(Map<String, dynamic> json) => UsedGifticon(
      id: (json['id'] as num).toInt(),
      used_time: DateTime.parse(json['used_time'] as String),
      menu_name: json['menu_name'] as String,
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$UsedGifticonToJson(UsedGifticon instance) =>
    <String, dynamic>{
      'id': instance.id,
      'used_time': instance.used_time.toIso8601String(),
      'menu_name': instance.menu_name,
      'price': instance.price,
    };

UsedGifticonList _$UsedGifticonListFromJson(Map<String, dynamic> json) =>
    UsedGifticonList(
      gifticonList: (json['gifticonList'] as List<dynamic>)
          .map((e) => UsedGifticon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsedGifticonListToJson(UsedGifticonList instance) =>
    <String, dynamic>{
      'gifticonList': instance.gifticonList,
    };

OwnerStore _$OwnerStoreFromJson(Map<String, dynamic> json) => OwnerStore(
      store_id: (json['store_id'] as num).toInt(),
      store_name: json['store_name'] as String,
    );

Map<String, dynamic> _$OwnerStoreToJson(OwnerStore instance) =>
    <String, dynamic>{
      'store_id': instance.store_id,
      'store_name': instance.store_name,
    };

OwnerStoreList _$OwnerStoreListFromJson(Map<String, dynamic> json) =>
    OwnerStoreList(
      ownerStoreList: (json['ownerStoreList'] as List<dynamic>)
          .map((e) => OwnerStore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OwnerStoreListToJson(OwnerStoreList instance) =>
    <String, dynamic>{
      'ownerStoreList': instance.ownerStoreList,
    };
