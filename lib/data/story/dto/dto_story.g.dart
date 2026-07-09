// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto_story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryMessageDto _$StoryMessageDtoFromJson(Map<String, dynamic> json) =>
    StoryMessageDto(
      type: json['type'] as String,
      text: json['text'] as String,
      characterId: json['character_id'] as String?,
    );

StoryDto _$StoryDtoFromJson(Map<String, dynamic> json) => StoryDto(
      id: json['id'] as String,
      title: json['title'] as String,
      siteId: json['site_id'] as String,
      characterIds: (json['character_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => StoryMessageDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
