import 'package:get_it/get_it.dart';

import '../../domain/heritage/repository/repository_heritage.dart';
import '../heritage/view_model/view_model_stage.dart';
import '../read_status/state_holder/state_holder_read_status.dart';
import '../story/view_model/view_model_chat.dart';
import '../story/view_model/view_model_story_list.dart';

/// 화면 스코프 ViewModel 팩토리 등록. Store·StateHolder 이후에 호출한다.
class ViewModelFactoryModule {
  void registerAll() {
    final getIt = GetIt.I;

    getIt.registerFactory<StoryListViewModel>(
      () => StoryListViewModel(),
    );
    getIt.registerFactory<ChatViewModel>(
      () => ChatViewModel(getIt.get<ReadStatusStateHolder>()),
    );
    getIt.registerFactory<StageViewModel>(
      () => StageViewModel(getIt.get<HeritageRepository>()),
    );
  }
}
