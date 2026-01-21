import 'package:json_annotation/json_annotation.dart';

part 'owner.g.dart';

@JsonSerializable()
class OwnerRegisterPost {
  String name;
  String email;
  String uid;
  String phone_number;

  OwnerRegisterPost(
      {required this.name,
      required this.email,
      required this.uid,
      required this.phone_number});

  factory OwnerRegisterPost.fromJson(Map<String, dynamic> json) =>
      _$OwnerRegisterPostFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerRegisterPostToJson(this);
}

@JsonSerializable()
class OwnerRegisterResponse {
  int? statusCode;
  int? owner_id;

  OwnerRegisterResponse({this.statusCode, this.owner_id});

  factory OwnerRegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$OwnerRegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerRegisterResponseToJson(this);
}

@JsonSerializable()
class OwnerFind {
  String name;
  String phone_number;

  OwnerFind({required this.name, required this.phone_number});

  factory OwnerFind.fromJson(Map<String, dynamic> json) =>
      _$OwnerFindFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerFindToJson(this);
}

@JsonSerializable()
class OwnerFindPw {
  String email;
  String phone_number;

  OwnerFindPw({required this.email, required this.phone_number});

  factory OwnerFindPw.fromJson(Map<String, dynamic> json) =>
      _$OwnerFindPwFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerFindPwToJson(this);
}

@JsonSerializable()
class OwnerLoginResponse {
  int? statusCode;
  int? owner_id;
  String name;
  String phone_number;
  String? msg;

  OwnerLoginResponse(
      {this.statusCode,
      required this.name,
      required this.phone_number});

  factory OwnerLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$OwnerLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerLoginResponseToJson(this);
}

@JsonSerializable()
class OwnerPushTokenPost {
  String push_token;

  OwnerPushTokenPost({required this.push_token});

  factory OwnerPushTokenPost.fromJson(Map<String, dynamic> json) =>
      _$OwnerPushTokenPostFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerPushTokenPostToJson(this);
}

@JsonSerializable()
class OwnerPushTokenResponse {
  String message;
  int owner_id;

  OwnerPushTokenResponse({required this.message, required this.owner_id});

  factory OwnerPushTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$OwnerPushTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerPushTokenResponseToJson(this);
}
