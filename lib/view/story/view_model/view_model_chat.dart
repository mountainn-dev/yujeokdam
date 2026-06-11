import '../../../core/result/result.dart';
import '../../../core/view/base_view_model.dart';
import '../../../core/view/ui_event.dart';
import '../../../domain/story/model/model_story.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';

/// 채팅 뷰어의 일시 상태(노출 메시지 수)와 열람 처리를 조율한다.
class ChatViewModel extends BaseViewModel {
  ChatViewModel(this._story, this._readStatus) {
    final total = _story.messages.length;
    final saved = _readStatus.progressOf(_story.id);
    // 저장된 진행도가 있으면 그 지점부터 이어본다.
    _visibleCount = saved < 1 ? 1 : (saved > total ? total : saved);
    _completed = _visibleCount >= total;
  }

  final StoryModel _story;
  final ReadStatusStateHolder _readStatus;

  /// 현재 노출된 메시지 수.
  int _visibleCount = 1;
  int get visibleCount => _visibleCount;

  /// 모든 메시지가 노출되었는지.
  bool _completed = false;
  bool get isCompleted => _completed;

  /// 화면 탭 시 다음 메시지를 노출하고 진행도를 저장한다. 마지막 도달 시 열람 처리한다.
  Future<void> revealNext() async {
    final story = _story;
    if (_visibleCount >= story.messages.length) {
      return;
    }

    _visibleCount += 1;
    notifyListeners();
    // 진행도 자동저장(베스트에포트) — 실패해도 읽기는 이어진다.
    await _readStatus.updateProgress(story.id, _visibleCount);

    if (_visibleCount >= story.messages.length && !_completed) {
      _completed = true;
      notifyListeners();
      final result = await _readStatus.markOpened(story.id);
      if (result case Failed(:final failure)) {
        emit(ShowToast(failure.message));
      }
    }
  }

  /// 처음부터 다시 본다. 진행도만 0 으로 되돌리고 완독 이력은 유지한다.
  void replay() {
    _visibleCount = 1;
    _completed = false;
    notifyListeners();
    _readStatus.resetProgress(_story.id);
  }
}
