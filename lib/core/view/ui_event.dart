/// ViewModel 이 화면에 일회성으로 발생시키는 UI 이벤트.
///
/// 화면은 `eventStream` 을 구독해 로딩 표시·토스트·내비게이션을 처리한다.
sealed class UiEvent {
  const UiEvent();
}

/// 비동기 작업 시작 — 화면은 로딩 인디케이터를 띄운다.
class StartTask extends UiEvent {
  const StartTask();
}

/// 비동기 작업 종료 — 화면은 로딩 인디케이터를 내린다.
class EndTask extends UiEvent {
  const EndTask();
}

/// 사용자에게 짧은 메시지를 보여준다.
class ShowToast extends UiEvent {
  final String message;
  const ShowToast(this.message);
}
