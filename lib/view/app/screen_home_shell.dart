import 'package:flutter/material.dart';

import '../character/screen/screen_character_codex.dart';
import '../story/screen/screen_story_list.dart';

/// 하단 탭 셸. 이야기·인물 두 탭을 [IndexedStack] 으로 상태 보존하며 전환한다.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedTabIndex = 0;

  static const List<Widget> _tabs = [
    StoryListScreen(),
    CharacterCodexScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedTabIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedTabIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: '이야기',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: '인물',
          ),
        ],
      ),
    );
  }
}
