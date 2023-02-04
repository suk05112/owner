import 'package:json_annotation/json_annotation.dart';

part 'cafeInfo.g.dart';

@JsonSerializable()
class CafeInfo {
  String? name, logo, address, intro, isOpen, telephone, business_registration;

  CafeInfo({
    required this.name,
    required this.logo,
    required this.address,
    required this.intro,
    required this.isOpen,
    required this.telephone,
    required this.business_registration,
  });

  @override
  toString() {
    return 'name: ${this.name} \n'
        'address: ${this.address} \n'
        'intro: ${this.intro} \n'
        'intro: ${this.intro}\n'
        'isOpen: ${this.isOpen}\n'
        'telephone: ${this.telephone}\n'
        'business_registration: ${this.business_registration}\n';
  }

  factory CafeInfo.fromJson(Map<String, dynamic> json) =>
      _$CafeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CafeInfoToJson(this);
}
