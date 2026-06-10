import 'package:flutter/foundation.dart';

import '../../../core/result/result.dart';
import '../../../domain/read_status/repository/repository_read_status.dart';

/// 열람한 이야기 id 집합을 보유하는 공유 가변 상태.
///
/// 상태 보유와 [notifyListeners] 에만 집중한다. UI 이벤트는 발생시키지 않는다.
class ReadStatusStateHolder extends ChangeNotifier {
  ReadStatusStateHolder(this._repository);

  final ReadStatusRepository _repository;

  Set<String> _opened = const {};

  /// 열람한 이야기 id 집합의 불변 뷰.
  Set<String> get openedStoryIds => Set.unmodifiable(_opened);

  bool isOpened(String id) => _opened.contains(id);

  /// 열람 집합을 통째로 교체하고 리스너에 알린다.
  void setOpened(Set<String> opened) {
    _opened = opened;
    notifyListeners();
  }

  /// [storyId] 를 열람 처리한다. 성공 시 자기 상태를 갱신하고 알린 뒤
  /// 결과를 반환한다.
  Future<Result<void>> markOpened(String storyId) async {
    final result = await _repository.markStoryOpened(storyId);
    switch (result) {
      case Succeed(:final data):
        _opened = data;
        notifyListeners();
        return const Succeed(null);
      case NotFound():
        return const NotFound();
      case Failed(:final failure):
        return Failed(failure);
    }
  }

  /// repository 에서 초기 열람 집합을 로드한다.
  Future<void> initialize() async {
    final result = await _repository.getOpenedStoryIds();
    if (result case Succeed(:final data)) {
      setOpened(data);
    }
  }
}
