import '../../../dto/dto_tour.dart';

/// 한국관광공사 TourAPI(KorService2) 호출 인터페이스.
///
/// 구현체는 `resultCode != "0000"` 이거나 네트워크 오류면 예외를 던진다
/// (repository 의 `execute` 가 `Failure` 로 변환).
abstract class TourApi {
  /// detailCommon2 — 개요·주소·대표사진·좌표. 콘텐츠가 없으면 null.
  Future<TourCommonDto?> fetchCommon(String contentId);

  /// detailIntro2 — 운영시간·휴무·유네스코 유산 여부. 없으면 null.
  Future<TourIntroDto?> fetchIntro(String contentId, String contentTypeId);

  /// detailImage2 — 추가 사진 갤러리.
  Future<List<TourImageDto>> fetchImages(String contentId);

  /// locationBasedList2 — 좌표 반경 내 주변 장소(거리순).
  Future<List<TourNearbyDto>> fetchNearby({
    required String mapX,
    required String mapY,
    required int radiusMeters,
  });
}
