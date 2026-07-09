import 'package:json_annotation/json_annotation.dart';

part 'dto_heritage_detail.g.dart';

/// 4개 TourAPI 응답을 합친 상세 정보. 캐시 직렬화에 쓰이므로 toJson 도 생성한다.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HeritageDetailDto {
  final String contentId;
  final String title;
  final String? overview;
  final String? address;
  final String? firstImageUrl;
  final String? homepage;
  final String? tel;
  final String? useTime;
  final String? restDate;
  final bool isWorldHeritage;
  @JsonKey(defaultValue: [])
  final List<String> galleryImageUrls;
  @JsonKey(defaultValue: [])
  final List<NearbyPlaceDto> nearbyPlaces;

  HeritageDetailDto({
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

  factory HeritageDetailDto.fromJson(Map<String, dynamic> json) =>
      _$HeritageDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HeritageDetailDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NearbyPlaceDto {
  final String contentId;
  final String name;
  final String? imageUrl;
  final double? distanceMeters;

  NearbyPlaceDto({
    required this.contentId,
    required this.name,
    this.imageUrl,
    this.distanceMeters,
  });

  factory NearbyPlaceDto.fromJson(Map<String, dynamic> json) =>
      _$NearbyPlaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NearbyPlaceDtoToJson(this);
}
