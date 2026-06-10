import '../../../core/result/result.dart';
import '../model/model_heritage_detail.dart';
import '../model/model_heritage_site.dart';

abstract class HeritageRepository {
  /// 앱에 내장된 모든 유적지 메타데이터를 불러온다.
  Future<Result<List<HeritageSiteModel>>> getSites();

  /// 유적지의 TourAPI 상세 정보를 가져온다.
  ///
  /// 원격 호출을 우선하고, 실패 시 캐시로 폴백한다(repository 정책).
  Future<Result<HeritageDetailModel>> getHeritageDetail(HeritageSiteModel site);
}
