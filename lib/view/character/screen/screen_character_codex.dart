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
  static const double _cellAspectRatio = 0.75;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('인물')),
      // ReadStatusStateHolder 변화에 반응해 도감을 다시 그린다.
      body: Consumer<ReadStatusStateHolder>(
        builder: (context, readStatus, _) {
          final entries = _buildEntries(store, readStatus);
          if (entries.isEmpty) {
            return const Center(child: Text('인물이 없습니다.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: _cellAspectRatio,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _CodexCell(entry: entries[index]),
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

class _HiddenCell extends StatelessWidget {
  const _HiddenCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.question_mark, size: 28),
        ),
        const SizedBox(height: 8),
        Text('???', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RevealedCell extends StatelessWidget {
  const _RevealedCell({super.key, required this.character});

  final CharacterModel character;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CharacterProfileScreen(characterId: character.id),
        ),
      ),
      child: Column(
        children: [
          CharacterAvatar(
            name: character.name,
            portrait: character.portrait,
            radius: 36,
          ),
          const SizedBox(height: 8),
          Text(
            character.name,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
