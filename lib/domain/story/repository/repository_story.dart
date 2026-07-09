import '../../../core/result/result.dart';
import '../model/model_story.dart';

abstract class StoryRepository {
  /// 앱에 내장된 모든 이야기를 불러온다.
  Future<Result<List<StoryModel>>> getStories();
}
