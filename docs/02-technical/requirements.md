# Technical Requirements

## Document Status

[FACT] Workflow 단계: 6. Technical Requirements

[FACT] 상태: Draft

[FACT] 작성 기준일: 2026-08-26 Asia/Seoul

[FACT] 작성자 역할: Technical Requirements Analyst, Senior Data Engineer, Software Architect

[FACT] 기준 문서는 승인된 [Product Specification](../01-product/product-spec.md)과 그 Acceptance Criteria AC-01~AC-24입니다.

[FACT] 사용자는 2026-08-26에 이 문서에서 사용할 P0-HG, P0, P1-V 우선순위와 Requirement ID 범주를 승인했습니다.

[FACT] 사용자는 2026-08-26에 Discord batch 검토 완료, 부정 reaction, 암묵적 수용, 누락 기사 제출·사유 회신·feedback 및 recall 분류 정책을 승인했습니다.

[FACT] 사용자 순차 검토에서 FR-001~FR-024 Functional Requirements의 내용과 관련 교차 수정안을 승인했습니다.

[FACT] 다음 순차 검토 시작점은 NFR-REL-001이며, NFR-REL-001은 설명만 진행하고 아직 승인하거나 수정하지 않았습니다.

[FACT] FR 검토 중 승인된 수량·복구·feedback 결정을 동기화하기 위해 NFR-REL-002, DR-002, DR-008, DR-009, DR-011과 일부 Traceability 문구를 보강했지만 NFR·DR 범주의 순차 검토는 아직 완료하지 않았습니다.

[FACT] 이 문서는 구현 가능한 기술 요구사항과 검증 계약을 정의하지만 Architecture, 데이터 모델, 인프라 또는 코드 구현 방식을 확정하지 않습니다.

[UNKNOWN] 이 Draft의 전체 내용에 대한 사용자 최종 승인은 아직 완료되지 않았습니다.

[UNKNOWN] NFR 17개, DR 14개, EXT 25개와 VR 11개의 순차 검토 및 전체 정합성 최종 확인이 남아 있습니다.

## Purpose

[INFERENCE] 이 문서의 목적은 승인된 MVP-A 제품 동작과 품질 기준을 구현·시험·운영에서 확인할 수 있는 기술 요구사항으로 변환하는 것입니다.

[INFERENCE] 핵심 기술 질문은 다음과 같습니다.

> GeekNews RSS 근거와 추가 월 운영비 0원이라는 제약 안에서 후보 누락·중복·근거 밖 생성과 실패 오표시를 방지하고, 하루 두 번의 Discord 결과와 MVP-A 품질 판정에 필요한 증거를 어떻게 요구사항으로 정의할 것인가?

## Approved Source Traceability

| Source | Approved scope used by this document |
|---|---|
| [Problem Definition](../01-product/problem.md) | [FACT] 한 명의 사용자, GeekNews RSS 하나, 월 0원, 최대 100건/일, 13시간 전달과 30분 batch 목표 |
| [Research / JTBD](../01-product/research.md) | [FACT] Atom feed, News·Ask·Show 전체, RSS title·content·topic link, 저정보 예외와 미확인 외부 계약 |
| [Solution Discovery](../01-product/solution-discovery.md) | [FACT] 근거 제한형 AI 판단, 결정적 Hard Guardrail, 후보 자격 유지와 비무음 fallback |
| [Feature Prioritization](../01-product/feature-prioritization.md) | [FACT] F01~F07 최소 범위와 F10이 MVP-A이며 월별 Insight와 자동 Retention은 MVP-B |
| [Product Specification](../01-product/product-spec.md) | [FACT] 사용자 시나리오, 품질 지표, Hard Gate와 AC-01~AC-24 |
| 2026-08-26 사용자 승인 | [FACT] Discord reaction 기반 feedback, batch 검토 완료, 암묵적 수용률, 구조화된 slash command와 누락 원인 분류 |

## Scope and Boundary

### In Scope

- [FACT] MVP-A Functional Requirements
- [FACT] Reliability, Performance, Latency, Cost, Data Quality, Observability, Security, Recoverability, Maintainability와 Timezone 요구사항
- [FACT] MVP-A에서 저장·추적·측정해야 하는 데이터 범주와 품질·보존·접근 요구
- [FACT] GeekNews RSS, 무료 AI, Discord와 feedback 외부 계약
- [FACT] Acceptance Criteria와 Hard Gate의 검증 요구 및 Traceability Matrix

### Out of Scope for This Stage

- [FACT] 최종 AI 제공자, SDK, model과 prompt
- [FACT] Python library와 framework
- [FACT] DBMS, table, column, index와 constraint
- [FACT] 상태 전이 구현 방식
- [FACT] retry 횟수와 backoff
- [FACT] polling 주기와 CronJob 구성
- [FACT] Queue, Worker, API와 component 구조
- [FACT] URL 정규화와 identity 알고리즘
- [FACT] 중요도 점수 공식, 홍보성 label·임계값과 동률 처리
- [FACT] 인프라와 배포 방식
- [FACT] 장기 Discord 장애 backlog 상한과 분할 정책
- [FACT] Discord slash command의 정확한 이름, parameter와 표시 UI

## Requirement Conventions

### Fact and Decision Tags

- [FACT] Repository, 공식 자료 또는 사용자가 승인한 내용
- [ASSUMPTION] 진행을 위해 임시로 둔 가정
- [INFERENCE] 사실과 가정에서 도출한 제안 요구사항
- [UNKNOWN] 외부 검증, Architecture, Data / Interface Design 또는 사용자 결정이 필요한 내용

### Priority

| Priority | Meaning | Completion effect |
|---|---|---|
| P0-HG | [FACT] 위반 0건이어야 하는 Hard Gate 또는 그 직접 보장 요구 | [FACT] 한 건이라도 발생하면 MVP-A 품질 검증 통과 후보가 될 수 없음 |
| P0 | [FACT] MVP-A 일일 가치 흐름을 제공하기 위한 필수 요구 | [FACT] 미충족 시 MVP-A 기능이 완성되지 않음 |
| P1-V | [FACT] MVP-A 품질·비용·실현 가능성 판정에 필요한 검증·학습 요구 | [FACT] 미충족 시 MVP-A 통과 여부를 증명할 수 없음 |

[FACT] P1-V는 선택 기능이나 MVP-B를 의미하지 않으며 MVP-A 품질 판정 전까지 필요합니다.

### Requirement ID

| Prefix | Category |
|---|---|
| FR | Functional |
| NFR-REL | Reliability and Idempotency |
| NFR-PERF | Performance and Capacity |
| NFR-LAT | Latency |
| NFR-COST | Cost Control |
| NFR-DQ | Data Quality |
| NFR-OBS | Observability |
| NFR-SEC | Security and Secret Management |
| NFR-REC | Recoverability |
| NFR-MNT | Maintainability |
| NFR-TIME | Timezone Handling |
| DR | Data |
| EXT-GN | GeekNews RSS |
| EXT-AI | Free AI Provider |
| EXT-DC | Discord |
| EXT-FB | Feedback |
| VR | Verification |

## Product and Technical Terms

- [FACT] RSS 관찰 entry는 정상적으로 parsing된 Raw RSS에서 확인한 entry이며 신규 후보, 기존·중복 관찰과 후보 생성 불가능 입력 오류를 포함합니다.
- [FACT] 후보는 RSS 관찰 entry 중 하나의 논리적 기사로 연결해 현재 또는 이후 처리할 자격을 확인할 수 있는 entry이며, 후보 생성 불가능 입력 오류와 기존·중복 관찰은 신규 후보 수에 포함하지 않습니다.
- [FACT] 신규 후보는 직전 완료된 신규 처리 구간 이후 현재 예정 batch의 처리 범위에 처음 포함된 후보이며, 신규 처리 구간은 Discord 성공 전달 범위와 구분합니다.
- [FACT] 미처리 후보는 AI 실패, 무료 한도 또는 처리 제약으로 필요한 분석을 완료하지 못한 후보입니다.
- [FACT] 저정보 후보는 RSS 입력이 충실한 2~3문장 요약에 부족하지만 후보 자격을 유지하는 entry입니다.
- [FACT] 전달 성공은 Discord가 논리적 전달 결과를 수락했다는 증거가 확인된 상태입니다.
- [FACT] batch 검토 완료는 사용자가 하나의 정규 발송 기사 세트 전체를 확인했다고 대표 메시지의 ✅ reaction으로 표시한 상태입니다.
- [FACT] 암묵적 수용은 검토 완료 batch에서 😕, 🚫 또는 📣 부정 reaction이 없는 전달 기사입니다.
- [FACT] 암묵적 수용은 명시적으로 유용하다고 평가했다는 뜻이나 GeekNews topic 또는 외부 원문을 열었다는 뜻이 아닙니다.

## Functional Requirements

[INFERENCE] 아래 요구사항은 승인된 Product Specification을 구현·검증 가능한 계약으로 변환한 Draft입니다.

| ID | Priority | Requirement | Product source | Verification | Undecided dependency |
|---|---|---|---|---|---|
| FR-001 | P0 | GeekNews Atom HTTP 응답을 수집하고 feed·entry 구조 및 제품 필수 입력의 존재·형식·파싱 가능성을 검증하여 feed 단위 수집 결과와 entry 단위 입력 검증 결과를 구분해야 한다. | F01, End-to-end Flow 1 | 정상·유효 빈 feed, 문서 구조·namespace·encoding 오류, 잘못되거나 잘린 XML, 필수 field별 누락·빈값·형식 오류, 선택 field 누락, 정상·오류 entry 혼합, 한국어·HTML·XML entity, 최대 100건과 안전하지 않은 XML fixture의 입력 계약 및 반복 검증 테스트 | [UNKNOWN] 필수·선택 field의 정확한 구분 |
| FR-002 | P0-HG | 파싱 가능한 GeekNews feed에서 관찰한 모든 entry는 하나의 고유 신규 후보, 기존 후보에 연결된 재관찰·중복 또는 후보 생성 불가능 입력 오류 중 하나의 대표 입력 결과를 가져야 하며 기록 없이 제외되어서는 안 된다. 파싱된 RSS 관찰 entry 수는 세 대표 결과의 합계와 일치해야 하고 기존·중복 관찰과 후보 생성 불가능 입력 오류를 신규 후보 수에 포함해서는 안 된다. feed 전체 parsing 실패는 entry 단위 입력 오류나 정상 신규 0건과 구분해야 한다. | End-to-end Flow 1~2, AC-01~AC-02, 미처리 후보 비무음 Hard Gate | 신규 entry, 동일 feed 내 중복, 이전 수집 결과와 중첩된 entry, 후보 생성 불가능 입력 오류, 정상·중복·오류 혼합, 복수 field 오류, feed 전체 parsing 실패와 반복 실행 fixture에서 대표 결과와 단계별 수량 불변식을 검사 | [UNKNOWN] 필수 field와 후보 생성 가능 경계, link·Atom id 안정성, identity·URL 정규화 알고리즘, 복수 오류의 대표 결과 우선순위 |
| FR-003 | P0-HG | 명시적인 입력 오류로 후보 처리가 불가능한 경우를 제외하고, 파싱된 GeekNews News·Ask·Show entry는 모두 수집·처리 후보 자격을 유지해야 한다. 명시적 source type 또는 그 추정값, title prefix, 관심 keyword의 존재·부재만으로 후보 자격을 제거해서는 안 된다. 후보 자격은 최종 선정 또는 동일한 수준의 AI 처리를 보장하지 않으며, 처리하지 못한 후보는 명시적인 결과를 가져야 한다. | AC-01, AC-02, AC-07 | News·Ask·Show, prefix 존재·부재, source type 추정 가능·불가, 관심 keyword 존재·부재와 관심 주제 밖 고중요도 fixture에서 후보 자격이 동일하게 유지되는지 검사하고 저정보·AI 한도·최종 미선정을 후보 조기 제외와 구분해 모든 미처리 결과가 수량에 포함되는지 확인 | [UNKNOWN] source type 추론·저장·표시 여부, 무료 AI 제약에 따른 실제 fallback 정책, 입력 오류와 제한 처리 가능 후보의 정확한 경계 |
| FR-004 | P0-HG | 반복·중첩 수집, feed 순서 변경, batch 재실행과 장애 후 재개에서도 동일한 RSS 관찰은 하나의 논리적 기사 identity에 연결되어야 하며, 동일 사용자·전달 대상에 같은 기사가 둘 이상의 Discord 수락 결과를 만들지 않아야 한다. 확인된 성공 발송은 다시 시도하지 않고, Discord 수락 여부가 불명확한 시도는 성공 또는 실패로 추정하거나 무조건 재발송하지 않은 채 명시적인 대조 대상으로 유지해야 한다. | AC-04, AC-17, Scenario 8, 동일 기사 중복 발송 Hard Gate | 동일·순서 변경·중첩 feed, feed 내부 중복, 성공 batch 재실행, 단계별 중단·재개, 동시 batch, Discord 명확한 실패·수락 후 응답 유실·수락 불명확 상태에서 논리 기사·발송 결과와 실제 Discord message를 대조 | [UNKNOWN] link·Atom id 안정성, URL 정규화와 identity 알고리즘, 고유성 범위, 동시 실행 제어, Discord 수락 대조 방식과 최종 전달 인터페이스 |
| FR-005 | P0-HG | 각 예정 batch는 RSS 수집 범위, 신규 후보 처리·선정 구간, 재사용 가능한 논리적 발송 결과와 Discord 수락이 확인된 성공 전달 범위를 서로 구분해 추적해야 한다. 완료된 선정 결과는 기사 내용·당시 상태·수량·판단 및 출력 version과 함께 보존하고 Discord 실패 때문에 현재 정책으로 다시 생성하거나 과거 정상 미선정 기사를 다음 신규 처리 구간에 자동 편입해서는 안 된다. 수집·분석·선정 성공만으로 전달 성공 범위를 전진시켜서는 안 되며, 선정됐지만 Discord가 수락하지 않았거나 수락 여부가 불명확한 논리적 전달 단위는 성공 범위에서 제외하고 각각 복구 또는 대조 대상으로 유지해야 한다. 수락이 확인된 전달 단위는 재실행 시 복구 대상으로 다시 포함하지 않아야 한다. | AC-04, AC-17~AC-19, Recovery Scenarios, Discord 미수락 성공 처리 Hard Gate | 수집 성공 후 AI·선정·Discord 단계별 실패, 신규 30건·선정 10건·정상 미선정 20건의 Discord 실패 후 다음 신규 5건, 여러 전달 단위의 부분 수락, Discord 수락 후 응답 유실, 단계별 중단·재개, 신규 0건이지만 복구 대상이 있는 batch, 지연·현재 논리적 구간 혼합 발송과 성공 batch 재실행에서 저장 결과·AI 호출·실제 Discord message를 대조 | [UNKNOWN] 수집·처리·전달 범위의 저장 표현, 논리적 발송 결과와 전달 단위의 구조·메시지 분할, 부분 수락 batch 상태, 수락 대조 방법, 상태 전이·동시성 제어와 장기 backlog 정책 |
| FR-006 | P0-HG | AI의 기사 내용 입력과 사실 근거는 수집된 해당 entry의 RSS title과 content 또는 description에 제한해야 한다. 외부 원문·GeekNews 상세 페이지·댓글·검색 결과 또는 모델의 외부 지식으로 보완한 사실을 결과에 포함해서는 안 되며, 말줄임표 뒤의 누락 내용을 추정해서는 안 된다. RSS 입력은 실행 지시가 아닌 신뢰할 수 없는 데이터로 취급하고, 생성된 핵심 주장·keyword·판단 근거는 제공된 RSS 입력까지 역추적할 수 있어야 한다. GeekNews topic link와 운영 metadata는 AI가 생성하지 않고 저장된 RSS 값에서 연결해야 한다. | Evidence-bounded Analysis, AC-03, AC-05, 중대한 RSS 근거 밖 사실 Hard Gate | 실제 AI 요청 payload와 저장 RSS 대조, 외부 HTTP·검색·브라우징 미사용 감사, HTML·encoding 전처리 대조, 말줄임표·저정보·사전 지식 유도·prompt injection fixture, claim-level 근거 대조와 AI 생성 URL 미사용 검사로 중대한 근거 밖 사실 0건·근거 충실도 95% 이상을 측정 | [UNKNOWN] HTML 정리·입력 직렬화, prompt·model·결과 version 표현, claim-근거 연결 형식, 중대한 오류 rubric과 외부 접근 차단·감사 방식 |
| FR-007 | P0 | 정상 분석으로 인정되는 기사별 결과는 검증 가능한 구조로 한국어 문장 구조를 기본으로 하되 제품명·고유 명사·약어와 널리 사용하는 영문 IT 용어를 원문 그대로 사용할 수 있는 표시 제목, RSS 근거 범위의 2~3문장 요약, RSS에서 도출한 keyword, 포함 추천, 상대적 중요도, 관심 주제 적합성, 홍보성 판단과 각 판단을 검토할 수 있는 최소 근거를 포함해야 한다. 결과는 입력 기사와 AI model·prompt·판단 정책·출력 계약의 version 또는 동등한 lineage에 연결되어야 한다. 필수 결과가 누락되거나 형식·근거 검증에 실패한 응답을 기본값으로 보완해 정상 결과로 기록해서는 안 된다. | Evidence-bounded Analysis, Normal Article Item, AC-05, AC-10, 최소 판단 근거·결과 version | 정상 응답과 필수 항목별 누락·빈값, 자료형·label·JSON 오류, AI 거부, 정상 후보의 2~3문장, 판단별 RSS 근거와 lineage를 검사하고 DB·API·SDK·async·cache·pipeline·제품명·version 등 영문 IT 용어를 허용하되 강제 번역의 의미 변경과 RSS 밖 수식어 추가를 차단 | [UNKNOWN] 구조화 schema, 한영 용어 기준·정규화, keyword 수, 판단 label·점수, 최소 근거 형식, version 조합, 오류 재시도·fallback과 Discord 표시 범위 |
| FR-008 | P0 | RSS 근거가 충실한 정상 2~3문장 요약에 부족한 후보는 입력 오류, AI 실패와 무료 한도 미처리와 구분되는 저정보 결과를 가져야 하며 후보 자격을 유지해야 한다. 저정보 후보가 선정되면 검증된 표시 제목 또는 저장된 RSS title을 반드시 제공하고 그 출처를 추적하며, `정보 제한`과 근거가 허용하는 1문장 이하 설명을 제공하거나 충실한 설명이 불가능할 때 `RSS 제공 정보가 부족해 상세 요약을 생성하지 못했습니다`라는 승인 문구를 사용해야 한다. 확인 가능한 keyword와 저장된 GeekNews topic link만 제공하고 말줄임표 뒤나 외부 지식으로 내용을 보완해서는 안 되며, 저정보 선정 기사도 최대 10개 제한과 batch 수량 대조에 포함해야 한다. | Low-information Article Item, AC-11, 후보 자격 유지, RSS 근거 Hard Gate | 기존 Sufficient 48건·Limited 1건·Insufficient 1건과 Ask·짧지만 구체적·길지만 모호한·말줄임표·반복 fixture에서 저정보·입력 오류·AI 실패·quota 미처리를 구분하고 제목 누락 0건, AI 제목 부재 시 RSS title fallback·출처, `정보 제한`, 문장 수·승인 문구·keyword·stored link·최대 10개와 batch 수량을 검사 | [UNKNOWN] 정보 충분성 rubric, 저정보 중요도·선정 정책, Ask 품질, 판정 단계, 결과 구조·Discord 표현과 제목 fallback 추적 방식 |
| FR-009 | P0 | 판단 가능한 후보의 전체 IT 중요도와 사용자 관심 주제 적합성은 서로 덮어쓰지 않는 별도 결과와 최소 근거로 관리해야 하며, 판단 불가를 낮음으로 기록해서는 안 된다. 중요도는 RSS에서 확인되는 영향 범위, 변화의 실질성, 행동 가능성과 위험·긴급성을 근거로 판단하고 회사 인지도, source type 또는 keyword 하나만으로 확정해서는 안 된다. 관심 적합성은 승인된 관심 주제 정책에 따라 판단하되 keyword 단순 일치와 구분해야 한다. 관심 주제 밖이어도 전체 IT 중요도가 높은 후보는 최종 선정 가능성을 유지해야 하며, 최종 선정·정렬 결과가 두 원 판단값과 적용된 정책 version까지 역추적 가능해야 한다. | Importance, Interest and Promotional Judgment, AC-05~AC-07 | 중요도·관심 적합성 네 조합, keyword와 실제 적합성이 엇갈리는 기사, 관심 밖 고중요도·관심 높은 저중요도, 회사 인지도·source type 변형, 판단 불가·낮음과 관심 정책 변경 전후 결과에서 두 판단·최종 선정·version lineage를 대조 | [UNKNOWN] label·점수와 판단 rubric, 두 축의 조합·가중·정렬 관계, 동률 처리, 저정보 후보 판단과 관심 정책 version 관리 |
| FR-010 | P0 | 처리 가능한 후보의 홍보성 판단은 RSS 근거와 적용한 판단 정책 version에 연결되어야 한다. 제품·회사·출시·source type 또는 keyword 하나만으로 홍보성을 확정해서는 안 되며, 승인된 기준상 판매·가입 유도나 과장·자기홍보가 중심이라는 근거가 충분한 후보만 주요 목록에서 제외해야 한다. 홍보성이 애매하거나 판단 불가인 후보는 제외하지 않고 선정 가능성을 유지해야 하며, 제외 사유와 batch별 제외 건수를 결과와 일치하게 추적해야 한다. | Importance, Interest and Promotional Judgment, AC-08, AC-12, 홍보성 품질 목표 | 구체적 기술 정보 중심의 제품 출시, 가입·구매 유도 중심, 과장·자기홍보 중심, 애매한 기사와 회사명·source type·keyword 변형 표본에서 판단·제외 사유·batch 제외 건수를 대조하고 False Positive·False Negative를 계산 | [UNKNOWN] 홍보성 label, 근거 rubric, 제외 임계값, 표본 추출과 AI 판단·최종 제외 정책의 결합 방식 |
| FR-011 | P0 | 직전 완료된 신규 처리 구간 이후 현재 예정 batch에 처음 포함된 고유 신규 후보 중 정상 또는 저정보 등 선정 가능한 결과를 가진 후보에서 홍보성 제외 근거가 충분한 후보를 먼저 제외하고, 승인된 중요도 정책에 따라 정렬해 현재 기사 목록을 최대 10개까지 선정해야 한다. 기존·중복 관찰과 후보 생성 불가능 입력 오류를 선정 후보 또는 최대 제한 미선정 수에 포함해서는 안 된다. 선정 가능한 후보가 10개보다 적으면 실제 수만 선정하고, 저정보 선정 기사는 같은 10개 제한에 포함해야 한다. Batch 선정 결과는 전체 신규 후보 수, 선정 수, 최대 10개 제한으로 미선정된 수, 홍보성 제외 수와 미처리 수를 서로 구분해 산출·추적하고 같은 선정 단계 안에서 합계를 대조할 수 있어야 한다. 각 후보의 순위·선정 여부·미선정 또는 제외 이유와 적용한 정책 version을 추적해야 한다. 완료된 batch에서 정상 미선정된 후보와 지연 복구 기사는 다음 현재 신규 후보에 다시 포함하지 않으며, 지연 복구 기사의 별도 최대 10개는 현재 기사 제한에 포함하지 않는다. 미처리 후보는 정상 미선정으로 간주하거나 이 규칙으로 조용히 제외해서는 안 된다. | Selection, AC-09, AC-11~AC-12 | RSS 관찰 35건·신규 30건·중복 2건·입력 오류 3건, 후보 0·1·9·10·11·30·100건, 정상·저정보·미처리·홍보성·동률·기전달·복구를 포함해 단계별 순위·이유·수량·정책 version을 대조하고 신규 30건·선정 10건·제한 미선정 20건의 Discord 실패 후 다음 신규 5건에서 지연 10건·현재 5건·과거 미선정 재편입 0건과 원래 수량 보존을 검사 | [UNKNOWN] 중요도 점수·정렬, 관심 적합성과의 관계, 동률 처리, 제한 결과의 선정 가능 조건과 선정 정책 version 표현, 미처리 후보 재처리 정책 |
| FR-012 | P0 | Discord로 전달되는 모든 정상·저정보·복구 기사 항목은 승인된 제목 정책에 따른 표시 제목, 정보 충분성에 맞는 요약 또는 제한 문구, RSS 근거 keyword와 저장된 GeekNews topic link를 포함해야 한다. 각 완료 batch의 기사 항목, 정상·부분 상태와 FR-011에서 산출·검증한 신규 후보·선정·최대 제한 미선정·홍보성 제외·미처리·저정보 수를 재사용 가능한 논리적 발송 결과로 보존해야 한다. 복구 발송에서는 지연 기사 구간에 과거 결과와 원래 batch 수량 요약을, 현재 기사 구간에는 현재 결과와 수량 요약을 서로 섞거나 다시 계산하지 않고 연결해야 한다. 후보 생성 불가능 입력 오류가 1건 이상이면 검증된 입력 단계의 오류 존재와 수를 표시하고 전체 RSS 관찰 범위의 완전한 Top 10으로 표현해서는 안 된다. 기존·중복 관찰은 운영상 추적하되 정상적인 경우 사용자 오류로 표시하지 않는다. RSS 수집과 필요한 처리가 정상 완료되고 후보 생성 불가능 입력 오류, 신규 후보, 복구 대상, 미처리·실패와 Discord 수락 불명확 대상이 모두 0일 때만 `정상 0건`으로 기록하고 Discord 메시지를 발송하지 않아야 한다. 신규 후보가 존재했지만 선정 기사가 0개라면 정상 0건으로 처리하지 않고 원인별 수량 요약을 발송해야 한다. | Normal Article Item, Low-information Article Item, AC-10~AC-13, AC-15, AC-18 | 정상·저정보·복구 기사, RSS 관찰 35건·신규 30건·중복 2건·입력 오류 3건, 입력 오류만 존재, 신규 30건·선정 10건·제한 미선정 20건의 실패 결과와 다음 신규 결과 결합, 실제 신규 0건·기존 기사만 재관찰·전체 홍보성 제외·AI 전체·부분 실패·미처리·복구·Discord 수락 불명확 시나리오에서 구간별 표시와 저장 결과를 대조 | [UNKNOWN] Discord 기사·batch 요약 배치, 입력 오류 문구, 물리적 메시지 분할·문구·emoji와 Discord 장애 시 보조 가시성 |
| FR-013 | P0-HG | FR-011에서 산출한 미처리 후보 수가 1건 이상이면 해당 batch를 부분 처리 상태로 구분해야 한다. 부분 결과를 발송하는 정책이 적용될 경우 사용자에게 미처리 기사가 존재한다는 사실과 전달 목록이 전체 후보 기준 Top 10이 아니라는 사실을 명확히 표시해야 한다. 미처리 수량은 FR-012의 검증된 batch 요약 결과를 사용하며 이 단계에서 다시 계산하지 않는다. 미처리 후보를 중요도가 낮아 미선정된 후보로 변경하거나 정상 처리 결과에 포함해서는 안 된다. | Partial AI Failure, AC-14~AC-15, 미처리 후보 비무음 Hard Gate | 미처리 0건·1건 이상, 전체 처리 완료 후 선정 10개 미만 시나리오에서 부분 상태·미처리 존재·전체 Top 10 아님 표시를 검사하고 표시 수량과 FR-011 산출값 및 후보 상태를 대조 | [UNKNOWN] 부분 발송·보류 조건, 경고 문구·emoji·위치와 미처리 재처리 정책 |
| FR-014 | P0-HG | 신규 후보가 존재하지만 필요한 AI 분석 결과를 하나도 확보하지 못하면 해당 batch를 전체 처리 실패로 구분하고 정상 신규 0건으로 기록해서는 안 된다. AI 장애는 발생 batch·처리 단계·원인 범주·영향 후보·전체 또는 부분 실패·사용자 안내 결과와 이후 복구 여부를 추적해야 한다. 원인은 최소한 무료 quota·rate limit, 인증·설정, AI 응답·형식, timeout과 제공자 장애를 구분하고 유료 API로 자동 전환해서는 안 된다. Discord가 사용 가능하면 FR-011·FR-012에서 산출·검증한 후보·미처리 수로 전체 실패·무료 한도 소진과 유료 전환 없음 사실을 표시하며, Discord도 실패하면 두 장애를 별도로 기록하고 전달 성공 경계를 전진시켜서는 안 된다. | Total AI Failure, Free Quota Exhaustion, AC-14, AC-16, AI 실패 오표시·유료 전환 Hard Gate | 후보 0건과 후보 존재·전체 실패, 전 요청 timeout, quota·rate limit, 인증·설정·형식·5xx 오류, 일부 성공과 AI·Discord 동시 실패를 주입해 후보·batch·사용자 안내·복구 상태와 FR-011 수량을 대조하고 유료 호출 0건을 확인 | [UNKNOWN] 원인별 fallback·재처리, 사용자 문구, Discord 동시 실패 보조 알림과 제공자별 오류 판별 방식 |
| FR-015 | P0-HG | Discord 전달은 이후 선택할 Discord 인터페이스의 공식 계약과 실제 검증으로 정의된 긍정적 수락 증거가 확인된 경우에만 성공으로 기록해야 한다. 요청을 실행했다는 사실이나 오류가 반환되지 않았다는 사실만으로 성공 처리해서는 안 된다. 거부·timeout·응답 유실 등으로 수락 여부를 확인할 수 없는 시도는 성공으로 추정하지 않고 명시적인 실패 또는 수락 불명확 결과로 유지해야 한다. 여러 논리적 전달 단위가 존재하면 각 단위의 수락 결과를 구분할 수 있어야 한다. | Delivery Success Rule, AC-17, Discord 미수락 성공 처리 Hard Gate | 명확한 수락·거부·timeout·응답 유실과 여러 전달 단위의 부분 수락에서 결과를 구분하고 수락 증거 없는 성공 기록 0건을 검사 | [UNKNOWN] Discord 인터페이스, 긍정적 수락 증거와 message 식별자 확보·대조 방식, batch 성공 판정, retry·backoff와 권한 |
| FR-016 | P0 | 이전 정규 발송에서 선정됐지만 Discord 수락이 확인되지 않았고 이후 대조를 통해 미수락으로 확인된 기사는 성공 전달 전까지 복구 대상으로 유지해야 한다. 다음 Discord 사용 가능 정규 발송에서는 과거 저장 결과의 미수락 선정 기사와 원래 batch 상태·수량 요약을 AI 재분석·재선정 없이 `지연 기사` 논리적 구간으로 재사용하고, 해당 신규 처리 구간의 선정 기사와 수량 요약을 `현재 기사` 논리적 구간으로 구분해 각각 최대 10개, 총 최대 20개까지 전달해야 한다. 과거 정상 미선정 기사는 현재 구간에 재편입하지 않아야 한다. 현재 기사가 0개여도 지연 기사가 있으면 복구 발송을 수행해야 하며, 수락이 확인된 기사와 아직 수락 여부가 불명확한 기사를 무조건 복구 목록에 포함해서는 안 된다. Discord payload 형식·크기 문제를 고쳐야 하면 원래 결과를 덮어쓰거나 기사 의미·선정 판단을 자동 변경하지 않고 수정된 전달 version을 연결해야 한다. 지연·현재·미복구 잔여 수량과 각 논리적 구간의 수락 결과를 추적·표시해야 한다. | Discord Delivery Failure and Recovery, AC-18~AC-19 | 지연만·현재만·혼합, 과거 30건·선정 10건·정상 미선정 20건과 다음 신규 5건, 각각 0·1·10·11개와 총 20개, 장기 장애, 일부 복구 성공·실패, 수락 완료·불명확 기사, transport payload 수정에서 AI 재호출 0건·과거 미선정 재편입 0건·원래 결과와 수정 전달 version·구간별 수락을 대조 | [UNKNOWN] 10개 초과 backlog 우선순위·상한·분할, 지연 정렬·물리적 메시지 표현, 수락 대조와 정규 발송 사이 즉시 retry 여부, transport 수정 허용 범위 |
| FR-017 | P1-V | 프로젝트 사용자는 전달 기사별로 😕 `별로였음`, 🚫 `불필요함`, 📣 `홍보성 의심` reaction을 하나 이상 복수로 남길 수 있어야 하며, 각 reaction은 정확한 사용자·Discord message·기사 identity와 의미에 연결돼야 한다. 품질 평가에는 프로젝트 사용자의 현재 reaction 상태만 사용하고, reaction이 제거되면 해당 현재 feedback도 철회해야 한다. 같은 기사에 여러 부정 reaction이 있으면 기사 단위 부정 여부에서는 한 건으로, 원인별 지표에서는 각 reaction을 별도로 계산할 수 있어야 한다. | Feedback Policy, AC-20, Scenario 9 | 각 reaction 추가·제거, 복수·중복 event, 다른 사용자·bot과 잘못된 message 연결에서 Discord 현재 상태를 저장 결과와 대조하고 기사 단위 부정 수와 원인별 reaction 수를 계산 | [UNKNOWN] message-article mapping, event·주기 조회 방식, history 보존, 제거 반영 지연과 사용자 안내 |
| FR-018 | P1-V | 기사 목록이 전달된 각 batch는 하나의 대표 Discord message와 연결돼야 하며, 프로젝트 사용자가 해당 대표 message에 남긴 ✅ reaction의 현재 존재 여부로 검토 완료를 관리해야 한다. ✅ reaction이 추가되면 검토 완료, 제거되면 검토 완료 취소로 반영해야 하며, 다른 사용자·bot의 reaction이나 GeekNews link 클릭은 검토 완료 증거로 사용해서는 안 된다. 중복 reaction event 또는 event 재처리가 검토 완료 상태를 중복 생성하지 않아야 한다. | Feedback Policy, AC-20, Scenario 9 | 사용자 ✅ 추가·제거·중복 event, 다른 사용자·bot·잘못된 message, message 분할과 link 클릭에서 Discord 현재 reaction과 저장된 batch 검토 상태를 대조 | [UNKNOWN] 대표 message 형태·선택, event·주기 조회, 반영 지연과 안내 UI |
| FR-019 | P1-V | 평가 snapshot 시점에 프로젝트 사용자의 ✅ reaction이 존재하는 검토 완료 batch의 실제 전달 기사만 암묵적 수용률 분모에 포함해야 한다. 해당 기사에 현재 😕·🚫·📣 reaction이 하나도 없으면 암묵적 수용으로 계산하고, 하나 이상 있으면 기사 단위 부정 한 건으로 계산해야 한다. 같은 기사에 복수 부정 reaction이 있어도 암묵적 수용 계산에서는 한 건으로 처리하되 원인별 지표에는 각각 포함해야 한다. ✅ 또는 부정 reaction의 추가·제거가 반영돼야 하며, 미검토 batch는 분모에서 제외하고 분모가 0이면 0%가 아니라 `판정 불충분`으로 기록해야 한다. 암묵적 수용은 명시적인 유용성 평가나 link·원문 열람을 의미하지 않는다. | Implicit Acceptance, AC-20, 암묵적 수용률 70% 목표 | 검토 완료·미완료, 부정 reaction 0·1·복수, ✅·부정 reaction 추가·제거, 다른 사용자·bot과 분모 0 표본에서 수동 계산과 시스템의 기사 단위·원인별 집계를 대조 | [UNKNOWN] 평가 snapshot·산출 주기, reaction 변경 후 과거 지표 재계산, 기사 유형별 세부 지표와 feedback 권장 기간 |
| FR-020 | P1-V | 프로젝트 사용자는 정확한 command 이름을 아직 고정하지 않은 구조화된 Discord slash command를 통해 하나의 GeekNews topic link를 누락 기사 검토 대상으로 제출할 수 있어야 한다. 입력은 GeekNews topic link 형식과 요청 사용자를 검증하고, 현재 처리 기록에서 발견되지 않은 유효 link도 수집원·수집 범위 누락 검토를 위해 접수해야 한다. 외부 URL·잘못된 link·지원하지 않는 입력은 명시적으로 거부하거나 지원 불가로 표시해야 하며, 요청을 일반 message parsing으로 추정하거나 GeekNews 상세·외부 본문을 수집해서는 안 된다. 접수 결과는 이후 누락 이유와 feedback을 같은 요청에 연결할 수 있어야 한다. | Missing Article Feedback, AC-21, 사용자 승인 | DB에 존재·미존재하는 유효 GeekNews link, 외부·잘못된·빈 입력, 중복·다른 사용자·일반 message에서 command 계약, 외부 페이지 미요청과 접수-후속 이유·feedback 연결을 검사 | [UNKNOWN] command·subcommand·parameter·언어, 복수 link, 응답 공개 범위, 중복 UI, 권한·실행 방식과 link validation 규칙 |
| FR-021 | P1-V | 제출된 유효 link는 보존된 수집 관찰, 입력 검증, AI 분석, 선정·순위·제외, Discord 발송 시도·수락 및 복구 기록과 대조해 당시 결정의 사실 기반 누락 이유와 현재 상태를 회신해야 한다. 수집 기록에서 관찰되지 않은 link는 `확인 가능한 RSS 수집 기록에서 관찰되지 않음`으로만 설명하고 RSS에 존재하지 않았다고 단정해서는 안 된다. 이미 Discord가 수락한 기사는 누락으로 취급하지 않고 성공 발송 사실을 알려야 한다. 기록이 부족하거나 서로 충돌하면 `원인 미확정`으로 회신해야 하며, 외부 page를 수집하거나 현재 AI·정책으로 재판단한 결과 또는 추측을 과거 누락 이유처럼 제시해서는 안 된다. | Missing Article Feedback, AC-21, Evidence Policy | 수집 미관찰, 입력 오류, 기존·중복 관찰, AI 실패·한도 소진·미처리, 상위 10개 제한, 홍보성 제외, Discord 실패·복구 대기, 이미 성공 발송, 기록 부족·충돌 및 결정 version 변경 fixture; 외부 HTTP 미호출 검증 | [UNKNOWN] 누락 이유 분류와 우선순위, 과거 기록 보존 범위, 응답 시점·UI, 상세 수준과 version 표시 방식 |
| FR-022 | P1-V | 누락 link 제출 자체를 사용자의 누락 검토 요청으로 기록하고 별도의 이유 확인·이해 feedback은 수집·저장·집계하지 않아야 한다. 누락 이유 회신에는 프로젝트 사용자가 해당 기사가 추천됐어야 한다고 판단할 때 남길 수 있는 `추천해야 했다` reaction만 제공하고 이를 사용자 사후 중요 판정으로 사용해야 한다. reaction이 없는 상태는 명시적 중요도 feedback이 없는 것으로만 처리하고 이유 확인, 시스템 판단 수용, 만족 또는 비중요로 해석해서는 안 된다. reaction 추가·제거는 현재 판정과 관련 지표에 반영하고 변경 이력을 추적해야 하며, 중복 event를 여러 건으로 계산하거나 다른 사용자·bot reaction을 품질 판정에 포함해서는 안 된다. 이미 Discord가 수락한 기사는 누락으로 계산하지 않고 원인 미확정 사례는 최종 분류 전까지 recall 계산에서 보류해야 한다. | Missing Article Feedback, Quality Metrics, AC-21, 사용자 승인 | link 제출과 이유 회신 연결, confirmation data 미생성, reaction 없음·추가·제거·중복 event, 다른 사용자·bot, 기전달 및 원인 미확정 사례를 검증하고 `추천해야 했다`만 FR-023 분류 대상으로 전달되는지 확인 | [UNKNOWN] reaction emoji·안내 문구, 응답 공개 범위, 반복 제출 link의 표시·통합 방식 |
| FR-023 | P1-V | 현재 유효한 `추천해야 했다` reaction이 연결된 link는 Raw RSS 관찰 가능 여부, 후보 처리 기록과 Discord 수락 기록을 근거로 분류해야 한다. 정상 수집된 Raw RSS에서 관찰되어 후보 자격이 확인됐지만 평가 기준 시점까지 Discord 수락이 확인되지 않은 기사는 AI 실패·무료 한도 소진·미처리·상위 10개 제한·홍보성 제외·Discord 전달 실패 등 세부 원인을 별도로 유지하면서 후보 기반 중요 기사 recall 누락으로 계산하고, 수락이 확인된 기사는 정상 전달로 처리해야 한다. 비교 기간을 포함하는 정상 Raw RSS 관찰 기록이 존재하지만 link가 관찰되지 않은 경우에만 `수집원·수집 범위 누락`으로 분류하고 후보 recall 분모에서 제외해야 한다. Raw RSS에는 entry가 있었지만 입력 검증·parsing·identity 연결·후보 생성에 실패한 경우에는 해당 pipeline 실패로 기록해야 한다. RSS 수집 실패, 관찰 기록 부족·범위 밖 또는 identity 불확실은 수집원 누락으로 확정하지 않고 확인 가능한 실패나 `원인 미확정`으로 분류해 recall 계산에서 보류해야 한다. 같은 논리적 기사의 반복 제출·중복 reaction은 한 번만 계산하고 reaction 제거나 근거 정정에 따른 현재 지표 변경과 이전 판정 근거를 추적할 수 있어야 한다. | Missing Article Feedback, 중요 기사 recall 정의, AC-21, 사용자 승인 | 정상 Raw RSS 미관찰, Raw entry 입력 검증·parsing 실패, identity 불확실, RSS HTTP·XML 실패, 기록 부족·관찰 범위 밖, 후보 미수락·기수락, 반복 제출, reaction 중복·제거와 근거 정정 fixture의 분류·지표를 대조 | [UNKNOWN] 비교 가능한 Raw RSS 관찰 범위, 입력 오류 entry의 후보 자격 경계, identity 알고리즘, 평가 기준 시점, 원인 미확정 절차와 반복 제출 통합 방식 |
| FR-024 | P1-V | Raw RSS 응답, parsing된 RSS 관찰 entry, 고유 신규 후보, 기존·중복 관찰, 후보 생성 불가능 입력 오류, 정상 분석, 저정보, 미처리, 선정, 최대 제한 미선정, 홍보성 제외, Discord 수락·실패·수락 불명확, feedback, AI 사용량·비용, 단계별 지연과 품질 측정값을 batch별·Asia/Seoul 일자별로 서로 구분해 산출할 수 있어야 한다. 정상 0건, 측정 불가, 해당 없음과 원인 미확정을 구분하고 실패·기록 부족을 0건으로 기록해서는 안 된다. 외부 호출·retry·reaction 추가·제거와 복구 발송의 event 수는 논리적 기사·처리 결과·성공 전달·현재 feedback 수와 구분하고 같은 결과를 중복 계산해서는 안 된다. 지연 결과는 원래 batch의 후보·처리·선정 수량과 연결해 유지하며 복구 시도·수락은 실행 batch의 별도 event로도 연결하되, 지연·현재 결과를 합쳐 원래 batch 수량을 다시 계산해서는 안 된다. 측정값은 근거 event에서 재계산할 수 있어야 하며 월별 category·집계와 Retention·삭제 주기는 이번 단계에서 확정하지 않는다. | AC-23, AC-24, Product Metrics, Timezone Policy | 동일 KST 일자의 복수 batch와 UTC/KST 날짜 경계, 정상 0건·RSS 실패·측정 불가, AI·Discord retry와 최종 결과, Discord 수락 불명확, reaction 추가·제거, 지연·현재 batch 및 논리 기사 중복 fixture의 batch 합계·KST 일자 합계와 수동 계산을 대조 | [UNKNOWN] metric report·dashboard, 산출 주기, 품질 평가 snapshot, 월별 category·partition·Insight, MVP-A 검토 후 Retention·archive·삭제 정책 |

## Non-functional Requirements

[INFERENCE] 아래 요구사항은 승인된 Guardrail과 Service Goal을 측정 가능한 운영·품질 계약으로 변환한 Draft입니다.

| ID | Priority | Requirement | Product source | Verification | Undecided dependency |
|---|---|---|---|---|---|
| NFR-REL-001 | P0-HG | 같은 기사와 성공 발송 구간의 재실행을 포함해 동일 기사 중복 전달은 0건이어야 한다. | Hard Gate, AC-04 | 반복·동시·응답 유실 재실행 시험 | [UNKNOWN] identity와 동시성 제어 방식 |
| NFR-REL-002 | P0-HG | 각 batch는 RSS 관찰, 후보 처리, 선정과 전달 단계별 수량을 독립적으로 대조할 수 있어야 한다. 파싱된 RSS 관찰 entry 수는 고유 신규 후보, 기존·중복 관찰과 후보 생성 불가능 입력 오류의 합과 일치해야 하고, 신규 후보 수는 정상 분석·저정보·미처리 후보의 대표 처리 결과로 설명돼야 하며, 선정 결과는 선정·최대 제한 미선정·홍보성 제외·미처리로 설명돼야 한다. 서로 다른 단계나 중첩 가능한 축을 중복 합산하거나 입력 오류·중복 관찰을 신규 후보로 포함해서는 안 되며 어느 단계에도 설명되지 않는 잔여 수량이 없어야 한다. | 비무음 원칙, AC-15, AC-24 | 정상·신규·중복·입력 오류·저정보·미처리·선정·제외·전달 혼합 fixture의 단계별 수량 불변식 자동 검사 | [UNKNOWN] 최종 상태 label과 중첩 축 표현 |
| NFR-PERF-001 | P0 | 최대 100건/일의 입력을 데이터 손실·유료 전환 없이 처리 가능함을 검증해야 한다. | Service Goal | 100건/일 대표 payload 부하 시험 | [UNKNOWN] AI 실제 한도 |
| NFR-LAT-001 | P0 | 발송 batch의 시작부터 완료까지 30분 이내 비율이 최소 95%여야 한다. | Service Goal | 최소 20개 예정 batch 실측 | [UNKNOWN] 시작·완료 event 정의 |
| NFR-LAT-002 | P0 | 검증된 기준 시각부터 Discord 수락까지 13시간 이내 전달 비율이 최소 95%여야 한다. | Service Goal | article별 End-to-End latency 계산 | [UNKNOWN] published의 업무 의미 |
| NFR-COST-001 | P0-HG | 추가 월 운영비는 0원이어야 하며 유료 호출 가능한 상태로 자동 전환하지 않아야 한다. | Hard Gate | 계정·credential 사전 검사, quota exhaustion과 월 비용 대조 | [UNKNOWN] 제공자별 강제 차단 방식 |
| NFR-DQ-001 | P0-HG | 중대한 RSS 근거 밖 사실은 0건이고 RSS 근거 충실도는 평가 표본의 95% 이상이어야 한다. | Quality Gate | RSS와 출력 claim 대조 | [UNKNOWN] 중대성 판정 rubric 상세 |
| NFR-DQ-002 | P0-HG | 처리되지 않은 후보는 제외·정상 0건·전달 완료로 오분류되지 않아야 한다. | Hard Gate | 상태·수량 reconciliation과 장애 주입 | [UNKNOWN] fallback 세부 정책 |
| NFR-OBS-001 | P0 | batch 식별자, 단계별 시각·결과, 후보 수량, 외부 응답 범주, 실패 원인과 상관관계를 추적할 수 있어야 한다. | AC-24 | 한 batch의 입력부터 전달까지 추적성 감사 | [UNKNOWN] 로그·metric 기술 |
| NFR-OBS-002 | P0-HG | 여섯 Hard Gate 위반 여부를 서로 독립적으로 탐지하고 실제 결과로 보고할 수 있어야 한다. | AC-24 | Hard Gate별 의도적 위반 fixture | [UNKNOWN] 알림 채널 |
| NFR-SEC-001 | P0 | RSS 공개 데이터와 승인된 feedback 외에는 무료 AI에 전달하지 않고 API key·webhook URL·token을 코드·출력·로그에 노출하지 않아야 한다. | Secret Management, AI terms | secret scan, log redaction, AI payload 검사 | [UNKNOWN] secret 저장 기술 |
| NFR-SEC-002 | P0 | 외부 credential은 필요한 서비스·작업 범위로 제한하고 교체·폐기 가능해야 한다. | Security | 권한 검토와 폐기 후 접근 실패 시험 | [UNKNOWN] 제공자별 권한 모델 |
| NFR-REC-001 | P0-HG | 수집·AI·Discord 실패 후 성공한 이전 결과를 훼손하지 않고 미처리·미발송 항목을 멱등하게 재처리할 수 있어야 한다. | Recovery scenarios | 외부 단계별 실패 후 복구 End-to-End | [UNKNOWN] retry·backoff·상태 전이 |
| NFR-MNT-001 | P0 | AI 제공자는 하나만 연동하되 요청·결과 version과 외부 계약 변경 영향을 식별하고 향후 제공자 교체 가능성을 유지해야 한다. | Approved Solution | provider 계약 대체 가능성 검토와 version 회귀 | [UNKNOWN] component 경계 |
| NFR-MNT-002 | P0 | Discord feedback command의 정확한 이름과 UI를 요구사항 로직에서 분리해 Interface Design 변경이 품질 의미를 바꾸지 않게 해야 한다. | 2026-08-26 사용자 승인 | command 이름 변경 시 의미·지표 회귀 테스트 | [UNKNOWN] interface 설정 방식 |
| NFR-TIME-001 | P0 | 사용자 일정과 일별 집계는 Asia/Seoul 기준으로 해석하고 외부 시각의 원값·offset과 비교 가능한 instant를 보존해야 한다. | 10:00·22:00 KST | 날짜 경계·offset·clock skew 테스트 | [UNKNOWN] 저장 형식 |
| NFR-REL-003 | P0 | GeekNews·AI·Discord의 rate limit과 retry 지시는 응답으로 관찰하고 고정 수치에 의존하지 않아야 한다. | Reliability, 과도한 요청 금지 | 429와 rate-limit header fixture | [UNKNOWN] retry 횟수와 backoff |

## Data Requirements

[FACT] 이 절은 데이터 범주와 정확성·보존·접근 요구를 정의하며 table, column 또는 schema를 설계하지 않습니다.

[INFERENCE] 아래 요구사항은 MVP-A 결과를 재현·복구·검증하기 위해 필요한 데이터 범주 수준의 Draft이며 물리·논리 데이터 모델을 확정하지 않습니다.

| ID | Priority | Data category and requirement | Accuracy requirement | Retention and access | Product source | Verification / dependency |
|---|---|---|---|---|---|---|
| DR-001 | P0 | RSS 원응답, 수집 시각, endpoint, HTTP 결과와 관찰 가능한 cache header | 원응답과 변형 없이 대조 가능 | 품질 검토에 필요한 기간 운영자에게 읽기 제공 | Input Boundary, AC-03, AC-24 | payload hash 대조 / [UNKNOWN] 검토 후 삭제 시점 |
| DR-002 | P0 | 파싱된 title, content/description, link, id, author, published, updated, 입력 검증 결과와 RSS 관찰 entry의 신규 후보·기존/중복·후보 생성 불가능 입력 오류 대표 분류 | 각 관찰 entry가 원응답과 하나의 대표 입력 결과까지 역추적되고 단계별 수량과 일치 | 처리·품질 검토에 제공 | AC-01~03, AC-05, AC-15 | parser·reconciliation fixture / [UNKNOWN] 필수 field와 후보 생성 가능 경계 |
| DR-003 | P0-HG | 기사 identity 판단에 사용한 원값과 중복 판정 근거 | 중복·비중복 이유 재현 가능 | 중복·복구 검증 기간 보존 | AC-04 | replay 대조 / [UNKNOWN] identity 알고리즘 |
| DR-004 | P0-HG | 후보 처리 상태, 단계별 시각, 실패 범주·원인과 처리 가능 여부 | 모든 관찰 후보가 설명 가능한 결과 보유 | 운영·복구 주체만 변경 가능 | AC-14~17, AC-24 | 수량 reconciliation / [UNKNOWN] 상태 표현 |
| DR-005 | P0-HG | 신규 후보 범위, 마지막 성공 전달 근거, 복구 대상과 발송 경계 | Discord 수락 사실과 일치 | 복구 완료·품질 검토 전 삭제 금지 | AC-04, AC-17~19 | 장애 End-to-End / [UNKNOWN] 경계 표현 |
| DR-006 | P0 | AI 입력 근거, 원응답, 구조화 결과, 판단 근거, model·prompt·결과 version과 usage | 입력·출력·version 조합 추적 가능 | MVP-A feedback·품질 검토 종료 전 접근 가능 | AC-05, AC-24 | 재현성 감사 / [UNKNOWN] 이후 보존 |
| DR-007 | P0 | 저정보, 정상, 미처리, 부분 처리와 홍보성 의심 상태 및 근거 | 서로 혼동되지 않아야 함 | 품질 검토자 접근 가능 | AC-11, AC-14~16 | 상태별 fixture / [UNKNOWN] label과 임계값 |
| DR-008 | P0 | batch별 선정 여부, 상대 순위, 제외 범주, 당시 상태·사용자 표시 수량과 재사용 가능한 논리적 발송 결과·version | 원래 batch의 분석·선정·수량·표시 결과와 일치하고 복구 시 현재 결과로 덮어쓰지 않음 | recall·홍보성 평가와 복구 기간 접근 | AC-09, AC-12, AC-15, AC-18 | 원본·복구 결과 대조 / [UNKNOWN] 동률 정보와 논리적 결과 저장 표현 |
| DR-009 | P0-HG | 논리적 발송 결과와 전달 단위, 실제 요청 payload·version, 발송 시도·시각·응답·수락 여부·message 식별자·오류 및 transport 수정 관계 | 미수락 시도를 성공으로 기록하지 않고 실제 요청과 원래 결과·수정 version을 대조 가능 | 중복·복구 판정 기간 접근 | AC-17~19 | API fault·payload 수정 test / [UNKNOWN] 메시지 단위와 payload 저장 표현 |
| DR-010 | P1-V | 기사별 세 부정 reaction, batch별 ✅ reaction, 추가·삭제 시각과 feedback 사용자 | Discord 현재 상태와 평가 snapshot 일치 | 프로젝트 사용자와 품질 검토만 접근 | AC-20 | reaction 조회·event 대조 / [UNKNOWN] snapshot 시점 |
| DR-011 | P1-V | 누락 link, command 검토 요청, 실제 처리 원인, 회신, 추천해야 했다 reaction의 현재 상태·변경 이력과 최종 분류 | 실제 pipeline 기록과 일치하고 추측·중복 집계 금지 | 품질 검토 기간 접근 | AC-21 | 원인·reaction 변경별 fixture / [UNKNOWN] 원인 미확정 처리와 반복 제출 통합 |
| DR-012 | P1-V | 후보 recall 누락과 수집원·수집 범위 누락의 분리 집계 | 후보 존재 여부와 전달 결과에 따라 분류 | 검증 기간 재계산 가능 | 중요 기사 recall, AC-21 | metric 대조 / [UNKNOWN] source coverage 목표 |
| DR-013 | P1-V | 기사량, AI 요청·token, quota, 비용, 단계별 지연, batch 상태와 Hard Gate 결과 | 원천 event로 재계산 가능 | 최소 2~4주 검증과 판정 근거로 보존 | AC-23, AC-24 | 지표 재계산 / [UNKNOWN] 장기 보존 |
| DR-014 | P0 | 실행 당시 외부 제공자·계정 tier·terms 확인일·설정 version | 실행 결과와 당시 조건 연결 가능 | 감사 가능한 사용자만 접근 | Cost Control, AC-24 | 사전 실행 점검 / [UNKNOWN] 설정 보존 방식 |

[INFERENCE] RSS 근거 충실도와 Hard Gate를 검증하려면 관련 Raw 입력, AI 결과, 판단 근거와 전달 증거를 최소한 해당 MVP-A 품질 검토가 끝날 때까지 함께 조회할 수 있어야 합니다.

[UNKNOWN] MVP-A 품질 검토 이후 임시 데이터의 정확한 보존·삭제 정책은 확정하지 않습니다.

[FACT] MVP-B의 Raw 3개월·AI 결과 12개월·Insight 무기한 정책을 MVP-A 자동 Retention 구현 요구로 앞당기지 않습니다.

## External Integration Requirements

[INFERENCE] 아래 요구사항은 승인된 제품 동작과 확인된 공식 외부 계약을 구현 전 검증 가능한 integration 계약으로 변환한 Draft입니다.

### GeekNews RSS

[FACT] 공식 RSS URL은 https://news.hada.io/rss/news 입니다.

[FACT] GeekNews 공식 공지는 feed가 News·Ask·Show 전체를 시간순으로 노출한다고 설명합니다.

[FACT] GeekNews 약관은 서비스에 과도한 부하를 주는 자동화 접근·크롤링·스크립트 실행을 금지하지만 허용 polling 수치는 제공하지 않습니다.

| ID | Priority | Requirement | Product source | Verification plan | Undecided dependency |
|---|---|---|---|---|---|
| EXT-GN-001 | P0 | 공식 RSS endpoint만 사용하고 접근량·응답 상태·시각을 측정하며 불필요한 요청을 줄여야 한다. | Input Boundary, AC-01 | 저빈도 live 요청과 운영 조건 검토 | [UNKNOWN] polling 주기 |
| EXT-GN-002 | P0 | ETag 또는 Last-Modified가 제공되면 conditional request와 304 동작을 사용할 수 있어야 한다. | Collection and Recovery, AC-24 | HEAD·GET header와 조건부 재요청 | [UNKNOWN] 현재 지원 여부 |
| EXT-GN-003 | P0-HG | link와 Atom id 원값을 추적하되 장기 identity 계약으로 확정하기 전에 변화를 검증해야 한다. | Duplicate Guardrail, AC-04 | 여러 시점 snapshot 비교와 수정·재등록 관찰 | [UNKNOWN] 장기 안정성 |
| EXT-GN-004 | P0 | published와 updated의 값·offset·변경을 보존하고 지연 시작 시각으로 사용하기 전에 의미를 검증해야 한다. | Service Goal, AC-24 | 시차를 둔 snapshot 비교 또는 운영자 확인 | [UNKNOWN] 게시·등록·수정 중 의미 |
| EXT-GN-005 | P0 | feed 항목 수, 과거 노출 범위, 갱신·삭제·재정렬을 관찰해 신규 구간과 재수집 중첩의 입력 사실을 제공해야 한다. | Collection and Recovery, AC-04 | 여러 날짜·발송 경계 전후 snapshot diff | [UNKNOWN] overlap 길이 |
| EXT-GN-006 | P0 | 4xx·5xx·timeout·잘못된 XML을 신규 0건으로 해석하지 않아야 한다. | Failure Policy, AC-13~AC-16 | HTTP·parser fault injection | [UNKNOWN] retry 정책 |

### Free AI Provider

[FACT] 최종 AI 제공자는 미정이며 Gemini API는 우선 검증 후보입니다.

[FACT] 2026-08-26 확인한 [Gemini API rate limits](https://ai.google.dev/gemini-api/docs/rate-limits)는 rate limit이 project 단위이며 model·tier에 따라 달라지고 실제 한도는 AI Studio에서 확인해야 한다고 설명합니다.

[FACT] 2026-08-26 확인한 [Gemini API Additional Terms](https://ai.google.dev/gemini-api/terms)는 무료 서비스의 입력·출력이 제품 개선과 사람 검토에 사용될 수 있으므로 민감·기밀·개인정보를 제출하지 말라고 설명합니다.

| ID | Priority | Requirement | Product source | Verification plan | Undecided dependency |
|---|---|---|---|---|---|
| EXT-AI-001 | P0 | 후보 model이 RSS 입력만으로 한국어 제목·요약·keyword·중요도·적합성·홍보성·근거를 구조적으로 생성 가능한지 평가해야 한다. | AI Analysis, AC-05~AC-09 | 기존 50개 표본과 Ask 추가 표본 benchmark | [UNKNOWN] 제공자·model |
| EXT-AI-002 | P0 | 실제 project와 model의 요청·token·일일 한도와 최대 100건/일 처리 가능성을 측정해야 한다. | Capacity and Cost, AC-24 | 계정 화면·API 응답·100건 workload 계산 | [UNKNOWN] 실제 무료 quota |
| EXT-AI-003 | P0 | RSS 공개 정보 외 비공개 데이터가 무료 AI로 전송되지 않으며 현재 데이터 이용 조건을 실행 전 확인해야 한다. | Input Boundary, Security | payload 감사와 terms snapshot | [UNKNOWN] 최종 제공자 약관 |
| EXT-AI-004 | P0-HG | 호출 전 credential·project가 유료 청구 불가능한 상태임을 확인하고 무료 한도 소진 시 fail-closed 해야 한다. | Cost Hard Gate | billing 미연결 상태와 quota exhaustion 시험 | [UNKNOWN] 제공자별 강제 차단 |
| EXT-AI-005 | P0-HG | quota·rate limit, 인증, 안전 필터, 형식 오류, timeout과 서버 오류를 구분해 기록할 수 있어야 한다. | Failure Policy, AC-14~AC-16 | 실제 또는 sandbox 오류 응답 수집 | [UNKNOWN] 제공자별 오류 taxonomy |
| EXT-AI-006 | P1-V | 성공률, 입력·출력 token, latency, 재처리 가능성, 저정보 품질, 근거 충실도와 판정 오류를 측정해야 한다. | Success Metrics, AC-23~AC-24 | benchmark 결과표와 수동 평가 | [UNKNOWN] fallback 조건 |
| EXT-AI-007 | P0 | 실제 검증 전 부분 발송·보류·제한 결과·전체 미발송 우선순위를 고정하지 않아야 한다. | Failure Policy, AC-14~AC-16 | 검증 결과와 정책 결정 추적 검토 | [UNKNOWN] 사용자 승인 정책 |

### Discord Delivery

[FACT] Discord [Webhook documentation](https://docs.discord.com/developers/resources/webhook)은 wait=false일 때 저장되지 않은 메시지가 오류를 반환하지 않을 수 있고 wait=true일 때 서버 확인을 기다려 생성된 message를 반환한다고 설명합니다.

[FACT] Discord [Rate Limits documentation](https://docs.discord.com/developers/topics/rate-limits)은 rate limit 수치를 고정하지 않고 응답 header와 Retry-After를 사용하도록 안내합니다.

| ID | Priority | Requirement | Product source | Verification plan | Undecided dependency |
|---|---|---|---|---|---|
| EXT-DC-001 | P0-HG | 선택한 전달 인터페이스에서 서버 수락을 입증하는 응답과 message 식별자를 확보해야 한다. | Delivery Success, AC-17 | sandbox 발송과 message 조회 | [UNKNOWN] webhook·bot 인터페이스 |
| EXT-DC-002 | P0 | 4xx·401·403·404·429·5xx·timeout·응답 유실을 구분하고 rate-limit header를 준수해야 한다. | Delivery Success, AC-17 | 상태별 fault test | [UNKNOWN] retry·backoff |
| EXT-DC-003 | P0-HG | 수락 여부가 불명확한 경우 무조건 재발송하지 않고 중복 여부를 판별할 수 있어야 한다. | Duplicate Guardrail, AC-04·AC-17 | 수락 후 응답 유실 시험 | [UNKNOWN] reconciliation 방식 |
| EXT-DC-004 | P0 | Discord payload 제한 안에서 정상 최대 10개와 복구 최대 20개의 논리적 결과를 전달하고 여러 전달 단위라면 전체 성공 조건을 정의해야 한다. | Selection and Delivery, AC-09·AC-10·AC-19 | 경계 크기 payload 검증 | [UNKNOWN] 메시지 분할과 표현 |
| EXT-DC-005 | P0 | Discord 장애 backlog는 전달 성공 전까지 유지하고 다음 정규 발송 복구에 포함해야 한다. | Recovery, AC-18·AC-19 | 장시간 장애 simulation | [UNKNOWN] 10개 초과 backlog |
| EXT-DC-006 | P0-HG | 정상 신규 0건, AI 실패 미발송과 Discord 전달 실패가 서로 다른 상태·지표로 기록돼야 한다. | Failure Policy, AC-13~AC-17 | 세 시나리오 비교 테스트 | [UNKNOWN] 보조 알림 채널 |

### Discord Feedback

[FACT] Discord [Message API](https://docs.discord.com/developers/resources/message)와 [Gateway Events](https://docs.discord.com/developers/events/gateway-events)는 reaction 조회와 reaction event를 지원합니다.

[FACT] Discord [Interactions documentation](https://docs.discord.com/developers/platform/interactions)은 구조화된 slash command와 interaction payload를 지원합니다.

[FACT] Discord link-style button은 클릭 시 Application에 interaction을 보내지 않으므로 GeekNews link 클릭을 검토 완료 증거로 사용하지 않습니다.

| ID | Priority | Requirement | Product source | Verification plan | Undecided dependency |
|---|---|---|---|---|---|
| EXT-FB-001 | P1-V | Discord Application capability로 기사별 부정 reaction과 batch별 ✅ reaction의 현재 상태를 수집할 수 있어야 한다. | Feedback Policy, AC-20 | reaction 추가·삭제의 event·REST 조회 대조 | [UNKNOWN] Gateway·HTTP·주기 조회 선택 |
| EXT-FB-002 | P1-V | reaction을 정확한 사용자, 기사 또는 batch와 연결하고 다른 사용자의 reaction을 품질 평가에서 분리해야 한다. | Feedback Policy, AC-20 | 다른 사용자·bot reaction fixture | [UNKNOWN] message와 article mapping |
| EXT-FB-003 | P1-V | 누락 기사 제출은 정확한 command 이름을 고정하지 않은 구조화된 slash command여야 한다. | Missing-Article Feedback, AC-21 | command payload와 link 검증 계약 | [UNKNOWN] command·subcommand·parameter |
| EXT-FB-004 | P1-V | command 입력은 GeekNews topic link 형식을 검증하고 외부 URL·여러 link·잘못된 link를 명시적으로 거부하거나 지원 불가로 표시해야 한다. | Missing-Article Feedback, AC-21 | 유효·무효·경계 입력 테스트 | [UNKNOWN] 정확한 validation 표현 |
| EXT-FB-005 | P1-V | 누락 이유 회신과 feedback을 원 요청·사용자·기사에 연결할 수 있어야 한다. | Missing-Article Feedback, AC-21 | 동시 요청·중복 요청·응답 연결 테스트 | [UNKNOWN] reply UI |
| EXT-FB-006 | P0 | Discord Application 실행·수신 방식은 월 운영비 0원과 secret 보호 요구를 충족해야 한다. | Cost Control, AC-24 | 운영비·credential·권한 검토 | [UNKNOWN] 실행 환경 |

### Feedback Collection Option Comparison

| Option | Cost | Implementation difficulty | Data quality | Operational burden | MVP-A disposition |
|---|---|---|---|---|---|
| Discord reaction와 slash command | [UNKNOWN] Discord Application 실행 환경까지 포함한 실제 추가 월 비용을 검증해야 함 | [INFERENCE] 중간: reaction 추가·삭제 동기화, 사용자·message mapping과 interaction 처리가 필요함 | [INFERENCE] 높음: 전달 기사·batch·누락 요청에 직접 연결할 수 있으나 검토 완료 의미를 지키지 않으면 편향될 수 있음 | [INFERENCE] 낮음~중간: 사용자 마찰은 낮지만 event 누락 대조와 권한·secret 운영이 필요함 | [FACT] 승인된 주 수단 |
| 간단한 form | [UNKNOWN] 제공자와 무료 한도·데이터 이용 조건에 따라 달라짐 | [INFERENCE] 낮음~중간: form 생성은 단순하지만 기사·batch 식별자 전달과 결과 연계가 필요함 | [INFERENCE] 중간: 구조화는 쉽지만 Discord 맥락과 분리되어 잘못된 link·batch 연결 가능성이 커짐 | [INFERENCE] 중간: 사용자 이동, 응답 export·권한·보존 관리가 필요함 | [FACT] MVP-A 주 수단으로 선택하지 않음 |
| 수동 기록 | [INFERENCE] 새 외부 integration 비용은 없지만 운영자 시간이 발생함 | [INFERENCE] 낮음: 자동 수집 기능은 필요하지 않음 | [INFERENCE] 낮음~중간: 예외를 유연하게 기록할 수 있으나 누락·표현 불일치·시각 오차 위험이 큼 | [INFERENCE] 높음: 매 feedback의 전사·연결·수정·집계를 사람이 수행함 | [FACT] MVP-A 주 수단으로 선택하지 않음 |

[INFERENCE] 승인된 Discord 방식은 사용자가 뉴스 확인 흐름을 벗어나지 않고 기사·batch·누락 사유에 feedback을 연결할 수 있어 세 대안 중 MVP-A의 사용자 마찰과 데이터 연결 품질 균형이 가장 좋습니다.

## Feedback Metrics

### Batch Review Completion

- [FACT] batch 대표 메시지의 프로젝트 사용자 ✅ reaction이 현재 존재하면 검토 완료입니다.
- [FACT] ✅ reaction이 제거되면 검토 완료도 취소합니다.
- [FACT] GeekNews link 클릭은 검토 완료로 간주하지 않습니다.
- [FACT] 검토 완료는 전달 목록 확인을 의미하며 원문 열람을 의미하지 않습니다.

### Negative Feedback

| Reaction | Approved meaning | Metric use |
|---|---|---|
| 😕 별로였음 | [FACT] 주제는 전달 가능했지만 실제 읽을 가치나 유용성이 낮음 | [FACT] 유용성 부족 원인 |
| 🚫 불필요함 | [FACT] 중요도·관심·영향 기준상 추천하지 않았어야 함 | [FACT] 선정 판단 오류 |
| 📣 홍보성 의심 | [FACT] 홍보성 때문에 제외했어야 함 | [FACT] 홍보성 False Negative |

[FACT] 한 기사에 여러 부정 reaction을 허용합니다.

### Implicit Acceptance

[FACT] 암묵적 수용률은 검토 완료 batch에서 세 부정 reaction이 하나도 없는 기사 수를 검토 완료 batch의 전체 전달 기사 수로 나눈 값입니다.

[FACT] 같은 기사에 부정 reaction이 여러 개 있어도 암묵적 수용률에서는 부정 기사 한 건으로 계산하고 원인별 지표에서는 각각 계산합니다.

[FACT] 목표 암묵적 수용률은 70% 이상입니다.

[FACT] 미검토 batch의 기사는 분모에서 제외합니다.

### Missing Article Feedback

- [FACT] 사용자는 구조화된 Discord slash command로 GeekNews topic link를 제출합니다.
- [FACT] 시스템은 실제 처리 기록을 우선해 누락 이유를 회신하고 확인할 수 없는 이유를 추측하지 않습니다.
- [FACT] 누락 link 제출 자체를 누락 검토 요청으로 취급하며 별도의 이유 확인·이해 feedback은 수집·저장·집계하지 않습니다.
- [FACT] 추천해야 했다는 해당 기사를 중요 기사로 사후 판정한 feedback입니다.
- [FACT] 수집된 후보의 추천해야 했다는 중요 기사 recall 누락으로 계산합니다.
- [FACT] 비교 기간을 포함하는 정상 Raw RSS 관찰 기록에서 확인되지 않은 link의 추천해야 했다는 수집원·수집 범위 누락으로 별도 집계하고 후보 recall 분모에서는 제외합니다. Raw RSS 처리 실패, 수집 장애, 기록 부족·범위 밖과 identity 불확실은 각각 pipeline 실패 또는 원인 미확정으로 구분합니다.
- [FACT] 이미 성공 전달된 기사는 누락으로 계산하지 않습니다.
- [FACT] 원인 미확정 사례는 확정 전까지 recall 계산에서 보류하고 별도 집계합니다.

## Verification Requirements

[INFERENCE] 아래 요구사항은 Product Specification Acceptance Criteria와 Hard Gate를 시험·운영 증거로 판정하기 위한 Draft입니다.

| ID | Priority | Verification requirement | Product source | Evidence | Undecided dependency |
|---|---|---|---|---|---|
| VR-001 | P0 | AC-01~AC-24와 Technical Requirement ID의 양방향 추적이 가능해야 한다. | AC-24 | Traceability Matrix | [UNKNOWN] 자동 관리 형식 |
| VR-002 | P0 | 정상·누락·잘못된 RSS fixture에 대한 입력 계약 테스트가 있어야 한다. | AC-01~03 | parser·validation 결과 | [UNKNOWN] test framework |
| VR-003 | P0 | Product Specification Scenario 1~9의 대표 End-to-End 테스트가 있어야 한다. | 전체 AC | 시나리오별 실행 증거 | [UNKNOWN] test 환경 |
| VR-004 | P0-HG | AI quota·전체·부분 실패, Discord 429·5xx·timeout과 응답 유실 fault test가 있어야 한다. | AC-14~19 | 상태·로그·출력 | [UNKNOWN] fault injection 방식 |
| VR-005 | P0-HG | 반복 수집, 성공 batch 재실행과 Discord 응답 유실에서 중복 0건을 입증해야 한다. | AC-04 | replay 결과 | [UNKNOWN] 동시 실행 범위 |
| VR-006 | P1-V | 최소 2주·20개 예정 batch·50개 후보 평가 전에는 품질 통과를 산출하지 않아야 한다. | AC-23 | 평가 표본과 판정 불충분 결과 | [UNKNOWN] 표본 추출 방식 |
| VR-007 | P1-V | recall·암묵적 수용률·근거 충실도·홍보성 FP·FN과 수집원·수집 범위 누락을 승인된 분모로 계산해야 한다. | Quality Metrics | 평가 dataset과 계산 결과 | [UNKNOWN] 중요 기사 판정 종료 시점 |
| VR-008 | P0 | 100건/일, batch 30분 95%, 전달 13시간 95%를 실측해야 한다. | Service Goals | benchmark·운영 지표 | [UNKNOWN] 13시간 시작 시각 |
| VR-009 | P0-HG | 실제 월 비용과 유료 가능 설정을 함께 검사해 0원을 입증해야 한다. | Cost Hard Gate | billing 상태·사용량·월 비용 보고 | [UNKNOWN] 제공자·실행 환경 |
| VR-010 | P1-V | reaction 추가·삭제, batch 검토 완료와 누락 command·사유·feedback의 End-to-End 추적성을 검증해야 한다. | AC-20, AC-21 | Discord feedback scenario 결과 | [UNKNOWN] Interface Design |
| VR-011 | P0 | external contract는 구현 직전과 운영 검증 시작 전에 다시 확인해야 한다. | 변동 가능한 외부 조건 | 공식 문서 확인일과 검증 결과 | [UNKNOWN] 재검토 주기 |

## Hard Gate Verification Evidence

| Hard Gate | Required evidence |
|---|---|
| 유료 AI 자동 전환 0건 | [INFERENCE] 유료 청구 불가 account 상태, quota 소진 시험과 실제 비용 보고 |
| 미처리 후보 조용한 제외 0건 | [INFERENCE] 후보 수량 reconciliation, 미처리 상태와 부분·실패 출력 |
| 동일 기사 중복 발송 0건 | [INFERENCE] identity 판정 근거, Discord 수락 기록과 replay 시험 |
| AI 실패의 신규 0건 오기록 0건 | [INFERENCE] AI fault test와 서로 다른 batch 상태·출력 |
| Discord 미수락의 성공 기록 0건 | [INFERENCE] Discord 응답·message 식별자와 timeout·5xx 시험 |
| 중대한 근거 밖 사실 0건 | [INFERENCE] RSS-AI 입력-출력 연결과 평가 표본 claim 검토 |

## Acceptance Criteria Traceability Matrix

[INFERENCE] 아래 연결은 승인된 Product Specification과 이 Draft의 Technical Requirement를 대조한 결과입니다.

| Acceptance Criterion | Technical Requirements | Verification evidence |
|---|---|---|
| AC-01 | FR-001, FR-003, EXT-GN-001 | News·Ask·Show fixture 후보 결과 |
| AC-02 | FR-002, FR-003 | prefix·keyword 변화에도 후보 유지 |
| AC-03 | FR-006, NFR-SEC-001 | AI payload와 외부 호출 감사 |
| AC-04 | FR-004, FR-005, NFR-REL-001, VR-005 | replay·중첩·응답 유실 중복 0건 |
| AC-05 | FR-006, FR-007, DR-006 | 정상 분석 결과 계약 테스트 |
| AC-06 | FR-009 | 관심도 낮음·IT 영향도 높음 선정 표본 |
| AC-07 | FR-003, FR-009 | 관심 주제 밖 후보 유지 |
| AC-08 | FR-010, VR-007 | 경계 표본과 홍보성 FP 계산 |
| AC-09 | FR-011 | 10·11·100건 순위·상한 테스트 |
| AC-10 | FR-007, FR-012 | Discord 정상 item 검사 |
| AC-11 | FR-008 | 저정보 출력 fixture |
| AC-12 | FR-010, FR-012 | 제외 수량과 출력 대조 |
| AC-13 | FR-005, FR-012 | 신규·실패·backlog 조합 테스트 |
| AC-14 | FR-013, FR-014, NFR-DQ-002 | AI fault 상태 비교 |
| AC-15 | FR-012, FR-013, NFR-REL-002 | 입력 오류·부분 결과 수량·경고 검사 |
| AC-16 | FR-014, NFR-COST-001 | 전체 AI 실패 notice |
| AC-17 | FR-005, FR-015, EXT-DC-001 | Discord 수락·미수락 시험 |
| AC-18 | FR-016, EXT-DC-005 | 다음 정규 발송 복구 End-to-End |
| AC-19 | FR-016, EXT-DC-004 | 10+10 경계 출력 |
| AC-20 | FR-017~019, DR-010, EXT-FB-001~002, VR-010 | 기사·batch reaction과 암묵적 수용 계산 |
| AC-21 | FR-020~023, DR-011~012, EXT-FB-003~005, VR-010 | 누락 command·근거 회신·feedback·원인 분류 |
| AC-22 | FR-010, FR-017, VR-007 | 제외 표본과 FP 산출 |
| AC-23 | FR-024, VR-006 | 기간·batch·후보 최소 조건 검사 |
| AC-24 | FR-024, NFR-OBS-002, VR-001, VR-007~009 | Hard Gate·품질·서비스 결과 보고 |

[INFERENCE] AC-01~AC-24 모두 하나 이상의 Functional Requirement와 검증 증거에 연결됩니다.

## User Decisions Required

- [UNKNOWN] 이 Technical Requirements Draft 전체를 승인할지 결정해야 합니다.
- [UNKNOWN] 무료 AI 실험 결과가 나온 뒤 부분 결과·보류·제한 결과·전체 미발송의 fallback 우선순위를 별도로 승인해야 합니다.
- [INFERENCE] 최종 AI 제공자, Discord 구현 인터페이스와 Architecture·Data / Interface Design 항목은 이번 Draft 승인 조건으로 결정할 필요가 없습니다.

## Research and Experiment Required

1. [UNKNOWN] GeekNews live 응답의 ETag, Last-Modified와 304 지원 여부
2. [UNKNOWN] 여러 시점의 link·id 안정성, feed 항목 수, 과거 노출 범위와 수정·삭제 동작
3. [UNKNOWN] published·updated의 업무 의미와 13시간 측정 시작점
4. [UNKNOWN] GeekNews의 허용 polling 빈도
5. [UNKNOWN] Ask가 포함된 추가 RSS 표본의 저정보·요약 품질
6. [UNKNOWN] 무료 AI 후보의 한국어 품질, 구조화 응답 안정성, token·latency와 100건/일 가능성
7. [UNKNOWN] 실제 계정의 무료 quota, rate limit, quota exhaustion 오류와 유료 차단 상태
8. [UNKNOWN] Discord sandbox의 수락 증거, payload 크기, 429·5xx·timeout·응답 유실
9. [UNKNOWN] Discord reaction 조회·event와 구조화된 slash command의 월 0원 실행 가능성
10. [UNKNOWN] 기사별 reaction과 batch 대표 메시지 표현의 Interface 적합성
11. [UNKNOWN] AI 검증 결과에 따른 부분 결과·보류·제한 결과·전체 미발송 정책

## Decisions Deferred to Architecture / Data and Interface Design

- [UNKNOWN] 최종 AI 제공자, SDK, model과 prompt
- [UNKNOWN] DBMS와 table·column schema
- [UNKNOWN] component와 external boundary
- [UNKNOWN] 상태 전이 구현 방식과 동시성 제어
- [UNKNOWN] polling, scheduling, retry와 backoff
- [UNKNOWN] URL identity와 정규화 알고리즘
- [UNKNOWN] 중요도 공식, 홍보성 label·임계값과 동률 처리
- [UNKNOWN] Discord webhook·bot·Gateway·HTTP interaction·주기 조회 선택
- [UNKNOWN] Discord message, article과 batch의 표시·mapping
- [UNKNOWN] slash command의 정확한 이름·parameter·언어와 누락 사유 응답 UI
- [UNKNOWN] Application 실행 환경과 secret 저장 방식
- [UNKNOWN] 13시간 latency 시작 시각
- [UNKNOWN] 장기 Discord 장애 backlog 상한·분할
- [UNKNOWN] MVP-A 품질 검토 이후 임시 데이터의 Retention과 삭제
- [UNKNOWN] 인프라와 배포 방식

## Technical Requirements Exit Criteria

- [INFERENCE] Functional, Non-functional, Data, External Integration과 Verification Requirements가 승인된 Product Specification을 변경하지 않고 구현·검증 가능한 수준으로 정의됐습니다.
- [INFERENCE] 각 요구사항이 Requirement ID, 우선순위, 제품 근거, 검증 방법과 미결정 의존성을 포함합니다.
- [INFERENCE] AC-01~AC-24가 Technical Requirement와 검증 증거에 연결됩니다.
- [INFERENCE] 여섯 Hard Gate를 검증할 로그·상태·테스트·운영 지표가 제안됐습니다.
- [INFERENCE] Architecture와 Data / Interface Design에서 결정할 사항이 기술 요구사항과 분리됐습니다.
- [UNKNOWN] 사용자가 이 Draft를 검토하고 최종 승인해야 Technical Requirements 단계를 완료할 수 있습니다.
