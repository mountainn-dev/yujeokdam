---
name: flutter-building-layouts
description: Flutter 제약 시스템과 레이아웃 위젯을 사용해 UI 구조를 설계·구현하는 가이드. Flutter 애플리케이션의 UI 구조를 새로 만들거나 다듬을 때 적용합니다.
---

# Flutter 레이아웃 설계

Flutter 의 제약 전달 시스템을 기반으로 `Scaffold` 하위 UI 트리를 설계·구현하기 위한 가이드.

## 목차

- [핵심 레이아웃 원칙](#핵심-레이아웃-원칙)
- [구조 위젯 선택](#구조-위젯-선택)
- [반응형·적응형 설계](#반응형적응형-설계)
- [복잡한 레이아웃 구현 워크플로](#복잡한-레이아웃-구현-워크플로)
- [예제](#예제)

## 핵심 레이아웃 원칙

Flutter 의 기본 레이아웃 규칙: **"제약은 아래로, 크기는 위로, 위치는 부모가 결정한다."**

### MUST

- 부모 위젯이 자식에게 제약(최소·최대 `width`/`height`) 을 내려보낸다. 자식은 부모 제약과 독립적으로 자기 크기를 고를 수 없다.
- 자식은 받은 제약 안에서 원하는 크기를 계산해 부모에게 되돌려 올린다.
- 자식의 화면 좌표(`x`, `y`) 는 부모 위젯이 지정한다. 자식은 자신의 화면 위치를 모른다.

### MUST NOT

- `Row` / `Column` 의 주축과 교차하는 축, 그리고 `ListView` 같은 스크롤 영역 내부에서 무제한 제약(`double.infinity`) 을 전달하지 않는다. 렌더 예외가 발생한다.

## 구조 위젯 선택

공간 배치 요구에 맞는 구조 위젯을 선택한다.

### MUST

- **수평 1차원 배치**: `Row`. 자식 정렬은 `mainAxisAlignment`, `crossAxisAlignment` 로 제어한다.
- **수직 1차원 배치**: `Column`. 정렬 제어는 `Row` 와 동일한 속성.
- **남은 공간을 강제로 차지해야 할 때**: `Row` / `Column` 의 자식을 `Expanded` 로 감싼다.
- **남은 공간까지만 확장 허용**: 자식을 `Flexible` 로 감싼다 (자식이 자기 크기를 먼저 정하고, 필요하면 남은 공간까지 확장).
- **`padding`, `margin`, `border`, 배경색** 적용: 자식을 `Container` 로 감싼다.
- **Z 축 겹침**: `Stack` 을 사용하고 자식을 `Positioned` 로 가장자리에 앵커링한다.
- **정확한 고정 크기**: 자식을 `SizedBox(width: ..., height: ...)` 로 감싸 타이트 제약을 적용한다.

## 반응형·적응형 설계

화면 크기·폼팩터 변화 대응은 두 전략으로 분리한다.

### MUST

- **반응형(Responsive) — 사용 가능한 공간에 UI 가 맞춰지는 경우**: `LayoutBuilder` 와 `Expanded` / `Flexible` 로 부모 제약에 따라 요소 크기·배치를 동적으로 조정한다.
- **적응형(Adaptive) — 폼팩터별로 UI 사용성을 바꿔야 하는 경우**: 조건 분기로 레이아웃 구조 자체를 교체한다. 예: 모바일은 하단 내비게이션 바, 태블릿·데스크톱은 사이드 내비게이션 레일.

## 복잡한 레이아웃 구현 워크플로

복잡한 화면은 네 단계를 순차적으로 거쳐 구현한다.

1. **Phase 1 — 시각 해체**
   - 목표 UI 를 `Row`, `Column`, 그리드 계층으로 분해.
   - 겹치는 요소 식별 (`Stack` 필요 지점).
   - 스크롤 영역 식별 (`ListView` 또는 `SingleChildScrollView` 필요 지점).
2. **Phase 2 — 제약 계획**
   - 타이트 제약(고정 크기) 이 필요한 위젯과 루즈 제약(유연 크기) 이 필요한 위젯을 구분.
   - 무제한 제약 위험 지점 식별 (예: `Column` 내부의 `ListView`).
3. **Phase 3 — 구현**
   - 바깥에서 안쪽으로 빌드. `Scaffold` 와 주요 구조 위젯부터 시작.
   - 깊게 중첩된 레이아웃 섹션은 별도 `StatelessWidget` 으로 추출해 가독성을 유지한다.
4. **Phase 4 — 검증과 피드백 루프**
   - 타깃 디바이스·시뮬레이터에서 실행.
   - Flutter Inspector 를 열고 "Debug Paint" 로 렌더 박스를 시각화.
   - 노란·검정 줄무늬 오버플로 경고를 점검.
   - 오버플로 발생 시: 오버플로 위젯을 `Expanded` 로 감싸거나(플렉스 박스 내부일 때), 부모를 스크롤 가능한 위젯으로 감싼다.

## 예제

### 예제 1 — 플렉스 박스 무제한 제약 해결

**Anti-pattern**: `Column` 내부에 `ListView` 를 그대로 두면 `Column` 이 `ListView` 에 무한 수직 공간을 주므로 unbounded height 예외 발생.

```dart
Column(
  children: [
    Text('Header'),
    ListView(
      children: [/* items */],
    ),
  ],
)
```

**수정**: `ListView` 를 `Expanded` 로 감싸 `Column` 의 남은 공간에 맞춘다.

```dart
Column(
  children: [
    Text('Header'),
    Expanded(
      child: ListView(
        children: [/* items */],
      ),
    ),
  ],
)
```

### 예제 2 — `LayoutBuilder` 로 반응형 레이아웃

`LayoutBuilder` 로 가용 너비에 따라 구조 위젯을 조건부로 교체한다.

```dart
Widget buildAdaptiveLayout(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return Row(
          children: [
            SizedBox(width: 250, child: SidebarWidget()),
            Expanded(child: MainContentWidget()),
          ],
        );
      } else {
        return Column(
          children: [
            Expanded(child: MainContentWidget()),
            BottomNavigationBarWidget(),
          ],
        );
      }
    },
  );
}
```

## 참조 파일

- [View Layer 가이드](../view-layer/SKILL.md)
