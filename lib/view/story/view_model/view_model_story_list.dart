import '../../../core/view/base_view_model.dart';
import '../../../domain/story/model/model_story.dart';

/// 이야기 목록 화면의 일시 상태(선택 태그)와 필터링 파생을 소유한다.
class StoryListViewModel extends BaseViewModel {
  /// null 이면 '전체'.
  String? _selectedTag;
  String? get selectedTag => _selectedTag;

  /// 선택 태그를 [all] 에 적용한 이야기 목록을 반환한다.
  List<StoryModel> applyFilter(List<StoryModel> all) {
    final tag = _selectedTag;
    if (tag == null) return all;
    return all.where((story) => story.tags.contains(tag)).toList();
  }

  void selectTag(String? tag) {
    if (_selectedTag == tag) return;
    _selectedTag = tag;
    notifyListeners();
  }
}
