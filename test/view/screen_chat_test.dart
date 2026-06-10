import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:yujeokdam/domain/story/model/model_story.dart';
import 'package:yujeokdam/view/app/store_content.dart';
import 'package:yujeokdam/view/read_status/state_holder/state_holder_read_status.dart';
import 'package:yujeokdam/view/story/screen/screen_chat.dart';

import 'view_test_harness.dart';

void main() {
  const story = StoryModel(
    id: 's1',
    title: '테스트 이야기',
    siteId: 'site1',
    characterIds: ['c1'],
    tags: ['신라'],
    sources: ['삼국사기'],
    messages: [
      StoryMessage(type: StoryMessageType.narration, text: '첫 번째 메시지'),
      StoryMessage(
          type: StoryMessageType.chat, characterId: 'c1', text: '두 번째 메시지'),
      StoryMessage(
          type: StoryMessageType.chat, characterId: 'c1', text: '세 번째 메시지'),
    ],
  );

  Widget wrap() {
    return MultiProvider(
      providers: [
        Provider<ContentStore>.value(value: GetIt.I.get<ContentStore>()),
        ChangeNotifierProvider<ReadStatusStateHolder>.value(
          value: GetIt.I.get<ReadStatusStateHolder>(),
        ),
      ],
      child: const MaterialApp(home: ChatScreen(story: story)),
    );
  }

  testWidgets('탭하면 말풍선이 하나씩 늘어난다', (tester) async {
    await registerViewLayer(
      stories: [story],
      characters: const [],
      sites: const [],
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // 처음에는 첫 메시지만 보인다.
    expect(find.text('첫 번째 메시지'), findsOneWidget);
    expect(find.text('두 번째 메시지'), findsNothing);

    // 한 번 탭하면 두 번째 메시지가 나타난다.
    await tester.tap(find.byType(ChatScreen));
    await tester.pumpAndSettle();
    expect(find.text('두 번째 메시지'), findsOneWidget);
    expect(find.text('세 번째 메시지'), findsNothing);

    // 다시 탭하면 세 번째 메시지가 나타난다.
    await tester.tap(find.byType(ChatScreen));
    await tester.pumpAndSettle();
    expect(find.text('세 번째 메시지'), findsOneWidget);
  });
}
