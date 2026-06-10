import '../../../dto/dto_heritage_site.dart';

abstract class HeritageAssetSource {
  /// 번들된 유적지 JSON 에셋을 읽어 DTO 목록으로 반환한다.
  Future<List<HeritageSiteDto>> loadSites();
}
