---
name: convention
description: 변경된 코드가 팀 수준의 컨벤션을 준수하는지 검토합니다 — 네이밍, 구조, 레이어링, DI, 상태 관리, 안티패턴, 가독성, 주석, 도메인 결합도. 트리거 구문 - "/convention", "check conventions", "convention review"
---

# Convention Review Skill

변경된 코드를 프로젝트 컨벤션 및 팀 수준의 품질 기준에 따라 검토합니다. 심각도별로 그룹화된 실행 가능한 피드백을 제공합니다.

## 사용 시점

- 커밋하거나 PR을 열기 전
- 새 기능 구현 또는 리팩터링 후
- 새 기여자의 코드를 온보딩할 때
- 사용자가 `/convention`을 호출하거나 "check conventions"를 요청할 때

## 검토 범위

**staged 및 unstaged 변경 사항**(`git diff` + `git diff --cached`)을 분석합니다. 변경 사항이 없으면 사용자가 지정한 파일을 분석합니다.

## 검토 프로토콜

### 1단계: 변경 사항 수집

`git diff HEAD`를 실행하여 수정된 모든 파일을 식별합니다. 변경된 각 파일을 전체적으로 읽어 문맥을 파악합니다.

### 2단계: 체크리스트 적용

아래 체크리스트에 대해 변경된 모든 라인을 평가합니다. 발견된 사항이 없는 항목은 건너뜁니다.

### 3단계: 리포트

심각도 체계를 사용하여 구조화된 리포트를 출력합니다. 파일별, 심각도별로 발견 사항을 그룹화합니다.

## 심각도 수준

| 레벨 | 레이블 | 의미 |
|-------|-------|---------|
| BLOCKING | `[B]` | 프로젝트 규칙의 MUST/MUST NOT을 위반함. 머지 전 반드시 수정해야 함. |
| SUGGESTION | `[S]` | 가독성, 유지보수성, 일관성을 개선함. 강력히 권장. |
| NIT | `[N]` | 사소한 스타일 선호도. 선택적 수정. |

## 체크리스트

### 1. 네이밍 & 파일 배치

- 파일명은 타입 접두사와 함께 `snake_case`를 사용함 (`screen_`, `view_model_`, `dto_`, `mapper_`, `api_`, `dao_`, `repository_impl_`, `usecase_`, `state_holder_`, `store_`).
- 클래스명은 책임 우선, 타입 후치 패턴의 `PascalCase`를 사용함 (예: `HomeScreen`, `ProfileViewModel`).
- 변수와 함수는 `camelCase`를 사용함.
- 새 파일은 올바른 레이어 디렉터리(`lib/data`, `lib/domain`, `lib/view`)에 배치됨.
- 하나의 파일에 관련 없는 책임이 혼재하지 않음.

### 2. 레이어 분리

- `domain` 파일에 Flutter/UI import가 없음.
- `data` 파일에 Flutter/UI import가 없고 매핑 이상의 도메인 로직이 없음.
- `view` 파일이 플랫폼/저수준 프로바이더를 직접 호출하지 않음.
- DTO가 데이터 레이어 위로 누출되지 않음. 도메인 모델은 view 및 domain 레이어에서 사용됨.
- 리포지터리 인터페이스는 `domain`에, 구현체는 `data`에 위치함.

### 3. 의존성 주입

- 모든 새 의존성은 올바른 DI 모듈(`LocalSourceModule`, `RemoteSourceModule`, `RepositoryModule`, `StoreModule`, `StateHolderModule`, `ViewModelFactoryModule`)에 등록됨.
- 스크린에서 repos, APIs, DAOs, ViewModels를 직접 생성하지 않음.
- `GetIt.I.get<T>()`를 사용하여 해결함. 추가적인 DI 컨테이너 없음.
- 싱글톤 vs 팩토리가 올바르게 사용됨 (공유 서비스 = 싱글톤, 스크린 범위 = 팩토리).

### 4. 상태 관리 패턴

- `StateHolder`는 오직 상태를 보유하고 `notifyListeners()`를 호출함. UI 이벤트 없음, `BaseViewModel` 확장 없음.
- ViewModel은 스크린 범위의 일시적 상태를 소유하고 UI 이벤트(스낵바, 네비게이션, 다이얼로그)를 방출함.
- ViewModel은 `StateHolder` 데이터에 대한 패스스루 getter를 노출하지 않음.
- View는 데이터 바인딩을 위해 `StateHolder`에 직접 바인딩하고, UI 이벤트를 위해 ViewModel `eventStream`을 구독함.
- 스크린 간 공유 데이터는 공유 ViewModel이 아닌 `Store`/`StateHolder`를 사용함.

### 5. Result · Either & 에러 처리

#### 계층별 반환 타입
- Repository(데이터 facing 작업)는 `Result<T>`(`Succeed` / `Failed(Failure)` / `NotFound`)를 반환함. `BaseRepository.execute` 가 저수준 예외를 `Failure` 로 변환해 감쌈.
- **Repository 는 결과를 해석해 어떤 `Result` 를 골라 반환하지 않음.** API/DAO 가 준 사실만 그대로 `Result` 로 올림 (비즈니스 의미 부여 금지).
- **`execute` 블록 안에서 `Result.succeed`/`Result.failed`/`Result.notFound` 인스턴스를 직접 만들지 않음.** 블록은 도메인 모델 값(`T`)을 반환하거나(값이 없으면 `null` → `execute` 가 `NotFound` 로), 실패면 `throw` 함(→ `execute` 가 `Failed` 로 변환). 블록 안에서 `Result` 를 직접 만든다는 것은 **해석이 들어갔다는 신호**이고, 그 해석은 `execute` 를 우회하는 것이므로 UseCase 로 옮김 (§6). 직접 만들 거면 `execute` 를 쓸 이유가 없음.
- **결과가 단순 성공/실패로 갈리지 않아 별도 해석이 필요하면(예: `NotFound`·특정 에러코드를 화면 의미로 바꿔야 하면) 반드시 UseCase 를 만든다.** UseCase 가 Repository 의 `Result` 를 해석해 **`Either<Failure, T>`(fpdart) 로 반환**함 (§6).
- 해석이 필요 없는 단순 조회/mutation 은 UseCase 없이 ViewModel/StateHolder 가 Repository 의 `Result` 를 직접 소비함. UseCase 를 만들었으면 ViewModel/View 는 그 `Either` 를 `.fold(onLeft, onRight)` 로 소비함.
- 도메인 경계를 넘는 raw `Future`·thrown 예외·DTO 는 없음.

#### try-catch 사용 제한
- **`domain`(단 `BaseRepository` = `repository_base.dart` 는 예외)·`view` 에서는 try-catch 를 절대 사용하지 않음.** 두 계층은 예외를 잡지 않고 `Result`/`Either` 만 소비함. 플랫폼/하드웨어 호출(카메라·ML Kit 등)도 `data` source 로 내려 `Result` 로 변환받고, ViewModel 은 그 결과만 소비함.
- try-catch 의 기본 위치는 **`BaseRepository.execute` 하나**다. 모든 저수준 예외는 여기서 `Failure` 로 변환됨.
- 유일한 추가 허용 지점은 `data` 레이어의 **mapper** 로, 파싱 등으로 불가피한 경우다. 이때도 **사용자에게 확인받은 뒤** 사용함 (무단 추가 금지).

### 6. UseCase 패턴

#### 언제 만드는가
- **Repository 의 `Result` 를 단순 성공/실패로 소비할 수 없고 별도 해석이 필요할 때만** 만든다 (예: `NotFound` 를 화면 의미로 변환, 특정 에러코드를 구분, 같은 결과를 화면별로 다르게 해석). 단순 list 조회·단순 mutation 에는 만들지 않음.
- Repository 가 `execute` 안에서 `Result` 를 직접 만들거나 결과를 해석하려는 충동이 보이면(§5), 그 해석은 UseCase 로 옮긴다.

#### 반환 타입 — `Either<Failure, T>` (fpdart)
- UseCase 는 Repository 의 `Result<T>` 를 받아 해석한 뒤 **`Either<Failure, T>`(fpdart) 를 반환**함. `Succeed` → `Right(data)`, `Failed` → `Left(failure)`(에러코드 등 구분 가능), `NotFound` → `Left(FeatureFailure(...))` 로 매핑.
- ViewModel/View 는 이 `Either` 를 `.fold(onLeft, onRight)` 로 소비함. (해석이 불필요해 UseCase 가 없는 경우만 ViewModel/StateHolder 가 Repository 의 `Result` 를 직접 소비.)
- 표준 형태:
  ```dart
  Future<Either<Failure, OrderModel>> placeOrder(...) async {
    final result = await _repository.createOrder(...);   // Result<T>
    return _interpretResult(result, FeatureFailureType.orderCreateNotFound);
  }

  Either<Failure, OrderModel> _interpretResult(
      Result<OrderModel> result, FeatureFailureType notFoundFallback) {
    return switch (result) {
      Succeed(:final data) => Right(data),
      Failed(:final failure)
          when failure is ServerFailure &&
              failure.code == ServerErrorCode.duplicateKey =>
        Left(const FeatureFailure(FeatureFailureType.orderDuplicated)),
      Failed(:final failure) => Left(failure),
      NotFound() => Left(FeatureFailure(notFoundFallback)),
    };
  }
  ```

#### 구조·배치
- UseCase 파일은 `lib/domain/{feature}/usecase/usecase_{feature}.dart`에 위치함 (도메인 단위 명명).
- 클래스명은 `{Domain}UseCase` 형식. 한 도메인의 여러 동작은 **단일 클래스의 메서드로 묶음**. 동작별로 클래스를 쪼개지 않음 (예: `OrderUseCase.placeOrder` / `updateOrder`, `NoticeUseCase.getVisible` / `dismiss`).
- `lib/domain/di/module_usecase.dart`에 등록됨.
- **UseCase 가 Repository 를 주입받고 있다면, ViewModel/StateHolder 는 같은 Repository 를 중복 주입받지 않음**. UseCase 만 주입받아 호출함. dismiss·delete 같은 단순 mutation 도 같은 도메인의 UseCase 메서드로 노출. UseCase 가 없는 도메인은 ViewModel/StateHolder 가 Repository 를 직접 주입받아도 됨 (예: `NoticeViewModel + NoticeRepository`).
- UseCase 는 Flutter UI 패키지·`BuildContext`·`Navigator` 를 import 하지 않음. try-catch 도 쓰지 않음(§5).

### 7. 함수 & 메서드 설계

- 기본적으로 private 인스턴스 메서드를 사용함. 명시적 승인 없이 `static` 또는 최상위 함수 사용 불가 (예외: 메시지/예외 상수).
- 함수는 작고, 단일 책임이며, 일관된 추상화 수준을 유지함.
- 중첩된 `if`/`else`를 최소화함. 이른 반환과 가드 절을 선호함.
- 단일 표현식 함수는 `=>`를 사용할 수 있음.

### 8. Dart 스타일

- 후행 쉼표: 단일 파라미터 = 후행 쉼표 없음; 두 개 이상 = 쉼표와 함께 여러 줄.
- 재사용 가능한 불변 리터럴/위젯에 `const` 사용.
- 널 안전: 널 가능성 최소화. `late` 과다 사용 금지.
- 미사용 import 제거. 적절한 경우 `show`/`hide`를 사용하여 노출 범위 제한.
- 사용자가 명시적으로 요청하지 않는 한 새 주석을 추가하지 않음. 기존 주석은 그대로 유지.
- 한 줄짜리 `if` 도 중괄호를 쓰고, `else`-`if` 체인은 단순화하며, `switch` 는 가능하면 모든 경우를 빠짐없이 다룸.
- `typedef` 는 `PascalCase`, 상수는 `lowerCamelCase` 를 선호함.
- named optional 파라미터를 선호하고, 필수는 `required`, 기본값은 상수로 둠.
- 값 객체는 `==` 와 `hashCode` 를 함께 구현하고, 컬렉션 비교에는 collection 헬퍼를 사용함.
- `package` 경로와 relative 경로를 일관성 없이 섞지 않음. `export` 로 공개 API 표면을 다듬음.
- 비동기: 필요하면 `unawaited` 를 쓰고, 스트림은 `await for` 로 소비하며, 정리는 `finally` 에서 함.
- 가능하면 `final`/불변을 선호하고, 내부 컬렉션은 `UnmodifiableListView` 같은 방어적 래퍼로 노출함.
- public 표면은 최소로 유지하고, getter/setter 는 가볍게, `extension` 은 이름 충돌을 피하도록 명명함.

### 9. 보안

- 소스 파일에 하드코딩된 API 키, 시크릿, 토큰 없음.
- 사용자 입력은 시스템 경계에서 검증됨.
- raw 쿼리에 SQL 인젝션 벡터 없음.

### 10. 가독성 & 유지보수성

- 일회성 작업에 대한 조기 추상화 없음.
- 코드를 직접 변경할 수 있는 경우 기능 플래그나 하위 호환성 심(shim) 없음.
- 발생할 수 없는 시나리오에 대한 불필요한 에러 처리 없음.
- 성급한 헬퍼/유틸리티보다 세 줄의 유사한 코드가 선호됨.
- 도메인 모델은 의미 있는 동작을 노출함. view는 모델을 많은 원시 필드로 분해하지 않음.

### 11. 코드 명확성 (모호성 감소)

다른 개발자가 작성자에게 묻지 않고 코드를 이해할 수 있는지 평가합니다.

#### 네이밍 의도
- 이름은 무엇인지가 아니라 **왜** 존재하는지를 드러냄. 이름을 설명하기 위해 주석이 필요하다면 이름이 잘못된 것임.
- 모호한 이름 금지: `data`, `result`, `tmp`, `info`, `item`, `value`, `manager`는 불명확한 책임을 나타냄.
- 불리언은 예/아니오 질문으로 읽힘: `isActive`, `hasPermission`, `canEdit` — `flag`, `check`, `status` 금지.
- 동사 일관성: `fetch`/`get`/`retrieve` 중 하나를 선택하여 코드베이스 전체에 일관되게 사용. 같은 작업에 동의어를 혼용하지 않음.
- 메서드명은 내부적으로 **어떻게** 하는지가 아니라 추상화 수준에서 **무엇**을 하는지를 설명함.

#### 명확한 제어 흐름
- `build()`, getter, 생성자 내부에 숨겨진 사이드 이펙트 없음. 사이드 이펙트는 라이프사이클 메서드나 명시적 액션 메서드에 속함.
- 메서드 동작을 암묵적으로 변경하는 불리언 파라미터 지양. 메서드에 두 가지 모드가 있다면 명확한 이름을 가진 두 개의 메서드를 고려함.
- 조건 분기는 자명함. 조건이 정신적 해독을 요구한다면 잘 명명된 불리언 변수나 메서드로 추출함.

#### 일관된 추상화 수준
- 각 메서드는 단일 추상화 수준에서 동작함. 같은 메서드 본문에 고수준 오케스트레이션과 저수준 세부 사항을 혼합하지 않음.
- 인수를 변경 없이 단순히 전달하기만 하는 패스스루 메서드 지양 — 가치 없이 간접 참조만 추가함.

#### 인지 부하 감소
- 변수는 사용 첫 번째 위치 근처에 선언함. 큰 메서드 본문의 최상단에 선언하지 않음.
- 매직 넘버와 매직 스트링 지양. 명명된 상수나 열거형 값을 사용함.
- 관련 로직은 같은 파일 내에 물리적으로 가깝게 유지함. 하나의 동작을 이해하기 위해 멀리 떨어진 위치를 이동해야 한다면 함께 배치함.
- 우변에서 타입이 명확하지 않은 경우 `var`보다 명시적 타입을 선호함.

### 12. 주석 작성 (명시적 요청 시 적용)

**적용 시점**: 사용자가 주석 추가/개선/정리를 명시적으로 요청한 경우에만 적용 (예: "주석 작성", "주석 가독성 개선", "TODO 정리"). 그 외에는 §8 의 "새 주석 추가하지 않고 기존 주석 그대로 유지" 룰이 우선함.

#### 명명과 의미의 일치
- 주석은 식별자(상수/함수/타입) 이름의 단위·범위와 정확히 일치해야 함. 명명이 `xxxPerRep` 인데 주석이 "한 세트 당" 이라고 적혀 있다면 둘 중 하나가 잘못된 것 — 사용처를 확인해 진실에 맞춤.
- 식별자가 잘 명명됐다면 주석은 WHAT 이 아니라 **WHY** 를 적음. "환산한다"는 결정의 근거, 측정 대신 고정값을 쓰는 이유 같은 것.
- 예: `_secondsPerWeightRep = 4` 의 좋은 주석은 "4초"가 아니라 "한 세트의 실제 수행 시간을 측정하지 않고 `reps × 4초` 로 환산한다" — 환산 결정 자체가 WHY.

#### 외부 도구 용어 누출 금지
- Figma 노드명(`Stat Row`, `circle graph`), JIRA 티켓 코드, Notion 페이지명 등 외부 도구의 raw 용어를 코드 주석에 그대로 옮기지 않음.
- 디자인 의도/위치는 **코드 도메인 용어로 풀어서** 적음.
  - 안 좋음: "Figma `Stat Row` 노드 구성과 1:1 대응"
  - 좋음: "분석 화면 상단 2x2 그리드에 표시"

#### Stale comment 검출
- 기존 주석을 손볼 때 먼저 **주석의 주장이 실제 구현과 일치하는지 검증**. 옛 버전 placeholder 값/로직 설명이 그대로 남아 있는 경우가 흔함.
- 주석과 코드가 어긋나면 **코드가 진실**. 주석을 현재 동작에 맞춰 갱신.
- 예: 클래스 docstring 이 "현재 placeholder `(0, ready)` 반환" 이라 적혀 있었으나 실제 구현은 `nextInt(1001)` + level 계산 — 코드 기준으로 갱신.

#### TODO 는 액션 불릿으로
- 줄글 TODO 는 안에 들어 있는 작업 항목이 묻혀 버림. **문단 → 불릿** 으로 분해.
- 파일 경로, 테스트 이름, 매직 넘버(비율·경계값) 같은 **구체적인 핸들은 반드시 보존** — 미래에 작업 범위를 추적할 단서.
- 좋은 형태:
  ```
  // TODO(tag): {조건} 시
  //   - 본문의 placeholder 를 실제 계산으로 교체
  //   - 관련 테스트 ("score 0~1000 범위") 도 함께 재작성
  //   - `screen_x.dart` 의 ratio (0.25/0.65/0.85) 도 맞춤
  ```

#### 자연스러운 한국어 + 용어집 준수
- 길고 꼬인 수식문(예: "X 가 Y 를 결정하는 Z 의 ...") 은 **짧은 직설** 로 풀어 씀. 한 번에 안 읽히면 다시 씀.
- 프로젝트에 용어집이 있으면 그 표준 표기를 따르고, 같은 비즈니스 개념은 한 단어로 통일한다. 영어 용어 음차 표기는 피한다.
- 예:
  - 안 좋음: "최근 추이에서 anchor 가 차지하는 마지막 칸 위치를 결정하는 항목 수"
  - 좋음: "추이 차트가 보여주는 항목 수 (anchor 가 마지막 칸)"

#### Public 과 Private 의 비대칭
- **public typedef/메서드** 의 doc 은 호출자(다른 파일/다른 작성자) 가 이해할 수 있도록 적음. 사용 위치, 입력 가정, 반환 단위.
- **private helper** 는 doc 없이 **self-explanatory naming** 만으로 충분 (예: `_isInRange`, `_records`, `_volumeOfPart`).
- 즉, helper 추출의 부수 효과로 주석이 줄어드는 게 정상 — 의도를 이름으로 흡수했기 때문.

#### 줄여야 할 표현 패턴
- "기존 X 의 관례를 따라" — 단순 fluff, 결정의 근거를 대체하지 못함. 진짜 이유가 있으면 적고 없으면 빼기.
- "임시 placeholder 용 ...", "공식이 미정이므로 임시로 ..." — 한 번 "(placeholder — 공식 미정)" 처럼 한 줄 표시로 충분. 두 번 반복 금지.
- "추후 실제 X 가 확정되면 ..." 같은 미래 예고 — TODO 로 옮기고 docstring 본문에서 제거.

#### 코드로 알 수 있는 메타 설명 금지

주석은 **코드 본문을 한 번 읽으면 즉시 알 수 있는 메타 사실** 을 적지 않는다. 팀원도, AI 도, 코드를 읽으면 자명한 것은 주석으로 옮길 가치가 없다 — 작성·유지보수에 토큰·인지 비용이 발생할 뿐이다.

금지되는 메타 설명 예:
- "이 클래스는 모든 메서드가 `static` 이다 / 인스턴스 상태가 없는 순수 유틸이다"
- "이 메서드는 입력만 받고 결과를 반환한다"
- "이 필드는 List<int> 타입이다"
- "X 와 동일한 패턴이다" (자매 클래스 단순 참조)

이런 사실은 **클래스 선언 / 메서드 시그니처 / 필드 타입을 보면 그 자체로 명확** 하다. 주석에 옮기면:
- 코드 변경 시 주석도 함께 갱신해야 하는 부담 (drift 위험)
- 토큰·문서 비용
- 의미 있는 WHY 가 메타 설명에 묻힘

좋은 주석의 기준 — **"코드만 읽어도 알 수 있나?"** 자문해서 No 인 것만 적음:
- 사용 컨텍스트 ("분석 화면 목표 세트 달성량 카드에서 사용")
- 비즈니스 의미 / 도메인 용어 매핑
- 알고리즘의 미묘한 결정 근거 (환산 비율, 경계값 출처)
- 외부 제약 / 숨은 invariant
- 향후 작업 단서 (TODO + 액션 불릿)

예) 안 좋음:
```dart
/// 월별 주차 계산기.
///
/// 인스턴스 상태가 없는 순수 도메인 유틸이라 모든 메서드를 `static` 으로 제공한다.
/// `SummaryCalculator` 와 동일한 패턴.
class WeekOfMonthCalculator { ... }
```

좋음:
```dart
/// 월별 주차 계산기
///
/// 통계 화면 카드에서 주차 정보를 계산할 때 사용합니다.
class WeekOfMonthCalculator { ... }
```

### 13. 도메인 → 뷰 결합 방지

§2 가 import 차원의 레이어 분리를 다룬다면, §13 은 **값/시그니처/네이밍 차원의 의미적 결합**을 다룬다. 도메인 계층은 뷰의 디자인 결정(표시 항목 수, 순서, 레이아웃, 차트 단위 등)을 몰라야 한다.

#### Acid test

> **"뷰 디자인이 바뀌면 도메인 코드도 바뀌어야 하나?"** → Yes 라면 결합이 새고 있다. No 가 되도록 도메인을 일반화.

예) 차트가 5 → 6 부위로 바뀌었을 때, 디자이너가 부위 순서를 바꾸기로 했을 때, 4주 추이가 6주 추이로 바뀌었을 때 — 도메인 측 코드 수정이 필요하다면 결합이 있는 것.

#### 결합 탐지 신호

도메인 코드에서 다음 패턴이 보이면 의심:

1. **상수 값에 디자인 결정이 박힘**: `static const displayCategories = [food, drink, snack, ...]`, `static const _trendWeekCount = 4`
2. **메서드 이름에 디자인 수치가 박힘**: `categoryFourWeekTotals(...)`, `top3Items(...)`, `weeklyStatRow2x2(...)`
3. **doc 코멘트에 view 용어**: "차트", "그리드", "카드", "표시되는", "디자인 순서", "Figma {노드명}"
4. **public 상수가 디자인 셋을 직접 노출**: 도메인이 "어떤 5개 항목" 인지 결정하고 있다는 뜻 — 그 결정은 view 의 몫

#### 해결 패턴

| 패턴 | 적용 예 |
|---|---|
| **파라미터화** — 디자인 수치를 호출자가 주입 | `categoryFourWeekTotals()` → `categoryTrendTotals(weekCount)` |
| **상수 이주** — view-specific 상수를 view 파일로 이동, 호출 시 인자 전달 | `SummaryCalculator.displayCategories` → `card_total_by_category.dart` 의 `_displayCategories` 후 `totalsByCategory(..., categories)` 로 주입 |
| **이름 일반화** — 메서드명에서 디자인 숫자 제거 | `FourWeek` → `Trend`, `Top3` → `Top` (count 인자) |
| **doc 환원** — view 용어를 도메인 용어로 | "대시보드 상단 2x2 그리드에 표시" → "한 기간의 4가지 합계 지표" |

#### 도메인 측에 정당한 상수 vs 디자인 결정

모든 상수가 view 결합은 아님. 두 종류를 구분:

- **도메인 상수 (남겨도 됨)**: 자연스러운 도메인 수치 — `1주 = 7일`, `1시간 = 3600초`, `AnalysisPeriod.{week, month, year}` 같은 도메인 분류
- **디자인 결정 (view 로 이주)**: 화면 표시용 수치 — "5개 부위 보여줌", "4주 추이", "Top 3" 같은 화면 디자인의 산물

판단 기준: **다른 화면/리포트에서도 자연스럽게 적용되는 수치인가?** (도메인) vs **이 특정 화면 디자인에서만 의미가 있나?** (view 결합)

#### 검토 시 확인사항

도메인(`lib/domain/...`) 파일을 변경할 때:

- [ ] 새로 추가/수정된 상수에 화면 디자인 결정이 들어가 있지 않은가
- [ ] 메서드명에 박힌 숫자가 view 가 정한 표시 수치는 아닌가 (그렇다면 파라미터화)
- [ ] doc 에 "차트/그리드/카드/표시" 같은 view 용어가 누출되지 않았는가
- [ ] public API 가 호출자(view)에게 충분히 일반적이어서, view 디자인이 바뀌어도 시그니처가 그대로일 수 있는가

### 14. 가독성 원칙: 명명과 책임 분배

코드가 한눈에 읽히지 않는다면 다음 네 원칙을 점검한다. 다음 징후 중 하나라도 보이면 이 섹션을 적용한다:
- 핵심 로직이 한눈에 들어오지 않는다
- 함수명만으로 역할을 파악하기 어렵다 (예: `percentByCategory()`, `_items()`)
- 의미가 모호한 변수명이 있다 (예: `p`)
- 주석이 길어지거나 오히려 이해를 방해한다

#### 원칙 1: 핵심 로직 앞 준비과정은 데이터를 소유한 객체가 책임진다

핵심 로직이 눈에 들어오지 않는 가장 흔한 이유는 준비과정이 호출자 쪽에 누적돼 있기 때문이다. 준비과정은 원본 데이터를 소유한 객체로 옮겨 "준비된 객체"로 만든다.

**Before** — 호출자가 카테고리별 합계를 직접 집계:

```dart
for (final order in _orders(periodOrders)) {
  for (final item in order.items) {
    final category = item.product.category;
    if (!totals.containsKey(category)) continue;
    totals[category] =
        totals[category]! + item.lineTotal(includeTax: true);
  }
}
```

**After** — 데이터 소유 객체가 집계를 제공:

```dart
final totals = periodOrders.totalsByCategory(categories);
```

`OrderListModel` 같은 모델 클래스는 본래 원본 데이터에서 필터링·요약된 결과를 제공하기 위해 존재한다. 호출자에 집계 루프가 남아 있다면 그 책임은 모델로 옮겨야 한다는 신호다. 옮긴 후 모델의 새 메서드에는 "`categories` 에 해당하는 합계만 각각 집계해 반환" 처럼 한 줄 주석만 달면 충분하다.

##### 원칙 1 은 한 번에 끝나지 않는다 — 재귀적으로 적용한다

호출자에서 모델로 위임했다고 끝이 아니다. **옮긴 메서드 본문을 다시 본다.** 또 다른 컬렉션이 보이면 같은 질문을 다시 던진다 — "이 데이터를 가장 잘 아는 객체는 누구인가?" 위임 체인의 종착점은 더 이상 자식 컬렉션이 보이지 않거나 (= leaf data), 위임이 인터페이스 복잡도를 더 증가시키기 시작할 때다.

**Before** — 첫 위임에서 멈춤. `OrderListModel` 이 내부에서 `order.items` 라는 또 다른 컬렉션을 직접 순회하고 있다:

```dart
// OrderListModel.totalsByCategory(...)
for (final order in _orders) {
  for (final item in order.items) {        // ← 또 다른 컬렉션 직접 순회
    final category = item.product.category;
    if (!totals.containsKey(category)) continue;
    totals[category] = totals[category]! + item.lineTotal(includeTax: true);
  }
}
```

**After** — items 의 책임자에게 한 번 더 위임:

```dart
// OrderListModel.totalsByCategory(...)
for (final order in _orders) {
  order.items.accumulateTotalsByCategory(totals, includeTax: true);   // 또는 order 자체에 위임
}
```

자기 데이터를 가장 잘 아는 객체에게 일을 시킨다는 동일 원칙을 한 단계 더 내려서 적용한 결과다. 첫 위임 후 결과 메서드를 즉시 다시 검사하지 않으면 위임 사슬의 한 단계에서 멈춰 버린다.

**체크리스트**: 모델에 메서드를 새로 추가했을 때, 그 메서드 본문에 다음이 보이면 위임이 한 단계 더 필요하다 — `for (final x in y.something) { ... }` 형태로 **다른 객체의 컬렉션 필드를 순회**하는 루프.

#### 원칙 2: 함수명은 "행위 / 대상 / (부사:option)" 형식

함수가 무엇을 하는지 파악되지 않는 이유는 행위와 대상이 명시되지 않았거나, 명시됐어도 모호하기 때문이다.

- 함수명은 **행위 + 대상 (+ 부사)** 구조를 따른다.
- 비즈니스 용어는 **프로젝트 용어집(존재 시) 우선** 적용한다. 용어집에 없는데 비즈니스 용어로 보이면 통일성을 위해 용어집부터 갱신한다.
- `percent`, `data`, `info` 같은 모호한 단어는 회피한다. 모호하다고 판단되면 사용자에게 한 번 확인받는 것이 가장 안전하다.
- **클래스명과 함수명이 행위를 중복 표현하지 않도록 한다.** 클래스명이 이미 행위(`Calculator`, `Validator`, `Builder`, `Mapper`, `Resolver` 같은 접미사) 를 담고 있다면 함수명에서 그 행위를 반복하지 않는다. 호출 표현 `receiver.method()` 전체가 자연스럽게 읽히는지가 기준이며, 이런 경우 `get` 처럼 일반 동사를 써도 클래스명이 "계산" 같은 본 행위를 충분히 알려준다.

**Before**: `percentByCategory()` — `percent` 가 무엇의 비율인지 불명. 주석에 `// 매출 비중(percent)` 라고 달아 보충하는 것은 가장 나쁜 패턴이다.

**After**: `salesSharesByCategory()` — "매출 비중" 이라는 비즈니스 용어로 즉시 해석 가능.

**Before (클래스명 중복)**: `CategoryBalanceCalculator.calculateSalesSharesByCategory()` — 클래스명의 `Calculator` 와 함수명의 `calculate` 가 행위를 중복 표현. 호출 표현이 "계산기가 계산한다" 처럼 어색해진다.

**After**: `CategoryBalanceCalculator.getSalesSharesByCategory()` — 클래스명이 이미 "계산" 이라는 행위를 알려주므로 함수명은 `get` 만으로 충분하다.

#### 원칙 3: 변수명에도 동일한 명명 규칙을 적용한다

차이는 행위가 빠진다는 점뿐이다. 한 글자 변수(`p`, `r`, `e`)는 짧은 람다 외에는 사용하지 않는다. 모호한 명사를 피하고 도메인 용어로 통일한다. 해결책은 원칙 2 와 동일하다 — 용어집 우선, 모호하면 사용자 확인.

#### 원칙 4: 주석은 마지막에, 짧게, 명료한 단어로만

주석이 길어지는 원인은 거의 항상 원칙 1~3 이 지켜지지 않은 데 있다. 모호한 이름과 복잡한 준비과정을 주석으로 메우려 할수록 주석은 더러워진다.

주석 작성 순서:
1. 원칙 1~3 을 먼저 적용해 코드가 스스로 의도를 드러내게 만든다.
2. 그래도 보충이 필요한 부분만 한두 줄로 적는다 — 역할과 의도만, 구현 설명 금지.
3. `humanizer` 스킬을 적용해 글의 맥락이 자연스럽게 읽히도록 다듬는다.

**Before**:

```dart
final percent; // 매출 비중(percent)
```

**After**: 이름만으로 충분, 주석 불필요.

```dart
final salesShares;
```

### 15. 데이터 소스 매핑의 단일 진입점

§2/§13 이 레이어 import 와 view 결합을 다룬다면, §15 는 **동일 도메인 모델을 빌드하는 매핑 경로가 코드베이스 안에 단일하게 존재해야 한다** 는 룰을 다룬다.

#### Acid test

> **"이 모델에 새 필드가 하나 추가되었을 때 갱신해야 하는 매핑 위치가 몇 곳인가?"** → 1곳이어야 한다. 2곳 이상이라면 매핑 경로가 새고 있다.

특히 상품 마스터 데이터(`ProductModel`, `ProductCategoryModel` 등) 처럼 여러 도메인이 참조하는 모델은 매핑 경로가 분산되면 한 곳만 갱신했을 때 다른 호출처에서 새 필드가 누락된 채 사용된다. 정적 분석으로 잡히지 않고 런타임 화면에서 빈 값으로만 드러나는 함정.

#### 결합 탐지 신호

다음 패턴이 보이면 매핑 경로 분산을 의심:

1. **Repository 마다 같은 DTO 의 lookup map 을 자체 빌드**: 주문 / 정산 / 배송 / 카탈로그 Repository 가 각각 `_buildProductMap()` 류 헬퍼로 `Map<String, ProductModel>` 을 자체 조립.
2. **매퍼가 호출자에게 외부 인자를 받음**: `dto.toModel(options: ...)` 처럼 매핑에 필요한 데이터를 호출자가 채워 넘기는 시그니처. 이 인자가 누락된 호출처가 한 곳이라도 있으면 즉시 버그.
3. **DAO 가 raw entity 만 반환하고 관련 테이블은 별도 메서드**: `getProducts()` 와 `getProductOptions()` 가 분리되어 있고, Repository 가 호출 후 메모리에서 합침. 두 Repository 가 같은 합치는 로직을 들고 있다면 분산 신호.
4. **`copyWith` 로 필드 후주입**: 매핑 완료 후 외부 데이터를 `copyWith` 로 끼워 넣는 패턴. 끼워 넣는 곳이 한 곳이라도 빠지면 빈 값.

#### 해결 패턴

| 패턴 | 적용 예 |
|---|---|
| **DAO SQL JOIN** — 관련 테이블을 SQL JOIN 으로 합쳐 완성된 DTO 반환 | `ProductDao.getProducts()` 가 `product_options` LEFT JOIN 으로 `options` 까지 채운 DTO 반환 |
| **DTO 가 외부 테이블 데이터를 흡수** — fromSqfData 가 JOIN 결과 그대로 받는 필드 보유 | `ProductDto.options: Map<int, double>` + `@JsonKey(includeFromJson: false)` 로 JSON 직렬화 경로와 분리 |
| **매퍼 시그니처 인자 0개** — DTO 만으로 도메인 모델 완성. 외부 인자 X | `dto.toModel()` 단일 호출. 호출자가 추가로 매핑할 책임 없음 |
| **Repository 의 그룹화 헬퍼 제거** — DAO 가 이미 그룹화한 결과를 주므로 Repository 의 inline 그룹화 로직 삭제 | `_groupOptions()` 같은 헬퍼는 DAO 로 이주 |

#### 정당한 분산 vs 매핑 누수

모든 매핑 책임 분산이 누수는 아님. 두 경우를 구분:

- **정당한 분산**: 도메인이 다른 두 모델이 같은 raw 데이터를 **다르게** 해석. 예: `OrderRecord` 가 `entries TEXT` JSON 을 자체 파싱해 `RetailOrderEntry` / `WholesaleOrderEntry` 로 분기. 의미 해석이 달라 단일화 불가능.
- **누수 (해결 필요)**: 같은 도메인 모델(`ProductModel`) 을 여러 Repository 가 자체 헬퍼로 **동일하게** 조립. 결과가 항상 같아야 하는데 분산되어 있음.

판단 기준: **"이 모델을 빌드하는 두 곳의 결과가 항상 같아야 하나?"** Yes 면 단일 진입점으로 합쳐야 함.

#### 신규 매스터 데이터 추가 시 기본 디자인

새 마스터 데이터(예: option 같은 상품 부속 정보) 를 도메인 모델에 노출해야 할 때 기본 디자인 순서:

1. 해당 데이터를 **DAO 의 기존 entity 조회 SQL 에 JOIN** 으로 합칠 수 있는지 먼저 검토.
2. JOIN 가능하면 **DTO 에 흡수 필드 추가** 후 fromSqfData 에서 받기. JSON 응답에 없으면 `@JsonKey(includeFromJson: false)`.
3. 매퍼는 시그니처 변경 없이 DTO 의 새 필드만 도메인 enum/타입으로 변환.
4. Repository 그룹화/주입 로직을 **추가하지 않음**. 이미 DAO 단에서 완성된 DTO 가 나옴.

이렇게 하면 같은 DAO 를 쓰는 모든 Repository (주문, 정산, 배송, 카탈로그 등) 가 자동으로 새 필드를 받게 되어 매핑 누락 함정이 원천 차단된다.

#### 검토 시 확인사항

새 도메인 모델 / 마스터 데이터 / 관련 매핑을 추가하거나 변경할 때:

- [ ] 이 모델을 빌드하는 매핑 경로가 코드베이스 안에서 단일한가
- [ ] DAO 가 완성된 DTO 를 반환하는가 (관련 데이터를 호출자가 합치는 구조가 아닌가)
- [ ] 매퍼 시그니처가 외부 인자 없이 `dto.toModel()` 단일 호출로 끝나는가
- [ ] 새 필드 추가 시 갱신할 매핑 위치가 1곳인가
- [ ] 같은 DTO 를 lookup map 으로 만드는 헬퍼가 Repository 마다 중복되어 있지 않은가

## 출력 형식

```markdown
## Convention Review: {브랜치 또는 파일 목록}

### {file_path}

- `[B]` **{Rule Category}**: {위반 설명}
  - Line {N}: `{code snippet}`
  - Fix: {구체적인 수정 제안}

- `[S]` **{Rule Category}**: {설명}
  - Line {N}: `{code snippet}`
  - Suggestion: {무엇을 변경할지와 이유}

- `[N]` **{Rule Category}**: {설명}
  - Line {N}: `{code snippet}`

### Summary

| Severity | Count |
|----------|-------|
| BLOCKING | {n} |
| SUGGESTION | {n} |
| NIT | {n} |

{전반적인 평가 한 문장}
```

## 규칙

### MUST
- 리포트 전에 변경된 모든 파일을 읽을 것. 파일명만으로 추측하지 않음.
- 각 발견 사항에 대해 정확한 라인 번호와 코드 스니펫을 참조할 것.
- 범위 내의 변경된 모든 파일에 대해 15개의 체크리스트를 모두 확인할 것 (단, §12 주석 작성은 사용자가 명시적으로 주석 작업을 요청한 경우에만 적용).
- `data-layer`/`domain-layer`/`view-layer` 스킬의 프로젝트별 규칙을 권위 있는 출처로 적용할 것.

### MUST NOT
- 변경되지 않은 코드에 주석, docstring, 타입 어노테이션 추가를 제안하지 않을 것.
- 변경 범위를 넘는 리팩터링을 제안하지 않을 것.
- 발견 사항을 자동 수정하지 않을 것. 보고만 하고 수정은 사용자가 결정함.
- 현재 변경 사항에 포함되지 않은 코드에 대한 발견 사항을 보고하지 않을 것.

## 참조 파일

- [Data Layer 가이드](../data-layer/SKILL.md)
- [Domain Layer 가이드](../domain-layer/SKILL.md)
- [View Layer 가이드](../view-layer/SKILL.md)
- [Git Commit & 브랜치 규칙](../git/SKILL.md)
