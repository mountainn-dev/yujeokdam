import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../dto/dto_character.dart';
import 'character_asset_source.dart';

class CharacterAssetSourceImpl implements CharacterAssetSource {
  final AssetBundle _bundle;
  static const String _path = 'assets/content/characters.json';

  CharacterAssetSourceImpl(this._bundle);

  @override
  Future<List<CharacterDto>> loadCharacters() async {
    final raw = await _bundle.loadString(_path);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => CharacterDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
