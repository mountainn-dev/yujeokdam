import 'package:get_it/get_it.dart';

import '../../domain/heritage/model/model_heritage_site.dart';
import '../../domain/heritage/repository/repository_heritage.dart';
import '../../domain/launcher/repository/repository_launcher.dart';
import '../../domain/story/model/model_story.dart';
import '../app/store_content.dart';
import '../heritage/view_model/view_model_stage.dart';
import '../read_status/state_holder/state_holder_read_status.dart';
import '../story/view_model/view_model_chat.dart';
import '../story/view_model/view_model_story_list.dart';

/// 화면 스코프 ViewModel 팩토리 등록. Store·StateHolder 이후에 호출한다.
class ViewModelFactoryModule {
  void registerAll() {
    final getIt = GetIt.I;

    getIt.registerFactory<StoryListViewModel>(
      () => StoryListViewModel(getIt.get<ContentStore>()),
    );
    getIt.registerFactoryParam<ChatViewModel, StoryModel, void>(
      (story, _) =>
          ChatViewModel(story, getIt.get<ReadStatusStateHolder>()),
    );
    getIt.registerFactoryParam<StageViewModel, HeritageSiteModel, void>(
      (site, _) => StageViewModel(
        site,
        getIt.get<HeritageRepository>(),
        getIt.get<LauncherRepository>(),
      ),
    );
  }
}
