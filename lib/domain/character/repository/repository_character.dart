import '../../../core/result/result.dart';
import '../model/model_character.dart';

abstract class CharacterRepository {
  /// 앱에 내장된 모든 인물을 불러온다.
  Future<Result<List<CharacterModel>>> getCharacters();
}
