import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class MenuGetResponse {
  @JsonKey(defaultValue: 200)
  int statusCode;
  List<Menu> menuList;

  MenuGetResponse({required this.statusCode, required this.menuList});

  factory MenuGetResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuGetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuGetResponseToJson(this);
}

@JsonSerializable()
class MenuPostResponse {
  int? statusCode;
  int menu_id;
  String menu_put_url;
  String menu_get_url;

  MenuPostResponse(
      {this.statusCode,
      required this.menu_id,
      required this.menu_put_url,
      required this.menu_get_url});

  factory MenuPostResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuPostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuPostResponseToJson(this);
}

@JsonSerializable()
class MenuUpdateResponse {
  int? statusCode;
  String? msg;
  String menu_put_url;
  String menu_get_url;

  MenuUpdateResponse(
      {this.statusCode,
      this.msg,
      required this.menu_put_url,
      required this.menu_get_url});

  factory MenuUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuUpdateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuUpdateResponseToJson(this);
}

@JsonSerializable()
class MenuDeleteResponse {
  int statusCode;
  String msg;

  MenuDeleteResponse({required this.statusCode, required this.msg});

  factory MenuDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuDeleteResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MenuDeleteResponseToJson(this);
}

@JsonSerializable()
class Menu {
  int menu_id;
  int? store_id;
  String name;
  int price;
  @JsonKey(name: 'menu_photo')
  String? menu_image_url;
  String description;
  String status;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool? delete_image;

  Menu(
      {required this.menu_id,
      this.store_id,
      required this.name,
      required this.price,
      this.menu_image_url,
      required this.description,
      this.status = 'ACTIVE',
      this.delete_image});

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() {
    final map = _$MenuToJson(this);
    if (delete_image == true) map['delete_image'] = true;
    return map;
  }
}
