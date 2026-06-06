import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int owner_id;
  String name;
  String? login_id;
  String? email;
  String phone_number;

  User({
    required this.owner_id,
    required this.name,
    this.login_id,
    this.email,
    required this.phone_number,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
