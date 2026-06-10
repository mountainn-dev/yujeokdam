import '../../../domain/story/model/model_story.dart';
import '../dto/dto_story.dart';

class StoryMapper {
  const StoryMapper();

  StoryModel toDomain(StoryDto dto) {
    return StoryModel(
      id: dto.id,
      title: dto.title,
      siteId: dto.siteId,
      characterIds: dto.characterIds,
      tags: dto.tags,
      sources: dto.sources,
      messages: dto.messages.map(_messageToDomain).toList(),
    );
  }

  StoryMessage _messageToDomain(StoryMessageDto dto) {
    return StoryMessage(
      type: _typeToDomain(dto.type),
      text: dto.text,
      characterId: dto.characterId,
    );
  }

  StoryMessageType _typeToDomain(String raw) {
    return switch (raw) {
      'narration' => StoryMessageType.narration,
      'chat' => StoryMessageType.chat,
      _ => throw FormatException('알 수 없는 메시지 타입: $raw'),
    };
  }
}
