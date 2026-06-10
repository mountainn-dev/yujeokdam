import '../../../core/data/base_repository.dart';
import '../../../core/result/result.dart';
import '../../../domain/story/model/model_story.dart';
import '../../../domain/story/repository/repository_story.dart';
import '../mapper/mapper_story.dart';
import '../source/local/asset/story_asset_source.dart';

class StoryRepositoryImpl extends BaseRepository implements StoryRepository {
  final StoryAssetSource _source;
  final StoryMapper _mapper;

  List<StoryModel>? _cache;

  StoryRepositoryImpl(this._source, this._mapper);

  @override
  Future<Result<List<StoryModel>>> getStories() {
    return execute(() async {
      final cached = _cache;
      if (cached != null) {
        return cached;
      }
      final dtos = await _source.loadStories();
      final models = dtos.map(_mapper.toDomain).toList();
      _cache = models;
      return models;
    });
  }
}
