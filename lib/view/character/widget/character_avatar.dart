import 'package:flutter/material.dart';

/// 인물 초상 아바타. 에셋 로드 실패 시 이름 첫 글자 [CircleAvatar] 로 폴백한다.
///
/// 초상 이미지 파일이 아직 없으므로 모든 표시 지점에서 이 위젯을 쓴다.
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.name,
    required this.portrait,
    this.radius = 20,
    this.color,
  });

  final String name;
  final String portrait;
  final double radius;
  final Color? color;

  /// '깔끔한 동화' 톤에 맞춘 차분한 스토리북 팔레트.
  ///
  /// 머티리얼 원색은 채도가 높아 흙빛 테마와 충돌하므로, 인물 구분은 유지하되
  /// 서로 어우러지는 부드러운 색만 쓴다.
  static const List<Color> _palette = [
    Color(0xFFB5835A), // 캐러멜
    Color(0xFF7E8C6A), // 세이지
    Color(0xFFC17A52), // 테라코타
    Color(0xFF6E8CA0), // 더스티 블루
    Color(0xFFA97A8C), // 모브
    Color(0xFF8C9A5B), // 올리브
    Color(0xFFCBA15B), // 허니 오커
    Color(0xFF9C6B45), // 흙빛 갈색
    Color(0xFF7BA089), // 소프트 제이드
    Color(0xFFB76E68), // 클레이 로즈
  ];

  /// 인물 id/이름 해시로 안정적인 색을 만든다.
  static Color colorFor(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final fallbackColor = color ?? colorFor(name);
    final initial = name.isEmpty ? '?' : name.characters.first;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: fallbackColor,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
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
