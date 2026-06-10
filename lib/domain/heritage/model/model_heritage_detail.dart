/// 특정 좌표 주변의 관광지·음식점 한 곳.
class NearbyPlace {
  final String contentId;
  final String name;

  /// 썸네일 이미지 URL. 없을 수 있다.
  final String? imageUrl;

  /// 기준 좌표에서의 거리(m). TourAPI 가 주면 채운다.
  final double? distanceMeters;

  const NearbyPlace({
    required this.contentId,
    required this.name,
    this.imageUrl,
    this.distanceMeters,
  });
}

/// TourAPI 에서 가져온 유적지 상세 관광정보.
class HeritageDetailModel {
  final String contentId;
  final String title;
  final String? overview;
  final String? address;
  final String? firstImageUrl;
  final String? homepage;
  final String? tel;

  /// 관람/이용 시간.
  final String? useTime;

  /// 휴무일.
  final String? restDate;

  /// 유네스코 세계유산(문화/자연/기록 중 하나라도) 여부.
  final bool isWorldHeritage;

  /// 추가 사진 갤러리 URL 목록.
  final List<String> galleryImageUrls;

  /// 주변 관광지/음식점.
  final List<NearbyPlace> nearbyPlaces;

  const HeritageDetailModel({
    required this.contentId,
    required this.title,
    required this.isWorldHeritage,
    required this.galleryImageUrls,
    required this.nearbyPlaces,
    this.overview,
    this.address,
    this.firstImageUrl,
    this.homepage,
    this.tel,
    this.useTime,
    this.restDate,
  });
}
