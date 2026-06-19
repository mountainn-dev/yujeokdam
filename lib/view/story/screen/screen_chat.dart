import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../core/view/ui_event.dart';
import '../../../domain/character/model/model_character.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/app_motion.dart';
import '../../app/store_content.dart';
import '../../character/screen/screen_character_profile.dart';
import '../../character/widget/character_avatar.dart';
import '../../heritage/screen/screen_stage.dart';
import '../view_model/view_model_chat.dart';
import '../widget/chat_progress_bar.dart';
import '../widget/epilogue_card.dart';

/// 채팅 뷰어 — 탭하면 메시지가 하나씩 노출된다.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.story});

  final StoryModel story;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatViewModel _viewModel;
  late final StreamSubscription<UiEvent> _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I.get<ChatViewModel>(param1: widget.story);
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
    return ChangeNotifierProvider<ChatViewModel>.value(
      value: _viewModel,
      child: _ChatBody(story: widget.story),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody({required this.story});

  final StoryModel story;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// AnimatedList 에 이미 삽입된 말풍선 수. VM 의 visibleCount 와 동기화한다.
  int _insertedCount = 0;
  late final ChatViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ChatViewModel>();
    _insertedCount = _viewModel.visibleCount;
    // VM 의 visibleCount 가 늘면 새 말풍선만 insertItem 으로 등장시킨다.
    _viewModel.addListener(_syncList);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_syncList);
    _scrollController.dispose();
    super.dispose();
  }

  /// 탭으로 다음 말풍선을 연다. 가벼운 햅틱으로 진행을 손끝에 전한다.
  void _onTapReveal() {
    HapticFeedback.lightImpact();
    _viewModel.revealNext();
  }

  void _syncList() {
    final target = _viewModel.visibleCount;
    // 다시보기로 visibleCount 가 줄면 리스트를 새로 만들어 처음부터 다시 그린다.
    if (target < _insertedCount) {
      setState(() {
        _listKey = GlobalKey<AnimatedListState>();
        _insertedCount = target;
      });
      return;
    }
    var inserted = false;
    while (_insertedCount < target) {
      _listKey.currentState?.insertItem(
        _insertedCount,
        duration: AppMotion.short,
      );
      _insertedCount += 1;
      inserted = true;
    }
    if (inserted) {
      _scrollToEnd();
    }
  }

  /// 새 말풍선이 삽입된 뒤 다음 프레임에 최신 메시지로 부드럽게 스크롤한다.
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppMotion.short,
        curve: AppMotion.curve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final store = context.read<ContentStore>();

    final characters = store.charactersOf(story);
    final lead = characters.isEmpty ? null : characters.first;
    final siteName = store.siteById(story.siteId)?.name;
    final accent = CharacterAvatar.colorFor(lead?.id ?? story.title);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _ChatTitle(
          title: story.title,
          siteName: siteName,
          lead: lead,
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTapReveal,
        child: Column(
          children: [
            Consumer<ChatViewModel>(
              builder: (context, viewModel, _) => ChatProgressBar(
                current: viewModel.visibleCount,
                total: story.messages.length,
              ),
            ),
            _ChatHeaderBanner(accent: accent, siteName: siteName),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                initialItemCount: _insertedCount,
                itemBuilder: (context, index, animation) {
                  final message = story.messages[index];
                  return AppFadeSlideIn(
                    animation: animation,
                    child: _MessageBubble(
                      message: message,
                      character: message.characterId == null
                          ? null
                          : store.characterById(message.characterId!),
                    ),
                  );
                },
              ),
            ),
            Consumer<ChatViewModel>(
              builder: (context, viewModel, _) => AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.curve,
                switchOutCurve: AppMotion.curve,
                child: viewModel.isCompleted
                    ? _StageEpilogue(key: const ValueKey('epilogue'), story: story)
                    : const _TapHint(key: ValueKey('hint')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AppBar 제목 — 대표 인물 아바타 + 이야기 제목 + 유적지 위치.
class _ChatTitle extends StatelessWidget {
  const _ChatTitle({
    required this.title,
    required this.siteName,
    required this.lead,
  });

  final String title;
  final String? siteName;
  final CharacterModel? lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        if (lead != null) ...[
          CharacterAvatar(
            name: lead!.name,
            portrait: lead!.portrait,
            id: lead!.id,
            radius: 16,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.appBarTheme.titleTextStyle
                    ?.copyWith(fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (siteName != null)
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 12, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      siteName!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 대화 위에 얹히는 컬러 헤더 — 대표 인물 색 바탕에 장식 원과 위치 칩.
class _ChatHeaderBanner extends StatelessWidget {
  const _ChatHeaderBanner({required this.accent, required this.siteName});

  final Color accent;
  final String? siteName;

  @override
  Widget build(BuildContext context) {
    final label = siteName == null ? '경주' : '경주 · $siteName';
    return SizedBox(
      height: 76,
      width: double.infinity,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: accent)),
            // 은은한 장식 원들.
            Positioned(
              left: 28,
              top: -18,
              child: _Bubble(size: 64, color: Colors.white.withOpacity(0.12)),
            ),
            Positioned(
              left: 8,
              bottom: -24,
              child: _Bubble(size: 52, color: Colors.white.withOpacity(0.10)),
            ),
            Positioned(
              right: 40,
              bottom: -10,
              child: _Bubble(size: 36, color: Colors.white.withOpacity(0.10)),
            ),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place, size: 15, color: accent),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// 탭하여 이야기를 이어가라는 안내. 단발 fade-in 으로 은은히 나타난다.
class _TapHint extends StatelessWidget {
  const _TapHint({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.4, end: 1),
        duration: AppMotion.medium,
        curve: AppMotion.curve,
        builder: (context, value, child) => Opacity(opacity: value, child: child),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              '화면을 터치하면 다음 이야기가 펼쳐집니다',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// 완독 후 무대로 잇는 에필로그. 유적지가 없으면 아무것도 그리지 않는다.
class _StageEpilogue extends StatelessWidget {
  const _StageEpilogue({super.key, required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();
    final site = store.siteById(story.siteId);
    if (site == null) {
      return const SizedBox.shrink();
    }

    return EpilogueCard(
      siteName: site.name,
      onOpenStage: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StageScreen(site: site, story: story),
        ),
      ),
      onReplay: () => context.read<ChatViewModel>().replay(),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.character});

  final StoryMessage message;
  final CharacterModel? character;

  @override
  Widget build(BuildContext context) {
    if (message.type == StoryMessageType.narration) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final name = character?.name ?? '?';
    final scheme = Theme.of(context).colorScheme;
    final seed = message.characterId ?? name;
    final color = CharacterAvatar.colorFor(seed);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: character == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CharacterProfileScreen(characterId: character!.id),
                      ),
                    ),
            child: CharacterAvatar(
              name: name,
              portrait: character?.portrait ?? '',
              id: character?.id,
              radius: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Text(message.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

