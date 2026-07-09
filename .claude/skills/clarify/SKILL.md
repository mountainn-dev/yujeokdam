---
name: clarify
description: 가설 기반 질문을 통해 모호하거나 불분명한 요구사항을 명확하고 실행 가능한 명세로 변환합니다. 트리거 문구 - "/clarify", "clarify requirements", "what do I mean by..."
---

# 모호한 요구사항 명확화

가설 기반 질문을 통해 모호하거나 불분명한 요구사항을 명확하고 실행 가능한 명세로 변환합니다. **항상 AskUserQuestion 도구를 사용할 것** — 일반 텍스트로 명확화 질문을 던지지 않는다.

## 사용 시점

- 모호한 기능 요청 ("로그인 기능을 추가해줘")
- 불완전한 버그 리포트 ("내보내기가 안 돼")
- 명세가 불충분한 작업 ("앱을 더 빠르게 만들어줘")

전략/계획의 사각지대 분석은 `unknown/SKILL.md`를 참고. 내용 vs 형식 재구성은 `metamedium/SKILL.md`를 참고.

## 핵심 원칙: 가설로서의 선택지

개방형 질문 대신 그럴듯한 해석을 선택지로 제시한다. 각 선택지는 사용자가 실제로 의도하는 바에 대한 검증 가능한 가설이다.

```
나쁜 예:  "어떤 종류의 로그인을 원하세요?"           ← 개방형 질문, 인지 부하 높음
좋은 예: "OAuth / 이메일+비밀번호 / SSO / Magic link" ← 하나를 선택, 부하 낮음
```

## 프로세스

### 1단계: 수집 및 진단

원본 요구사항을 그대로 기록한다. 모호한 부분을 파악한다:
- 무엇이 불분명하거나 명세가 부족한가?
- 어떤 가정이 필요한가?
- 어떤 결정이 해석에 맡겨져 있는가?

### 2단계: 반복적 명확화

AskUserQuestion을 사용하여 모호한 부분을 해소한다. **한 번의 호출에 관련 질문을 최대 4개까지 묶는다.** 각 선택지는 사용자의 의도에 대한 가설이다.

**최대 5~8개 질문.** 모든 핵심 모호성이 해소되거나, 사용자가 "충분하다"고 하거나, 한도에 도달하면 중단한다.

**AskUserQuestion 호출 예시:**
```
questions:
  - question: "Which authentication method should the login use?"
    header: "Auth method"
    options:
      - label: "Email + Password"
        description: "Traditional signup with email verification"
      - label: "OAuth (Google/GitHub)"
        description: "Delegated auth, no password management needed"
      - label: "Magic link"
        description: "Passwordless email-based login"
    multiSelect: false
  - question: "What should happen after registration?"
    header: "Post-signup"
    options:
      - label: "Immediate access"
        description: "User can use the app right away"
      - label: "Email verification first"
        description: "Must confirm email before access"
    multiSelect: false
```

### 3단계: 변환 전/후 요약

변환 결과를 다음과 같이 제시한다:

```markdown
## 요구사항 명확화 요약

### 변환 전 (원본)
"{원본 요청 그대로}"

### 변환 후 (명확화)
**목표**: [정확한 설명]
**범위**: [포함된 것과 제외된 것]
**제약**: [제한 사항, 선호 사항]
**완료 기준**: [언제 완료되었는지 판단하는 방법]

**결정된 사항**:
| 질문 | 결정 |
|----------|----------|
| [모호성 1] | [선택된 선택지] |
```

### 4단계: 저장 옵션

명확화된 요구사항을 파일로 저장할지 묻는다. 기본 위치: `requirements/` 또는 프로젝트에 맞는 디렉토리.

## 모호성 분류

| 분류 | 가설 예시 |
|----------|-------------------|
| **범위** | 모든 사용자 / 관리자만 / 특정 역할 |
| **동작** | 조용히 실패 / 에러 표시 / 자동 재시도 |
| **인터페이스** | REST API / GraphQL / CLI |
| **데이터** | JSON / CSV / 모두 |
| **제약** | <100ms / <1s / 없음 |
| **우선순위** | 필수 / 있으면 좋음 / 향후 |

## 규칙

1. **가설, 개방형 질문 아님**: 모든 선택지는 그럴듯한 해석이어야 한다
2. **가정하지 않기**: 가정하지 말고 질문하라
3. **의도 보존**: 방향을 바꾸지 말고 정제하라
4. **최대 5~8개 질문**: 그 이상은 피로를 유발한다
5. **관련 질문 묶기**: AskUserQuestion 호출당 최대 4개
6. **변화 추적**: 항상 전/후를 보여주기
