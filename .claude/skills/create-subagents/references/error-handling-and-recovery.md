# 서브에이전트를 위한 오류 처리 및 복구

<common_failure_modes>


업계 조사에서 식별된 실패 패턴들입니다.

<specification_problems>
**실패의 32%**: 서브에이전트가 무엇을 해야 할지 모릅니다.

**원인**:
- 모호하거나 불완전한 역할 정의
- 누락된 워크플로우 단계
- 불명확한 성공 기준
- 애매한 제약 조건

**증상**: 서브에이전트가 명확화 질문을 하거나 (서브에이전트는 이를 할 수 없음), 잘못된 가정을 하거나, 부분적인 출력을 생성하거나, 작업을 완료하지 못합니다.

**예방**: 프롬프트에 명시적인 `<role>`, `<workflow>`, `<focus_areas>`, `<output_format>` 섹션을 포함하세요.
</specification_problems>

<inter_agent_misalignment>
**실패의 28%**: 멀티 에이전트 워크플로우에서의 조정 실패.

**원인**:
- 서브에이전트들이 충돌하는 목표를 가짐
- 핸드오프 지점이 불명확
- 공유 컨텍스트나 상태가 없음
- 다른 에이전트의 출력에 대한 가정

**증상**: 중복 작업, 상충하는 출력, 무한 루프, 작업이 누락됨.

**예방**: 명확한 오케스트레이션 패턴 ([orchestration-patterns.md](orchestration-patterns.md) 참조), 명시적인 핸드오프 프로토콜.
</inter_agent_misalignment>

<verification_gaps>
**실패의 24%**: 품질을 검사하는 주체가 없습니다.

**원인**:
- 워크플로우에 검증 단계 없음
- 출력 형식 명세 누락
- 오류 감지 로직 없음
- 서브에이전트 출력에 대한 맹목적 신뢰

**증상**: 잘못된 결과가 조용히 전파되고, 환각(hallucination)이 감지되지 않으며, 형식 오류가 하위 프로세스를 중단시킵니다.

**예방**: 서브에이전트 워크플로우에 검증 단계를 포함하고, 사용 전 출력을 검증하며, 평가자 에이전트를 구현하세요.
</verification_gaps>

<error_cascading>
**중요 패턴**: 하나의 서브에이전트에서 발생한 실패가 다른 에이전트들로 전파됩니다.

**원인**:
- 하위 에이전트에 오류 처리 없음
- 상위 출력이 유효하다는 가정
- 서킷 브레이커나 폴백 없음

**증상**: 단일 실패가 전체 워크플로우 실패를 야기합니다.

**예방**: 서브에이전트 프롬프트에 방어적 프로그래밍 적용, 우아한 성능 저하(graceful degradation) 전략, 경계에서의 검증.
</error_cascading>

<non_determinism>
**내재적 과제**: 동일한 프롬프트가 서로 다른 출력을 생성할 수 있습니다.

**원인**:
- LLM 샘플링 및 온도 설정
- API 지연 시간 변동
- 컨텍스트 창 순서 효과

**증상**: 호출 간 일관성 없는 동작, 테스트가 때로는 통과하고 때로는 실패합니다.

**완화**: 일관성이 중요한 작업에는 낮은 온도 사용, 변동 패턴을 파악하기 위한 종합적인 테스트, 견고한 검증.
</non_determinism>
</common_failure_modes>

<recovery_strategies>


<graceful_degradation>
**패턴**: 이상적인 경로가 실패하더라도 워크플로우가 유용한 결과를 생성합니다.

<example>
```markdown
<workflow>
1. Attempt to fetch latest API documentation from web
2. If fetch fails, use cached documentation (flag as potentially outdated)
3. If no cache available, use local stub documentation (flag as incomplete)
4. Generate code with best available information
5. Add TODO comments indicating what should be verified
</workflow>

<fallback_hierarchy>
- Primary: Live API docs (most accurate)
- Secondary: Cached docs (may be stale, flag date)
- Tertiary: Stub docs (minimal, flag as incomplete)
- Always: Add verification TODOs to generated code
</fallback_hierarchy>
```

**핵심 원칙**: 부분적인 성공이 완전한 실패보다 낫습니다. 항상 유용한 결과를 생성하세요.
</example>
</graceful_degradation>

<autonomous_retry>
**패턴**: 서브에이전트가 지수 백오프(exponential backoff)로 실패한 작업을 재시도합니다.

<example>
```markdown
<error_handling>
When a tool call fails:
1. Attempt operation
2. If fails, wait 1 second and retry
3. If fails again, wait 2 seconds and retry
4. If fails third time, proceed with fallback approach
5. Document the failure in output

Maximum 3 retry attempts before falling back.
</error_handling>
```

**사용 사례**: 일시적 실패 (네트워크 문제, 임시 파일 잠금, 속도 제한).

**안티 패턴**: 백오프나 최대 시도 횟수 없이 무한 재시도.
</example>
</autonomous_retry>

<circuit_breakers>
**패턴**: 실패하는 컴포넌트에 대한 호출을 중단하여 연쇄 실패를 방지합니다.

<conceptual_example>
```markdown
<circuit_breaker_logic>
If API endpoint has failed 5 consecutive times:
- Stop calling the endpoint (circuit "open")
- Use fallback data source
- After 5 minutes, attempt one call (circuit "half-open")
- If succeeds, resume normal calls (circuit "closed")
- If fails, keep circuit open for another 5 minutes
</circuit_breaker_logic>
```

**서브에이전트 적용**: 서브에이전트가 외부 API나 서비스를 호출할 때 프롬프트에 포함하세요.

**장점**: 실패하는 것으로 알려진 작업에 시간/토큰을 낭비하는 것을 방지합니다.
</conceptual_example>
</circuit_breakers>

<timeouts>
**패턴**: 응답이 없는 에이전트가 워크플로우를 무기한 차단해서는 안 됩니다.

<implementation>
```markdown
<timeout_handling>
For long-running operations:
1. Set reasonable timeout (e.g., 2 minutes for analysis)
2. If operation exceeds timeout:
   - Abort operation
   - Provide partial results if available
   - Clearly flag as incomplete
   - Suggest manual intervention
</timeout_handling>
```

**참고**: Claude Code에는 도구 호출에 대한 내장 타임아웃이 있습니다. 서브에이전트 프롬프트에는 합리적인 시간 제한에 가까워졌을 때 무엇을 해야 하는지에 대한 지침을 포함해야 합니다.
</implementation>
</timeouts>

<multiple_verification_paths>
**패턴**: 서로 다른 검증자가 서로 다른 유형의 오류를 포착합니다.

<example>
```markdown
<verification_strategy>
After generating code:
1. Syntax check: Parse code to verify valid syntax
2. Type check: Run static type checker (if applicable)
3. Linting: Check for common issues and anti-patterns
4. Security scan: Check for obvious vulnerabilities
5. Test run: Execute tests if available

If any check fails, fix issue and re-run all checks.
Each check catches different error types.
</verification_strategy>
```

**장점**: 계층화된 검증이 단일 검증 패스보다 더 많은 문제를 포착합니다.
</example>
</multiple_verification_paths>

<reassigning_tasks>
**패턴**: 기본 접근 방식이 실패할 때 대체 에이전트를 호출하거나 사람에게 에스컬레이션합니다.

<example>
```markdown
<escalation_workflow>
If automated fix fails after 2 attempts:
1. Document what was tried and why it failed
2. Provide diagnosis of the problem
3. Recommend human review with specific questions to investigate
4. DO NOT continue attempting automated fixes that aren't working

Know when to escalate rather than thrashing.
</escalation_workflow>
```

**핵심 인사이트**: 서브에이전트는 자신의 한계를 인식하고 유용한 핸드오프 정보를 제공해야 합니다.
</example>
</reassigning_tasks>
</recovery_strategies>

<structured_communication>


멀티 에이전트 시스템은 통신이 모호할 때 실패합니다. 구조화된 메시지 방식이 오해를 방지합니다.

<message_types>
에이전트 간 (또는 에이전트에서 사용자로의) 모든 메시지는 명시적인 유형을 가져야 합니다.

**요청(Request)**: 무언가를 요청하는 경우
```markdown
Type: Request
From: code-reviewer
To: test-writer
Task: Create tests for authentication module
Context: Recent security review found gaps in auth testing
Expected output: Comprehensive test suite covering auth edge cases
```

**통보(Inform)**: 정보를 제공하는 경우
```markdown
Type: Inform
From: debugger
To: Main chat
Status: Investigation complete
Findings: Root cause identified in line 127, race condition in async handler
```

**약속(Commit)**: 무언가를 수행하겠다고 약속하는 경우
```markdown
Type: Commit
From: security-reviewer
Task: Review all changes in PR #342 for security issues
Deadline: Before responding to main chat
```

**거절(Reject)**: 이유와 함께 요청을 거부하는 경우
```markdown
Type: Reject
From: test-writer
Reason: Cannot write tests - no testing framework configured in project
Recommendation: Install Jest or similar framework first
```
</message_types>

<schema_validation>
**패턴**: 모든 페이로드를 기대하는 스키마에 맞게 검증합니다.

<example>
```markdown
<output_validation>
Expected output format:
{
  "vulnerabilities": [
    {
      "severity": "Critical|High|Medium|Low",
      "location": "file:line",
      "type": "string",
      "description": "string",
      "fix": "string"
    }
  ],
  "summary": "string"
}

Before returning output:
1. Verify JSON is valid
2. Check all required fields present
3. Validate severity values are from allowed list
4. Ensure location follows "file:line" format
</output_validation>
```

**장점**: 잘못된 형식의 출력이 하위 프로세스를 중단시키는 것을 방지합니다.
</example>
</schema_validation>
</structured_communication>

<observability>


"대부분의 에이전트 실패는 모델 실패가 아니라 컨텍스트 실패입니다."

<structured_logging>
**기록해야 할 항목**:
- 입력 프롬프트 및 파라미터
- 도구 호출과 그 결과
- 중간 추론 과정 (가능한 경우)
- 최종 출력
- 메타데이터 (타임스탬프, 모델 버전, 토큰 사용량, 지연 시간)
- 오류 및 경고

**로그 구조**:
```markdown
Invocation ID: abc-123-def
Timestamp: 2025-11-15T14:23:01Z
Subagent: security-reviewer
Model: sonnet-4.5
Input: "Review changes in commit a3f2b1c"
Tool calls:
  1. git diff a3f2b1c (success, 234 lines)
  2. Read src/auth.ts (success, 156 lines)
  3. Read src/db.ts (success, 203 lines)
Output: 3 vulnerabilities found (2 High, 1 Medium)
Tokens: 2,341 input, 876 output
Latency: 4.2s
Status: Success
```

**사용 사례**: 실패 디버깅, 패턴 식별, 성능 최적화.
</structured_logging>

<correlation_ids>
**패턴**: 엔드 투 엔드 재구성을 위해 모든 메시지, 계획, 도구 호출을 추적합니다.

```markdown
Correlation ID: workflow-20251115-abc123

Main chat [abc123]:
  → Launched code-reviewer [abc123-1]
     → Tool: git diff [abc123-1-t1]
     → Tool: Read auth.ts [abc123-1-t2]
     → Returned: 3 issues found
  → Launched test-writer [abc123-2]
     → Tool: Read auth.ts [abc123-2-t1]
     → Tool: Write auth.test.ts [abc123-2-t2]
     → Returned: Test suite created
  → Presented results to user
```

**장점**: 전체 워크플로우 실행을 추적하고, 실패가 발생한 위치를 파악하며, 연쇄 효과를 이해할 수 있습니다.
</correlation_ids>

<metrics_monitoring>
**추적해야 할 주요 메트릭**:
- 성공률 (완료된 작업 / 전체 호출)
- 오류 유형별 오류율
- 평균 토큰 사용량 (급증은 프롬프트 문제를 나타냄)
- 지연 시간 추세 (증가는 비효율을 나타냄)
- 도구 호출 패턴 (비정상적인 패턴은 문제를 나타냄)
- 재시도율 (실패 후 사용자가 얼마나 자주 재호출하는지)

**경보 임계값**:
- 성공률이 80% 미만으로 떨어질 때
- 오류율이 15%를 초과할 때
- 프롬프트 변경 없이 토큰 사용량이 50% 이상 증가할 때
- 지연 시간이 기준선의 2배를 초과할 때
- 동일한 오류 유형이 24시간 내 5회 이상 발생할 때
</metrics_monitoring>

<evaluator_agents>
**패턴**: 전담 품질 관리 에이전트가 출력을 검증합니다.

<example>
```markdown
---
name: output-validator
description: 서브에이전트 출력을 기대하는 스키마와 품질 기준에 맞게 검증합니다. 서브에이전트가 구조화된 출력을 생성한 후에 사용하세요.
tools: Read
model: haiku
---

<role>
You are an output validation specialist. Check subagent outputs for:
- Schema compliance
- Completeness
- Internal consistency
- Format correctness
</role>

<workflow>
1. Receive subagent output and expected schema
2. Validate structure matches schema
3. Check for required fields
4. Verify value constraints (enums, formats, ranges)
5. Test internal consistency (references valid, no contradictions)
6. Return validation report: Pass/Fail with specific issues
</workflow>

<validation_criteria>
Pass: All checks succeed
Fail: Any check fails - provide detailed error report
Partial: Minor issues that don't prevent use - flag warnings
</validation_criteria>
```

**사용 사례**: 출력 품질이 필수적인 중요 워크플로우, 고위험 작업, 컴플라이언스 요구사항.
</example>
</evaluator_agents>
</observability>

<anti_patterns>


<anti_pattern name="silent_failures">
서브에이전트가 실패했음에도 출력에 실패를 표시하지 않는 것은 피해야 합니다.

**예시**:
```markdown
Task: Review 10 files for security issues
Reality: Only reviewed 3 files due to errors, returned results anyway
Output: "No issues found" (incomplete review, but looks successful)
```

**해결**: 검토된 내용을 명시적으로 기술하고, 부분 완료를 표시하며, 오류 요약을 포함하세요.
</anti_pattern>

<anti_pattern name="no_fallback">
이상적인 경로가 실패할 때 서브에이전트가 완전히 포기하는 것은 피해야 합니다.

**예시**:
```markdown
Task: Generate code from API documentation
Error: API docs unavailable
Output: "Cannot complete task, API docs not accessible"
```

**더 나은 방식**:
```markdown
Error: API docs unavailable
Fallback: Using cached documentation (last updated: 2025-11-01)
Output: Code generated with note: "Verify against current API docs, using cached version"
```

**원칙**: 제약 조건 내에서 가능한 최선의 출력을 제공하고, 한계를 명확하게 표시하세요.
</anti_pattern>

<anti_pattern name="infinite_retry">
백오프나 제한 없이 실패한 작업을 재시도하는 것은 피해야 합니다.

**위험**: 토큰과 시간을 낭비하며, 속도 제한에 도달할 수 있습니다.

**해결**: 최대 재시도 횟수 (일반적으로 2~3회), 지수 백오프, 재시도 소진 후 폴백을 사용하세요.
</anti_pattern>

<anti_pattern name="error_cascading">
하위 에이전트가 상위 에이전트의 출력이 유효하다고 가정하는 것은 피해야 합니다.

**예시**:
```markdown
Agent 1: Generates code (contains syntax error)
  ↓
Agent 2: Writes tests (assumes code is syntactically valid, tests fail)
  ↓
Agent 3: Runs tests (all tests fail due to syntax error in code)
  ↓
Total workflow failure from single upstream error
```

**해결**: 각 에이전트가 처리 전 입력을 검증하고, 유효하지 않은 입력에 대한 오류 처리를 포함하세요.
</anti_pattern>

<anti_pattern name="no_error_context">
진단 컨텍스트가 없는 오류 메시지는 피해야 합니다.

**나쁨**: "Failed to complete task"

**좋음**: "Failed to complete task: Unable to access file src/auth.ts (file not found). Attempted to review authentication code but file missing from expected location. Recommendation: Verify file path or check if file was moved/deleted."

**원칙**: 오류 메시지는 근본 원인을 진단하고 해결책을 제안하는 데 도움이 되어야 합니다.
</anti_pattern>
</anti_patterns>

<recovery_checklist>


서브에이전트 프롬프트에 이러한 패턴을 포함하세요.

**오류 감지**:
- [ ] 처리 전 입력 검증
- [ ] 도구 호출 결과에서 오류 확인
- [ ] 출력이 기대하는 형식과 일치하는지 검증
- [ ] 가정 테스트 (파일 존재, 데이터 유효 여부 등)

**복구 메커니즘**:
- [ ] 기본 경로 실패를 위한 폴백 방법 정의
- [ ] 일시적 실패에 대한 재시도 로직 포함
- [ ] 우아한 성능 저하 (부분 결과가 없는 것보다 나음)
- [ ] 진단 컨텍스트를 포함한 명확한 오류 메시지

**실패 커뮤니케이션**:
- [ ] 작업을 완료할 수 없을 때 명시적으로 기술
- [ ] 시도한 내용과 실패 이유 설명
- [ ] 가능한 경우 부분 결과 제공
- [ ] 해결책 또는 다음 단계 제안

**품질 게이트**:
- [ ] 출력 반환 전 검증 단계
- [ ] 자체 확인 (출력이 의미 있는가?)
- [ ] 형식 준수 검증
- [ ] 완전성 확인 (필요한 모든 컴포넌트가 존재하는가?)
</recovery_checklist>
