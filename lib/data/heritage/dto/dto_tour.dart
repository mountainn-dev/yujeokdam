import 'package:json_annotation/json_annotation.dart';

part 'dto_tour.g.dart';

/// detailCommon2 응답 item. TourAPI 키는 소문자라 [JsonKey] 로 명시한다.
@JsonSerializable(createToJson: false)
class TourCommonDto {
  final String contentid;
  final String? title;
  final String? addr1;
  final String? addr2;
  final String? overview;
  final String? firstimage;
  final String? homepage;
  final String? tel;
  final String? mapx;
  final String? mapy;

  TourCommonDto({
    required this.contentid,
    this.title,
    this.addr1,
    this.addr2,
    this.overview,
    this.firstimage,
    this.homepage,
    this.tel,
    this.mapx,
    this.mapy,
  });

  factory TourCommonDto.fromJson(Map<String, dynamic> json) =>
      _$TourCommonDtoFromJson(json);
}

/// detailIntro2 응답 item (관광타입 12 기준 필드).
@JsonSerializable(createToJson: false)
class TourIntroDto {
  final String? infocenter;
  final String? restdate;
  final String? usetime;
  final String? parking;

  /// 세계문화/자연/기록유산 유무 — "0" 또는 "1".
  final String? heritage1;
  final String? heritage2;
  final String? heritage3;

  TourIntroDto({
    this.infocenter,
    this.restdate,
    this.usetime,
    this.parking,
    this.heritage1,
    this.heritage2,
    this.heritage3,
  });

  factory TourIntroDto.fromJson(Map<String, dynamic> json) =>
      _$TourIntroDtoFromJson(json);
}

/// detailImage2 응답 item.
@JsonSerializable(createToJson: false)
class TourImageDto {
  final String? originimgurl;
  final String? smallimageurl;

  TourImageDto({this.originimgurl, this.smallimageurl});

  factory TourImageDto.fromJson(Map<String, dynamic> json) =>
      _$TourImageDtoFromJson(json);
}

/// locationBasedList2 응답 item (주변 장소).
@JsonSerializable(createToJson: false)
class TourNearbyDto {
  final String contentid;
  final String? title;
  final String? firstimage;

  /// 기준 좌표에서의 거리(m), 문자열.
  final String? dist;

  TourNearbyDto({
    required this.contentid,
    this.title,
    this.firstimage,
    this.dist,
  });

  factory TourNearbyDto.fromJson(Map<String, dynamic> json) =>
      _$TourNearbyDtoFromJson(json);
}
