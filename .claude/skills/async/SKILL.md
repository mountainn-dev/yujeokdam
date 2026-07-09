---
name: async
description: Dart/Flutter 비동기 프로그래밍 가이드 — Future, Stream, Isolate 패턴 및 모범 사례. 트리거 문구 - "/async", "async guide"
---

# Dart 비동기 프로그래밍 가이드

Dart/Flutter 프로젝트에서 async/await, Future, Stream, Isolate 사용에 대한 참고 문서.

## async/await

### MUST
- 모든 I/O 작업(네트워크, DB, 파일)에는 `async/await`를 사용한다.
- 반환 타입은 `Future<T>`로 명시한다.
- `.then()` / `.catchError()` 체인 대신 `async/await`를 선호한다.

### MUST NOT
- `.then()` / `.catchError()` 콜백 체인을 사용하지 않는다. `async/await`를 사용할 것.
- 모든 `await` 호출 지점마다 `try-catch`를 추가하지 않는다. 에러는 **시스템 경계**(Repository, API 최상위)에서만 처리하고, 내부에서는 `Result<T>` 패턴으로 전파한다.

```dart
// Anti-pattern: callback chain
Future<void> loadData() {
  return fetchUser()
    .then((user) => fetchProfile(user.id))
    .catchError((e) => print(e));
}

// Best practice: async/await
Future<void> loadData() async {
  final user = await fetchUser();
  final profile = await fetchProfile(user.id);
}
```

## 에러 처리 전략

### MUST
- `try-catch`는 시스템 경계에만 위치시킨다. 즉, 외부 I/O가 애플리케이션 계층과 만나는 곳(예: `BaseRepository.execute`, 최상위 API 호출, 플랫폼 채널)에서만 사용한다.
- 포착한 예외는 경계에서 도메인 친화적 타입(`Result<T>`, `ServiceError`)으로 변환한다.
- 내부 계층에서는 추가적인 try-catch 없이 `Result<T>`를 그대로 흘려보낸다.

### MUST NOT
- 모든 `await`를 `try-catch`로 감싸지 않는다. 이는 중복 에러 처리를 야기하고 실제 에러 경계를 불분명하게 만든다.
- 예외를 단순히 다시 던지거나 로깅만 하기 위해 catch하지 않는다. 의미 있는 처리 또는 변환이 가능할 때만 catch한다.

```dart
// Anti-pattern: try-catch at every layer
Future<void> loadUser() async {
  try {
    final user = await fetchUser();
    try {
      final profile = await fetchProfile(user.id);
    } catch (e) {
      handleProfileError(e);
    }
  } catch (e) {
    handleUserError(e);
  }
}

// Best practice: single boundary handles errors
Future<Result<UserProfile>> getUser() => execute(
  () async {
    final user = await _api.fetchUser();
    final profile = await _api.fetchProfile(user.id);
    return profile.toModel();
  },
  FeatureFailureType.getUser,
);
```

## 순차 실행 vs 동시 실행

### 순차 실행 — 이전 결과에 의존하는 호출

```dart
final user = await fetchUser(id);
final profile = await fetchProfile(user.profileId);
```

### 동시 실행 — 독립적인 호출

```dart
final results = await Future.wait([
  fetchUserData(id),
  fetchUserPreferences(id),
  fetchUserPermissions(id),
]);
```

### MUST
- 독립적인 작업에는 `Future.wait`를 사용하여 전체 대기 시간을 줄인다.
- `Future.wait`는 빠른 실패(fail fast) 방식임을 인지한다. 하나의 future가 throw하면 전체 호출이 실패한다.

### MUST NOT
- 서로의 결과에 의존하는 future에는 `Future.wait`를 사용하지 않는다.
- 독립적인 future를 순차적으로 await하지 않는다. 시간 낭비다.

## Stream

### 소비(Consuming)

- 순차 처리에는 `.listen()` / `.forEach()` 대신 `await for`를 선호한다.

```dart
Future<void> processEvents(Stream<Event> stream) async {
  await for (final event in stream) {
    handleEvent(event);
  }
}
```

### StreamController로 생성

```dart
class DataProvider {
  final _controller = StreamController<Data>.broadcast();

  Stream<Data> get dataStream => _controller.stream;

  void update(Data data) {
    if (!_controller.isClosed) {
      _controller.add(data);
    }
  }

  void dispose() {
    _controller.close();
  }
}
```

### MUST
- 소유 클래스가 dispose될 때 `StreamController`의 `.close()`를 호출한다.
- `.add()`를 호출하기 전에 `_controller.isClosed`를 확인한다.

### MUST NOT
- `StreamController`를 dispose 경로 없이 열어두지 않는다. 메모리 누수를 유발한다.

## Isolate — CPU 집약적 작업

### 판단 기준표

| 시나리오 | 접근 방법 |
|----------|----------|
| I/O 작업 (HTTP, DB, 파일) | `async/await` |
| CPU 작업, 빠름 (< 16ms) | `async/await` |
| CPU 작업, 느림, 일회성 | `compute()` (Flutter) 또는 `Isolate.run()` (Dart) |
| CPU 작업, 지속적인 백그라운드 | `Isolate.spawn()` + `ReceivePort` / `SendPort` |

### 일회성: `compute()`

```dart
import 'package:flutter/foundation.dart';

// Must be top-level or static, must be pure
List<dynamic> parseJson(String json) => jsonDecode(json) as List<dynamic>;

Future<List<dynamic>> processData(String rawJson) async {
  return await compute(parseJson, rawJson);
}
```

### 장수명 Worker Isolate

```dart
class WorkerManager {
  late SendPort _workerSendPort;
  final ReceivePort _mainReceivePort = ReceivePort();
  Isolate? _isolate;

  Future<void> initialize() async {
    _isolate = await Isolate.spawn(_workerEntry, _mainReceivePort.sendPort);
    _mainReceivePort.listen((message) {
      if (message is SendPort) {
        _workerSendPort = message;
      } else {
        print('Received: $message');
      }
    });
  }

  static void _workerEntry(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();
    mainSendPort.send(workerReceivePort.sendPort);
    workerReceivePort.listen((message) {
      mainSendPort.send("Processed: $message");
    });
  }

  void dispose() {
    _mainReceivePort.close();
    _isolate?.kill();
  }
}
```

### MUST
- Flutter에서 일회성 CPU 작업에는 `compute()`를 사용한다. view 코드에서 `Isolate.run`을 직접 사용하지 않는다.
- `compute` 콜백은 최상위 또는 static이어야 하며, 순수 함수(부수 효과 없음)여야 한다.

### MUST NOT
- `compute()`에 클로저나 인스턴스 메서드를 전달하지 않는다.
- 메인 isolate에서 16ms를 초과하는 동기 작업을 실행하지 않는다. UI 끊김을 유발한다.

## Flutter 비동기 UI

### FutureBuilder / StreamBuilder

```dart
FutureBuilder<String>(
  future: _dataFuture, // created in initState, NOT in build
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    return Text('Result: ${snapshot.data}');
  },
)
```

### MUST
- `waiting`, `hasError`, `hasData` 세 가지 상태를 모두 처리한다.
- `Future`는 `initState` 또는 ViewModel에서 생성한다. 필드에 할당한 뒤 `FutureBuilder`에 전달한다.
- 비동기 간격(async gap) 이후 `setState`를 호출하기 전에 `mounted`를 확인한다.

### MUST NOT
- `build()` 내부에서 새로운 `Future`를 생성하지 않는다. 리빌드마다 재실행된다.
- `mounted` 확인 없이 비동기 간격 이후 `BuildContext`를 사용하지 않는다.

## 빠른 참고

```
I/O 작업           → async/await
독립적인 호출      → Future.wait([...])
Stream 소비        → await for
CPU 일회성         → compute() / Isolate.run()
CPU 지속적         → Isolate.spawn() + Port
UI 바인딩          → FutureBuilder / StreamBuilder
에러 경계          → try-catch는 시스템 경계에서만, 내부는 Result<T>
```
