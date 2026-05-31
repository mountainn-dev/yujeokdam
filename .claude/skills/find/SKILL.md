---
name: find
description: 사용자가 "X를 어떻게 하나요", "X용 스킬 찾아줘", "X를 할 수 있는 스킬이 있나요" 같은 질문을 하거나 기능 확장에 관심을 표현할 때 도움을 줍니다. 설치 가능한 스킬로 존재할 수 있는 기능을 사용자가 찾고 있을 때 이 스킬을 사용합니다.
---

# Find Skills

이 스킬은 오픈 에이전트 스킬 생태계에서 스킬을 검색하고 설치하는 데 도움을 줍니다.

## 사용 시점

다음과 같은 경우에 이 스킬을 사용합니다:

- 사용자가 "X를 어떻게 하나요"라고 물을 때 (X가 기존 스킬이 있는 일반적인 작업일 수 있음)
- "X용 스킬 찾아줘" 또는 "X용 스킬이 있나요"라고 말할 때
- "X를 할 수 있나요"라고 물을 때 (X가 특수한 기능인 경우)
- 에이전트 기능 확장에 관심을 표현할 때
- 도구, 템플릿, 워크플로를 검색하고 싶을 때
- 특정 도메인(디자인, 테스팅, 배포 등)에서 도움이 필요하다고 언급할 때

## Skills CLI란?

Skills CLI(`npx skills`)는 오픈 에이전트 스킬 생태계의 패키지 매니저입니다. 스킬은 전문 지식, 워크플로, 도구를 통해 에이전트 기능을 확장하는 모듈식 패키지입니다.

**주요 명령어:**

- `npx skills find [query]` - 대화형으로 또는 키워드로 스킬 검색
- `npx skills add <package>` - GitHub 또는 다른 소스에서 스킬 설치
- `npx skills check` - 스킬 업데이트 확인
- `npx skills update` - 설치된 모든 스킬 업데이트

**스킬 탐색:** https://skills.sh/

## 사용자가 스킬을 찾도록 돕는 방법

### 1단계: 필요 사항 파악

사용자가 도움을 요청할 때 다음을 파악합니다:

1. 도메인 (예: React, 테스팅, 디자인, 배포)
2. 구체적인 작업 (예: 테스트 작성, 애니메이션 생성, PR 검토)
3. 스킬이 존재할 만큼 충분히 일반적인 작업인지 여부

### 2단계: 리더보드 먼저 확인

CLI 검색을 실행하기 전에 [skills.sh 리더보드](https://skills.sh/)를 확인하여 해당 도메인에 이미 잘 알려진 스킬이 있는지 확인합니다. 리더보드는 총 설치 수 기준으로 스킬을 순위 매겨 가장 인기 있고 검증된 옵션을 보여줍니다.

예를 들어, 웹 개발 분야의 상위 스킬은 다음과 같습니다:
- `vercel-labs/agent-skills` — React, Next.js, 웹 디자인 (각 100K+ 설치)
- `anthropics/skills` — 프론트엔드 디자인, 문서 처리 (100K+ 설치)

### 3단계: 스킬 검색

리더보드에서 사용자의 필요를 충족하는 항목이 없다면 검색 명령어를 실행합니다:

```bash
npx skills find [query]
```

예시:

- 사용자가 "React 앱을 빠르게 만들려면 어떻게 하나요?" → `npx skills find react performance`
- 사용자가 "PR 검토에 도움받을 수 있나요?" → `npx skills find pr review`
- 사용자가 "변경 로그를 만들어야 해요" → `npx skills find changelog`

### 4단계: 추천 전 품질 검증

**검색 결과만을 기반으로 스킬을 추천하지 않습니다.** 항상 다음을 확인합니다:

1. **설치 수** — 1K+ 설치된 스킬을 선호함. 100 미만은 주의할 것.
2. **소스 신뢰도** — 공식 소스(`vercel-labs`, `anthropics`, `microsoft`)가 알 수 없는 저자보다 신뢰할 수 있음.
3. **GitHub 스타** — 소스 저장소를 확인함. 스타 수가 100 미만인 저장소의 스킬은 신중하게 판단할 것.

### 5단계: 사용자에게 옵션 제시

관련 스킬을 찾은 경우 다음 정보와 함께 제시합니다:

1. 스킬 이름과 기능 설명
2. 설치 수와 소스
3. 사용자가 실행할 수 있는 설치 명령어
4. skills.sh의 자세한 정보 링크

예시 응답:

```
도움이 될 만한 스킬을 찾았습니다! "react-best-practices" 스킬은
Vercel Engineering의 React 및 Next.js 성능 최적화 가이드라인을 제공합니다.
(185K 설치)

설치하려면:
npx skills add vercel-labs/agent-skills@react-best-practices

자세히 보기: https://skills.sh/vercel-labs/agent-skills/react-best-practices
```

### 6단계: 설치 제안

사용자가 진행을 원하면 직접 스킬을 설치할 수 있습니다:

```bash
npx skills add <owner/repo@skill> -g -y
```

`-g` 플래그는 전역(사용자 레벨)으로 설치하고, `-y`는 확인 프롬프트를 건너뜁니다.

## 일반 스킬 카테고리

검색할 때 다음과 같은 일반적인 카테고리를 고려합니다:

| 카테고리 | 예시 쿼리 |
| --------------- | ---------------------------------------- |
| 웹 개발 | react, nextjs, typescript, css, tailwind |
| 테스팅 | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| 문서화 | docs, readme, changelog, api-docs |
| 코드 품질 | review, lint, refactor, best-practices |
| 디자인 | ui, ux, design-system, accessibility |
| 생산성 | workflow, automation, git |

## 효과적인 검색 팁

1. **구체적인 키워드 사용**: "react testing"이 단순한 "testing"보다 나음
2. **대체 용어 시도**: "deploy"가 안 되면 "deployment" 또는 "ci-cd" 시도
3. **인기 소스 확인**: 많은 스킬이 `vercel-labs/agent-skills` 또는 `ComposioHQ/awesome-claude-skills`에서 제공됨

## 스킬을 찾을 수 없는 경우

관련 스킬이 없으면:

1. 기존 스킬이 없음을 인정함
2. 일반적인 기능으로 작업을 직접 도와주겠다고 제안함
3. `npx skills init`으로 직접 스킬을 만들 수 있다고 안내함

예시:

```
"xyz"와 관련된 스킬을 검색했지만 일치하는 항목을 찾지 못했습니다.
이 작업은 직접 도와드릴 수 있습니다! 진행할까요?

자주 하는 작업이라면 직접 스킬을 만들 수 있습니다:
npx skills init my-xyz-skill
```
