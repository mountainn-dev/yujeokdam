---
name: flutter-testing
description: Flutter 애플리케이션의 단위 테스트, 위젯 테스트, 통합 테스트를 포괄적으로 안내합니다. 함수/메서드/클래스 단위 테스트 작성, UI 컴포넌트 검증을 위한 위젯 테스트 작성, 종단간 통합 테스트 개발, 의존성 및 플러그인 인터랙션 모킹, 일반적인 테스트 오류 디버깅, 네이티브 코드를 포함한 Flutter 플러그인 테스트, 다양한 빌드 모드(debug, profile, release)에서 테스트 실행이 필요할 때 활용하세요.
metadata:
  author: Stanislav [MADTeacher] Chernyshev
  version: "1.0"
---

# Flutter 테스트

## 개요

이 스킬은 Flutter 애플리케이션의 모든 테스트 유형에 대한 포괄적인 가이드를 제공합니다. Flutter 테스트는 세 가지 범주로 나뉩니다.

- **단위 테스트(Unit tests)** — 개별 함수, 메서드, 클래스를 독립적으로 테스트
- **위젯 테스트(Widget tests)**(컴포넌트 테스트) — 단일 위젯의 UI 외관과 동작을 테스트
- **통합 테스트(Integration tests)** — 앱 전체 또는 주요 부분을 실행하여 종단간 기능을 검증

잘 테스트된 Flutter 앱은 코드 커버리지를 위한 단위·위젯 테스트를 충분히 갖추고, 중요한 유스케이스를 커버하는 통합 테스트도 적절히 포함합니다.

### 테스트 유형별 트레이드오프

| 트레이드오프 | 단위 | 위젯 | 통합 |
|---|---|---|---|
| 신뢰도 | 낮음 | 높음 | 가장 높음 |
| 유지보수 비용 | 낮음 | 높음 | 가장 높음 |
| 의존성 | 적음 | 많음 | 가장 많음 |
| 실행 속도 | 빠름 | 빠름 | 느림 |

### 테스트를 위한 빌드 모드

Flutter는 테스트에 각각 다른 영향을 미치는 세 가지 빌드 모드를 지원합니다.

- **Debug 모드** — 개발 중 핫 리로드와 함께 사용. 어서션 활성화, 디버깅 활성화, 성능은 다소 저하
- **Profile 모드** — 성능 분석에 사용. Release 모드와 유사하나 일부 디버깅 기능 활성화
- **Release 모드** — 배포에 사용. 어서션 비활성화, 속도 및 크기 최적화

## 빠른 시작

### 단위 테스트

단위 테스트는 단일 함수, 메서드, 클래스를 테스트합니다. 외부 의존성을 모킹하고 디스크 I/O 또는 UI 렌더링은 피합니다.

```dart
import 'package:test/test.dart';
import 'package:my_app/counter.dart';

void main() {
  test('Counter value should be incremented', () {
    final counter = Counter();
    counter.increment();
    expect(counter.value, 1);
  });
}
```

실행 명령: `flutter test`

### 위젯 테스트

위젯 테스트는 단일 위젯의 UI 외관과 인터랙션을 검증합니다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget has a title and message', (tester) async {
    await tester.pumpWidget(const MyWidget(title: 'T', message: 'M'));
    
    final titleFinder = find.text('T');
    final messageFinder = find.text('M');
    
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
```

### 통합 테스트

통합 테스트는 실제 기기 또는 에뮬레이터에서 앱 전체를 테스트합니다.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('tap button, verify counter', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pumpAndSettle();
    
    expect(find.text('1'), findsOneWidget);
  });
}
```

실행 명령: `flutter test integration_test/`

## 테스트 워크플로 결정 트리

1. **무엇을 테스트하나요?**
   - 단일 함수/클래스 → [단위 테스트](#단위-테스트)
   - 단일 위젯/컴포넌트 → [위젯 테스트](#위젯-테스트)
   - 완전한 사용자 플로 → [통합 테스트](#통합-테스트)

2. **플러그인/네이티브 코드에 의존하나요?**
   - 예 → [테스트에서 플러그인 사용](#테스트에서-플러그인-사용) 또는 [플러그인 테스트](#플러그인-테스트) 참고

3. **의존성 모킹이 필요한가요?**
   - 예 → [Mocking 가이드](references/mocking.md) 참고

4. **오류가 발생했나요?**
   - [자주 발생하는 테스트 오류](references/common-errors.md) 참고

## 단위 테스트

단위 테스트는 다양한 조건에서 로직 단위의 정확성을 검증합니다.

### 단위 테스트 사용 시점

- 비즈니스 로직 함수 테스트
- 데이터 변환 검증
- 상태 관리 로직 테스트
- 외부 서비스/API 호출 모킹

### 핵심 개념

- `package:test/test.dart` 사용
- Mockito 또는 유사 라이브러리로 의존성 모킹
- 파일 I/O 또는 UI 렌더링 회피
- 빠른 실행, 높은 유지보수성

### 고급 단위 테스트

의존성 모킹, 플러그인 인터랙션, 복잡한 시나리오에 대해서는 [단위 테스트 레퍼런스](references/unit-testing.md)를 참고하세요.

## 위젯 테스트

위젯 테스트는 테스트 환경에서 위젯의 UI 외관과 동작을 검증합니다.

### 위젯 테스트 사용 시점

- 위젯 렌더링 테스트
- 사용자 인터랙션(탭, 드래그, 스크롤) 검증
- 다양한 방향(orientation) 테스트
- 위젯 상태 변경 검증

### 위젯 테스트 패턴

#### 위젯 찾기

```dart
// 텍스트로 찾기
final titleFinder = find.text('Title');

// 위젯 타입으로 찾기
final buttonFinder = find.byType(ElevatedButton);

// 키로 찾기
final fabFinder = find.byKey(const ValueKey('increment'));

// 위젯 인스턴스로 찾기
final myWidgetFinder = find.byWidget(myWidgetInstance);
```

#### 사용자 인터랙션

```dart
// 탭
await tester.tap(buttonFinder);

// 드래그
await tester.drag(listFinder, const Offset(0, -300));

// 텍스트 입력
await tester.enterText(fieldFinder, 'Hello World');

// 스크롤
await tester.fling(listFinder, const Offset(0, -500), 10000);
await tester.pumpAndSettle();
```

#### 방향(orientation) 테스트

```dart
testWidgets('widget in landscape mode', (tester) async {
  // 가로 모드로 설정
  await tester.binding.setSurfaceSize(const Size(800, 400));
  await tester.pumpWidget(const MyApp());
  
  // 가로 모드 동작 검증
  expect(find.byType(MyWidget), findsOneWidget);
  
  // 세로 모드로 복원
  addTearDown(tester.binding.setSurfaceSize(null));
});
```

### 고급 위젯 테스트

스크롤, 복잡한 인터랙션, 성능 테스트에 대해서는 [위젯 테스트 레퍼런스](references/widget-testing.md)를 참고하세요.

## 통합 테스트

통합 테스트는 실제 기기 또는 에뮬레이터에서 앱 전체 또는 주요 부분을 테스트합니다.

### 통합 테스트 사용 시점

- 완전한 사용자 플로 테스트
- 여러 화면/페이지 검증
- 네비게이션 플로 테스트
- 성능 프로파일링

### 통합 테스트 구조

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('end-to-end test', () {
    testWidgets('complete user flow', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // 단계 1: 화면으로 이동
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // 단계 2: 자격 증명 입력
      await tester.enterText(find.byKey(const Key('username')), 'user');
      await tester.enterText(find.byKey(const Key('password')), 'pass');
      
      // 단계 3: 제출
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      
      // 결과 검증
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

### 성능 테스트

```dart
testWidgets('scrolling performance', (tester) async {
  await tester.pumpWidget(const MyApp());
  
  final listFinder = find.byType(ListView);
  
  // 성능 측정
  final timeline = await tester.trace(() async {
    await tester.fling(listFinder, const Offset(0, -500), 10000);
    await tester.pumpAndSettle();
  });
  
  // 타임라인 데이터 분석
  expect(timeline.frames.length, greaterThan(10));
});
```

### 고급 통합 테스트

성능 프로파일링, CI 연동, 복잡한 시나리오에 대해서는 [통합 테스트 레퍼런스](references/integration-testing.md)를 참고하세요.

## 테스트에서 플러그인 사용

플러그인을 사용하는 코드를 테스트할 때는 충돌을 방지하기 위해 특별한 처리가 필요합니다.

### 플러그인을 사용하는 앱 코드 테스트

Flutter 앱에서 플러그인을 사용하는 경우, 단위/위젯 테스트에서 플랫폼 채널 호출을 모킹해야 합니다.

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() {
    // 플랫폼 채널 모킹
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('your.plugin.channel'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getPlatformVersion') {
          return 'Android 12';
        }
        return null;
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

### 플러그인 테스트

Flutter 플러그인(네이티브 코드 포함) 테스트에 대한 포괄적인 가이드는 [플러그인 테스트 레퍼런스](references/plugin-testing.md)를 참고하세요.

## 자주 발생하는 테스트 오류

### 'A RenderFlex overflowed...'

노란색과 검은색 줄무늬는 오버플로를 나타냅니다. 주로 `Row`/`Column` 내부의 제약 없는 자식 위젯이 원인입니다.

**해결:** 오버플로가 발생하는 위젯을 `Expanded` 또는 `Flexible`로 감쌉니다.

```dart
// 문제
Row(
  children: [
    Icon(Icons.message),
    Column(children: [Text('Very long text...')]), // 오버플로!
  ],
)

// 해결
Row(
  children: [
    Icon(Icons.message),
    Expanded(child: Column(children: [Text('Very long text...')])),
  ],
)
```

### 'Vertical viewport was given unbounded height'

`Column` 내부의 `ListView`(또는 다른 스크롤 가능 위젯)에 높이 제약이 없을 때 발생합니다.

**해결:** `Expanded`로 감싸거나 `shrinkWrap: true`를 사용합니다.

```dart
// 문제
Column(
  children: [
    Text('Header'),
    ListView(children: [...]), // 오류!
  ],
)

// 해결
Column(
  children: [
    Text('Header'),
    Expanded(child: ListView(children: [...])),
  ],
)
```

### 'setState called during build'

`build` 메서드 실행 중에는 절대 `setState`를 호출하지 마세요.

**해결:** Navigator API를 사용하거나 빌드 이후 콜백으로 처리를 지연합니다.

더 많은 오류와 해결책은 [오류 레퍼런스](references/common-errors.md)를 참고하세요.

## 테스트 모범 사례

1. **테스트 피라미드** — 단위·위젯 테스트를 많이, 통합 테스트는 적절히
2. **명확한 테스트 이름** — 무엇을, 왜 테스트하는지 이름에서 명확히 드러나야 함
3. **Arrange-Act-Assert** — 명확한 섹션으로 테스트 구조화
4. **테스트 간 독립성 유지** — 각 테스트는 독립적이어야 함
5. **외부 의존성 모킹** — 테스트를 빠르고 안정적으로 유지
6. **CI에서 테스트 실행** — 모든 푸시마다 테스트 자동화

## 테스트 실행

### 모든 테스트 실행

```bash
flutter test
```

### 특정 테스트 파일 실행

```bash
flutter test test/widget_test.dart
```

### 통합 테스트 실행

```bash
flutter test integration_test/
```

### 커버리지 포함 실행

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 플랫폼별 테스트 실행

```bash
# Android
flutter test --platform android

# iOS
flutter test --platform ios

# Web
flutter test --platform chrome
```

## 테스트 디버깅

### 테스트 디버그

```bash
flutter test --no-sound-null-safety test/my_test.dart
```

### 상세 출력

```bash
flutter test --verbose
```

### 특정 테스트 실행

```bash
flutter test --name "Counter value should be incremented"
```

## 리소스

### 레퍼런스 파일

- [단위 테스트 가이드](references/unit-testing.md) — 심층적인 단위 테스트 패턴 및 모킹 전략
- [위젯 테스트 가이드](references/widget-testing.md) — 위젯 찾기, 인터랙션, 고급 시나리오
- [통합 테스트 가이드](references/integration-testing.md) — 종단간 테스트 및 성능 프로파일링
- [Mocking 가이드](references/mocking.md) — 의존성 및 플러그인 인터랙션 모킹
- [자주 발생하는 오류](references/common-errors.md) — 빈번한 테스트 오류 해결책
- [플러그인 테스트](references/plugin-testing.md) — 네이티브 코드를 포함한 Flutter 플러그인 테스트

### 외부 리소스

- [Flutter 테스트 문서](https://docs.flutter.dev/cookbook/testing)
- [flutter_test 패키지](https://pub.dev/packages/flutter_test)
- [Mockito 패키지](https://pub.dev/packages/mockito)
- [Integration Test 패키지](https://pub.dev/packages/integration_test)
