import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/character/model/model_character.dart';
import '../../app/store_content.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';
import '../widget/character_avatar.dart';
import 'screen_character_profile.dart';

/// 도감 한 칸 — 인물과 공개 여부.
class CodexEntry {
  const CodexEntry({required this.character, required this.revealed});

  final CharacterModel character;
  final bool revealed;
}

/// 인물 도감 — 열람한 이야기에 등장한 인물만 공개한다.
class CharacterCodexScreen extends StatelessWidget {
  const CharacterCodexScreen({super.key});

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
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _CodexCell(entry: entries[index]),
          );
        },
      ),
    );
  }
}

/// 열람한 이야기에 등장한 인물만 공개로 파생한다.
List<CodexEntry> _buildEntries(
  ContentStore store,
  ReadStatusStateHolder readStatus,
) {
  final opened = readStatus.openedStoryIds;
  return store.characters.map((character) {
    final revealed = store
        .storiesFeaturing(character.id)
        .any((story) => opened.contains(story.id));
    return CodexEntry(character: character, revealed: revealed);
  }).toList();
}

class _CodexCell extends StatelessWidget {
  const _CodexCell({required this.entry});

  final CodexEntry entry;

  @override
  Widget build(BuildContext context) {
    final character = entry.character;
    if (!entry.revealed) {
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
