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
  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey<AnimatedListState>();

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

    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
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
              '화면을 탭해 이야기를 이어가세요',
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _TypingThenText(color: color, text: message.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 메신저처럼 타이핑 점을 잠깐 보였다가 대사로 전환하는 말풍선 본문.
///
/// 단발 [AnimationController] 로 한 박자만 재생한다(반복 없음 → pumpAndSettle
/// 호환). 텍스트는 처음부터 트리에 상주하고 불투명도만 0→1 로 올라온다.
class _TypingThenText extends StatefulWidget {
  const _TypingThenText({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  State<_TypingThenText> createState() => _TypingThenTextState();
}

class _TypingThenTextState extends State<_TypingThenText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dotsOpacity;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppMotion.typing, vsync: this);
    _dotsOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        children: [
          Opacity(opacity: _textOpacity.value, child: Text(widget.text)),
          if (_dotsOpacity.value > 0)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Opacity(
                  opacity: _dotsOpacity.value,
                  child: _TypingDots(color: widget.color),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 타이핑 인디케이터의 세 점.
class _TypingDots extends StatelessWidget {
  const _TypingDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
