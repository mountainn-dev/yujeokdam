// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto_character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterRelationDto _$CharacterRelationDtoFromJson(
        Map<String, dynamic> json) =>
    CharacterRelationDto(
      targetId: json['target_id'] as String,
      label: json['label'] as String,
    );

CharacterDto _$CharacterDtoFromJson(Map<String, dynamic> json) => CharacterDto(
      id: json['id'] as String,
      name: json['name'] as String,
      portrait: json['portrait'] as String,
      lifespan: json['lifespan'] as String,
      oneLiner: json['one_liner'] as String,
      description: json['description'] as String,
      relations: (json['relations'] as List<dynamic>?)
              ?.map((e) =>
                  CharacterRelationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
