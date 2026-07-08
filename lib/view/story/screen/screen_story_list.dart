import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../core/view/ui_event.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/store_content.dart';
import '../../character/widget/character_avatar.dart';
import '../../read_status/state_holder/state_holder_read_status.dart';
import '../view_model/view_model_story_list.dart';
import 'screen_chat.dart';

/// 이야기 목록 화면 — 유적지 이야기를 한 줄씩 모아 보여준다.
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
    // 카테고리 필터는 잠시 비활성. 선택 태그가 없으면 전체 목록이 그대로 나온다.
    final stories = context.watch<StoryListViewModel>().filteredStories;

    return Scaffold(
      appBar: AppBar(title: const Text('유적담')),
      body: Column(
        children: [
          Expanded(
            child: stories.isEmpty
                ? const Center(child: Text('이야기가 없습니다.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: stories.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) =>
                        _StoryRow(story: stories[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 이야기 한 줄 — 대표 인물 아바타 + 제목/위치/도입부.
class _StoryRow extends StatelessWidget {
  const _StoryRow({required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = context.read<ContentStore>();

    final characters = store.charactersOf(story);
    final lead = characters.isEmpty ? null : characters.first;
    final siteName = store.siteById(story.siteId)?.name;
    final intro = story.messages.isEmpty ? '' : story.messages.first.text;

    final isOpened = context.select<ReadStatusStateHolder, bool>(
      (holder) => holder.isOpened(story.id),
    );
    final progress = context.select<ReadStatusStateHolder, int>(
      (holder) => holder.progressOf(story.id),
    );
    final isNew = !isOpened && progress == 0;

    final location = [
      if (lead != null) lead.name,
      if (siteName != null) siteName,
    ].join(' · ');

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatScreen(story: story)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lead == null
                ? CircleAvatar(
                    radius: 26,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Icon(Icons.menu_book, color: scheme.onSurfaceVariant),
                  )
                : CharacterAvatar(
                    name: lead.name,
                    portrait: lead.portrait,
                    id: lead.id,
                    radius: 26,
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          story.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        const _NewBadge(),
                      ],
                    ],
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (intro.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      intro,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!isNew) ...[
              const SizedBox(width: 8),
              _ProgressLabel(
                progress: progress,
                total: story.messages.length,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 미열람 이야기에 붙는 NEW 배지 — 시안 톤에 맞춘 세이지 알약.
class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    );
  }
}

/// 진행 중 이야기의 우측 진행도 퍼센트.
class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({required this.progress, required this.total});

  final int progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
