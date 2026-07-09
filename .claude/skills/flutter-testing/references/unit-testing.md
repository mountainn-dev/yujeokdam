# Unit Testing Guide

## 개요

유닛 테스트는 개별 함수, 메서드, 또는 클래스를 격리하여 테스트합니다. 유닛 테스트는 잘 테스트된 Flutter 앱의 기반이 되며, 빠른 피드백과 높은 유지보수성을 제공합니다.

## 유닛 테스트를 작성해야 하는 경우

- 비즈니스 로직 함수 테스트
- 데이터 변환 로직 검증
- 상태 관리 로직 테스트 (Bloc, Provider, Riverpod)
- 외부 서비스/API 호출 모킹
- 유틸리티 함수 및 헬퍼 테스트

## 테스트 구조

### 기본 테스트

```dart
import 'package:test/test.dart';

void main() {
  test('description', () {
    // Arrange
    final subject = MyClass();
    
    // Act
    final result = subject.myMethod();
    
    // Assert
    expect(result, expectedValue);
  });
}
```

### 테스트 그룹화

```dart
import 'package:test/test.dart';

void main() {
  group('Counter', () {
    late Counter counter;
    
    setUp(() {
      counter = Counter();
    });
    
    test('value starts at 0', () {
      expect(counter.value, 0);
    });
    
    test('increment increases value', () {
      counter.increment();
      expect(counter.value, 1);
    });
    
    tearDown(() {
      counter.dispose();
    });
  });
}
```

## 테스트 패턴

### 순수 함수 테스트

```dart
// Function to test
int add(int a, int b) => a + b;

// Test
test('add returns sum of two numbers', () {
  expect(add(2, 3), 5);
  expect(add(-1, 1), 0);
});
```

### 상태 변경 테스트

```dart
class Counter {
  int _value = 0;
  int get value => _value;
  
  void increment() => _value++;
  void decrement() => _value--;
  void reset() => _value = 0;
}

// Tests
group('Counter state changes', () {
  late Counter counter;
  
  setUp(() => counter = Counter());
  
  test('initial value is 0', () {
    expect(counter.value, 0);
  });
  
  test('increment increases value by 1', () {
    counter.increment();
    expect(counter.value, 1);
  });
  
  test('decrement decreases value by 1', () {
    counter.decrement();
    expect(counter.value, -1);
  });
  
  test('multiple increments work correctly', () {
    counter.increment();
    counter.increment();
    counter.increment();
    expect(counter.value, 3);
  });
});
```

### 비동기 작업 테스트

```dart
class DataService {
  Future<String> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'data';
  }
}

// Test
test('fetchData returns data after delay', () async {
  final service = DataService();
  final result = await service.fetchData();
  expect(result, 'data');
});
```

### 스트림 테스트

```dart
class CounterStream {
  final _controller = StreamController<int>();
  Stream<int> get stream => _controller.stream;
  
  void increment() => _controller.sink.add(1);
  void dispose() => _controller.close();
}

// Test
test('stream emits values', () async {
  final counter = CounterStream();
  
  expectLater(
    counter.stream,
    emitsInOrder([1, 1, 1]),
  );
  
  counter.increment();
  counter.increment();
  counter.increment();
  
  await Future.delayed(const Duration(milliseconds: 100));
  counter.dispose();
});
```

## 매처(Matchers)

### 자주 사용하는 매처

```dart
// Equality
expect(actual, equals(expected));

// Not equal
expect(actual, isNot(equals(expected)));

// Null checks
expect(value, isNull);
expect(value, isNotNull);

// Numeric comparisons
expect(5, greaterThan(3));
expect(5, lessThan(10));
expect(5, greaterThanOrEqualTo(5));
expect(5, lessThanOrEqualTo(5));

// Type checking
expect(obj, isA<String>());
expect(obj, isNot(isA<int>()));

// String matching
expect(text, contains('substring'));
expect(text, startsWith('prefix'));
expect(text, endsWith('suffix'));
expect(text, matches(RegExp(r'\d+')));

// Lists
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, hasLength(3));
expect(list, contains(item));
expect(list, orderedEquals([1, 2, 3]));
```

### 커스텀 매처

```dart
import 'package:test/test.dart';

class HasLength extends Matcher {
  final int expectedLength;
  HasLength(this.expectedLength);
  
  @override
  bool matches(item, Map matchState) {
    return (item as List).length == expectedLength;
  }
  
  @override
  Description describe(Description description) {
    return description.add('has length $expectedLength');
  }
}

// Usage
test('list has custom length', () {
  final list = [1, 2, 3];
  expect(list, HasLength(3));
});
```

## 예외 테스트

```dart
class Calculator {
  int divide(int a, int b) {
    if (b == 0) throw ArgumentError('Cannot divide by zero');
    return a ~/ b;
  }
}

// Test
test('divide throws when dividing by zero', () {
  final calculator = Calculator();
  expect(
    () => calculator.divide(10, 0),
    throwsArgumentError,
  );
});

test('divide throws with specific message', () {
  final calculator = Calculator();
  expect(
    () => calculator.divide(10, 0),
    throwsA(isA<ArgumentError>()
      .having((e) => e.message, 'message', contains('zero'))),
  );
});
```

## 모킹(Mocking)

### Mockito 사용

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks with: flutter pub run build_runner build

class MockApiClient extends Mock implements ApiClient {}

@GenerateMocks([ApiClient])
void main() {
  group('UserService', () {
    late MockApiClient mockApiClient;
    late UserService userService;
    
    setUp(() {
      mockApiClient = MockApiClient();
      userService = UserService(mockApiClient);
    });
    
    test('fetches user data', () async {
      when(mockApiClient.getUser('123'))
        .thenAnswer((_) async => User(id: '123', name: 'John'));
      
      final user = await userService.getUser('123');
      
      expect(user.name, 'John');
      verify(mockApiClient.getUser('123')).called(1);
    });
  });
}
```

### 수동 모킹

```dart
class MockStorage implements Storage {
  String? savedData;
  
  @override
  void save(String data) {
    savedData = data;
  }
  
  @override
  String? load() => savedData;
}

// Test
test('saves and loads data', () {
  final mockStorage = MockStorage();
  final service = DataService(mockStorage);
  
  service.saveData('test');
  expect(mockStorage.savedData, 'test');
  
  final loaded = service.loadData();
  expect(loaded, 'test');
});
```

## 가상 클럭(Fake Clock)을 활용한 테스트

```dart
import 'package:clock/clock.dart';

test('time-based operations', () {
  withClock(Clock(() => DateTime(2024, 1, 1)), () {
    final timestamp = DateTime.now();
    expect(timestamp.year, 2024);
  });
});
```

## 테스트 구성

### 파일 구조

```
lib/
  counter.dart
test/
  counter/
    counter_test.dart
    counter_value_test.dart
    counter_operations_test.dart
```

### 네이밍 컨벤션

- 테스트 파일: `*_test.dart`
- 테스트 그룹: 관련 기능별로 묶기
- 테스트 이름: 무엇을, 왜 테스트하는지 명확하게 기술

```dart
// Good
test('value increments when increment is called', () {});

// Avoid
test('increment', () {});
```

## 권장 사항

1. **Arrange-Act-Assert** — 명확한 섹션으로 테스트 구조화
2. **테스트당 단일 검증** — 가능한 한 테스트를 하나의 관심사에 집중
3. **서술적인 이름** — 무엇을, 왜 테스트하는지 설명 (단순히 무엇인지만 나열하지 말 것)
4. **테스트 간 독립성 유지** — 각 테스트는 다른 테스트에 의존하지 않아야 함
5. **setUp/tearDown 활용** — 중복 코드 제거
6. **엣지 케이스 테스트** — 경계값, null, 에러 상황 검증
7. **테스트를 빠르게 유지** — 유닛 테스트에서는 느린 작업 지양
8. **외부 의존성 모킹** — 테스트가 결정론적으로 동작하도록 보장

## 흔한 실수

### 구현 세부사항 테스트

```dart
// Bad - tests implementation
test('counter calls _update', () {
  verify(counter._update()).called(1);
});

// Good - tests behavior
test('counter value increases after increment', () {
  expect(counter.value, 1);
});
```

### 깨지기 쉬운 테스트

```dart
// Bad - depends on exact timing
test('completes within 100ms', () async {
  final stopwatch = Stopwatch()..start();
  await operation();
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});

// Good - tests completion
test('completes successfully', () async {
  await operation();
  // operation completed without error
});
```

## 테스트 실행

```bash
# Run all tests
flutter test

# Run specific file
flutter test test/counter/counter_test.dart

# Run with coverage
flutter test --coverage

# Run verbose
flutter test --verbose

# Run specific test
flutter test --name "value increments"
```
