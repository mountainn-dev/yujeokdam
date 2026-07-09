import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../read_status/state_holder/state_holder_read_status.dart';
import 'app_theme.dart';
import 'screen_home_shell.dart';
import 'store_content.dart';

/// 유적담 루트 위젯.
///
/// 셸 위에 읽기 전용 [ContentStore] 와 공유 가변 [ReadStatusStateHolder] 를
/// 제공한다. 둘 다 GetIt singleton 을 `.value` 로 주입한다.
class YujeokdamApp extends StatelessWidget {
  const YujeokdamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ContentStore>.value(value: GetIt.I.get<ContentStore>()),
        ChangeNotifierProvider<ReadStatusStateHolder>.value(
          value: GetIt.I.get<ReadStatusStateHolder>(),
        ),
      ],
      child: MaterialApp(
        title: '유적담',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeShellScreen(),
      ),
    );
  }
}
