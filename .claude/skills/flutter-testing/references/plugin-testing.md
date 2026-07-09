# Plugin Testing Guide

## 개요

Flutter 플러그인은 네이티브 코드를 포함하기 때문에 특별한 테스트 전략이 필요합니다. 이 가이드는 Dart, 네이티브, 통합 테스트를 통해 플러그인 패키지를 테스트하는 방법을 다룹니다.

## 플러그인 테스트 유형

| 유형              | 테스트 대상                    | 실행 환경              | 목적                            |
|------------------|-------------------------------|----------------------|---------------------------------|
| Dart Unit        | 단일 클래스/함수               | Dart VM              | Dart 코드를 격리하여 테스트      |
| Dart Widget      | UI 컴포넌트                   | 테스트 환경           | 위젯 동작 테스트                 |
| Dart Integration | Dart + 네이티브 브릿지         | 기기/에뮬레이터        | 플러그인 전체 기능 테스트        |
| Native Unit      | 네이티브 코드                  | 네이티브 테스트 환경   | 네이티브 코드를 격리하여 테스트  |
| Native UI        | 네이티브 UI + Flutter UI      | 기기/에뮬레이터        | 네이티브 UI 상호작용 테스트      |

## 프로젝트 구조

```
my_plugin/
├── lib/                    # Dart code
│   └── my_plugin.dart
├── android/                 # Android native code
│   └── src/test/           # Android unit tests
├── ios/                    # iOS native code
├── example/                 # Example app
│   ├── integration_test/      # Integration tests
│   ├── ios/RunnerTests/     # iOS tests
│   └── lib/
├── test/                    # Dart unit tests
│   └── my_plugin_test.dart
└── pubspec.yaml
```

## Dart 유닛 테스트

### 기본 플러그인 유닛 테스트

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_plugin/my_plugin.dart';

void main() {
  test('plugin initializes correctly', () {
    final plugin = MyPlugin();
    expect(plugin.initialized, false);
    
    plugin.initialize();
    expect(plugin.initialized, true);
  });
  
  test('processes data correctly', () {
    final plugin = MyPlugin();
    final result = plugin.processData([1, 2, 3]);
    
    expect(result, [2, 4, 6]);
  });
}
```

### 유닛 테스트에서 플랫폼 채널 모킹

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_plugin/my_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MyPlugin plugin;
  
  setUp(() {
    // Mock platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.my_plugin'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getNativeValue') {
          return 42;
        }
        return null;
      },
    );
    
    plugin = MyPlugin();
  });
  
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.my_plugin'),
      null,
    );
  });
  
  test('gets value from native side', () async {
    final result = await plugin.getNativeValue();
    expect(result, 42);
  });
}
```

## Dart 통합 테스트

### 설정

`example/pubspec.yaml`에 추가:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
  my_plugin:
    path: ../
```

### 기본 통합 테스트

```dart
// example/integration_test/my_plugin_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_plugin_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('plugin works in real app', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    final plugin = MyPlugin();
    final result = await plugin.getNativeValue();
    
    expect(result, greaterThan(0));
  });
}
```

### 테스트 드라이버 생성

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

### 통합 테스트 실행

```bash
# From example directory
cd example
flutter test integration_test/

# Or with driver
flutter drive --target=integration_test/my_plugin_test.dart
```

## Android 유닛 테스트

### 설정

`android/src/test/java/com/example/my_plugin/MyPluginTest.java`에 테스트를 작성합니다:

```java
package com.example.my_plugin;

import org.junit.Test;
import static org.junit.Assert.*;

public class MyPluginTest {
    
    @Test
    public void testNativeMethod() {
        MyPlugin plugin = new MyPlugin();
        int result = plugin.calculate(10, 20);
        
        assertEquals(30, result);
    }
    
    @Test
    public void testStringProcessing() {
        MyPlugin plugin = new MyPlugin();
        String result = plugin.process("hello");
        
        assertEquals("HELLO", result);
    }
}
```

### Android 테스트 실행

```bash
# From android directory
cd example/android

# Run all tests
./gradlew testDebugUnitTest

# Run specific test
./gradlew test --tests MyPluginTest.testNativeMethod
```

## iOS 유닛 테스트

### 설정

`example/ios/RunnerTests/RunnerTests.m`에 테스트를 작성합니다:

```objectivec
#import <XCTest/XCTest.h>
#import "MyPlugin.h"

@interface MyPluginTest : XCTestCase
@end

@implementation MyPluginTest

- (void)setUp {
    [super setUp];
    // Setup code
}

- (void)testNativeMethod {
    MyPlugin *plugin = [[MyPlugin alloc] init];
    NSInteger result = [plugin calculateWithA:10 b:20];
    
    XCTAssertEqual(result, 30);
}

- (void)testStringProcessing {
    MyPlugin *plugin = [[MyPlugin alloc] init];
    NSString *result = [plugin processString:@"hello"];
    
    XCTAssertEqualObjects(result, @"HELLO");
}

@end
```

### iOS 테스트 실행

```bash
# From ios directory
cd example/ios

# Run tests
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -configuration Debug

# Or run from Xcode
# Product > Test
```

## 네이티브 UI 테스트 (Espresso/XCUITest)

### Android Espresso 테스트

```java
// android/src/androidTest/java/com/example/my_plugin/UiTest.java
package com.example.my_plugin;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withText;

@RunWith(AndroidJUnit4.class)
public class UiTest {
    
    @Rule
    public ActivityTestRule<MainActivity> activityRule = 
        new ActivityTestRule<>(MainActivity.class);
    
    @Test
    public void testPluginButton() {
        onView(withText("Plugin Button"))
            .check(matches(isDisplayed()));
    }
}
```

### iOS XCUITest

```objectivec
// example/ios/RunnerUITests/RunnerUITests.m
#import <XCTest/XCTest.h>

@interface RunnerUITests : XCTestCase
@end

@implementation RunnerUITests

- (void)setUp {
    [super setUp];
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
}

- (void)testPluginButtonExists {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *button = app.buttons[@"Plugin Button"];
    
    XCTAssertTrue(button.exists);
}

- (void)testPluginButtonClick {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *button = app.buttons[@"Plugin Button"];
    
    [button tap];
    
    XCUIElement *result = app.staticTexts[@"Success"];
    XCTAssertTrue(result.exists);
}

@end
```

## 플러그인 초기화 테스트

### 플러그인 등록 테스트

```dart
testWidgets('plugin registers correctly', (tester) async {
  final calls = <MethodCall>[];
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.example.my_plugin'),
    (MethodCall methodCall) async {
      calls.add(methodCall);
      return null;
    },
  );
  
  await tester.pumpWidget(const MyApp());
  
  expect(calls.any((call) => call.method == 'initialize'), true);
});
```

## 에러 처리 테스트

### 네이티브 에러 처리

```dart
testWidgets('handles native errors', (tester) async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.example.my_plugin'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'failingMethod') {
        throw PlatformException(
          code: 'ERROR',
          message: 'Native error occurred',
        );
      }
      return null;
    },
  );
  
  final plugin = MyPlugin();
  
  expect(
    () => plugin.failingMethod(),
    throwsA(isA<PlatformException>()),
  );
});
```

## 플랫폼별 기능 테스트

### Android 전용 테스트

```java
@Test
public void testAndroidOnlyFeature() {
    MyPlugin plugin = new MyPlugin();
    
    // Test Android-specific API
    Context context = InstrumentationRegistry.getTargetContext();
    String deviceModel = plugin.getDeviceModel(context);
    
    assertNotNull(deviceModel);
}
```

### iOS 전용 테스트

```objectivec
- (void)testIOSOnlyFeature {
    MyPlugin *plugin = [[MyPlugin alloc] init];
    
    // Test iOS-specific API
    NSString *deviceName = plugin.getDeviceName();
    
    XCTAssertNotNil(deviceName);
}
```

## 멀티 플랫폼 테스트

### 플랫폼 감지 테스트

```dart
testWidgets('works on all platforms', (tester) async {
  final plugin = MyPlugin();
  final platform = await plugin.getPlatform();
  
  if (Platform.isAndroid) {
    expect(platform, contains('Android'));
  } else if (Platform.isIOS) {
    expect(platform, contains('iOS'));
  }
});
```

## 성능 테스트

### 네이티브 성능 테스트

```java
@Test
public void testPerformance() {
    MyPlugin plugin = new MyPlugin();
    
    long startTime = System.nanoTime();
    plugin.heavyOperation();
    long endTime = System.nanoTime();
    
    long duration = endTime - startTime;
    long maxDuration = 100_000_000; // 100ms
    
    assertTrue("Operation too slow", duration < maxDuration);
}
```

## 권장 사항

1. **각 레이어별로 테스트하기** — Dart, 네이티브, 통합 테스트 모두 작성
2. **플랫폼 채널 모킹** — Dart 유닛 테스트에서는 플랫폼 채널을 모킹하여 사용
3. **에러 케이스 테스트** — 네이티브 실패, 네트워크 오류 등의 상황 검증
4. **통합 테스트 활용** — 플러그인 전체 기능을 실제 환경에서 검증
5. **실제 기기에서 테스트** — 플랫폼별 기능은 반드시 실제 기기에서 확인
6. **테스트 독립성 유지** — 각 테스트는 다른 테스트에 의존하지 않아야 함
7. **모든 플랫폼에서 테스트** — Android, iOS, 웹, 데스크톱 환경 모두 검증
8. **플랫폼 제한 사항 문서화** — 플랫폼별 동작 차이를 명시적으로 기록

## 플러그인을 위한 CI/CD

### GitHub Actions

```yaml
name: Plugin Tests

on: [push, pull_request]

jobs:
  dart-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test
      
  android-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Android tests
        run: |
          cd example/android
          ./gradlew testDebugUnitTest
          
  ios-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run iOS tests
        run: |
          cd example/ios
          xcodebuild test -workspace Runner.xcworkspace \
            -scheme Runner -configuration Debug
```
