import 'package:shared_preferences/shared_preferences.dart';

import 'read_status_source.dart';

class ReadStatusSourceImpl implements ReadStatusSource {
  final SharedPreferences _prefs;
  static const String _key = 'opened_story_ids';

  ReadStatusSourceImpl(this._prefs);

  @override
  Future<List<String>> loadOpenedStoryIds() async {
    return _prefs.getStringList(_key) ?? const [];
  }

  @override
  Future<void> saveOpenedStoryIds(List<String> ids) async {
    await _prefs.setStringList(_key, ids);
  }
}
