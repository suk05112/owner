import 'package:json_annotation/json_annotation.dart';

part 'update_store_post.g.dart';

@JsonSerializable()
class UpdateStorePost {
  int owner_id, sotre_id;
  String? store_telephone;
  String? store_description;
  String? store_photo;

  UpdateStorePost({
    required this.owner_id,
    required this.sotre_id,
    required this.store_telephone,
    required this.store_description,
    required this.store_photo,
  });

  factory UpdateStorePost.fromJson(Map<String, dynamic> json) =>
      _$UpdateStorePostFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateStorePostToJson(this);
}
