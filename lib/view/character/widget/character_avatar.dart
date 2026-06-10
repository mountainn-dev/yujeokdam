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

  /// 인물 id/이름 해시로 안정적인 색을 만든다.
  static Color colorFor(String seed) {
    final hash = seed.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return Colors.primaries[hash % Colors.primaries.length];
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
