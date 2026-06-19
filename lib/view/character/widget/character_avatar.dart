import 'package:flutter/material.dart';

/// 인물 초상 아바타.
///
/// 표시 우선순위는 다음과 같다.
///   1. `assets/portraits/{id}.png` 같은 초상 이미지([portrait]) — 추후 일러스트를 넣으면 자동 사용.
///   2. 인물 id 별 역할 이모지([glyphFor]) — 이미지가 없을 때의 기본 표현.
///   3. 이름 첫 글자 — 이모지조차 없을 때의 최종 폴백.
///
/// 배경색은 인물별로 안정적으로 정해지는 선명한 색([colorFor])을 쓴다.
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.name,
    required this.portrait,
    this.id,
    this.radius = 20,
    this.color,
  });

  final String name;
  final String portrait;

  /// 인물 id. 역할 이모지([glyphFor])와 색([colorFor]) 결정에 쓴다.
  final String? id;
  final double radius;
  final Color? color;

  /// 시안 톤에 맞춘 선명한 인물 팔레트.
  ///
  /// 인물 구분이 또렷하도록 채도를 높이되, 크림 배경과 어우러지게 명도는 살짝 낮춘다.
  static const List<Color> _palette = [
    Color(0xFFE0A52E), // 골드
    Color(0xFF3E78B2), // 로열 블루
    Color(0xFFCE5E8A), // 로즈
    Color(0xFF2FA37A), // 제이드
    Color(0xFFD9743F), // 테라코타
    Color(0xFF8E6BB0), // 플럼
    Color(0xFF2C9AA0), // 틸
    Color(0xFFE0664F), // 코랄
    Color(0xFF8AA02E), // 올리브
    Color(0xFF5A6BC0), // 인디고
  ];

  /// 인물 id 별 역할 이모지. 초상 이미지가 없을 때 쓰는 기본 표현.
  static const Map<String, String> _glyphById = {
    'soji_king': '👑', // 소지왕
    'court_lady': '🎎', // 왕비
    'monk': '🙏', // 분수승
    'kim_daeseong': '🛕', // 김대성 — 불국사·석불사 건립
    'gyeongjo': '👩', // 경조 — 전생의 어머니
    'kim_munryang': '🧑', // 김문량 — 재상
    'queen_seondeok': '👸', // 선덕여왕
    'minister_eulje': '🧑', // 을제 — 재상
    'king_munmu': '🐉', // 문무왕 — 호국룡 설화
    'king_gyeongae': '👑', // 경애왕
    'gyeon_hwon': '⚔️', // 견훤 — 후백제 무장
  };

  /// 인물 id 의 역할 이모지. 없으면 null.
  static String? glyphFor(String? id) => id == null ? null : _glyphById[id];

  /// id(우선) 또는 이름 해시로 안정적인 선명한 색을 만든다.
  static Color colorFor(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? colorFor(id ?? name);
    final glyph = glyphFor(id);

    final Widget label = glyph != null
        ? Text(glyph, style: TextStyle(fontSize: radius * 0.95))
        : Text(
            name.isEmpty ? '?' : name.characters.first,
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          );

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: label,
    );

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Image.asset(
          portrait,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      ),
    );
  }
}
