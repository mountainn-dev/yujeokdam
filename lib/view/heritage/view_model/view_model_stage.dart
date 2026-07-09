import '../../../core/result/result.dart';
import '../../../core/view/base_view_model.dart';
import '../../../core/view/ui_event.dart';
import '../../../domain/heritage/model/model_heritage_detail.dart';
import '../../../domain/heritage/model/model_heritage_site.dart';
import '../../../domain/heritage/repository/repository_heritage.dart';
import '../../../domain/launcher/repository/repository_launcher.dart';

/// 이야기의 무대(유적지 상세) 화면의 로딩·상세 일시 상태를 소유한다.
class StageViewModel extends BaseViewModel {
  StageViewModel(this._site, this._repository, this._launcher);

  final HeritageSiteModel _site;
  final HeritageRepository _repository;
  final LauncherRepository _launcher;

  HeritageDetailModel? _detail;
  HeritageDetailModel? get detail => _detail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  /// NotFound 인 경우의 안내 메시지. 정상/에러 시 null.
  String? _emptyMessage;
  String? get emptyMessage => _emptyMessage;

  /// 상세 정보를 다시 불러온다(최초 로드/재시도 공용).
  Future<void> load() async {
    final site = _site;

    _isLoading = true;
    _hasError = false;
    _emptyMessage = null;
    notifyListeners();

    final result = await _repository.getHeritageDetail(site);

    switch (result) {
      case Succeed(:final data):
        _detail = data;
      case NotFound():
        _detail = null;
        _emptyMessage = '유적지 정보가 없습니다.';
      case Failed(:final failure):
        _hasError = true;
        emit(ShowToast(failure.message));
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 외부 지도 앱에서 [query](유적지명/주소)를 연다. 실패 시 토스트로 안내한다.
  Future<void> openMap(String query) async {
    final result = await _launcher.openMapSearch(query);
    if (result case Failed(:final failure)) {
      emit(ShowToast(failure.message));
    }
  }
}
