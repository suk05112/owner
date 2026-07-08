import 'package:json_annotation/json_annotation.dart';

part 'owner.g.dart';

class CheckDuplicateResponse {
  final bool emailExists;
  final bool phoneExists;

  CheckDuplicateResponse({required this.emailExists, required this.phoneExists});

  factory CheckDuplicateResponse.fromJson(Map<String, dynamic> json) =>
      CheckDuplicateResponse(
        emailExists: json['email_exists'] as bool? ?? false,
        phoneExists: json['phone_exists'] as bool? ?? false,
      );
}

@JsonSerializable()
class OwnerRegisterPost {
  String login_id;
  String email;
  String uid;
  String client_tx_id;

  OwnerRegisterPost(
      {required this.login_id,
      required this.email,
      required this.uid,
      required this.client_tx_id});

  factory OwnerRegisterPost.fromJson(Map<String, dynamic> json) =>
      _$OwnerRegisterPostFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerRegisterPostToJson(this);
}

class MokClientInfoResponse {
  final String serviceId;
  final String encryptReqClientInfo;
  final String serviceType;
  final String usageCode;
  final String retTransferType;
  final String returnUrl;
  final String encryptVersion;
  final String clientTxId;

  MokClientInfoResponse({
    required this.serviceId,
    required this.encryptReqClientInfo,
    required this.serviceType,
    required this.usageCode,
    required this.retTransferType,
    required this.returnUrl,
    required this.encryptVersion,
    required this.clientTxId,
  });

  factory MokClientInfoResponse.fromJson(Map<String, dynamic> json) =>
      MokClientInfoResponse(
        serviceId: json['serviceId'] as String,
        encryptReqClientInfo: json['encryptReqClientInfo'] as String,
        serviceType: json['serviceType'] as String,
        usageCode: json['usageCode'] as String,
        retTransferType: json['retTransferType'] as String,
        returnUrl: json['returnUrl'] as String,
        encryptVersion: json['encryptVersion'] as String,
        clientTxId: json['clientTxId'] as String,
      );
}

class MokAuthResult {
  final bool success;
  final String? name;
  final String? phone;
  final String? birthdate;
  final String? gender;
  final String clientTxId;

  MokAuthResult({
    required this.success,
    required this.clientTxId,
    this.name,
    this.phone,
    this.birthdate,
    this.gender,
  });

  factory MokAuthResult.fromJson(Map<String, dynamic> json, String clientTxId) =>
      MokAuthResult(
        success: json['success'] as bool? ?? false,
        clientTxId: clientTxId,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        birthdate: json['birthdate'] as String?,
        gender: json['gender'] as String?,
      );
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
  String? login_id;
  String? email;
  String? msg;

  OwnerLoginResponse(
      {this.statusCode,
      required this.name,
      required this.phone_number,
      this.login_id,
      this.email});

  factory OwnerLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$OwnerLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerLoginResponseToJson(this);
}

@JsonSerializable()
class OwnerPushTokenPost {
  String fcm_token;
  String device_type;

  OwnerPushTokenPost({required this.fcm_token, required this.device_type});

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
