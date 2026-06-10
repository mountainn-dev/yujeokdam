import '../../../core/data/base_repository.dart';
import '../../../core/result/result.dart';
import '../../../domain/character/model/model_character.dart';
import '../../../domain/character/repository/repository_character.dart';
import '../mapper/mapper_character.dart';
import '../source/local/asset/character_asset_source.dart';

class CharacterRepositoryImpl extends BaseRepository
    implements CharacterRepository {
  final CharacterAssetSource _source;
  final CharacterMapper _mapper;

  List<CharacterModel>? _cache;

  CharacterRepositoryImpl(this._source, this._mapper);

  @override
  Future<Result<List<CharacterModel>>> getCharacters() {
    return execute(() async {
      final cached = _cache;
      if (cached != null) {
        return cached;
      }
      final dtos = await _source.loadCharacters();
      final models = dtos.map(_mapper.toDomain).toList();
      _cache = models;
      return models;
    });
  }
}
