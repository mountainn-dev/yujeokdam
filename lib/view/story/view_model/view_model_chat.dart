import '../../../core/result/result.dart';
import '../../../core/view/base_view_model.dart';
import '../../../core/view/ui_event.dart';
import '../../../domain/story/model/model_story.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';

/// 채팅 뷰어의 일시 상태(노출 메시지 수)와 열람 처리를 조율한다.
class ChatViewModel extends BaseViewModel {
  ChatViewModel(this._readStatus);

  final ReadStatusStateHolder _readStatus;

  StoryModel? _story;

  /// 처음 노출되는 메시지 수.
  int _visibleCount = 1;
  int get visibleCount => _visibleCount;

  /// 모든 메시지가 노출되었는지.
  bool _completed = false;
  bool get isCompleted => _completed;

  /// 화면 인자로 받은 이야기를 등록한다.
  void bind(StoryModel story) {
    _story = story;
  }

  /// 화면 탭 시 다음 메시지를 노출한다. 마지막 도달 시 열람 처리한다.
  Future<void> revealNext() async {
    final story = _story;
    if (story == null) return;
    if (_visibleCount < story.messages.length) {
      _visibleCount += 1;
      notifyListeners();
    }
    if (_visibleCount >= story.messages.length && !_completed) {
      _completed = true;
      notifyListeners();
      final result = await _readStatus.markOpened(story.id);
      if (result case Failed(:final failure)) {
        emit(ShowToast(failure.message));
      }
    }
  }
}
