import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../dto/dto_story.dart';
import 'story_asset_source.dart';

class StoryAssetSourceImpl implements StoryAssetSource {
  final AssetBundle _bundle;
  static const String _path = 'assets/content/stories.json';

  StoryAssetSourceImpl(this._bundle);

  @override
  Future<List<StoryDto>> loadStories() async {
    final raw = await _bundle.loadString(_path);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => StoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
