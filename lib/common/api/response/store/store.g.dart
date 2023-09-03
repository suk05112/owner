// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Body2 _$Body2FromJson(Map<String, dynamic> json) => Body2(
      store: (json['store'] as List<dynamic>)
          .map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$Body2ToJson(Body2 instance) => <String, dynamic>{
      'store': instance.store,
    };

StoreListResponse _$StoreListResponseFromJson(Map<String, dynamic> json) =>
    StoreListResponse(
      statusCode: json['statusCode'] as int,
      body: Body2.fromJson(json['body'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreListResponseToJson(StoreListResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'body': instance.body,
    };

StoreResponse _$StoreResponseFromJson(Map<String, dynamic> json) =>
    StoreResponse(
      statusCode: json['statusCode'] as int,
      store: Store.fromJson(json['store'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreResponseToJson(StoreResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'store': instance.store,
    };

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
      owner_id: json['owner_id'] as int,
      store_id: json['store_id'] as int,
      store_name: json['store_name'] as String,
      store_telephone: json['store_telephone'] as String,
      store_address: json['store_address'] as String,
      store_description: json['store_description'] as String,
      store_photo: json['store_photo'] as String?,
      store_logo: json['store_logo'] as String,
      status: json['status'] as int?,
      inspection_status: json['inspection_status'] as int,
      open_yn: json['open_yn'] as int?,
      store_lat: (json['store_lat'] as num?)?.toDouble(),
      store_lng: (json['store_lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'owner_id': instance.owner_id,
      'store_id': instance.store_id,
      'store_name': instance.store_name,
      'store_telephone': instance.store_telephone,
      'store_address': instance.store_address,
      'store_description': instance.store_description,
      'store_photo': instance.store_photo,
      'store_logo': instance.store_logo,
      'status': instance.status,
      'inspection_status': instance.inspection_status,
      'open_yn': instance.open_yn,
      'store_lat': instance.store_lat,
      'store_lng': instance.store_lng,
    };

StoreCard _$StoreCardFromJson(Map<String, dynamic> json) => StoreCard(
      status: json['status'] as int,
      store_name: json['store_name'] as String,
      store_logo: json['store_logo'] as String,
    );

Map<String, dynamic> _$StoreCardToJson(StoreCard instance) => <String, dynamic>{
      'status': instance.status,
      'store_name': instance.store_name,
      'store_logo': instance.store_logo,
    };
