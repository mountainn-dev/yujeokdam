import '../../../dto/dto_heritage_detail.dart';

/// TourAPI 상세 응답의 로컬 캐시. (`shared_preferences`)
abstract class TourCacheSource {
  /// [contentId] 의 캐시된 상세를 읽는다. 없으면 null.
  Future<HeritageDetailDto?> read(String contentId);

  /// [contentId] 의 상세를 캐시에 저장한다.
  Future<void> save(String contentId, HeritageDetailDto detail);
}
