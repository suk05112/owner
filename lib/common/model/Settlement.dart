import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'Settlement.g.dart';

int _numToInt(dynamic v) => v == null ? 0 : (v as num).toInt();

int _statusToInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is String) return v.toUpperCase() == 'PENDING' ? 0 : 1;
  return 0;
}

DateTime _parsePayoutDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.parse(v as String);
}

@JsonSerializable()
class Settlement {
  int settlement_id;
  @JsonKey(name: 'expected_amount', fromJson: _numToInt)
  int total_price;
  String? settlement_msg;
  @JsonKey(name: 'expected_payout_date', fromJson: _parsePayoutDate)
  DateTime settlement_date;
  @JsonKey(name: 'cycle_id', fromJson: _numToInt)
  int settlement_period;
  @JsonKey(fromJson: _statusToInt)
  int status;
  @JsonKey(name: 'period_start')
  String? period_start;
  @JsonKey(name: 'period_end')
  String? period_end;

  Settlement(
      {required this.settlement_id,
      required this.total_price,
      this.settlement_msg,
      required this.settlement_date,
      required this.settlement_period,
      required this.status,
      this.period_start,
      this.period_end});

  factory Settlement.fromJson(Map<String, dynamic> json) =>
      _$SettlementFromJson(json);
  Map<String, dynamic> toJson() => _$SettlementToJson(this);
}

@JsonSerializable()
class DetailSettlement {
  String menu_name;
  int commission;
  int price;
  int deposit;
  DateTime? used_time;

  DetailSettlement(
      {required this.menu_name,
      required this.commission,
      required this.price,
      required this.deposit,
      this.used_time});

  factory DetailSettlement.fromJson(Map<String, dynamic> json) =>
      _$DetailSettlementFromJson(json);
  Map<String, dynamic> toJson() => _$DetailSettlementToJson(this);
}

@JsonSerializable()
class SettlementList {
  String? msg;
  List<Settlement> settlements;

  SettlementList({this.msg, required this.settlements});

  factory SettlementList.fromJson(Map<String, dynamic> json) =>
      _$SettlementListFromJson(json);
  Map<String, dynamic> toJson() => _$SettlementListToJson(this);
}

@JsonSerializable()
class DetailSettlementList {
  String? msg;
  @JsonKey(name: 'detail_settlements')
  List<DetailSettlement> detailSettlements;

  DetailSettlementList({this.msg, required this.detailSettlements});

  factory DetailSettlementList.fromJson(Map<String, dynamic> json) =>
      _$DetailSettlementListFromJson(json);
  Map<String, dynamic> toJson() => _$DetailSettlementListToJson(this);
}
