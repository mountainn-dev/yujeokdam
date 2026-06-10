import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../dto/dto_heritage_site.dart';
import 'heritage_asset_source.dart';

class HeritageAssetSourceImpl implements HeritageAssetSource {
  final AssetBundle _bundle;
  static const String _path = 'assets/content/sites.json';

  HeritageAssetSourceImpl(this._bundle);

  @override
  Future<List<HeritageSiteDto>> loadSites() async {
    final raw = await _bundle.loadString(_path);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => HeritageSiteDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
