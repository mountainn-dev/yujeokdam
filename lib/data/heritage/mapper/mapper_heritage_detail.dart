import '../../../domain/heritage/model/model_heritage_detail.dart';
import '../dto/dto_heritage_detail.dart';
import '../dto/dto_tour.dart';

class HeritageDetailMapper {
  const HeritageDetailMapper();

  /// 4개 TourAPI 응답을 하나의 캐시 가능한 DTO 로 합친다.
  HeritageDetailDto assemble({
    required TourCommonDto common,
    TourIntroDto? intro,
    required List<TourImageDto> images,
    required List<TourNearbyDto> nearby,
  }) {
    return HeritageDetailDto(
      contentId: common.contentid,
      title: common.title ?? '',
      overview: _blankToNull(common.overview),
      address: _joinAddress(common.addr1, common.addr2),
      firstImageUrl: _blankToNull(common.firstimage),
      homepage: _blankToNull(common.homepage),
      tel: _blankToNull(common.tel),
      useTime: _blankToNull(intro?.usetime),
      restDate: _blankToNull(intro?.restdate),
      isWorldHeritage: _isWorldHeritage(intro),
      galleryImageUrls: images
          .map((e) => e.originimgurl)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList(),
      nearbyPlaces: nearby
          .map(
            (e) => NearbyPlaceDto(
              contentId: e.contentid,
              name: e.title ?? '',
              imageUrl: _blankToNull(e.firstimage),
              distanceMeters: double.tryParse(e.dist ?? ''),
            ),
          )
          .toList(),
    );
  }

  HeritageDetailModel toDomain(HeritageDetailDto dto) {
    return HeritageDetailModel(
      contentId: dto.contentId,
      title: dto.title,
      overview: dto.overview,
      address: dto.address,
      firstImageUrl: dto.firstImageUrl,
      homepage: dto.homepage,
      tel: dto.tel,
      useTime: dto.useTime,
      restDate: dto.restDate,
      isWorldHeritage: dto.isWorldHeritage,
      galleryImageUrls: dto.galleryImageUrls,
      nearbyPlaces: dto.nearbyPlaces
          .map(
            (e) => NearbyPlace(
              contentId: e.contentId,
              name: e.name,
              imageUrl: e.imageUrl,
              distanceMeters: e.distanceMeters,
            ),
          )
          .toList(),
    );
  }

  bool _isWorldHeritage(TourIntroDto? intro) {
    if (intro == null) {
      return false;
    }
    return intro.heritage1 == '1' ||
        intro.heritage2 == '1' ||
        intro.heritage3 == '1';
  }

  String? _joinAddress(String? addr1, String? addr2) {
    final a1 = _blankToNull(addr1);
    final a2 = _blankToNull(addr2);
    if (a1 == null) {
      return a2;
    }
    if (a2 == null) {
      return a1;
    }
    return '$a1 $a2';
  }

  String? _blankToNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
