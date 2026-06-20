import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/character/model/model_character.dart';
import '../../app/app_motion.dart';
import '../../app/store_content.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';
import '../widget/character_avatar.dart';
import 'screen_character_profile.dart';

/// 도감 한 칸 — 인물과 공개 여부.
class _CodexEntry {
  const _CodexEntry({required this.character, required this.revealed});

  final CharacterModel character;
  final bool revealed;
}

/// 인물 도감 — 열람한 이야기에 등장한 인물만 공개한다.
class CharacterCodexScreen extends StatelessWidget {
  const CharacterCodexScreen({super.key});

  static const int _crossAxisCount = 3;
  static const double _cellAspectRatio = 0.62;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('인물 도감')),
      // ReadStatusStateHolder 변화에 반응해 도감을 다시 그린다.
      body: Consumer<ReadStatusStateHolder>(
        builder: (context, readStatus, _) {
          final entries = _buildEntries(store, readStatus);
          if (entries.isEmpty) {
            return const Center(child: Text('인물이 없습니다.'));
          }
          final revealed = entries.where((e) => e.revealed).length;
          return Column(
            children: [
              _UnlockProgress(revealed: revealed, total: entries.length),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: _cellAspectRatio,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _CodexCell(entry: entries[index]),
                ),
              ),
              const _UnlockHintBanner(),
            ],
          );
        },
      ),
    );
  }

  /// 열람한 이야기에 등장한 인물만 공개로 파생한다.
  static List<_CodexEntry> _buildEntries(
    ContentStore store,
    ReadStatusStateHolder readStatus,
  ) {
    final opened = readStatus.openedStoryIds;
    return store.characters.map((character) {
      final revealed = store
          .storiesFeaturing(character.id)
          .any((story) => opened.contains(story.id));
      return _CodexEntry(character: character, revealed: revealed);
    }).toList();
  }
}

/// 상단 해금 진행도 — "n / 총 인물 해금" + 진행 바.
class _UnlockProgress extends StatelessWidget {
  const _UnlockProgress({required this.revealed, required this.total});

  final int revealed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = total == 0 ? 0.0 : revealed / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$revealed / $total 인물 해금',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHigh,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodexCell extends StatelessWidget {
  const _CodexCell({required this.entry});

  final _CodexEntry entry;

  @override
  Widget build(BuildContext context) {
    // 비공개(물음표)→공개(아바타) 전환을 크로스페이드한다.
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.curve,
      switchOutCurve: AppMotion.curve,
      child: entry.revealed
          ? _RevealedCell(
              key: const ValueKey(true),
              character: entry.character,
            )
          : const _HiddenCell(key: ValueKey(false)),
    );
  }
}

/// 카드 공통 외형 — 라운드 면 + 얇은 테두리.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.faded = false});

  final Widget child;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: faded
            ? scheme.surfaceContainer
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: child,
    );
  }
}

class _HiddenCell extends StatelessWidget {
  const _HiddenCell({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _CardShell(
      faded: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: scheme.surfaceContainerHighest,
            child: Icon(Icons.question_mark,
                size: 26, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            '???',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RevealedCell extends StatelessWidget {
  const _RevealedCell({super.key, required this.character});

  final CharacterModel character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = CharacterAvatar.colorFor(character.id);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CharacterProfileScreen(characterId: character.id),
        ),
      ),
      child: _CardShell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CharacterAvatar(
              name: character.name,
              portrait: character.portrait,
              id: character.id,
              radius: 30,
            ),
            const SizedBox(height: 8),
            Text(
              character.name,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                character.oneLiner,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

/// 하단 안내 배너 — 해금 방식을 알린다.
class _UnlockHintBanner extends StatelessWidget {
  const _UnlockHintBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '유적지 이야기를 읽으면 인물이 해금됩니다 🔒',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
