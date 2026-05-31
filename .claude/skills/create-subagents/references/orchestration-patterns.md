# 멀티 에이전트 시스템의 오케스트레이션 패턴

<core_concept>
오케스트레이션은 여러 서브에이전트가 복잡한 작업을 완료하기 위해 어떻게 협력하는지를 정의합니다.

**단일 에이전트**: 하나의 컨텍스트 내에서 순차적으로 실행됩니다.
**멀티 에이전트**: 각자 전문 영역을 가진 여러 전문화된 에이전트 간의 협력입니다.
</core_concept>

<pattern_catalog>


<sequential>
**순차(Sequential) 패턴**: 에이전트들이 미리 정의된 선형 순서로 연결됩니다.

<characteristics>
- 각 에이전트는 이전 에이전트의 출력을 처리합니다
- 전문화된 변환의 파이프라인입니다
- 결정론적 흐름 (A → B → C)
- 추론과 디버깅이 용이합니다
</characteristics>

<when_to_use>
**적합한 경우**:
- 문서 리뷰 워크플로우 (보안 → 성능 → 스타일)
- 데이터 처리 파이프라인 (추출 → 변환 → 검증 → 적재)
- 다단계 추론 (조사 → 분석 → 통합 → 권고)

**예시**:
```markdown
작업: 종합적인 코드 리뷰

흐름:
1. security-reviewer: 취약점 검사
   ↓ (보안 리포트)
2. performance-analyzer: 성능 문제 식별
   ↓ (성능 리포트)
3. test-coverage-checker: 테스트 커버리지 평가
   ↓ (커버리지 리포트)
4. report-synthesizer: 모든 결과를 실행 가능한 리뷰로 통합
```
</when_to_use>

<implementation>
```markdown
<sequential_workflow>
메인 채팅이 오케스트레이션:
1. 코드 변경사항과 함께 security-reviewer 실행
2. 보안 리포트 대기
3. 코드 변경사항 + 보안 리포트 컨텍스트와 함께 performance-analyzer 실행
4. 성능 리포트 대기
5. 코드 변경사항과 함께 test-coverage-checker 실행
6. 커버리지 리포트 대기
7. 모든 리포트를 통합하여 사용자에게 전달
</sequential_workflow>
```

**장점**: 명확한 의존성, 각 단계가 이전 단계를 기반으로 구성됩니다.
**단점**: 병렬 방식보다 느림 (순차적 지연), 하나의 실패가 파이프라인을 차단합니다.
</implementation>
</sequential>

<parallel>
**병렬(Parallel)/동시(Concurrent) 패턴**: 여러 전문화된 서브에이전트가 동시에 작업을 수행합니다.

<characteristics>
- 에이전트들이 독립적으로 동시에 실행됩니다
- 출력이 최종 응답으로 통합됩니다
- 상당한 속도 향상을 제공합니다
- 동기화가 필요합니다
</characteristics>

<when_to_use>
**적합한 경우**:
- 동일한 입력에 대한 독립적인 분석 (보안 + 성능 + 품질)
- 여러 독립 항목 처리 (여러 파일 리뷰)
- 조사 작업 (여러 출처에서 정보 수집)

**성능 데이터**: Anthropic의 조사 시스템에서 3~5개의 서브에이전트를 병렬로 실행했을 때 90%의 시간 절감을 달성했습니다.

**예시**:
```markdown
작업: 종합적인 코드 리뷰 (병렬 방식)

동시에 실행:
- security-reviewer (auth.ts 분석)
- performance-analyzer (auth.ts 분석)
- test-coverage-checker (auth.ts 테스트 커버리지 분석)

세 에이전트 모두 완료 대기 → 결과 통합.

소요 시간: max(agent_1, agent_2, agent_3) vs 순차: agent_1 + agent_2 + agent_3
```
</when_to_use>

<implementation>
```markdown
<parallel_workflow>
메인 채팅이 오케스트레이션:
1. 동일한 컨텍스트로 모든 에이전트를 동시에 실행
2. 완료되는 순서대로 출력 수집
3. 모두 완료되면 결과 통합

동기화 과제:
- 서로 다른 완료 시간 처리
- 부분적 실패 처리 (일부 에이전트는 실패, 다른 에이전트는 성공)
- 잠재적으로 충돌하는 출력 결합
</parallel_workflow>
```

**장점**: 대폭적인 속도 향상, 효율적인 리소스 활용.
**단점**: 복잡성 증가, 동기화 과제, 높은 비용 (여러 에이전트 동시 실행).
</implementation>
</parallel>

<hierarchical>
**계층(Hierarchical) 패턴**: 에이전트들이 계층적으로 구성되며, 상위 에이전트가 하위 에이전트를 감독합니다.

<characteristics>
- 위임이 있는 트리 구조
- 상위 에이전트가 작업을 분해합니다
- 하위 에이전트가 특정 하위 작업을 실행합니다
- 마스터-워커 관계
</characteristics>

<when_to_use>
**적합한 경우**:
- 분해가 필요한 크고 복잡한 문제
- 자연스러운 계층이 있는 작업 (시스템 설계 → 컴포넌트 설계 → 구현)
- 감독 및 품질 관리가 필요한 상황

**예시**:
```markdown
작업: 완전한 인증 시스템 구현

계층 구조:
- architect (최상위): 전체 인증 시스템 설계, 컴포넌트로 분해
  ↓ 위임:
  - backend-dev: API 엔드포인트 구현
  - frontend-dev: 로그인 UI 구현
  - security-reviewer: 두 영역의 취약점 검토
  - test-writer: 통합 테스트 작성
  ↑ 보고:
- architect: 컴포넌트 통합, 일관성 확보
```
</when_to_use>

<implementation>
```markdown
<hierarchical_workflow>
최상위 에이전트 (architect):
1. 요구사항 분석
2. 하위 작업으로 분해
3. 전문화된 에이전트에 위임
4. 진행 상황 모니터링
5. 결과 통합
6. 컴포넌트 간 일관성 검증

하위 에이전트:
- 집중된 하위 작업을 수신합니다
- 깊은 전문성으로 실행합니다
- 코디네이터에게 결과를 보고합니다
- 다른 에이전트의 작업을 인지하지 않습니다
</hierarchical_workflow>
```

**장점**: 분해를 통해 복잡성을 처리, 명확한 책임 경계.
**단점**: 조정 오버헤드, 계층 간 정렬 불일치 위험.
</implementation>
</hierarchical>

<coordinator>
**코디네이터(Coordinator) 패턴**: 중앙 LLM 에이전트가 전문 서브에이전트에게 작업을 라우팅합니다.

<characteristics>
- 중앙 의사 결정자
- 동적 라우팅 (하드코딩된 워크플로우 아님)
- AI 모델이 작업 특성에 따라 오케스트레이션
- 계층 패턴과 유사하지만 프로세스 흐름에 집중
</characteristics>

<when_to_use>
**적합한 경우**:
- 다양한 전문성이 필요한 다양한 작업 유형
- 다음 단계가 결과에 따라 달라지는 동적 워크플로우
- 다양한 요청을 처리하는 사용자 대면 시스템

**예시**:
```markdown
작업: "내 코드베이스를 개선해 주세요"

코디네이터가 요청을 분석 → 관련 에이전트를 결정:
- code-quality-analyzer: 전체 코드 품질 평가
  ↓ 보안 문제 발견
- 코디네이터: security-reviewer로 라우팅
  ↓ 보안 문제 발견
- 코디네이터: auto-fixer로 라우팅하여 패치 생성
  ↓ 패치 준비 완료
- 코디네이터: test-writer로 라우팅하여 수정 사항에 대한 테스트 작성
  ↓
- 코디네이터: 모든 작업을 개선 계획으로 통합
```

중간 결과에 기반한 **동적 라우팅** - 미리 정의된 흐름이 아닙니다.
</when_to_use>

<implementation>
```markdown
<coordinator_workflow>
코디네이터 에이전트 프롬프트:

<role>
You are an orchestration coordinator. Route tasks to specialized agents based on:
- Task characteristics
- Available agents and their capabilities
- Results from previous agents
- User goals
</role>

<available_agents>
- security-reviewer: Security analysis
- performance-analyzer: Performance optimization
- test-writer: Test creation
- debugger: Bug investigation
- refactorer: Code improvement
</available_agents>

<decision_process>
1. Analyze incoming task
2. Identify relevant agents (may be multiple)
3. Determine execution strategy (sequential, parallel, conditional)
4. Launch agents with appropriate context
5. Analyze results
6. Decide next step (more agents, synthesis, completion)
7. Repeat until task complete
</decision_process>
```

**장점**: 유연하고, 작업 요구사항에 적응하며, 에이전트를 효율적으로 활용합니다.
**단점**: 코디네이터가 단일 장애점, 라우팅 로직의 복잡성.
</implementation>
</coordinator>

<orchestrator_worker>
**오케스트레이터-워커(Orchestrator-Worker) 패턴**: 중앙 오케스트레이터가 작업을 할당하고 실행을 관리합니다.

<characteristics>
- 분산 실행과 함께 중앙 집중식 조정
- 워커들이 특정한 독립 작업에 집중합니다
- 분산 컴퓨팅의 마스터-워커 패턴과 유사합니다
- 계획(오케스트레이터)과 실행(워커)의 명확한 분리
</characteristics>

<when_to_use>
**적합한 경우**:
- 배치 처리 (100개 파일 처리)
- 분산 가능한 독립 작업 (여러 API 엔드포인트 분석)
- 워커 간 부하 분산

**예시**:
```markdown
작업: 50개 마이크로서비스 보안 리뷰

오케스트레이터:
1. 50개 서비스를 모두 식별합니다
2. 5개씩 배치로 나눕니다
3. 워커 에이전트에 배치를 할당합니다
4. 진행 상황을 모니터링합니다
5. 결과를 집계합니다

워커 (security-reviewer의 5개 동시 인스턴스):
- 각각 할당된 서비스를 리뷰합니다
- 오케스트레이터에 결과를 보고합니다
- 독립 실행 (워커 간 통신 없음)
```
</when_to_use>

<sonnet_haiku_orchestration>
**Sonnet 4.5 + Haiku 4.5 오케스트레이션**: 최적의 비용/성능 패턴.

연구 결과:
- Sonnet 4.5: "에이전트 분야 최고의 모델", 계획 및 검증에서 뛰어난 성능
- Haiku 4.5: "Sonnet 4.5 성능의 90%", 최고의 코딩 모델 중 하나, 빠르고 비용 효율적

**패턴**:
```markdown
1. Sonnet 4.5 (오케스트레이터):
   - 작업을 분석합니다
   - 계획을 수립합니다
   - 하위 작업으로 분해합니다
   - 병렬화 가능한 항목을 식별합니다

2. 다수의 Haiku 4.5 인스턴스 (워커):
   - 각각 할당된 하위 작업을 완료합니다
   - 속도를 위해 병렬로 실행됩니다
   - 결과를 오케스트레이터에 반환합니다

3. Sonnet 4.5 (오케스트레이터):
   - 모든 워커의 결과를 통합합니다
   - 출력 품질을 검증합니다
   - 일관성을 확보합니다
   - 최종 출력을 전달합니다
```

**비용/성능 최적화**: 비싼 Sonnet은 계획/검증에만, 저렴한 Haiku는 실행에 사용합니다.
</sonnet_haiku_orchestration>
</orchestrator_worker>
</pattern_catalog>

<hybrid_approaches>


실제 시스템은 종종 서로 다른 워크플로우 단계에 패턴을 조합해서 사용합니다.

<example name="sequential_then_parallel">
**초기 처리는 순차 → 분석은 병렬**:

```markdown
작업: 종합적인 기능 구현 리뷰

순차 단계:
1. requirements-validator: 요구사항 완전성 확인
   ↓
2. implementation-reviewer: 기능이 올바르게 구현되었는지 확인
   ↓

병렬 단계 (구현 검증 후):
3. 동시에 실행:
   - security-reviewer
   - performance-analyzer
   - accessibility-checker
   - test-coverage-validator
   ↓

순차 통합:
4. report-generator: 모든 결과 통합
```

**근거**: 초기 단계에는 의존성이 있고 (요구사항 전에 구현을 검증할 수 없음), 후기 단계는 독립적인 분석입니다.
</example>

<example name="coordinator_with_hierarchy">
**코디네이터가 계층적 팀을 오케스트레이션**:

```markdown
최상위: 코디네이터가 "결제 시스템 구축"을 수신

코디네이터가 계층적 팀을 구성:

팀 1 (백엔드):
- 리드: backend-architect
  - 워커: api-developer, database-designer, integration-specialist

팀 2 (프론트엔드):
- 리드: frontend-architect
  - 워커: ui-developer, state-management-specialist

팀 3 (DevOps):
- 리드: infra-architect
  - 워커: deployment-specialist, monitoring-specialist

코디네이터:
- 팀 간 조정을 관리합니다
- 팀 간 의존성을 해결합니다
- 결과물을 통합합니다
```

**장점**: 동적 라우팅(코디네이터)과 팀 구조(계층)를 결합합니다.
</example>
</hybrid_approaches>

<implementation_guidance>


<coordinator_subagent>
**코디네이터 구현 예시**:

```markdown
---
name: workflow-coordinator
description: 멀티 에이전트 워크플로우를 오케스트레이션합니다. 작업에 여러 전문화된 에이전트의 협력이 필요할 때 사용하세요.
tools: all
model: sonnet
---

<role>
You are a workflow coordinator. Analyze tasks, identify required agents, orchestrate their execution.
</role>

<available_agents>
{list of specialized agents with capabilities}
</available_agents>

<orchestration_strategies>
**Sequential**: When agents depend on each other's outputs
**Parallel**: When agents can work independently
**Hierarchical**: When task needs decomposition with oversight
**Adaptive**: Choose pattern based on task characteristics
</orchestration_strategies>

<workflow>
1. Analyze incoming task
2. Identify required capabilities
3. Select agents and pattern
4. Launch agents (sequentially or parallel as appropriate)
5. Monitor execution
6. Handle errors (retry, fallback, escalate)
7. Integrate results
8. Validate coherence
9. Deliver final output
</workflow>

<error_handling>
If agent fails:
- Retry with refined context (1-2 attempts)
- Try alternative agent if available
- Proceed with partial results if acceptable
- Escalate to human if critical
</error_handling>
```
</coordinator_subagent>

<handoff_protocol>
**에이전트 간 명확한 핸드오프**:

```markdown
<agent_handoff_format>
From: {source_agent}
To: {target_agent}
Task: {specific task}
Context:
  - What was done: {summary of prior work}
  - Key findings: {important discoveries}
  - Constraints: {limitations or requirements}
  - Expected output: {what target agent should produce}

Attachments:
  - {relevant files, data, or previous outputs}
</agent_handoff_format>
```

**명시적 형식이 중요한 이유**: 정보 손실을 방지하고, 대상 에이전트가 완전한 컨텍스트를 갖도록 보장하며, 검증을 가능하게 합니다.
</handoff_protocol>

<synchronization>
**병렬 실행 처리**:

```markdown
<parallel_synchronization>
Launch pattern:
1. Initiate all parallel agents with shared context
2. Track which agents have completed
3. Collect outputs as they arrive
4. Wait for all to complete OR timeout
5. Proceed with available results (flag missing if timeout)

Partial failure handling:
- If 1 of 3 agents fails: Proceed with 2 results, note gap
- If 2 of 3 agents fail: Consider retry or workflow failure
- Always communicate what was completed vs attempted
</parallel_synchronization>
```
</synchronization>
</implementation_guidance>

<anti_patterns>


<anti_pattern name="over_orchestration">
단일 에이전트로 충분한 경우에 여러 에이전트를 사용하는 것은 피해야 합니다.

**예시**: 10줄의 코드를 리뷰하기 위해 세 에이전트를 사용하는 것은 과잉입니다.

**해결**: 진정으로 복잡한 작업에만 멀티 에이전트를 사용하세요. 여러 단순한 에이전트를 조정하는 것보다 하나의 유능한 에이전트가 더 나은 경우가 많습니다.
</anti_pattern>

<anti_pattern name="no_coordination">
조정이나 통합 없이 여러 에이전트를 실행하는 것은 피해야 합니다.

**문제**: 사용자가 충돌하는 리포트를 받고, 일관된 출력이 없으며, 어느 것을 신뢰해야 할지 불분명합니다.

**해결**: 항상 멀티 에이전트 출력을 일관된 최종 결과로 통합하세요.
</anti_pattern>

<anti_pattern name="sequential_when_parallel">
독립적인 분석을 순차적으로 실행하는 것은 피해야 합니다.

**예시**: 보안 리뷰 → 성능 리뷰 → 품질 리뷰 (각각 독립적이지만 순차적으로 수행).

**해결**: 독립적인 작업에는 병렬 실행을 사용하세요. 이 경우 3배의 속도 향상을 달성할 수 있습니다.
</anti_pattern>

<anti_pattern name="unclear_handoffs">
다음 에이전트에게 충분한 컨텍스트를 제공하지 않는 에이전트 출력은 피해야 합니다.

**예시**:
```markdown
Agent 1: "Found issues"
Agent 2: Receives "Found issues" with no details on what, where, or severity
Agent 2: Can't effectively act on vague input
```

**해결**: 완전한 컨텍스트를 포함한 구조화된 핸드오프 형식을 사용하세요.
</anti_pattern>

<anti_pattern name="no_error_recovery">
에이전트 실패 시 폴백이 없는 오케스트레이션은 피해야 합니다.

**문제**: 하나의 에이전트 실패가 전체 워크플로우 실패를 야기합니다.

**해결**: 우아한 성능 저하(graceful degradation), 재시도 로직, 대체 에이전트, 부분 결과 처리 방식을 사용하세요 ([error-handling-and-recovery.md](error-handling-and-recovery.md) 참조).
</anti_pattern>
</anti_patterns>

<best_practices>


<principle name="right_granularity">
**에이전트 세분화**: 너무 넓지도, 너무 좁지도 않게.

너무 넓음: "general-purpose-helper" (전문화의 목적을 무색하게 함)
너무 좁음: "checks-for-sql-injection-in-nodejs-express-apps-only" (지나치게 특정적)
적절함: "웹 애플리케이션 취약점 전문 security-reviewer"
</principle>

<principle name="clear_responsibilities">
**각 에이전트는 명확하고 중복되지 않는 책임을 가져야 합니다**.

나쁨: 두 에이전트가 모두 "코드 품질을 리뷰" (중복, 혼란)
좋음: "security-reviewer" + "performance-analyzer" (뚜렷한 관심사)
</principle>

<principle name="minimize_handoffs">
**경계에서의 정보 손실을 최소화하세요**.

각 핸드오프는 컨텍스트 손실의 기회입니다. 구조화된 핸드오프 형식이 이를 방지합니다.
</principle>

<principle name="parallel_where_possible">
**독립적인 작업은 병렬화하세요**.

에이전트들이 서로의 출력에 의존하지 않는다면 동시에 실행하세요.
</principle>

<principle name="coordinator_lightweight">
**코디네이터 로직을 경량으로 유지하세요**.

무거운 코디네이터 = 병목. 코디네이터는 라우팅과 통합을 담당해야 하며, 직접 깊은 작업을 수행하지 않아야 합니다.
</principle>

<principle name="cost_optimization">
**모델 등급을 전략적으로 사용하세요**.

- 계획/검증: Sonnet 4.5 (지능이 필요)
- 명확한 작업 실행: Haiku 4.5 (빠르고, 저렴하며, 여전히 유능함)
- 가장 중요한 결정: Sonnet 4.5
- 대량 처리: Haiku 4.5
</principle>
</best_practices>

<pattern_selection>


<decision_tree>
```markdown
작업이 독립적인 하위 작업으로 분해 가능한가?
├─ 예: 병렬 패턴 (가장 빠름)
└─ 아니오: ↓

하위 작업들이 서로의 출력에 의존하는가?
├─ 예: 순차 패턴 (명확한 의존성)
└─ 아니오: ↓

작업이 분해와 감독이 모두 필요한 크고 복잡한 작업인가?
├─ 예: 계층 패턴 (구조화된 위임)
└─ 아니오: ↓

작업 요구사항이 동적으로 변하는가?
├─ 예: 코디네이터 패턴 (적응형 라우팅)
└─ 아니오: 단일 에이전트로 충분
```
</decision_tree>

<performance_vs_complexity>
**성능**: 병렬 > 계층 > 순차 > 코디네이터 (오버헤드)
**복잡성**: 코디네이터 > 계층 > 병렬 > 순차
**유연성**: 코디네이터 > 계층 > 병렬 > 순차

**트레이드오프**: 요구사항을 충족하는 가장 단순한 패턴을 선택하세요.
</performance_vs_complexity>
</pattern_selection>
