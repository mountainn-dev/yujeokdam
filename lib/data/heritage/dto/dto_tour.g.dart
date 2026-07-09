// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto_tour.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourCommonDto _$TourCommonDtoFromJson(Map<String, dynamic> json) =>
    TourCommonDto(
      contentid: json['contentid'] as String,
      title: json['title'] as String?,
      addr1: json['addr1'] as String?,
      addr2: json['addr2'] as String?,
      overview: json['overview'] as String?,
      firstimage: json['firstimage'] as String?,
      homepage: json['homepage'] as String?,
      tel: json['tel'] as String?,
      mapx: json['mapx'] as String?,
      mapy: json['mapy'] as String?,
    );

TourIntroDto _$TourIntroDtoFromJson(Map<String, dynamic> json) => TourIntroDto(
      infocenter: json['infocenter'] as String?,
      restdate: json['restdate'] as String?,
      usetime: json['usetime'] as String?,
      parking: json['parking'] as String?,
      heritage1: json['heritage1'] as String?,
      heritage2: json['heritage2'] as String?,
      heritage3: json['heritage3'] as String?,
    );

TourImageDto _$TourImageDtoFromJson(Map<String, dynamic> json) => TourImageDto(
      originimgurl: json['originimgurl'] as String?,
      smallimageurl: json['smallimageurl'] as String?,
    );

TourNearbyDto _$TourNearbyDtoFromJson(Map<String, dynamic> json) =>
    TourNearbyDto(
      contentid: json['contentid'] as String,
      title: json['title'] as String?,
      firstimage: json['firstimage'] as String?,
      dist: json['dist'] as String?,
    );
