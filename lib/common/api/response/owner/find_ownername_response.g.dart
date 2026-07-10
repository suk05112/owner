// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_ownername_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindOwnernameResponse _$FindOwnernameResponseFromJson(
        Map<String, dynamic> json) =>
    FindOwnernameResponse(
      statusCode: (json['statusCode'] as num?)?.toInt(),
    )
      ..owner_id = (json['owner_id'] as num?)?.toInt()
      ..email = json['email'] as String?
      ..login_id = json['login_id'] as String?
      ..created_time = json['created_time'] as String?
      ..msg = json['msg'] as String?;

Map<String, dynamic> _$FindOwnernameResponseToJson(
        FindOwnernameResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'owner_id': instance.owner_id,
      'email': instance.email,
      'login_id': instance.login_id,
      'created_time': instance.created_time,
      'msg': instance.msg,
    };
