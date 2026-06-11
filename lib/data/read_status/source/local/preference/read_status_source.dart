abstract class ReadStatusSource {
  /// 저장된 열람 이야기 id 목록.
  Future<List<String>> loadOpenedStoryIds();

  /// 열람 이야기 id 목록을 저장한다.
  Future<void> saveOpenedStoryIds(List<String> ids);

  /// 이야기별 진행도(노출한 말풍선 수) 맵.
  Future<Map<String, int>> loadStoryProgress();

  /// 이야기별 진행도 맵을 저장한다.
  Future<void> saveStoryProgress(Map<String, int> progress);
}
