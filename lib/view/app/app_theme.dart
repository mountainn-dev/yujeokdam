import 'package:flutter/material.dart';

/// 유적담 앱 테마.
///
/// 디자인 방향은 '깔끔한 동화'. 유적·이야기의 정서를 담은 따뜻한 흙빛을
/// 기조로 하되, 크림빛 여백과 넉넉한 라운딩으로 그림책 같은 부드러움을 준다.
/// 색은 [ColorScheme] 에서, 모양은 컴포넌트 테마에서 한곳에 모아 내려보내므로
/// 각 화면은 별도 스타일 없이 이 테마만 따른다.
class AppTheme {
  const AppTheme._();

  /// 시드(흙빛 갈색). 팔레트의 기준점으로만 남겨둔다.
  static const Color seed = Color(0xFF8C5A3B);

  // 넉넉한 라운딩 토큰 — 동화책 같은 부드러운 모서리.
  static const double _radiusCard = 20;
  static const double _radiusButton = 16;
  static const double _radiusBadge = 10;

  /// 손으로 다듬은 '깔끔한 동화' 라이트 팔레트.
  ///
  /// fromSeed 의 다소 채도 높은 결과 대신, 크림 표면 + 차분한 흙빛/세이지/
  /// 테라코타 포인트로 그림책 톤을 직접 지정한다.
  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF9C6B45), // 따뜻한 흙빛 갈색
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF3DFC9), // 부드러운 탄
    onPrimaryContainer: Color(0xFF3A2616),
    secondary: Color(0xFF7E8C6A), // 세이지 그린
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE4E8D3),
    onSecondaryContainer: Color(0xFF333A24),
    tertiary: Color(0xFFC17A52), // 테라코타
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFAE0CF),
    onTertiaryContainer: Color(0xFF4A2A16),
    error: Color(0xFFB23B3B), // 차분한 벽돌빛
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF6D9D2),
    onErrorContainer: Color(0xFF5A1A12),
    surface: Color(0xFFFBF6EE), // 크림 바탕
    onSurface: Color(0xFF3B302A), // 따뜻한 차콜
    onSurfaceVariant: Color(0xFF6F6258),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F0E5),
    surfaceContainer: Color(0xFFF2E9DB),
    surfaceContainerHigh: Color(0xFFEDE2D1),
    surfaceContainerHighest: Color(0xFFE7DBC8),
    outline: Color(0xFFB7A998),
    outlineVariant: Color(0xFFDED1C0),
    inverseSurface: Color(0xFF362F28),
    onInverseSurface: Color(0xFFF6EEE2),
    inversePrimary: Color(0xFFF0BC8E),
    surfaceTint: Color(0xFF9C6B45),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData get light {
    final base = ThemeData(
      colorScheme: _scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _scheme.surface,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),

      // 그림자를 거의 쓰지 않는 '깔끔한' 평면 톤.
      appBarTheme: AppBarTheme(
        backgroundColor: _scheme.surface,
        foregroundColor: _scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),

      // 이야기 카드 — 부드러운 크림 면 + 넉넉한 라운딩, 테두리/그림자 최소화.
      cardTheme: CardTheme(
        color: _scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
        ),
      ),

      // 필터 칩 — 체크마크 없는 알약형으로 깔끔하게.
      chipTheme: ChipThemeData(
        backgroundColor: _scheme.surfaceContainerHigh,
        selectedColor: _scheme.secondaryContainer,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: _scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          color: _scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),

      // 하단 네비게이션 — 평면 + 세이지 인디케이터.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _scheme.surface,
        indicatorColor: _scheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? _scheme.onSurface : _scheme.onSurfaceVariant,
          );
        }),
      ),

      // 채우기 버튼('무대 보기' 등) — 둥글고 또렷한 형태.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusButton),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusButton),
        ),
        iconColor: _scheme.primary,
      ),

      dividerTheme: DividerThemeData(
        color: _scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // 스낵바 — 떠 있는 둥근 형태.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _scheme.inverseSurface,
        contentTextStyle: TextStyle(color: _scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusBadge),
        ),
      ),
    );
  }

  /// 본문 가독성을 우선한 부드러운 타이포 스케일.
  ///
  /// 별도 폰트 에셋 없이 기본 글꼴 위에서 자간·행간·굵기만 다듬어
  /// 동화책 같은 편안함을 준다.
  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.55),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
    );
  }
}
