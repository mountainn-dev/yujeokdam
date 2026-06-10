import '../../../core/view/base_view_model.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/store_content.dart';

/// 이야기 목록 화면의 일시 상태(선택 태그)와 필터링 파생을 소유한다.
class StoryListViewModel extends BaseViewModel {
  StoryListViewModel(this._store);

  final ContentStore _store;

  /// null 이면 '전체'.
  String? _selectedTag;
  String? get selectedTag => _selectedTag;

  /// 선택 태그로 필터링한 이야기 목록(파생값). 태그가 null 이면 전체.
  List<StoryModel> get filteredStories {
    final tag = _selectedTag;
    final stories = _store.stories;
    if (tag == null) return stories;
    return stories.where((story) => story.tags.contains(tag)).toList();
  }

  void selectTag(String? tag) {
    if (_selectedTag == tag) return;
    _selectedTag = tag;
    notifyListeners();
  }
}
