import 'package:json_annotation/json_annotation.dart';

part 'find_ownername_response.g.dart';

@JsonSerializable()
class FindOwnernameResponse {
  int? statusCode;
  int? owner_id;
  String? email;
  String? created_time;
  String? msg;

  FindOwnernameResponse({this.statusCode});

  factory FindOwnernameResponse.fromJson(Map<String, dynamic> json) =>
      _$FindOwnernameResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FindOwnernameResponseToJson(this);
}
