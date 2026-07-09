import 'package:get_it/get_it.dart';

import '../../domain/character/repository/repository_character.dart';
import '../../domain/heritage/repository/repository_heritage.dart';
import '../../domain/launcher/repository/repository_launcher.dart';
import '../../domain/read_status/repository/repository_read_status.dart';
import '../../domain/story/repository/repository_story.dart';
import '../character/mapper/mapper_character.dart';
import '../character/repository_impl/repository_impl_character.dart';
import '../character/source/local/asset/character_asset_source.dart';
import '../heritage/mapper/mapper_heritage_detail.dart';
import '../heritage/mapper/mapper_heritage_site.dart';
import '../heritage/repository_impl/repository_impl_heritage.dart';
import '../heritage/source/local/asset/heritage_asset_source.dart';
import '../heritage/source/local/cache/tour_cache_source.dart';
import '../heritage/source/remote/api/tour_api.dart';
import '../launcher/repository_impl/repository_impl_launcher.dart';
import '../launcher/source/external_link_source.dart';
import '../read_status/repository_impl/repository_impl_read_status.dart';
import '../read_status/source/local/preference/read_status_source.dart';
import '../story/mapper/mapper_story.dart';
import '../story/repository_impl/repository_impl_story.dart';
import '../story/source/local/asset/story_asset_source.dart';

/// repository 구현체 등록. LocalSourceModule·RemoteSourceModule 이후에 호출한다.
class RepositoryModule {
  void registerAll() {
    final getIt = GetIt.I;
    getIt.registerSingleton<StoryRepository>(
      StoryRepositoryImpl(getIt.get<StoryAssetSource>(), const StoryMapper()),
    );
    getIt.registerSingleton<CharacterRepository>(
      CharacterRepositoryImpl(
        getIt.get<CharacterAssetSource>(),
        const CharacterMapper(),
      ),
    );
    getIt.registerSingleton<HeritageRepository>(
      HeritageRepositoryImpl(
        getIt.get<HeritageAssetSource>(),
        const HeritageSiteMapper(),
        getIt.get<TourApi>(),
        getIt.get<TourCacheSource>(),
        const HeritageDetailMapper(),
      ),
    );
    getIt.registerSingleton<ReadStatusRepository>(
      ReadStatusRepositoryImpl(getIt.get<ReadStatusSource>()),
    );
    getIt.registerSingleton<LauncherRepository>(
      LauncherRepositoryImpl(getIt.get<ExternalLinkSource>()),
    );
  }
}
