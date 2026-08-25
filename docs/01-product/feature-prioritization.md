# Feature Prioritization

## Document Status

[FACT] Workflow 단계: 4. Feature Prioritization

[FACT] 상태: Approved

[FACT] 승인일: 2026-08-25 Asia/Seoul

[FACT] 승인자: 프로젝트 사용자 및 소유자

[FACT] 이 문서는 승인된 [Problem Definition](problem.md), [Research / JTBD](research.md)와 [Solution Discovery](solution-discovery.md)를 바탕으로 MVP 기능 후보를 비교하고 승인된 우선순위를 기록합니다.

[FACT] 사용자가 2026-08-25에 최초 P0·P1 MVP 포함, 후순위 기능, 기존 제외 범위와 주요 Trade-off를 승인했으며 아래 비판적 제품 검토 결정으로 최초 MVP 범위를 개정했습니다.

[FACT] 사용자가 2026-08-25의 비판적 제품 검토 후 최초 MVP를 MVP-A 일일 가치 검증과 MVP-B 후속 완결성으로 분리하고, 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다루며, 모든 후보 자격을 유지하되 모든 항목에 동일한 수준의 AI 처리를 보장하지 않는 우선순위 개정을 승인했습니다.

[FACT] 이 문서는 상세 요구사항, acceptance criteria, 기술 요구사항, Architecture, 데이터·인터페이스 설계, 구현 계획 또는 구현 방식을 확정하지 않습니다.

## Prioritization Question

[INFERENCE] 이번 단계의 핵심 질문은 다음과 같습니다.

> 어떤 기능이 중요한 한국어 IT 기사를 하루 두 번 빠르게 판단하는 최초 MVP-A에 필요하고, 어떤 장기 추세·데이터 lifecycle 기능을 MVP-A 검증 후 MVP-B로 분리해야 하는가?

## Approved Inputs and Boundaries

- [FACT] 사용자는 프로젝트 소유자 한 명이며 일일 큐레이션과 월별 기술 흐름을 확인하려고 합니다.
- [FACT] MVP 수집원은 GeekNews RSS 하나이고 News, Ask와 Show를 모두 일반 후보로 유지합니다.
- [FACT] 외부 원문 기사 본문은 수집하지 않습니다.
- [FACT] 승인된 Solution은 모든 RSS entry의 후보 자격을 유지하고 근거 제한형 AI 판단과 결정적 하드 가드레일을 결합하되, 모든 항목에 동일한 수준의 AI 처리를 보장하지 않고 처리하지 못한 후보를 조용히 제외하지 않는 Approach C입니다.
- [FACT] 기사별 공통 결과를 재사용하고 월별 기준으로 별도 정규화·집계하는 4C가 승인됐습니다.
- [FACT] MVP-A는 일일 Discord 결과와 최소 추적·feedback·측정을 검증하며, 월별 Insight, 장기 재사용·normalization과 자동 Retention lifecycle은 MVP-B 후속 범위입니다.
- [FACT] 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다룹니다.
- [FACT] 후보 처리 정책은 후보 자격과 비무음 원칙 유지, 실제 무료 AI 후보 검증, 검증 결과에 따른 fallback 명세 순서로 진행합니다.
- [FACT] 중요도·홍보성 기준, AI 제공자, 실패 동작, 월별 집계 공식과 전달 방식은 아직 결정되지 않았습니다.
- [INFERENCE] 따라서 이번 단계는 기능의 포함 여부와 상대 우선순위만 비교하고, 각 기능의 상세 정책과 구현 방식은 이후 단계에 남겨야 합니다.

## Evaluation Criteria

[INFERENCE] 숫자 점수는 근거가 부족한 차이를 정밀해 보이게 만들 수 있으므로 정성 등급으로 비교합니다.

1. [INFERENCE] **사용자 가치**: 뉴스 탐색·정리 시간, 중요 기사 누락 가능성, 홍보성 검토 부담 또는 월별 추세 파악에 미치는 직접 효과
2. [INFERENCE] **MVP 필수성**: 승인된 MVP 결과를 제공하거나 비용·보존·신뢰성 Guardrail을 지키는 데 필요한 정도
3. [INFERENCE] **의존성**: 해당 기능 전에 갖춰져야 하는 제품 capability 또는 아직 해소해야 할 결정·검증
4. [INFERENCE] **비용 압력**: 무료 AI 할당량, 요청량과 추가 운영 자원에 주는 상대적 압력
5. [INFERENCE] **운영 복잡도**: 재실행, 부분 실패, 상태 경계, 품질 확인과 장기 유지에 필요한 운영 부담
6. [INFERENCE] **위험**: 기능이 실패하거나 잘못 동작했을 때 누락, 중복, 잘못된 판단, 데이터 손실 또는 비용 초과로 이어질 가능성과 영향

[INFERENCE] 사용자 가치, 비용 압력, 운영 복잡도와 위험은 `낮음 / 보통 / 높음`으로 비교합니다. MVP 필수성은 `MVP-A 필수 / MVP-A 최소·MVP-B 확장 / MVP-B / 후순위 / 승인 범위와 충돌`로 구분합니다.

## Feature Candidate Assessment

### Candidates Derived from the Approved MVP

| ID | 기능 후보 | 사용자 가치 | MVP 필수성 | 주요 의존성 | 비용 압력 | 운영 복잡도 | 주요 위험 |
|---|---|---:|---|---|---:|---:|---:|
| F01 | GeekNews RSS 후보 수집과 필수 입력 검증 | 높음 | MVP-A 필수 | 공식 feed의 현재 접근 가능성 | 낮음 | 보통 | 보통 |
| F02 | 이전 발송 이후 신규 기사 구간, 중복과 재처리 상태 관리 | 높음 | MVP-A 필수 | F01, 발송·수집 경계의 후속 정의 | 낮음 | 높음 | 높음 |
| F03 | RSS 근거 제한형 기사 분석: 한국어 표시 제목, 보수적 요약, 주제·keyword 후보, 포함 추천, 상대적 중요도, 홍보성 판단과 근거 | 높음 | MVP-A 필수 | F01, 단일 무료 AI 후보 검증, 후속 판단·fallback 기준 | 높음 | 높음 | 높음 |
| F04 | 근거·필수 형식·최대 출력·잘못된 응답·무료 한도·유료 전환 차단, 명시적 fallback과 실패 가시성을 위한 하드 가드레일 | 높음 | MVP-A 필수 | F03, 무료 AI 검증 후 실패·fallback 정책 | 낮음 | 보통 | 높음 |
| F05 | 이전 발송 이후 기사에서 중요도순 최대 10개 선정, 홍보성 의심 제외와 제외 건수 표시 | 높음 | MVP-A 필수 | F02~F04, 후속 중요도·홍보성 기준 | 낮음 | 높음 | 높음 |
| F06 | 매일 10:00·22:00 KST Discord 발송, 신규 기사 0건 시 미발송과 처리 실패 미발송의 구분 | 높음 | MVP-A 필수 | F02, F04, F05, Discord 전달·실패 알림 조건 | 낮음 | 보통 | 높음 |
| F07 | 기사별 AI 결과와 판단 추적 정보의 보존·재사용 | 보통 | MVP-A 최소 / MVP-B 확장 | F03, 후속 보존 필드·version 경계 | 낮음 | 보통 | 높음 |
| F08 | 공통 taxonomy를 이용한 월별 정규화·집계와 불변 Insight 보존 | 높음 | MVP-B | F07, 후속 집계·대표 기사·전달 기준 | 보통 | 높음 | 높음 |
| F09 | Raw RSS 3개월, 기사별 AI 결과 12개월, 월별 Insight 무기한의 설정 가능한 Retention lifecycle | 보통 | MVP-B | F01, F07, F08, 후속 삭제 안전 기준 | 낮음 | 높음 | 높음 |
| F10 | 첫 2~4주 기사량·AI 사용량·배치 시간, 사용자 feedback과 품질 판단을 확인할 수 있는 최소 측정 capability | 높음 | MVP-A 필수 | F01~F07에서 측정할 결과와 상태 | 낮음 | 보통 | 보통 |

### Additional Candidates

| ID | 기능 후보 | 사용자 가치 | MVP 필수성 | 주요 의존성 | 비용 압력 | 운영 복잡도 | 주요 위험 |
|---|---|---:|---|---|---:|---:|---:|
| L01 | AI 판정과 요약을 사람이 수정·승인하는 전용 검토 화면 | 보통 | 비필수 | F07, 검토 workflow 정의 | 낮음 | 높음 | 보통 |
| L02 | 관심 주제·keyword와 선호도를 사용자가 직접 변경하는 설정 기능 | 보통 | 비필수 | 품질 feedback, 변경 영향 정책 | 낮음 | 보통 | 보통 |
| L03 | 저장된 기사와 월별 Insight의 검색·탐색 화면 | 보통 | 비필수 | F07, F08 | 낮음 | 높음 | 낮음~보통 |
| L04 | News·Ask·Show source type 추론·표시 | 낮음 | 비필수 | 안정적인 분류 근거 | 낮음 | 보통 | 보통 |
| L05 | 월별 Insight의 자동 전달 채널과 알림 | 보통 | 비필수 | F08, 사용자의 채널·시점 결정 | 낮음 | 보통 | 보통 |
| L06 | 하루 두 번 배치 외 실시간·수시 알림 | 낮음 | 비필수 | 별도 notification 정책 | 보통 | 높음 | 보통 |
| L07 | 운영자용 수동 재발송·재처리 UI | 낮음~보통 | 비필수 | F02, 실패·복구 정책 | 낮음 | 높음 | 보통 |

## Approved Priority

[FACT] 사용자가 2026-08-25에 아래 우선순위 구분을 승인했습니다.

### MVP-A — P0 Core Daily Value and Learning Loop

1. [FACT] **F01 RSS 후보 수집과 입력 검증**
2. [FACT] **F02 신규 기사 구간·중복·재처리 상태 관리**
3. [FACT] **F03 근거 제한형 기사 분석**
4. [FACT] **F04 결정적 하드 가드레일과 비용 차단**
5. [FACT] **F05 일일 기사 선정·순위·홍보성 제외**
6. [FACT] **F06 Discord 정시 발송·0건 미발송**
7. [FACT] **F07 판단을 검토할 최소 근거·결과 version 보존**
8. [FACT] **F10 사용자 feedback과 초기 사용량·지연·품질 측정 capability**

[FACT] MVP-A는 일일 큐레이션의 사용자 가치를 끝까지 전달하고 첫 2~4주의 품질과 실현 가능성을 검증하는 최소 capability 묶음입니다. 위 번호는 제품 동작의 의존 관계를 나타내며 상세 구현 순서를 확정하지 않습니다.

### MVP-B — P1 Follow-up Completeness

1. [FACT] **F07 기사별 결과의 장기 보존·재사용 확장**
2. [FACT] **F08 월별 정규화·Insight 생성·영구 보존**
3. [FACT] **F09 설정 가능한 Retention lifecycle**

[FACT] MVP-B는 MVP-A 검증 후 장기 추세 Job과 데이터 lifecycle을 확장하는 후속 범위이며 MVP-A 완료의 선행조건이 아닙니다.

### 후순위

- [FACT] **L01 전용 사람 검토 화면**은 후순위입니다. [INFERENCE] 판단 근거의 최소 보존은 F07에 포함하되 별도 UI는 실제 검토 부담을 관찰한 뒤 결정합니다.
- [FACT] **L02 주제·선호도 설정**과 **L03 검색·탐색 화면**은 후순위입니다. [INFERENCE] 한 명의 사용자와 승인된 고정 관심 주제로 핵심 가치를 먼저 검증합니다.
- [FACT] **L04 source type 추론·표시**는 후순위입니다. [INFERENCE] source type은 후보 포함 조건이 아니므로 일일·월별 가치에 직접 필요하다는 근거가 없습니다.
- [FACT] **L05 월별 Insight 자동 전달**은 후순위입니다. [INFERENCE] Insight 생성과 보존은 MVP에 포함하되 전달 채널과 시점이 결정되기 전에는 별도 전달 기능을 확정하지 않습니다.
- [FACT] **L06 실시간 알림**과 **L07 운영자 UI**는 후순위입니다. [INFERENCE] 현재의 하루 두 번 확인 Job과 최소 운영 범위를 먼저 검증합니다.

### MVP 제외

[FACT] 아래 항목은 새 우선순위 판단으로 제외하는 것이 아니라 승인된 Problem Definition의 제외·조건부 범위를 유지하는 것입니다.

| 제외 후보 | 구분 | 근거 |
|---|---|---|
| GeekNews 상세 페이지 또는 외부 원문 본문 수집 | 조건부 제외 | RSS 요약 품질 부족이 검증된 경우에만 별도 사용자 승인으로 재검토 |
| 외부 원문 직접 URL을 얻기 위한 추가 crawling | 제외 | RSS topic link 사용이 승인됐고 외부 페이지 수집은 현재 범위가 아님 |
| 다중 뉴스 수집원, 시사·경제 뉴스와 네이버 RSS | 제외 | 승인된 MVP는 한국어 IT 뉴스와 GeekNews RSS 하나로 제한 |
| 여러 AI 제공자 동시 구현 또는 자동 failover | 제외 | 무료 제공자 하나만 선택하고 교체 가능한 경계만 고려 |
| 무료 한도 이후 자동 유료 호출 | 금지 | 추가 월 운영비 상한 0원과 직접 충돌 |
| 팀·다중 사용자 기능 | 제외 | MVP 대상은 프로젝트 소유자 한 명 |
| Kafka와 Spark | 제외 | 현재 규모와 요구사항으로 필요성이 입증되지 않음 |

## Recommendation Rationale

1. [INFERENCE] F01~F06은 수집에서 Discord 확인까지 Core Job을 완결합니다. 하나라도 없으면 사용자가 하루 두 번 중요한 기사를 빠르게 판단하는 결과가 성립하지 않습니다.
2. [INFERENCE] 모든 일반 후보의 자격을 유지하고 F04로 절대 제약과 명시적 fallback을 통제하는 구성이 승인된 Approach C와 3B를 유지하면서 무료 한도 압력을 검증할 여지를 남깁니다.
3. [INFERENCE] F02와 F04는 눈에 보이는 기능은 아니지만 누락·중복·근거 없는 결과·유료 전환이 핵심 가치를 훼손하는 것을 막으므로 P0에 필요합니다.
4. [INFERENCE] F07의 최소 근거·version과 F10의 feedback·측정은 MVP-A의 품질을 판정하는 데 필요합니다.
5. [INFERENCE] F08과 F09는 MVP-A 검증 후 기사별 결과를 장기 재사용하고 월별 기준으로 정규화하는 4C와 Retention 목표를 완성합니다.
6. [INFERENCE] F10은 최대 100건/일, 월 0원과 배치 30분 목표가 실제로 가능한지 첫 2~4주에 검증하고 MVP-B 진입의 근거를 만듭니다.
7. [INFERENCE] 전용 UI, 실시간 전달과 추가 분류 metadata를 후순위로 두면 핵심 가치와 Guardrail을 바꾸지 않으면서 초기 운영 복잡도를 제한할 수 있습니다.

## Major Trade-offs

- [INFERENCE] **누락 위험 대 AI 비용 압력**: 모든 News·Ask·Show의 후보 자격을 유지하면 조기 keyword 제외보다 중요한 기사를 놓칠 위험은 낮아지지만, 동일 수준의 AI 처리를 보장하지 않을 때는 명시적 fallback과 미처리 가시성이 필요합니다.
- [INFERENCE] **판정 유연성 대 재현성**: AI에 포함 추천·상대적 중요도·홍보성 의미 판단을 맡기면 맥락을 반영할 수 있지만 동일 입력의 결과가 달라질 수 있습니다.
- [INFERENCE] **추적 가능성 대 운영 복잡도**: 판단 근거와 결과 version을 보존하면 오판 검토와 월별 재사용에 유리하지만 보존·변경 경계를 관리해야 합니다.
- [INFERENCE] **빠른 일일 가치 대 월별 완결성**: MVP-A를 먼저 검증하면 초기 범위와 실패 비용은 줄지만 월별 Insight와 자동 Retention은 MVP-B까지 제공되지 않습니다.
- [INFERENCE] **자동화 범위 대 초기 검토 편의**: 전용 사람 검토 UI를 미루면 MVP 범위는 작아지지만 초기 오판을 검토·수정하는 과정은 덜 편리할 수 있습니다.
- [INFERENCE] **보존 대 데이터 lifecycle 위험**: 서로 다른 Retention은 비용과 장기 분석을 균형 있게 만들지만 삭제 순서가 잘못되면 월별 결과의 추적 근거를 잃을 수 있습니다.

## Remaining Unknowns

### Required for Product Specification

- [FACT] 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 봅니다.
- [UNKNOWN] 관심 주제 적합성, 상대적 중요도와 홍보성 판단 기준·label·합격선
- [UNKNOWN] 홍보성 False Positive와 False Negative 중 어느 오류를 더 엄격히 제한할지
- [UNKNOWN] 저정보 entry를 1문장으로 허용할지, 불충분으로 표시할지, 주요 목록에서 제외할지
- [UNKNOWN] 판단 근거, confidence, model·prompt와 결과 version을 어떤 수준으로 보존하고 사용자에게 노출할지
- [UNKNOWN] AI 실패·무료 한도 소진·부분 응답 때 기사를 보류할지 제한된 결과로 처리할지
- [UNKNOWN] 모든 후보에 동일한 수준의 AI 처리를 수행하지 못할 때 보류, 제한 결과 또는 미발송 중 어떤 fallback을 적용하고 어떻게 표시할지
- [UNKNOWN] 보류·재시도, 제한 결과와 미발송의 정확한 조건과 우선순위
- [UNKNOWN] Discord 자체 장애를 포함한 실패 사실과 미처리 건수의 알림 채널과 형식
- [UNKNOWN] MVP-A의 최소 사용자 feedback 수집 방식과 품질 합격선
- [UNKNOWN] 월별 Insight의 전달 채널과 생성 시점
- [UNKNOWN] 월별 주제 비중의 분모, 다중 주제 처리, 신규·급증 keyword 공식과 대표 기사 기준
- [UNKNOWN] 월별 normalization에서 결정적 규칙만 사용할지 같은 단일 AI 제공자의 보조를 허용할지

### Required Before Technical Decisions

- [UNKNOWN] 단일 무료 AI 후보의 한국어 품질, 무료 할당량, rate limit, 데이터 이용 조건과 유료 전환 차단 방법
- [UNKNOWN] GeekNews polling 허용 기준, conditional request, ID·link 안정성, 시각 의미와 갱신 동작
- [UNKNOWN] 발송·수집 경계, 재수집 중첩 범위와 중복·재처리의 정확한 상태 규칙
- [UNKNOWN] Retention 삭제 기준 시각, 실행 순서, 실패·audit·복구 정책
- [UNKNOWN] Approach C가 최대 100건/일을 월 0원과 배치 30분 이내에 처리할 수 있는지

### Current Approval State

- [FACT] 사용자가 2026-08-25의 비판적 제품 검토 후 기존 P0·P1을 MVP-A와 MVP-B로 분리하는 개정을 승인했습니다.
- [FACT] 사용자가 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다루기로 승인했습니다.
- [FACT] 사용자가 모든 News·Ask·Show의 후보 자격을 유지하되 모든 항목에 동일한 수준의 AI 처리를 보장하지 않고, 처리하지 못한 후보를 조용히 제외하지 않는 방향을 승인했습니다.
- [FACT] 사용자가 후보 자격 유지, 실제 무료 AI 후보 검증, 검증 결과에 따른 fallback 명세 순서로 진행하고 정확한 fallback 조건은 검증 후 확정하는 방향을 승인했습니다.
- [FACT] 사용자가 2026-08-25에 문서의 주요 Trade-off를 확인하고 승인했습니다.

## Traceability to Approved Work

| 승인 근거 | 반영된 후보 |
|---|---|
| Problem Definition의 일일 Discord 결과 | F01~F06 |
| Solution Discovery의 Approach C와 3B | F03, F04, F05, F07 |
| 비판적 검토 후 승인된 MVP-A 일일 가치·학습 loop | F01~F07 최소 범위, F10 |
| Solution Discovery의 4C와 월별 Insight | MVP-B의 F07 확장, F08 |
| 승인된 목표 Retention | MVP-B의 F07, F08, F09 |
| 최대 100건/일, 월 0원, 30분 배치와 첫 2~4주 측정 | MVP-A의 F04, F10 |
| Problem Definition의 명시적 제외·조건부 범위 | MVP 제외 전체 |

## Stage Boundary

- [FACT] 이번 단계에서는 feature 포함 범주와 상대 우선순위만 확정했습니다.
- [FACT] acceptance criteria, 상세 출력 규칙, 점수 공식, 임계값, AI 제공자, 수집 주기, 데이터 schema, component 구조, 기술 stack과 구현 순서는 정하지 않습니다.
- [FACT] 2026-08-25 비판적 제품 검토 후 사용자가 승인한 MVP-A/MVP-B 분리와 후보 처리 원칙 개정을 현재 우선순위에 적용합니다.
- [FACT] 코드, 테스트와 배포 구성은 작성하지 않습니다.
- [FACT] 사용자 승인으로 확정된 우선순위만 `[FACT]`로 기록했습니다.
- [FACT] 단계 종료 commit/push 완료 또는 사용자의 명시적 연기 전에는 Product Specification으로 이동하지 않습니다.

## Feature Prioritization Exit Criteria

- [FACT] 승인된 이전 단계에서 MVP 기능 후보를 식별했습니다.
- [FACT] 사용자 가치, MVP 필수성, 의존성, 비용 압력, 운영 복잡도와 위험을 비교했습니다.
- [FACT] MVP 포함, 후순위와 제외 추천을 구분했습니다.
- [FACT] 추천안, 추천 근거와 주요 Trade-off를 분리했습니다.
- [FACT] 상세 정책과 기술 검증 항목을 `[UNKNOWN]`으로 유지했습니다.
- [FACT] 사용자가 2026-08-25에 Feature Prioritization을 명시적으로 승인했습니다.
- [FACT] 최초 Feature Prioritization 단계 종료 commit/push는 commit `bd4b359`로 완료됐습니다.
- [UNKNOWN] 2026-08-25 우선순위 개정 내용을 반영한 문서 동기화 commit/push가 남아 있습니다.
