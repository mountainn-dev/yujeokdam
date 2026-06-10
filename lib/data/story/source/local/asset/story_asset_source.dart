import '../../../dto/dto_story.dart';

abstract class StoryAssetSource {
  /// 번들된 이야기 JSON 에셋을 읽어 DTO 목록으로 반환한다.
  Future<List<StoryDto>> loadStories();
}
