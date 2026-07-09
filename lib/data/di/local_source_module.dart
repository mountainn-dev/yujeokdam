import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../character/source/local/asset/character_asset_source.dart';
import '../character/source/local/asset/character_asset_source_impl.dart';
import '../heritage/source/local/asset/heritage_asset_source.dart';
import '../heritage/source/local/asset/heritage_asset_source_impl.dart';
import '../heritage/source/local/cache/tour_cache_source.dart';
import '../heritage/source/local/cache/tour_cache_source_impl.dart';
import '../read_status/source/local/preference/read_status_source.dart';
import '../read_status/source/local/preference/read_status_source_impl.dart';
import '../story/source/local/asset/story_asset_source.dart';
import '../story/source/local/asset/story_asset_source_impl.dart';

/// 로컬 데이터 소스(에셋 로더 + TourAPI 캐시) 등록.
class LocalSourceModule {
  final SharedPreferences _prefs;

  LocalSourceModule(this._prefs);

  void registerAll() {
    final getIt = GetIt.I;
    getIt.registerSingleton<StoryAssetSource>(
      StoryAssetSourceImpl(rootBundle),
    );
    getIt.registerSingleton<CharacterAssetSource>(
      CharacterAssetSourceImpl(rootBundle),
    );
    getIt.registerSingleton<HeritageAssetSource>(
      HeritageAssetSourceImpl(rootBundle),
    );
    getIt.registerSingleton<TourCacheSource>(
      TourCacheSourceImpl(_prefs),
    );
    getIt.registerSingleton<ReadStatusSource>(
      ReadStatusSourceImpl(_prefs),
    );
  }
}
