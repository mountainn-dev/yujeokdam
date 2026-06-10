import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../core/view/ui_event.dart';
import '../../../domain/character/model/model_character.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/store_content.dart';
import '../../character/screen/screen_character_profile.dart';
import '../../character/widget/character_avatar.dart';
import '../../heritage/screen/screen_stage.dart';
import '../view_model/view_model_chat.dart';

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
    _viewModel = GetIt.I.get<ChatViewModel>()..bind(widget.story);
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

class _ChatBody extends StatelessWidget {
  const _ChatBody({required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();

    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: Consumer<ChatViewModel>(
        builder: (context, viewModel, _) {
          final visible = story.messages.take(viewModel.visibleCount).toList();
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: viewModel.revealNext,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final message in visible)
                  _MessageBubble(
                    message: message,
                    character: message.characterId == null
                        ? null
                        : store.characterById(message.characterId!),
                  ),
                if (!viewModel.isCompleted)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '화면을 탭해 이야기를 이어가세요',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                if (viewModel.isCompleted) _StageButton(story: story),
              ],
            ),
          );
        },
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

class _StageButton extends StatelessWidget {
  const _StageButton({required this.story});

  final StoryModel story;

  @override
  Widget build(BuildContext context) {
    final store = context.read<ContentStore>();
    final site = store.siteById(story.siteId);
    if (site == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: FilledButton.icon(
        icon: const Icon(Icons.place),
        label: const Text('이야기의 무대 보기'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StageScreen(site: site, story: story),
          ),
        ),
      ),
    );
  }
}
