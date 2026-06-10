import '../../../core/result/result.dart';
import '../../../core/view/base_view_model.dart';
import '../../../core/view/ui_event.dart';
import '../../../domain/heritage/model/model_heritage_detail.dart';
import '../../../domain/heritage/model/model_heritage_site.dart';
import '../../../domain/heritage/repository/repository_heritage.dart';

/// 이야기의 무대(유적지 상세) 화면의 로딩·상세 일시 상태를 소유한다.
class StageViewModel extends BaseViewModel {
  StageViewModel(this._repository);

  final HeritageRepository _repository;

  HeritageSiteModel? _site;

  HeritageDetailModel? _detail;
  HeritageDetailModel? get detail => _detail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  /// NotFound 인 경우의 안내 메시지. 정상/에러 시 null.
  String? _emptyMessage;
  String? get emptyMessage => _emptyMessage;

  /// 화면 인자로 받은 유적지를 등록하고 상세를 로드한다.
  Future<void> bindAndLoad(HeritageSiteModel site) async {
    _site = site;
    await load();
  }

  /// 상세 정보를 다시 불러온다(최초 로드/재시도 공용).
  Future<void> load() async {
    final site = _site;
    if (site == null) return;

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
}
