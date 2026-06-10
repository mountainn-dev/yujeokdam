import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/character/model/model_character.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/store_content.dart';
import '../../story/screen/screen_chat.dart';
import '../widget/character_avatar.dart';

/// 인물 프로필 — ContentStore 에서 읽기만 하므로 ViewModel 불필요.
class CharacterProfileScreen extends StatelessWidget {
  const CharacterProfileScreen({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();
    final character = store.characterById(characterId);

    if (character == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('인물 정보가 없습니다.')),
      );
    }

    final theme = Theme.of(context);
    final stories = store.storiesFeaturing(character.id);

    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CharacterAvatar(
              name: character.name,
              portrait: character.portrait,
              radius: 56,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(character.name, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              character.lifespan,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            character.oneLiner,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Text(character.description),
          if (character.relations.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('관계도', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final relation in character.relations)
                  _RelationChip(relation: relation, store: store),
              ],
            ),
          ],
          if (stories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('등장 이야기', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final story in stories) _StoryTile(story: story),
          ],
        ],
      ),
    );
  }
}

class _RelationChip extends StatelessWidget {
  const _RelationChip({required this.relation, required this.store});

  final CharacterRelation relation;
  final ContentStore store;

  @override
  Widget build(BuildContext context) {
    final target = store.characterById(relation.targetId);
    final name = target?.name ?? relation.targetId;
    return ActionChip(
      avatar: const Icon(Icons.link, size: 16),
      label: Text('$name · ${relation.label}'),
      onPressed: target == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CharacterProfileScreen(characterId: target.id),
                ),
              ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.chat_bubble_outline),
      title: Text(story.title),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatScreen(story: story)),
      ),
    );
  }
}
