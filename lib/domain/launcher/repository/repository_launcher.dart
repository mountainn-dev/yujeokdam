import '../../../core/result/result.dart';

/// 외부 앱(지도 등)을 실행하는 저장소.
abstract class LauncherRepository {
  /// 외부 지도 앱에서 [query](장소명/주소)를 검색해 연다. 성공하면 `true`.
  Future<Result<bool>> openMapSearch(String query);
}
