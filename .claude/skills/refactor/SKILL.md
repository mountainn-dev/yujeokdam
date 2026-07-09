---
name: refactor
description: 코드 스멜 감지, 계획 수립, 단계적 실행을 통한 동작 보존형 구조적 코드 리팩터링. 트리거 문구 - "/refactor", "refactor this", "clean up code"
---

# 리팩터링 스킬

외부 동작을 변경하지 않고 코드 구조를 개선한다. 코드 스멜을 감지하고, 점진적 변경을 계획하고, 사용자 승인 후 실행한다.

## 사용 시점

- 새 기능을 추가하기 전 ("변경하기 쉽게 만들고, 그 다음 쉽게 변경하라")
- 테스트를 통과시킨 후 (Red-Green-Refactor 사이클)
- 코드 리뷰 피드백에서 구조 개선을 요청할 때
- 사용자가 `/refactor` 또는 "정리" / "리팩터링"을 요청할 때

## 리팩터링하지 않을 시점

- 코드를 보호하는 테스트 커버리지가 없을 때
- 코드가 교체 또는 삭제될 예정일 때
- 코드의 목적을 아직 파악하지 못했을 때 — 먼저 읽고 이해하라
- 코드 동결 기간이 활성 상태일 때

## 리팩터링 프로토콜

### 1단계: 평가

대상 코드를 전체적으로 읽는다. 아래 카탈로그를 사용해 코드 스멜을 식별한다. 의존성을 파악한다(이 코드를 호출하는 곳, 이 코드가 호출하는 곳). 영향과 위험도에 따라 우선순위를 부여한다.

결과를 스멜 보고서 형태로 사용자에게 제시한다:

```markdown
## Smell Report: {file or scope}

| # | Smell | Location | Severity | Suggested Technique |
|---|-------|----------|----------|---------------------|
| 1 | {smell name} | {file:line} | High/Medium/Low | {technique name} |
```

### 2단계: 계획

순서가 있는 리팩터링 단계 시퀀스를 제안한다. 각 단계는 독립적으로 검증 가능한 하나의 원자적 변경이다.

```markdown
## Refactoring Plan

1. {technique}: {what changes and why} → {file:line range}
2. {technique}: {what changes and why} → {file:line range}
...

Estimated scope: {N} files, {N} methods affected
```

진행 전에 사용자 승인을 기다린다. 사용자는 모든 단계를 승인하거나, 특정 단계만 선택하거나, 계획 변경을 요청할 수 있다.

### 3단계: 실행

승인된 단계를 하나씩 적용한다. 각 단계 후:
- 변경이 외부 동작을 보존하는지 확인한다
- 코드가 컴파일되거나 정적 분석을 통과하는지 확인한다
- 현재 단계가 안정적인 후에만 다음 단계로 이동한다

## 코드 스멜 카탈로그

### 구조 스멜

| 스멜 | 감지 방법 | 기법 |
|-------|-----------|-----------|
| **Long Method** | 메서드가 약 20줄을 초과하거나 읽기 위해 스크롤이 필요할 때 | Extract Method |
| **Deep Nesting** | if/else/for 중첩이 3단계 이상일 때 | Guard Clause + Early Return |
| **God Class** | 하나의 클래스가 너무 많은 책임을 가질 때 | Extract Class |
| **Long Parameter List** | 메서드 파라미터가 4개를 초과할 때 | Introduce Parameter Object |
| **Shotgun Surgery** | 하나의 변경이 여러 파일에 분산된 수정을 필요로 할 때 | Move/Inline to co-locate related logic |

### 중복 스멜

| 스멜 | 감지 방법 | 기법 |
|-------|-----------|-----------|
| **Duplicated Logic** | 동일하거나 유사한 로직이 3곳 이상 반복될 때 | Extract Method 또는 공유 추상화 |
| **Parallel Hierarchies** | 한 계층에 클래스를 추가하면 다른 계층에도 클래스를 추가해야 할 때 | Merge or delegate |

### 추상화 스멜

| 스멜 | 감지 방법 | 기법 |
|-------|-----------|-----------|
| **Primitive Obsession** | 도메인 개념을 raw `String`/`int`/`bool`로 표현할 때 | Introduce Value Object |
| **Feature Envy** | 메서드가 자신의 데이터보다 다른 클래스의 데이터를 더 많이 사용할 때 | Move Method to data owner |
| **Inappropriate Intimacy** | 클래스들이 서로의 내부 구현에 의존할 때 | Extract Interface or invert dependency |
| **Conditional Complexity** | 타입이나 enum에 따라 반복적으로 분기하는 switch/if-else 체인이 있을 때 | Replace Conditional with Polymorphism |

### 위생 스멜

| 스멜 | 감지 방법 | 기법 |
|-------|-----------|-----------|
| **Dead Code** | 사용하지 않는 변수, 메서드, import, 또는 도달 불가능한 분기 | Remove Dead Code |
| **Magic Numbers/Strings** | 의미가 불분명한 하드코딩된 리터럴 | Extract Constant |
| **Speculative Generality** | 아직 아무것도 사용하지 않는 추상화, 훅, 또는 파라미터 | Inline or Remove |

## 리팩터링 기법 참고

### Extract Method
응집력 있는 코드 블록을 찾는다. 의도를 설명하는 이름의 새 메서드로 이동한다. 원래 블록을 새 메서드 호출로 교체한다.

### Inline Method
메서드 본문이 이름만큼 명확할 때, 모든 호출을 본문으로 교체하고 메서드를 제거한다.

### Extract Variable
복잡한 표현식을 설명적인 이름의 지역 변수에 할당한다. 주석 없이도 의도를 읽을 수 있게 만든다.

### Rename
변수, 메서드, 또는 클래스 이름을 의도를 드러내도록 변경한다. 모든 사용처에 일관되게 적용한다.

### Move Method / Move Field
메서드나 필드를 해당 데이터를 소유하는 클래스로 이동한다. Feature Envy를 줄인다.

### Extract Class
여러 책임을 가진 클래스를 각각 단일 집중 책임을 가진 둘 이상의 클래스로 분리한다.

### Introduce Parameter Object
함께 이동하는 파라미터들을 전용 객체로 묶는다. 파라미터 수를 줄이고 관련 로직의 위치를 만든다.

### Replace Conditional with Polymorphism
타입 확인 switch/if-else 체인을 인터페이스와 구체 구현체로 교체한다. 각 분기가 하나의 클래스가 된다.

### Guard Clause
전제 조건 검사를 메서드 상단으로 이동하고 early return한다. 중첩을 평탄화하고 주요 경로를 부각시킨다.

### Compose Method
메서드 본문이 동일한 추상화 수준의 호출 시퀀스로 읽히도록 재구성한다. 각 호출은 잘 명명된 private 메서드다.

## 안전한 리팩터링 원칙

### MUST
- 외부에서 관찰 가능한 동작을 보존한다. 리팩터링 중에는 기능 변경을 하지 않는다.
- 단계마다 하나의 기법만 적용한다. 각 단계는 독립적으로 검증 가능하다.
- 각 변경은 독립적으로 검증할 수 있는 최소 단위로 유지한다.
- 변경을 실행하기 전에 계획에 대한 사용자 승인을 기다린다.
- 요청된 대상으로 범위를 제한한다. 관련 없는 코드는 리팩터링하지 않는다.
- 어느 단계든 독립적으로 롤백할 수 있도록 커밋을 세분화한다.

### MUST NOT
- 리팩터링과 기능 변경 또는 버그 수정을 같은 단계에 결합하지 않는다.
- 테스트 커버리지가 없는 코드를 사용자에게 위험을 알리지 않고 리팩터링하지 않는다.
- 일회성 동작에 새로운 추상화를 도입하지 않는다 (이는 Speculative Generality다).
- 모든 호출처가 업데이트되었음을 확인하지 않고 공개 API를 이름 변경하지 않는다.
- 전체 코드베이스에서 미사용을 확인하지 않고 사용되지 않는 것처럼 보이는 코드를 삭제하지 않는다.
- 현재 단계에서 컴파일 오류나 테스트 실패가 발생하면 다음 단계로 진행하지 않는다.
