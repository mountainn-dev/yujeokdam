---
name: view-layer
description: 뷰 레이어 가이드 — Screen/ViewModel/StateHolder/Store 책임 분리, GetIt+Provider 배선, UI 이벤트, 에셋. 트리거 구문 - "/view-layer", "view layer", "StateHolder", "ViewModel", "screen 작성", "위젯 상태"
---

# View Layer 가이드

`lib/view` 레이어에서 화면을 작성하거나 상태 객체를 설계할 때 적용하는 규칙이다. Screen / ViewModel / StateHolder / Store 의 책임을 분리하고, GetIt + Provider 로 배선하며, UI 이벤트와 에셋을 다루는 기준을 담는다.

## 사용 시점

- 새 화면(`screen_*.dart`)이나 ViewModel(`view_model_*.dart`)을 작성할 때
- 상태 객체(`StateHolder`, `Store`)를 설계하거나 화면에 연결할 때
- 위젯 트리에 상태를 바인딩하거나 UI 이벤트(스낵바, 다이얼로그, 내비게이션)를 발생시킬 때
- 사용자가 `/view-layer` 를 호출하거나 "view layer", "StateHolder", "ViewModel" 관련 작업을 요청할 때

## 네 가지 상태 객체의 역할 한눈에 보기

| 객체 | 책임 | 금지 |
|---|---|---|
| `Screen` / Widget | UI 렌더링, 사용자 상호작용. `StateHolder` 는 읽기 전용으로 바인딩 | 변경/작업 요청을 `StateHolder` 에 직접 호출, 저수준 data source 로직 |
| `ViewModel` | 화면별 일시 상태, `StateHolder`/`Store` 조율, UI 이벤트 발생 | `BuildContext` 주입, 패스스루 getter, `StateHolder` 대신 `notifyListeners()` |
| `StateHolder` | 상태 보유 + `notifyListeners()` | UI 이벤트, `BaseViewModel` 상속 |
| `Store` | 읽기 전용/불변 앱 데이터, 한 번 초기화 후 읽기 | 가변 공유 상태 (그건 `StateHolder` 소관) |

핵심 제어 흐름: **Screen → ViewModel → StateHolder**. 화면은 자기 ViewModel 메서드를 호출하고, ViewModel 만이 `StateHolder` 를 호출한다.

## 에러 처리 — view 는 try-catch 금지

### MUST NOT
- **view 레이어(Screen·Widget·ViewModel·StateHolder)에서 try-catch 를 절대 사용하지 않는다.** 예외 처리는 data 레이어(`BaseRepository.execute`)가 전담하고, view 는 `Result` 만 소비한다.
- 카메라·ML Kit·파일 등 **플랫폼/하드웨어/저수준 호출을 ViewModel 에서 직접 하지 않는다.** 이런 호출은 throw 하므로 data source 로 내려 `execute` 로 감싸 `Result` 로 변환받고, ViewModel 은 그 결과만 소비한다.

### MUST
- repository·usecase 모두 `Result<T>` 를 반환하므로 소비 방식이 같다. `BaseViewModel` 의 `runSingleTask*`/`withMessage`/`runWithLoading` 로 감싸 로딩·실패 토스트를 자동 처리하거나, 직접 분기 시 case/is 룰(값 사용 → `case`, 값 미사용 → `is`)을 따른다.

## 1. 뷰 레이어 아키텍처 관점

### MUST
- 화면(예: `screen_home.dart`)은 UI 렌더링과 사용자 상호작용만 담당한다.
- ViewModel(예: `view_model_home.dart`)은 명확히 정의된 인터페이스를 통해 `view` 와 `domain`/`data` 사이를 조율한다.
- 의존성 주입 / ViewModel 생성 로직(예: `view/di/module_view_model_factory.dart`)은 한곳에 모아 화면 간에 재사용한다.

### MUST NOT
- 화면은 원시 repository 나 저수준 data source 로직을 포함하지 않는다.
- 뷰 코드는 `domain` 에 속하는 복잡한 비즈니스 규칙을 품지 않는다.
- DI 설정은 화면마다 중복하지 않으며, DI 모듈에 추가한다.

## 2. StateHolder — 상태 보유와 알림에만 집중

### MUST
- `StateHolder` 클래스는 오직 상태를 들고 리스너에 알리는 일에만 집중하며, 내부 상태가 바뀌면 `notifyListeners()` 를 호출한다.
- 자기 데이터가 바뀌면 `notifyListeners()` 호출은 `StateHolder` 가 책임진다.
- ViewModel 이 `StateHolder` 에 작업을 요청할 때, `StateHolder` 는 요청된 작업을 수행하고 성공 시 자기 상태를 갱신한 뒤 `Result`(성공/실패)를 ViewModel 에 반환한다.

### MUST NOT
- `StateHolder` 는 ViewModel 처럼 행동하지 않으며, UI 이벤트(스낵바, 다이얼로그, 내비게이션)를 직접 일으키지 않는다.
- `StateHolder` 는 `BaseViewModel` 이나 그 외 뷰 전용 베이스 클래스를 상속하지 않으며, `ChangeNotifier`(또는 비슷한 최소 인터페이스)만 구현하는 게 좋다.

## 3. ViewModel — 화면 스코프 조율자

### MUST
- 화면 스코프 ViewModel 은 화면별 일시 상태, `StateHolder`/`Store` 호출 조율, UI 이벤트 발생(스낵바, 다이얼로그, 내비게이션, 일회성 동작)을 소유한다.
- ViewModel 은 작업을 요청하거나 공유 상태를 조율해야 할 때 `StateHolder` 나 `Store` 인스턴스를 의존성 주입으로 받을 수 있다.
- ViewModel 이 `StateHolder` 에 작업을 요청할 때, 연산이 끝날 때까지 `Processing`(또는 동등한) UI 이벤트를 발생시키고, 반환된 `Result` 에 따라 적절한 UI 이벤트(성공/실패 메시지, 내비게이션)를 발생시킨다.
- 부모 화면이 처리해야 하는 자식 화면발 이벤트는 부모 화면의 ViewModel 을 통해 흐른다. 자식이 부모 ViewModel 에 알리고, 부모가 처리한다.

### MUST NOT
- "global ViewModel" 이라는 용어는 사용하지 않으며, 모든 ViewModel 은 특정 화면에 스코프된다.
- ViewModel 은 `BuildContext` 나 그 외 뷰 전용 의존성을 생성자 주입이나 setter 로 받지 않으며, 구체적인 위젯 트리와 내비게이션 메커니즘에서 독립적으로 유지된다.
- ViewModel 은 `StateHolder` 데이터를 뷰에 노출만 하는 단순 패스스루 `getter` 를 구현하지 않는다. 뷰는 데이터 바인딩을 위해 `StateHolder` 에 직접 접근해 `notifyListeners()` 가 의도대로 동작하게 하는 게 좋다.
- ViewModel 은 `StateHolder` 소유 데이터에 대해 `StateHolder` 를 대신해 `notifyListeners()` 를 호출하지 않는다.
- 어떤 데이터를 화면이 읽기만 하고 ViewModel 에서 변경할 필요가 없다면, ViewModel 은 읽기 목적만으로 `StateHolder` 의존성을 받지 않는다. 그 상태는 화면에 파라미터로 넘기거나 `StateHolder` 에서 직접 바인딩하는 게 좋다.

## 4. Screen / Widget — StateHolder 는 listen-only

### MUST
- 화면과 위젯은 `StateHolder` 를 읽기 전용 의존성으로 취급한다. `context.watch`/`context.read`/`Selector`/`Consumer` 나 단순 getter 접근으로 상태를 읽는다.
- `StateHolder` 를 향한 변경이나 작업 요청은 그 화면의 ViewModel 을 거친다. 화면은 ViewModel 메서드를 호출하고, ViewModel 이 `StateHolder` 를 호출한다.

### MUST NOT
- 화면과 위젯은 `StateHolder` 의 변경/요청/작업 메서드를 직접 호출하지 않는다(예: `stateHolder.updateXxx(...)`, `stateHolder.setXxx(...)`, `stateHolder.startXxx(...)`, `stateHolder.requestXxx(...)`). 화면이 `StateHolder` 상태를 바꿔야 한다면 자기 ViewModel 의 메서드를 호출하고, 그 ViewModel 이 `StateHolder` 를 호출한다.
- 네트워크를 건드리지 않는 "로컬 전용" setter 에도 똑같이 적용된다. 핵심은 네트워크 호출 여부가 아니라 제어 흐름의 방향이다.

## 5. 프레젠테이션 상태 객체 선택 (Store vs StateHolder vs ViewModel)

### MUST
- `Store` 객체는 읽기 전용이거나 사실상 불변인 앱 데이터에 사용하며, 한 번 초기화한 뒤 화면과 ViewModel 이 읽기만 해도 된다.
- `StateHolder` 객체는 여러 화면(예: 하단 탭 흐름)에 걸쳐 공유 가변 상태가 필요할 때 쓸 수 있되, 과한 결합을 피하도록 사용을 신중하게 하고 최소화한다.
- 여러 화면이 공유하는 데이터는 공유 ViewModel 이 아니라 공유 `Store` / `StateHolder` 인스턴스로 다룬다.
- 화면은 자기 ViewModel 과 관련 `StateHolder` / `Store` 인스턴스에서 관심 있는 이벤트나 스트림을 구독하며, 구독은 전역이 아니라 화면 단위로 스코프하는 게 좋다.
- 화면이 공유 상태를 편집해야 하면, 해당 `StateHolder` 를 `ChangeNotifierProvider`(또는 동등한 메커니즘)로 위젯 트리에 제공해 변경이 관심 있는 위젯들에 자동으로 전파되게 하는 게 좋다.

### MUST NOT
- 하단 탭 화면은 단일 ViewModel 인스턴스를 공유하지 않으며, 각 화면이 자기 ViewModel 을 가지고 필요한 데이터만 `Store` / `StateHolder` 로 공유한다.
- 개별 화면이나 위젯은 특정 상태 조각만 넘겨받을 수 있는 상황에서 암묵적 전역 `StateHolder` 접근에 의존하지 않는다.
- `StateHolder` 에서 몇 개 값만 읽으면 되는 화면은 전체 `StateHolder` 를 주입하지 않으며, 필요한 값이나 도메인 모델만 파라미터로 받는 게 좋다.

## 6. View & ViewModel 안티패턴

### MUST NOT
- 위젯은 기본적으로 ViewModel 인스턴스 전체를 받지 않으며, 실제로 필요한 데이터와 콜백만 받는 게 좋다(예외: 값과 콜백을 넘기기가 명백히 비현실적인 매우 큰 복합 위젯).
- 화면과 위젯은 위젯 트리 아래로 과도한 양의 원시 값과 콜백을 흘려보내지 않으며, 그런 일이 시작되면 전용 ViewModel 을 도입하는 게 좋다.
- 뷰는 도메인 모델을 여러 개별 원시 필드로 "폭발" 시키지 않는다. 도메인 모델은 의미 있는 동작과 파생 값을 노출하고, ViewModel 이 그 동작을 조율하며, 뷰는 그 결과 상태에만 바인딩하는 게 좋다.

## 7. View 배선 패턴 (GetIt + Provider)

### MUST
- ViewModel 은 `GetIt` 의 `registerFactory`/`registerFactoryParam` 을 통해서만 인스턴스화하고, 화면은 필요한 `StateHolderGroup` 인자를 모아 `GetIt.I.get<VM>(param1: group)` 을 호출한다.
- ViewModel 은 `ChangeNotifierProvider.value` 로 제공하고, UI 이벤트(예: `StartTask`/`EndTask`/`ShowToast`)는 ViewModel `eventStream` 을 구독하며, 화면 데이터는 `Provider` 를 통해 `StateHolder`/`Store` 에서 직접 바인딩한다.
- `StateHolder`/repository 로의 작업 요청을 감싸고 UI 이벤트를 발생시키는 데는 `BaseViewModel` 헬퍼(`runSingleTaskWithMessage`, `runMultipleTasks`)를 사용하되, `notifyListeners()` 소유는 `StateHolder` 가 가진다.

### MUST NOT
- 화면 안에서 repository 나 `StateHolder` 인스턴스를 직접 생성하지 말고, `GetIt` 모듈로만 해석한다.
- 바인딩을 위해 ViewModel 패스스루 getter 로 `StateHolder` 데이터를 노출하지 말고, 뷰가 `StateHolder` 를 직접 리슨해 그 `notifyListeners()` 가 리빌드를 구동하게 한다.

## 8. 뷰 DI 모듈과 배선 순서

뷰 레이어의 DI 는 세 모듈로 한곳에 모은다.

| 모듈 | 등록 대상 |
|---|---|
| `StoreModule` | `Store` 객체 (읽기 전용/불변 앱 데이터) |
| `StateHolderModule` | `StateHolder` 객체 (공유 가변 상태) |
| `ViewModelFactoryModule` | 화면 스코프 ViewModel 팩토리 |

### MUST
- DI 컨테이너는 `GetIt` 하나만 사용하고, 뷰 의존성은 위 세 모듈에만 등록한다.
- 모듈 배선은 `main.dart`(또는 단일 bootstrap)에서만 하며, 전체 순서는 **Local → Remote → Repository → UseCase → Store → StateHolder → ViewModel** 이다. 뷰 레이어는 이 중 마지막 셋(`Store` / `StateHolder` / `ViewModel`)을 소유한다.
- 뷰에서 의존성은 `GetIt.I.get<T>()`(필요 시 factory param 사용)로 가져오며, 직접 생성하지 않는다.
- 라이프타임을 일관되게 사용한다. 공용 서비스는 `registerSingleton`, 화면 스코프 객체는 `registerFactory`/`registerFactoryParam`.

### MUST NOT
- DI 등록을 여기저기 흩뿌리지 말고, 알맞은 모듈 클래스에만 추가한다.
- view 에서 repo/API/DAO 를 직접 생성하지 말고, `GetIt` 에서 추상화를 요청한다.
- 추가 DI 컨테이너/서비스 로케이터를 도입하지 않는다.

## 9. 에셋 & 설정

뷰가 참조하는 이미지/아이콘 에셋과 시작 화면 비주얼을 다룰 때 적용한다.

### MUST
- 모든 이미지와 아이콘 에셋은 `assets` 아래(예: `assets/icons`, `assets/images`)에 두고 필요할 때 `pubspec.yaml` 에 등록한다.
- 스플래시나 시작 화면 비주얼 변경은 `flutter_native_splash.yaml` 이나 알맞은 플랫폼별 설정 파일을 통해 조율한다.

### MUST NOT
- 플랫폼별 설정 파일(예: `android/app/build.gradle`, `ios/Podfile`)은 기능 로직을 위해 수정하지 않는다. 이 파일들은 빌드/설정 전용이다.

## 참조 파일

- [Data Layer 가이드](../data-layer/SKILL.md)
- [Domain Layer 가이드](../domain-layer/SKILL.md)
- [Convention Skill](../convention/SKILL.md)
