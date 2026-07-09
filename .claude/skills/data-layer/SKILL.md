---
name: data-layer
description: 데이터 레이어 구현 가이드 — source(API/DAO), DTO, mapper, repository_impl, `BaseRepository.execute`, `Result<T>`, 데이터측 DI 모듈. 트리거 구문 - "/data-layer", "data layer", "repository 구현", "DAO 작성", "DTO 매핑".
---

# Data Layer 구현 가이드

`lib/data` 레이어를 새로 짜거나 손볼 때 따르는 골격이다. 외부 I/O를 격리하고, DTO를 도메인 모델로 변환하며, 실패를 `Result<T>`로 감싸 도메인 경계 밖으로 저수준 예외가 새지 않게 만드는 것이 핵심이다.

## 사용 시점

- 새 기능의 `source`/`dto`/`mapper`/`repository_impl` 골격을 만들 때
- repository 구현체를 작성하거나 API와 DAO를 조율하는 흐름을 짤 때
- DAO를 추가하거나 sqflite 캐싱 로직을 손볼 때
- DTO ↔ 도메인 매핑을 다룰 때

## 데이터 레이어의 책임

데이터 레이어는 도메인이 정의한 추상화를 실제로 구현하는 곳이다. HTTP, DB, 로컬 스토리지, 플랫폼 채널 같은 모든 외부 I/O가 여기에 모인다. `source`(API/DAO)는 DTO와 원시 타입만 다루고, 원시 데이터와 도메인 모델 사이의 변환은 mapper가 맡는다.

### MUST

- 도메인이 정의한 repository/data source 추상화를 데이터 레이어에서 구현한다.
- 모든 외부 I/O(HTTP, DB, 로컬 스토리지, 플랫폼 채널)를 `data`에 둔다.
- 원시 데이터 ↔ 도메인 매핑은 mapper에서 처리하고, `source`(API/DAO)는 DTO/원시 타입만 다룬다.

### MUST NOT

- `data`에 UI 코드나 import를 두지 않는다.
- `data`에 `BuildContext`나 내비게이션을 두지 않는다.
- 데이터와 무관한 비즈니스 규칙을 `data`에 두지 않는다. 그건 `domain` 소관이다.

## 기능별 골격

기능 하나를 추가할 때는 아래 구조를 일관되게 따른다. 디렉터리와 파일 접두사가 책임을 그대로 드러낸다.

```
lib/data/{feature}/
├── source/
│   ├── remote/
│   │   ├── api/        → 추상 API 인터페이스 (api_{feature}.dart)
│   │   └── api_impl/   → Supabase 구현체 (api_impl_{feature}.dart)
│   └── local/
│       ├── dao/        → 추상 DAO 인터페이스 (dao_{feature}.dart)
│       └── dao_impl/   → sqflite 구현체 (dao_impl_{feature}.dart)
├── dto/                → DTO 클래스 (dto_{feature}.dart)
├── mapper/             → DTO ↔ 도메인 변환 (mapper_{feature}.dart)
└── repository_impl/    → repository 구현 (repository_impl_{feature}.dart)
```

### MUST

- 기능마다 위 골격을 그대로 사용한다: `source/remote`(API + Supabase impl), `source/local`(DAO + sqflite impl), `dto`, `mapper`(DTO↔domain), `repository_impl`(`BaseRepository.execute` + `Result`).
- DTO는 `json` 스킬의 `@JsonSerializable` 패턴을 따른다. 직렬화 세부는 그 스킬을 참조한다.
- repository가 API와 DAO를 조율하게 하고, DTO를 위로 반환하지 말고 반환 전에 도메인 모델로 매핑한다.
- DateTime은 읽을 때 server→local, 쓸 때 local→UTC로 변환한다.

### MUST NOT

- DTO를 domain/view로 노출해 mapper를 우회하지 않는다. 필요하면 mapper를 추가하거나 확장한다.
- API/DAO impl 밖으로 `SupabaseClient`/`Database`를 주입하지 않는다. repository는 추상화만 받는다.
- 데이터 DI 등록을 여기저기 흩뿌리지 않으며, 모듈과 instanceName 규약을 지킨다.
- API/DAO 안에 비즈니스 규칙을 넣지 않으며, repository나 domain에 둔다.

## DTO 직렬화는 json 스킬을 따른다

DTO의 JSON·sqflite 직렬화는 `@JsonSerializable` + `json_annotation` + `build_runner` 제너레이터 방식을 쓴다. 코드베이스는 이미 이 방식으로 100% 마이그레이션이 끝났고, 레거시 커스텀 `JsonMapper`/`SqfLiteMapper`/`TypeChange` 는 더 이상 쓰지 않는다(`JsonMapper` 사용처 0건).

새 DTO를 만들거나 직렬화를 손볼 때는 이 스킬에서 패턴을 다시 설명하지 않고 `json` 스킬(`.claude/skills/json/SKILL.md`)을 참조한다. 거기에 `@JsonSerializable`, `fieldRename`, `explicitToJson`, `@DateTimeConverter`, `createToJson`, `fromSqfData`/`toSqfData` 변환 규칙이 모두 정리되어 있다.

이 가이드에서 유지할 데이터 레이어 차원의 규칙은 DateTime 변환 방향뿐이다.

### MUST

- DateTime은 읽을 때(server→local) `toLocal()`, 쓸 때(local→UTC) `toUtc()`로 변환한다. API JSON은 `@DateTimeConverter`가, sqflite는 `fromSqfData`/`toSqfData`가 처리한다.

### MUST NOT

- `JsonMapper`/`SqfLiteMapper`/`TypeChange` 를 새 코드에 다시 들이지 않는다. 직렬화는 `json` 스킬의 제너레이터 방식만 사용한다.

## Repository & 데이터 흐름

repository는 도메인 계약을 충족하는 조율자다. API와 DAO, 때로는 다른 repository를 가로질러 데이터를 모으고, 도메인 모델로 변환한 뒤 `Result<T>`로 감싸 반환한다. 캐싱·병합·변환은 모두 이 레이어 이하에서 끝나야 하며 ViewModel로 새지 않는다.

```
API (HTTP) ┐
           ├→ Repository (조율 + DTO→도메인 매핑 + Result 래핑) → UseCase → ...
DAO (sqf) ┘
```

### MUST

- 외부 의존성(`SupabaseClient`, sqflite `Database`)은 API/DAO에 주입하고, 이들은 CRUD에 집중하게 한다.
- repository 구현체가 API/DAO/다른 repo를 가로질러 조율해 도메인 계약을 충족하게 한다.
- 모든 API/DAO DTO는 위로 노출하기 전에 데이터 레이어 안에서 도메인 모델로 변환한다.
- 실패하는 메서드는 `Result<T>`를 반환하고, 저수준 예외를 도메인 친화적 에러로 보호한다.
- 캐싱/데이터 병합/모델 변환은 repository나 그 아래에 둔다.

### MUST NOT

- 최소한의 검증을 넘어서는 비즈니스 규칙을 API/DAO 안에 두지 않는다.
- DTO 타입을 domain/view로 새어 나가게 하지 않는다.
- repository 쪽 캐싱/변환을 ViewModel에 중복하지 않는다.

## BaseRepository.execute 와 Result<T>

도메인 대면 연산은 모두 `Result<T>`로 감싼다. 데이터가 있으면 `Success`, 실패면 `Error(ServiceError)`, 부재면 `NotFound`다. `NotFound`는 기술적 에러가 아니라 도메인 상태이므로 그 의미 해석은 repository가 아니라 UseCase가 한다. repository는 "데이터를 못 찾았다"는 사실만 알린다.

저수준 호출은 `BaseRepository.execute`로 감싼다. Socket/Timeout/Postgrest/알 수 없는 에러를 `ServiceExceptionMessage` 기본값과 기능별 fallback이 적용된 `ServiceError`로 변환해 준다.

### MUST

- 도메인 대면 연산은 `Result<T>`로 감싼다: 데이터는 `Succeed`, 실패는 `Failed(Failure)`, 부재는 `NotFound`.
- 저수준 호출을 보호하기 위해 `BaseRepository.execute`를 사용하고, Socket/Timeout/Postgrest/알 수 없는 에러를 `Failure`로 변환한다.
- **`execute` 블록은 도메인 모델 값(`T`) 또는 `null`을 반환하거나, 실패 시 `throw` 한다.** 값이 없으면 `null` → `execute` 가 `NotFound`, 값이 있으면 `Succeed`, 예외는 `Failed` 로 변환한다.
- 도메인 repository 인터페이스는 `Future<Result<...>>`를 반환하고, 데이터 구현체는 감싸기 전에 DTO를 도메인 모델로 변환한다.

### MUST NOT

- 도메인 경계 너머로 DTO나 맨 future를 반환하거나 저수준 예외를 던지지 않는다. 언제나 `Result<T>`를 반환한다.
- `NotFound`의 비즈니스 의미를 repository에서 판단하지 않는다. 그건 UseCase 소관이다.
- **`execute` 블록 안에서 `Result.succeed`/`Result.failed`/`Result.notFound` 인스턴스를 직접 만들지 않는다.** 직접 만든다는 것은 결과 해석이 들어갔다는 신호이고(이는 `execute` 를 우회함), 그 해석은 UseCase 로 옮긴다. 직접 만들 거면 `execute` 를 쓸 이유가 없다.
- 폐기된 `Result.error(String)`을 다시 들이지 않는다.
- **try-catch 는 `BaseRepository.execute` 가 전담한다.** api/dao impl·repository impl 본문에 임의 try-catch 를 두지 않는다 (예외는 그대로 던져 `execute` 가 변환). `data` 레이어에서 유일한 추가 허용 지점은 **mapper** 의 파싱 등 불가피한 경우이며, 이때도 **사용자에게 확인받은 뒤** 사용한다. (단, `finally` 만 쓰는 리소스 정리 `try/finally` 는 허용 — 예: detector·controller close)

## sqflite (로컬 DAO)

로컬 캐싱이 필요한 기능은 DAO를 통해 sqflite에 접근한다. 스키마와 마이그레이션은 한곳에 모으고, DAO 구현체는 SQL과 DTO 마샬링에만 집중한다.

### MUST

- sqflite 스키마/마이그레이션은 `lib/data/sqflite_helper.dart`에 둔다.
- DAO impl은 SQL과 DTO 마샬링(`toSqfData`/`fromSqfData`)에 집중하며, 가능하면 batch로 처리한다.
- `fromSqfData`/`toSqfData`의 타입·DateTime 변환은 `json` 스킬의 sqflite 직렬화 규칙을 따른다.

### MUST NOT

- DAO impl 밖으로 `Database`를 주입하지 않는다.
- DAO 안에 비즈니스 규칙을 넣지 않는다.

## 데이터측 DI 모듈

데이터 레이어 의존성은 세 모듈로만 등록한다. 등록을 화면이나 다른 곳에 흩뿌리지 않고 모듈 클래스에만 추가한다.

| 모듈 | 등록 대상 |
|---|---|
| `LocalSourceModule` | DAO / 로컬 소스 |
| `RemoteSourceModule` | remote API / Supabase |
| `RepositoryModule` | repository 구현체 |

전체 배선 순서는 `main.dart`(또는 단일 bootstrap)에서 Local → Remote → Repository → UseCase → Store → StateHolder → ViewModel 로 진행되며, **데이터 레이어는 앞의 세 단계(Local → Remote → Repository)를 소유한다.** 나머지(UseCase 이후)는 도메인·뷰 레이어 소관이다.

### MUST

- 데이터 레이어 의존성은 `LocalSourceModule`, `RemoteSourceModule`, `RepositoryModule`로만 등록한다.
- 데이터측 초기화 순서는 Local → Remote → Repository로 한다.
- 외부 의존성(`SupabaseClient`, `Database`)은 API/DAO impl에만 주입하고, repository에는 추상화만 넘긴다.

### MUST NOT

- DI 등록을 여기저기 흩뿌리지 않으며, 알맞은 모듈 클래스에만 추가한다.
- view나 domain에서 repo/API/DAO를 직접 생성하지 않으며, `GetIt`에서 추상화를 요청한다.
- 저수준 클라이언트(`SupabaseClient`/`Database`)를 데이터 레이어의 API/DAO impl 밖에서 요청하지 않는다.

## 관련 스킬

- DTO 직렬화(`@JsonSerializable`, `@DateTimeConverter`, `fromSqfData`/`toSqfData` 변환 규칙): `json` 스킬
- 데이터 레이어 테스트(단위/모킹): `flutter-testing` 스킬
