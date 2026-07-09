/// 경주 유적지. 상세 관광정보는 [tourApiContentId] 로 TourAPI 에서 가져온다.
class HeritageSiteModel {
  final String id;
  final String name;

  /// TourAPI 콘텐츠 id (detailCommon2/detailIntro2/detailImage2 조회 키).
  final String tourApiContentId;

  /// TourAPI 관광타입 id (예: 12 관광지). detailIntro2 등에서 필요.
  final String tourApiContentTypeId;

  const HeritageSiteModel({
    required this.id,
    required this.name,
    required this.tourApiContentId,
    required this.tourApiContentTypeId,
  });
}
