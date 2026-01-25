import 'package:json_annotation/json_annotation.dart';

part 'statistics_response.g.dart';

@JsonSerializable()
class StoreStatisticsResponse {
  int total_issued;
  int total_used;
  int total_unused;

  StoreStatisticsResponse({
    required this.total_issued,
    required this.total_used,
    required this.total_unused,
  });

  factory StoreStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreStatisticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StoreStatisticsResponseToJson(this);
}
