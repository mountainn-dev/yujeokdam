import 'package:json_annotation/json_annotation.dart';

part 'dto_character.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CharacterRelationDto {
  final String targetId;
  final String label;

  CharacterRelationDto({required this.targetId, required this.label});

  factory CharacterRelationDto.fromJson(Map<String, dynamic> json) =>
      _$CharacterRelationDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class CharacterDto {
  final String id;
  final String name;
  final String portrait;
  final String lifespan;
  final String oneLiner;
  final String description;
  @JsonKey(defaultValue: [])
  final List<CharacterRelationDto> relations;

  CharacterDto({
    required this.id,
    required this.name,
    required this.portrait,
    required this.lifespan,
    required this.oneLiner,
    required this.description,
    required this.relations,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) =>
      _$CharacterDtoFromJson(json);
}
