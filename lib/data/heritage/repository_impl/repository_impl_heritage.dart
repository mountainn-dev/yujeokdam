import '../../../core/data/base_repository.dart';
import '../../../core/result/result.dart';
import '../../../domain/heritage/model/model_heritage_detail.dart';
import '../../../domain/heritage/model/model_heritage_site.dart';
import '../../../domain/heritage/repository/repository_heritage.dart';
import '../dto/dto_tour.dart';
import '../mapper/mapper_heritage_detail.dart';
import '../mapper/mapper_heritage_site.dart';
import '../source/local/asset/heritage_asset_source.dart';
import '../source/local/cache/tour_cache_source.dart';
import '../source/remote/api/tour_api.dart';

class HeritageRepositoryImpl extends BaseRepository
    implements HeritageRepository {
  final HeritageAssetSource _assetSource;
  final HeritageSiteMapper _siteMapper;
  final TourApi _tourApi;
  final TourCacheSource _cache;
  final HeritageDetailMapper _detailMapper;

  static const int _nearbyRadiusMeters = 2000;

  List<HeritageSiteModel>? _siteCache;

  HeritageRepositoryImpl(
    this._assetSource,
    this._siteMapper,
    this._tourApi,
    this._cache,
    this._detailMapper,
  );

  @override
  Future<Result<List<HeritageSiteModel>>> getSites() {
    return execute(() async {
      final cached = _siteCache;
      if (cached != null) {
        return cached;
      }
      final dtos = await _assetSource.loadSites();
      final models = dtos.map(_siteMapper.toDomain).toList();
      _siteCache = models;
      return models;
    });
  }

  @override
  Future<Result<HeritageDetailModel>> getHeritageDetail(
    HeritageSiteModel site,
  ) async {
    final remote = await _fetchRemoteDetail(site);
    // 원격 성공/정보없음은 그대로 반환. 실패일 때만 캐시로 폴백한다.
    if (remote is! Failed<HeritageDetailModel>) {
      return remote;
    }
    final cached = await _readCachedDetail(site.tourApiContentId);
    if (cached is Succeed<HeritageDetailModel>) {
      return cached;
    }
    return remote;
  }

  Future<Result<HeritageDetailModel>> _fetchRemoteDetail(
    HeritageSiteModel site,
  ) {
    final contentId = site.tourApiContentId;
    return execute(() async {
      final common = await _tourApi.fetchCommon(contentId);
      if (common == null) {
        return null;
      }
      final intro = await _tourApi.fetchIntro(
        contentId,
        site.tourApiContentTypeId,
      );
      final images = await _tourApi.fetchImages(contentId);
      final nearby = await _fetchNearby(common);

      final dto = _detailMapper.assemble(
        common: common,
        intro: intro,
        images: images,
        nearby: nearby,
      );
      await _cache.save(contentId, dto);
      return _detailMapper.toDomain(dto);
    });
  }

  Future<List<TourNearbyDto>> _fetchNearby(TourCommonDto common) async {
    final mapX = common.mapx;
    final mapY = common.mapy;
    if (mapX == null || mapX.isEmpty || mapY == null || mapY.isEmpty) {
      return [];
    }
    return _tourApi.fetchNearby(
      mapX: mapX,
      mapY: mapY,
      radiusMeters: _nearbyRadiusMeters,
    );
  }

  Future<Result<HeritageDetailModel>> _readCachedDetail(String contentId) {
    return execute(() async {
      final dto = await _cache.read(contentId);
      if (dto == null) {
        return null;
      }
      return _detailMapper.toDomain(dto);
    });
  }
}
