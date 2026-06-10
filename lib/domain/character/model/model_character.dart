/// 한 인물과 다른 인물의 관계.
class CharacterRelation {
  /// 상대 인물 id ([CharacterModel.id]).
  final String targetId;

  /// 관계 라벨 — 예: "군신", "라이벌", "부부".
  final String label;

  const CharacterRelation({required this.targetId, required this.label});
}

/// 이야기에 등장하는 역사 인물.
class CharacterModel {
  final String id;
  final String name;

  /// 초상 이미지 에셋 경로.
  final String portrait;

  /// 생몰년 표기 — 예: "?~500".
  final String lifespan;
  final String oneLiner;
  final String description;
  final List<CharacterRelation> relations;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.portrait,
    required this.lifespan,
    required this.oneLiner,
    required this.description,
    required this.relations,
  });
}
