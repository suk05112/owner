// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerRegisterPost _$OwnerRegisterPostFromJson(Map<String, dynamic> json) =>
    OwnerRegisterPost(
      name: json['name'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
      phone_number: json['phone_number'] as String,
    );

Map<String, dynamic> _$OwnerRegisterPostToJson(OwnerRegisterPost instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'uid': instance.uid,
      'phone_number': instance.phone_number,
    };

OwnerRegisterResponse _$OwnerRegisterResponseFromJson(
        Map<String, dynamic> json) =>
    OwnerRegisterResponse(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      owner_id: (json['owner_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OwnerRegisterResponseToJson(
        OwnerRegisterResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'owner_id': instance.owner_id,
    };

OwnerFind _$OwnerFindFromJson(Map<String, dynamic> json) => OwnerFind(
      name: json['name'] as String,
      phone_number: json['phone_number'] as String,
    );

Map<String, dynamic> _$OwnerFindToJson(OwnerFind instance) => <String, dynamic>{
      'name': instance.name,
      'phone_number': instance.phone_number,
    };

OwnerFindPw _$OwnerFindPwFromJson(Map<String, dynamic> json) => OwnerFindPw(
      email: json['email'] as String,
      phone_number: json['phone_number'] as String,
    );

Map<String, dynamic> _$OwnerFindPwToJson(OwnerFindPw instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone_number': instance.phone_number,
    };

OwnerLoginResponse _$OwnerLoginResponseFromJson(Map<String, dynamic> json) =>
    OwnerLoginResponse(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      name: json['name'] as String,
      phone_number: json['phone_number'] as String,
    )
      ..owner_id = (json['owner_id'] as num?)?.toInt()
      ..msg = json['msg'] as String?;

Map<String, dynamic> _$OwnerLoginResponseToJson(OwnerLoginResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'owner_id': instance.owner_id,
      'name': instance.name,
      'phone_number': instance.phone_number,
      'msg': instance.msg,
    };

OwnerPushTokenPost _$OwnerPushTokenPostFromJson(Map<String, dynamic> json) =>
    OwnerPushTokenPost(
      fcm_token: json['fcm_token'] as String,
      device_type: json['device_type'] as String,
    );

Map<String, dynamic> _$OwnerPushTokenPostToJson(OwnerPushTokenPost instance) =>
    <String, dynamic>{
      'fcm_token': instance.fcm_token,
      'device_type': instance.device_type,
    };

OwnerPushTokenResponse _$OwnerPushTokenResponseFromJson(
        Map<String, dynamic> json) =>
    OwnerPushTokenResponse(
      message: json['message'] as String,
      owner_id: (json['owner_id'] as num).toInt(),
    );

Map<String, dynamic> _$OwnerPushTokenResponseToJson(
        OwnerPushTokenResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'owner_id': instance.owner_id,
    };
