/// 채팅 메시지 한 줄의 종류.
enum StoryMessageType {
  /// 장면을 전환하는 나레이션(시스템 메시지).
  narration,

  /// 등장인물의 대사.
  chat,
}

/// 이야기 속 메시지 한 줄.
class StoryMessage {
  final StoryMessageType type;

  /// 대사일 때 말한 인물 id. 나레이션이면 null.
  final String? characterId;
  final String text;

  const StoryMessage({
    required this.type,
    required this.text,
    this.characterId,
  });
}

/// 한 유적지에 얽힌 채팅 형식 이야기.
class StoryModel {
  final String id;
  final String title;

  /// 이야기의 무대가 되는 유적지 id ([HeritageSiteModel.id]).
  final String siteId;

  /// 등장인물 id 목록.
  final List<String> characterIds;
  final List<String> tags;

  /// 이야기의 근거가 되는 사료 출처 목록.
  final List<String> sources;
  final List<StoryMessage> messages;

  const StoryModel({
    required this.id,
    required this.title,
    required this.siteId,
    required this.characterIds,
    required this.tags,
    required this.sources,
    required this.messages,
  });
}
