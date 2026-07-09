import 'package:flutter/material.dart';

import '../../app/app_motion.dart';

/// 채팅 진행도 바 — 읽은 말풍선 비율을 앱바 아래에 얇게 보여준다.
///
/// 이야기의 길이와 끝을 가늠하게 해 몰입·완독을 돕는다. 값 변화는 단발
/// [TweenAnimationBuilder] 로 부드럽게 채운다.
class ChatProgressBar extends StatelessWidget {
  const ChatProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  /// 현재까지 노출된 말풍선 수.
  final int current;

  /// 전체 말풍선 수.
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: AppMotion.short,
      curve: AppMotion.curve,
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        minHeight: 3,
        backgroundColor: scheme.surfaceContainerHighest,
        color: scheme.primary,
      ),
    );
  }
}
