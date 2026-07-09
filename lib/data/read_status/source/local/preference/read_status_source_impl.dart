import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'read_status_source.dart';

class ReadStatusSourceImpl implements ReadStatusSource {
  final SharedPreferences _prefs;
  static const String _openedKey = 'opened_story_ids';
  static const String _progressKey = 'story_progress';

  ReadStatusSourceImpl(this._prefs);

  @override
  Future<List<String>> loadOpenedStoryIds() async {
    return _prefs.getStringList(_openedKey) ?? const [];
  }

  @override
  Future<void> saveOpenedStoryIds(List<String> ids) async {
    await _prefs.setStringList(_openedKey, ids);
  }

  @override
  Future<Map<String, int>> loadStoryProgress() async {
    final raw = _prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((id, count) => MapEntry(id, count as int));
  }

  @override
  Future<void> saveStoryProgress(Map<String, int> progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress));
  }
}
