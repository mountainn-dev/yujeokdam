import 'package:get_it/get_it.dart';

import '../../domain/character/repository/repository_character.dart';
import '../../domain/heritage/repository/repository_heritage.dart';
import '../../domain/story/repository/repository_story.dart';
import '../app/store_content.dart';

/// 읽기 전용/불변 앱 데이터 `Store` 등록. Repository 이후에 호출한다.
class StoreModule {
  void registerAll() {
    final getIt = GetIt.I;
    getIt.registerSingleton<ContentStore>(
      ContentStore(
        getIt.get<StoryRepository>(),
        getIt.get<CharacterRepository>(),
        getIt.get<HeritageRepository>(),
      ),
    );
  }
}
