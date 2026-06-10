abstract class ReadStatusSource {
  /// 저장된 열람 이야기 id 목록.
  Future<List<String>> loadOpenedStoryIds();

  /// 열람 이야기 id 목록을 저장한다.
  Future<void> saveOpenedStoryIds(List<String> ids);
}
