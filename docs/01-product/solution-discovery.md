# Solution Discovery

## Document Status

[FACT] Workflow 단계: 3. Solution Discovery

[FACT] 상태: Approved

[FACT] 승인일: 2026-08-25 Asia/Seoul

[FACT] 승인자: 프로젝트 사용자 및 소유자

[FACT] 작성 기준일: 2026-08-25 Asia/Seoul

[FACT] 이 문서는 승인된 [Problem Definition](problem.md)과 [Research / JTBD](research.md)를 바탕으로 MVP에 적용할 수 있는 Solution Approach를 비교합니다.

[FACT] 이 문서는 Feature Prioritization, Product Specification, Technical Requirements, Architecture, 데이터 모델, 구현 기술 또는 AI 제공자를 확정하지 않습니다.

[FACT] 사용자가 2026-08-25에 아래 네 가지 Solution 결정을 모두 승인했습니다.

[FACT] 사용자는 기존 계획과 이 Repository의 승인 기준이 충돌할 때 현재 승인된 Problem Definition, Research / JTBD와 Current Product Guardrails를 적용한다고 확인했습니다.

## Discovery Question

[INFERENCE] 이번 단계의 핵심 질문은 다음과 같습니다.

> GeekNews RSS 하나가 제공하는 제한된 정보만 사용하면서, 한 명의 사용자가 중요한 한국어 IT 기사를 하루 두 번 빠르게 판단하고 월별 기술 흐름을 확인할 수 있도록, 추가 월 운영비 0원과 최대 100건/일의 초기 기준 안에서 신뢰 가능한 큐레이션을 어떤 방식으로 구성할 것인가?

## Approved Inputs and Guardrails

- [FACT] 사용자는 프로젝트 소유자 한 명이며 매일 10:00와 22:00 KST에 Discord 결과를 확인합니다.
- [FACT] MVP 수집원은 GeekNews RSS 하나이고 News, Ask와 Show를 모두 일반 후보로 처리합니다.
- [FACT] source type 또는 title prefix만으로 Ask와 Show를 조기 제외하지 않습니다.
- [FACT] RSS의 제목, HTML content, GeekNews topic link와 관련 metadata만 저장·처리하며 외부 원문 기사 본문은 수집하지 않습니다.
- [FACT] 일일 결과는 이전 발송 이후 수집된 기사 중 중요도순 최대 10개이고, 제목, 2~3문장 요약, 키워드와 링크를 포함합니다.
- [FACT] 홍보성 의심 기사는 주요 목록에서 제외하고 제외 건수만 표시합니다.
- [FACT] 월별 Insight는 주제 비중과 증감, 신규·급증 키워드와 주요 주제별 대표 기사를 포함합니다.
- [FACT] Raw RSS, 기사별 AI 결과와 월별 Insight의 Retention은 각각 3개월, 12개월, 무기한입니다.
- [FACT] MVP에서는 무료 AI 제공자 하나만 연동하고 무료 한도 소진 후 유료 호출로 자동 전환하지 않습니다.
- [FACT] 추가 월 운영비 상한은 0원이고 초기 처리 기준은 최대 100건/일입니다.
- [FACT] 기사 전달 목표는 게시 후 최대 13시간이며 각 발송 배치는 30분 이내 완료가 목표입니다.
- [INFERENCE] 사용자 제공 표본에서는 50개 중 48개가 RSS title과 content만으로 보수적인 2문장 요약에 충분했으므로 상세 페이지 수집은 현재 Solution 후보에 포함하지 않습니다.

## Evaluation Criteria

1. [INFERENCE] **JTBD 적합성**: 중요 기사 탐색 시간과 홍보성 검토 부담을 줄이고 장기 추세를 파악할 수 있는가?
2. [INFERENCE] **중요 기사 누락 위험**: 규칙이나 모델 판단 때문에 가치 있는 기사를 후보 단계 또는 최종 선택 단계에서 잃을 가능성이 어느 정도인가?
3. [INFERENCE] **사실 충실성과 추적 가능성**: RSS에 없는 내용을 만들지 않고 결과의 판단 근거를 재검토할 수 있는가?
4. [INFERENCE] **MVP Guardrail 적합성**: 단일 RSS, 외부 원문 미수집, 단일 무료 AI 제공자와 월 0원 조건을 지킬 수 있는가?
5. [INFERENCE] **비용 통제**: 최대 100건/일에서 무료 AI 할당량과 요청량을 예측하고 제한할 수 있는가?
6. [INFERENCE] **운영 복잡도와 복구 가능성**: 재실행, 부분 실패, AI 일시 장애와 결과 변동을 다룰 수 있는가?
7. [INFERENCE] **월별 분석 일관성**: 기사별 주제·키워드·판정 결과를 월별 비교에 재사용할 수 있는가?

## Approach A — Rules-first Candidate Gate with AI Enrichment

### Concept

[INFERENCE] 모든 RSS entry를 수집 후보로 받아들인 뒤, 관심 주제 keyword, 명시적 제외 pattern과 고정 점수 같은 결정적 규칙으로 AI 처리 후보를 넓게 선별합니다. 통과한 기사만 단일 AI 제공자가 요약과 keyword 생성을 보조하고, 최종 중요도와 홍보성 처리는 규칙 점수를 중심으로 결정합니다.

[FACT] 이 접근도 source type만으로 News, Ask 또는 Show를 제외하지 않고 외부 원문을 수집하지 않아야 합니다.

### Advantages

- [INFERENCE] AI에 보내는 기사 수를 줄일 수 있어 무료 할당량과 처리 시간을 가장 직접적으로 통제할 수 있습니다.
- [INFERENCE] 같은 입력과 규칙에는 같은 결과를 내므로 재실행과 판정 설명이 비교적 쉽습니다.
- [INFERENCE] AI가 일시적으로 실패해도 후보 판별과 일부 집계를 계속할 여지가 있습니다.

### Disadvantages and Trade-offs

- [INFERENCE] 새 기술명, 동의어와 맥락을 keyword 규칙이 놓치면 중요한 기사가 AI 처리 전에 사라질 수 있습니다.
- [INFERENCE] 홍보성 여부가 문맥에 따라 달라지는 경우 단순 pattern은 False Positive와 False Negative를 만들기 쉽습니다.
- [INFERENCE] 규칙을 지속해서 보정해야 하므로 초기 비용은 낮아도 운영자 판단과 유지보수 부담이 누적될 수 있습니다.
- [INFERENCE] 규칙으로 걸러진 기사들이 월별 분모와 keyword 추세에서 빠지면 Insight가 기존 관심 keyword에 편향될 수 있습니다.

### MVP Fit, Cost, Complexity and Main Risk

- [INFERENCE] **MVP 적합성: 보통** — Guardrail에는 맞출 수 있지만 중요한 기사 누락을 줄이려는 JTBD에는 약점이 있습니다.
- [INFERENCE] **AI 비용 압력: 낮음** — 사전 gate를 통과한 기사만 AI를 사용합니다.
- [INFERENCE] **운영 복잡도: 보통** — 실행은 단순하지만 규칙 목록, 점수와 예외를 계속 관리해야 합니다.
- [INFERENCE] **주요 위험** — 보이지 않는 사전 제외가 일일 큐레이션과 월별 Insight 모두를 왜곡할 수 있습니다.

## Approach B — AI-first End-to-end Curation

### Concept

[INFERENCE] 모든 RSS entry의 title과 content를 단일 AI 제공자에 전달하여 요약, 주제, keyword, 중요도, 홍보성 판단과 최종 순위까지 한 흐름에서 생성합니다. 애플리케이션 측 처리는 필수 형식 확인과 Discord 전달에 집중합니다.

### Advantages

- [INFERENCE] 고정 keyword에 없는 신기술과 문맥을 이해할 가능성이 높고, 규칙 작성 없이 여러 판단을 빠르게 실험할 수 있습니다.
- [INFERENCE] 요약, 분류와 순위가 같은 문맥을 사용하므로 초기 solution 개념은 가장 단순합니다.
- [INFERENCE] 관심 주제와 홍보성처럼 경계가 모호한 판단에 자연어 기준을 적용하기 쉽습니다.

### Disadvantages and Trade-offs

- [INFERENCE] 모든 기사와 모든 핵심 판단이 AI에 의존하므로 무료 할당량, rate limit 또는 제공자 장애의 영향이 가장 큽니다.
- [INFERENCE] 같은 입력의 점수와 순위가 달라질 수 있고 최종 선택 이유를 일관되게 재현하기 어렵습니다.
- [INFERENCE] 요약, 분류와 최종 순위를 하나의 응답에 강하게 결합하면 한 필드의 오류가 전체 기사 처리 실패로 이어질 수 있습니다.
- [INFERENCE] 모델이 RSS에 없는 사실을 보완하거나 저정보 항목을 억지로 확장할 위험이 있습니다.
- [INFERENCE] 모델·prompt 변화로 주제 label과 keyword 기준이 흔들리면 전월 비교의 일관성이 낮아질 수 있습니다.

### MVP Fit, Cost, Complexity and Main Risk

- [INFERENCE] **MVP 적합성: 조건부** — 단일 AI와 외부 원문 미수집 조건은 지킬 수 있지만 월 0원과 안정성은 실제 무료 한도 검증에 크게 의존합니다.
- [INFERENCE] **AI 비용 압력: 높음** — 모든 후보를 처리하고 최종 판단도 AI가 담당합니다.
- [INFERENCE] **운영 복잡도: 초기에는 낮음, 품질 운영은 높음** — 구성 요소는 적지만 결과 변동, 평가와 장애 대응이 어렵습니다.
- [INFERENCE] **주요 위험** — AI 제공자 또는 응답 품질이 단일 실패 지점이 되어 큐레이션 전체의 신뢰성을 좌우합니다.

## Approach C — Evidence-bounded AI Judgment with Deterministic Hard Guardrails

### Concept

[INFERENCE] News, Ask와 Show를 포함한 모든 RSS entry를 후보로 유지하고 먼저 필수 field와 입력 안전성을 확인합니다. 단일 AI 제공자는 RSS에 명시된 title과 content 안에서 보수적인 요약, 주제, keyword, 포함 추천, 상대적 중요도, 홍보성 판단과 근거를 구조화해 제안합니다. 후속 하드 가드레일은 RSS 근거 범위, 필수 결과와 형식, 최대 10개, 신규 기사 0건 시 미발송, 무료 한도와 잘못된 응답·실패의 처리 경계를 통제합니다.

[INFERENCE] 기사별 요약, 근거와 주제·keyword 후보를 일일 발송과 월별 Insight의 공통 입력으로 재사용하고, 월별 단계에서 공통 taxonomy와 집계 기준으로 별도 정규화하면 반복 분석 요청과 월별 label 불일치를 줄일 수 있습니다.

[INFERENCE] 결정적인 부분은 AI의 의미 판단을 고정 점수로 다시 계산하는 정책이 아니라 입력 근거, 필수 형식, 출력 개수, 비용과 실패 범위를 통제하는 하드 가드레일입니다. 판단 기준, 결과 label과 정확한 실패 동작은 이후 Product Specification과 Technical Requirements에서 정해야 합니다.

### Advantages

- [INFERENCE] 의미 판단은 AI가 담당하고 RSS 근거, 필수 형식, 출력 개수와 비용 같은 절대 제약은 하드 가드레일이 통제하므로 품질과 운영 통제의 균형이 좋습니다.
- [INFERENCE] 근거와 판정 결과를 함께 검토할 수 있어 중요도·홍보성 오판과 요약의 근거 없는 확장을 진단하기 쉽습니다.
- [INFERENCE] 모든 source type을 후보로 유지하므로 Approach A의 조기 keyword 제외 위험을 줄일 수 있습니다.
- [INFERENCE] 기사별 공통 결과를 재사용하고 월별로 별도 정규화하면 일일 큐레이션과 월별 Insight 사이의 추적 가능성과 비교 기준을 유지할 수 있습니다.
- [INFERENCE] AI 의미 판단 오류와 하드 가드레일·처리 오류의 경계를 나눌 수 있어 부분 실패와 재처리 정책을 정의하기 쉽습니다.

### Disadvantages and Trade-offs

- [INFERENCE] AI 결과 형식과 하드 가드레일을 함께 정의해야 하므로 Approach B보다 초기 solution 규칙이 많습니다.
- [INFERENCE] 같은 입력에서도 model·prompt에 따라 포함 추천, 상대적 중요도와 홍보성 판단이 달라질 수 있어 지속적인 품질 평가가 필요합니다.
- [INFERENCE] 모든 후보에 AI 분석을 적용한다면 Approach A보다 무료 할당량 압력이 큽니다.
- [INFERENCE] AI 장애 중 어떤 결과를 보류하고 어떤 결과를 제한적으로 제공할지 별도 정책이 필요합니다.

### MVP Fit, Cost, Complexity and Main Risk

- [INFERENCE] **MVP 적합성: 높음** — 승인된 입력 범위를 유지하면서 누락 위험, 추적 가능성, 월별 재사용과 단일 무료 AI 조건을 함께 다룹니다.
- [INFERENCE] **AI 비용 압력: 보통** — 기사별 분석을 한 번 생성해 재사용하는 방향이지만 실제 요청·token 사용량 검증이 필요합니다.
- [INFERENCE] **운영 복잡도: 보통** — AI 의미 판단과 하드 가드레일의 책임을 함께 관리해야 하지만 실패 위치와 판정 근거를 분리할 수 있습니다.
- [INFERENCE] **주요 위험** — model·prompt 변화와 비결정성으로 최종 선택 품질이 흔들릴 수 있습니다.

## Comparative Assessment

[INFERENCE] 아래 평가는 승인된 요구와 현재 Research 근거에 따른 상대 비교이며 실제 AI 후보의 품질·할당량 검증 결과에 따라 달라질 수 있습니다.

| Criterion | Approach A: Rules-first | Approach B: AI-first | Approach C: Hybrid |
|---|---|---|---|
| JTBD 전체 충족 | 보통 | 높음 | 높음 |
| 중요한 기사 조기 누락 위험 | 높음 | 낮음~보통 | 낮음 |
| 판정 재현성과 설명 가능성 | 높음 | 낮음 | 보통 |
| RSS 밖 사실 생성 통제 | 보통 | 낮음 | 높음 |
| 무료 AI 한도 압력 | 낮음 | 높음 | 보통 |
| 초기 solution 단순성 | 보통 | 높음 | 보통 |
| 지속적인 품질 운영 난이도 | 보통~높음 | 높음 | 보통 |
| 월별 label 일관성 | 보통 | 낮음~보통 | 높음 |
| 부분 실패 격리 가능성 | 높음 | 낮음 | 높음 |
| 현재 MVP Guardrail 적합성 | 보통 | 조건부 | 높음 |

## Selected Solution Direction

### Selected Approach

[FACT] 사용자가 **Approach C — Evidence-bounded AI Judgment with Deterministic Hard Guardrails를 MVP Solution 방향으로 승인했습니다.**

### Recommendation Rationale

1. [INFERENCE] 중요한 기사 누락을 줄이는 JTBD 때문에 불투명한 keyword gate로 AI 처리 전 후보를 좁히는 Approach A보다 모든 RSS entry를 후보로 유지하는 편이 적합합니다.
2. [INFERENCE] 홍보성 제외와 중요도순 최대 10개 선정은 사용자 경험에 직접 영향을 주므로 AI의 의미 판단 근거를 보존하고 RSS 근거, 필수 형식, 출력 개수와 비용은 하드 가드레일로 통제하는 편이 안전합니다.
3. [INFERENCE] 사용자 제공 표본의 96%는 RSS 정보만으로 보수적인 2문장 요약이 가능했으므로 외부 원문 수집 없이 근거 제한형 분석을 적용할 실질적 근거가 있습니다.
4. [INFERENCE] 기사별 요약, 근거와 주제·keyword 후보를 12개월 보존해 재사용하고 월별로 별도 정규화하면 추가 호출을 줄이면서 일일 결과와 월별 추세의 추적 가능성을 유지할 수 있습니다.
5. [INFERENCE] AI 제공자, prompt 또는 model이 바뀌어도 AI 의미 판단과 하드 가드레일의 경계를 분리하면 변경 영향을 확인하기 쉽습니다.

## Approved Solution Decisions

1. [FACT] MVP Solution 방향으로 Approach C를 채택합니다.
2. [FACT] 모든 News, Ask와 Show entry를 일반 후보로 유지하고 source type이나 단순 keyword만으로 AI 분석 전에 조기 제외하지 않습니다.
3. [FACT] AI가 포함 추천, 상대적 중요도와 홍보성 판단을 제안하고, 후속 정책은 RSS 근거, 필수 형식, 최대 10개, 실패와 비용 제한 같은 하드 가드레일을 적용하는 3B를 채택합니다.
4. [FACT] 기사별 요약, 근거, 주제·keyword 후보는 재사용하되 월별 단계에서 공통 taxonomy와 집계 기준으로 정규화하고 월별 결과를 별도 보존하는 4C를 채택합니다.

[FACT] 사용자가 2026-08-25에 위 네 항목을 승인했습니다.

### Decision 3 — Alternatives and Selection

[FACT] 3번은 AI 분석 결과와 최종 큐레이션 결정 사이의 책임 경계를 선택하는 항목입니다.

| Option | Direction | Advantages | Trade-offs | AI Cost Pressure | Operations |
|---|---|---|---|---|---|
| 3A. Policy-led hybrid | AI는 신호와 근거를 제안하고 명시적 점수·임계값이 최종 순위와 제외를 결정 | 재현성과 설명 가능성이 높고 같은 입력에 같은 후속 판단을 적용하기 쉬움 | 중요도·홍보성의 문맥을 고정 규칙이 충분히 표현하지 못할 수 있고 정책 보정 부담이 큼 | 보통 | 높음 |
| 3B. Model-led judgment with hard guardrails | AI가 포함 추천, 상대적 중요도와 홍보성 판단을 제안하고 후속 정책은 RSS 근거, 필수 형식, 최대 10개, 실패·비용 제한 같은 하드 가드레일만 적용 | 의미 판단을 AI에 맡기면서 형식·범위·비용은 통제하고 임의의 세밀한 점수 공식을 줄일 수 있음 | 동일 입력의 선택이 달라질 수 있고 model·prompt 변화가 최종 결과에 직접 영향을 줌 | 보통 | 보통 |
| 3C. Two-pass AI review | 첫 AI 분석 후 같은 단일 제공자의 두 번째 검토가 후보 간 상대 순위와 홍보성 판정을 재평가하고 하드 가드레일을 적용 | 후보 간 비교와 자기검토 기회가 있어 복합적인 선택에 유리할 수 있음 | 요청량·지연·실패 지점이 늘고 두 번의 AI 판단도 재현성을 보장하지 않음 | 높음 | 높음 |

[INFERENCE] MVP에는 **3B**를 추천합니다. 중요도와 홍보성 기준이 아직 정량화되지 않은 상태에서 3A의 세밀한 점수·임계값을 먼저 만들면 false precision이 생길 수 있고, 3C는 월 0원과 배치 시간 목표에 불필요한 압력을 줄 가능성이 큽니다.

[INFERENCE] 3B를 선택해도 최종 결과를 AI에 무제한 위임하지 않습니다. RSS 근거 밖 내용 금지, 필수 결과 확인, 최대 10개 제한, 신규 기사 0건 시 미발송과 무료 한도 초과 시 유료 전환 차단은 하드 가드레일이 적용합니다. AI 실패를 보류·재시도하거나 제한된 결과로 처리할 정확한 방식은 이후 단계에서 결정합니다.

[FACT] 사용자가 2026-08-25에 3B를 선택했습니다.

### Decision 4 — Alternatives and Selection

[FACT] 4번은 기사별 AI 결과를 일일 큐레이션과 월별 Insight에서 어느 범위까지 공유할지 선택하는 항목입니다.

| Option | Direction | Advantages | Trade-offs | AI Cost Pressure | Operations |
|---|---|---|---|---|---|
| 4A. Full reuse | 일일 처리에서 만든 요약, 주제, keyword와 판정 결과를 월별 Insight에 그대로 재사용 | 추가 기사별 AI 호출이 없고 일일·월별 결과의 추적과 재현이 쉬움 | 초기 오분류가 월별 통계에도 그대로 반영되고 월별 분석 목적에 맞춘 정규화가 어려움 | 낮음 | 낮음 |
| 4B. Independent daily and monthly analysis | 일일 큐레이션과 월별 Insight가 같은 기사를 각 목적에 맞게 별도로 분석 | 각 작업에 최적화된 prompt와 분류 체계를 사용할 수 있음 | 기사별 재호출이 늘고 일일·월별 label이 달라질 수 있으며 월 0원 목표에 가장 불리함 | 높음 | 높음 |
| 4C. Layered reuse with monthly normalization | 기사별 요약, 근거, 주제·keyword 후보는 재사용하되 월별 단계가 공통 taxonomy와 집계 기준으로 정규화하고 월별 결과를 별도 보존 | 반복 기사 분석을 억제하면서 월별 비교 기준과 불변 monthly snapshot을 만들 수 있음 | 정규화 규칙과 결과 version 경계를 정의해야 하며 4A보다 운영 개념이 추가됨 | 낮음~보통 | 보통 |

[INFERENCE] MVP에는 **4C**를 추천합니다. 기사별 AI 결과 12개월 보존과 월별 Insight 무기한 보존 요구를 활용하면서도, 일일 분류를 월별 통계에 무비판적으로 복사하는 문제를 줄일 수 있습니다.

[INFERENCE] 4C는 월말에 모든 기사를 AI로 다시 분석한다는 뜻이 아닙니다. 기본 방향은 보존된 기사별 결과를 입력으로 재사용하고 월별 비교에 필요한 normalization·aggregation만 별도로 수행하는 것입니다.

[FACT] 사용자가 2026-08-25에 4C를 선택했습니다.

[UNKNOWN] 월별 normalization에 결정적 규칙만 사용할지 같은 단일 AI 제공자의 보조를 허용할지는 Product Specification과 Technical Requirements에서 결정해야 합니다.

## Remaining Unknowns

### Deferred to Later Workflow Stages

- [UNKNOWN] 중요한 기사 누락과 비중요 기사 포함 중 어느 오류를 더 크게 볼지는 Product Specification에서 결정해야 합니다.
- [UNKNOWN] 홍보성 False Positive와 False Negative 중 어느 오류를 더 엄격히 제한할지는 Product Specification에서 결정해야 합니다.
- [UNKNOWN] 저정보 entry를 1문장으로 허용할지, 요약 불충분으로 표시할지, 주요 후보에서 제외할지는 Product Specification에서 결정해야 합니다.
- [UNKNOWN] 관심 주제, 중요도와 홍보성 판단 기준, 결과 label, 근거 형식 및 필요한 경우 사용할 confidence·임계값은 Product Specification에서 결정해야 합니다.
- [UNKNOWN] 판정 근거, 점수, model·prompt 정보를 어떤 수준으로 보존할지는 Product Specification과 Data / Interface Design에서 결정해야 합니다.
- [UNKNOWN] 실제 무료 AI 후보의 한국어 품질, 무료 할당량, rate limit, 데이터 이용 조건과 유료 전환 차단 방법은 Technical Requirements 전에 공식 자료와 표본으로 검증해야 합니다.
- [UNKNOWN] 무료 AI 실패·한도 소진 시 기사 처리를 보류할지 제한된 결과를 제공할지는 Product Specification과 Technical Requirements에서 결정해야 합니다.
- [UNKNOWN] 월별 Insight의 전달 채널, 생성 시점, 집계 공식과 대표 기사 기준은 Product Specification에서 결정해야 합니다.
- [UNKNOWN] GeekNews polling 허용 기준, conditional request, ID·link 안정성, 시각 의미와 갱신 동작은 Technical Requirements와 Data / Interface Design 전에 검증해야 합니다.
- [UNKNOWN] Approach C가 최대 100건/일을 월 0원과 배치 30분 이내에 처리할 수 있는지는 AI 후보 검증 전에는 확정할 수 없습니다.

## Stage Boundary

- [FACT] 이번 단계에서는 Feature 우선순위를 정하지 않습니다.
- [FACT] 이번 단계에서는 acceptance criteria, 점수 공식, 임계값, 수집 주기, 데이터 schema, component 구조, 기술 stack 또는 배포 방식을 정하지 않습니다.
- [FACT] 구현, 코드와 테스트는 작성하지 않습니다.
- [FACT] 사용자 승인과 단계 종료 commit/push 완료 또는 명시적 연기 전에는 Feature Prioritization으로 이동하지 않습니다.

## Solution Discovery Exit Criteria

- [FACT] 비교 가능한 세 가지 Solution Approach를 정리했습니다.
- [FACT] 각 Approach의 장단점, Trade-off, MVP Guardrail 적합성, 비용 압력, 운영 복잡도와 주요 위험을 비교했습니다.
- [FACT] 추천안과 추천 근거를 분리해 제시했습니다.
- [FACT] 미결정 사항을 `[UNKNOWN]`으로 유지하고 이후 단계에서 다룰 항목을 구분했습니다.
- [FACT] 사용자가 2026-08-25에 네 가지 Solution 결정을 확인하고 Solution Discovery를 승인했습니다.
- [UNKNOWN] 단계 종료 commit/push 절차가 남아 있습니다.
