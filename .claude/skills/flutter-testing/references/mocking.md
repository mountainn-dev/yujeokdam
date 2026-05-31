# 목(Mock) 가이드

## 개요

목(mocking)은 실제 의존성을 테스트 더블로 대체하여 코드를 격리하고 테스트를 결정론적으로 만듭니다. 이 가이드는 Flutter 테스트에서 사용하는 목킹 전략을 다룹니다.

## 목을 사용해야 하는 경우

- 외부 서비스(API, 데이터베이스)에 의존하는 코드 테스트
- 단위 테스트를 위한 컴포넌트 격리
- 에러 조건 및 엣지 케이스 시뮬레이션
- 테스트를 더 빠르고 안정적으로 만들기
- 플러그인을 사용하는 코드 테스트

## Mockito 사용

### 설정

`pubspec.yaml`에 추가:

```yaml
dev_dependencies:
  build_runner: ^2.10.4
  mockito: ^5.6.1
```

### 목 생성

어노테이션으로 목 클래스 생성:

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ApiClient, UserRepository])
void main() {}
```

목 생성 실행:

```bash
flutter pub run build_runner build
```

### 기본 목킹

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late MyService myService;
  
  setUp(() {
    mockApiService = MockApiService();
    myService = MyService(mockApiService);
  });
  
  test('calls API and returns data', () async {
    // Arrange
    when(mockApiService.fetchData())
      .thenAnswer((_) async => {'data': 'value'});
    
    // Act
    final result = await myService.getData();
    
    // Assert
    expect(result['data'], 'value');
    verify(mockApiService.fetchData()).called(1);
  });
}
```

## 다양한 타입의 목킹

### 클래스 목킹

```dart
class DataService {
  Future<String> fetchData() async => 'real data';
}

// Test
test('mocks class method', () async {
  final mockService = MockDataService();
  
  when(mockService.fetchData())
    .thenAnswer((_) async => 'mocked data');
  
  final result = await mockService.fetchData();
  expect(result, 'mocked data');
});
```

### 인터페이스 목킹

```dart
abstract class Storage {
  void save(String key, String value);
  String? load(String key);
}

class MockStorage extends Mock implements Storage {}

// Test
test('mocks interface methods', () {
  final mockStorage = MockStorage();
  
  mockStorage.save('key', 'value');
  when(mockStorage.load('key')).thenReturn('value');
  
  expect(mockStorage.load('key'), 'value');
  verify(mockStorage.save('key', 'value')).called(1);
});
```

### 스트림 목킹

```dart
class StreamService {
  Stream<int> get counterStream => StreamController<int>().stream;
}

// Test
test('mocks stream', () async {
  final mockService = MockStreamService();
  
  final controller = StreamController<int>();
  when(mockService.counterStream).thenAnswer((_) => controller.stream);
  
  expectLater(
    mockService.counterStream,
    emitsInOrder([1, 2, 3]),
  );
  
  controller.add(1);
  controller.add(2);
  controller.add(3);
  await controller.close();
});
```

## Mockito 기능

### 값 반환

```dart
when(mockService.getData()).thenReturn('value');

when(mockService.getUser(id)).thenReturn(User(id: id, name: 'Test'));

when(mockService.getList()).thenReturn([1, 2, 3]);
```

### 에러 던지기

```dart
when(mockService.getData())
  .thenThrow(Exception('Network error'));

when(mockService.saveData(data))
  .thenThrow(FormatException('Invalid data'));
```

### 비동기 응답

```dart
when(mockService.fetchData())
  .thenAnswer((_) async => 'async data');

when(mockService.loadUser(id))
  .thenAnswer((_) async => Future.delayed(
    const Duration(milliseconds: 100),
    () => User(id: id),
  ));
```

### 순차 반환

```dart
when(mockService.getData())
  .thenReturn('first')
  .thenReturn('second')
  .thenThrow(Exception('error'));

// First call returns 'first'
expect(await mockService.getData(), 'first');

// Second call returns 'second'
expect(await mockService.getData(), 'second');

// Third call throws
await expectLater(mockService.getData(), throwsException);
```

### 조건부 반환

```dart
when(mockService.getUser(argThat(isA<String>() && contains('@')))
  .thenReturn(User(email: 'test@example.com'));

when(mockService.getUser(argThat(predicate((arg) => arg.length > 5)))
  .thenReturn(User(name: 'Long Name'));

// Matches email format
expect(mockService.getUser('test@example.com').email, 'test@example.com');

// Matches length > 5
expect(mockService.getUser('Long Name').name, 'Long Name');
```

### 인자 캡처

```dart
final captured = captureNamed(mockService, 'save');

mockService.save('key1', 'value1');
mockService.save('key2', 'value2');

verify(mockService.save('key1', 'value1')).called(1);
expect(captured[0].positionalArguments[0], 'key1');
expect(captured[1].positionalArguments[1], 'value2');
```

## 검증

### 호출 검증

```dart
mockService.getData();

verify(mockService.getData()).called(1);
verify(mockService.getData()).called(greaterThan(0));
verifyNever(mockService.otherMethod());
```

### 순서 검증

```dart
mockService.first();
mockService.second();
mockService.third();

verifyInOrder([
  verify(mockService.first()).called(1),
  verify(mockService.second()).called(1),
  verify(mockService.third()).called(1),
]);
```

### 특정 인자 검증

```dart
mockService.save('key', 'value');

verify(mockService.save('key', 'value')).called(1);
verify(mockService.save(argThat(isA<String>()), any)).called(1);
```

### 추가 인터랙션 없음 검증

```dart
mockService.getData();
mockService.getData();

verifyNoMoreInteractions(mockService);

verifyNoInteractions(otherMockService);
```

## 플랫폼 채널 목킹

### 기본 플랫폼 채널 목

```dart
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.app/channel'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getBatteryLevel':
            return 85;
          case 'openUrl':
            return true;
          default:
            throw MissingPluginException();
        }
      },
    );
  });
  
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.app/channel'),
      null,
    );
  });
  
  test('gets battery level', () async {
    final platform = MethodChannel('com.example.app/channel');
    final result = await platform.invokeMethod('getBatteryLevel');
    expect(result, 85);
  });
}
```

### 인자가 있는 플랫폼 채널

```dart
setUp(() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('com.example.app/storage'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'save') {
        final args = methodCall.arguments as Map;
        storage[args['key']] = args['value'];
        return true;
      } else if (methodCall.method == 'load') {
        final args = methodCall.arguments as Map;
        return storage[args['key']];
      }
      return null;
    },
  );
});

test('saves and loads from platform storage', () async {
  final platform = MethodChannel('com.example.app/storage');
  
  await platform.invokeMethod('save', {'key': 'test', 'value': 'data'});
  final result = await platform.invokeMethod('load', {'key': 'test'});
  
  expect(result, 'data');
});
```

## 리포지토리 목킹

### 데이터 리포지토리

```dart
class UserRepository {
  final ApiClient apiClient;
  
  UserRepository(this.apiClient);
  
  Future<User> getUser(String id) async {
    final data = await apiClient.get('/users/$id');
    return User.fromJson(data);
  }
}

// Test
@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late UserRepository userRepository;
  
  setUp(() {
    mockApiClient = MockApiClient();
    userRepository = UserRepository(mockApiClient);
  });
  
  test('fetches and parses user', () async {
    when(mockApiClient.get('/users/123'))
      .thenAnswer((_) async => {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
      });
    
    final user = await userRepository.getUser('123');
    
    expect(user.id, '123');
    expect(user.name, 'John Doe');
    verify(mockApiClient.get('/users/123')).called(1);
  });
}
```

## 상태 관리 목킹

### BLoC 목

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<IncrementEvent>((event, emit) => emit(CounterIncremented()));
  }
}

// Test
test('emits states on increment', () {
  final bloc = CounterBloc();
  
  expectLater(bloc, emitsInOrder([
    CounterInitial(),
    CounterIncremented(),
  ]));
  
  bloc.add(IncrementEvent());
});
```

### Provider 목

```dart
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  
  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }
}

// Test
test('notifies listeners on login', () {
  final provider = AuthProvider();
  bool notified = false;
  
  provider.addListener(() {
    notified = true;
  });
  
  provider.login();
  
  expect(notified, true);
  expect(provider.isLoggedIn, true);
});
```

## 수동 목

### 단순 수동 목

```dart
class ApiService {
  Future<String> fetchData() async => 'real data';
}

class MockApiService implements ApiService {
  String? _mockedResponse;
  
  void setMockResponse(String response) {
    _mockedResponse = response;
  }
  
  @override
  Future<String> fetchData() async => _mockedResponse ?? 'default mock';
}

// Test
test('uses manual mock', () async {
  final mockService = MockApiService();
  mockService.setMockResponse('test data');
  
  final result = await mockService.fetchData();
  expect(result, 'test data');
});
```

### 상태 기반 목

```dart
class StatefulMockService implements ApiService {
  final List<String> responses = [];
  int _callCount = 0;
  
  @override
  Future<String> fetchData() async {
    if (_callCount < responses.length) {
      return responses[_callCount++];
    }
    throw Exception('No more responses');
  }
  
  void addResponse(String response) {
    responses.add(response);
  }
}

// Test
test('returns sequential responses', () async {
  final mock = StatefulMockService();
  mock.addResponse('first');
  mock.addResponse('second');
  
  expect(await mock.fetchData(), 'first');
  expect(await mock.fetchData(), 'second');
  
  expect(() => mock.fetchData(), throwsException);
});
```

## 모범 사례

1. **경계에서 목킹** — 내부 로직이 아닌 외부 의존성을 목킹
2. **과도한 목킹 지양** — 테스트에 필요한 것만 목킹
3. **인터랙션 검증** — 목이 올바르게 호출되는지 확인
4. **구체적인 매처 사용** — 가능하면 `any` 사용 자제
5. **명확한 기대값** — 테스트 의도를 명확하게 표현
6. **목 초기화** — `setUp`/`tearDown`으로 정리
7. **실제 동작 테스트** — 구현 세부사항이 아닌 예상 결과 검증
8. **목을 단순하게 유지** — 복잡한 목은 설계 문제를 시사

## 공통 패턴

### 목 체이닝

```dart
when(mockService.first())
  .thenReturn(mockSecondService);
when(mockSecondService.getData())
  .thenReturn('result');

final result = mockService.first().getData();
expect(result, 'result');
```

### 목 리포지토리

```dart
class MockRepository {
  final Map<String, dynamic> _data = {};
  
  T get<T>(String key) => _data[key] as T;
  void set<T>(String key, T value) => _data[key] = value;
}

// Test
test('uses mock repository', () {
  final repo = MockRepository();
  repo.set('name', 'John');
  
  expect(repo.get<String>('name'), 'John');
});
```

### 목 팩토리

```dart
class ServiceFactory {
  static ApiService create() => RealApiService();
}

class MockServiceFactory {
  ApiService? mockService;
  
  ApiService create() => mockService ?? RealApiService();
}

// Test
test('uses factory mock', () {
  final factory = MockServiceFactory();
  factory.mockService = MockApiService();
  
  when(factory.mockService!.getData()).thenReturn('mocked');
  
  final service = factory.create();
  expect(service.getData(), 'mocked');
});
```
