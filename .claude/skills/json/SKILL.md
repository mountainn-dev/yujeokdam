---
name: json
description: DTO 클래스를 커스텀 JsonMapper/SqfLiteMapper 패턴에서 json_annotation(@JsonSerializable)과 build_runner 코드 생성 방식으로 마이그레이션. API JSON과 sqflite 직렬화를 모두 다룸.
---

# JSON Annotation 마이그레이션 스킬

레거시 커스텀 `JsonMapper`/`SqfLiteMapper`/`TypeChange` 패턴을 사용하는 DTO 파일을 `json_annotation` + `build_runner` 코드 생성 방식으로 마이그레이션한다. API(Supabase) JSON 직렬화와 sqflite 로컬 DB 직렬화를 모두 포함한다.

## 트리거 시점

- 사용자가 DTO를 json_annotation으로 마이그레이션해 달라고 요청할 때
- 사용자가 새 DTO를 생성해 달라고 요청할 때

## 레거시 패턴 (이전)

### API JSON — `JsonMapper`

```dart
class ExampleDto {
  final String id;
  final DateTime created;

  ExampleDto({required this.id, required this.created});

  factory ExampleDto.fromJson(Map<String, dynamic> json) {
    final tc = JsonMapper();
    return ExampleDto(
      id: tc.toStrFromKey(json, 'id'),
      created: tc.toDateTimeFromKey(json, 'created'),
    );
  }

  Map<String, dynamic> toJson() {
    final tc = JsonMapper();
    return {
      'id': tc.fromStr(id),
      'created': tc.fromDateTime(created),
    };
  }
}
```

### sqflite — `SqfLiteMapper`

```dart
// Same DTO class, additional methods:
factory ExampleDto.fromSqfData(Map<String, dynamic> data) {
  TypeChange tc = SqfLiteMapper();
  return ExampleDto(
    id: tc.toStrFromKey(data, 'id'),
    created: tc.toDateTimeFromKey(data, 'created'),
  );
}

Map<String, dynamic> toSqfData() {
  TypeChange tc = SqfLiteMapper();
  return {
    'id': tc.fromStr(id),
    'created': tc.fromDateTime(created),
  };
}
```

## 목표 패턴 (이후)

### Case 1: 표준 — fromJson과 toJson 모두 자동 생성

모든 필드가 JSON 키와 1:1로 매핑되고(snake_case ↔ camelCase) 중첩된 DTO 필드가 없을 때 사용한다.

```dart
import 'package:json_annotation/json_annotation.dart';

part 'dto_example.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExampleDto {
  final String id;
  final String userId;

  ExampleDto({required this.id, required this.userId});

  factory ExampleDto.fromJson(Map<String, dynamic> json) => _$ExampleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleDtoToJson(this);
}
```

### Case 1-1: 중첩 객체 — `explicitToJson: true`

DTO가 다른 DTO 타입의 필드(단일 객체 또는 `List<OtherDto>`)를 포함할 때 사용한다. `explicitToJson: true` 없이는 생성된 `toJson`이 `.toJson()`을 호출하는 대신 Dart 객체를 직접 할당하여 직렬화가 깨진다.

```dart
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RecordDto {
  final String id;
  @DateTimeConverter()
  final DateTime created;
  final List<RecordEntryDto> entries;

  const RecordDto({required this.id, required this.created, required this.entries});

  factory RecordDto.fromJson(Map<String, dynamic> json) => _$RecordDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RecordDtoToJson(this);
}
```

**`explicitToJson: true`를 추가해야 하는 경우:**
- DTO에 다른 DTO 클래스 타입의 필드가 있을 때 (예: `CommentDto comment`)
- DTO에 `List<OtherDto>` 필드가 있을 때 (예: `List<EntryDto> entries`)

**불필요한 경우:**
- 모든 필드가 기본 타입(`String`, `int`, `double`, `bool`)일 때
- `DateTime` 필드 (`@DateTimeConverter`가 처리하며, `toJson`과 무관)
- `List<String>`, `List<dynamic>`, `Map<String, dynamic>` (기본 타입)
- DTO가 `createToJson: false`를 사용할 때 (toJson 자체가 생성되지 않음)

### Case 2: 수동 toJson — `createToJson: false`

toJson에 커스텀 로직이 필요할 때 사용한다(예: 중첩 객체를 ID만 직렬화하거나 선택적 필드만 포함).

```dart
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class OrderDto {
  final String id;
  final UserDto user;
  @DateTimeConverter()
  final DateTime created;

  OrderDto({required this.id, required this.user, required this.created});

  factory OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user.id,
      'created': const DateTimeConverter().toJson(created),
    };
  }
}
```

### Case 3: fromJson만 사용 — `createToJson: false` (toJson 불필요)

다시 직렬화하지 않는 읽기 전용 DTO에 사용한다.

```dart
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class UpdateInfoDto {
  @JsonKey(fromJson: VersionDto.from)
  final VersionDto minimumRequiredVersion;

  UpdateInfoDto({required this.minimumRequiredVersion});

  factory UpdateInfoDto.fromJson(Map<String, dynamic> json) => _$UpdateInfoDtoFromJson(json);
}
```

### Case 4: fieldRename 없음 — JSON 키가 이미 Dart 필드명과 일치

```dart
@JsonSerializable()
class TermsLinkDto {
  final String name;
  final String url;

  TermsLinkDto({required this.name, required this.url});

  factory TermsLinkDto.fromJson(Map<String, dynamic> json) => _$TermsLinkDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TermsLinkDtoToJson(this);
}
```

## 어노테이션 참고표

| 어노테이션 | 사용 시점 |
|---|---|
| `fieldRename: FieldRename.snake` | 서버가 snake_case 키를 사용할 때 (대부분의 DTO) |
| `explicitToJson: true` | DTO에 중첩 DTO 필드가 있을 때 (단일 또는 List) — 올바른 toJson 직렬화에 필수 |
| `createToJson: false` | toJson이 수동이거나 불필요할 때 |
| `@DateTimeConverter()` | DateTime 필드 — UTC ↔ 로컬 자동 변환 |
| `@NullableDateTimeConverter()` | 널 가능 DateTime 필드 (`DateTime?`) |
| `@JsonKey(fromJson: ...)` | 특정 필드의 커스텀 역직렬화 |
| `@JsonKey(name: '...')` | 필드명이 snake_case 관례와 다를 때 |
| `@JsonKey(defaultValue: <T>[])` | JSON에서 누락될 수 있는 List 필드 |

## 마이그레이션 절차

1. DTO에 기존 `fromSqfData`/`toSqfData` 메서드가 있는지 확인한다(sqflite와 함께 사용되는지 여부).
2. import와 `part` 지시어를 추가한다:
   ```dart
   import 'package:json_annotation/json_annotation.dart';
   part 'dto_{name}.g.dart';
   ```
3. 클래스에 `@JsonSerializable(...)` 어노테이션을 추가한다 — 위 케이스에 맞는 옵션을 선택한다.
4. DTO에 다른 DTO 타입의 필드(단일 또는 `List<OtherDto>`)가 있으면 `explicitToJson: true`를 추가한다.
5. 수동 `fromJson` 본문을 `=> _${ClassName}FromJson(json);`으로 교체한다.
6. 수동 `toJson` 본문을 `=> _${ClassName}ToJson(this);`으로 교체한다 (Case 2의 경우 수동 유지).
7. 모든 `DateTime` 필드에 `@DateTimeConverter()`를, `DateTime?`에는 `@NullableDateTimeConverter()`를 추가한다.
8. 커스텀 역직렬화가 필요하거나 비표준 키명을 가진 필드에 `@JsonKey(...)`를 추가한다.
8. DTO가 sqflite와 함께 사용되는 경우: 아래 sqflite 섹션에 따라 `fromSqfData`/`toSqfData`를 마이그레이션한다.
9. 더 이상 사용하지 않는 `JsonMapper`/`SqfLiteMapper`/`TypeChange` import를 제거한다.
10. `dart run build_runner build --delete-conflicting-outputs`를 실행하여 `.g.dart`를 생성한다.
11. `dart analyze`를 실행하여 오류가 없는지 확인한다.

## sqflite 직렬화 규칙

API JSON과 sqflite는 스키마가 다르다(예: `isRead`, `isDeleted` 같은 클라이언트 전용 필드). 따라서 `fromJson`/`toJson`과 `fromSqfData`/`toSqfData`는 MUST 분리되어야 한다.

### MUST
- sqflite와 함께 사용되는 DTO(`sqflite_helper.dart`에 대응 테이블이 있는 경우)는 MUST `fromSqfData`와 `toSqfData` 메서드를 가져야 한다.
- sqflite와 함께 사용되지 않는 DTO는 MUST NOT `fromSqfData`/`toSqfData` 메서드를 가지지 않아야 한다.
- 마이그레이션 시 `lib/data/sqflite_helper.dart`를 참조하여 컬럼명, 타입, 널 가능성을 확인한다.

### sqflite 타입 변환 규칙

sqflite는 JSON API와 다르게 데이터를 저장한다. `fromSqfData`/`toSqfData`에 다음 변환을 적용한다:

| Dart 타입 | sqflite 컬럼 타입 | `fromSqfData` 변환 | `toSqfData` 변환 |
|---|---|---|---|
| `String` | `TEXT` | 직접 캐스트 | 직접 |
| `int` | `INTEGER` | 직접 캐스트 | 직접 |
| `double` | `REAL` | `.toDouble()` | 직접 |
| `bool` | `INTEGER` (0/1) | `data == 1` | `value ? 1 : 0` |
| `DateTime` | `TEXT` (ISO8601) | `DateTime.parse(data).toLocal()` | `.toUtc().toIso8601String()` |
| `DateTime?` | `TEXT` (nullable) | `data != null ? DateTime.parse(data).toLocal() : null` | `value?.toUtc().toIso8601String()` |
| `List` / `Map` | `TEXT` (JSON 인코딩) | `jsonDecode(data)` | `jsonEncode(value)` |
| `List<String>` | `TEXT` (JSON 인코딩) | `(jsonDecode(data) as List).cast<String>()` | `jsonEncode(value)` |

### 마이그레이션 패턴

#### 이전 (레거시)

```dart
factory ExampleDto.fromSqfData(Map<String, dynamic> data) {
  TypeChange tc = SqfLiteMapper();
  return ExampleDto(
    id: tc.toStrFromKey(data, 'id'),
    isRead: tc.toBoolFromKey(data, 'is_read'),
    created: tc.toDateTimeFromKey(data, 'created'),
    entries: tc.toListFromKey(data, 'entries'),
  );
}

Map<String, dynamic> toSqfData() {
  TypeChange tc = SqfLiteMapper();
  return {
    'id': tc.fromStr(id),
    'is_read': tc.fromBool(isRead),
    'created': tc.fromDateTime(created),
    'entries': tc.fromList(entries),
  };
}
```

#### 이후 (직접 변환, SqfLiteMapper 없음)

```dart
factory ExampleDto.fromSqfData(Map<String, dynamic> data) {
  return ExampleDto(
    id: data['id'] as String,
    isRead: data['is_read'] == 1,
    created: DateTime.parse(data['created'] as String).toLocal(),
    entries: jsonDecode(data['entries'] as String) as List<dynamic>,
  );
}

Map<String, dynamic> toSqfData() {
  return {
    'id': id,
    'is_read': isRead ? 1 : 0,
    'created': created.toUtc().toIso8601String(),
    'entries': jsonEncode(entries),
  };
}
```

### 전체 마이그레이션 후 불필요해지는 파일

모든 DTO가 마이그레이션되면 다음 레거시 파일을 제거할 수 있다:
- `lib/data/util/type_change.dart` — 추상 `TypeChange` 인터페이스
- `lib/data/util/mapper_json.dart` — `JsonMapper` 구현체
- `lib/data/util/mapper_sqf_lite.dart` — `SqfLiteMapper` 구현체
