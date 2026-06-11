/// 외부 링크/앱 실행 저수준 소스.
///
/// 실행 불가/실패 시 예외를 던진다(repository 의 `execute` 가 `Failure` 로 변환).
abstract class ExternalLinkSource {
  /// 지도 검색 URL 을 외부 앱에서 연다. 성공하면 `true`.
  Future<bool> openMapSearch(String query);
}
