import 'package:json_annotation/json_annotation.dart';

part 'dto_story.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class StoryMessageDto {
  /// "narration" | "chat".
  final String type;
  final String? characterId;
  final String text;

  StoryMessageDto({required this.type, required this.text, this.characterId});

  factory StoryMessageDto.fromJson(Map<String, dynamic> json) =>
      _$StoryMessageDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class StoryDto {
  final String id;
  final String title;
  final String siteId;
  @JsonKey(defaultValue: [])
  final List<String> characterIds;
  @JsonKey(defaultValue: [])
  final List<String> tags;
  @JsonKey(defaultValue: [])
  final List<String> sources;
  @JsonKey(defaultValue: [])
  final List<StoryMessageDto> messages;

  StoryDto({
    required this.id,
    required this.title,
    required this.siteId,
    required this.characterIds,
    required this.tags,
    required this.sources,
    required this.messages,
  });

  factory StoryDto.fromJson(Map<String, dynamic> json) =>
      _$StoryDtoFromJson(json);
}
