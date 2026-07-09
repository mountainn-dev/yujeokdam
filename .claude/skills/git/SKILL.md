---
name: git
description: Git 커밋 메시지·브랜치 전략 규칙 — 프로젝트의 `type[sub]: description` 포맷과 브랜치 네이밍을 강제하고 AI 자동 생성 문구를 차단한다. 트리거 구문 - "/git", "commit message", "커밋 메시지", "커밋해줘", "브랜치 전략"
---

# Git Commit Rules

## Commit Message Format

### MUST
- Write commit messages with title only, or title + body when necessary
- Title format: `type[sub]: description`
  - **`sub` 는 항상 `snake_case`** 인 feature/모듈 이름이다. 예: `sign_in`, `home`, `profile`, `settings`, `search`.
  - `feat[sub]`: new feature
  - `fix[sub]`: bug fix. **UI 나 기능에 영향이 있는 변경**, 그리고 **소규모 구조 변경(단일 함수 추출·메서드 분리·단일 파일 정리 등)** 도 여기로 분류
  - `design[sub]`: UI layout changes
  - `refactor[sub]`: **구조 변경 전용**. UI 와 기능에 전혀 영향이 없을 때만 사용하고, 여러 파일에 걸친 책임 재분배·레이어 이동 같은 큰 단위 변경에 한정. 한 함수 추출·메서드 분리 같은 소규모 변경은 `fix` 로 분류
  - `chore[sub]`: miscellaneous tasks
  - `style`, `comment`, `rename`, `docs`, etc.
- 예시:
  - `feat[sign_in]: 약관 동의 단계 추가`
  - `fix[home]: 목록 정렬 순서 수정`
  - `refactor[profile]: 위임 사슬 정리`

### MUST NOT
- Do NOT include auto-generated phrases in commit messages:
  - No `🤖 Generated with [Claude Code]`
  - No `Co-Authored-By: Claude`
  - No other AI/auto-generation related phrases
- Do NOT add unnecessary body content (write title only unless explicitly requested)
- **`sub` 를 카멜 케이스로 작성하지 않는다.** `feat[signIn]`, `fix[userProfile]` 같은 표기 금지 — 항상 `snake_case` (`sign_in`, `user_profile`).

## 브랜치 전략

### MUST
- 브랜치는 다음 전략을 따른다.
  - `main`: 프로덕션 릴리스
  - `develop`: 다가오는 기능 통합
  - `feature/*`: 새 기능
  - `bugfix/*`: 버그 수정
  - `refactor/*`: 리팩터링
  - `hotfix/vX.X.X`: 긴급 수정
  - `release/vX.X.X`: 릴리스 준비

### MUST NOT
- 기능 개발을 `main` 에 직접 커밋하지 않는다.

## 이슈 넘버 연계

### MUST
- 사용자가 작업과 함께 이슈 넘버를 알려준 경우, **커밋 메시지 title 끝에 `(#number)` 형태로 부착**한다.
- 위치는 description 의 가장 마지막. 그 뒤에 다른 텍스트를 두지 않는다.
- 예시:
  - `fix[home]: 목록 매핑 버그 픽스 (#246)`
  - `feat[sign_in]: 약관 동의 단계 추가 (#312)`

### MUST NOT
- 사용자가 이슈 넘버를 명시하지 않은 경우 임의로 추정해 붙이지 않는다.
- `#246` 만 적거나 `[#246]`, `(이슈 246)` 같은 변형 표기를 쓰지 않는다 — 항상 `(#number)`.

## Humanizer 연계

### MUST
- 한국어 description 작성 시 `humanizer` 스킬을 항상 적용한다 — AI 작문 패턴(쉼표 과다, 명사 과다, AI 유행어, 영어식 구문 등)을 제거하고 자연스러운 한국어로 다듬은 뒤 커밋한다.
- body 를 작성하는 경우(사용자가 명시적으로 요청한 경우)에도 동일하게 `humanizer` 를 적용한다.

### MUST NOT
- `humanizer` 적용을 생략하지 않는다 — 짧은 한 줄 description 이라도 예외 없이 적용한다.
