// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafeInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CafeInfo _$CafeInfoFromJson(Map<String, dynamic> json) => CafeInfo(
      logo: json['logo'] as String?,
      store_name: json['store_name'] as String?,
      store_telephone: json['store_telephone'] as String?,
      owner_id: json['owner_id'] as String?,
      open_yn: json['open_yn'] as bool?,
      operatingHourId: json['operatingHourId'] as String?,
    );

Map<String, dynamic> _$CafeInfoToJson(CafeInfo instance) => <String, dynamic>{
      'logo': instance.logo,
      'store_name': instance.store_name,
      'store_telephone': instance.store_telephone,
      'owner_id': instance.owner_id,
      'open_yn': instance.open_yn,
      'operatingHourId': instance.operatingHourId,
    };
