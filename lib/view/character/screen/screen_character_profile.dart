import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/character/model/model_character.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/store_content.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';
import '../../story/screen/screen_chat.dart';
import '../widget/character_avatar.dart';

/// 인물 프로필 — ContentStore 에서 읽고, 등장 이야기의 NEW 여부만 열람 상태를 본다.
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
    final scheme = theme.colorScheme;
    final accent = CharacterAvatar.colorFor(character.id);
    final stories = store.storiesFeaturing(character.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const _CircleBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // 색 링을 두른 대형 아바타.
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 3),
              ),
              child: CharacterAvatar(
                name: character.name,
                portrait: character.portrait,
                id: character.id,
                radius: 52,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(character.name, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              character.oneLiner,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              character.lifespan,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          Text('인물 소개', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(character.description),
          if (character.relations.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('관계도', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _RelationDiagram(character: character),
          ],
          if (stories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('📖 등장 이야기', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final story in stories)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StoryCard(story: story, accent: accent),
              ),
          ],
        ],
      ),
    );
  }
}

/// 흰 원 배경의 원형 뒤로가기 버튼.
class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).maybePop(),
          child: Icon(Icons.arrow_back, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}

/// 세로 관계 다이어그램 — 본인을 위에 두고, 각 관계를 라벨로 잇는다.
class _RelationDiagram extends StatelessWidget {
  const _RelationDiagram({required this.character});

  final CharacterModel character;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          _RelationNode(
            name: character.name,
            portrait: character.portrait,
            id: character.id,
            radius: 28,
            emphasize: true,
          ),
          for (final relation in character.relations) ...[
            const _Connector(),
            _RelationLabel(relation.label),
            const _Connector(),
            Builder(
              builder: (context) {
                final target = store.characterById(relation.targetId);
                final name = target?.name ?? relation.targetId;
                final node = _RelationNode(
                  name: name,
                  portrait: target?.portrait ?? '',
                  id: target?.id,
                  radius: 24,
                );
                if (target == null) return node;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CharacterProfileScreen(characterId: target.id),
                    ),
                  ),
                  child: node,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _RelationNode extends StatelessWidget {
  const _RelationNode({
    required this.name,
    required this.portrait,
    required this.id,
    required this.radius,
    this.emphasize = false,
  });

  final String name;
  final String portrait;
  final String? id;
  final double radius;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CharacterAvatar(
          name: name,
          portrait: portrait,
          id: id,
          radius: radius,
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: emphasize
              ? theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 14,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _RelationLabel extends StatelessWidget {
  const _RelationLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 등장 이야기 카드 — 색 점 + 제목/유적지 + 미열람 시 NEW.
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, required this.accent});

  final StoryModel story;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = context.read<ContentStore>();
    final siteName = store.siteById(story.siteId)?.name;
    final isOpened = context.select<ReadStatusStateHolder, bool>(
      (holder) => holder.isOpened(story.id),
    );
    final progress = context.select<ReadStatusStateHolder, int>(
      (holder) => holder.progressOf(story.id),
    );
    final isNew = !isOpened && progress == 0;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatScreen(story: story)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (siteName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 13, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            siteName,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isNew) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      color: scheme.onSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
