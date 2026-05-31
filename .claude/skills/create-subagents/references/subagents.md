<file_format>
서브에이전트 파일 구조:

```markdown
---
name: your-subagent-name
description: Description of when this subagent should be invoked
tools: tool1, tool2, tool3 # Optional - inherits all tools if omitted
model: sonnet # Optional - specify model alias or 'inherit'
---

<role>
Your subagent's system prompt using pure XML structure. This defines the subagent's role, capabilities, and approach.
</role>

<constraints>
Hard rules using NEVER/MUST/ALWAYS for critical boundaries.
</constraints>

<workflow>
Step-by-step process for consistency.
</workflow>
```

**중요**: 본문에는 순수 XML 구조를 사용하세요. 마크다운 헤딩(##, ###)을 모두 제거하세요. 콘텐츠 내부의 마크다운 포맷(볼드, 목록, 코드블록)은 유지하세요.

<configuration_fields>
| 필드 | 필수 여부 | 설명 |
|-------|----------|-------------|
| `name` | 예 | 소문자와 하이픈을 사용한 고유 식별자 |
| `description` | 예 | 목적을 자연어로 설명. Claude가 이 서브에이전트를 호출해야 하는 시점 포함 |
| `tools` | 아니오 | 쉼표로 구분된 목록. 생략 시 메인 스레드의 모든 도구 상속 |
| `model` | 아니오 | `sonnet`, `opus`, `haiku`, 또는 `inherit`. 생략 시 기본 서브에이전트 모델 사용 |
</configuration_fields>
</file_format>

<storage_locations>
| 유형 | 위치 | 범위 | 우선순위 |
|------|----------|-------|----------|
| **프로젝트** | `.claude/agents/` | 현재 프로젝트만 | 가장 높음 |
| **사용자** | `~/.claude/agents/` | 모든 프로젝트 | 낮음 |
| **CLI** | `--agents` 플래그 | 현재 세션 | 중간 |
| **플러그인** | 플러그인의 `agents/` 디렉토리 | 모든 프로젝트 | 가장 낮음 |

서브에이전트 이름이 충돌할 경우 우선순위가 높은 쪽이 적용됩니다.
</storage_locations>

<execution_model>
<black_box_model>
서브에이전트는 사용자 상호작용 없이 독립된 컨텍스트에서 실행됩니다.

**주요 특성:**
- 서브에이전트는 메인 채팅으로부터 입력 파라미터를 받음
- 서브에이전트는 사용 가능한 도구를 사용하여 자율적으로 실행
- 서브에이전트는 최종 결과/리포트를 메인 채팅으로 반환
- 사용자는 최종 결과만 볼 수 있으며 중간 단계는 보이지 않음

**이것이 의미하는 바:**
- ✅ 서브에이전트는 Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch 사용 가능
- ✅ 서브에이전트는 MCP 서버 (비대화형 도구) 접근 가능
- ✅ 서브에이전트는 프롬프트와 사용 가능한 데이터를 기반으로 결정 가능
- ❌ **서브에이전트는 `AskUserQuestion` 사용 불가**
- ❌ **서브에이전트는 옵션 제시 후 사용자 선택 대기 불가**
- ❌ **서브에이전트는 사용자에게 확인 또는 설명 요청 불가**
- ❌ **사용자는 서브에이전트의 도구 호출이나 중간 추론 과정을 볼 수 없음**
</black_box_model>

<workflow_implications>
**서브에이전트 워크플로우 설계 시:**

사용자 상호작용은 메인 채팅에서 유지하세요:
```markdown
# ❌ WRONG - Subagent cannot do this
---
name: requirement-gatherer
description: Gathers requirements from user
tools: AskUserQuestion  # This won't work!
---

You ask the user questions to gather requirements...
```

```markdown
# ✅ CORRECT - Main chat handles interaction
Main chat: Uses AskUserQuestion to gather requirements
  ↓
Launch subagent: Uses requirements to research/build (no interaction)
  ↓
Main chat: Present subagent results to user
```
</workflow_implications>
</execution_model>

<tool_configuration>
<inherit_all_tools>
`tools` 필드를 생략하면 메인 스레드의 모든 도구를 상속합니다:

```yaml
---
name: code-reviewer
description: Reviews code for quality and security
---
```

서브에이전트는 MCP 도구를 포함한 모든 도구에 접근할 수 있습니다.
</inherit_all_tools>

<specific_tools>
세밀한 제어를 위해 쉼표로 구분된 도구 목록을 지정하세요:

```yaml
---
name: read-only-analyzer
description: Analyzes code without making changes
tools: Read, Grep, Glob
---
```

사용 가능한 전체 도구 목록은 `/agents` 명령으로 확인하세요.
</specific_tools>
</tool_configuration>

<model_selection>
<model_capabilities>
**Sonnet 4.5** (`sonnet`):
- "에이전트를 위한 세계 최고의 모델" (Anthropic)
- 에이전트 작업에 탁월: 코딩 벤치마크에서 64% 문제 해결
- SWE-bench Verified: 49.0%
- **사용 시점**: 계획, 복잡한 추론, 검증, 중요 결정

**Haiku 4.5** (`haiku`):
- "준-프런티어 성능" - Sonnet 4.5 역량의 90%
- SWE-bench Verified: 73.3% (세계 최고 수준의 코딩 모델 중 하나)
- 가장 빠르고 비용 효율적
- **사용 시점**: 작업 실행, 단순 변환, 대량 처리

**Opus** (`opus`):
- 평가 벤치마크에서 최고 성능
- 가장 유능하지만 가장 느리고 비용이 높음
- **사용 시점**: 가장 중요한 결정, 가장 복잡한 추론

**Inherit** (`inherit`):
- 메인 대화와 동일한 모델 사용
- **사용 시점**: 세션 전체에서 일관된 역량 유지
</model_capabilities>

<orchestration_strategy>
**Sonnet + Haiku 오케스트레이션 패턴** (최적 비용/성능):

```markdown
1. Sonnet 4.5 (코디네이터):
   - 계획 수립
   - 작업을 서브태스크로 분리
   - 병렬화 가능한 작업 파악

2. Multiple Haiku 4.5 instances (워커):
   - 서브태스크를 병렬로 실행
   - 빠르고 비용 효율적
   - 실행 시 Sonnet 역량의 90%

3. Sonnet 4.5 (검증자):
   - 결과 통합
   - 출력 품질 검증
   - 일관성 보장
```

**장점**: 계획 및 검증에만 비싼 Sonnet을 사용하고, 실행에는 저렴한 Haiku를 사용합니다.
</orchestration_strategy>

<decision_framework>
**각 모델을 사용해야 하는 경우**:

| 작업 유형 | 권장 모델 | 이유 |
|-----------|------------------|-----------|
| 단순 검증 | Haiku | 빠르고, 저렴하고, 충분한 역량 |
| 코드 실행 | Haiku | 73.3% SWE-bench, 매우 빠름 |
| 복잡한 분석 | Sonnet | 우수한 추론, 비용 가치 있음 |
| 다단계 계획 | Sonnet | 복잡성 분해에 최적 |
| 품질 검증 | Sonnet | 중요 체크포인트, 지능 필요 |
| 배치 처리 | Haiku | 대용량을 위한 비용 효율성 |
| 중요 보안 | Sonnet | 높은 위험도에는 최상의 모델 필요 |
| 출력 종합 | Sonnet | 입력 전반의 일관성 보장 |
</decision_framework>
</model_selection>

<invocation>
<automatic>
Claude는 다음을 기반으로 서브에이전트를 자동으로 선택합니다:
- 사용자 요청의 작업 설명
- 서브에이전트 설정의 `description` 필드
- 현재 컨텍스트
</automatic>

<explicit>
사용자가 서브에이전트를 명시적으로 요청할 수 있습니다:

```
> Use the code-reviewer subagent to check my recent changes
> Have the test-runner subagent fix the failing tests
```
</explicit>
</invocation>

<management>
<using_agents_command>
**권장**: 대화형 관리를 위해 `/agents` 명령 사용:
- 사용 가능한 모든 서브에이전트 확인 (내장, 사용자, 프로젝트, 플러그인)
- 가이드 설정으로 새 서브에이전트 생성
- 기존 서브에이전트 및 도구 접근 편집
- 커스텀 서브에이전트 삭제
- 이름 충돌 시 어떤 서브에이전트가 우선순위를 갖는지 확인
</using_agents_command>

<direct_file_management>
**대안**: 서브에이전트 파일을 직접 편집:
- 프로젝트: `.claude/agents/subagent-name.md`
- 사용자: `~/.claude/agents/subagent-name.md`

위에서 명시한 파일 형식을 따르세요 (YAML 프론트매터 + 시스템 프롬프트).
</direct_file_management>

<cli_based_configuration>
**임시**: 세션별 사용을 위해 CLI로 서브에이전트 정의:

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

설정을 저장하기 전에 테스트할 때 유용합니다.
</cli_based_configuration>
</management>

<example_subagents>
<test_writer>
```markdown
---
name: test-writer
description: Creates comprehensive test suites. Use when new code needs tests or test coverage is insufficient.
tools: Read, Write, Grep, Glob, Bash
model: sonnet
---

<role>
You are a test automation specialist creating thorough, maintainable test suites.
</role>

<workflow>
1. Analyze the code to understand functionality
2. Identify test cases (happy path, edge cases, error conditions)
3. Write tests using the project's testing framework
4. Run tests to verify they pass
</workflow>

<test_quality_criteria>
- Test one behavior per test
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Include edge cases and error conditions
- Avoid test interdependencies
</test_quality_criteria>
```
</test_writer>

<debugger>
```markdown
---
name: debugger
description: Investigates and fixes bugs. Use when errors occur or behavior is unexpected.
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
---

<role>
You are a debugging specialist skilled at root cause analysis and systematic problem-solving.
</role>

<workflow>
1. **Reproduce**: Understand and reproduce the issue
2. **Isolate**: Identify the failing component
3. **Analyze**: Examine code, logs, and stack traces
4. **Hypothesize**: Form theories about the cause
5. **Test**: Verify hypotheses systematically
6. **Fix**: Implement and verify the solution
</workflow>

<debugging_techniques>
- Add logging/print statements to trace execution
- Use binary search to isolate the problem
- Check assumptions (inputs, state, environment)
- Review recent changes that might have introduced the bug
- Verify fix doesn't break other functionality
</debugging_techniques>
```
</debugger>
</example_subagents>

<tool_security>
<core_principle>
**"권한 남용은 불안전한 자율성으로 가는 가장 빠른 길입니다."** - Anthropic

도구 접근을 프로덕션 IAM처럼 다루세요: 전체 거부에서 시작하여 필요한 것만 허용 목록에 추가하세요.
</core_principle>

<why_it_matters>
**과도한 권한 부여의 보안 위험**:
- 에이전트가 잘못된 코드를 수정할 수 있음 (테스트 대신 프로덕션)
- 에이전트가 위험한 명령을 실행할 수 있음 (rm -rf, 데이터 삭제)
- 에이전트가 보호된 정보를 노출할 수 있음
- 에이전트가 중요한 단계를 건너뛸 수 있음 (린팅, 테스트, 검증)

**취약점 예시**:
```markdown
❌ Bad: Agent drafting sales email has full access to all tools
Risk: Could access revenue dashboard data, customer financial info

✅ Good: Agent drafting sales email has Read access to Salesforce only
Scope: Can draft email, cannot access sensitive financial data
```
</why_it_matters>

<permission_patterns>
**신뢰 수준별 도구 접근 패턴**:

**신뢰할 수 있는 데이터 처리**:
- 전체 도구 접근 적합
- 사용자 자신의 코드 작업
- 예시: 사용자 코드베이스 리팩토링

**신뢰할 수 없는 데이터 처리**:
- 제한된 도구 접근 필수
- 외부 입력 처리
- 예시: 서드파티 API 응답 분석
- 제한: 읽기 전용 도구, 실행 불가
</permission_patterns>

<audit_checklist>
**도구 접근 감사**:
- [ ] 이 서브에이전트에 Write/Edit이 필요한가, 아니면 Read로 충분한가?
- [ ] 코드를 실행(Bash)해야 하는가, 아니면 분석만 하면 되는가?
- [ ] 부여된 모든 도구가 작업에 필요한가?
- [ ] 최악의 오용 시나리오는 무엇인가?
- [ ] 합법적인 사용을 막지 않으면서 더 제한할 수 있는가?

**기본 원칙**: 최소한으로 부여하세요. 접근 부재가 작업을 막을 때만 도구를 추가하세요.
</audit_checklist>
</tool_security>

<prompt_caching>
<benefits>
자주 호출되는 서브에이전트의 프롬프트 캐싱:
- 캐시된 토큰에서 **90% 비용 절감**
- 캐시 히트 시 **85% 지연 감소**
- 캐시된 콘텐츠: 미캐시 토큰 비용의 약 10%
- 캐시 TTL: 5분 (기본) 또는 1시간 (확장)
</benefits>

<cache_structure>
**캐싱을 위한 프롬프트 구조화**:

```markdown
---
name: security-reviewer
description: ...
tools: ...
model: sonnet
---

[CACHEABLE SECTION - Stable content]
<role>
You are a senior security engineer...
</role>

<focus_areas>
- SQL injection
- XSS attacks
...
</focus_areas>

<workflow>
1. Read modified files
2. Identify risks
...
</workflow>

<severity_ratings>
...
</severity_ratings>

--- [CACHE BREAKPOINT] ---

[VARIABLE SECTION - Task-specific content]
Current task: {dynamic context}
Recent changes: {varies per invocation}
```

**원칙**: 안정적인 지침은 앞에 (캐시됨), 변동 컨텍스트는 뒤에 (새로 처리됨).
</cache_structure>

<when_to_use>
**캐싱에 가장 적합한 경우**:
- 자주 호출되는 서브에이전트 (세션당 여러 번)
- 크고 안정적인 프롬프트 (광범위한 가이드라인, 예시)
- 호출 간 일관된 도구 정의
- 서브에이전트를 반복 사용하는 장기 세션

**효과 없는 경우**:
- 거의 사용되지 않는 서브에이전트 (세션당 한 번)
- 자주 변경되는 프롬프트
- 매우 짧은 프롬프트 (캐싱 오버헤드 > 이점)
</when_to_use>

<cache_management>
**캐시 생명주기**:
- 첫 번째 호출: 캐시에 쓰기 (25% 비용 추가)
- 이후 호출: 캐시된 부분에서 90% 저렴
- 사용 시마다 캐시 갱신 (TTL 연장)
- 5분 미사용 시 만료 (또는 확장 TTL의 경우 1시간)

**무효화 트리거**:
- 서브에이전트 프롬프트 수정됨
- 도구 정의 변경됨
- 캐시 TTL 만료
</cache_management>
</prompt_caching>

<best_practices>
<be_specific>
범용 도우미가 아닌 작업별 전문 서브에이전트를 만드세요.

❌ 나쁜 예: "You are a helpful assistant"
✅ 좋은 예: "You are a React performance optimizer specializing in hooks and memoization"
</be_specific>

<clear_triggers>
`description`에 언제 호출할지 명확히 하세요:

❌ 나쁜 예: "Helps with code"
✅ 좋은 예: "Reviews code for security vulnerabilities. Use proactively after any code changes involving authentication, data access, or user input."
</clear_triggers>

<focused_tools>
작업에 필요한 도구만 부여하세요 (최소 권한):

- 읽기 전용 분석: `Read, Grep, Glob`
- 코드 수정: `Read, Edit, Bash, Grep`
- 테스트 실행: `Read, Write, Bash`

**보안 참고**: 과도한 권한 부여가 주요 위험 요소입니다. 최소로 시작하고 필요할 때만 추가하세요.
</focused_tools>

<structured_prompts>
명확성을 위해 XML 태그로 시스템 프롬프트를 구성하세요:

```markdown
<role>
You are a senior security engineer specializing in web application security.
</role>

<focus_areas>
- SQL injection
- XSS attacks
- CSRF vulnerabilities
- Authentication/authorization flaws
</focus_areas>

<workflow>
1. Analyze code changes
2. Identify security risks
3. Provide specific remediation
4. Rate severity
</workflow>
```
</structured_prompts>
</best_practices>
