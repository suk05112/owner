import 'package:json_annotation/json_annotation.dart';

part 'Settlement.g.dart';

int _numToInt(dynamic v) => v == null ? 0 : (v as num).toInt();

int? _optionalIntFromJson(dynamic v) => v == null ? null : (v as num).toInt();

DateTime _parsePayoutDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.parse(v as String);
}

@JsonSerializable()
class Settlement {
  @JsonKey(fromJson: _optionalIntFromJson)
  int? settlement_id;
  @JsonKey(name: 'expected_amount', fromJson: _numToInt)
  int total_price;
  String? settlement_msg;
  @JsonKey(name: 'expected_payout_date', fromJson: _parsePayoutDate)
  DateTime settlement_date;
  @JsonKey(name: 'cycle_id', fromJson: _numToInt)
  int settlement_period;
  String? status;
  @JsonKey(name: 'period_start')
  String? period_start;
  @JsonKey(name: 'period_end')
  String? period_end;

  Settlement(
      {this.settlement_id,
      required this.total_price,
      this.settlement_msg,
      required this.settlement_date,
      required this.settlement_period,
      this.status,
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

/// GET /settlement/detail/{id} 응답의 details[] 한 건: id, gifticon_id, menu_name, used_at, amount, fee_amount, settlement_amount, status
@JsonSerializable()
class SettlementDetailItem {
  int id;
  @JsonKey(name: 'gifticon_id', fromJson: _numToInt)
  int gifticon_id;
  @JsonKey(name: 'menu_name')
  String? menu_name;
  @JsonKey(name: 'used_at')
  String? used_at;
  @JsonKey(fromJson: _numToInt)
  int amount;
  @JsonKey(name: 'fee_amount', fromJson: _numToInt)
  int fee_amount;
  @JsonKey(name: 'settlement_amount', fromJson: _numToInt)
  int settlement_amount;
  String? status;

  SettlementDetailItem({
    required this.id,
    this.gifticon_id = 0,
    this.menu_name,
    this.used_at,
    this.amount = 0,
    this.fee_amount = 0,
    this.settlement_amount = 0,
    this.status,
  });

  factory SettlementDetailItem.fromJson(Map<String, dynamic> json) =>
      _$SettlementDetailItemFromJson(json);
  Map<String, dynamic> toJson() => _$SettlementDetailItemToJson(this);
}

@JsonSerializable()
class SettlementList {
  String? msg;
  List<Settlement> settlements;

  SettlementList({this.msg, required this.settlements});

  factory SettlementList.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SettlementList(settlements: []);
    final raw = json['settlements'];
    if (raw == null || raw is! List) return SettlementList(settlements: []);
    final list = <Settlement>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        try {
          list.add(Settlement.fromJson(e));
        } catch (_) {}
      }
    }
    return SettlementList(msg: json['msg'] as String?, settlements: list);
  }
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

/// GET /settlement/detail/{id} 응답의 settlement 객체
@JsonSerializable()
class SettlementSummary {
  int? settlement_id;
  int? store_id;
  @JsonKey(name: 'cycle_id', fromJson: _numToInt)
  int cycle_id;
  @JsonKey(name: 'period_start')
  String? period_start;
  @JsonKey(name: 'period_end')
  String? period_end;
  @JsonKey(name: 'total_sales_amount', fromJson: _numToInt)
  int total_sales_amount;
  @JsonKey(name: 'total_fee_amount', fromJson: _numToInt)
  int total_fee_amount;
  @JsonKey(name: 'net_payout_amount', fromJson: _numToInt)
  int net_payout_amount;
  String? status;
  @JsonKey(name: 'payout_date')
  String? payout_date;
  @JsonKey(name: 'failure_reason')
  String? failure_reason;

  SettlementSummary({
    this.settlement_id,
    this.store_id,
    this.cycle_id = 0,
    this.period_start,
    this.period_end,
    this.total_sales_amount = 0,
    this.total_fee_amount = 0,
    this.net_payout_amount = 0,
    this.status,
    this.payout_date,
    this.failure_reason,
  });

  factory SettlementSummary.fromJson(Map<String, dynamic> json) =>
      _$SettlementSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$SettlementSummaryToJson(this);
}

/// GET /settlement/detail/{id} 전체 응답: { settlement, details }
@JsonSerializable()
class SettlementDetailResponse {
  SettlementSummary settlement;
  List<SettlementDetailItem> details;

  SettlementDetailResponse({required this.settlement, required this.details});

  factory SettlementDetailResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SettlementDetailResponse(
        settlement: SettlementSummary(),
        details: [],
      );
    }
    SettlementSummary s;
    try {
      final raw = json['settlement'];
      s = (raw is Map<String, dynamic>)
          ? SettlementSummary.fromJson(raw)
          : SettlementSummary();
    } catch (_) {
      s = SettlementSummary();
    }
    List<SettlementDetailItem> list = [];
    try {
      final raw = json['details'] ?? json['detail_settlements'];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map<String, dynamic>) {
            try {
              list.add(SettlementDetailItem.fromJson(e));
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    return SettlementDetailResponse(settlement: s, details: list);
  }
  Map<String, dynamic> toJson() => _$SettlementDetailResponseToJson(this);
}
