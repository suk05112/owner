import 'dart:ffi';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'Account.g.dart';

@JsonSerializable()
class Account {
  String? name;
  String? code;
  String? bank;
  String? account;

  Account({this.name, this.code, this.bank, this.account});

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
  Map<String, dynamic> toJson() => _$AccountToJson(this);
}
