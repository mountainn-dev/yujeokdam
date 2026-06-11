import '../../../core/result/result.dart';

/// 사용자의 이야기 열람 상태를 관리한다. (완독 이력 + 진행도)
abstract class ReadStatusRepository {
  /// 지금까지 열어본(완독한) 이야기 id 집합.
  Future<Result<Set<String>>> getOpenedStoryIds();

  /// [storyId] 를 열람 처리하고, 갱신된 전체 집합을 반환한다.
  Future<Result<Set<String>>> markStoryOpened(String storyId);

  /// 이야기별 진행도(노출한 말풍선 수) 맵.
  Future<Result<Map<String, int>>> getStoryProgress();

  /// [storyId] 의 진행도를 [revealedCount] 로 저장하고 갱신된 맵을 반환한다.
  /// [revealedCount] 가 0 이하면 해당 항목을 제거한다.
  Future<Result<Map<String, int>>> saveStoryProgress(
    String storyId,
    int revealedCount,
  );
}
