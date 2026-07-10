import 'package:json_annotation/json_annotation.dart';

part 'owner.g.dart';

class TermAgreementItem {
  final int termId;
  final int termVersionId;
  final bool agreed;

  TermAgreementItem({
    required this.termId,
    required this.termVersionId,
    required this.agreed,
  });

  Map<String, dynamic> toJson() => {
        'term_id': termId,
        'term_version_id': termVersionId,
        'agreed': agreed,
      };
}

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
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<TermAgreementItem> agreements;

  OwnerRegisterPost(
      {required this.login_id,
      required this.email,
      required this.uid,
      required this.client_tx_id,
      this.agreements = const []});

  factory OwnerRegisterPost.fromJson(Map<String, dynamic> json) =>
      _$OwnerRegisterPostFromJson(json);
  Map<String, dynamic> toJson() => {
        ..._$OwnerRegisterPostToJson(this),
        'agreements': agreements.map((e) => e.toJson()).toList(),
      };
}

class MokAuthResult {
  final bool success;
  final String clientTxId;

  MokAuthResult({
    required this.success,
    required this.clientTxId,
  });
}

@JsonSerializable()
class OwnerRegisterResponse {
  int? statusCode;
  int? owner_id;
  String? phone_number;

  OwnerRegisterResponse({this.statusCode, this.owner_id, this.phone_number});

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
  String login_id;
  String phone_number;

  OwnerFindPw({required this.login_id, required this.phone_number});

  factory OwnerFindPw.fromJson(Map<String, dynamic> json) =>
      _$OwnerFindPwFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerFindPwToJson(this);
}

class ResetPasswordPublicKeyResponse {
  final String publicKey;

  ResetPasswordPublicKeyResponse({required this.publicKey});

  factory ResetPasswordPublicKeyResponse.fromJson(Map<String, dynamic> json) =>
      ResetPasswordPublicKeyResponse(publicKey: json['public_key'] as String);
}

@JsonSerializable()
class OwnerResetPassword {
  String login_id;
  String phone_number;
  String encrypted_password;

  OwnerResetPassword({
    required this.login_id,
    required this.phone_number,
    required this.encrypted_password,
  });

  factory OwnerResetPassword.fromJson(Map<String, dynamic> json) =>
      _$OwnerResetPasswordFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerResetPasswordToJson(this);
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
