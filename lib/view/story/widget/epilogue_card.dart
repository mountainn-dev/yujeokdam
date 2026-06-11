import 'package:flutter/material.dart';

/// 이야기 완독 후 무대로 잇는 닫는 비트.
///
/// 감정을 끊지 않도록 "끝" 표시와 고정 카피로 마무리하고, 유적지명을 끼운
/// 버튼으로 무대 화면을 연다. 등장 애니메이션은 부모가 담당한다.
class EpilogueCard extends StatelessWidget {
  const EpilogueCard({
    super.key,
    required this.siteName,
    required this.onOpenStage,
  });

  final String siteName;
  final VoidCallback onOpenStage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '─  끝  ─',
            style: theme.textTheme.labelLarge?.copyWith(
              color: muted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '이야기는 여기서 끝납니다.\n하지만 그 무대는 지금도 경주에 남아 있습니다.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.place),
            label: Text('「$siteName」의 무대 보러가기'),
            onPressed: onOpenStage,
          ),
        ],
      ),
    );
  }
}
