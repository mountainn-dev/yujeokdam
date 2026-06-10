import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../dto/dto_heritage_detail.dart';
import 'tour_cache_source.dart';

class TourCacheSourceImpl implements TourCacheSource {
  final SharedPreferences _prefs;
  static const String _keyPrefix = 'tour_cache_';

  TourCacheSourceImpl(this._prefs);

  @override
  Future<HeritageDetailDto?> read(String contentId) async {
    final raw = _prefs.getString('$_keyPrefix$contentId');
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return HeritageDetailDto.fromJson(decoded);
  }

  @override
  Future<void> save(String contentId, HeritageDetailDto detail) async {
    await _prefs.setString(
      '$_keyPrefix$contentId',
      jsonEncode(detail.toJson()),
    );
  }
}
