import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'Settlement.g.dart';

@JsonSerializable()
class Settlement {
  int settlement_id;
  int total_price;
  String? settlement_msg;
  DateTime settlement_date;
  int settlement_period;
  int status;

  Settlement(
      {required this.settlement_id,
      required this.total_price,
      this.settlement_msg,
      required this.settlement_date,
      required this.settlement_period,
      required this.status});

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
