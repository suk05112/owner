// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settlement _$SettlementFromJson(Map<String, dynamic> json) => Settlement(
      settlement_id: (json['settlement_id'] as num).toInt(),
      total_price: _numToInt(json['expected_amount']),
      settlement_msg: json['settlement_msg'] as String?,
      settlement_date: _parsePayoutDate(json['expected_payout_date']),
      settlement_period: _numToInt(json['cycle_id']),
      status: _statusToInt(json['status']),
      period_start: json['period_start'] as String?,
      period_end: json['period_end'] as String?,
    );

Map<String, dynamic> _$SettlementToJson(Settlement instance) =>
    <String, dynamic>{
      'settlement_id': instance.settlement_id,
      'expected_amount': instance.total_price,
      'settlement_msg': instance.settlement_msg,
      'expected_payout_date': instance.settlement_date.toIso8601String(),
      'cycle_id': instance.settlement_period,
      'status': instance.status,
      'period_start': instance.period_start,
      'period_end': instance.period_end,
    };

DetailSettlement _$DetailSettlementFromJson(Map<String, dynamic> json) =>
    DetailSettlement(
      menu_name: json['menu_name'] as String,
      commission: (json['commission'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      deposit: (json['deposit'] as num).toInt(),
      used_time: json['used_time'] == null
          ? null
          : DateTime.parse(json['used_time'] as String),
    );

Map<String, dynamic> _$DetailSettlementToJson(DetailSettlement instance) =>
    <String, dynamic>{
      'menu_name': instance.menu_name,
      'commission': instance.commission,
      'price': instance.price,
      'deposit': instance.deposit,
      'used_time': instance.used_time?.toIso8601String(),
    };

SettlementList _$SettlementListFromJson(Map<String, dynamic> json) =>
    SettlementList(
      msg: json['msg'] as String?,
      settlements: (json['settlements'] as List<dynamic>)
          .map((e) => Settlement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SettlementListToJson(SettlementList instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'settlements': instance.settlements,
    };

DetailSettlementList _$DetailSettlementListFromJson(
        Map<String, dynamic> json) =>
    DetailSettlementList(
      msg: json['msg'] as String?,
      detailSettlements: (json['detail_settlements'] as List<dynamic>)
          .map((e) => DetailSettlement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DetailSettlementListToJson(
        DetailSettlementList instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'detail_settlements': instance.detailSettlements,
    };
