import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../core/view/ui_event.dart';
import '../../../domain/character/model/model_character.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/store_content.dart';
import '../../character/widget/character_avatar.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';
import '../view_model/view_model_story_list.dart';
import 'screen_chat.dart';

/// 이야기 목록 화면 — 채팅방 목록 메타포.
class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  late final StoryListViewModel _viewModel;
  late final StreamSubscription<UiEvent> _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I.get<StoryListViewModel>();
    _eventSub = _viewModel.eventStream.listen((event) {
      if (!mounted) return;
      if (event is ShowToast) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(event.message)));
      }
    });
  }

  @override
  void dispose() {
    _eventSub.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoryListViewModel>.value(
      value: _viewModel,
      child: const _StoryListBody(),
    );
  }
}

class _StoryListBody extends StatelessWidget {
  const _StoryListBody();

  @override
  Widget build(BuildContext context) {
    // 목록은 VM 의 파생값, 태그 칩 목록은 store 에서 직접 읽는다.
    final stories = context.watch<StoryListViewModel>().filteredStories;
    final viewModel = context.read<StoryListViewModel>();
    final tags = context.read<ContentStore>().allTags();

    return Scaffold(
      appBar: AppBar(title: const Text('이야기')),
      body: Column(
        children: [
          _FilterChips(
            tags: tags,
            selectedTag: viewModel.selectedTag,
            onTagSelected: viewModel.selectTag,
          ),
          Expanded(
            child: stories.isEmpty
                ? const Center(child: Text('이야기가 없습니다.'))
                : ListView.builder(
                    itemCount: stories.length,
                    itemBuilder: (context, index) =>
                        _StoryCard(story: stories[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  static const double _barHeight = 56;

  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FilterChip(
              label: const Text('전체'),
              selected: selectedTag == null,
              onSelected: (_) => onTagSelected(null),
            ),
          ),
          for (final tag in tags)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: FilterChip(
                label: Text(tag),
                selected: selectedTag == tag,
                onSelected: (_) => onTagSelected(tag),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();
    final characters = store.charactersOf(story);
    final isOpened = context.select<ReadStatusStateHolder, bool>(
      (holder) => holder.isOpened(story.id),
    );
    final progress = context.select<ReadStatusStateHolder, int>(
      (holder) => holder.progressOf(story.id),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _AvatarCluster(characters: characters),
        title: Text(story.title),
        trailing: _CardStatus(
          isOpened: isOpened,
          progress: progress,
          total: story.messages.length,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(story: story),
          ),
        ),
      ),
    );
  }
}

/// 카드 우측 상태 표시 — 시작 전이면 NEW 배지, 그 외에는 진행도 퍼센트.
class _CardStatus extends StatelessWidget {
  const _CardStatus({
    required this.isOpened,
    required this.progress,
    required this.total,
  });

  final bool isOpened;
  final int progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!isOpened && progress == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.tertiary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'NEW',
          style: TextStyle(
            color: scheme.onTertiary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    final percent = total == 0 ? 0 : (progress / total * 100).round();
    return Text(
      '$percent%',
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AvatarCluster extends StatelessWidget {
  const _AvatarCluster({required this.characters});

  final List<CharacterModel> characters;

  @override
  Widget build(BuildContext context) {
    final shown = characters.take(3).toList();
    if (shown.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.menu_book));
    }
    const overlap = 18.0;
    return SizedBox(
      width: 40 + (shown.length - 1) * overlap,
      height: 40,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * overlap,
              child: CharacterAvatar(
                name: shown[i].name,
                portrait: shown[i].portrait,
                radius: 18,
              ),
            ),
        ],
      ),
    );
  }
}
