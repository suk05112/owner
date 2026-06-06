// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Settlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settlement _$SettlementFromJson(Map<String, dynamic> json) => Settlement(
      settlement_id: _optionalIntFromJson(json['settlement_id']),
      total_price: _numToInt(json['expected_amount']),
      settlement_msg: json['settlement_msg'] as String?,
      settlement_date: _parsePayoutDate(json['expected_payout_date']),
      settlement_period: _numToInt(json['cycle_id']),
      status: json['status'] as String?,
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

SettlementDetailItem _$SettlementDetailItemFromJson(
        Map<String, dynamic> json) =>
    SettlementDetailItem(
      id: _optionalIntFromJson(json['id']),
      gifticon_id:
          json['gifticon_id'] == null ? 0 : _numToInt(json['gifticon_id']),
      menu_name: json['menu_name'] as String?,
      used_at: json['used_at'] as String?,
      amount: json['amount'] == null ? 0 : _numToInt(json['amount']),
      fee_amount:
          json['fee_amount'] == null ? 0 : _numToInt(json['fee_amount']),
      settlement_amount: json['settlement_amount'] == null
          ? 0
          : _numToInt(json['settlement_amount']),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$SettlementDetailItemToJson(
        SettlementDetailItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gifticon_id': instance.gifticon_id,
      'menu_name': instance.menu_name,
      'used_at': instance.used_at,
      'amount': instance.amount,
      'fee_amount': instance.fee_amount,
      'settlement_amount': instance.settlement_amount,
      'status': instance.status,
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

SettlementSummary _$SettlementSummaryFromJson(Map<String, dynamic> json) =>
    SettlementSummary(
      settlement_id: (json['settlement_id'] as num?)?.toInt(),
      store_id: (json['store_id'] as num?)?.toInt(),
      cycle_id: json['cycle_id'] == null ? 0 : _numToInt(json['cycle_id']),
      period_start: json['period_start'] as String?,
      period_end: json['period_end'] as String?,
      total_sales_amount: json['total_sales_amount'] == null
          ? 0
          : _numToInt(json['total_sales_amount']),
      total_fee_amount: json['total_fee_amount'] == null
          ? 0
          : _numToInt(json['total_fee_amount']),
      net_payout_amount: json['net_payout_amount'] == null
          ? 0
          : _numToInt(json['net_payout_amount']),
      status: json['status'] as String?,
      payout_date: json['payout_date'] as String?,
      failure_reason: json['failure_reason'] as String?,
      base_fee_rate: (json['base_fee_rate'] as num?)?.toDouble(),
      promo_fee_rate: (json['promo_fee_rate'] as num?)?.toDouble(),
      promo_discount_amount:
          _optionalIntFromJson(json['promo_discount_amount']),
      supply_amount:
          json['supply_amount'] == null ? 0 : _numToInt(json['supply_amount']),
      vat_amount:
          json['vat_amount'] == null ? 0 : _numToInt(json['vat_amount']),
    );

Map<String, dynamic> _$SettlementSummaryToJson(SettlementSummary instance) =>
    <String, dynamic>{
      'settlement_id': instance.settlement_id,
      'store_id': instance.store_id,
      'cycle_id': instance.cycle_id,
      'period_start': instance.period_start,
      'period_end': instance.period_end,
      'total_sales_amount': instance.total_sales_amount,
      'total_fee_amount': instance.total_fee_amount,
      'net_payout_amount': instance.net_payout_amount,
      'status': instance.status,
      'payout_date': instance.payout_date,
      'failure_reason': instance.failure_reason,
      'base_fee_rate': instance.base_fee_rate,
      'promo_fee_rate': instance.promo_fee_rate,
      'promo_discount_amount': instance.promo_discount_amount,
      'supply_amount': instance.supply_amount,
      'vat_amount': instance.vat_amount,
    };

SettlementDetailResponse _$SettlementDetailResponseFromJson(
        Map<String, dynamic> json) =>
    SettlementDetailResponse(
      settlement: SettlementSummary.fromJson(
          json['settlement'] as Map<String, dynamic>),
      details: (json['details'] as List<dynamic>)
          .map((e) => SettlementDetailItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      parseFailureCount: (json['parseFailureCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SettlementDetailResponseToJson(
        SettlementDetailResponse instance) =>
    <String, dynamic>{
      'settlement': instance.settlement,
      'details': instance.details,
      'parseFailureCount': instance.parseFailureCount,
    };
