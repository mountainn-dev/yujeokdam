# 통합 테스트 가이드

## 개요

통합 테스트는 실제 기기 또는 에뮬레이터에서 앱 전체 또는 주요 부분을 테스트합니다. 모든 위젯과 서비스가 예상대로 함께 동작하는지 검증하고, 성능을 측정할 수 있습니다.

## 통합 테스트를 작성해야 하는 경우

- 여러 화면에 걸친 전체 사용자 흐름 테스트
- 페이지 간 내비게이션 검증
- 상태 지속성 테스트
- 실제 기기 동작 검증 (센서, 카메라 등)
- 성능 프로파일링 및 벤치마킹
- 플랫폼별 기능 테스트

## 설정

### 의존성 추가

`pubspec.yaml`에 추가:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

### 테스트 드라이버 생성

`test_driver/integration_test.dart` 생성:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

## 테스트 구조

### 기본 통합 테스트

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('app launches and displays home', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
```

### 통합 테스트 실행

```bash
# 모든 기기에서 실행
flutter test integration_test/

# 특정 기기에서 실행
flutter test -d <device-id> integration_test/

# 특정 테스트 파일 실행
flutter test integration_test/my_test.dart

# 드라이버로 실행
flutter drive --target=integration_test/my_test.dart
```

## 사용자 흐름 테스트

### 다중 화면 내비게이션

```dart
testWidgets('complete user flow from login to dashboard', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Login screen
  expect(find.text('Login'), findsOneWidget);
  
  // Enter credentials
  await tester.enterText(find.byKey(const Key('username')), 'user@example.com');
  await tester.enterText(find.byKey(const Key('password')), 'password123');
  
  // Tap login
  await tester.tap(find.byKey(const Key('login-button')));
  await tester.pumpAndSettle();
  
  // Dashboard screen
  expect(find.text('Dashboard'), findsOneWidget);
  expect(find.text('Welcome, user@example.com'), findsOneWidget);
});
```

### 탭 내비게이션

```dart
testWidgets('navigate between tabs', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Initial tab
  expect(find.text('Home'), findsOneWidget);
  
  // Tap second tab
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
  
  expect(find.text('Home'), findsNothing);
  expect(find.text('Profile'), findsOneWidget);
  
  // Navigate back
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
  
  expect(find.text('Home'), findsOneWidget);
});
```

## 폼 테스트

### 전체 폼 제출

```dart
testWidgets('submit registration form', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Navigate to registration
  await tester.tap(find.text('Sign Up'));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byKey(const Key('name')), 'John Doe');
  await tester.enterText(find.byKey(const Key('email')), 'john@example.com');
  await tester.enterText(find.byKey(const Key('password')), 'password123');
  await tester.enterText(find.byKey(const Key('confirm-password')), 'password123');
  
  // Submit
  await tester.tap(find.byKey(const Key('submit')));
  await tester.pumpAndSettle();
  
  // Verify success
  expect(find.text('Registration Successful'), findsOneWidget);
});
```

### 폼 유효성 검사

```dart
testWidgets('form shows validation errors', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  await tester.tap(find.text('Sign Up'));
  await tester.pumpAndSettle();
  
  // Submit empty form
  await tester.tap(find.byKey(const Key('submit')));
  await tester.pump();
  
  // Verify errors
  expect(find.text('Name is required'), findsOneWidget);
  expect(find.text('Email is required'), findsOneWidget);
  expect(find.text('Password is required'), findsOneWidget);
  
  // Fill with invalid email
  await tester.enterText(find.byKey(const Key('email')), 'invalid-email');
  await tester.tap(find.byKey(const Key('submit')));
  await tester.pump();
  
  expect(find.text('Invalid email format'), findsOneWidget);
});
```

## 목록 및 데이터 테스트

### 데이터 로딩 및 표시

```dart
testWidgets('load and display items from API', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Wait for data load
  await tester.pumpAndSettle();
  
  // Verify items loaded
  expect(find.byType(ListTile), findsWidgets);
  expect(find.text('Item 1'), findsOneWidget);
  expect(find.text('Item 2'), findsOneWidget);
});
```

### 당겨서 새로 고침

```dart
testWidgets('pull to refresh updates list', (tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  // Pull down
  await tester.drag(
    find.byType(RefreshIndicator),
    const Offset(0, 300),
  );
  await tester.pumpAndSettle();
  
  // Verify refreshed data
  expect(find.text('Updated Item 1'), findsOneWidget);
});
```

### 무한 스크롤

```dart
testWidgets('load more items on scroll', (tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  // Initial items
  expect(find.text('Item 20'), findsNothing);
  
  // Scroll to bottom to trigger load more
  await tester.fling(
    find.byType(ListView),
    const Offset(0, -2000),
    10000,
  );
  await tester.pumpAndSettle();
  
  // New items loaded
  expect(find.text('Item 20'), findsOneWidget);
});
```

## 상태 지속성 테스트

### SharedPreferences

```dart
testWidgets('user preference persists across restarts', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Change setting
  await tester.tap(find.text('Dark Mode'));
  await tester.pumpAndSettle();
  
  // Restart app
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  // Verify setting persisted
  expect(find.text('Light Mode'), findsNothing);
  expect(find.text('Dark Mode'), findsOneWidget);
});
```

### 인증 상태

```dart
testWidgets('user stays logged in', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Login
  await tester.enterText(find.byKey(const Key('email')), 'user@example.com');
  await tester.enterText(find.byKey(const Key('password')), 'password');
  await tester.tap(find.byKey(const Key('login')));
  await tester.pumpAndSettle();
  
  expect(find.text('Dashboard'), findsOneWidget);
  
  // Restart app
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  // Still logged in
  expect(find.text('Dashboard'), findsOneWidget);
  expect(find.text('Login'), findsNothing);
});
```

## 성능 테스트

### 프레임 시간 측정

```dart
testWidgets('measure scrolling performance', (tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  final timeline = await tester.trace(() async {
    await tester.fling(
      find.byType(ListView),
      const Offset(0, -1000),
      5000,
    );
    await tester.pumpAndSettle();
  });
  
  // Analyze frame times
  final frameTimings = timeline.frames.map((frame) => frame.duration).toList();
  final averageFrameTime = frameTimings.reduce((a, b) => a + b) / frameTimings.length;
  
  // Should run at 60fps (16.67ms per frame max)
  expect(averageFrameTime.inMilliseconds, lessThan(17));
});
```

### 빌드 횟수 추적

```dart
testWidgets('widget doesn't rebuild unnecessarily', (tester) async {
  int buildCount = 0;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          buildCount++;
          return const MyWidget();
        },
      ),
    ),
  );
  
  expect(buildCount, 1);
  
  // Perform unrelated action
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
  
  // Should not rebuild
  expect(buildCount, 1);
});
```

### 메모리 추적

```dart
testWidgets('monitor memory usage during scrolling', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  final initialMemory = ProcessInfo.currentRss;
  
  await tester.fling(
    find.byType(ListView),
    const Offset(0, -5000),
    10000,
  );
  await tester.pumpAndSettle();
  
  final finalMemory = ProcessInfo.currentRss;
  final memoryIncrease = finalMemory - initialMemory;
  
  // Memory increase should be reasonable (< 10MB)
  expect(memoryIncrease, lessThan(10 * 1024 * 1024));
});
```

## 플랫폼별 기능 테스트

### 권한

```dart
testWidgets('request and handle camera permission', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Request camera access
  await tester.tap(find.text('Take Photo'));
  await tester.pumpAndSettle();
  
  // Handle permission dialog (platform-specific)
  await tester.pumpAndSettle();
  
  // Verify camera screen appears
  expect(find.byType(CameraPreview), findsOneWidget);
});
```

### 딥 링크

```dart
testWidgets('handle deep link to product page', (tester) async {
  await tester.pumpWidget(const MyApp(initialRoute: '/product/123'));
  await tester.pumpAndSettle();
  
  expect(find.text('Product #123'), findsOneWidget);
});
```

### 인앱 결제

```dart
testWidgets('complete purchase flow', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  await tester.tap(find.text('Premium'));
  await tester.pumpAndSettle();
  
  await tester.tap(find.text('Subscribe'));
  await tester.pumpAndSettle();
  
  // Verify purchase completed
  expect(find.text('Premium Active'), findsOneWidget);
});
```

## 네트워크 테스트

### 오프라인 동작

```dart
testWidgets('handle offline state gracefully', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Simulate offline
  await tester.binding.setSurfaceSize(Size.zero);
  
  // Verify offline message
  expect(find.text('No internet connection'), findsOneWidget);
  
  // Simulate back online
  await tester.binding.setSurfaceSize(const Size(400, 800));
  await tester.pumpAndSettle();
  
  // Reload data
  expect(find.text('Data loaded'), findsOneWidget);
});
```

### 에러 처리

```dart
testWidgets('handle network errors', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Trigger API call
  await tester.tap(find.text('Load Data'));
  await tester.pumpAndSettle();
  
  // Verify error message displayed
  expect(find.text('Failed to load data'), findsOneWidget);
  expect(find.byKey(const Key('retry-button')), findsOneWidget);
});
```

## 애니메이션 테스트

### 부드러운 애니메이션

```dart
testWidgets('animation runs smoothly', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  final timeline = await tester.trace(() async {
    await tester.tap(find.byKey(const Key('animate')));
    await tester.pumpAndSettle();
  });
  
  // Check for janky frames
  final jankyFrames = timeline.frames.where((frame) => 
    frame.duration.inMicroseconds > 16667 // 60fps threshold
  );
  
  expect(jankyFrames.length, lessThan(timeline.frames.length ~/ 10));
});
```

## 모범 사례

1. **핵심 사용자 경로 테스트** — 중요한 흐름에 집중
2. **테스트 독립성 유지** — 각 테스트는 독립적으로 실행 가능해야 함
3. **명확한 테스트 이름 사용** — 테스트가 무엇을 검사하는지 설명
4. **비동기 작업 대기** — `pumpAndSettle()` 사용
5. **실제 동작 테스트** — 목(mock)이 아닌 실제 기기 동작 검증
6. **성능 측정** — 프레임 시간, 메모리, 빌드 횟수 추적
7. **엣지 케이스 테스트** — 오프라인, 에러, 빈 상태
8. **테스트를 빠르게 유지** — 불필요한 지연 방지

## 통합 테스트 디버깅

### 스크린샷 촬영

```dart
testWidgets('debug test with screenshot', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Take screenshot
  await tester.takeScreenshot('test-screenshot');
  
  // Perform actions
  await tester.tap(find.text('Button'));
  await tester.pumpAndSettle();
  
  // Take another screenshot
  await tester.takeScreenshot('after-tap');
});
```

### 위젯 트리 출력

```dart
testWidgets('print widget tree for debugging', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Print widget tree
  debugDumpApp();
});
```

## CI/CD 연동

### GitHub Actions

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run integration tests
        run: flutter test integration_test/
```

### 테스트 리포트

```bash
# Generate test report
flutter test integration_test/ --reporter expanded

# Generate JSON report
flutter test integration_test/ --reporter json > test-results.json
```
