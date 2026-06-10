import '../../../core/result/result.dart';
import '../../../core/view/base_view_model.dart';
import '../../../core/view/ui_event.dart';
import '../../../domain/story/model/model_story.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';

/// 채팅 뷰어의 일시 상태(노출 메시지 수)와 열람 처리를 조율한다.
class ChatViewModel extends BaseViewModel {
  ChatViewModel(this._story, this._readStatus);

  final StoryModel _story;
  final ReadStatusStateHolder _readStatus;

  /// 처음 노출되는 메시지 수.
  int _visibleCount = 1;
  int get visibleCount => _visibleCount;

  /// 모든 메시지가 노출되었는지.
  bool _completed = false;
  bool get isCompleted => _completed;

  /// 화면 탭 시 다음 메시지를 노출한다. 마지막 도달 시 열람 처리한다.
  Future<void> revealNext() async {
    final story = _story;
    if (_visibleCount < story.messages.length) {
      _visibleCount += 1;
      notifyListeners();
    }
    if (_visibleCount >= story.messages.length && !_completed) {
      _completed = true;
      notifyListeners();
      final result = await _readStatus.markOpened(story.id);
      switch (result) {
        // 정상 열람 처리. 별도 UI 반응 불필요.
        case Succeed():
          break;
        // 저장 실패는 사용자에게 알린다.
        case Failed(:final failure):
          emit(ShowToast(failure.message));
        // markOpened 는 항상 갱신된 집합을 돌려주므로 NotFound 는 발생하지 않는다.
        case NotFound():
          break;
      }
    }
  }
}
