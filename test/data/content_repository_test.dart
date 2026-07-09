import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yujeokdam/core/result/result.dart';
import 'package:yujeokdam/data/character/mapper/mapper_character.dart';
import 'package:yujeokdam/data/character/repository_impl/repository_impl_character.dart';
import 'package:yujeokdam/data/character/source/local/asset/character_asset_source_impl.dart';
import 'package:yujeokdam/data/heritage/dto/dto_heritage_detail.dart';
import 'package:yujeokdam/data/heritage/dto/dto_tour.dart';
import 'package:yujeokdam/data/heritage/mapper/mapper_heritage_detail.dart';
import 'package:yujeokdam/data/heritage/mapper/mapper_heritage_site.dart';
import 'package:yujeokdam/data/heritage/repository_impl/repository_impl_heritage.dart';
import 'package:yujeokdam/data/heritage/source/local/asset/heritage_asset_source_impl.dart';
import 'package:yujeokdam/data/heritage/source/local/cache/tour_cache_source.dart';
import 'package:yujeokdam/data/heritage/source/remote/api/tour_api.dart';
import 'package:yujeokdam/data/story/mapper/mapper_story.dart';
import 'package:yujeokdam/data/story/repository_impl/repository_impl_story.dart';
import 'package:yujeokdam/data/story/source/local/asset/story_asset_source_impl.dart';
import 'package:yujeokdam/domain/story/model/model_story.dart';

/// getSites 테스트에서는 원격/캐시가 쓰이지 않으므로 호출되면 실패시킨다.
class _UnusedTourApi implements TourApi {
  @override
  Future<TourCommonDto?> fetchCommon(String contentId) =>
      throw UnimplementedError();
  @override
  Future<TourIntroDto?> fetchIntro(String contentId, String contentTypeId) =>
      throw UnimplementedError();
  @override
  Future<List<TourImageDto>> fetchImages(String contentId) =>
      throw UnimplementedError();
  @override
  Future<List<TourNearbyDto>> fetchNearby({
    required String mapX,
    required String mapY,
    required int radiusMeters,
  }) =>
      throw UnimplementedError();
}

class _UnusedTourCache implements TourCacheSource {
  @override
  Future<HeritageDetailDto?> read(String contentId) async => null;
  @override
  Future<void> save(String contentId, HeritageDetailDto detail) async {}
}

void main() {
  // rootBundle 은 테스트에서 실제 에셋을 읽으므로 바인딩 초기화가 필요하다.
  TestWidgetsFlutterBinding.ensureInitialized();
  final bundle = rootBundle;

  test('StoryRepository 가 번들 이야기를 Succeed 로 반환한다', () async {
    final repo = StoryRepositoryImpl(
      StoryAssetSourceImpl(bundle),
      const StoryMapper(),
    );

    final result = await repo.getStories();

    expect(result, isA<Succeed<List<StoryModel>>>());
    final stories = (result as Succeed<List<StoryModel>>).data;
    expect(stories, isNotEmpty);

    final seochulji = stories.firstWhere((s) => s.id == 'story_seochulji_01');
    expect(seochulji.siteId, 'site_seochulji');
    expect(seochulji.messages.first.type, StoryMessageType.narration);
    expect(
      seochulji.messages.any((m) => m.type == StoryMessageType.chat),
      isTrue,
    );
    expect(seochulji.sources, isNotEmpty);
  });

  test('CharacterRepository 가 인물과 관계를 반환한다', () async {
    final repo = CharacterRepositoryImpl(
      CharacterAssetSourceImpl(bundle),
      const CharacterMapper(),
    );

    final result = await repo.getCharacters();

    final characters = (result as Succeed).data;
    final king = characters.firstWhere((c) => c.id == 'soji_king');
    expect(king.relations, isNotEmpty);
    expect(king.relations.any((r) => r.targetId == 'court_lady'), isTrue);
  });

  test('HeritageRepository 가 유적지 메타를 반환한다', () async {
    final repo = HeritageRepositoryImpl(
      HeritageAssetSourceImpl(bundle),
      const HeritageSiteMapper(),
      _UnusedTourApi(),
      _UnusedTourCache(),
      const HeritageDetailMapper(),
    );

    final result = await repo.getSites();

    final sites = (result as Succeed).data;
    final site = sites.firstWhere((s) => s.id == 'site_seochulji');
    expect(site.tourApiContentId, '128612');
  });
}
