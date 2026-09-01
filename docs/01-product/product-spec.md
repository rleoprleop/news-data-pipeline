# Product Specification

## Document Status

[FACT] Workflow 단계: 5. Product Specification

[FACT] 상태: Approved

[FACT] 정책 승인일: 2026-08-26 Asia/Seoul

[FACT] 문서 최종 승인일: 2026-08-26 Asia/Seoul

[FACT] Feedback 정책 개정 승인일: 2026-08-26 Asia/Seoul

[FACT] Technical Requirements 정책 보완 승인일: 2026-08-27 Asia/Seoul

[FACT] 승인자: 프로젝트 사용자 및 소유자

[FACT] 작성 기준일: 2026-08-26 Asia/Seoul

[FACT] 작성자 역할: Senior Product Manager, Software Architect, Senior Data Engineer

[FACT] 사용자는 2026-08-26에 이 문서에 반영할 제품 방향, 중요도·관심 주제, 홍보성, 저정보 entry, 실패 가시성, Discord 복구, feedback과 MVP-A 합격선 정책을 승인하고 문서 작성을 요청했습니다.

[FACT] 이 문서는 승인된 제품 정책과 acceptance criteria를 정의하며 AI 제공자, SDK, 데이터베이스 schema, component 구조, 인프라 또는 구현 방식을 확정하지 않습니다.

[FACT] 사용자가 2026-08-26에 이 Product Specification 문서를 최종 승인했습니다.

[FACT] 사용자가 2026-08-26 Technical Requirements 검토 중 Discord reaction 기반 batch 검토 완료, 부정 feedback, 암묵적 수용률, 구조화된 slash command를 통한 누락 기사 feedback과 recall 분류 정책을 추가 승인했습니다.

[FACT] 사용자가 2026-08-27 Technical Requirements 순차 검토에서 예정 batch·Discord 수락 시각, Asia/Seoul 일자별 고유 신규 후보 100건 기준, 추가 월 비용 0원, Raw RSS 원본 보존과 원값 `link` 단일 identity 정책을 추가 승인했습니다.

[FACT] 사용자가 2026-09-01 Architecture 검토에서 유효 후보 AI 분석 미완료 시 목록 미발송, 전체 선정 완료 뒤 별도 처리 지연 full result 발송, Discord 미수락 backlog와의 분리, 정시 attempt·1분 안 수락 목표를 승인했습니다.

## Purpose

[FACT] 프로젝트명은 `IT 뉴스 데이터 파이프라인`입니다.

[FACT] 제품 목표는 프로젝트 소유자 한 명이 매일 두 번 중요한 한국어 IT 뉴스를 빠르게 확인하고 GeekNews topic으로 이동해 원문 확인 여부를 판단할 수 있도록 수집·분석·선정·전달하는 배치 데이터 파이프라인을 제공하는 것입니다.

[FACT] 포트폴리오 목표는 단순 뉴스 요약이 아니라 멱등 수집, 상태 관리, 데이터 품질, AI 판단의 근거와 한계, 실패 가시성, 무료 운영 제약과 측정 가능한 운영을 설명할 수 있는 제품을 만드는 것입니다.

[INFERENCE] MVP-A의 핵심 검증 질문은 다음과 같습니다.

> 제한된 GeekNews RSS 근거와 추가 월 운영비 0원 안에서 중요한 기사의 누락을 우선적으로 줄이면서, 사용자가 하루 두 번 신뢰할 수 있는 큐레이션과 처리 한계를 확인할 수 있는가?

## Approved Source Traceability

| 승인 근거 | 승인된 결정 | 이 문서의 반영 위치 |
|---|---|---|
| [Problem Definition](problem.md) | [FACT] 한 명의 사용자, 하루 두 번 Discord, 최대 10개, 월 0원, 최대 100건/일, 13시간 전달과 30분 배치 목표 | Product Scope, User-visible Outcome, Service Goals, Acceptance Criteria |
| [Research / JTBD](research.md) | [FACT] News·Ask·Show 전체 feed, RSS title·content·topic link, 48/50 요약 가능, 저정보 예외 존재 | Input Boundary, Evidence Policy, Low-information Scenario |
| [Solution Discovery](solution-discovery.md) | [FACT] Approach C와 3B, 후보 자격 유지, 비무음 fallback, 실패와 0건 구분 | Analysis Policy, Batch States, Failure Scenarios |
| [Feature Prioritization](feature-prioritization.md) | [FACT] F01~F07 최소 범위와 F10이 MVP-A이며 F07 확장·F08·F09는 MVP-B | End-to-end Flow, Feedback, Metrics, MVP Boundary |
| 2026-08-26 사용자 승인 | [FACT] 중요도·적합성 분리, 홍보성 False Positive 우선, 저정보 제한 결과, Discord 복구 발송, feedback과 합격선 | Product Policies, Recovery, Quality Gate |
| 2026-08-26 Feedback 정책 개정 승인 | [FACT] batch 검토 완료, 세 부정 reaction, 암묵적 수용률, 구조화된 누락 기사 제출·사유 회신과 후보 recall·수집 범위 누락 분리 | Feedback Scenario, Quality Metrics, AC-20, AC-21 |
| 2026-08-27 최신성·발송 시각 정책 개정 승인 | [FACT] 기존 게시 후 실제 전달 13시간 목표를 예정 전달 시각 기준 `published` 13시간 이내의 결정적 현재 기사 최신성 정책으로 대체하고, batch·Discord 정시 수락·복구 지연을 별도 측정 | Candidate Processability, Selection, Recovery, Reliability·Latency Metrics, Service Goals, AC-09 |
| 2026-08-27 NFR·DR 순차 검토 승인 | [FACT] `100건/일`의 Asia/Seoul 일자별 고유 신규 후보 기준, 추가 월 비용 0원, Raw RSS 원본 계층과 원값 `link` 단일 identity | Candidate Terms, Capacity·Cost, Scenario 8, Remaining Unknowns |

## Target User and Job

### Target User

- [FACT] 사용자는 프로젝트 소유자 한 명입니다.
- [FACT] 팀용 정보 시스템과 다중 사용자 서비스는 MVP-A 대상이 아닙니다.
- [FACT] 사용자는 매일 10:00와 22:00 KST에 Discord 결과를 확인합니다.

### Job to Be Done

[INFERENCE] 사용자가 하루의 주요 뉴스 확인 시점에 최신 한국어 IT 뉴스를 살펴볼 때, 여러 페이지를 순회하거나 홍보성 글을 일일이 가려내지 않고 중요한 기술 변화와 읽을 GeekNews topic을 빠르게 판단하여 놓치면 안 되는 기사를 신뢰할 수 있게 파악하고 싶습니다.

### User-visible Success

- [FACT] 사용자는 각 완료된 신규 처리 구간의 중요한 기사를 최대 10개로 압축해 확인하며, Discord 전달 실패로 복구하는 과거 선정 결과는 현재 신규 결과와 구분해 확인합니다.
- [FACT] 각 정상 결과에서 한국어 제목, 2~3문장 요약, keyword와 GeekNews topic link를 확인합니다.
- [FACT] 저정보 entry가 선정되면 정보가 충분한 것처럼 보이지 않는 제한 결과를 확인합니다.
- [FACT] 홍보성 의심 기사는 주요 목록에서 제외되고 사용자는 제외 건수를 확인합니다.
- [FACT] 신규 기사가 0건이면 불필요한 Discord 메시지를 받지 않습니다.
- [FACT] AI 실패, 무료 한도 소진, 부분 처리 또는 Discord 장애는 정상 0건과 구분됩니다.
- [FACT] Discord 장애로 전달하지 못한 기사는 다음 성공 정규 발송에서 지연 이유와 함께 확인합니다.

## Product Scope

### MVP-A — Initial Daily Validation

- [FACT] 수집원은 GeekNews RSS 하나입니다.
- [FACT] 한국어 IT 뉴스만 다룹니다.
- [FACT] RSS의 title, content 또는 description, link와 관련 metadata만 처리합니다.
- [FACT] 외부 원문 기사 본문과 GeekNews 상세 페이지 본문은 수집하지 않습니다.
- [FACT] News, Ask와 Show는 모두 일반 후보 자격을 유지합니다.
- [FACT] 링크 기반 중복 방지와 신규 기사 구간·재처리 상태 관리 capability가 필요합니다.
- [FACT] RSS 근거 제한형 분석, 중요도·관심 주제·홍보성 판단과 최대 10개 선정을 포함합니다.
- [FACT] 매일 10:00와 22:00 KST Discord 발송을 포함합니다.
- [FACT] 정상 0건, 후보 생성 불가능 입력 오류가 있는 입력 제약 결과, AI 미완료 목록 미발송, 처리 지연 full result, 전체 선정 불가 처리 실패 notice와 Discord 전달 실패를 구분합니다.
- [FACT] 최소 판단 근거와 결과 version을 보존합니다.
- [INFERENCE] 최소 판단 근거와 결과 version은 적어도 해당 MVP-A feedback·품질 검토가 끝날 때까지 재검토할 수 있어야 합니다.
- [FACT] 사용자 feedback과 첫 2~4주의 초기 사용량·지연·품질 측정을 포함합니다.

### MVP-B — Follow-up Scope

- [FACT] 기사별 AI 결과의 장기 보존·재사용 확장
- [FACT] 공통 taxonomy에 따른 월별 normalization·aggregation
- [FACT] 월별 Insight 생성과 불변 결과의 영구 보존
- [FACT] Raw RSS 3개월, 기사별 AI 결과 12개월, 월별 Insight 무기한의 자동 Retention lifecycle
- [FACT] MVP-B는 MVP-A 완료의 선행조건이 아닙니다.

### Explicitly Out of Scope or Later

- [FACT] 외부 원문 기사 본문과 GeekNews 상세 페이지 본문 수집
- [FACT] 다중 뉴스 수집원
- [FACT] 시사·경제 뉴스와 네이버 RSS
- [FACT] 여러 AI 제공자의 동시 구현과 자동 failover
- [FACT] 무료 한도 이후 자동 유료 호출
- [FACT] 월별 Insight 자동 전달
- [FACT] 검토 UI, 설정 UI, 검색 UI와 운영자 UI
- [FACT] News·Ask·Show source type 추론·표시
- [FACT] 실시간 알림
- [FACT] 다중 사용자 기능
- [FACT] Kafka와 Spark

## Product Terms and User-visible Batch States

### Candidate Terms

- [FACT] **RSS 관찰 entry**는 정상적으로 parsing된 Raw RSS에서 확인한 entry이며 신규 후보, 기존·중복 관찰과 후보 생성 불가능 입력 오류를 포함합니다.
- [FACT] **후보**는 RSS 관찰 entry 중 하나의 논리적 기사로 연결해 현재 또는 이후 처리할 자격을 확인할 수 있는 entry입니다. 후보 생성 불가능 입력 오류와 기존·중복 관찰은 신규 후보 수에 포함하지 않습니다.
- [FACT] **신규 후보**는 직전 완료된 신규 처리 구간 이후 현재 예정 batch의 처리 범위에 처음 포함된 후보입니다. 신규 처리 구간은 Discord 성공 전달 범위와 구분하며, 과거 선정 후 미수락된 복구 기사와 과거 정상 미선정 기사는 현재 신규 후보에 다시 포함하지 않습니다.
- [FACT] **정상 분석 후보**는 RSS 근거 안에서 정상 결과의 필수 판단을 완료한 후보입니다.
- [FACT] **저정보 후보**는 RSS 입력 자체가 충실한 2~3문장 요약에 부족하지만 후보 자격을 유지하는 entry입니다.
- [FACT] **미처리 후보**는 AI 실패, 무료 한도, 처리 제약 또는 승인된 최신성 정책 때문에 필요한 분석을 완료하지 못했거나 수행하지 않은 후보이며, 그 원인을 서로 구분합니다.
- [FACT] **홍보성 의심 후보**는 승인된 보수적 제품 정책에 따라 주요 목록에서 제외할 근거가 충분하다고 판단된 후보입니다.
- [FACT] **선정 기사**는 현재 발송 결과에 포함하기로 결정된 정상 분석 또는 저정보 후보입니다.

[FACT] 위 용어는 제품 의미를 정의합니다. 정확한 상태 값, 저장 schema와 전이 구현은 이후 설계 단계에서 결정합니다.

### Batch States

| 사용자 관점 상태 | 제품 의미 | Discord 기대 |
|---|---|---|
| 정상 발송 | [FACT] 필요한 후보 처리를 완료하고 큐레이션을 생성함 | [FACT] 최대 10개 정상 결과 발송 |
| 정상 미발송 — 신규 0건 | [FACT] 장애가 없고 신규 후보가 없음 | [FACT] 메시지 발송 없음 |
| 입력 제약 결과 | [FACT] 일부 RSS entry에서 후보를 생성하지 못했지만, 생성된 모든 유효 후보의 필요한 처리는 완료됨 | [FACT] 입력 제약과 수를 표시하며, 목록을 발송하면 전체 RSS 관찰 범위의 완전한 Top 10으로 표현하지 않음 |
| 처리 실패 미발송 | [FACT] 정상적인 기사 목록을 생성하지 못함 | [FACT] Discord가 사용 가능하면 실패 사실과 미처리 건수를 알림 |
| Discord 전달 실패 | [FACT] 결과는 생성됐지만 Discord에 전달되지 않음 | [FACT] 발송 성공으로 처리하지 않고 다음 성공 정규 발송에서 복구 |

## End-to-end User Value Flow

### 1. GeekNews RSS Candidate Collection

- [FACT] News, Ask와 Show를 포함한 RSS 관찰 entry의 후보 자격을 동일하게 검토합니다.
- [FACT] 필수 입력이 부족하거나 잘못되어 후보를 생성할 수 없는 경우를 신규 후보와 구분된 명시적 입력 오류로 기록합니다.
- [FACT] source type, title prefix 또는 단순 keyword만으로 후보 자격을 제거하지 않습니다.

### 2. Candidate State and Processability Check

- [FACT] GeekNews RSS entry의 원값 `link`를 MVP-A의 단일 논리 기사 identity로 사용해 이미 본 후보와 신규 후보를 구분합니다. 같은 원값 `link`는 같은 기사이고 서로 다른 원값 `link`는 다른 기사이며, Atom `id`·제목·내용은 identity 판정 기준으로 사용하지 않습니다.
- [FACT] RSS 관찰 entry 수, 기존·중복 관찰 수, 후보 생성 불가능 입력 오류 수와 고유 신규 후보 수를 서로 구분합니다.
- [FACT] 현재 예정 Discord 전달 시각과 RSS `published`의 차이가 13시간 이내인 고유 신규 후보만 AI 분석과 현재 기사 선정 대상으로 진행하며 정확히 13시간인 후보는 포함합니다.
- [FACT] 위 차이가 13시간을 초과한 처음 관찰 기사는 고유 신규 후보 기록과 `게시 시각 기준 최신 전달 범위 밖`이라는 명시적 미처리 이유를 유지하되 AI 분석과 현재 기사 선정에서 제외합니다.
- [FACT] 재실행과 중첩 수집이 동일 기사의 중복 사용자 전달을 만들면 안 됩니다.
- [FACT] 이전 Discord 전달이 실패했다면 해당 발송 구간의 기사를 전달 완료로 처리하지 않습니다.
- [FACT] URL 정규화는 별도 승인 전 적용하지 않으며, identity 규칙 변경은 과거 기사·처리 결과·발송 경계를 소급 변경하지 않습니다.
- [UNKNOWN] GeekNews link의 장기 안정성·재사용, link 유효성 검증, 신규 구간과 재수집 중첩 범위의 구현 규칙은 Research와 Data / Interface Design에서 결정합니다.

### 3. Evidence-bounded Analysis

- [FACT] AI 입력 근거는 RSS title과 content 또는 description에 제한합니다.
- [FACT] AI는 한국어 표시 제목, 보수적 요약, 주제·keyword 후보, 포함 추천, 상대적 중요도, 홍보성 의심과 판단 근거를 제안합니다.
- [FACT] RSS에 없는 사실, 말줄임표 이후의 내용 또는 외부 원문의 내용을 추정하지 않습니다.
- [FACT] 최소 판단 근거와 결과 version을 재검토할 수 있어야 합니다.
- [UNKNOWN] AI 제공자, SDK, model, prompt와 구체적 version 표현은 이후 단계에서 결정합니다.

### 4. Importance, Interest and Promotional Judgment

- [FACT] 중요도와 사용자의 관심 주제 적합성을 별도 축으로 판단합니다.
- [FACT] 관심 주제는 데이터 엔지니어링, 클라우드, AI, 백엔드, 개발 도구와 데이터베이스입니다.
- [FACT] 관심 주제에 직접 관련되고 중요도가 높은 기사를 우선 고려합니다.
- [FACT] 관심 주제와 동떨어져 있어도 전체 IT 생태계에 미치는 영향이 높으면 전달 대상이 될 수 있습니다.
- [FACT] 관심 주제 밖이라는 이유만으로 후보에서 제외하지 않습니다.
- [INFERENCE] 중요도 판단에는 영향 범위, 변화의 실질성, 행동 가능성, 위험·긴급성을 사용자 관점 신호로 사용합니다.
- [INFERENCE] 회사 인지도, source type 또는 keyword 하나만으로 중요도를 확정하지 않습니다.
- [UNKNOWN] 점수 공식, 임계값과 동률 처리 방식은 이번 단계에서 확정하지 않습니다.

### 5. Selection

- [FACT] 현재 예정 batch의 신규 처리 구간에서 승인된 `published` 최신성 기준을 통과하고 정상 또는 저정보 결과를 가진 후보 중 중요도순 최대 10개를 주요 목록으로 선정합니다.
- [FACT] 홍보성 의심 후보는 주요 목록에서 제외하고 제외 건수를 표시합니다.
- [FACT] 홍보성 False Positive, 즉 유용한 비홍보 기사를 잘못 제외하는 오류를 False Negative보다 더 심각하게 다룹니다.
- [FACT] 홍보성이 애매한 후보는 제외하지 않는 보수적인 정책을 적용합니다.
- [INFERENCE] 제품·회사·출시를 다룬다는 사실만으로 홍보성으로 판정하지 않습니다.
- [INFERENCE] 판매·가입 유도가 주목적이거나 구체적인 기술 정보보다 과장·자기홍보가 중심이라는 RSS 근거가 있을 때 홍보성 의심 가능성이 커집니다.
- [UNKNOWN] 정확한 홍보성 label과 제외 임계값은 실제 품질 검증 후 결정합니다.

### 6. Discord Delivery or Explicit Non-delivery

- [FACT] 정상 발송 시 매일 10:00와 22:00 KST에 최대 10개를 제공합니다.
- [FACT] 신규 기사가 0건이면 Discord 메시지를 발송하지 않습니다.
- [FACT] AI 실패·무료 한도·처리 미완료·처리 지연 full result와 Discord 장애는 신규 0건과 구분합니다.
- [FACT] Discord가 메시지를 수락하지 않았다면 발송 성공으로 처리하지 않습니다.

### 7. Feedback and Measurement

- [FACT] 전달 기사에는 별로였음, 불필요함, 홍보성 의심의 세 부정 reaction을 복수로 수집할 수 있습니다.
- [FACT] 사용자는 한 정규 발송 기사 세트 전체를 확인한 뒤 batch 대표 메시지에 ✅ reaction으로 검토 완료를 표시합니다.
- [FACT] 검토 완료 batch에서 세 부정 reaction이 없는 기사는 암묵적 수용으로 기록합니다.
- [FACT] 암묵적 수용은 명시적으로 유용하다고 평가하거나 원문을 열었다는 뜻이 아닙니다.
- [FACT] 누락 중요 기사 후보는 구조화된 Discord slash command로 GeekNews topic link를 제출하고, 시스템은 Raw RSS `link` 원값 기준 기사 테이블의 실제 처리 기록에 따른 결과 또는 수집 기록상 누락을 회신합니다.
- [FACT] 누락 link 제출 자체를 누락 검토 요청으로 취급하고 별도의 확인 feedback은 수집하지 않습니다. 실제 이력상 제외·미선정 사유를 회신할 때만 사용자는 해당 기사가 추천됐어야 한다는 reaction을 남길 수 있습니다.
- [FACT] 홍보성으로 제외된 후보의 표본을 별도로 검토해 False Positive를 확인합니다.
- [FACT] 첫 2~4주에 기사량, 처리량, AI 사용량, 지연, 실패와 품질 지표를 측정합니다.

## Discord Output Specification

### Normal Article Item

[FACT] 정상 선정 기사는 다음 정보를 표시합니다.

1. [FACT] 한국어 제목
2. [FACT] RSS 근거 범위의 2~3문장 보수적 요약
3. [FACT] RSS 근거에서 도출한 keyword
4. [FACT] RSS가 제공한 GeekNews topic link

[FACT] 외부 원문 직접 URL은 필수가 아닙니다.

### Low-information Article Item

- [FACT] 저정보 후보도 후보 자격을 유지하며 중요도 판단 결과에 따라 주요 목록에 선정될 수 있습니다.
- [FACT] 선정된 저정보 후보에는 `정보 제한` 표시를 붙입니다.
- [FACT] 2~3문장을 억지로 생성하지 않고 RSS 근거가 허용하는 1문장 이하 설명을 제공합니다.
- [FACT] 충실한 사실 설명을 만들 수 없으면 `RSS 제공 정보가 부족해 상세 요약을 생성하지 못했습니다`라고 표시합니다.
- [FACT] 확인 가능한 keyword만 표시하고 GeekNews topic link는 제공합니다.
- [FACT] 저정보 선정 기사는 최대 10개 제한에 포함됩니다.
- [INFERENCE] 배치 요약에 `정보 제한 N건`을 표시하면 결과 한계를 빠르게 확인할 수 있습니다.

### Promotional Exclusion Summary

- [FACT] 홍보성 의심 기사는 주요 목록에서 제외합니다.
- [FACT] 제외된 기사가 있으면 `홍보성 의심 제외 N건`으로 개수를 표시합니다.
- [FACT] MVP-A Discord 결과에는 제외 기사 전체 목록을 표시하지 않습니다.

### Input-constrained Result Notice

[FACT] 후보 생성 불가능 입력 오류가 존재하지만 생성된 모든 유효 후보의 필요한 처리를 완료해 목록을 발송하는 경우 최소한 다음 사실을 명시합니다.

- [FACT] 전체 신규 후보 수
- [FACT] 정상 처리 수
- [FACT] 후보 생성 불가능 입력 오류가 존재하면 그 사실과 수
- [FACT] 전체 후보의 최종 Top 10이 아니라는 경고
- [FACT] 미처리 후보가 조용히 폐기되지 않았다는 상태

[INFERENCE] 사용자 표시 예시는 다음과 같습니다.

> 입력 제약 결과 — RSS 입력 오류 E건이 있어 후보를 생성하지 못했습니다. 신규 후보 N건 중 P건을 정상 처리했으며 아래 목록은 전체 RSS 관찰 범위의 완전한 Top 10이 아닙니다.

[FACT] 유효 후보 중 필요한 AI 분석이 하나라도 미완료이면 기사 목록을 발송하지 않습니다. 모든 유효 후보의 필요한 처리와 선정이 완료되면, 목표 시각 이후라도 원래 batch의 지연 full result로 발송합니다. 전체 선정이 불가능하면 기사 목록 대신 처리 실패 notice를 발송합니다.

### Full AI Failure Notice

- [FACT] 정상적인 기사 목록을 만들 수 없는 전체 AI 실패는 신규 기사 0건과 구분합니다.
- [FACT] Discord가 사용 가능하면 실패 범주, 신규 후보 수, 미처리 수와 유료 전환이 없었다는 사실을 알립니다.

[INFERENCE] 사용자 표시 예시는 다음과 같습니다.

> 이번 IT 뉴스 큐레이션을 완료하지 못했습니다. 신규 후보 N건 중 미처리 U건이며 유료 API로 전환하지 않았습니다.

## Core User Scenarios

### Scenario 1 — Normal Scheduled Delivery

1. [FACT] 09:30 또는 21:30 KST에 예정 batch를 시작하고 10:00 또는 22:00 KST Discord 도착을 준비합니다.
2. [FACT] 직전 완료된 신규 처리 구간 이후 현재 예정 batch에 처음 포함된 신규 후보를 확인합니다.
3. [FACT] 후보 상태, 입력, 중복 여부와 목표 전달 시각 기준 `published` 최신성을 확인합니다.
4. [FACT] 최신성 기준을 초과한 처음 관찰 후보는 명시적 이유를 남기고 AI 분석과 현재 기사 선정에서 제외합니다.
5. [FACT] 최신성 기준을 통과한 후보에 RSS 근거 제한형 분석과 중요도·관심 주제·홍보성 판단을 수행합니다.
6. [FACT] 홍보성 의심을 제외하고 중요도순 최대 10개를 선정합니다.
7. [FACT] 결과가 일찍 준비되면 예정 전달 시각까지 기다린 뒤 정상 Discord 결과를 발송합니다.
8. [FACT] Discord 전달이 확인된 경우에만 사용자 전달 성공으로 처리합니다.

### Scenario 2 — No New Articles

- [FACT] 신규 후보가 0건이고 처리 장애가 없다면 정상 미발송입니다.
- [FACT] Discord 메시지를 발송하지 않습니다.
- [FACT] 실패나 무료 한도 소진을 신규 0건으로 기록하지 않습니다.
- [FACT] 미발송 backlog가 존재한다면 신규 0건 정책보다 Discord 복구 발송 정책을 적용합니다.

### Scenario 3 — AI Response Failure or Free-quota Exhaustion

- [FACT] 유료 API로 자동 전환하지 않습니다.
- [FACT] 처리하지 못한 후보를 조용히 제외하지 않습니다.
- [FACT] 후보 수, 정상 처리 수와 미처리 수를 확인할 수 있어야 합니다.
- [FACT] 미처리 후보는 정상 제외 또는 전달 완료로 처리하지 않습니다.
- [INFERENCE] AI 복구 후 재처리할 수 있는 제품 상태를 유지해야 합니다.
- [UNKNOWN] 정확한 재시도 횟수·간격과 전체 선정 불가 판정 기준은 이후 검증·설계 단계에서 결정합니다.

### Scenario 4 — Incomplete Candidate Processing

- [FACT] 유효 후보 중 필요한 AI 분석이 미완료인 batch는 기사 목록을 발송하지 않으며, 완전한 정상 결과로 표시하지 않습니다.
- [FACT] 기존 pipeline이 모든 유효 후보의 필요한 처리와 선정까지 완료하면, 원래 batch의 지연 full result를 발송하고 지연 사실을 기록합니다.
- [FACT] quota 소진·비용 차단·영구 오류 등으로 전체 선정이 불가능하면 처리 실패 notice에 미처리 후보 수와 원인 범주를 표시합니다.
- [UNKNOWN] 원인별 재시도 횟수·간격과 전체 선정 불가능의 제공자별 판정 방식은 무료 AI 검증과 이후 설계에서 결정합니다.

### Scenario 5 — Discord Delivery Failure and Recovery

- [FACT] Discord가 메시지를 받지 못하면 해당 기사를 발송 완료로 처리하지 않습니다.
- [FACT] 각 batch의 선정 기사, 당시 상태와 후보·선정·최대 제한 미선정·홍보성 제외·미처리 수량을 재사용 가능한 논리적 발송 결과로 보존합니다.
- [FACT] Discord 서버 미수락이 확인된 전달은 자동 복구 backlog에 보존하고, 다음 10:00 또는 22:00 정규 발송에서 가장 오래된 원래 batch의 실제 미수락 선정 기사 최대 10개와 원래 batch 수량 요약을 AI 재분석·재선정·최신성 재판정 없이 `지연 기사` 구간으로 다시 제공합니다.
- [FACT] 과거 batch에서 최대 10개 제한으로 정상 미선정된 기사는 현재 신규 후보로 다시 포함하지 않지만, 해당 미선정 수는 지연 기사 구간의 원래 batch 요약에 유지합니다.
- [FACT] 장애 직후의 별도 임시 발송은 현재 제품 정책에 포함하지 않으며, 승인된 수신자가 미수신을 확인하거나 자동 복구 backlog의 추가 복구를 명시적으로 선택한 경우의 즉시 재전송만 예외입니다.
- [FACT] 응답 유실·timeout 등으로 Discord 서버 수락을 확인할 수 없는 전달은 수락 불명확으로 기록하며, 성공 전달·확인된 미수락·자동 재전송으로 추정하지 않습니다. 원래 Discord 전달 attempt 시각부터 1시간 안에 해당 원래 전달 message에 정확히 연결된 승인된 수신자의 reaction 또는 수신 확인 근거가 없으면, 원래 예정 batch당 한 번만 승인된 수신자에게 확인 메시지를 보냅니다.
- [FACT] 승인된 수신자가 `받음`으로 응답하면 사용자 수신 확인으로 기록하고 원래 결과를 재전송·복구 대상으로 다시 포함하지 않습니다. `못 받음`으로 응답하면 사용자 미수신 확인으로 기록하고, 저장된 원래 논리적 발송 결과를 AI 재분석·재선정·최신성 재판정 없이 즉시 재전송합니다. 이 즉시 재전송은 사용자 미수신 확인에 한정된 정규 발송 복구의 예외입니다.
- [FACT] 확인 메시지에 다음 성공 정규 batch 시각까지 응답이 없으면 확인 요청 무응답으로 기록합니다. 다음 성공 정규 batch에서 해당 원래 batch에 대해 복구 선택지를 한 번만 제공하며, 승인된 수신자가 재전송을 선택할 때만 저장된 원래 결과를 재전송합니다. 선택지에도 응답이 없으면 수락 불명확과 확인 요청 무응답을 유지하고 추가 확인 메시지·자동 재전송·자동 복구를 하지 않습니다.
- [FACT] 같은 원래 예정 batch에 확인 메시지는 한 번만 보냅니다. 사용자 미수신 확인에 따른 즉시 재전송도 다시 수락 불명확이 되면 확인 절차와 자동 재전송을 반복하지 않습니다. 사용자 수신 확인은 Discord 서버 수락 응답과 구분하며, 원래 수락 시각을 추정해 정시 전달 지표에 사용하지 않습니다.
- [FACT] 자동 복구 backlog가 정규 발송의 지연 기사 최대 10개를 초과하면 남은 대기 수와 가장 오래된 원래 batch를 표시합니다. 승인된 수신자가 `추가 복구`를 선택할 때마다 가장 오래된 원래 batch의 남은 실제 미수락 선정 기사 묶음만 원래 순서·수량 요약과 함께 즉시 전송합니다. 이 즉시 복구는 최대 10개이며 서로 다른 원래 batch의 기사를 섞지 않습니다. 선택하지 않은 backlog는 보존하고 자동 즉시 복구하지 않습니다.
- [FACT] 복구 메시지는 `이전 Discord 장애로 지연된 기사`와 `이번 발송 신규 기사`를 별도 구역으로 표시합니다.
- [FACT] 현재 신규 기사가 0건이어도 지연 기사가 있으면 복구 메시지를 발송하며, 현재 신규 결과가 있으면 원래 batch와 수량 요약이 다른 별도 논리적 구간으로 표시합니다.
- [FACT] 복구 발송은 `지연 기사 최대 10개 + 현재 기사 최대 10개`로 총 최대 20개를 허용합니다.
- [UNKNOWN] 두 번 이상의 발송 시각 동안 장애가 계속되어 지연 기사가 10개를 초과할 때의 backlog 상한과 분할 정책은 이후 결정합니다.

### Scenario 6 — Low-information RSS Entry

- [FACT] 저정보 entry라는 이유만으로 후보 자격을 제거하지 않습니다.
- [FACT] 중요도 판단 결과 선정되면 `정보 제한` 형식으로 발송합니다.
- [FACT] RSS에 없는 내용을 보완하지 않습니다.
- [FACT] 저정보 상태와 AI 처리 실패를 구분합니다.

### Scenario 7 — Promotional Suspicion

- [FACT] 충분한 홍보성 의심 근거가 있는 후보는 주요 목록에서 제외합니다.
- [FACT] 홍보성이 애매하면 유용한 기사 누락을 피하기 위해 후보 자격을 유지합니다.
- [FACT] Discord에는 제외 건수를 표시합니다.
- [FACT] 초기 검증에서는 제외 후보 표본을 검토해 False Positive를 측정합니다.

### Scenario 8 — Duplicate Collection and Re-run

- [FACT] 같은 GeekNews topic link가 반복 수집돼도 동일 기사를 사용자에게 중복 발송하지 않아야 합니다.
- [FACT] 성공한 발송 구간을 재실행해도 같은 기사 목록을 다시 보내지 않아야 합니다.
- [FACT] Discord 전달이 실패한 구간의 재실행은 중복 발송이 아니라 복구 대상이 될 수 있습니다.
- [FACT] MVP-A의 동일 기사 판정은 Raw RSS `link` 원값의 정확한 일치만 사용하고 URL 정규화는 적용하지 않습니다.
- [UNKNOWN] link 유효성 검증·고유성 constraint·동시성 제어, 발송 경계와 재처리 상태 전이의 구현은 Data / Interface Design에서 결정합니다.

### Scenario 9 — User Feedback

- [FACT] 전달 기사에 대해 😕 별로였음, 🚫 불필요함, 📣 홍보성 의심 reaction을 구분하고 한 기사에 복수 reaction을 허용합니다.
- [FACT] 사용자는 한 정규 발송 기사 세트 전체를 확인한 뒤 batch 대표 메시지에 ✅ reaction으로 검토 완료를 표시합니다.
- [FACT] ✅ reaction이 제거되면 해당 batch의 검토 완료도 취소합니다.
- [FACT] GeekNews topic link 클릭은 Discord에서 확인 가능한 interaction이 아니며 검토 완료로 간주하지 않습니다.
- [FACT] 검토 완료 batch에서 세 부정 reaction이 없는 기사는 암묵적 수용으로 기록합니다.
- [FACT] 검토 완료되지 않은 batch의 기사는 암묵적 수용률 분모에서 제외합니다.
- [FACT] 누락 중요 기사 후보는 정확한 command 이름을 고정하지 않은 구조화된 Discord slash command로 GeekNews topic link를 제출합니다.
- [FACT] 시스템은 제출된 GeekNews topic link를 Raw RSS `link` 원값 기준으로 기사 테이블에서 조회합니다. 기사가 있으면 실제 수집·분석·선정·전달 이력에 따라 이미 전달됨, 최대 제한 미선정, 홍보성 의심 제외, 최신성 범위 밖, 입력·AI 처리 미완료 또는 확인 가능한 다른 처리 결과를 회신합니다.
- [FACT] 기사 테이블에 해당 `link`가 없으면 추가 RSS 재수집 또는 과거 Raw RSS 관찰 재검증 없이 `수집 기록상 누락`으로 기록하고 누락 기록에 추가합니다. `수집 기록상 누락`은 시스템의 기사·수집 기록에 해당 link가 없다는 뜻이며 실제 RSS 원천의 누락을 확정하지 않습니다.
- [FACT] 예정 batch의 RSS 수집·parsing 실패는 해당 batch의 pipeline 실패로 별도 표시하며, 정상 신규 0건 또는 개별 누락 요청의 수집 기록상 누락으로 바꾸지 않습니다.
- [FACT] 실제 이력상 제외·미선정 사유를 회신할 때만, 해당 원래 요청과 `link` 기사에 직접 연결된 `추천해야 했다` feedback reaction 입력을 함께 제공합니다. 누락 link 제출 자체를 추천해야 했다 reaction·중요 기사·실제 누락 확정으로 취급하거나 별도의 이유 확인·이해 feedback을 수집하지 않습니다.
- [FACT] 제외·미선정 사유 회신에 연결된 추천해야 했다 reaction이 있는 수집된 후보만 후보 기반 중요 기사 recall의 누락 사례로 계산합니다. 수집 기록상 누락은 후보 recall 분모에서 제외하고 별도 집계합니다.
- [FACT] 이미 성공 전달된 기사는 누락으로 계산하지 않으며 원인 미확정 사례는 확정 전까지 recall 계산에서 보류합니다.
- [FACT] 홍보성 제외 False Positive는 제외 후보 표본 검토로 확인합니다.
- [UNKNOWN] 기사·batch·reaction의 정확한 Discord 표시와 mapping, slash command 이름·parameter와 응답 UI는 Interface Design에서 결정합니다.

## Product Metrics

### Volume and Funnel Metrics

- [FACT] Raw RSS 응답과 parsing된 RSS 관찰 entry 수
- [FACT] 기존·중복 관찰과 후보 생성 불가능 입력 오류 수
- [FACT] batch별·Asia/Seoul 일자별 신규 후보 수
- [FACT] 정상 분석 후보 수
- [FACT] 저정보 후보와 선정 수
- [FACT] 미처리 후보 수
- [FACT] 게시 시각 기준 최신 전달 범위 밖 사유로 AI 분석·현재 기사 선정에서 제외된 후보 수
- [FACT] 선정 기사 수
- [FACT] 홍보성 의심 제외 수
- [FACT] Discord 발송·미발송·실패 수
- [FACT] 검토 완료·미검토 batch 수
- [FACT] 별로였음, 불필요함, 홍보성 의심 reaction 수와 대상 기사 수
- [FACT] 누락 기사 제출, 추천해야 했다 reaction과 수집 기록상 누락 수

[FACT] 모든 측정값은 정상 0건, 측정 불가, 해당 없음과 원인 미확정을 구분하고 실패·기록 부족을 0건으로 기록하지 않습니다.

[FACT] 외부 호출·retry·reaction 변경과 복구 event 수는 논리적 기사·처리 결과·성공 전달·현재 feedback 수와 구분하며, 지연 결과의 원래 batch 수량과 현재 batch 수량을 합쳐 다시 계산하지 않습니다.

[UNKNOWN] 월별 category·집계, 자동 Retention과 삭제는 MVP-A 측정값 산출 방식으로 확정하지 않고 MVP-B 범위와 MVP-A 검토 후 데이터 정책에서 결정합니다.

### Quality Metrics

| 지표 | 제품 정의 | MVP-A 목표 |
|---|---|---:|
| 중요 기사 recall | [FACT] 사용자가 중요하다고 사후 판정한 후보 중 실제 전달된 비율 | [FACT] 90% 이상 |
| 암묵적 수용률 | [FACT] 검토 완료 batch의 전달 기사 중 세 부정 reaction이 하나도 없는 기사 비율 | [FACT] 70% 이상 |
| RSS 근거 충실도 | [FACT] 검토한 요약 중 모든 핵심 주장이 RSS 근거로 확인되는 비율 | [FACT] 95% 이상 |
| 중대한 근거 없는 사실 | [FACT] 사용자 판단을 크게 바꿀 수 있는 RSS 밖 사실의 수 | [FACT] 0건 |
| 홍보성 False Positive | [FACT] 검토한 홍보성 제외 후보 중 실제 유용한 비홍보 기사 비율 | [FACT] 5% 이하 |
| 홍보성 False Negative | [FACT] 검토한 전달 기사 중 홍보성으로 제외했어야 하는 기사 비율 | [FACT] 10% 이하 |

[FACT] 같은 기사에 부정 reaction이 여러 개 있어도 암묵적 수용률에서는 부정 기사 한 건으로 계산하고 원인별 지표에서는 각각 계산합니다.

[FACT] 검토 완료되지 않은 batch의 기사는 암묵적 수용률 분모에서 제외합니다.

[FACT] 암묵적 수용은 별다른 부정 feedback이 없다는 뜻이며 명시적 유용함 또는 원문 열람을 의미하지 않습니다.

[FACT] 처리되지 않았다고 표시된 중요 후보는 실패 가시성에는 기여하지만 중요 기사 recall의 전달 성공으로 계산하지 않습니다.

[FACT] 수집된 후보에 대한 추천해야 했다는 사용자 사후 중요 판정으로서 중요 기사 recall 분모에 포함하고 전달되지 않았다면 누락으로 계산합니다.

[FACT] 수집 기록상 누락은 제출 link가 기사 테이블에 없는 경우에 추가 RSS 재수집 또는 과거 Raw RSS 관찰 재검증 없이 별도 집계하며 후보 기반 중요 기사 recall 분모에서는 제외합니다. Raw RSS 수집·parsing 실패는 해당 batch의 pipeline 실패로 기록합니다.

### Reliability, Latency and Cost Metrics

- [FACT] 정상 발송, 입력 제약 결과, AI 미완료 처리 실패, 지연 full result, 정상 0건과 Discord 전달 실패의 batch별 수
- [FACT] 반복 수집·재실행 또는 자동 복구에 따른 동일 기사 의도되지 않은 중복 발송 수와, 승인된 사용자 미수신 확인 기반 즉시 재전송 수의 별도 집계
- [FACT] 장애 이후 지연 기사 복구 수와 미복구 수
- [FACT] Discord 수락 불명확, 사용자 수신 확인, 사용자 미수신 확인, 확인 요청 무응답, 사용자 확인 또는 추가 복구 선택에 따른 즉시 재전송 수
- [FACT] 현재 기사별 예정 Discord 전달 시각과 RSS `published`의 차이 및 13시간 최신성 기준 위반 수
- [FACT] batch 시작부터 발송 가능 결과 준비까지의 시간과 batch 시작부터 Discord 수락까지의 pipeline 지연
- [FACT] 원래 예정 Discord 전달 시각부터 실제 복구 수락까지의 복구 지연
- [FACT] AI 요청·사용량과 무료 한도 거절 수
- [FACT] 실제 추가 월 운영비
- [UNKNOWN] 링크 click은 별도 추적 방식이 없으므로 MVP-A 필수 합격 지표가 아닙니다.

## MVP-A Validation and Quality Gate

### Minimum Evaluation Sample

- [FACT] 초기 검증 기간은 최소 2주, 최대 4주입니다.
- [FACT] 최소 20개 예정 batch 실행을 검토합니다.
- [FACT] 최소 50개 후보를 평가합니다.
- [FACT] 4주에도 최소 표본이 부족하면 `통과` 또는 `실패`가 아니라 `판정 불충분`으로 기록합니다.

### Hard Gates

[FACT] 다음 위반은 각각 0건이어야 합니다.

- [FACT] 추가 월 비용·유료 호출·유료 자원 사용
- [FACT] 미처리 후보의 조용한 제외
- [FACT] 반복 수집·재실행 또는 자동 복구로 인한 동일 기사의 의도되지 않은 중복 발송. 단, 수락 불명확 상태에서 원래 전달에 정확히 연결된 승인된 수신자의 `못 받음` 응답에 따라 한 번 실행한 즉시 재전송은 별도 사용자 요청 기반 복구로 기록하며 이 Hard Gate 위반으로 계산하지 않습니다.
- [FACT] AI 실패를 신규 기사 0건으로 기록
- [FACT] Discord가 수락하지 않은 메시지를 발송 성공으로 기록
- [FACT] 중대한 RSS 근거 밖 사실 생성

### Service Goal Thresholds

- [FACT] 현재 기사로 선정되는 모든 기사는 예정 Discord 전달 시각 기준 RSS `published`가 13시간 이내여야 하며 정확히 13시간인 기사는 포함합니다.
- [FACT] 09:30·21:30 예정 batch 시작부터 발송 가능한 결과 준비까지 30분 이내 목표의 충족률은 95% 이상입니다.
- [FACT] 메시지가 필요한 예정 batch 중 Discord 수락이 10:00:00 이상 10:01:00 미만 또는 22:00:00 이상 22:01:00 미만에 확인되는 비율은 95% 이상입니다.
- [FACT] 초기 처리 기준 `100건/일`은 Asia/Seoul 일자별 고유 신규 후보 수이며 실제 AI 요청 수와 구분합니다. 100건 초과 또는 무료 한도 때문에 처리하지 못한 후보도 기록 없이 버리거나 숨기지 않습니다.
- [FACT] 추가 월 운영비는 0원을 초과하면 안 됩니다.

### MVP-A Result Interpretation

- [FACT] Hard Gate 위반이 없고 최소 표본과 승인된 품질·서비스 목표를 충족하면 MVP-A 품질 검증 통과 후보가 됩니다.
- [FACT] 품질 지표 하나가 미달했다고 전체 프로젝트를 즉시 종료하지 않고 원인과 개선 가능성을 기록한 뒤 추가 검증합니다.
- [FACT] 표본이 부족하면 실패가 아니라 `판정 불충분`입니다.
- [FACT] MVP-A 검증 통과가 MVP-B 자동 시작을 의미하지 않으며 측정 결과 검토와 사용자 승인이 별도로 필요합니다.

## Acceptance Criteria

### Candidate and Input

- [FACT] **AC-01**: GeekNews RSS의 News, Ask와 Show는 모두 일반 후보 자격을 유지합니다.
- [FACT] **AC-02**: source type, title prefix 또는 단순 keyword만으로 후보를 조기 제외하지 않습니다.
- [FACT] **AC-03**: 외부 원문 또는 GeekNews 상세 페이지 본문을 수집·분석 근거로 사용하지 않습니다.
- [FACT] **AC-04**: 반복 수집과 재실행이 동일 기사의 중복 Discord 전달을 만들지 않습니다.

### Analysis and Selection

- [FACT] **AC-05**: 정상 분석 결과는 RSS 근거 범위의 한국어 제목, 2~3문장 요약, keyword, 중요도·관심 주제·홍보성 판단과 최소 근거를 제공합니다.
- [FACT] **AC-06**: 관심 주제 밖이어도 전체 IT 영향도가 높은 기사는 전달 대상이 될 수 있습니다.
- [FACT] **AC-07**: 관심 주제 밖이라는 이유만으로 후보를 제외하지 않습니다.
- [FACT] **AC-08**: 홍보성이 애매한 기사를 자동 제외하지 않으며 False Positive를 더 엄격하게 관리합니다.
- [FACT] **AC-09**: 현재 정상 주요 목록은 예정 Discord 전달 시각 기준 RSS `published`가 13시간 이내인 정상·저정보 후보 중 중요도순 최대 10개이며 정확히 13시간인 후보는 포함하고 초과 후보는 선정하지 않습니다.

### User-visible Output

- [FACT] **AC-10**: 정상 기사에는 한국어 제목, 2~3문장 요약, keyword와 GeekNews topic link가 있습니다.
- [FACT] **AC-11**: 저정보 선정 기사에는 `정보 제한`, 근거가 허용하는 1문장 이하 설명과 GeekNews topic link가 있습니다.
- [FACT] **AC-12**: 홍보성 의심 제외 건수가 표시됩니다.
- [FACT] **AC-13**: 신규 후보 0건이고 실패·backlog가 없으면 Discord 메시지를 보내지 않습니다.

### Failure Visibility

- [FACT] **AC-14**: AI 실패 또는 무료 한도 소진을 신규 0건으로 표시하지 않습니다.
- [FACT] **AC-15**: 후보 생성 불가능 입력 오류가 있는 목록은 전체 RSS 관찰 범위의 완전한 Top 10으로 표현하지 않고 신규 후보·정상 처리·입력 오류 수를 표시합니다. 유효 후보 AI 분석이 미완료이면 기사 목록을 발송하지 않습니다.
- [FACT] **AC-16**: 전체 AI 실패 시 Discord가 사용 가능하면 실패 사실, 미처리 수와 유료 전환이 없었다는 사실을 표시합니다.
- [FACT] **AC-17**: Discord 전달 실패는 성공으로 처리하지 않습니다.
- [FACT] **AC-18**: 다음 성공 정규 발송은 과거 논리적 발송 결과를 재사용한 지연 기사와 현재 신규 기사를 분리하고, 각 구간에 해당 원래 batch의 상태와 수량 요약을 표시합니다. 단, 승인된 수신자가 해당 원래 batch의 미수신을 확인하거나 자동 복구 backlog의 추가 복구를 선택한 경우에는 저장된 원래 결과를 즉시 재전송할 수 있습니다.
- [FACT] **AC-19**: Discord 복구 발송은 지연 기사 최대 10개와 현재 기사 최대 10개, 총 최대 20개를 허용합니다.

### Feedback and Validation

- [FACT] **AC-20**: 기사별 세 부정 reaction과 batch별 검토 완료를 구분하고, 검토 완료 batch의 무부정 기사를 암묵적 수용으로 계산하며 미검토 batch를 분모에서 제외할 수 있습니다.
- [FACT] **AC-21**: 구조화된 Discord slash command로 누락 기사 GeekNews topic link를 제출하고, 기사 테이블의 실제 처리 기록에 따른 결과 또는 수집 기록상 누락을 원래 요청에 연결해 회신할 수 있습니다. 제외·미선정 사유 회신에는 추천해야 했다 reaction을 연결할 수 있습니다. 제출 자체는 중요 기사·실제 누락·추천 오류로 확정하지 않으며, 별도의 이유 확인·이해 feedback은 수집하지 않습니다.
- [FACT] **AC-22**: 홍보성 제외 후보 표본을 검토해 False Positive를 측정할 수 있습니다.
- [FACT] **AC-23**: 최소 2주·20개 batch·50개 후보 평가 전에는 MVP-A 품질 통과를 확정하지 않습니다.
- [FACT] **AC-24**: Hard Gate와 승인된 품질·서비스 지표의 실제 결과를 구분해 보고할 수 있습니다.

## Remaining Unknowns and Dependencies

### Required after Free AI Candidate Validation

- [UNKNOWN] AI 제공자와 SDK
- [UNKNOWN] 실제 한국어 요약, 중요도와 홍보성 판단 품질
- [UNKNOWN] 무료 할당량, rate limit, 데이터 이용 조건과 유료 전환 차단 방법
- [UNKNOWN] 원인별 재시도·backoff, 전체 선정 불가능의 제공자별 판정과 지연 full result의 실제 latency

### Required for Technical Requirements and Design

- [UNKNOWN] 데이터베이스 schema, table과 column
- [FACT] Architecture AD-01·AD-03·AD-06·AD-08에 따라 하나의 Python image를 K3s의 Prepare·Delivery-gate·Recovery CronJob과 Gateway listener Deployment 역할로 나누고, 별도 queue 없이 PostgreSQL durable work ledger를 사용합니다. 정확한 command·state·lease 구현은 [UNKNOWN]입니다.
- [UNKNOWN] RSS polling 주기, CronJob expression·기동 지연과 role별 내부 interface
- [UNKNOWN] 정확한 재시도 횟수와 backoff
- [UNKNOWN] 점수 계산 알고리즘과 임계값
- [FACT] MVP-A 기사 identity는 Raw RSS `link` 원값의 정확한 일치이며 URL 정규화는 별도 승인 전 적용하지 않습니다.
- [UNKNOWN] GeekNews link 장기 안정성·재사용, link 유효성 검증·고유성 constraint 구현과 향후 identity 정책 변경 절차
- [UNKNOWN] 신규 구간, 수집 중첩 범위, 입력 제약·AI 미완료·처리 지연 full result·Discord 복구의 정확한 상태 전이
- [UNKNOWN] 판단 근거, model·prompt와 결과 version의 정확한 저장 구조
- [UNKNOWN] MVP-A 최소 추적 정보의 검토 완료 이후 임시 보존·삭제 제품 정책
- [UNKNOWN] 기술적인 Retention 구현
- [FACT] Architecture AD-06·AD-09·AD-13~AD-16에 따라 MVP-A 실행 환경은 K3s, PostgreSQL은 StatefulSet·PersistentVolume, secret은 encryption at rest와 역할별 최소 권한, image는 검증된 digest를 사용합니다. StorageClass·registry·manifest·backup 도구와 비용 근거는 [UNKNOWN]입니다.
- [UNKNOWN] `published` 누락·오류·미래 시각과 최신 전달 범위 밖 후보의 정확한 상태 label·사용자 표시 방식
- [UNKNOWN] Discord 장애가 두 번 이상의 발송 시각 동안 지속될 때 backlog 상한과 분할 정책
- [UNKNOWN] 기사·batch·reaction의 정확한 Discord 표시와 mapping
- [UNKNOWN] slash command의 정확한 이름·parameter·표시 언어와 누락 이유 응답 UI
- [FACT] Architecture AD-05·AD-11·AD-12·AD-21에 따라 Discord feedback은 Gateway-first event 수신과 조건부 REST 현재 상태 대조를 함께 사용합니다. 정확한 Gateway·REST·interaction contract, 권한·rate limit과 월 0원 실행 가능성은 [UNKNOWN]입니다.

## Stage Boundary

- [FACT] 이 문서는 제품 기대, 사용자 시나리오, 정책, 결과 형식, 품질 지표와 acceptance criteria를 정의합니다.
- [FACT] 이 문서는 AI 제공자, SDK, 데이터 schema, 상태 전이 구현, polling, component 구조, 재시도, 인프라 또는 배포 방식을 확정하지 않습니다.
- [FACT] 코드, 데이터베이스 schema, 테스트와 배포 구성은 작성하지 않습니다.
- [FACT] 사용자 최종 승인과 관련 문서 동기화를 완료한 후 Product Specification 단계 종료 Git 검토를 진행합니다.
- [FACT] Git commit과 push는 별도 사용자 승인 전에는 실행하지 않습니다.

## Product Specification Exit Criteria

- [FACT] 승인된 Problem, Research / JTBD, Solution Discovery와 Feature Prioritization 결정이 추적 가능합니다.
- [FACT] MVP-A 사용자 가치 흐름과 정상·0건·부분 실패·전체 실패·Discord 장애 시나리오가 정의됐습니다.
- [FACT] 중요도·관심 주제, 홍보성, 저정보 entry, Discord 복구와 feedback 정책이 반영됐습니다.
- [FACT] Acceptance Criteria, 품질 지표, Hard Gate와 최소 검증 표본이 정의됐습니다.
- [FACT] MVP-B와 명시적 비목표가 MVP-A 완료 조건과 분리됐습니다.
- [FACT] 기술 설계로 넘길 사항이 `[UNKNOWN]`으로 유지됐습니다.
- [FACT] 사용자가 2026-08-26에 Product Specification 문서를 최종 승인했습니다.
