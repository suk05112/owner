import 'package:json_annotation/json_annotation.dart';

// part '../../model/response/gifticonPatchResponse.g.dart';

part 'GifticonResponse.g.dart';

@JsonSerializable()
class GifticonPatchResponse {
  int result;

  GifticonPatchResponse({required this.result});

  factory GifticonPatchResponse.fromJson(Map<String, dynamic> json) =>
      _$GifticonPatchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GifticonPatchResponseToJson(this);
}
