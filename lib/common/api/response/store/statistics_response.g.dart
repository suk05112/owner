// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreStatisticsResponse _$StoreStatisticsResponseFromJson(
        Map<String, dynamic> json) =>
    StoreStatisticsResponse(
      total_issued: (json['total_issued'] as num).toInt(),
      total_used: (json['total_used'] as num).toInt(),
      total_unused: (json['total_unused'] as num).toInt(),
    );

Map<String, dynamic> _$StoreStatisticsResponseToJson(
        StoreStatisticsResponse instance) =>
    <String, dynamic>{
      'total_issued': instance.total_issued,
      'total_used': instance.total_used,
      'total_unused': instance.total_unused,
    };
