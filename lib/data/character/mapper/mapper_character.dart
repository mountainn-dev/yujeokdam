import '../../../domain/character/model/model_character.dart';
import '../dto/dto_character.dart';

class CharacterMapper {
  const CharacterMapper();

  CharacterModel toDomain(CharacterDto dto) {
    return CharacterModel(
      id: dto.id,
      name: dto.name,
      portrait: dto.portrait,
      lifespan: dto.lifespan,
      oneLiner: dto.oneLiner,
      description: dto.description,
      relations: dto.relations.map(_relationToDomain).toList(),
    );
  }

  CharacterRelation _relationToDomain(CharacterRelationDto dto) {
    return CharacterRelation(targetId: dto.targetId, label: dto.label);
  }
}
