# 자주 발생하는 테스트 오류

## 개요

이 가이드는 Flutter 테스트에서 자주 마주치는 오류와 그 해결책을 다룹니다.

## 레이아웃 오류

### 'A RenderFlex overflowed...'

**오류 메시지:**
```
The following assertion was thrown during layout:
A RenderFlex overflowed by 1146 pixels on the right.
```

**원인:** 자식 위젯이 부모(`Row`/`Column`)보다 클 때 노란색과 검은색 줄무늬로 오버플로가 표시됩니다.

**해결:** 오버플로가 발생하는 위젯을 `Expanded` 또는 `Flexible`로 감쌉니다.

```dart
// 문제
Row(
  children: [
    Icon(Icons.message),
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: Theme.of(context).textTheme.headlineMedium),
        Text('Very long text that overflows the available space...'),
      ],
    ),
  ],
)

// 해결
Row(
  children: [
    Icon(Icons.message),
    Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title', style: Theme.of(context).textTheme.headlineMedium),
          Text('Very long text that fits in the available space...'),
        ],
      ),
    ),
  ],
)
```

### 'Vertical viewport was given unbounded height'

**오류 메시지:**
```
Vertical viewport was given unbounded height.
Viewports expand in the scrolling direction to fill their container.
This situation typically happens when a scrollable widget is nested inside another scrollable widget.
```

**원인:** `Column` 내부의 `ListView` 또는 다른 스크롤 가능 위젯에 높이 제약이 없을 때 발생합니다.

**해결:** `Expanded`로 감싸거나 `shrinkWrap: true`를 사용합니다.

```dart
// 문제
Column(
  children: [
    Text('Header'),
    ListView(
      children: [
        ListTile(leading: Icon(Icons.map), title: Text('Map')),
        ListTile(leading: Icon(Icons.subway), title: Text('Subway')),
      ],
    ),
  ],
)

// 해결 1: Expanded 사용
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView(
        children: [
          ListTile(leading: Icon(Icons.map), title: Text('Map')),
          ListTile(leading: Icon(Icons.subway), title: Text('Subway')),
        ],
      ),
    ),
  ],
)

// 해결 2: shrinkWrap 사용
Column(
  children: [
    Text('Header'),
    ListView(
      shrinkWrap: true,
      children: [
        ListTile(leading: Icon(Icons.map), title: Text('Map')),
        ListTile(leading: Icon(Icons.subway), title: Text('Subway')),
      ],
    ),
  ],
)
```

### 'An InputDecorator...cannot have an unbounded width'

**오류 메시지:**
```
An InputDecorator, which is typically created by a TextField, cannot have an unbounded width.
This happens when the parent widget does not provide a finite width constraint.
```

**원인:** `Row` 내부의 `TextField` 또는 `TextFormField`에 너비 제약이 없을 때 발생합니다.

**해결:** `Expanded` 또는 `SizedBox`로 감쌉니다.

```dart
// 문제
Row(
  children: [TextField()],
)

// 해결 1: Expanded 사용
Row(
  children: [Expanded(child: TextFormField())],
)

// 해결 2: SizedBox 사용
Row(
  children: [SizedBox(width: 200, child: TextFormField())],
)
```

## 위젯 라이프사이클 오류

### 'setState called during build'

**오류 메시지:**
```
setState() or markNeedsBuild() called during build.
This Overlay widget cannot be marked as needing to build because the framework
is already in the process of building widgets.
```

**원인:** `build` 메서드 내에서 직접 `setState`(또는 `showDialog`처럼 이를 호출하는 메서드)를 호출할 때 발생합니다.

**해결:** `WidgetsBinding.instance.addPostFrameCallback` 또는 Navigator API를 사용합니다.

```dart
// 문제
Widget build(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(title: Text('Error!')),
  );
  return Center(child: Text('Show Dialog'));
}

// 해결 1: 포스트 프레임 콜백 사용
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text('Success!')),
    );
  });
  return Center(child: Text('Show Dialog'));
}

// 해결 2: Navigator API 사용 (초기 네비게이션 시)
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => DialogScreen(),
        ),
      );
    },
    child: Text('Show Dialog'),
  );
}
```

## 부모 위젯 오류

### 'Incorrect use of ParentData widget'

**오류 메시지:**
```
The following assertion was thrown while looking for parent data:
Incorrect use of ParentDataWidget.
Usually, this indicates that at least one of the offending ParentDataWidgets
listed above is not placed directly inside a compatible ancestor widget.
```

**원인:** 특정 부모 위젯을 필요로 하는 위젯을 잘못된 컨텍스트에서 사용할 때 발생합니다.

**일반적인 해결책:**

| 위젯 | 필요한 부모 | 해결책 |
|---|---|---|
| `Flexible` | `Row`, `Column`, `Flex` | 부모가 Row/Column/Flex인지 확인 |
| `Expanded` | `Row`, `Column`, `Flex` | 부모가 Row/Column/Flex인지 확인 |
| `Positioned` | `Stack` | Stack으로 감싸기 |
| `TableCell` | `Table` | 부모가 Table인지 확인 |

```dart
// 문제
Column(
  children: [
    Expanded(child: Text('Wrong!')), // Expanded는 Row/Column/Flex 자식으로 사용해야 함
  ],
)

// 해결
Column(
  children: [
    Row(
      children: [
        Expanded(child: Text('Correct!')),
      ],
    ),
  ],
)
```

## 테스트 전용 오류

### 'WidgetTester.pumpWidget() called with a widget that doesn't include a MaterialApp'

**오류 메시지:**
```
WidgetTester.pumpWidget() called with a widget that doesn't include a MaterialApp.
```

**원인:** `MaterialApp` 컨텍스트 없이 위젯을 펌핑할 때 발생합니다.

**해결:** 위젯을 `MaterialApp`으로 감쌉니다.

```dart
// 문제
testWidgets('test without MaterialApp', (tester) async {
  await tester.pumpWidget(MyWidget());
});

// 해결
testWidgets('test with MaterialApp', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MyWidget(),
    ),
  );
});
```

### 'No Finder found'

**오류 메시지:**
```
No Finder found.
Test failed: No elements found matching the finder.
```

**원인:** 테스트 시점에 위젯 트리에서 위젯을 찾을 수 없을 때 발생합니다.

**일반적인 해결책:**

```dart
// 1. 잘못된 텍스트/내용
expect(find.text('Wrong Text'), findsNothing); // 오류

// 해결: 올바른 텍스트 사용
expect(find.text('Correct Text'), findsOneWidget);

// 2. 위젯이 아직 빌드되지 않은 경우
testWidgets('widget not built', (tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Async Text'), findsOneWidget); // 오류
});

// 해결: 비동기 작업을 위해 pumpAndSettle 사용
testWidgets('widget not built', (tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.pumpAndSettle(); // 비동기 작업 완료 대기
  expect(find.text('Async Text'), findsOneWidget);
});

// 3. 잘못된 finder 타입
testWidgets('wrong finder', (tester) async {
  await tester.pumpWidget(TextButton(child: Text('Button')));
  await tester.tap(find.byType(ElevatedButton)); // 오류
});

// 해결: 올바른 타입 또는 Text finder 사용
testWidgets('correct finder', (tester) async {
  await tester.pumpWidget(TextButton(child: Text('Button')));
  await tester.tap(find.byType(TextButton)); // 정상
});
```

## 플러그인/플랫폼 오류

### 'MissingPluginException'

**오류 메시지:**
```
MissingPluginException(No implementation found for method MethodName on channel channel.name)
```

**원인:** 테스트에서 플러그인이 등록되지 않았거나 모킹이 설정되지 않은 경우 발생합니다.

**해결:** 테스트에서 메서드 채널을 모킹합니다.

```dart
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('your.plugin.channel'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getPlatformVersion') {
          return 'Android 12';
        }
        throw MissingPluginException();
      },
    );
  });
  
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('your.plugin.channel'),
      null,
    );
  });
}
```

## 비동기 오류

### 'TimeoutException'

**오류 메시지:**
```
TimeoutException after 0:00:05.000000: Test timed out after 5 seconds.
```

**원인:** 비동기 작업이 완료되지 않거나 `pumpAndSettle()`이 무한 대기하는 경우 발생합니다.

**해결:** 타임아웃을 설정하거나 무한 루프를 수정합니다.

```dart
// 해결 1: 타임아웃 늘리기
testWidgets(
  'long-running test',
  (tester) async {
    await tester.pumpWidget(MyWidget());
    await Future.delayed(const Duration(seconds: 10));
  },
  timeout: const Timeout(Duration(minutes: 1)),
);

// 해결 2: 무한 pumpAndSettle 수정
testWidgets('fix infinite settle', (tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.pump(); // 애니메이션 루프가 있는 경우 pumpAndSettle() 대신 pump() 사용
});
```

## 데이터 오류

### 'RangeError'

**오류 메시지:**
```
RangeError: Index out of range: index should be less than 5, but is 5
```

**원인:** 유효하지 않은 인덱스로 리스트/배열에 접근할 때 발생합니다.

**해결:** 접근 전 범위를 확인하거나 빈 케이스를 처리합니다.

```dart
// 문제
testWidgets('range error', (tester) async {
  final items = [1, 2, 3, 4, 5];
  expect(items[5], 6); // 오류: 인덱스 5는 범위를 벗어남
});

// 해결 1: 범위 확인
testWidgets('safe access', (tester) async {
  final items = [1, 2, 3, 4, 5];
  if (items.length > 5) {
    expect(items[5], 6);
  }
});

// 해결 2: 빈 리스트 처리
testWidgets('handle empty list', (tester) async {
  final items = <int>[];
  if (items.isEmpty) {
    expect(find.text('No items'), findsOneWidget);
  } else {
    expect(items.first, 1);
  }
});
```

## 디버깅 팁

### 상세 로깅 활성화

```bash
flutter test --verbose
```

### 스크린샷 캡처

```dart
testWidgets('debug with screenshot', (tester) async {
  await tester.pumpWidget(MyWidget());
  await tester.takeScreenshot('debug-state');
});
```

### 위젯 트리 출력

```dart
testWidgets('print tree', (tester) async {
  await tester.pumpWidget(MyWidget());
  debugDumpApp();
});
```

### 디버그 플래그 사용

```dart
testWidgets('debug flags', (tester) async {
  debugPrint('Current state: ...');
  await tester.pumpWidget(MyWidget());
  debugPrint('Widget tree: ${tester.widgetList(find.byType(MyWidget))}');
});
```

## 예방

### 타입 안전성 활용

```dart
// 좋음: 타입 안전한 접근 방식
final text = tester.widget<Text>(find.byType(Text));

// 지양: 안전하지 않은 캐스팅
final text = find.byType(Text).evaluate().first.widget as Text;
```

### 액션 전 확인

```dart
testWidgets('safe tap', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  final button = find.byType(ElevatedButton);
  if (button.evaluate().isNotEmpty) {
    await tester.tap(button);
  } else {
    fail('Button not found');
  }
});
```

### 모든 케이스 처리

```dart
testWidgets('comprehensive', (tester) async {
  await tester.pumpWidget(MyWidget());
  
  // 모든 가능한 상태 확인
  if (find.text('Loading').evaluate().isNotEmpty) {
    // 로딩 상태 처리
  } else if (find.text('Error').evaluate().isNotEmpty) {
    // 오류 상태 처리
  } else {
    // 성공 상태 처리
  }
});
```
