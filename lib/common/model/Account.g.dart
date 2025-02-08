// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      name: json['name'] as String?,
      code: json['code'] as String?,
      bank: json['bank'] as String?,
      account: json['account'] as String?,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'bank': instance.bank,
      'account': instance.account,
    };
