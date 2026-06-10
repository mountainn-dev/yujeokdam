import 'package:flutter/material.dart';

/// 유적담 앱 테마.
///
/// 유적·이야기의 정서를 담아 따뜻한 흙빛 계열을 기조로 한다.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF8C5A3B);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
      ),
    );
  }
}
