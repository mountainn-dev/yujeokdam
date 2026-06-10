import '../../../core/result/result.dart';

/// 사용자가 열어본 이야기 id 집합을 관리한다. (NEW 배지용)
abstract class ReadStatusRepository {
  /// 지금까지 열어본 이야기 id 집합.
  Future<Result<Set<String>>> getOpenedStoryIds();

  /// [storyId] 를 열람 처리하고, 갱신된 전체 집합을 반환한다.
  Future<Result<Set<String>>> markStoryOpened(String storyId);
}
