---
name: create-subagents
description: Claude Code 서브에이전트를 생성, 빌드, 활용하는 전문 가이드. 서브에이전트 작업, 에이전트 설정, 에이전트 동작 원리 이해, Task 도구를 통한 전문 에이전트 실행 시 사용하세요.
---

<objective>
서브에이전트는 독립된 컨텍스트에서 집중된 역할과 제한된 도구 접근 권한을 가지고 실행되는 특수화된 Claude 인스턴스입니다. 이 스킬은 효과적인 서브에이전트를 만들고, 강력한 시스템 프롬프트를 작성하며, 도구 접근을 설정하고, Task 도구를 사용해 다중 에이전트 워크플로우를 조율하는 방법을 알려줍니다.

서브에이전트는 복잡한 작업을 사용자 상호작용 없이 자율적으로 수행하는 전문 에이전트에 위임하고, 최종 결과를 메인 대화로 반환할 수 있게 합니다.
</objective>

<quick_start>
<workflow>
1. `/agents` 명령 실행
2. "Create New Agent" 선택
3. 프로젝트 레벨(`.claude/agents/`) 또는 사용자 레벨(`~/.claude/agents/`) 선택
4. 서브에이전트 정의:
   - **name**: lowercase-with-hyphens
   - **description**: 이 서브에이전트는 언제 사용해야 하나요?
   - **tools**: 선택사항, 쉼표로 구분된 목록 (생략 시 모든 도구 상속)
   - **model**: 선택사항 (`sonnet`, `opus`, `haiku`, 또는 `inherit`)
5. 시스템 프롬프트 작성 (서브에이전트의 지침)
</workflow>

<example>
```markdown
---
name: code-reviewer
description: Expert code reviewer. Use proactively after code changes to review for quality, security, and best practices.
tools: Read, Grep, Glob, Bash
model: sonnet
---

<role>
You are a senior code reviewer focused on quality, security, and best practices.
</role>

<focus_areas>
- Code quality and maintainability
- Security vulnerabilities
- Performance issues
- Best practices adherence
</focus_areas>

<output_format>
Provide specific, actionable feedback with file:line references.
</output_format>
```
</example>
</quick_start>

<file_structure>
| 유형 | 위치 | 범위 | 우선순위 |
|------|----------|-------|----------|
| **프로젝트** | `.claude/agents/` | 현재 프로젝트만 | 가장 높음 |
| **사용자** | `~/.claude/agents/` | 모든 프로젝트 | 낮음 |
| **플러그인** | 플러그인의 `agents/` 디렉토리 | 모든 프로젝트 | 가장 낮음 |

이름이 충돌할 경우 프로젝트 레벨 서브에이전트가 사용자 레벨을 덮어씁니다.
</file_structure>

<configuration>
<field name="name">
- 소문자와 하이픈만 사용
- 고유해야 함
</field>

<field name="description">
- 목적을 자연어로 설명
- Claude가 이 서브에이전트를 호출해야 하는 시점 명시
- 자동 서브에이전트 선택에 사용됨
</field>

<field name="tools">
- 쉼표로 구분된 목록: `Read, Write, Edit, Bash, Grep`
- 생략 시: 메인 스레드의 모든 도구 상속
- 사용 가능한 모든 도구 목록은 `/agents` 인터페이스에서 확인
</field>

<field name="model">
- `sonnet`, `opus`, `haiku`, 또는 `inherit`
- `inherit`: 메인 대화와 동일한 모델 사용
- 생략 시: 설정된 서브에이전트 기본 모델로 동작 (보통 sonnet)
</field>
</configuration>

<execution_model>
<critical_constraint>
**서브에이전트는 사용자와 상호작용할 수 없는 블랙박스입니다.**

서브에이전트는 독립된 컨텍스트에서 실행되며 최종 결과를 메인 대화로 반환합니다. 서브에이전트는:
- ✅ Read, Write, Edit, Bash, Grep 같은 도구 사용 가능
- ✅ MCP 서버 및 기타 비대화형 도구 접근 가능
- ❌ **`AskUserQuestion` 또는 사용자 상호작용이 필요한 도구 사용 불가**
- ❌ **옵션 제시 또는 사용자 입력 대기 불가**
- ❌ **사용자는 서브에이전트의 중간 단계를 볼 수 없음**

메인 대화에서는 서브에이전트의 최종 리포트/결과만 보입니다.
</critical_constraint>

<workflow_design>
**서브에이전트를 사용한 워크플로우 설계:**

**메인 채팅** 사용 시:
- 사용자로부터 요구사항 수집 (AskUserQuestion)
- 사용자에게 옵션 또는 결정사항 제시
- 사용자 확인/입력이 필요한 모든 작업
- 진행 상황이 사용자에게 보여야 하는 작업

**서브에이전트** 사용 시:
- 리서치 작업 (API 문서 조회, 코드 분석)
- 사전 정의된 요구사항 기반 코드 생성
- 분석 및 리포팅 (보안 리뷰, 테스트 커버리지)
- 사용자 상호작용이 필요 없는 컨텍스트 집약적 작업

**워크플로우 패턴 예시:**
```
Main Chat: Ask user for requirements (AskUserQuestion)
  ↓
Subagent: Research API and create documentation (no user interaction)
  ↓
Main Chat: Review research with user, confirm approach
  ↓
Subagent: Generate code based on confirmed plan
  ↓
Main Chat: Present results, handle testing/deployment
```
</workflow_design>
</execution_model>

<system_prompt_guidelines>
<principle name="be_specific">
서브에이전트의 역할, 역량, 제약을 명확하게 정의하세요.
</principle>

<principle name="use_pure_xml_structure">
시스템 프롬프트를 순수 XML 태그로 구성하세요. 본문에서 마크다운 헤딩을 모두 제거하세요.

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: sonnet
---

<role>
You are a senior code reviewer specializing in security.
</role>

<focus_areas>
- SQL injection vulnerabilities
- XSS attack vectors
- Authentication/authorization issues
- Sensitive data exposure
</focus_areas>

<workflow>
1. Read the modified files
2. Identify security risks
3. Provide specific remediation steps
4. Rate severity (Critical/High/Medium/Low)
</workflow>
```
</principle>

<principle name="task_specific">
특정 작업 도메인에 맞게 지침을 조정하세요. 범용 "도우미" 서브에이전트는 만들지 마세요.

❌ 나쁜 예: "You are a helpful assistant that helps with code"
✅ 좋은 예: "You are a React component refactoring specialist. Analyze components for hooks best practices, performance anti-patterns, and accessibility issues."
</principle>
</system_prompt_guidelines>

<subagent_xml_structure>
서브에이전트 `.md` 파일은 Claude만이 소비하는 시스템 프롬프트입니다. 스킬 및 슬래시 명령어와 마찬가지로 최적의 파싱과 토큰 효율성을 위해 순수 XML 구조를 사용해야 합니다.

<recommended_tags>
서브에이전트 구조에 사용하는 공통 태그:

- `<role>` - 서브에이전트의 정체와 역할
- `<constraints>` - 강제 규칙 (NEVER/MUST/ALWAYS)
- `<focus_areas>` - 우선순위 항목
- `<workflow>` - 단계별 프로세스
- `<output_format>` - 결과물 구성 방식
- `<success_criteria>` - 완료 기준
- `<validation>` - 작업 검증 방법
</recommended_tags>

<intelligence_rules>
**단순 서브에이전트** (단일 집중 작업):
- role + constraints + workflow 최소 구성 사용
- 예시: code-reviewer, test-runner

**중간 서브에이전트** (다단계 프로세스):
- workflow 단계, output_format, success_criteria 추가
- 예시: api-researcher, documentation-generator

**복잡한 서브에이전트** (리서치 + 생성 + 검증):
- validation, examples 포함하여 필요에 따라 모든 태그 사용
- 예시: mcp-api-researcher, comprehensive-auditor
</intelligence_rules>

<critical_rule>
**서브에이전트 본문에서 마크다운 헤딩(##, ###)을 모두 제거하세요.** 대신 시맨틱 XML 태그를 사용하세요.

콘텐츠 내부의 마크다운 포맷(볼드, 이탤릭, 목록, 코드블록, 링크)은 유지하세요.

XML 구조 원칙과 토큰 효율성 세부 사항은 @skills/create-agent-skills/references/use-xml-tags.md를 참고하세요. 동일한 원칙이 서브에이전트에도 적용됩니다.
</critical_rule>
</subagent_xml_structure>

<invocation>
<automatic>
Claude는 현재 작업과 일치할 때 `description` 필드를 기반으로 자동으로 서브에이전트를 선택합니다.
</automatic>

<explicit>
서브에이전트를 명시적으로 호출할 수 있습니다:

```
> Use the code-reviewer subagent to check my recent changes
```

```
> Have the test-writer subagent create tests for the new API endpoints
```
</explicit>
</invocation>

<management>
<using_agents_command>
`/agents` 명령을 실행하면 대화형 인터페이스에서:
- 사용 가능한 모든 서브에이전트 확인
- 새 서브에이전트 생성
- 기존 서브에이전트 편집
- 커스텀 서브에이전트 삭제
</using_agents_command>

<manual_editing>
서브에이전트 파일을 직접 편집할 수도 있습니다:
- 프로젝트: `.claude/agents/subagent-name.md`
- 사용자: `~/.claude/agents/subagent-name.md`
</manual_editing>
</management>

<reference>
**핵심 참고자료**:

**서브에이전트 사용 및 설정**: [references/subagents.md](references/subagents.md)
- 파일 형식과 설정
- 모델 선택 (Sonnet 4.5 + Haiku 4.5 오케스트레이션)
- 도구 보안과 최소 권한 원칙
- 프롬프트 캐싱 최적화
- 전체 예시

**효과적인 프롬프트 작성**: [references/writing-subagent-prompts.md](references/writing-subagent-prompts.md)
- 핵심 원칙과 XML 구조
- 라우팅을 위한 description 필드 최적화
- 복잡한 추론을 위한 extended thinking
- 보안 제약과 강력한 규범 동사
- 성공 기준 정의

**고급 주제**:

**평가 및 테스트**: [references/evaluation-and-testing.md](references/evaluation-and-testing.md)
- 평가 지표 (작업 완료, 도구 정확성, 견고성)
- 테스트 전략 (오프라인, 시뮬레이션, 온라인 모니터링)
- 평가 주도 개발
- 커스텀 기준을 위한 G-Eval

**오류 처리 및 복구**: [references/error-handling-and-recovery.md](references/error-handling-and-recovery.md)
- 일반적인 실패 모드와 원인
- 복구 전략 (우아한 저하, 재시도, 서킷 브레이커)
- 구조화된 커뮤니케이션과 관찰 가능성
- 피해야 할 안티패턴

**컨텍스트 관리**: [references/context-management.md](references/context-management.md)
- 메모리 아키텍처 (STM, LTM, 작업 메모리)
- 컨텍스트 전략 (요약, 슬라이딩 윈도우, 스크래치패드)
- 장기 실행 작업 관리
- 프롬프트 캐싱 상호작용

**오케스트레이션 패턴**: [references/orchestration-patterns.md](references/orchestration-patterns.md)
- 순차, 병렬, 계층, 코디네이터 패턴
- 비용/성능을 위한 Sonnet + Haiku 오케스트레이션
- 다중 에이전트 조율
- 패턴 선택 가이드

**디버깅 및 트러블슈팅**: [references/debugging-agents.md](references/debugging-agents.md)
- 로깅, 트레이싱, 상관관계 ID
- 일반적인 실패 유형 (환각, 형식 오류, 도구 오용)
- 진단 절차
- 지속적인 모니터링
</reference>

<success_criteria>
잘 설정된 서브에이전트의 조건:

- 유효한 YAML 프론트매터 (name이 파일명과 일치, description에 트리거 포함)
- 시스템 프롬프트에 명확한 역할 정의
- 적절한 도구 제한 (최소 권한)
- role, approach, constraints가 포함된 XML 구조 시스템 프롬프트
- 자동 라우팅에 최적화된 description 필드
- 대표적인 작업에서 성공적으로 테스트됨
- 작업 복잡도에 맞는 모델 선택 (추론에는 Sonnet, 단순 작업에는 Haiku)
</success_criteria>
