---
name: domain-layer
description: 도메인 레이어 가이드 — 프레임워크 비종속 모델, `Result<T>`/`ServiceError` 에러 처리, UseCase(선택적) 패턴. 트리거 구문 - "/domain-layer", "domain layer", "usecase", "Result 패턴", "도메인 모델"
---

# Domain Layer Skill

`lib/domain` 레이어를 작성하거나 검토할 때 적용하는 가이드입니다. 프레임워크에 종속되지 않는 도메인 모델, `Result<T>` 기반 에러 처리, 그리고 **선택적인** UseCase 패턴을 다룹니다.

## 사용 시점

- `lib/domain` 아래에 모델/repository 인터페이스/UseCase 를 새로 만들 때
- 도메인 경계에서 에러 처리(`Result<T>` / `ServiceError`)를 설계할 때
- UseCase 를 도입할지 말지 판단할 때
- `NotFound` 같은 도메인 상태를 화면별로 어떻게 해석할지 결정할 때

## 1. 도메인 레이어 기본 (`lib/domain`)

### MUST
- 도메인 모델과 유스케이스는 프레임워크에 종속되지 않게 유지한다 (Flutter import 금지).
- 비즈니스 규칙은 명확한 인터페이스/유스케이스로 표현하고, 모델은 순수 데이터 + 도메인 헬퍼(`copyWith` 등)로 유지한다.

### MUST NOT
- 도메인 코드에서 Flutter UI 패키지를 import 하지 않는다.
- `BuildContext`, `Navigator`, 그 외 어떤 위젯 API에도 의존하지 않는다.

## 2. Result & 에러 처리 패턴

### MUST
- 도메인 대면 연산은 `Result<T>`로 감싼다: 데이터는 `Succeed`, 실패는 `Failed(Failure)`, 부재는 `NotFound`.
- 호출을 보호하기 위해 (data 레이어에서) `BaseRepository.execute`를 사용하고, Socket/Timeout/Postgrest/알 수 없는 에러를 기능별 fallback이 적용된 `Failure`로 변환한다.
- `execute` 블록은 **도메인 모델 값(`T`) 또는 `null`을 반환하거나 실패 시 `throw` 한다.** 블록 안에서 `Result.succeed`/`Result.failed`/`Result.notFound` 인스턴스를 직접 만들지 않는다 — 만든다는 건 해석이 들어간 것이고, 그 해석은 UseCase 소관이다 (§3).
- 도메인 repository 인터페이스는 `Future<Result<...>>`를 반환하게 유지하고, data 구현체는 감싸기 전에 DTO를 도메인 모델로 변환한다.
- 도메인 모델은 프레임워크에 종속되지 않게 유지하며, 데이터와 `copyWith` 같은 헬퍼로만 제한한다.

### MUST NOT
- 도메인 경계 너머로 DTO/맨 future를 반환하거나 저수준 예외를 던지지 말고, 언제나 `Result<T>`를 반환한다.
- 도메인 모델이나 repository 인터페이스에 Supabase/DB/HTTP/플랫폼 타입을 붙이지 않는다.
- 폐기된 `Result.error(String)`을 다시 들이지 않는다.
- **`domain`에서 try-catch 를 사용하지 않는다** (단 `BaseRepository` = `repository_base.dart` 는 예외 — 예외→`Failure` 변환을 전담). UseCase·도메인 모델·repository 인터페이스 어디에도 try-catch 를 두지 않는다.

## 3. UseCase 패턴 (선택)

### 개요
- `NotFound`는 기술적 에러가 아니라 **도메인 상태**다.
- 같은 Repository 결과라도 **화면(유스케이스)에 따라 의미가 달라질 수 있다**.
- Repository는 "데이터를 못 찾았다"는 사실만 알릴 뿐이고, **의미 해석은 UseCase가 한다**.

### UseCase 는 필수가 아니라 선택이다

- Repository 를 우선적으로 구현한다. ViewModel/StateHolder 는 기본적으로 Repository 를 직접 주입받아 호출해도 된다.
- **별도의 Result 해석(같은 Repository 결과를 화면별로 다르게 의미 해석)이 필요한 경우에만** UseCase 를 정의한다.
- UseCase 를 만들 때는 **항상 그 필요성을 먼저 따져본다.** 단순 list 조회나 단순 mutation 에는 UseCase 를 만들지 않는다.

### MUST
- UseCase 클래스는 **도메인 단위로 묶는다**: `{Domain}UseCase` (예: `OrderUseCase` 에 `createOrder`/`updateOrder` 메서드). 동작별로 클래스를 쪼개지 않는다.
- UseCase 파일은 `lib/domain/{feature}/usecase/usecase_{feature}.dart` 에 둔다 (도메인 단위 명명).
- UseCase DI 는 `lib/domain/di/module_usecase.dart` 에서 관리한다.
- UseCase 는 Repository 를 주입받아 호출하고, 화면별 의미에 맞게 `Result` 를 해석한 뒤 **다시 `Result<T>` 로 반환한다.** (`NotFound`·특정 에러코드 → 화면 의미의 `Failed(Failure)`, 그 외 `Succeed`/`Failed` 는 passthrough)
- UseCase 가 Repository 를 주입받는다면, 같은 도메인의 ViewModel/StateHolder 는 그 Repository 를 중복 주입받지 않고 UseCase 만 주입받는다. dismiss·delete 같은 단순 mutation 도 같은 도메인의 UseCase 메서드로 노출한다.

### MUST NOT
- Repository 는 `NotFound`의 비즈니스 의미를 판단하지 않는다.
- ViewModel/View 는 `NotFound`가 에러인지 직접 판단하지 않는다 (UseCase 가 이미 해석한 결과를 사용한다).
- UseCase 는 Flutter UI 패키지를 import 하지 않는다.
- UseCase 는 `BuildContext`, `Navigator` 같은 View 레이어 의존성을 사용하지 않는다.
- UseCase·도메인 모델·repository 인터페이스에 **try-catch 를 사용하지 않는다** (예외→`Failure` 변환은 `BaseRepository.execute` 전담).

### Result 해석 패턴

Repository 는 `Result<T>` (raw 사실) 를 올리고, UseCase 가 화면 의미로 해석한 뒤 **다시 `Result<T>` 로 반환**한다. `NotFound`·특정 에러코드를 화면 의미의 `Failed` 로 매핑하고, 그 외는 passthrough.

```dart
// Repository: 사실만 반환 (해석 없음)
Future<Result<OrderModel>> createOrder(...);

// UseCase: Result 를 해석해 다시 Result 로 반환
Future<Result<OrderModel>> placeOrder(...) async {
  final result = await _repository.createOrder(...);
  return _interpretResult(result, FeatureFailureType.orderCreateNotFound);
}

Result<OrderModel> _interpretResult(
    Result<OrderModel> result, FeatureFailureType notFoundFallback) {
  return switch (result) {
    Failed(:final failure)
        when failure is ServerFailure &&
            failure.code == ServerErrorCode.duplicateKey =>
      Result.failed(const FeatureFailure(FeatureFailureType.orderDuplicated)),
    NotFound() => Result.failed(FeatureFailure(notFoundFallback)),
    Succeed() => result,
    Failed() => result,
  };
}
```

같은 Repository 결과를 화면마다 다르게 해석할 수 있는 지점이 UseCase 가 정당화되는 곳이다. 해석이 갈리지 않으면 UseCase 없이 Repository 의 `Result` 를 직접 쓴다. repository·usecase 가 같은 `Result` 타입이라 소비 측은 주입 대상과 무관하게 동일하게 다룬다.

### 데이터 흐름
```
API / DAO
  ↓
Repository (네트워크 실패 vs 정상 응답 구분, 해석 없이 Result<T> 반환)
  ↓
UseCase (Result 해석 → Result<T> 재반환)   ← 해석이 필요할 때만
  ↓
StateHolder / ViewModel (Result 를 헬퍼·case/is 로 소비)
  ↓
View (렌더링)
```

UseCase 가 없는 경우 ViewModel/StateHolder 가 Repository 의 `Result` 를 직접 소비한다 (예: `NoticeViewModel + NoticeRepository`).

## UseCase 도입 판단 체크리스트

UseCase 를 만들기 전에 다음을 확인한다:

- [ ] 같은 Repository 결과를 화면마다 **다르게** 의미 해석하는가 → Yes 면 UseCase 정당
- [ ] 단순 list 조회 / 단순 mutation 인가 → Yes 면 UseCase 만들지 않음
- [ ] 화면별 비즈니스 규칙 없이 Repository 결과를 그대로 쓰는가 → Yes 면 Repository 직접 주입
- [ ] UseCase 를 도입한다면 같은 도메인의 동작들을 `{Domain}UseCase` 단일 클래스 메서드로 묶었는가
- [ ] UseCase 가 Repository 를 주입받는다면, 같은 도메인 ViewModel/StateHolder 가 그 Repository 를 중복 주입받고 있지 않은가

## 참조 파일

- [Data Layer 가이드](../data-layer/SKILL.md)
- [View Layer 가이드](../view-layer/SKILL.md)
- [Convention Skill — §6 UseCase 패턴](../convention/SKILL.md)
