import 'package:json_annotation/json_annotation.dart';

part 'dto_heritage_site.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class HeritageSiteDto {
  final String id;
  final String name;
  final String tourApiContentId;
  final String tourApiContentTypeId;

  HeritageSiteDto({
    required this.id,
    required this.name,
    required this.tourApiContentId,
    required this.tourApiContentTypeId,
  });

  factory HeritageSiteDto.fromJson(Map<String, dynamic> json) =>
      _$HeritageSiteDtoFromJson(json);
}
