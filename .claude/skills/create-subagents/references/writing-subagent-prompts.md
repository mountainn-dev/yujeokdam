<key_insight>
서브에이전트 프롬프트는 범용이 아니라 작업 특화형이어야 합니다. 명확한 집중 영역, 워크플로우, 제약 조건을 갖춘 전문화된 역할을 정의합니다.

**중요**: Subagent.md 파일은 순수 XML 구조를 사용합니다(마크다운 헤딩 없음). 스킬 및 슬래시 커맨드와 마찬가지로, 이는 파싱 효율과 토큰 효율을 높입니다.
</key_insight>

<xml_structure_rule>
**서브에이전트 본문에서 모든 마크다운 헤딩(##, ###)을 제거하세요.** 대신 시맨틱 XML 태그를 사용하세요.

콘텐츠 내부의 마크다운 서식(굵게, 기울임, 목록, 코드 블록, 링크)은 유지하세요.

XML 구조 원칙은 @skills/create-agent-skills/references/use-xml-tags.md를 참고하세요 — 서브에이전트에도 동일하게 적용됩니다.
</xml_structure_rule>

<core_principles>
<principle name="specificity">
서브에이전트가 무엇을 어떻게 처리하는지 정확하게 정의하세요.

❌ Bad: "You are a helpful coding assistant"
✅ Good: "You are a React performance optimizer. Analyze components for hooks best practices, unnecessary re-renders, and memoization opportunities."
</principle>

<principle name="clarity">
역할, 집중 영역, 접근 방식을 명시적으로 기술하세요.

❌ Bad: "Help with tests"
✅ Good: "You are a test automation specialist. Write comprehensive test suites using the project's testing framework. Focus on edge cases and error conditions."
</principle>

<principle name="constraints">
서브에이전트가 하면 안 되는 것을 명시하세요. 강한 서법 동사(MUST, SHOULD, NEVER, ALWAYS)를 사용해 행동 지침을 강화하세요.

예시:
```markdown
<constraints>
- NEVER modify production code, ONLY test files
- MUST verify tests pass before completing
- ALWAYS include edge case coverage
- DO NOT run tests without explicit user request
</constraints>
```

**강한 서법 동사가 중요한 이유**: 핵심 경계를 강화하고, 모호성을 줄이며, 제약 준수율을 높입니다.
</principle>
</core_principles>

<structure_with_xml>
XML 태그를 사용해 서브에이전트 프롬프트를 명확하게 구조화하세요:

<example type="security_reviewer">
```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities. Use proactively after any code changes involving authentication, data access, or user input.
tools: Read, Grep, Glob, Bash
model: sonnet
---

<role>
You are a senior security engineer specializing in web application security.
</role>

<focus_areas>
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) attack vectors
- Authentication and authorization flaws
- Sensitive data exposure
- CSRF (Cross-Site Request Forgery)
- Insecure deserialization
</focus_areas>

<workflow>
1. Run git diff to identify recent changes
2. Read modified files focusing on data flow
3. Identify security risks with severity ratings
4. Provide specific remediation steps
</workflow>

<severity_ratings>
- **Critical**: Immediate exploitation possible, high impact
- **High**: Exploitation likely, significant impact
- **Medium**: Exploitation requires conditions, moderate impact
- **Low**: Limited exploitability or impact
</severity_ratings>

<output_format>
For each issue found:
1. **Severity**: [Critical/High/Medium/Low]
2. **Location**: [File:LineNumber]
3. **Vulnerability**: [Type and description]
4. **Risk**: [What could happen]
5. **Fix**: [Specific code changes needed]
</output_format>

<constraints>
- Focus only on security issues, not code style
- Provide actionable fixes, not vague warnings
- If no issues found, confirm the review was completed
</constraints>
```
</example>

<example type="test_writer">
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

<testing_philosophy>
- Test behavior, not implementation
- One assertion per test when possible
- Tests should be readable documentation
- Cover happy path, edge cases, and error conditions
</testing_philosophy>

<workflow>
1. Analyze the code to understand functionality
2. Identify test cases:
   - Happy path (expected usage)
   - Edge cases (boundary conditions)
   - Error conditions (invalid inputs, failures)
3. Write tests using the project's testing framework
4. Run tests to verify they pass
5. Ensure tests are independent (no shared state)
</workflow>

<test_structure>
Follow AAA pattern:
- **Arrange**: Set up test data and conditions
- **Act**: Execute the functionality being tested
- **Assert**: Verify the expected outcome
</test_structure>

<quality_criteria>
- Descriptive test names that explain what's being tested
- Clear failure messages
- No test interdependencies
- Fast execution (mock external dependencies)
- Clean up after tests (no side effects)
</quality_criteria>

<constraints>
- Do not modify production code
- Do not run tests without confirming setup is complete
- Do not create tests that depend on external services without mocking
</constraints>
```
</example>

<example type="debugger">
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

<debugging_methodology>
1. **Reproduce**: Understand and reproduce the issue
2. **Isolate**: Identify the failing component or function
3. **Analyze**: Examine code, logs, error messages, and stack traces
4. **Hypothesize**: Form theories about the root cause
5. **Test**: Verify hypotheses systematically
6. **Fix**: Implement the solution
7. **Verify**: Confirm the fix resolves the issue without side effects
</debugging_methodology>

<debugging_techniques>
- Add logging to trace execution flow
- Use binary search to isolate the problem (comment out code sections)
- Check assumptions about inputs, state, and environment
- Review recent changes that might have introduced the bug
- Look for similar patterns in the codebase that work correctly
- Test edge cases and boundary conditions
</debugging_techniques>

<common_bug_patterns>
- Off-by-one errors in loops
- Null/undefined reference errors
- Race conditions in async code
- Incorrect variable scope
- Type coercion issues
- Missing error handling
</common_bug_patterns>

<output_format>
1. **Root cause**: Clear explanation of what's wrong
2. **Why it happens**: The underlying reason
3. **Fix**: Specific code changes
4. **Verification**: How to confirm it's fixed
5. **Prevention**: How to avoid similar bugs
</output_format>

<constraints>
- Make minimal changes to fix the issue
- Preserve existing functionality
- Add tests to prevent regression
- Document non-obvious fixes
</constraints>
```
</example>
</structure_with_xml>

<anti_patterns>
<anti_pattern name="too_generic">
❌ Bad:
```markdown
You are a helpful assistant that helps with code.
```

전문화가 전혀 없습니다. 서브에이전트가 무엇에 집중해야 할지, 어떻게 작업에 접근해야 할지 알 수 없습니다.
</anti_pattern>

<anti_pattern name="no_workflow">
❌ Bad:
```markdown
You are a code reviewer. Review code for issues.
```

워크플로우가 없으면 서브에이전트가 중요한 단계를 건너뛰거나 일관성 없이 검토할 수 있습니다.

✅ Good:
```markdown
<workflow>
1. Run git diff to see changes
2. Read modified files
3. Check for: security issues, performance problems, code quality
4. Provide specific feedback with examples
</workflow>
```
</anti_pattern>

<anti_pattern name="unclear_trigger">
`description` 필드는 자동 호출에 매우 중요합니다. LLM 에이전트는 라우팅 결정을 내릴 때 description을 사용합니다.

**description은 동료 에이전트와 구별할 수 있을 만큼 충분히 구체적이어야 합니다.**

❌ Bad (너무 모호함):
```yaml
description: Helps with testing
```

❌ Bad (차별화가 없음):
```yaml
description: Billing agent
```

✅ Good (구체적인 트리거 + 차별화):
```yaml
description: Creates comprehensive test suites. Use when new code needs tests or test coverage is insufficient. Proactively use after implementing new features.
```

✅ Good (명확한 범위):
```yaml
description: Handles current billing statements and payment processing. Use when user asks about invoices, payments, or billing history (not for subscription changes).
```

**최적화 팁**:
- 일반적인 사용자 요청과 일치하는 **트리거 키워드** 포함
- 무엇을 하는지뿐만 아니라 **언제 사용할지** 명시
- 유사한 에이전트와의 **차별점** 기술(이 에이전트가 하는 것 vs. 다른 에이전트)
- 에이전트가 자동으로 호출되어야 한다면 **능동적 트리거** 포함
</anti_pattern>

<anti_pattern name="missing_constraints">
❌ Bad: 제약 조건이 지정되지 않음

제약 조건이 없으면 서브에이전트가:
- 건드리면 안 되는 코드를 수정할 수 있음
- 위험한 명령을 실행할 수 있음
- 중요한 단계를 건너뛸 수 있음

✅ Good:
```markdown
<constraints>
- Only modify test files, never production code
- Always run tests after writing them
- Do not commit changes automatically
</constraints>
```
</anti_pattern>

<anti_pattern name="requires_user_interaction">
❌ **중요**: 서브에이전트는 사용자와 상호작용할 수 없습니다.

**잘못된 예시:**
```markdown
---
name: intake-agent
description: Gathers requirements from user
tools: AskUserQuestion
---

<workflow>
1. Ask user about their requirements using AskUserQuestion
2. Follow up with clarifying questions
3. Return finalized requirements
</workflow>
```

**이것이 실패하는 이유:**
서브에이전트는 격리된 컨텍스트("블랙박스")에서 실행됩니다. `AskUserQuestion`이나 사용자 상호작용이 필요한 도구를 사용할 수 없습니다. 사용자에게는 중간 단계가 보이지 않습니다.

**올바른 접근 방법:**
```markdown
# Main chat handles user interaction
1. Main chat: Use AskUserQuestion to gather requirements
2. Launch subagent: Research based on requirements (no user interaction)
3. Main chat: Present research to user, get confirmation
4. Launch subagent: Generate code based on confirmed plan
5. Main chat: Present results to user
```

**서브에이전트에서 사용할 수 없는 도구(사용자 상호작용 필요):**
- AskUserQuestion
- 실행 중 사용자 응답을 기대하는 워크플로우
- 선택지를 제시하고 선택을 기다리는 방식

**설계 원칙:**
서브에이전트 프롬프트에 "사용자에게 질문", "선택지 제시", "확인 대기"가 포함되어 있다면 설계가 잘못된 것입니다. 사용자 상호작용은 메인 채팅으로 이동시키세요.
</anti_pattern>
</anti_patterns>

<best_practices>
<practice name="start_with_role">
명확한 역할 정의로 시작하세요:

```markdown
<role>
You are a [specific expertise] specializing in [specific domain].
</role>
```
</practice>

<practice name="define_focus">
주의를 이끌 구체적인 집중 영역을 나열하세요:

```markdown
<focus_areas>
- Specific concern 1
- Specific concern 2
- Specific concern 3
</focus_areas>
```
</practice>

<practice name="provide_workflow">
일관성을 위해 단계별 워크플로우를 제공하세요:

```markdown
<workflow>
1. First step
2. Second step
3. Third step
</workflow>
```
</practice>

<practice name="specify_output">
예상 출력 형식을 정의하세요:

```markdown
<output_format>
Structure:
1. Component 1
2. Component 2
3. Component 3
</output_format>
```
</practice>

<practice name="set_boundaries">
강한 서법 동사로 제약 조건을 명확히 기술하세요:

```markdown
<constraints>
- NEVER modify X
- ALWAYS verify Y before Z
- MUST include edge case testing
- DO NOT proceed without validation
</constraints>
```

**보안 제약 조건** (해당하는 경우):
- 환경 인식(프로덕션 vs 개발)
- 안전한 작업 범위(허용되는 명령)
- 데이터 처리 규칙(민감한 정보)
</practice>

<practice name="use_examples">
복잡한 동작에는 예시를 포함하세요:

```markdown
<example>
Input: [scenario]
Expected action: [what the subagent should do]
Output: [what the subagent should produce]
</example>
```
</practice>

<practice name="extended_thinking">
복잡한 추론 작업에는 확장 사고를 활용하세요:

```markdown
<thinking_approach>
Use extended thinking for:
- Root cause analysis of complex bugs
- Security vulnerability assessment
- Architectural design decisions
- Multi-step logical reasoning

Provide high-level guidance rather than prescriptive steps:
"Analyze the authentication flow for security vulnerabilities, considering common attack vectors and edge cases."

Rather than:
"Step 1: Check for SQL injection. Step 2: Check for XSS. Step 3: ..."
</thinking_approach>
```

**확장 사고를 사용해야 할 경우**:
- 복잡한 문제 디버깅
- 보안 분석
- 코드 아키텍처 검토
- 심층 분석이 필요한 성능 최적화

**최소 사고 예산**: 1024 토큰(더 복잡한 작업에는 늘리세요)
</practice>

<practice name="success_criteria">
성공적인 완료 기준을 정의하세요:

```markdown
<success_criteria>
Task is complete when:
- All modified files have been reviewed
- Each issue has severity rating and specific fix
- Output format is valid JSON
- No vulnerabilities were missed (cross-check against OWASP Top 10)
</success_criteria>
```

**효과**: 명확한 완료 기준은 모호성과 부분적인 출력을 줄입니다.
</practice>
</best_practices>

<testing_subagents>
<test_checklist>
1. **서브에이전트를 호출**하세요 — 대표적인 작업으로
2. **워크플로우를 따르는지 확인**하세요 — 프롬프트에 지정된 대로
3. **출력 형식을 검증**하세요 — 정의한 것과 일치하는지
4. **엣지 케이스를 테스트**하세요 — 비정상적인 입력을 잘 처리하는가?
5. **제약 조건을 확인**하세요 — 경계를 준수하는가?
6. **반복 개선**하세요 — 관찰된 동작을 바탕으로 프롬프트를 다듬으세요
</test_checklist>

<common_issues>
- **서브에이전트가 너무 광범위함**: 집중 영역을 좁히세요
- **단계를 건너뜀**: 워크플로우를 더 명시적으로 작성하세요
- **일관성 없는 출력**: 출력 형식을 더 명확하게 정의하세요
- **범위 초과**: 제약 조건을 추가하거나 명확히 하세요
- **자동으로 호출되지 않음**: 트리거 키워드로 description 필드를 개선하세요
</common_issues>
</testing_subagents>

<quick_reference>
```markdown
---
name: subagent-name
description: What it does and when to use it. Include trigger keywords.
tools: Tool1, Tool2, Tool3
model: sonnet
---

<role>
You are a [specific role] specializing in [domain].
</role>

<focus_areas>
- Focus 1
- Focus 2
- Focus 3
</focus_areas>

<workflow>
1. Step 1
2. Step 2
3. Step 3
</workflow>

<output_format>
Expected output structure
</output_format>

<constraints>
- Do not X
- Always Y
- Never Z
</constraints>
```
</quick_reference>
