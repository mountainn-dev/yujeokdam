import '../../core/result/result.dart';
import '../../domain/character/model/model_character.dart';
import '../../domain/character/repository/repository_character.dart';
import '../../domain/heritage/model/model_heritage_site.dart';
import '../../domain/heritage/repository/repository_heritage.dart';
import '../../domain/story/model/model_story.dart';
import '../../domain/story/repository/repository_story.dart';

/// 읽기 전용 앱 데이터 저장소.
///
/// 앱 시작 시 한 번 [initialize] 로 이야기·인물·유적지를 로드하고, 이후
/// 화면과 ViewModel 은 조회 헬퍼로 읽기만 한다. `ChangeNotifier` 가 아니다.
class ContentStore {
  ContentStore(
    this._storyRepository,
    this._characterRepository,
    this._heritageRepository,
  );

  final StoryRepository _storyRepository;
  final CharacterRepository _characterRepository;
  final HeritageRepository _heritageRepository;

  List<StoryModel> _stories = const [];
  List<CharacterModel> _characters = const [];
  List<HeritageSiteModel> _sites = const [];

  /// 읽기 전용 이야기 목록.
  List<StoryModel> get stories => List.unmodifiable(_stories);

  /// 읽기 전용 인물 목록.
  List<CharacterModel> get characters => List.unmodifiable(_characters);

  /// 읽기 전용 유적지 목록.
  List<HeritageSiteModel> get sites => List.unmodifiable(_sites);

  /// 3개 repository 에서 데이터를 로드한다. 각 Result 가 Succeed 면 채우고,
  /// 아니면 빈 리스트를 유지한다.
  Future<void> initialize() async {
    final storyResult = await _storyRepository.getStories();
    if (storyResult case Succeed(:final data)) {
      _stories = data;
    }

    final characterResult = await _characterRepository.getCharacters();
    if (characterResult case Succeed(:final data)) {
      _characters = data;
    }

    final siteResult = await _heritageRepository.getSites();
    if (siteResult case Succeed(:final data)) {
      _sites = data;
    }
  }

  StoryModel? storyById(String id) {
    for (final story in _stories) {
      if (story.id == id) return story;
    }
    return null;
  }

  CharacterModel? characterById(String id) {
    for (final character in _characters) {
      if (character.id == id) return character;
    }
    return null;
  }

  List<CharacterModel> charactersOf(StoryModel story) {
    final result = <CharacterModel>[];
    for (final id in story.characterIds) {
      final character = characterById(id);
      if (character != null) result.add(character);
    }
    return result;
  }

  HeritageSiteModel? siteById(String id) {
    for (final site in _sites) {
      if (site.id == id) return site;
    }
    return null;
  }

  List<StoryModel> storiesFeaturing(String characterId) {
    return _stories
        .where((story) => story.characterIds.contains(characterId))
        .toList();
  }

  List<String> allTags() {
    final tags = <String>{};
    for (final story in _stories) {
      tags.addAll(story.tags);
    }
    return tags.toList();
  }
}
