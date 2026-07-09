import '../../../dto/dto_character.dart';

abstract class CharacterAssetSource {
  /// 번들된 인물 JSON 에셋을 읽어 DTO 목록으로 반환한다.
  Future<List<CharacterDto>> loadCharacters();
}
