import '../../../core/data/base_repository.dart';
import '../../../core/result/result.dart';
import '../../../domain/read_status/repository/repository_read_status.dart';
import '../source/local/preference/read_status_source.dart';

class ReadStatusRepositoryImpl extends BaseRepository
    implements ReadStatusRepository {
  final ReadStatusSource _source;

  ReadStatusRepositoryImpl(this._source);

  @override
  Future<Result<Set<String>>> getOpenedStoryIds() {
    return execute(() async {
      final ids = await _source.loadOpenedStoryIds();
      return ids.toSet();
    });
  }

  @override
  Future<Result<Set<String>>> markStoryOpened(String storyId) {
    return execute(() async {
      final ids = (await _source.loadOpenedStoryIds()).toSet();
      ids.add(storyId);
      await _source.saveOpenedStoryIds(ids.toList());
      return ids;
    });
  }

  @override
  Future<Result<Map<String, int>>> getStoryProgress() {
    return execute(() => _source.loadStoryProgress());
  }

  @override
  Future<Result<Map<String, int>>> saveStoryProgress(
    String storyId,
    int revealedCount,
  ) {
    return execute(() async {
      final progress = Map<String, int>.from(await _source.loadStoryProgress());
      if (revealedCount <= 0) {
        progress.remove(storyId);
      } else {
        progress[storyId] = revealedCount;
      }
      await _source.saveStoryProgress(progress);
      return progress;
    });
  }
}
