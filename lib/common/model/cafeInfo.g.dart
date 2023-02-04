part of 'cafeInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CafeInfo _$CafeInfoFromJson(Map<String, dynamic> json) => CafeInfo(
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      address: json['address'] as String?,
      intro: json['intro'] as String?,
      isOpen: json['isOpen'] as String,
      telephone: json['telephone'] as String,
      business_registration: json['business_registration'] as String?,
    );

Map<String, dynamic> _$CafeInfoToJson(CafeInfo instance) => <String, dynamic>{
      'name': instance.name,
      'logo': instance.logo,
      'address': instance.address,
      'intro': instance.intro,
      'isOpen': instance.isOpen,
      'telephone': instance.telephone,
      'business_registration': instance.business_registration,
    };
