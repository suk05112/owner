import 'dart:convert';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';

// part '../../model/response/gifticonPatchResponse.g.dart';

part 'GifticonResponse.g.dart';

@JsonSerializable()
class GifticonPatchResponse {
  int statusCode;

  GifticonPatchResponse({required this.statusCode});

  factory GifticonPatchResponse.fromJson(Map<String, dynamic> json) =>
      _$GifticonPatchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GifticonPatchResponseToJson(this);
}
