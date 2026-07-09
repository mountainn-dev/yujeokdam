import 'dart:async';

import 'package:flutter/foundation.dart';

import '../result/result.dart';
import 'ui_event.dart';

/// 화면 스코프 ViewModel 의 베이스.
///
/// 화면별 일시 상태를 보유하고, [eventStream] 으로 UI 이벤트를 발생시킨다.
/// 공유 상태와 `notifyListeners()` 소유는 StateHolder 의 몫이다.
abstract class BaseViewModel extends ChangeNotifier {
  final StreamController<UiEvent> _eventController =
      StreamController<UiEvent>.broadcast();

  /// 화면이 구독하는 UI 이벤트 스트림.
  Stream<UiEvent> get eventStream => _eventController.stream;

  /// 하위 ViewModel 이 UI 이벤트를 발생시키는 통로.
  @protected
  void emit(UiEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// 로딩 표시와 함께 [task] 를 실행한다.
  ///
  /// 시작 시 [StartTask], 종료 시 [EndTask] 를 발생시키고, 실패면 실패 메시지를
  /// 토스트로 보여준다. ViewModel 은 try-catch 없이 반환된 [Result] 만 소비한다.
  @protected
  Future<Result<T>> runWithLoading<T>(
    Future<Result<T>> Function() task,
  ) async {
    emit(const StartTask());
    final result = await task();
    emit(const EndTask());
    if (result case Failed(:final failure)) {
      emit(ShowToast(failure.message));
    }
    return result;
  }

  /// [runWithLoading] 에 성공 메시지 토스트를 추가한 변형.
  @protected
  Future<Result<T>> runSingleTaskWithMessage<T>(
    Future<Result<T>> Function() task, {
    required String successMessage,
  }) async {
    final result = await runWithLoading(task);
    if (result is Succeed<T>) {
      emit(ShowToast(successMessage));
    }
    return result;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
