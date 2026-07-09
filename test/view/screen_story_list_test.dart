import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:yujeokdam/domain/story/model/model_story.dart';
import 'package:yujeokdam/view/app/store_content.dart';
import 'package:yujeokdam/view/read_status/state_holder/state_holder_read_status.dart';
import 'package:yujeokdam/view/story/screen/screen_story_list.dart';

import 'view_test_harness.dart';

void main() {
  const story = StoryModel(
    id: 's1',
    title: '안 읽은 이야기',
    siteId: 'site1',
    characterIds: [],
    tags: ['신라'],
    sources: [],
    messages: [
      StoryMessage(type: StoryMessageType.narration, text: 'hi'),
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
      child: const MaterialApp(home: StoryListScreen()),
    );
  }

  testWidgets('안 읽은 이야기에 NEW 배지가 보인다', (tester) async {
    await registerViewLayer(
      stories: [story],
      characters: const [],
      sites: const [],
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('안 읽은 이야기'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
  });

  testWidgets('읽은 이야기에는 NEW 배지가 없다', (tester) async {
    await registerViewLayer(
      stories: [story],
      characters: const [],
      sites: const [],
      opened: {'s1'},
    );

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('NEW'), findsNothing);
  });
}
