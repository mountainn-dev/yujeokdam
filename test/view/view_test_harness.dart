import 'package:get_it/get_it.dart';
import 'package:yujeokdam/core/result/result.dart';
import 'package:yujeokdam/domain/character/model/model_character.dart';
import 'package:yujeokdam/domain/character/repository/repository_character.dart';
import 'package:yujeokdam/domain/heritage/model/model_heritage_detail.dart';
import 'package:yujeokdam/domain/heritage/model/model_heritage_site.dart';
import 'package:yujeokdam/domain/heritage/repository/repository_heritage.dart';
import 'package:yujeokdam/domain/read_status/repository/repository_read_status.dart';
import 'package:yujeokdam/domain/story/model/model_story.dart';
import 'package:yujeokdam/domain/story/repository/repository_story.dart';
import 'package:yujeokdam/view/di/state_holder_module.dart';
import 'package:yujeokdam/view/di/store_module.dart';
import 'package:yujeokdam/view/di/view_model_factory_module.dart';
import 'package:yujeokdam/view/app/store_content.dart';
import 'package:yujeokdam/view/read_status/state_holder/state_holder_read_status.dart';

/// 테스트용 가짜 이야기 repository.
class FakeStoryRepository implements StoryRepository {
  FakeStoryRepository(this.stories);
  final List<StoryModel> stories;
  @override
  Future<Result<List<StoryModel>>> getStories() async => Succeed(stories);
}

class FakeCharacterRepository implements CharacterRepository {
  FakeCharacterRepository(this.characters);
  final List<CharacterModel> characters;
  @override
  Future<Result<List<CharacterModel>>> getCharacters() async =>
      Succeed(characters);
}

class FakeHeritageRepository implements HeritageRepository {
  FakeHeritageRepository(this.sites, [this.detail]);
  final List<HeritageSiteModel> sites;
  final HeritageDetailModel? detail;
  @override
  Future<Result<List<HeritageSiteModel>>> getSites() async => Succeed(sites);
  @override
  Future<Result<HeritageDetailModel>> getHeritageDetail(
      HeritageSiteModel site) async {
    final d = detail;
    if (d == null) return const NotFound();
    return Succeed(d);
  }
}

class FakeReadStatusRepository implements ReadStatusRepository {
  FakeReadStatusRepository([Set<String>? opened, Map<String, int>? progress])
      : _opened = {...?opened},
        _progress = {...?progress};
  Set<String> _opened;
  Map<String, int> _progress;
  @override
  Future<Result<Set<String>>> getOpenedStoryIds() async => Succeed(_opened);
  @override
  Future<Result<Set<String>>> markStoryOpened(String storyId) async {
    _opened = {..._opened, storyId};
    return Succeed(_opened);
  }

  @override
  Future<Result<Map<String, int>>> getStoryProgress() async =>
      Succeed(_progress);
  @override
  Future<Result<Map<String, int>>> saveStoryProgress(
    String storyId,
    int revealedCount,
  ) async {
    _progress = {..._progress};
    if (revealedCount <= 0) {
      _progress.remove(storyId);
    } else {
      _progress[storyId] = revealedCount;
    }
    return Succeed(_progress);
  }
}

/// GetIt 에 가짜 repository 와 실제 뷰 모듈을 등록하고 Store/StateHolder 초기화.
Future<void> registerViewLayer({
  required List<StoryModel> stories,
  required List<CharacterModel> characters,
  required List<HeritageSiteModel> sites,
  Set<String>? opened,
  Map<String, int>? progress,
}) async {
  final getIt = GetIt.I;
  await getIt.reset();

  getIt.registerSingleton<StoryRepository>(FakeStoryRepository(stories));
  getIt.registerSingleton<CharacterRepository>(
      FakeCharacterRepository(characters));
  getIt.registerSingleton<HeritageRepository>(FakeHeritageRepository(sites));
  getIt.registerSingleton<ReadStatusRepository>(
      FakeReadStatusRepository(opened, progress));

  StoreModule().registerAll();
  StateHolderModule().registerAll();
  ViewModelFactoryModule().registerAll();

  await getIt.get<ContentStore>().initialize();
  await getIt.get<ReadStatusStateHolder>().initialize();
}
