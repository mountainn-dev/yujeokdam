import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yujeokdam/data/character/dto/dto_character.dart';
import 'package:yujeokdam/data/heritage/dto/dto_heritage_site.dart';
import 'package:yujeokdam/data/story/dto/dto_story.dart';

void main() {
  test('assets/content JSON 이 DTO 로 전부 파싱된다', () {
    final sites = (jsonDecode(
      File('assets/content/sites.json').readAsStringSync(),
    ) as List)
        .map((e) => HeritageSiteDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final characters = (jsonDecode(
      File('assets/content/characters.json').readAsStringSync(),
    ) as List)
        .map((e) => CharacterDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final stories = (jsonDecode(
      File('assets/content/stories.json').readAsStringSync(),
    ) as List)
        .map((e) => StoryDto.fromJson(e as Map<String, dynamic>))
        .toList();

    expect(sites.length, greaterThanOrEqualTo(23));
    expect(characters.length, greaterThanOrEqualTo(37));
    expect(stories.length, greaterThanOrEqualTo(23));

    final siteIds = sites.map((s) => s.id).toSet();
    final characterIds = characters.map((c) => c.id).toSet();
    for (final story in stories) {
      expect(siteIds, contains(story.siteId), reason: story.id);
      for (final id in story.characterIds) {
        expect(characterIds, contains(id), reason: story.id);
      }
      expect(story.messages, isNotEmpty, reason: story.id);
    }
  });
}
