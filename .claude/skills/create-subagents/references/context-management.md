# 서브에이전트를 위한 컨텍스트 관리

<core_problem>


"대부분의 에이전트 실패는 모델 실패가 아니라 컨텍스트 실패다."

<stateless_nature>
LLM은 기본적으로 상태를 유지하지 않는다. 각 호출은 이전 상호작용의 기억 없이 처음부터 시작된다.

**서브에이전트에게 이것이 의미하는 바**:
- 장기 실행 작업은 도구 호출 사이에서 컨텍스트를 잃는다
- 반복되는 정보가 토큰을 낭비한다
- 워크플로 초기의 중요한 결정이 잊혀진다
- 컨텍스트 윈도우가 중복 정보로 채워진다
</stateless_nature>

<context_window_limits>
전체 대화 기록은 다음을 초래한다:
- 성능 저하 (중요한 정보가 노이즈에 묻힘)
- 높은 비용 (중복 토큰에 비용 지불)
- 컨텍스트 한도 초과 (워크플로 실패)

**임계점**: 컨텍스트가 한도에 가까워지면 실패 전에 이미 품질이 저하된다.
</context_window_limits>
</core_problem>

<memory_architecture>


<short_term_memory>
**단기 기억(STM)**: 최근 5~9개의 상호작용.

**구현**: 컨텍스트 윈도우에 보존됨.

**사용 목적**:
- 현재 작업 상태
- 최근 도구 호출 결과
- 즉각적인 결정
- 활성 대화 흐름

**한계**: 용량이 제한적이며 휘발성(컨텍스트 초기화 시 소멸).
</short_term_memory>

<long_term_memory>
**장기 기억(LTM)**: 세션 간 지속적인 저장소.

**구현**: 외부 저장소 (파일, 데이터베이스, 벡터 스토어).

**사용 목적**:
- 역사적 패턴
- 축적된 지식
- 사용자 선호도
- 과거 작업 결과

**접근 패턴**: 필요 시 관련 기억을 작업 기억으로 가져온다.
</long_term_memory>

<working_memory>
**작업 기억**: 현재 컨텍스트 + 가져온 기억.

**구성**:
- 핵심 작업 정보 (항상 존재)
- 최근 상호작용 기록 (STM)
- 가져온 관련 기억 (LTM에서)
- 현재 도구 출력

**관리**: 컨텍스트 윈도우에 담기는 내용이다. 적극적으로 최적화하라.
</working_memory>

<core_memory>
**핵심 기억**: 현재 상호작용에서 활발히 사용되는 정보.

**예시**:
- 현재 작업 목표와 제약
- 작업 중인 코드베이스의 주요 사실
- 사용자의 중요 요구사항
- 활성 워크플로 상태

**원칙**: 핵심 기억은 최소하고 높은 관련성을 유지하라. 나머지는 검색 가능하다.
</core_memory>

<archival_memory>
**보관 기억**: 덜 중요한 데이터를 위한 지속적인 저장소.

**예시**:
- 전체 대화 기록
- 전체 도구 출력 로그
- 역사적 지표
- 시도했던 더 이상 사용하지 않는 접근 방식

**접근**: 거의 필요하지 않으며, 필요 시 검색 가능하고, 컨텍스트 윈도우를 소비하지 않는다.
</archival_memory>
</memory_architecture>

<context_strategies>


<summarization>
**패턴**: 컨텍스트에서 검색 가능한 데이터베이스로 정보를 이동하고, 기억에 요약을 유지한다.

<when_to_summarize>
다음 시점에 요약을 트리거하라:
- 컨텍스트가 한도의 75%에 도달했을 때
- 작업이 새로운 단계로 전환될 때
- 정보가 중요하지만 더 이상 적극적으로 필요하지 않을 때
- 동일한 정보가 여러 번 반복될 때
</when_to_summarize>

<summary_quality>
**품질 지침**:

1. **중요한 이벤트를 강조하라**
```markdown
나쁨: "코드를 검토하고, 문제를 발견하고, 수정을 제공했다"
좋음: "auth.ts:127에서 치명적인 SQL 인젝션 발견, 파라미터화된 쿼리 수정 제공. 높은 우선순위: 배포 전 즉각적인 조치 필요."
```

2. **순차적 추론을 위해 순서를 포함하라**
```markdown
"첫 번째 시도: 타입 불일치로 인해 직접 수정 실패.
두 번째 시도: 타입 변환 추가, 런타임 오류 발생.
최종 접근: 타입 안전 래퍼로 리팩터링 (성공)."
```

3. **긴 단락 대신 카테고리로 구조화하라**
```markdown
발견된 문제:
- 보안: SQL 인젝션 (심각), XSS (높음)
- 성능: N+1 쿼리 (보통)
- 코드 품질: 중복 로직 (낮음)

취한 조치:
- prepared statements로 SQL 인젝션 수정
- XSS를 위한 입력 정제 추가
- 성능 최적화 지연 (TODO에 메모)
```

**장점**: 조직화된 그룹화가 관계 이해를 향상시킨다.
</summary_quality>

<example_workflow>
```markdown
<context_management>
대화 기록이 15턴을 초과하면:
1. 다음에 해당하는 정보를 식별하라:
   - 중요 (보존 필수)
   - 완료 (더 이상 활발히 변경되지 않음)
   - 역사적 (다음 즉각적인 단계에 불필요)
2. 카테고리로 구조화된 요약 생성
3. 전체 세부 정보를 파일에 저장 (보관 기억)
4. 장황한 기록을 간결한 요약으로 대체
5. 줄어든 컨텍스트 부하로 계속 진행
</context_management>
```
</example_workflow>
</summarization>

<sliding_window>
**패턴**: 컨텍스트에 최근 상호작용을 유지하고, 오래된 상호작용은 검색을 위한 벡터로 저장.

<implementation>
```markdown
<sliding_window_strategy>
컨텍스트에 유지:
- 마지막 5개의 도구 호출과 결과 (단기 기억)
- 현재 작업 상태와 목표 (핵심 기억)
- 사용자 요구사항의 주요 사실 (핵심 기억)

벡터 저장소로 이동:
- 5단계 이전의 도구 호출
- 완료된 하위 작업 결과
- 역사적 디버깅 시도
- 해결책으로 이어지지 않은 탐색

검색 트리거:
- 현재 문제가 과거 문제와 유사할 때
- 사용자가 이전 논의를 참조할 때
- 패턴 매칭이 관련 기록을 시사할 때
</sliding_window_strategy>
```

**장점**: 컨텍스트 성장이 제한되면서 관련 기록에 여전히 접근 가능.
</implementation>
</sliding_window>

<semantic_context_switching>
**패턴**: 컨텍스트 변경을 감지하고 적절하게 대응한다.

<example>
```markdown
<context_switch_detection>
주제 변경 모니터링:
- 사용자가 "버그 수정"에서 "기능 추가"로 전환
- 서브에이전트가 "분석"에서 "구현"으로 전환
- 실행 중 작업 범위 변경

컨텍스트 전환 시:
1. 현재 컨텍스트 상태 요약
2. 상태를 작업 기억/파일에 저장
3. 새 주제에 관련된 컨텍스트 로드
4. 전환 알림: "버그 분석에서 기능 구현으로 전환합니다. 버그 분석 결과는 나중에 참조할 수 있도록 저장되었습니다."
</context_switch_detection>
```

**방지**: 컨텍스트 혼합, 잘못된 제약 적용, 작업 전환 시 중요 정보 망각.
</example>
</semantic_context_switching>

<scratchpads>
**패턴**: LLM 컨텍스트 외부에 중간 결과를 기록한다.

<use_cases>
**스크래치패드 사용 시점**:
- 여러 단계의 복잡한 계산
- 여러 접근 방식의 탐색
- 모두 관련이 없을 수 있는 상세 분석
- 디버깅 추적
- 중간 데이터 변환

**구현**:
```markdown
<scratchpad_workflow>
복잡한 디버깅의 경우:
1. 스크래치패드 파일 생성: `.claude/scratch/debug-session-{timestamp}.md`
2. 스크래치패드에 각 가설과 테스트 결과 기록
3. 컨텍스트에는 현재 가설과 주요 발견만 유지
4. 전체 디버깅 기록은 스크래치패드 참조
5. 최종 출력에 성공적인 접근 방식 요약
</scratchpad_workflow>
```

**장점**: 컨텍스트에는 인사이트가, 스크래치패드에는 탐색 내용이 담긴다. 사용자는 깔끔한 요약을 받고, 필요 시 전체 세부 정보에 접근 가능.
</use_cases>
</scratchpads>

<smart_memory_management>
**패턴**: 핵심 데이터를 자동 추가하고 필요 시 검색한다.

<smart_write>
```markdown
<auto_capture>
자동으로 기억에 저장:
- 사용자가 명시한 선호도: "JavaScript보다 TypeScript를 선호한다"
- 프로젝트 관례: "이 코드베이스는 테스트에 Jest를 사용한다"
- 중요한 결정: "인증에 OAuth2를 사용하기로 결정했다"
- 자주 사용되는 패턴: "API 엔드포인트는 REST 명명 규칙을 따른다: /api/v1/{resource}"

쉽게 검색할 수 있도록 구조화된 형식으로 저장.
</auto_capture>
```
</smart_write>

<smart_read>
```markdown
<auto_retrieval>
다음 상황에서 기억으로부터 자동 검색:
- 사용자가 과거 결정에 대해 묻는 경우: "왜 OAuth2를 선택했나요?"
- 유사한 작업 발생 시: "지난번에 인증을 추가했을 때, 우리는..."
- 패턴 매칭: "이것은 지난주의 결제 흐름 문제와 비슷해 보인다"

관련 기억을 작업 컨텍스트에 주입.
</auto_retrieval>
```
</smart_read>
</smart_memory_management>

<compaction>
**패턴**: 한도 근접 시 대화를 요약하고 요약으로 재초기화한다.

<workflow>
```markdown
<compaction_workflow>
컨텍스트가 90% 용량에 도달하면:
1. 필수 정보 식별:
   - 현재 작업과 상태
   - 내린 핵심 결정
   - 중요한 제약
   - 주요 발견
2. 간결한 요약 생성 (최대 컨텍스트 크기의 20%)
3. 전체 컨텍스트를 보관 저장소에 저장
4. 요약으로 초기화된 새 대화 생성
5. 새로운 컨텍스트에서 작업 계속

요약 형식:
**Task**: [현재 목표]
**Status**: [완료된 것, 남은 것]
**Key findings**: [중요한 발견]
**Decisions**: [내린 중요 결정]
**Next steps**: [즉각적인 조치]
</compaction_workflow>
```

**사용 시점**: 장기 실행 작업, 탐색적 분석, 반복적 디버깅.
</workflow>
</compaction>
</context_strategies>

<framework_support>


<langchain>
**LangChain**: 자동 메모리 관리를 제공한다.

**기능**:
- 대화 메모리 버퍼
- 요약 메모리
- 벡터 스토어 메모리
- 엔티티 추출

**사용 사례**: 수동 구현 없이 정교한 메모리가 필요한 서브에이전트 구축.
</langchain>

<llamaindex>
**LlamaIndex**: 긴 대화를 위한 인덱싱.

**기능**:
- 대화 기록에 대한 시맨틱 검색
- 자동 청킹 및 인덱싱
- 검색 보강

**사용 사례**: 대규모 코드베이스, 문서, 또는 방대한 대화 기록으로 작업하는 서브에이전트.
</llamaindex>

<file_based>
**파일 기반 메모리**: 단순하고, 명시적이며, 디버깅 가능.

```markdown
<memory_structure>
.claude/memory/
  core-facts.md          # 필수 프로젝트 정보
  decisions.md           # 핵심 결정과 근거
  patterns.md            # 발견된 패턴과 관례
  {subagent}-state.json  # 서브에이전트별 상태
</memory_structure>

<usage>
서브에이전트는 시작 시 관련 파일을 읽고, 실행 중 업데이트하며, 종료 시 요약한다.
</usage>
```

**장점**: 투명하고, 버전 관리 가능하며, 사람이 읽을 수 있다.
</file_based>
</framework_support>

<subagent_patterns>


<stateful_subagent>
**장기 실행 또는 자주 호출되는 서브에이전트의 경우**:

```markdown
---
name: code-architect
description: Maintains understanding of system architecture across multiple invocations
tools: Read, Write, Grep, Glob
model: sonnet
---

<role>
You are a system architect maintaining coherent design across project evolution.
</role>

<memory_management>
On each invocation:
1. Read `.claude/memory/architecture-state.md` for current system state
2. Perform assigned task with full context
3. Update architecture-state.md with new components, decisions, patterns
4. Maintain concise state (max 500 lines), summarize older decisions

State file structure:
- Current architecture (always up-to-date)
- Recent changes (last 10 modifications)
- Key design decisions (why choices were made)
- Active concerns (issues to address)
</memory_management>
```
</stateful_subagent>

<stateless_subagent>
**단순하고 집중된 서브에이전트의 경우**:

```markdown
---
name: syntax-checker
description: Validates code syntax without maintaining state
tools: Read, Bash
model: haiku
---

<role>
You are a syntax validator. Check code for syntax errors.
</role>

<workflow>
1. Read specified files
2. Run syntax checker (language-specific linter)
3. Report errors with line numbers
4. No memory needed - each invocation is independent
</workflow>
```

**무상태 사용 시점**: 단일 목적 검증기, 포매터, 단순 변환.
</stateless_subagent>

<context_inheritance>
**메인 채팅으로부터 컨텍스트 상속**:

서브에이전트는 자동으로 다음에 접근할 수 있다:
- 사용자의 원래 요청
- 호출 시 제공된 모든 컨텍스트

```markdown
메인 채팅: "보안 문제에 대해 인증 변경 사항을 검토해주세요.
           컨텍스트: 최근에 JWT에서 세션 기반 인증으로 전환했습니다."

서브에이전트가 받는 것:
- 작업: 인증 변경 사항 검토
- 컨텍스트: JWT에서 세션 기반 인증으로의 최근 전환
- 이 컨텍스트는 명시적인 메모리 관리 없이 검토 초점에 영향을 미침
```
</context_inheritance>
</subagent_patterns>

<anti_patterns>


<anti_pattern name="context_dumping">
❌ "혹시 모르니" 모든 것을 컨텍스트에 포함

**문제**: 중요한 정보를 노이즈에 묻히게 하고, 토큰을 낭비하며, 성능을 저하시킨다.

**수정**: 현재 작업에 관련된 것만 포함하라. 나머지는 검색 가능하다.
</anti_pattern>

<anti_pattern name="no_summarization">
❌ 한도에 도달할 때까지 컨텍스트를 무한히 늘리는 것

**문제**: 작업 중 갑작스러운 컨텍스트 오버플로, 실패 전 품질 저하.

**수정**: 75% 용량에서 선제적 요약, 지속적인 압축.
</anti_pattern>

<anti_pattern name="lossy_summarization">
❌ 중요한 정보를 버리는 요약

**예시**:
```markdown
나쁜 요약: "여러 접근 방식을 시도했고, 결국 버그를 수정했다"
잃어버린 정보: 어떤 접근 방식이 실패했는지, 왜 실패했는지, 성공적인 수정이 무엇이었는지
```

**수정**: 요약은 필수 사실, 결정, 근거를 보존한다. 세부 정보는 보관 저장소로.
</anti_pattern>

<anti_pattern name="no_memory_structure">
❌ 구조화되지 않은 메모리 (긴 단락, 구성 없음)

**문제**: 관련 정보를 검색하기 어렵고, LLM 추론에 불리하다.

**수정**: 카테고리, 글머리 기호, 명확한 섹션을 가진 구조화된 메모리.
</anti_pattern>

<anti_pattern name="context_failure_ignorance">
❌ 모든 실패를 모델 한계로 가정

**현실**: "대부분의 에이전트 실패는 컨텍스트 실패이지, 모델 실패가 아니다."

모델을 탓하기 전에 컨텍스트 품질을 확인하라:
- 관련 정보가 존재하는가?
- 명확하게 구성되어 있는가?
- 중요한 정보가 노이즈에 묻혀 있는가?
- 컨텍스트가 적절히 유지되었는가?
</anti_pattern>
</anti_patterns>

<best_practices>


<principle name="core_memory_minimal">
핵심 기억은 최소하고 높은 관련성을 유지하라.

**경험 법칙**: 다음 3단계에 필요하지 않은 정보라면 핵심 기억에 속하지 않는다.
</principle>

<principle name="summaries_structured">
요약은 구조화되고, 카테고리화되고, 훑어볼 수 있어야 한다.

**템플릿**:
```markdown

**Status**: [진행 상황]
**Completed**:
- [주요 성과 1]
- [주요 성과 2]

**Active**:
- [현재 작업]

**Decisions**:
- [중요한 결정 1]: [근거]
- [중요한 결정 2]: [근거]

**Next**: [즉각적인 다음 단계]
```
</principle>

<principle name="timing_matters">
순차적 추론을 위해 순서를 포함하라.

"먼저 X를 시도했고 (실패), 그 다음 Y를 시도했다 (성공)"가 "Y 방식을 사용했다"보다 더 유용하다.
</principle>

<principle name="retrieval_over_retention">
항상 컨텍스트에 유지하는 것보다 필요할 때 정보를 검색하는 것이 낫다.

**예외**: 자주 사용되는 핵심 사실 (작업 목표, 중요한 제약).
</principle>

<principle name="external_storage">
파일시스템 사용 대상:
- 전체 로그와 추적
- 상세 탐색 결과
- 역사적 데이터
- 중간 작업 산출물

컨텍스트 사용 대상:
- 현재 작업 상태
- 핵심 결정
- 활성 워크플로
- 즉각적인 다음 단계
</principle>
</best_practices>

<prompt_caching_interaction>


프롬프트 캐싱(참고: [subagents.md](subagents.md#prompt_caching))은 안정적인 컨텍스트에서 가장 잘 작동한다.

<cache_friendly_context>
**캐싱을 위한 컨텍스트 구조화**:

```markdown
[CACHEABLE: Stable subagent instructions]
<role>...</role>
<focus_areas>...</focus_areas>
<workflow>...</workflow>
---
[CACHE BREAKPOINT]
---
[VARIABLE: Task-specific context]
Current task: ...
Recent context: ...
```

**장점**: 안정적인 지침은 캐시되고, 작업별 컨텍스트는 새로 유지된다. 캐시된 부분에서 90% 비용 절감.
</cache_friendly_context>

<cache_invalidation>
**컨텍스트 변경이 캐시를 무효화하는 경우**:
- 서브에이전트 프롬프트 업데이트
- 핵심 메모리 구조 변경
- 컨텍스트 재구성

**완화**: 안정적인 콘텐츠(역할, 워크플로, 제약)를 가변 콘텐츠(현재 작업, 최근 기록)와 분리하라.
</cache_invalidation>
</prompt_caching_interaction>
