# MVP-A Logical Data Model

## Document Status

[FACT] Workflow 단계: 8. Data / Interface Design

[FACT] 상태: Approved logical design — DDI-01~DDI-10, MIN-01~MIN-08 및 세부 정합성 검토를 반영해 2026-09-04 Asia/Seoul에 문서 전체 최종 승인; Workflow 8 단계 종료 Git Review 대기

[FACT] 작성일: 2026-09-02 Asia/Seoul

[FACT] 이 문서는 승인된 [Product Specification](../01-product/product-spec.md), [Technical Requirements](requirements.md), [Architecture](architecture.md)의 MVP-A 경계를 구현 가능한 논리 데이터 설계로 구체화합니다.

[FACT] Architecture 완료 commit `c993ed9`는 local `main`과 `origin/main`에 반영되어 있습니다.

[FACT] 이 문서는 DB migration, ORM, 실제 SQL, index DDL, AI provider/model/prompt, retry/backoff 값, backup 도구, RPO/RTO, 자동 Retention lifecycle을 확정하지 않습니다.

[FACT] 본문의 `[FACT]`는 Repository·승인된 상위 문서 또는 사용자가 항목별로 확정한 결정이고, `[INFERENCE]`는 사실에서 도출한 설계 이유·추천이며 태그 자체가 승인 대기를 뜻하지 않습니다. `[UNKNOWN]`은 후속 물리 설계나 환경 검증이 필요한 항목입니다. 개별 결정의 승인 상태는 `Decision Review Register`를 정본으로 확인합니다.

## Purpose and Design Boundary

[INFERENCE] 이 설계의 목적은 Raw RSS 관찰부터 후보·AI 판단·선정·Discord 전달·feedback·복구·품질 측정까지를 원래 근거와 시각으로 추적하면서, 미처리 후보의 조용한 제외·의도되지 않은 중복 전달·AI 실패의 신규 0건 오표시·Discord 미수락의 성공 오표시를 방지하는 것입니다.

[FACT] MVP-A 논리 기사 identity는 Raw RSS `link` 원값의 정확한 일치입니다. URL 정규화, Atom `id`, title, content는 identity 판정 기준으로 사용하지 않습니다.

[FACT] MVP-A는 GeekNews RSS 하나만 수집하고 GeekNews 상세 페이지나 외부 원문을 수집하지 않습니다.

[FACT] PostgreSQL은 예정 batch, 실행 attempt의 외부 호출 전 `prepared` 상태, 수락 근거, feedback 및 복구의 단일 제어 기준입니다.

## Design Principles

1. [FACT] Raw input, 처리 결과, 선택 결과, 전달 결과와 feedback은 하나의 전역 상태로 덮어쓰지 않습니다.
2. [FACT] 모든 파싱된 RSS observation은 신규 후보, 기존·중복 관찰 또는 후보 생성 불가능 입력 오류 중 하나의 대표 결과를 가집니다.
3. [FACT] 외부 호출은 도메인 attempt를 `prepared` 상태로 DB에 commit할 수 있을 때만 시작하며, 외부 응답은 별도 typed evidence로 기록합니다.
4. [FACT] 외부 효과 불명확 상태는 자동 재호출·재발송의 근거가 아닙니다.
5. [FACT] 처리 지연 full result와 Discord 미수락 recovery backlog는 별도 논리 구간입니다.
6. [FACT] MVP-A는 월별 Insight, 자동 Retention, partition 및 VACUUM 정책을 구현하지 않습니다.
7. [FACT] 논리적 책임의 분리는 각각의 물리 테이블 생성을 뜻하지 않습니다. 같은 aggregate의 상태·event·결과 subtype은 고유 제약과 이력을 유지할 수 있는 범위에서 하나의 typed record 계열로 저장할 수 있습니다.
8. [FACT] canonical business value는 책임 엔터티에 한 번만 저장하고, 후속 단계는 immutable 식별자와 version을 참조합니다. 외부로 실제 전송한 값의 재현에 필요한 경우에도 원문 복사 대신 source reference, output/configuration version 및 payload hash를 우선 보존합니다.

## Logical Entity Model

| Domain | Logical entity | Responsibility |
| --- | --- | --- |
| Scheduling | `scheduled_batch` | Asia/Seoul 일자와 오전·오후 slot으로 결정되는 하나의 예정 identity 및 09:30·21:30 예정 시작·10:00·22:00 예정 전달 시각을 한 번 소유하는 예정 논리 단위입니다. 실제 실행 여부·시작·결과 준비·Discord 수락과 구분합니다. |
| Work coordination | `work_item`, `work_attempt` | Prepare, candidate analysis, delivery release, recovery, reconciliation, evaluation 작업의 key와 현재 실행 여부·현재 claim/lease 및 실제 attempt 이력을 보존합니다. 실제 Prepare를 시작한 batch는 이 work scope에 processing `configuration_snapshot` reference를 한 번 고정합니다. delivery release work는 전달 생성 계기와 idempotency 경계이며 하나의 `delivery_set`이 이를 참조합니다. `batch_execution`은 예정 batch에 연결된 prepare work를 읽는 논리 projection이며 별도 canonical record가 아닙니다. |
| RSS evidence | `rss_fetch`, `raw_rss_snapshot` | fetch 목적·endpoint·요청 시각·도메인 결과와 변형 전 Raw RSS 응답을 보존합니다. HTTP response 근거는 공통 external attempt evidence를 참조합니다. |
| RSS parsing | `rss_observation` | snapshot 내 entry의 parsing 결과, entry 원값, 입력 검증, 관찰 시각을 보존합니다. |
| Identity | `article` | Raw RSS `link` 원값 하나에 대응하는 논리 기사입니다. exact identity와 최초 observation reference만 소유하며, observation과 모든 후속 처리의 공통 연결점입니다. |
| Candidate processing | `batch_candidate` | 특정 예정 batch의 신규 처리 구간에 처음 포함된 article과 신규성·최신성·분석 필요 여부를 연결합니다. 입력 오류와 기존·중복 observation은 이 엔터티를 만들지 않습니다. |
| External safety | `configuration_snapshot`, `external_contract_check`, `cost_safety_evidence` | 설정 설명 snapshot, 외부 계약 검증, AI부터 runtime·storage·backup·registry까지의 비용·plan·quota 확인 근거 및 호출 허용/차단 상태를 중복 없이 versioned record로 보존합니다. 실제 활성화 결정은 운영 event가 소유합니다. |
| External attempt evidence | `external_attempt_evidence` | RSS·AI·Discord 도메인 attempt가 받은 append-only `response`·`usage`·`limit` 근거를 typed evidence로 공통 보존합니다. 도메인 attempt와 업무 결과를 대체하지 않습니다. |
| AI processing | `ai_analysis_attempt`, `article_analysis`, `article_analysis_keyword` | `prepared` 상태부터 시작하는 호출 attempt, 외부 응답·오류, 구조 검증 및 원문 article의 구조화된 분석 결과와 analysis별 keyword 집합 lineage를 분리 보존합니다. 각 실제 attempt는 source Prepare의 고정 processing snapshot을 직접 참조하며 별도 AI intent 엔터티를 만들지 않습니다. |
| Selection | `selection_result`, `candidate_selection`, `batch_item` | 고정된 논리 결과, 후보별 선정·제외·미선정 결정, 선정된 Discord 기사 항목, 순위·정책 version·수량을 분리 보존합니다. `selection_result`가 적용한 processing snapshot의 판단·출력 contract를 소유하고 candidate selection·batch item은 이를 상속합니다. |
| Delivery | `delivery_set`, `delivery_segment`, `delivery_attempt` | `delivery_set`은 source delivery release work에 연결된 한 번의 Discord 전달 묶음이고, segment는 정시 현재 결과·처리 지연 full result·recovery backlog·failure notice의 콘텐츠 범위를, attempt는 set 안의 실제 Discord invocation을 분리 보존합니다. |
| Discord evidence | `discord_message_mapping`, `discord_message_item`, `acceptance_evidence` | system message, article, batch 대표 message, Discord message 식별자, article-bearing physical message의 실제 `batch_item` 범위 및 수락 근거를 연결합니다. |
| Feedback | `discord_gateway_event`, `reconciliation_request`, `rest_state_snapshot`, `feedback_state` | Gateway 원본 event, REST 현재 상태 관측 및 article·batch review·`추천해야 했다`의 typed 현재 feedback projection을 보존합니다. |
| Interaction | `interaction_request`, `missing_article_case` | idempotent 사용자 interaction과 exact link 누락 기사 조회 결과를 보존합니다. receipt와 recovery 진행은 recovery aggregate에 연결합니다. |
| Recovery | `recovery_case`, `recovery_event` | 원래 전달을 기준으로 한 수신 확인·1회 즉시 재전송·offer·사용자 선택·추가 복구의 현재 aggregate와 append-only event 이력을 보존합니다. 실제 Discord 전송은 delivery 계층이 담당합니다. |
| Measurement, operations, and durability | `evaluation_snapshot`, `evaluation_result`, `backup_run`, `restore_validation`, `operational_event` | 원본 사실에서 읽기 전용으로 계산한 표본·Hard Gate·품질·서비스·최종 해석의 typed 결과와 versioned snapshot, backup 실행·restore 검증 증거 및 outbound gate 운영 사건을 보존합니다. 평가 실행 이력은 work coordination이 소유합니다. |

## Primary Relationships

```text
scheduled_batch
  -> work_item(type=prepare) -> work_attempt
                              -> configuration_snapshot (batch processing binding)
  -> rss_fetch -> external_attempt_evidence
               -> raw_rss_snapshot -> rss_observation -> article
  -> batch_candidate -> article
                     -> ai_analysis_attempt -> external_attempt_evidence
                                            -> article_analysis -> article_analysis_keyword
  -> selection_result -> configuration_snapshot (applied selection policy/output contract)
                      -> candidate_selection -> batch_item

configuration_snapshot -> external_contract_check
ai_analysis_attempt -> configuration_snapshot
cost_safety_evidence -> configuration_snapshot / affected batch or work
backup_run -> restore_validation
           -> operational_event
restore_validation -> operational_event

work_item(type=delivery release) -> delivery_set
delivery_set -> delivery_segment -> source selection_result / delivered batch_item subset
             -> delivery_attempt -> external_attempt_evidence
                                 -> discord_message_mapping -> acceptance_evidence
discord_message_mapping(role=article) -> delivery_segment / discord_message_item
discord_message_mapping(role=batch representative) -> delivery_set

article_analysis -> candidate_selection

discord_gateway_event / rest_state_snapshot
  -> feedback_state / interaction_request
  -> recovery_case -> recovery_event -> delivery_set

work_item(type=evaluation) -> work_attempt -> evaluation_snapshot -> evaluation_result
```

[INFERENCE] `article`은 identity 축, `batch_candidate`는 해당 예정 batch에서의 처리 축, `selection_result`는 고정·재사용 가능한 결과 축, `delivery_attempt`는 Discord 외부 효과 축입니다. 이 축을 분리하면 Discord 실패가 selection을 변경하거나 retry가 RSS observation을 소거하는 것을 막을 수 있습니다.

### Canonical ownership and reference-only rule

[FACT] `article`은 Raw RSS `link` 원값의 exact identity와 최초 `rss_observation` reference만 소유합니다. RSS title·content·published 등 entry 표시 원값은 `rss_observation`이 보존합니다. 같은 exact link 원값을 raw observation 입력과 canonical identity key에 함께 쓰는 것은 identity uniqueness를 위한 의도된 최소 중복입니다.

[FACT] `article_analysis`는 AI가 만든 구조화된 표시 제목·요약·분류·점수·판단 근거와 그 analysis별 keyword 집합을 한 번만 소유합니다. keyword 값은 0개 이상의 `article_analysis_keyword` 자식 record로 보존하며, `batch_candidate`, `candidate_selection`, `batch_item`, `delivery_segment`는 이 값을 복사하지 않고 해당 immutable record를 참조합니다.

[FACT] `batch_item`은 선정 항목의 고정 순서, source `candidate_selection`, source `article_analysis`를 연결합니다. batch의 판단·출력 contract version은 source `selection_result`가 한 번 소유하므로 item마다 반복 보존하지 않습니다. 기사 제목·link·AI 요약의 또 다른 canonical 사본이 아닙니다.

[FACT] `discord_message_mapping`은 Discord message 식별자, delivery segment 또는 system message 연결, 물리 순서, 실제 delivery output/configuration version 및 안전한 payload hash를 보존합니다. 이 physical delivery version은 source selection result의 snapshot과 다를 수 있으나, 승인된 Discord 표시·분할·payload 보정 범위에서만 가능하며 선정·기사 의미·원래 수량 summary를 변경하지 않습니다. article-bearing mapping이 실제 표시한 `batch_item` 범위는 `discord_message_item` association으로 읽습니다. 이 association은 mapping과 batch item의 reference만 보존하며 제목·요약·link·AI 결과를 복제하지 않습니다. batch 대표 message는 delivery set의 실제 article scope를 한 번만 참조하므로 article별 `discord_message_item`을 만들지 않습니다. Discord에 실제 보낸 제목·요약·기사 본문은 별도 canonical article 또는 analysis로 복제하지 않고, source record와 전송 contract로 재현합니다.

[FACT] `operational_event`, `recovery_event`, `evaluation_result`는 관련 원본 record의 전체 payload를 복사하지 않고 source 식별자와 해당 event·결과에 고유한 사실만 보존합니다.

## Input and Identity Design

### DDI-01 — Raw RSS input lineage and article identity

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-01을 승인했습니다. 승인 범위는 Raw RSS snapshot, 모든 RSS observation, 최소 입력·identity 검증 및 article 생성·기존 연결이며, batch·AI·최신성·선정·전달은 포함하지 않습니다.

[FACT] `raw_rss_snapshot`은 변형하지 않고 보존하며, `rss_observation`은 그 snapshot에서 parsing한 entry의 사실을 append-only로 남깁니다.

[FACT] 후보 생성에 필요한 최소 입력 검증과 Raw RSS `link` 원값 identity 검증을 통과한 observation은 해당 원값의 `article`을 찾거나 생성합니다.

[FACT] News·Ask·Show 또는 source type 미상의 parsing 가능한 observation은 모두 같은 후보 자격을 유지합니다. source type 또는 그 추정값, title prefix, 관심 keyword의 존재·부재는 후보 생성 가능 입력 검증이나 후보 자격 제거 기준이 아닙니다. source type의 별도 추론·저장·표시 기능은 MVP-A에서 확정하지 않습니다.

[FACT] 같은 `link`의 `article`이 없으면 하나를 생성하고 observation을 연결합니다. 이미 존재하면 기존 `article`에 observation만 연결하며 새 논리 기사를 만들지 않습니다.

[FACT] `link`가 누락·빈값·검증 불가이면 Atom `id`, title 또는 다른 값으로 대체 identity를 만들지 않고 `input_invalid` observation으로 보존합니다.

[FACT] 동일 link의 반복 수집은 새 논리 기사를 만들지 않아야 합니다.

[FACT] 반복 수집된 Raw RSS observation은 재현성을 위해 소거하지 않아야 합니다.

[FACT] `article`은 원문 기사의 identity 연결점이며 exact `link` 원값과 최초 observation reference만 둡니다. RSS title·content·published 같은 표시 원값, AI 분석 결과, batch 후보, 최신성·선정·Discord 전달 상태는 직접 포함하지 않습니다.

[INFERENCE] 최신 RSS 값만 유지하는 모델은 title/content 수정, parsing 오류, 후보 수량 및 RSS 근거 충실도를 재현할 수 없으므로 채택하지 않습니다.

[UNKNOWN] Raw snapshot의 저장 형식·압축·물리 보관 기간·삭제 절차는 MVP-A 자동 Retention 범위가 아니며 후속 환경 검증과 MVP-B 데이터 lifecycle 결정으로 남깁니다.

## Batch Candidate, Analysis, and Selection Design

### DDI-02 — Batch candidate, article analysis, and selection

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-02의 추천 구조를 승인했습니다. 예정 batch가 먼저 존재하고, 신규 처리 구간의 article을 `batch_candidate`로 연결한 뒤 AI 분석·선정 결과를 분리하는 구조입니다.

[FACT] `batch_candidate`는 article이 단순히 이번 RSS 수집에서 생성됐다는 사실만으로 만들지 않습니다. MVP-A의 하나의 article은 신규 후보로 한 번만 편입할 수 있으며, 최초 편입에 성공한 `batch_candidate`가 source `scheduled_batch`와 admission `rss_observation`을 고정합니다. 이 후보 편입 이력 자체가 신규 처리 구간의 durable 경계이므로, 별도 시간 창 또는 mutable `last_completed_batch` marker를 만들지 않습니다.

[FACT] 유효 observation의 article identity 연결과 최초 candidate admission은 하나의 DB transaction으로 처리합니다. 동시·중첩 수집에서 같은 article의 admission 경쟁이 발생하면 하나만 후보로 편입하고, 나머지 observation은 기존 article 재관찰로 보존합니다. 정확한 uniqueness constraint·lock·isolation 구현은 [UNKNOWN]입니다.

[FACT] 신규 처리 구간에 처음 포함된 유효 article은 News·Ask·Show·type 미상 여부, title prefix 또는 관심 keyword만으로 `batch_candidate` 생성을 건너뛰지 않습니다. 최신성·시간 검증 또는 이후 AI·selection 판단은 후보 생성 뒤의 별도 처리 결과이며, 후보 자격의 조기 제외가 아닙니다.

[FACT] 기존 article의 재관찰, 이미 편입된 후보의 처리 대기·terminal 최신성 결과·정상 미선정, 확인된 Discord 미수락 recovery 대상은 새 예정 batch의 신규 `batch_candidate`로 다시 만들지 않습니다. AI 지연·처리 지연 full result·Discord 전달·수락·복구는 최초 candidate의 source batch를 바꾸거나 다음 batch에 재편입시키지 않습니다.

[FACT] 입력 오류 observation은 article을 만들지 않으므로 `batch_candidate`도 만들지 않습니다. 이후 다른 RSS observation이 유효하게 같은 `link`를 처음 identity 연결하면, 그 관찰이 속한 실제 실행 batch에서 최초 candidate admission이 가능합니다. feed 전체 실패 또는 미실행 slot은 article·candidate admission을 만들지 않으며, 이후 실제 수집에서 처음 관찰한 batch의 후보 경계를 소급 변경하지 않습니다. RSS fetch와 observation의 batch 연결을 통해 오류·미실행을 별도 집계합니다.

[FACT] `article_analysis`는 `article`, 실제 AI 입력에 사용한 `rss_observation`, 이를 처리한 `batch_candidate` 및 정확한 source `ai_analysis_attempt`를 연결합니다. 이 record는 검증을 통과한 정상 분석 또는 저정보 결과만 소유합니다. 구조 검증 실패·quota·rate limit·인증·설정·timeout·provider 오류·비용 차단·결과 불명확은 `ai_analysis_attempt`와 `external_attempt_evidence`, `batch_candidate` 처리 결과에서 서로 구분하며 실패마다 analysis row를 만들지 않습니다.

[FACT] `article_analysis`는 원문 article을 덮어쓰지 않으며, 실제 입력·근거·정책·출력 contract version을 보존합니다.

[FACT] 유효한 `article_analysis`는 AI provider 원문 응답 string·JSON 덩어리가 아니라 검증된 구조화 결과입니다. 표시 제목·요약은 text로, 중요도·관심 적합성은 분석 가능한 numeric value로, 홍보성·분석 추천은 controlled code로, 판단 근거는 reason code와 필요한 짧은 설명으로 보존합니다. keyword는 순서와 원값을 갖는 0개 이상의 `article_analysis_keyword` 자식 record로 보존합니다. 이 값들은 하나의 analysis aggregate의 서로 다른 논리 field 또는 자식 record이며 단일 `judgement_text` blob으로 합치지 않습니다.

[FACT] 정상 분석은 검증된 표시 제목, RSS 근거 범위의 2~3문장 요약, keyword·판단·reason을 출력합니다. 요약·keyword·판단 근거는 실제 input `rss_observation`에만 연결되며 외부 원문·외부 지식·말줄임표 뒤 내용을 보완하지 않습니다. GeekNews topic link는 AI가 생성한 값이 아니라 source `article`의 exact Raw RSS `link` reference로만 연결합니다.

[FACT] 저정보 분석은 `low_information` output class와 `정보 제한` 표시를 보존합니다. 표시 제목은 검증된 analysis title 또는 저장된 `rss_observation` title 중 하나를 사용하고, `title_source`가 둘 중 어느 출처인지 구분합니다. 저정보 요약은 RSS 근거 범위의 1문장 이하이거나, 충실한 설명이 불가능할 때 승인 문구 `RSS 제공 정보가 부족해 상세 요약을 생성하지 못했습니다`를 사용합니다. 제목·keyword·stored link를 임의 기본값·외부 정보로 보완하지 않습니다.

[FACT] `article_analysis_keyword`는 해당 analysis 안에서만 canonical입니다. MVP-A는 전역 `keyword` 사전, keyword 간 고유성, 대소문자·공백 정규화, 동의어·alias 병합 또는 전역 분류 체계를 만들지 않습니다. 이후 전역 keyword 모델이 필요하면 기존 analysis keyword 원값을 소급 변경하지 않고 별도 mapping을 추가합니다.

[FACT] `article_analysis`와 그 `article_analysis_keyword` 자식 record는 성공·저정보 분석 결과의 canonical owner이며, provider response evidence가 제목·요약·keyword·점수·판단을 다시 복사하지 않습니다. MVP-A에서 하나의 `batch_candidate`는 selection-eligible 정상 또는 저정보 analysis를 최대 하나만 가집니다. source attempt의 검증된 결과가 candidate를 처음 `analysis_resolved`로 고정할 때만 이를 만들며, `candidate.current_analysis_id` 같은 mutable pointer 또는 최신 analysis 교체 규칙은 만들지 않습니다. 새 output contract version 또는 사용자 승인 재분석은 MVP-A의 원래 batch selection input으로 활성화하지 않으며, 이후 범위에서 별도 immutable analysis를 허용하더라도 원래 analysis·candidate selection·selection result·delivery를 수정하지 않습니다.

[FACT] 현재 기사 최신성은 source `scheduled_batch`의 예정 Discord 전달 시각과 `rss_observation`의 비교 가능한 `published` instant로만 판정합니다. `0 ≤ (예정 전달 시각 - published) ≤ 13시간`이면 AI 분석·현재 기사 선정 대상에 포함하며, 정확히 13시간은 포함합니다. `published` 원값·해석 결과는 observation에, 이 판정 결과·사유는 batch candidate에만 두며 예정 시각이나 RSS 시각을 후보·분석·선정·delivery에 복사하지 않습니다. 13시간 초과·누락·오류·미래·비교 불가는 `batch_candidate`의 명시적 terminal 처리 결과로 보존하며 AI 분석 대상은 아닙니다.

[FACT] 최신성 제외·시간 검증 불가는 AI 장애·quota·비용 차단과 구분합니다. 이들의 수량과 이유는 보존하지만, 분석 가능한 유효 후보의 AI 완료를 기다리는 batch completion gate와 같은 의미로 처리하지 않습니다.

[INFERENCE] 정확한 candidate 상태명은 `awaiting_analysis`, `analysis_resolved`, `outside_freshness`, `freshness_unavailable`, `analysis_unresolved`처럼 후보 처리 축만 표현하고, selection·delivery 상태를 대체하지 않게 설계합니다. 실제 상태값은 후속 상세 상태 설계에서 확정합니다.

### AI lineage

[FACT] `ai_analysis_attempt`는 별도 intent 엔터티 없이 `prepared` 상태로 먼저 commit합니다. 이 상태는 article, 실제 AI 입력에 사용한 RSS observation, batch candidate, configuration snapshot, 비용 안전 근거 및 output contract version을 연결하며 외부 호출 전 intent 역할을 합니다.

[FACT] `prepared` attempt가 `invocation_started` 전 중단되면 같은 attempt를 DB 근거상 안전하게 재개할 수 있습니다. 호출 시작 전에는 그 attempt의 state를 `invocation_started`로 update·commit하고, 호출 뒤의 안전한 response·usage·limit 근거는 `external_attempt_evidence`로 연결합니다. 검증된 정상·저정보 업무 결과는 source attempt를 직접 참조하는 `article_analysis`에, 오류·응답 검증 실패·외부 효과 불명확은 attempt 결과에 남깁니다. 같은 candidate에 이미 selection-eligible analysis 또는 final `selection_result`가 있으면 후발·중복 response는 evidence와 비적용 사유만 append-only로 보존하고 새 analysis·재선정·delivery를 만들지 않습니다.

[FACT] 실제 provider 호출이 시작된 attempt는 `prepared`로 되돌리지 않습니다. retry 가능한 실패 뒤 새 provider 호출을 시도할 때는 같은 article·input observation을 참조하는 새 `ai_analysis_attempt`를 `prepared`로 만들며, 이전 attempt·evidence·결과를 수정하거나 덮어쓰지 않습니다.

[FACT] `external_attempt_evidence`의 `evidence_kind`는 상태나 기능이 아니라 관측 사실의 종류이며 초기 논리 값은 `response`, `usage`, `limit`으로 제한합니다. attempt lifecycle state와 evidence outcome은 별도입니다. 같은 kind라도 service key와 schema version에 따라 허용된 안전 값은 다를 수 있습니다.

[FACT] evidence row는 append-only이며 한 번 commit한 observation 값·시각·outcome을 수정하지 않습니다. 같은 attempt에 후속 usage·limit·정정 근거가 생기면 새 evidence row를 추가하고 기존 row를 덮어쓰지 않습니다. 관측되지 않은 kind를 빈 row로 만들지 않습니다.

[FACT] evidence에는 공통 식별자·source attempt·kind·관측 시각·schema version·outcome과 명시적으로 허용된 provider별 속성만 저장합니다. 여기서 안전한 evidence는 별도 자유형 field가 아니라 secret·credential·민감 header·불필요한 전체 응답을 제외한 허용 값의 집합입니다. 필요할 때만 provider response digest 또는 제한된 검증 근거를 보존하며, 제목·요약·점수·판단 결과는 `article_analysis`에만 둡니다.

[FACT] 최종 provider/model/prompt와 정확한 구조화 output schema는 아직 확정하지 않습니다.

[FACT] 비용·plan·quota 상태가 불명확하거나 유료 가능성이 있으면 AI 호출을 시작하지 않습니다.

### Candidate selection and batch item

[FACT] `selection_result`는 분석 가능한 유효 후보의 필요한 처리가 완료된 경우에만 고정합니다. 전체 선정이 불가능하면 article list 대신 처리 실패 notice를 고정합니다.

[FACT] `processing_failure_notice`는 정상·저정보 분석 결과가 하나 이상 확정됐지만 하나 이상의 유효 분석 대상 후보가 전체 선정을 막는 `partial_processing_failure`, 또는 유효 분석 대상 후보 중 정상·저정보 분석 결과가 하나도 확정되지 않은 `total_processing_failure`를 구분합니다. 두 경우 모두 article list·`candidate_selection`·`batch_item`을 만들지 않고, immutable result summary에 유효 신규 후보·처리 완료·미처리 수와 원인 범주를 보존합니다. 원인 범주는 quota, rate limit, 인증·설정, 응답 구조 검증 실패, timeout, provider 오류, 비용 차단 및 외부 효과 불명확의 논리 family로 attempt·비용 근거를 참조하며, exact provider별 code mapping은 확정하지 않습니다.

[FACT] `candidate_selection`은 분석 완료 후보에 대한 `selected`, `promotional_excluded`, `limit_not_selected` 결정과 순위·이유·정책 version 및 정확한 selection-eligible `article_analysis` reference를 보존합니다. selection finalization은 이 유일한 analysis가 없는 분석 대상 후보가 남아 있으면 후보별 selection을 만들지 않습니다.

[FACT] 중요도와 관심 적합성은 `article_analysis`의 서로 덮어쓰지 않는 판단값이며, `candidate_selection`은 둘과 적용 정책 version을 reference로 선정·정렬 근거를 보존합니다. 관심 적합성이 낮거나 관심 주제 밖이라는 사실만으로 후보 자격 또는 최종 선정 가능성을 제거하지 않으며, 전체 IT 중요도가 높은 후보는 선정 가능성을 유지합니다. 두 판단값의 정확한 조합·가중·동률 처리는 후속 정책 결정입니다.

[FACT] `promotional_excluded`는 RSS 근거와 적용 정책상 판매·가입 유도 또는 과장·자기홍보 중심이라는 충분한 근거가 있을 때만 사용합니다. source type, 회사·제품명, title prefix 또는 keyword 하나만으로 홍보성을 확정하지 않으며, 홍보성 판단이 애매하거나 불가한 후보는 제외하지 않고 선정 가능성을 유지합니다.

[FACT] `batch_item`은 `candidate_selection = selected`인 경우에만 생성하며, 실제 Discord 현재 기사 목록에 포함될 정리 기사의 immutable reference와 표시 순서를 고정합니다. 기사·AI 결과 값을 복사하지 않으며 홍보성 제외·최대 제한 미선정은 `batch_item`을 만들지 않습니다.

[FACT] 미처리 후보는 최대 제한 미선정 또는 정상 제외로 변환할 수 없습니다.

## Delivery and Acceptance Design

### DDI-03 — Delivery set, segment, physical message, and acceptance

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-03을 승인했고, 2026-09-02에 source cardinality를 추가 확인했습니다. `selection_result`는 원래 예정 batch의 불변 결과로 보존하고, `delivery_set`은 한 번의 실제 Discord 전달 기회를 묶는 컨테이너로 분리합니다.

[FACT] 각 `delivery_set`은 자신을 생성한 하나의 `work_item(type=delivery_release)`을 immutable reference로 가지며, 같은 logical delivery work는 최대 하나의 delivery set만 만들 수 있습니다. source work는 scheduled regular delivery, 처리 지연 full result, receipt confirmation, 승인된 1회 즉시 재전송 또는 사용자 선택 recovery의 생성 계기와 idempotency 범위를 구분합니다. 별도 `delivery_trigger` canonical 엔터티나 여러 trigger 값을 delivery set에 중복 저장하지 않으며, work key의 실제 물리 표현은 [UNKNOWN]입니다.

[FACT] `delivery_set` 자체는 하나의 `selection_result`만 소유하거나 참조하지 않습니다. article을 전달하는 각 `delivery_segment`가 하나의 source `selection_result`와 그중 실제 전달할 `batch_item` subset을 참조합니다. 따라서 한 delivery set의 current segment와 recovery segment는 서로 다른 원래 selection result를 안전하게 참조할 수 있습니다.

[FACT] current 또는 recovery article segment는 source `selection_result`의 immutable 원래 batch summary와 이 segment가 실제 전달하는 `batch_item` subset 수를 각각 reference로 읽습니다. recovery는 원래 선정 수와 실제 재전송 수가 다를 수 있으므로 둘을 대체하거나 합산하지 않습니다. `delivery_set`·batch 대표 message mapping·delivery summary는 서로 다른 source batch의 신규 후보·선정·제외·미처리 수를 합산한 새 canonical result를 만들지 않습니다.

[FACT] article `batch_item`을 갖는 delivery segment는 `scheduled_current`, `processing_delayed_full_result`, `confirmed_non_acceptance_recovery`를 논리 구간으로 구분합니다. `failure_notice` segment와 `receipt_confirmation` delivery는 article `batch_item`이 없는 non-article system message입니다.

[FACT] `failure_notice` segment는 source `processing_failure_notice` 결과만 참조하고 article `batch_item` subset은 갖지 않습니다. 필요하면 해당 notice의 physical system message mapping 하나 이상을 만들 수 있으며, 그 Discord 호출·수락·응답 유실은 독립된 `delivery_attempt`와 acceptance evidence로만 기록합니다. notice message의 2XX는 notice 전달만 뜻하며 batch review·article feedback·recipient receipt·recovery backlog를 만들지 않습니다. 그 message의 지원하지 않는 reaction은 raw Gateway event와 연결 불가 또는 지원하지 않는 mapping 사유만 보존하며 `feedback_state`나 recovery 상태를 update하지 않습니다. notice의 Discord 전달 실패는 AI 처리 실패 result, 원인·미처리 수 또는 유료 전환 없음 기록을 수정하거나 정상 신규 0건·전달 성공으로 바꾸지 않습니다.

[FACT] 다음 성공 정규 전달의 한 `delivery_set`은 현재 결과와 확인된 미수락 recovery를 별도 segment로 함께 가지거나, 이전 source result의 확인된 recovery segment만 가진 recovery-only set일 수 있습니다. recovery-only set은 해당 정규 전달 기회에 새 후보가 0건인 source batch의 current segment·`batch_item`·summary를 만들거나 포함하지 않으며, recovery segment는 원래 source selection result와 실제 미수락 subset만 참조합니다. 처리 지연 full result는 원래 batch의 `full_selection`이 고정되면 전용 `delivery_set`으로 release하며, current 또는 Discord 미수락 recovery segment와 같은 delivery set 또는 segment에 섞지 않습니다.

[FACT] current segment에서 미수락이 확인돼도 원래 segment·attempt·message mapping·selection result를 recovery 상태로 이동하거나 덮어쓰지 않습니다. 원래 미수락 mapping을 참조하는 `recovery_case`와 `recovery_event`를 만들고, 후속 delivery set의 recovery segment가 같은 source selection result와 실제 미수락 `batch_item` subset을 새로 참조합니다.

[FACT] `receipt_confirmation`은 article source selection을 갖는 segment가 아니라, 수락 불명확한 원래 delivery attempt를 참조하는 별도 confirmation delivery로 기록합니다. article `batch_item`을 포함하지 않으며, 기사 전달 성공·batch 검토 완료·품질 feedback으로 계산하지 않습니다. confirmation message의 2XX 또는 지원하지 않는 일반 reaction은 원래 article delivery의 수락·수신·recovery 상태를 바꾸지 않으며, 정확히 연결된 승인 사용자의 `받음`/`못 받음` interaction만 기존 `recovery_case`에 적용합니다.

[FACT] recovery backlog는 저장된 원래 selection 결과만 재사용하며, AI 재분석·재선정·최신성 재판정을 하지 않습니다.

### Delivery evidence and acceptance

[FACT] `delivery_segment`와 physical Discord message를 분리합니다. `delivery_attempt`는 하나의 `delivery_set`에 속한 실제 Discord invocation이고, 그 invocation에서 생성·확인하려는 physical message mapping을 참조합니다. article-bearing mapping만 정확히 하나의 delivery segment와 실제 `batch_item` subset을 `discord_message_item` association으로 연결하며, 같은 segment의 batch item은 article-bearing physical message 하나에만 연결합니다. batch 대표 mapping은 segment가 아니라 전체 delivery set을 참조하고, failure notice·receipt confirmation은 각 system source를 참조하며 article item association을 만들지 않습니다.

[FACT] `delivery_attempt`는 `prepared`·`invocation_started` lifecycle, 호출 후 Discord 응답 또는 오류의 `external_attempt_evidence`, 물리적 message mapping과 수락 근거를 분리합니다. attempt가 delivery set을 소유하지 않고 source delivery work와 set 아래에서 실행되므로, article message·batch 대표 message·system message의 실제 호출 이력을 같은 set 범위에서 대조할 수 있습니다. 논리 결과의 전달 완료는 필요한 physical message마다 Discord 수락 근거가 있을 때만 기록합니다.

[FACT] 유효한 Discord 2XX 응답과 필요한 message 식별자가 함께 확인되면 해당 physical mapping에 `discord_2xx` 출처의 acceptance evidence를 추가하고 `accepted`로 기록할 수 있습니다. 응답 유실·식별자 부족은 2XX 수락으로 추정하지 않습니다.

[FACT] 승인 사용자의 유효한 기사별 reaction, batch 대표 message의 ✅, 명시적 `받음`은 원본 Gateway/interaction event를 참조하는 append-only recipient-observed acceptance evidence가 될 수 있습니다. batch ✅ evidence는 하나의 delivery set에 실제 포함된 batch item 전체에 한 번만 연결하며 기사마다 복제하지 않습니다. 정규 current·recovery delivery set에서는 두 segment의 item을 함께 가리키고, 전용 처리 지연 delivery set에서는 그 지연 segment의 item만 가리킵니다. 이 evidence는 원래 Discord 2XX 수락 시각·response를 생성하거나 변경하지 않습니다.

[FACT] `discord_message_mapping`은 article message와 batch 대표 message를 구분합니다. batch 대표 message는 해당 `delivery_set`에 실제 포함된 batch item 전체를 가리키며, 정규 current·recovery 또는 전용 처리 지연 delivery set의 원래 selection batch 참조는 segment별로 보존합니다.

[FACT] article/message mapping의 수락 상태는 `accepted`, `explicitly_not_accepted`, `acceptance_uncertain`, `partially_accepted`, `unattempted`로 구분합니다. segment와 delivery set의 상태는 이 하위 근거를 요약한 값이며, 원본 근거를 대체하지 않습니다.

[FACT] 호출 후 응답 기록이 유실되면 `acceptance_uncertain`이며 2XX 수락·명시적 미수락으로 추정하거나 자동 재전송하지 않습니다. 다만 이후 정확히 mapping된 recipient-observed evidence가 있으면 원래 2XX를 만들지 않은 채 user-observed receipt로 recovery 확인 대상에서 제외할 수 있습니다.

[FACT] delivery acceptance resolution은 feedback reconciliation과 별도 논리 경계입니다. 늦게 보존된 원래 Discord 응답, Discord 계약 sandbox가 exact original mapping을 검증한 직접 positive message proof 또는 정확히 연결된 recipient-observed evidence만 원래 불명확 delivery에 연결할 수 있습니다. 직접 positive message proof는 `discord_message_reconciliation` 출처의 acceptance evidence로 기록하여 mapping을 `accepted`로 판정할 수 있지만, 원래 `discord_2xx` 응답·수락 시각·정시 수락 지표를 만들거나 대체하지 않습니다. `explicitly_not_accepted`는 원래 Discord 계약 응답 또는 sandbox가 검증한 별도의 명시적 미수락 근거가 있을 때만 기록합니다. recipient-observed evidence는 원래 server acceptance 상태를 덮어쓰지 않고 receipt confirmation·자동 recovery 대상 제외에만 사용합니다.

[FACT] 부분 수락에서는 `discord_message_item`이 가리키는 수락된 article을 성공 전달로 유지하고, 나머지는 각 physical mapping의 명시적 미수락 또는 수락 불명확 상태를 유지합니다. 명시적으로 미수락인 item은 같은 item 범위를 포함하는 유효한 recipient-observed receipt가 없을 때만 recovery 후보가 됩니다. 유효한 receipt가 있으면 server 미수락 evidence와 오류 이력은 보존하되 자동 recovery 후보에서는 제외합니다. 수락 불명확 또는 부분 수락은 자동 재전송하지 않습니다.

[FACT] `delivery_attempt`가 `prepared`이지만 Discord 외부 호출 전에 중단된 `unattempted` 결과는 DB 근거상 안전한 경우에만 원래 selection result로 재개할 수 있습니다.

[FACT] 승인 사용자의 `못 받음`은 원래 attempt·message·batch·article에 정확히 연결될 때만 1회 즉시 재전송 예외가 됩니다.

## Feedback and Reconciliation Design

### DDI-04 — Gateway event, REST snapshot, and feedback state

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-04를 승인했습니다. Gateway 원본 event, 제한된 REST 현재 snapshot 및 운영 조회용 현재 feedback projection을 서로 덮어쓰지 않는 세 계층으로 분리합니다.

[FACT] `discord_gateway_event`는 reaction 추가·제거, batch 검토, slash command 및 수신 확인의 원본 event를 append-only로 보존합니다. 제거 event가 추가 event를 삭제하지 않습니다.

[FACT] 동일한 외부 event identity가 재전달되면 현재 상태 projection에는 한 번만 적용합니다. event 순서가 불명확하거나 누락 가능성이 있으면 현재 상태를 추정하지 않고 reconciliation request를 만듭니다.

[FACT] `reconciliation_request`는 새 Gateway 연결에서 resume 실패, DB 복구, Gateway event 저장 실패, feedback 지표 계산 직전의 네 경우에만 만듭니다. REST는 이 저장된 request를 근거로 추적된 system message·승인 사용자·허용 reaction 범위에서만 실행합니다.

[FACT] `reconciliation_request` 생성은 내부 DB 기록이며 Discord REST 호출 또는 feedback 부재 판정을 뜻하지 않습니다. request의 실제 REST 실행은 별도 Discord 외부 효과로 취급하며, 정기 polling·새 trigger의 확대 또는 request만으로 외부 호출을 허용하지 않습니다.

[FACT] `reconciliation_request`와 그 REST snapshot은 feedback 현재 상태 전용이며 delivery acceptance resolution에 재사용하지 않습니다. sandbox에서 검증된 direct message proof가 필요하면 원래 delivery attempt·message mapping·payload/configuration version에 정확히 묶인 별도 logical work와 external contract check를 거쳐야 하며, 그 work는 feedback state를 update하지 않습니다. 검증되지 않은 REST 조회, 제목·payload 유사성 또는 시간 추정으로 original mapping을 맞추거나 acceptance evidence를 만들지 않습니다.

[FACT] `rest_state_snapshot`은 대조 시점의 현재 상태만 보존하며 Gateway event를 삭제하거나 수정하지 않습니다.

[FACT] `feedback_state`에는 subject별로 안전하게 순서를 비교할 수 있는 최신 observation만 projection으로 적용합니다. 이미 적용한 observation보다 이전임이 확인된 Gateway 재전달 또는 REST snapshot은 현재 state를 되돌리지 않습니다. observation 순서·누락·대조 범위를 안전하게 판단할 수 없으면 `present`·`absent`를 추정하지 않고 `stale` 또는 `unknown`의 비확정 상태와 근거를 유지합니다. 실제 event sequence·clock 비교 방식은 [UNKNOWN]입니다.

[FACT] `feedback_state`의 현재 상태는 `present`, `absent`, `stale`, `unknown`, `unmapped`로 구분합니다. `absent`는 현재 reaction 부재의 확인 근거가 있을 때만 사용합니다.

[FACT] `feedback_state`는 사용자·운영의 현재 조회를 위한 projection이며 immutable evaluation의 최종 evidence가 아닙니다. evaluation snapshot은 DDI-08에서 정한 cutoff 아래 `discord_gateway_event`·`rest_state_snapshot`·reconciliation reference로 같은 feedback predicate를 당시 상태로 재구성합니다.

[FACT] Gateway 또는 REST observation으로 `feedback_state`를 update해도 append-only `discord_gateway_event`·`rest_state_snapshot`, Discord 2XX·recipient-observed `acceptance_evidence`, `recovery_event` 및 `conflicting_receipt`를 생성·삭제·수정하지 않습니다. ✅ 제거 또는 REST의 reaction 부재는 현재 review projection만 취소할 수 있으며, 과거 receipt·수락·상충 근거를 되돌리지 않습니다.

[FACT] feedback event와 REST 현재 상태 관측이 모두 없는 subject에는 feedback state row를 만들지 않습니다. 이 경우 조회상 `not_observed`로만 해석하며 `absent`, feedback 없음, 검토 미완료, 수신 실패로 변환하지 않습니다. REST reconciliation이 현재 reaction 부재를 확인한 경우에만 해당 state row를 만들거나 `absent`로 update합니다.

[FACT] `feedback_state.feedback_kind`는 article negative reaction, batch review와 `missing_article_recommendation`으로 제한된 의미를 구분합니다. `reaction_code`는 같은 kind 안의 정확한 reaction을 구분합니다. 종류마다 허용 source mapping과 의미가 다르며, 하나의 typed projection을 사용하더라도 서로의 지표 의미로 변환하지 않습니다.

[FACT] `stale`, `unknown`, `unmapped`은 feedback 없음·검토 미완료·암묵적 수용으로 추정하지 않으며, 운영 조회와 evaluation as-of 재구성에서 해당 상태가 필요한 품질 지표의 분자·분모에서 제외하고 별도 수량으로 보고합니다.

[FACT] article 부정 reaction은 article·원래 batch·reaction 종류·승인 사용자의 mapping으로 관리합니다. 😕, 🚫, 📣은 같은 article에 복수로 존재할 수 있습니다.

[FACT] batch 대표 message의 승인 사용자 ✅ 현재 상태는 해당 `delivery_set`에 실제 포함된 batch item 전체의 검토 완료 대상이자 user-observed receipt 근거에 연결합니다. 정규 current·recovery delivery set에서는 두 segment의 item을, 전용 처리 지연 delivery set에서는 지연 segment의 item만 대상으로 합니다. ✅ 제거는 현재 검토 완료 취소이지만, 이미 저장된 Gateway event와 recipient-observed evidence를 삭제하지 않습니다. 이 근거는 원래 Discord 2XX 수락 시각·원문 열람·각 article의 명시적 유용함을 뜻하지 않습니다.

[FACT] ✅ receipt 근거와 `받음`/`못 받음`의 상충 여부는 같은 source selection result가 아니라 exact delivery attempt·message mapping 및 실제 대상 `batch_item` 범위가 겹치는지를 기준으로 판단합니다. 원래 D1의 `못 받음`과 그 결과로 재전송한 D2의 ✅는 서로 다른 delivery scope이므로 상충이 아닙니다. 반대로 같은 D1 scope의 유효한 ✅와 `못 받음`은 어느 근거도 삭제·우선하지 않고 `conflicting_receipt`로 보존합니다.

[FACT] `delivery_set`, `delivery_segment`, `scheduled_batch`에는 `feedback_received` 같은 feedback 상태를 별도 저장하지 않습니다. batch review의 현재 상태는 batch 대표 message mapping을 subject로 하는 `feedback_state(feedback_kind=batch_review)`에서 조회하며, row가 없으면 `not_observed`입니다.

[FACT] 운영 조회에서 암묵적 수용은 같은 delivery set의 batch review가 현재 `present`이고, 해당 article에 Discord 2XX 수락 또는 그 batch review에서 파생된 유효한 user-observed receipt 근거가 있으며, 😕·🚫·📣 세 부정 reaction 상태가 모두 확인된 `absent`인 경우에만 계산합니다. 하나라도 `present`이면 부정 article이며, `not_observed`·`stale`·`unknown`·`unmapped`은 암묵적 수용률 분자·분모에서 제외합니다. evaluation snapshot은 이 predicate를 mutable current projection이 아닌 DDI-08의 cutoff-bound 원본 observation으로 재구성합니다.

[FACT] batch review 원본 event와 현재 `feedback_state`의 subject는 하나의 `delivery_set`·batch 대표 message에 한 번만 연결합니다. 평가의 암묵적 수용 계산 단위는 physical message·delivery set이 아니라 source `selection_result`의 `batch_item` 하나입니다. current·recovery가 섞인 delivery set의 ✅는 실제 포함된 각 batch item에 검토 완료·receipt 근거로 적용하되, 평가는 각 item을 source scheduled batch로 귀속하고 서로 다른 source batch의 수량을 합치지 않습니다. 승인된 즉시 재전송처럼 같은 batch item의 physical mapping이 여러 개여도 item을 message 수만큼 중복 계산하지 않고 mapping은 전달·feedback 근거로만 읽습니다.

[FACT] 누락 기사 요청과 `받음`/`못 받음` 확인은 원본 Gateway/interaction 근거를 가질 수 있지만, 품질 reaction·batch 검토 완료와 다른 business 의미와 지표를 가집니다. batch review feedback의 `present`·`absent`·`not_observed`는 Discord 수락·사용자 수신·원문 열람으로 해석하지 않습니다.

[UNKNOWN] Discord의 실제 event identity·sequence·resume 계약, REST endpoint·pagination·권한·rate limit·retry/backoff 및 interaction transport는 sandbox 검증 전 확정하지 않습니다.

## Work Claim and Transaction Design

### DDI-05 — Work claim, lease, and external-effect uncertainty

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-05를 승인했고, MIN-05에서 execution·lease 저장을 최소화했습니다. `work_item`은 논리 작업의 현재 실행·최종 상태와 동시 실행을 조정하는 현재 요약 record이고, `work_attempt`는 실제 claim 성공 뒤 시작한 실행 이력을 append-only로 보존합니다. RSS·AI·선정·전달의 business 결과는 각 도메인 엔터티에 분리 보존합니다.

[FACT] 논리 work key는 대상과 외부 효과 경계를 포함합니다. 예정 batch prepare, batch candidate AI 분석, delivery release, reconciliation request, recovery case 처리, evaluation은 서로 다른 logical work입니다.

[FACT] delivery release work key는 scheduled regular delivery의 target `scheduled_batch`, 처리 지연 full result의 source `selection_result`, receipt confirmation·승인된 즉시 재전송·사용자 선택 recovery의 정확한 source `recovery_event` 또는 interaction 범위를 서로 구분합니다. 이 key를 참조하는 delivery set은 하나만 허용하며, target 실행 계기와 segment가 참조하는 원래 selection result를 서로 대체하지 않습니다.

[FACT] reconciliation의 logical work key는 trigger 시각이 아니라 추적된 system message·승인 사용자·허용 reaction으로 구성된 exact reconciliation scope와 적용 configuration/contract boundary를 나타냅니다. 같은 exact scope에 resume 실패·DB 복구·event 저장 실패·evaluation trigger가 겹치면 하나의 `work_item`과 현재 lease를 재사용하며, claim을 얻지 못한 trigger는 새 `work_attempt`·REST domain attempt·HTTP 호출을 만들지 않습니다. 일부만 겹치는 scope의 병합·분할 방식은 [UNKNOWN]입니다.

[FACT] 동일 logical work key에는 하나의 `work_item`과 동시에 하나의 현재 유효 lease만 존재할 수 있습니다. work item의 현재 state·lease owner·token·획득·만료·갱신 값은 실행 중 update될 수 있으며, 완료·차단·대기 뒤에는 현재 상태만 남습니다. 각 claim의 owner·token·시작·종료·outcome은 append-only `work_attempt`에 남겨 전체 이력을 재현합니다. 별도 `work_lease` canonical record는 만들지 않습니다.

[FACT] lease 유효성·만료 판단은 worker 또는 Pod의 local clock이 아니라 PostgreSQL 기준 시각으로 합니다. 외부 invocation을 시작하는 `prepared → invocation_started` 전환은 같은 transaction 안에서 현재 work item의 유효 lease와 claim token이 work attempt의 token과 일치하는지 대조해야 합니다. 만료 또는 교체된 token의 worker는 새 외부 invocation을 시작하거나 prepared attempt를 `invocation_started`로 바꿀 수 없습니다. 정확한 token 표현·lease 기간·SQL/ORM isolation은 [UNKNOWN]입니다.

[FACT] 유효 lease가 없는 work item을 claim할 때 현재 lease 설정과 실제 `work_attempt` 생성은 같은 DB transaction으로 처리합니다. claim을 얻지 못한 worker는 실제 작업을 시작하지 않았으므로 work attempt를 만들지 않고 현재 상태만 대조한 뒤 종료합니다.

[FACT] `batch_execution`은 `scheduled_batch`와 그 batch의 prepare `work_item`·`work_attempt`를 결합한 읽기 전용 논리 projection입니다. 같은 실행 사실을 별도 canonical row로 중복 저장하지 않습니다.

[FACT] 목표 전달 시각 전에는 해당 예정 slot을 idempotent하게 등록하고 Prepare claim을 시작할 수 있습니다. 목표 전달 시각 뒤 또는 서비스 복구 뒤에 발견한 과거 slot은 같은 deterministic scheduled-batch identity의 historical ledger record로만 등록할 수 있으며, 이 등록은 Prepare work item·work attempt·RSS fetch·AI 분석·selection·Discord delivery를 만들지 않습니다. 이는 목표 시각 뒤 새 예정 batch를 실행하는 것이 아닙니다.

[FACT] 평가 또는 운영 조회 시 source ledger가 완전하다고 검증된 예정 slot에 prepare `work_attempt`가 없으면 `batch_execution`은 `not_executed`로 읽습니다. prepare attempt가 있으나 final `selection_result`가 없으면 `incomplete` 또는 저장된 work 상태로 읽으며, 둘 다 정상 신규 0건이 아닙니다. 정상 신규 0건은 승인된 수집·입력·처리 완료 뒤 고정된 결과로만 판단합니다. restore 또는 ledger 완전성을 신뢰할 수 없으면 attempt 부재를 `not_executed`로 단정하지 않고 `not_measurable`과 원인을 유지합니다. 실제 projection code와 상태 표현은 [UNKNOWN]입니다.

[FACT] claim을 얻지 못한 실행은 중복 실행하지 않고 처리 중·완료·불명확 대기 상태를 대조한 뒤 종료합니다.

[FACT] 외부 API 호출이 없는 내부 DB 작업은 lease 만료 뒤 commit된 결과를 대조해 안전하게 재claim할 수 있습니다.

[FACT] 예정 batch의 selection finalization은 별도 `selection_finalization` work item을 만들지 않는 기존 Prepare logical work의 마지막 내부 단계입니다. 후보 분석 완료·terminal 처리의 변경은 Prepare 재개를 요청할 수 있으나, 같은 batch의 최종 결과를 고정하는 책임은 그 Prepare work 하나에 남습니다.

[FACT] Prepare가 finalization을 시작할 때는 하나의 짧은 DB transaction 안에서 현재 유효 lease·fencing token, RSS 입력 단계 완료, source batch의 모든 candidate 처리 상태와 이미 고정된 `selection_result` 존재 여부를 다시 대조합니다. 결과가 이미 있으면 이를 재사용하고 selection을 다시 계산하거나 후보별 결정을 추가하지 않습니다. 결과가 없고 completion 조건이 충족되면 `selection_result`, immutable summary, 필요한 `candidate_selection`·`batch_item`, Prepare work의 완료 상태와 해당 attempt의 종료 결과를 함께 commit합니다. token이 만료·교체됐거나 completion 조건이 달라지면 결과를 쓰지 않고 현재 상태를 다시 읽습니다.

[FACT] AI·Discord 외부 효과가 있거나 있을 수 있는 work는 lease 만료만으로 재실행하지 않습니다.

[FACT] AI·Discord 외부 호출은 다음 순서로 분리합니다.

```text
도메인 attempt의 prepared 상태 commit
  → invocation started commit
  → 외부 API 호출
  → external_attempt_evidence와 업무 결과 commit
```

[FACT] attempt가 `prepared`이지만 `invocation_started` 전 중단된 경우에는 외부 호출이 시작되지 않았으므로 DB 근거상 안전하게 원래 작업을 재개할 수 있습니다. 단, 재개 직전에도 현재 유효 lease·fencing token, outbound gate, 비용 안전 상태, 적용 configuration snapshot 및 외부 contract 확인이 모두 유효하고 서로 일치하는지 다시 대조해야 합니다. 하나라도 충족하지 않으면 같은 prepared attempt를 원인과 함께 차단·대기 상태로 두며, 외부 invocation 또는 새 attempt를 만들지 않습니다.

[FACT] invocation started 뒤 응답·오류 근거를 기록하지 못한 경우에는 `external_effect_uncertain`으로 유지합니다. AI 자동 재호출과 Discord 자동 재발송을 하지 않습니다. lease가 만료된 worker도 새 invocation을 시작할 수는 없지만, source attempt와 correlation 또는 mapping이 명확히 일치하는 late response·usage·acceptance evidence는 해당 invocation-started 도메인 attempt에 append-only·idempotent하게 추가할 수 있습니다. AI의 late response는 source candidate가 아직 미해결이고 final `selection_result`가 없을 때만 검증을 거쳐 그 source attempt의 유일한 selection-eligible `article_analysis`와 업무 결과를 commit하여 `external_effect_uncertain`을 해소할 수 있습니다. 이미 다른 analysis가 candidate를 해결했거나 final result·failure notice가 고정된 뒤에는 evidence와 비적용 사유만 보존하며 새 analysis·selection·delivery를 만들지 않습니다. 출처·대응 관계가 불명확하거나 중복·상충하는 evidence는 불명확 상태와 원인을 유지합니다.

[FACT] outbound gate에 막힌 reconciliation work는 REST domain attempt 없이 차단·대기 상태로 남으므로, gate가 열리면 같은 work item을 다시 claim해 호출 전 경계부터 안전하게 진행할 수 있습니다. 반면 reconciliation REST domain attempt가 `invocation_started` 뒤 응답 근거 없이 중단되면 같은 scope의 후속 trigger·lease 만료·gate 재개만으로 자동 재호출하지 않고 `external_effect_uncertain`과 feedback 비확정 상태를 유지합니다.

[FACT] DB transaction이 commit되지 않으면 AI·Discord 외부 호출을 시작하지 않습니다. DB 무결성·restore 신뢰가 불명확하면 신규 outbound를 자동 재개하지 않습니다.

[UNKNOWN] lease 시간, 갱신, 정확한 logical key, constraint 및 isolation 구현은 후속 상세 설계와 sandbox 검증 전 확정하지 않습니다.

## Operational Evidence and Control Design

### DDI-06 — Configuration, cost, backup/restore, and outbound gate

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-06을 승인했습니다. configuration, 비용 안전, 수동 pause, backup/restore 검증과 수동 resume approval은 시점별 evidence와 `operational_event`로 분리 보존합니다.

[FACT] `configuration_snapshot`은 provider/model 식별자, free-only 정책, output contract·판단 정책 version, runtime/image revision 및 등록 시각을 immutable하게 보존하는 설정 설명 record입니다. 설정을 새로 등록하거나 변경할 때만 만들고, 변경 전까지 여러 batch·attempt가 같은 snapshot을 재사용합니다. pause·resume·재활성화와 batch 실행은 새 snapshot을 만들지 않습니다.

[FACT] historical ledger 등록이 아닌 실제 Prepare의 첫 내부 commit은 해당 batch의 processing `configuration_snapshot`을 한 번 binding하며, 이후 batch의 AI attempt와 final `selection_result`는 같은 snapshot을 각각 reference로 보존합니다. 이 binding은 예정 시각·현재 활성화 상태·secret을 `scheduled_batch`에 복사하는 것이 아니라 Prepare work scope의 immutable 처리 기준입니다. candidate selection과 batch item은 source selection result를 통해 이 기준을 상속합니다.

[FACT] batch가 진행 중인 상태에서 새 snapshot이 승인·활성화돼도 기존 batch의 binding·이미 저장된 attempt·analysis·selection result를 바꾸지 않습니다. 기존 snapshot이 계속 비용·계약 조건을 충족하면 같은 snapshot으로만 AI retry를 진행할 수 있고, 충족하지 않으면 새 snapshot으로 자동 전환하지 않고 해당 후보·batch를 차단 또는 미처리 상태로 유지합니다. 새 snapshot은 후속 실제 Prepare batch에만 binding할 수 있으며, 자동 재분석·재선정을 만들지 않습니다.

[FACT] `configuration_snapshot`은 outbound 활성화 이력이나 현재 허용 상태를 뜻하지 않습니다. 활성화·pause·resume과 필요한 사용자 승인·재개 조건은 snapshot, contract check, 비용·backup·DB evidence를 참조하는 `operational_event`만 소유합니다.

[FACT] `external_contract_check`는 RSS·AI·Discord의 `service_key`, 비밀값 없는 적용 설정 version 또는 fingerprint, 확인 계기, 공식 계약·자료 version 또는 fingerprint, 검증 시각, 검증 방식과 결과, 불일치·미확인의 영향 및 활성화 차단 여부를 보존합니다. 검증 방식은 공식 자료 확인, sandbox 또는 제한 workload 검증의 수행 여부와 결과를 구분하되 원문·전체 응답·credential은 보존하지 않습니다. 외부 서비스별 subject 엔터티나 별도 activation snapshot을 만들지 않고, `configuration_snapshot`이 활성화에 필요한 하나 이상의 reusable contract check를 참조합니다.

[FACT] contract check는 구현 직전, 운영 검증 시작 직전, 외부 계약·적용 설정 변경 확인, mismatch 발견 또는 승인된 재검증 때 새 record를 만듭니다. batch·호출마다 반복 생성하지 않으며 공식 문서 원문·전체 응답·secret은 저장하지 않습니다. 확인 불가·미검증·설정 불일치·유료 가능성은 안전한 것으로 추정하지 않고 영향 경로의 활성화 차단 여부와 사유를 기록합니다.

[FACT] 하나의 contract check는 조건이 여전히 일치하는 여러 configuration snapshot에서 재사용할 수 있습니다. configuration snapshot은 check 결과·공식 자료를 복사하지 않고 check reference만 연결합니다.

[FACT] credential, webhook URL, interaction secret, API key와 그 파생 민감값은 configuration snapshot, 비용·운영 evidence, DB, 일반 log, metric, trace, AI input, 사용자 표시에 저장하지 않습니다.

[FACT] 시스템은 provider·model·credential·과금 경로를 자동 전환하지 않습니다. 비용·plan 상태가 불명확하거나 새 설정이 비용 안전 검증을 통과하지 못하면 해당 비용 가능 AI 경로를 fail-closed로 차단합니다.

[FACT] 하나의 `cost_safety_evidence`는 AI provider, Discord 연동, K3s runtime/host, PostgreSQL/PersistentVolume, backup 저장소, image registry, scheduler/monitoring 중 하나 이상의 적용 범위를 함께 다룰 수 있습니다. 적용 범위마다 별도 비용 엔터티를 만들지 않으며, 하나의 근거가 여러 범위를 덮는 경우 그 coverage만 한 record에 보존합니다.

[FACT] 사용자의 billing·usage 확인, 공식 provider quota/오류 근거, 전 실행 경로의 월별 비용 확인 기간·결과와 영향 batch·작업은 `cost_safety_evidence`로 연결합니다. 이 record는 해당 범위의 0원 확인·확인 불가·위반 사실을 구분하지만 account identifier·invoice 원문·credential은 보존하지 않습니다. 실제 비용 위반을 사용자가 확인해 수동 중지를 선택한 사실과 재확인 결과는 별도 `operational_event`로 기록합니다.

[FACT] 외부 호출 전 outbound gate는 모든 비용 가능 실행 범위의 무료·과금 불가 설정과 공식 비용 조건을 확인한 사전 비용 안전 근거를 사용합니다. 실제 월별 billing 결과는 해당 기간이 끝난 뒤의 사용자 운영 증거이며, 첫 운영월에 아직 존재하지 않는 월 결과 자체를 사전 비용 안전 미확인으로 바꾸지 않습니다.

[FACT] 비용 상태의 재확인은 새 `cost_safety_evidence`만 추가하며 configuration snapshot이나 contract check를 복제하지 않습니다. AI·Discord attempt는 적용 configuration snapshot 및 필요한 최신 사전 비용 안전 근거를 참조하고, runtime·storage·backup·registry 같은 환경 범위의 근거는 outbound gate가 참조합니다.

[FACT] 수동 pause와 resume approval은 reason, 시각, 영향 workload 범위, 사용자 확인 근거 및 재개 조건을 `operational_event`로 보존합니다. 확인된 비용 위반, 비용 가능 경로의 사전 비용 안전 상태 불명확 또는 수동 pause 뒤에는 자동 재개하지 않습니다.

[FACT] `backup_run`은 생성 시각·성공/실패·검증 가능성·별도 실패 영역 보관 근거를, `restore_validation`은 DB 무결성·ledger 대조·필요한 Discord/feedback 대조·사용자 수동 승인 상태를 보존합니다.

[FACT] `backup_run`과 `restore_validation`은 각각 실행·검증의 source record이며, 성공한 backup 또는 통과한 validation을 `operational_event`에 다시 복사하지 않습니다. backup 실패, restore 검증 대기, 수동 pause·resume approval처럼 사람이 확인해야 하는 사건만 해당 source record를 참조하는 `operational_event`로 추가합니다.

[FACT] backup 공백 한계 초과, DB 신뢰 불명, restore 검증 대기, 비용 가능 실행 범위의 사전 비용 안전 미확인 또는 확인된 비용 위반, 수동 pause 중 하나라도 존재하면 outbound gate는 닫힙니다. AI와 Discord의 새 외부 호출은 모든 허용 조건이 충족될 때만 시작합니다. 아직 존재하지 않는 실제 월별 billing 결과만으로는 gate를 닫지 않지만, 그 기간의 비용 Hard Gate는 `pass` 또는 0원으로 추정하지 않습니다.

[FACT] 저장된 reconciliation request의 Discord REST 실행도 같은 outbound gate, 적용 configuration snapshot 및 Discord external contract check를 통과해야 합니다. gate가 닫혀 있으면 request는 차단·대기 사유를 가진 내부 work로 유지하고 REST domain attempt·HTTP 호출을 만들지 않으며, feedback state를 `absent`로 바꾸지 않습니다. 실제 REST 호출 뒤의 rate limit·권한·timeout·오류는 해당 Discord attempt와 안전한 evidence에 원인으로 남기고, 자동 polling·자동 비용 경로 전환 또는 미확정 retry를 시작하지 않습니다.

[FACT] restore 뒤에는 DB 무결성, batch·prepared delivery attempt·Discord 수락 근거, 필요한 Gateway/REST feedback 상태를 대조하고 사용자가 수동 승인하기 전까지 outbound를 재개하지 않습니다.

[UNKNOWN] backup 도구·저장 위치, 공백 한계, RPO/RTO, provider별 quota 재개 공식 근거, 실제 K3s pause/resume 명령, contract 재검증 주기와 configuration/evidence의 정확한 필드 구조는 환경 검증 전 확정하지 않습니다.

## Retention Boundary

### DDI-07 — MVP-A Retention과 MVP-B lifecycle 경계

[FACT] MVP-A는 자동 Retention lifecycle을 구현하지 않습니다. Raw RSS 3개월·AI 결과 12개월·월별 Insight 무기한 보존은 MVP-B 목표 정책입니다.

[FACT] 아래의 `article_identity_tombstone`, retention gate, deletion manifest와 `retention_purged`는 미래 데이터 정리에서 identity 손실·중복 처리·미해결 외부 효과의 삭제를 막기 위한 reserved safety constraint입니다. MVP-A의 canonical entity·현재 schema·실행 lifecycle 또는 최종 MVP-B 계약이 아니며, 실제 필요성·명칭·필드·관계·실행 interface와 정책은 MVP-B 상세 설계에서 별도 승인해야 합니다.

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-07을 승인했습니다. 보존 대상은 하나의 batch 시각으로 일괄 판정하지 않고, Raw RSS는 fetch·snapshot 시각, AI 분석 결과는 분석 완료 시각, 월별 Insight는 대상 기간·생성 시각이라는 도메인별 시계로 판정합니다.

[FACT] MVP-B에서 월별 Insight와 retention을 별도 승인해 도입한다면, 월별 Insight는 원본 행을 단순 참조하는 report가 아니라 대상 기간·정규화/집계 정책 version·입력 건수·검증 결과·입력 manifest를 갖는 독립 snapshot이어야 합니다. 해당 snapshot의 완결성 검증 전에는 원본 보존 정리를 시작하지 않습니다.

[FACT] article의 상세 관찰·분석·선정·feedback 기록을 보존 정책에 따라 정리하더라도, exact Raw RSS `link` identity와 최초 관찰 시각, 삭제 시각·정책 version·`retention_purged` 상태는 `article_identity_tombstone`으로 남깁니다. 이는 이후 같은 link 재관찰을 신규 기사로 잘못 처리하지 않기 위한 최소 identity 근거입니다.

[FACT] 자동 정리 대상은 Insight 완결성, 유효 work lease, `external_effect_uncertain`, 미해결 recovery·수락 확인, 필요한 feedback/evaluation 근거, backup 및 restore 검증 상태를 모두 확인하는 retention gate를 통과해야 합니다. 통과 전·후 대상 수와 policy version, 실행 결과 및 실패 이유는 deletion manifest와 감사 record로 남깁니다.

[FACT] PostgreSQL backup은 database 보존과 분리된 backup 전용 폐기정책을 따릅니다. 반면 Discord에 이미 발송한 system message는 이 데이터 보존 lifecycle 때문에 자동 삭제하지 않습니다.

[INFERENCE] Discord message의 삭제는 별도 Discord API 호출·권한·실패 및 수락 근거 보존 문제를 만들므로, database record 삭제와 연결하지 않는 것이 MVP-A의 비용 0원 및 안전한 외부 효과 원칙에 부합합니다.

[UNKNOWN] backup의 실제 보존 기간·폐기 방식·저장 위치, deletion job의 실행 주기·순서·실제 삭제 단위, Insight 완결성 검증 규칙과 user-facing retention-purged 응답은 환경 검증 및 후속 MVP-B 상세 설계에서 확정합니다.

### DDI-08 — Typed evaluation result와 immutable evaluation snapshot

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-08을 승인했고, MIN-02에서 평가 저장 구조를 최소화했습니다. RSS·AI·selection·delivery·feedback·recovery business record가 원본 사실이며, 평가 때 이 원본을 읽기 전용으로 계산합니다. 같은 사실을 지속적인 `metric_observation`으로 다시 복제하지 않고 평가 snapshot에 확정된 결과만 보존합니다.

[FACT] 평가 실행은 `work_item(type=evaluation)`과 `work_attempt`가 소유합니다. `evaluation_run`은 이 실행 기록과 성공한 snapshot을 보여 주는 논리 projection이며 별도 canonical record를 만들지 않습니다. 실행이 성공한 경우에만 `evaluation_snapshot`을 만들고, 실패·재시도는 work attempt에만 기록합니다. 사람 확인이 필요한 실패만 `operational_event`를 추가합니다.

[FACT] 사용자는 2026-09-03 Asia/Seoul에 MVP-A evaluation의 기본 실행을 사용자 요청 기반 command로 승인했습니다. batch별·일별 자동 evaluation은 MVP-A에서 만들지 않습니다.

[FACT] `evaluation_snapshot`은 대상 기간·대상 scheduled batch 범위 또는 ID, `as_of_at`, 계산 시각·성공 work attempt, `metric_definition_version` 및 `input_manifest_scheme_version`을 immutable하게 보존합니다. compact input manifest의 source별 항목은 source kind, high-watermark 또는 고정 reference, 선택 input row 수와 deterministic digest를 보존합니다. `input_manifest_scheme_version`은 source kind·선택 projection·canonical ordering의 해석을 구분합니다. 원본 article·AI·delivery·feedback payload나 전체 원본 ID 목록은 복사하지 않습니다.

[FACT] `as_of_at`과 source high-watermark는 평가가 사용한 원본 사실의 관측 cutoff입니다. 늦게 저장된 Gateway event·REST snapshot은 외부 발생 시각이 cutoff보다 이르더라도 해당 source high-watermark 밖이면 기존 evaluation snapshot에 소급 반영하지 않습니다. feedback 의존 지표는 mutable `feedback_state`를 최종 evidence로 읽지 않고, snapshot에 고정된 high-watermark와 reconciliation reference 이하의 `discord_gateway_event`·`rest_state_snapshot`으로 당시 상태를 재구성합니다.

[FACT] evaluation scope는 단일 예정 batch, Asia/Seoul 하루의 두 예정 batch, 또는 검증 기간의 batch 범위가 될 수 있습니다. 단일 batch와 하루 scope는 운영 진단용이며 MVP-A 품질 통과·실패를 확정하지 않습니다. 최소 2주·20개 예정 batch·50개 후보 및 최대 4주의 해석은 검증 기간 scope에만 적용합니다. 하루 scope에 속한 예정 batch가 미실행이어도 범위에서 제거하지 않고, 미실행 사실과 준비시간 측정 불가 또는 목표 미충족 사유를 보존하며 준비시간 비율 분모에서 제외하지 않습니다. source ledger 완전성을 검증할 수 없는 경우에는 미실행 수·준비시간을 0 또는 실패로 추정하지 않고 `not_measurable`로 구분합니다.

[FACT] `evaluation_result`는 한 snapshot 아래에서 `sample_adequacy`, `quality_review`, `hard_gate`, `quality_metric`, `service_metric`, `final_interpretation`의 `result_kind`를 구분합니다. snapshot 공통 기간·입력 manifest·definition version을 반복 저장하지 않습니다.

[FACT] 모든 성공 snapshot의 `final_interpretation`은 논리적으로 `scope_kind`, `interpretation_level`, 결론 또는 판정 불가 사유 및 참조한 `sample_adequacy`·`hard_gate`·품질·서비스 결과를 보존합니다. 단일 batch와 하루 scope의 `interpretation_level`은 운영 진단이며 MVP-A 품질 통과·실패 결론을 만들지 않습니다. 검증 기간 scope의 `interpretation_level`만 MVP-A 품질 검증 통과 후보 여부를 해석할 수 있습니다. 물리 field명과 최종 결론 code는 [UNKNOWN]입니다.

[FACT] `quality_review`는 선택된 평가 표본 하나와 검토 기준 하나에 대한 상세 품질 판정입니다. RSS 충실도 검토는 source `article_analysis`와 `rss_observation`을, 홍보성 오선정·누락 검토는 `candidate_selection`과 연결된 분석·article을 reference로 연결합니다. 검토 결과·이유와 source reference만 보존하며 원본 RSS·AI payload를 복사하지 않습니다.

[FACT] `quality_review` row는 사용자 요청 evaluation에서 선택한 표본·기준에 대해서만 생성합니다. 모든 article·analysis·selection마다 지속적으로 생성하지 않으며, 재검토는 기존 결과를 update하지 않고 새 evaluation snapshot 아래의 새 결과입니다. 같은 snapshot의 `quality_metric`과 `hard_gate`는 해당 `quality_review`를 reference로 집계·판정할 수 있습니다.

[FACT] `sample_adequacy` 결과는 최소 2주·20개 예정 batch·50개 후보의 각 충족 여부와 최대 4주 뒤의 `판정 불충분`을 보존합니다. `hard_gate` 결과는 추가 월 비용·유료 호출·유료 자원 사용, 미처리 후보 조용한 제외, 의도되지 않은 동일 기사 중복 발송, AI 실패의 신규 0건 오표시, Discord 미수락의 성공 오표시, 중대한 RSS 근거 밖 사실 생성의 여섯 Gate를 각각 독립적으로 평가합니다. 각 Gate의 승인 기준은 위반 0건이며, `pass`, `fail`, `not_measurable`과 근거 metric·누락 evidence·실패 이유를 기록합니다.

[FACT] 비율·품질·서비스 `evaluation_result`는 분자·분모, 제외 건수와 이유, 측정 가능 여부, 원본 evidence reference 및 definition version을 함께 기록합니다. 원본 payload를 복사하지 않으며 `unknown`, `stale`, `unmapped` feedback 또는 누락된 필수 근거를 0·반응 없음·암묵적 수용·`pass`로 변환하지 않고 `not_measurable` 또는 해당 제외 사유로 보존합니다.

[FACT] 모든 `hard_gate`는 같은 `evaluation_snapshot`의 `as_of_at` 및 source high-watermark 아래에 있는 evidence만 읽습니다. cutoff 뒤에 저장된 evidence는 기존 Gate 결과를 바꾸지 않고 새 사용자 요청 evaluation에서만 반영합니다. cutoff 안에서 Gate 위반이 확인되면 표본 부족과 관계없이 `fail`이며, 필수 evidence의 범위·연결·완전성이 부족하거나 불명확하면 `not_measurable`입니다. 정의된 필수 evidence 범위가 충족되고 위반이 없을 때만 `pass`입니다.

| Metric / result | Read-only source lineage | Required separation |
| --- | --- | --- |
| Asia/Seoul 일별 고유 신규 후보 | 해당 일자의 `batch_candidate`와 source `article` | 고유 후보 수와 AI invocation/retry를 합치지 않음 |
| 실제 AI 요청·retry·usage | `ai_analysis_attempt.invocation_started`와 `external_attempt_evidence` | 호출 전 `prepared` 및 후보 수와 합치지 않음 |
| 결과 준비 시간 | `scheduled_batch`의 예정 시작 시각과 final `selection_result` 고정 시각 | 실제 Prepare 시작과 구분하며 정상 신규 0건·미실행 예정 batch를 준비시간 분모에서 제외하지 않음 |
| Discord 정시 수락 | source `scheduled_batch` 예정 전달 시각, 그 batch의 final 결과가 요구한 current article·결과 요약 또는 processing failure notice의 필요한 physical mapping과 `discord_2xx` evidence | 정상 신규 0건은 분모에서 제외. `processing_delayed_full_result`, Discord 미수락 recovery, receipt confirmation은 정시 수락 분자·분모에 넣지 않으며 recipient-observed receipt로 원래 2XX·정시 수락 시각을 만들지 않음 |
| Pipeline 지연 | source `scheduled_batch`의 예정 시작 시각과 그 batch final 결과의 최초 `discord_2xx` acceptance evidence 시각 | 목표 시각 뒤 `processing_delayed_full_result`도 원래 batch pipeline 지연에는 포함하되, 과거 Discord 미수락 recovery·receipt confirmation은 포함하지 않음 |
| 복구 지연·receipt 무응답 | 원래 `scheduled_batch` 예정 전달 시각, recovery delivery의 `discord_2xx` evidence, `recovery_event` | 원래 최신성·원래 batch 수량·현재 batch pipeline 지연을 바꾸지 않으며, `confirmation_no_response`를 `못 받음`·자동 recovery로 변환하지 않음 |
| batch review coverage·암묵적 수용·feedback 미관측 | batch 대표 mapping·전달 mapping·각 source `batch_item`·recipient-observed evidence 및 snapshot cutoff 아래 `discord_gateway_event`·`rest_state_snapshot`·reconciliation reference | review coverage는 delivery set 범위로 읽되, 암묵적 수용은 source batch item당 한 번만 계산. mutable `feedback_state` 현재값이나 review 없는 전달 성공을 암묵적 수용으로 계산하지 않음 |
| RSS 충실도·홍보성 오선정/누락·중대한 근거 밖 사실 | 선택 표본의 `quality_review`와 그 source `article_analysis`·`rss_observation`·`candidate_selection` reference | 표본별 판정과 집계 `quality_metric`을 혼동하지 않음 |
| 비용 Hard Gate | 모든 적용 범위를 덮는 `cost_safety_evidence`와 사용자 월별 billing 확인 | 근거 범위 하나라도 불명·누락이면 0원·`pass`로 추정하지 않음 |

[FACT] 위 lineage는 평가할 때만 읽어 `evaluation_result`의 계산값·분자·분모·제외 이유와 source reference로 보존합니다. 후보·attempt·feedback·recovery마다 지속적인 metric 원본 record를 새로 만들지 않습니다.

| Hard Gate | Read-only evidence and permitted exception | `fail` / `not_measurable` boundary |
| --- | --- | --- |
| 추가 월 비용·유료 호출·유료 자원 사용 0건 | 모든 적용 범위를 덮는 `cost_safety_evidence`, 필요한 `external_attempt_evidence`, 사용자 월별 billing 확인 | 유료 사용·비용 위반은 `fail`; 적용 범위·월별 billing·필수 근거 누락은 0원·`pass` 추정 대신 `not_measurable` |
| 미처리 후보 조용한 제외 0건 | `batch_candidate`, `article_analysis`, 명시적 terminal 처리, `selection_result`·`candidate_selection` 또는 `processing_failure_notice`의 원인·미처리 수 | 후보가 완료·명시적 terminal·선정 결정·실패 notice 어느 곳에도 설명 없이 사라지면 `fail`; 후보 처리 근거가 누락되면 `not_measurable` |
| 의도되지 않은 동일 기사 중복 발송 0건 | exact `article` identity, `batch_item`, delivery segment의 article message mapping, 필요한 message ID를 동반한 `discord_2xx` 또는 sandbox에서 exact original mapping이 검증된 `discord_message_reconciliation` acceptance evidence, `recovery_event`의 승인된 1회 즉시 재전송 예외 | batch 대표 message mapping은 기사 중복 수에 넣지 않으며, 명시적 `immediate_resend_authorized` 예외 밖의 같은 article 수락 반복은 `fail`; mapping·수락 근거 불완전은 `not_measurable` |
| AI 실패의 신규 0건 오기록 0건 | `batch_candidate`, `ai_analysis_attempt`, `article_analysis`, final `selection_result`와 `selection_not_run_reason` | 신규 후보 또는 AI 실패가 있는데 `normal_no_new_candidates`로 기록하면 `fail`; 후보·AI·final result 연결이 불완전하면 `not_measurable` |
| Discord 미수락의 성공 기록 0건 | `delivery_attempt`, response `external_attempt_evidence`, physical `discord_message_mapping`, `acceptance_evidence` | 필요한 message ID를 동반한 `discord_2xx` 또는 sandbox에서 원래 attempt·message mapping·payload/configuration version의 exact relation이 검증된 `discord_message_reconciliation` 없이 `accepted`로 기록하면 `fail`; 후자는 원래 `discord_2xx`·수락 시각·정시 수락 지표를 만들지 않으며, recipient-observed receipt도 원래 2XX·`accepted`를 만들지 않음; 필수 mapping·수락 근거 부족은 `not_measurable` |
| 중대한 RSS 근거 밖 사실 생성 0건 | 선택 표본의 `quality_review`와 source `article_analysis`·`rss_observation` reference | 검토에서 중대한 근거 밖 사실이 확인되면 `fail`; 필요한 표본·검토 근거가 부족하면 `not_measurable` |

[FACT] 이 표는 평가 시에만 여섯 `hard_gate` 결과가 참조하는 원본과 판정 경계를 정의합니다. 별도 Hard Gate entity, 상시 metric 원본 record 또는 새로운 result kind를 만들지 않습니다.

[FACT] `metric_definition_version`은 산식·분모·제외 규칙의 변경을 구분합니다. 새 정의를 적용한 재평가가 필요하면 기존 snapshot을 덮어쓰지 않고 새 evaluation work item/attempt와 `evaluation_snapshot`을 만듭니다.

[FACT] 정의가 같아도 late Gateway event·REST snapshot·reconciliation 결과 또는 새 evidence를 반영하려면 사용자의 새 evaluation 요청으로 별도 work item/attempt와 evaluation snapshot을 만듭니다. MVP-A는 late observation만으로 자동 재평가하지 않으며, 이전 snapshot의 result·분자·분모·제외 이유는 수정하지 않습니다.

[FACT] `operational_event`는 비용 차단·수동 pause·backup 실패·restore 검증 대기처럼 사람이 확인해야 할 운영 사건을 기록하며, 그 사건의 개수·비율·지연을 나타내는 metric과 분리합니다. alert 발송 여부는 Hard Gate 통과 근거가 아닙니다.

[FACT] 검증 기간 scope의 `final_interpretation` 결과는 같은 snapshot의 최소 표본, 여섯 Hard Gate, 승인된 품질 목표와 서비스 목표 결과를 서로 덮어쓰지 않고 함께 참조합니다. 표본 부족은 `판정 불충분`이며 확인된 Hard Gate 위반을 숨기지 않습니다. 최소 표본 충족만으로 품질 통과가 되지 않고, 모든 Gate·품질·서비스 조건을 실제로 충족했을 때만 MVP-A 품질 검증 통과 후보가 됩니다. 품질 지표 미달 또는 Hard Gate 위반은 원인·추가 검증 대상으로 기록하며 프로젝트 자동 종료로 변환하지 않습니다.

[FACT] MVP-A에서 원본 행이 이용 가능한 동안 같은 scope·cutoff·definition·input manifest scheme으로 새 evaluation을 실행해 source별 input row 수·digest와 결과를 대조할 수 있습니다. 이 대조도 새 work attempt·immutable snapshot을 만들며 기존 결과를 update하지 않습니다. MVP-B retention 뒤에도 확정된 `evaluation_snapshot`과 연결된 `evaluation_result`의 집계값·definition version·입력 manifest·integrity 결과는 보존합니다. 원본 행이 정리된 뒤 row-level 재계산 가능 여부는 snapshot의 재현 가능성과 구분해 기록합니다.

[UNKNOWN] input manifest digest의 알고리즘·canonical serialization·정렬 규칙, source kind의 실제 물리 표현, 검증 기간의 정확한 시작·종료 선택, `quality_review`의 검토자 식별 방식, 평가 표본 추출·검토 rubric·보고 형식, 확정된 Gate·표본·품질·서비스 기준의 실제 계산 구현, metric 보존 기간, alert/dashboard 도구와 retention 후 row-level 재계산 가능성은 후속 검증에서 확정합니다.

### DDI-09 — Candidate 처리 상태와 batch 완료 기준

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-09를 승인했습니다. `batch_candidate`의 처리 상태, `article_analysis`의 분석 상태, `selection_result`의 고정 결과, `delivery_set`의 전달 상태는 서로 다른 축으로 보존합니다. 하나의 전역 batch 상태가 이들을 덮어쓰지 않습니다.

[FACT] `batch_candidate`의 논리 처리 범주는 분석 대기·진행·안전한 재시도 대기, 분석 완료, 최신성 초과, 시간 검증 불가 및 분석 완료 불가능을 서로 구분합니다. 최신성 초과·시간 검증 불가는 명시적 terminal 처리이지만 AI 실패가 아닙니다.

[FACT] 개별 `ai_analysis_attempt`의 timeout·rate limit·provider 오류·응답 검증 실패는 해당 attempt의 결과이며, 그 자체만으로 batch의 전체 선정 불가능을 확정하지 않습니다. 승인된 재시도·비용·provider 정책에 따라 아직 완료 가능하면 후보는 처리 중 또는 재시도 대기로 유지하고 기사 목록을 release하지 않습니다.

[FACT] `selection_result`는 하나의 scheduled batch에 하나의 immutable final 결과만 가집니다. 모든 AI 분석 대상 후보가 완료되고 선정이 끝난 경우에만 `full_selection`을 고정합니다. quota 소진·비용 차단·영구 오류 등 승인된 판정 근거로 전체 선정 완료 불가능이 확정된 경우에만 `processing_failure_notice`를 고정합니다. 목표 시각에 단순히 미완료인 상태에는 final `selection_result`를 만들지 않습니다.

[FACT] 고정된 `processing_failure_notice`는 완료된 정상·저정보 분석이 하나 이상인지에 따라 partial 또는 total processing failure를 구분하고, 유효 신규 후보·처리 완료·미처리 수와 원인별 attempt·비용 근거를 summary에 연결합니다. 아직 재시도가 가능한 미완료는 failure notice가 아니라 처리 중 상태이며 article list를 계속 보류합니다. 정확한 재시도 종료와 전체 선정 불가능 판정은 provider 검증 뒤 정합니다.

[FACT] `selection_result`는 completion 종류와 사용자 표시용 논리 결과를 구분합니다. completion은 `full_selection` 또는 `processing_failure_notice`이며, `full_selection`의 논리 결과는 `article_list`, `selection_summary_no_articles`, `normal_no_new_candidates` 중 하나입니다. `normal_no_new_candidates`는 final result를 남기되 source scheduled batch의 current Discord message를 만들지 않는 깨끗한 정상 0건 결과입니다. 이 결과는 이전 batch의 확인된 recovery를 담은 별도 recovery-only delivery set을 막거나 그 recovery를 source batch 결과로 바꾸지 않습니다. 후보 생성 불가능 입력 오류, 최신성 초과·시간 검증 불가, 저정보, 홍보성 제외와 최대 제한 미선정은 고정 result summary의 수량·사유를 읽는 조합 가능한 display qualifier이며, `input_constrained_result`는 독립적인 completion 또는 현재 기사 결과와 경쟁하지 않습니다.

[FACT] 고정된 `selection_result`는 당시 사용자 표시·delivery가 재사용할 immutable result summary를 소유합니다. summary는 신규 후보, 선정, 최대 제한 미선정, 홍보성 제외, 미처리, 저정보 및 후보 생성 불가능 입력 오류의 수량과 필요한 명시적 terminal 처리 사유를 서로 구분하고, 후보별 `candidate_selection`·`batch_candidate`·`article_analysis`와 합계를 대조합니다. `full_selection`에서는 정상·저정보 분석이 완료된 각 후보가 선정·홍보성 제외·최대 제한 미선정 중 하나의 논리적 `candidate_selection`으로 정확히 한 번 설명되어야 하며, 최신성 초과·시간 검증 불가 후보는 `batch_candidate`의 terminal reason과 summary로 설명하고 선정 판단을 억지로 만들지 않습니다. 이 summary는 후보별 원본 판단을 대체하지 않으며 delivery·Discord mapping·evaluation result에 다시 복사하지 않습니다.

[FACT] `normal_no_new_candidates`는 해당 source scheduled batch의 RSS 수집·입력·처리가 정상이고 신규 후보·후보 생성 불가능 입력 오류·미처리·실패가 모두 0인 경우에만 사용하며 source current Discord message를 만들지 않습니다. 다른 원래 batch의 확인된 recovery 대상 또는 수락 불명확 대상은 이 source batch의 논리 결과 조건이 아니며, 수락 불명확은 recovery-only delivery를 만들지 않습니다. 입력 오류가 있으면 `input_constrained_result` qualifier로 오류 수·처리 수·완전한 Top 10이 아니라는 경고를 함께 보존합니다. 신규 후보가 있었지만 선정 기사가 0건이거나 입력 오류만 있었던 경우에는 `selection_summary_no_articles`와 필요한 qualifier로 원인별 수량을 보존하고 정상 신규 0건으로 바꾸지 않습니다.

[FACT] `candidate_selection`과 `batch_item`은 실제 선정이 완료된 `full_selection`에만 생성합니다. `processing_failure_notice`에는 partial 또는 total 처리 실패 분류, `selection_not_run_reason`, 처리 완료·미처리 후보 수와 원인별 근거 reference를 기록하고, 후보별 미해결 근거는 `batch_candidate`와 `article_analysis`에 남깁니다. 따라서 일부 분석이 완료됐더라도 `processing_failure_notice`에는 partial article list·`candidate_selection`·`batch_item`을 만들지 않습니다. 처리 미완료 후보는 홍보성 제외·최대 제한 미선정·정상 신규 0건으로 변환하지 않습니다.

[FACT] 목표 전달 시각 경과는 batch 처리 실패가 아니라 delivery segment 판단 근거입니다. 목표 시각 뒤에 `full_selection`이 고정되면 원래 scheduled batch의 `processing_delayed_full_result`가 되며, 새 예정 batch를 만들거나 부분 article list를 전달하지 않습니다.

[FACT] RSS observation과 article identity 연결, candidate 생성과 최신성 결과, final `selection_result`·`candidate_selection`·`batch_item` 고정은 각각 하나의 DB transaction으로 보존합니다. finalization transaction은 현재 Prepare lease·fencing token, source 입력·candidate 완료 조건 및 source Prepare에 binding된 configuration snapshot을 같은 commit 안에서 재대조하고, final result·summary·후보별 결정·선정 item과 Prepare 완료를 분리해 남기지 않습니다. commit 전 중단이면 final 결과를 남기지 않고 안전한 내부 재claim이 현재 상태를 다시 계산하며, commit 뒤 중단이면 후속 실행은 저장된 immutable result만 읽고 selection을 재실행하지 않습니다. Delivery work는 이 commit 뒤에만 result를 읽어 release하며 selection transaction 안에서 delivery set·Discord attempt를 만들지 않습니다. AI·Discord 외부 효과의 transaction 경계는 DDI-05와 DDI-03을 따릅니다.

[UNKNOWN] 실제 enum 명칭, timeout·retry 횟수, attempt 실패 뒤 재시도 가능 판정과 전체 선정 불가능 판정의 provider별 세부 기준, lease 기간, DB isolation·constraint 구현과 result 문구·Discord payload는 상세 설계 및 sandbox 검증에서 확정합니다.

### DDI-10 — Missing article과 delivery receipt interaction

[FACT] 사용자는 2026-09-02 Asia/Seoul에 DDI-10을 승인했고, MIN-01·MIN-07에서 interaction·feedback·recovery 저장을 최소화했습니다. `interaction_request`는 Discord 원본 interaction/event를 참조하는 idempotent 업무 request이며, `missing_article_case`는 누락 기사 조회 결과를 보존합니다. 수신 확인과 recovery 진행은 `recovery_case`와 `recovery_event`가 담당하고 원본 Gateway event는 append-only로 보존합니다.

[FACT] `missing_article_case`는 제출된 exact Raw RSS `link` 원값, 입력 검증, `article`·RSS observation·batch 처리 이력 lookup 결과와 답변 근거를 보존합니다. MVP-A 결과는 `found_in_collection`, `not_collected`, `invalid_reference`로 구분합니다. `retention_purged`는 MVP-A에서 생성하지 않으며, MVP-B retention gate 뒤 exact link의 `article_identity_tombstone`이 남은 경우에만 가능한 미래 결과입니다. Atom id·title·유사 URL로 대체 조회하지 않고, 어느 결과도 RSS 재수집이나 과거 observation 재검증을 시작하지 않습니다.

[FACT] 실제 이력상 제외·최대 제한 미선정 사유를 회신한 `missing_article_case`에만 `추천해야 했다` reaction 입력을 연결할 수 있습니다. 별도 feedback 엔터티를 만들지 않고 `feedback_state.feedback_kind = missing_article_recommendation`이 원래 case·article·회신 근거·승인 사용자와 현재 `present`/`absent` 상태를 연결합니다. reaction 추가·제거·중복 이력은 `discord_gateway_event`에 남습니다.

[FACT] 이미 전달됨, 입력 오류, AI 미처리, Discord 전달 상태, 수집 기록상 누락 또는 원인 미확정 회신에는 `추천해야 했다` 입력을 제공하지 않습니다. 제출 자체·reaction 부재·다른 사용자나 bot의 reaction은 중요 기사 판정·동의·비중요 또는 recall 결과로 해석하지 않습니다.

[FACT] 현재 유효한 `추천해야 했다` feedback이 연결된 수집 article만 후보 기반 중요 기사 recall 분모 후보가 됩니다. 평가 시점까지 Discord 2XX 수락 또는 유효한 recipient-observed receipt가 확인된 기사는 분자로, 미수락·미전달 기사는 원인별 recall 누락으로 분류합니다. `not_collected`는 별도 수집 기록상 누락 지표이며 후보 recall 분모에 포함하지 않습니다.

[FACT] `recovery_case`는 독립 식별자를 가지며, 하나의 원래 source `selection_result`, 원래 Discord delivery target reference와 승인 recipient reference가 이루는 immutable receipt scope의 조합에 중복 생성되지 않는 논리적 유일성 경계를 가집니다. receipt scope는 합성 문자열이나 별도 canonical entity가 아니며, 세 논리 값을 분리해 같은 조합인지 판단하는 범위입니다. source selection result가 원래 `scheduled_batch`를 결정하므로 batch identity를 별도 key로 중복 소유하지 않습니다. 원래 delivery attempt·message mapping·segment와 article은 case를 새로 나누는 기준이 아니라 관련 event와 acceptance evidence가 참조하는 전달 근거입니다. 실제 PK, column·reference 구성과 uniqueness constraint는 [UNKNOWN]입니다.

[FACT] 하나의 delivery set에 서로 다른 source selection result의 current·recovery segment가 함께 있으면 source별 recovery case를 분리합니다. 반대로 같은 source의 physical attempt·message가 여러 개여도 case를 기사·attempt·message마다 중복 생성하지 않습니다. 수신 확인, 즉시 재전송, 다음 정규 batch offer와 추가 복구는 같은 case에서 진행합니다.

[FACT] `recovery_event`는 같은 case 안에서 `receipt_confirmation_requested`, `user_received`, `user_not_received`, `confirmation_no_response`, `immediate_resend_authorized`, `recovery_offered`, `recovery_selected`, `additional_recovery_selected`, `delivery_prepared`, `completed`, `conflicting_receipt`를 구분하는 append-only event입니다. event는 원래 interaction 및 실제 delivery set·segment·attempt를 참조하며 해당 전달 결과를 복사하지 않습니다. `recovery_offered`는 원래 batch당 한 번의 offer delivery intent로서 target regular delivery mapping을 참조하고, 사용자에게 실제 표시된 성공은 그 mapping의 `discord_2xx` evidence와 message ID로만 판단합니다.

[FACT] 별도 `recovery_case_item` 또는 `recovery_event_item` 논리 record는 만들지 않습니다. recovery case는 source selection result와 receipt scope의 aggregate이며, item별 전달 상태는 원래 `discord_message_item`·physical mapping·`acceptance_evidence`에서 계산합니다. 명시적으로 미수락이고 같은 item scope의 유효한 recipient-observed receipt가 없는 item만 recovery 후보가 됩니다. 실제 재전송 대상으로 고정된 subset은 후속 `delivery_segment`와 기존 `batch_item`의 관계에 한 번만 기록합니다. recovery event는 그 delivery segment를 참조하며 기사·AI 결과·item 목록을 다시 복사하지 않습니다.

[FACT] `받음`/`못 받음` event는 원래 delivery attempt·message·batch·article 범위와 승인 사용자를 모두 정확히 연결할 수 있을 때만 유효합니다. `받음`은 `user_received_confirmation` 출처의 acceptance evidence를 추가합니다. `못 받음`은 `user_not_received` 원본 interaction과 recovery case 상태를 추가해 1회 즉시 재전송 권한만 만들며, 원래 Discord 서버 전달을 `explicitly_not_accepted`로 바꾸거나 그 자체로 `confirmed_non_acceptance_recovery` backlog에 편입하지 않습니다. Discord 2XX·Gateway/interaction 기반 recipient observation·명시적 사용자 수신·미수신 확인의 evidence 출처는 분리 보존합니다.

[FACT] mapping 불가·모호·승인되지 않은 사용자의 interaction은 원본 request와 거부 이유만 보존하고 전달 상태를 추정하거나 resend하지 않습니다. 동일 interaction identity의 재전달은 업무 결과에 한 번만 적용합니다.

[FACT] `못 받음`의 1회 즉시 재전송 예외는 원래 message/article-or-batch mapping, 승인 사용자, explicit missing-receipt exception의 논리 중복 방지 key를 가진 `immediate_resend_authorized` event로 제한합니다. 같은 key의 event 또는 연결된 delivery가 이미 있으면 새 Discord 호출을 만들지 않습니다. 재전송은 저장된 `selection_result`와 `batch_item`만 재사용하며 RSS·AI·selection을 재실행하지 않습니다.

[FACT] 수락 불명확 attempt의 `confirmation_due_at`은 같은 원래 delivery scope에서 불명확한 physical attempt 중 마지막 `invocation_started_at + 1시간`입니다. source observation 시각이 이 due 시각 이하인 Discord 2XX 수락·direct message proof·recipient-observed receipt·명시적 사용자 수신 근거는 1시간 내 근거로 처리합니다. due 시각에 Recovery가 confirmation work를 claim하더라도 외부 호출 직전에 위 근거를 다시 대조하며, 모두 없을 때만 원래 예정 batch당 하나의 `receipt_confirmation_requested` event와 confirmation delivery를 만듭니다. 외부 confirmation invocation이 시작된 뒤 늦게 도착한 근거는 원래 case에 보존하지만 이미 시작한 confirmation 호출을 취소·재호출하거나 기사 resend를 만들지 않습니다. 확인 message 자체도 별도 delivery attempt로 기록하며, 발송 사실만으로 원래 전달의 수락·수신을 추정하지 않습니다.

[FACT] `받음`은 `user_received_confirmation`으로 기록하고 재전송하지 않지만, 원래 Discord 서버 수락 시각이나 정시 수락 근거를 생성·추정하지 않습니다. `못 받음`은 승인된 1회 즉시 재전송 예외를 만들며, 그 재전송이 Discord 2XX 수락 또는 유효한 recipient-observed receipt를 얻으면 backlog를 만들지 않습니다. 그 재전송 attempt 자체가 명시적으로 미수락이면 그 실제 item subset만 `confirmed_non_acceptance_recovery` backlog 후보가 되며, 다시 수락 불명확하면 같은 원래 batch에 확인 message·자동 재전송·자동 backlog 편입을 반복하지 않습니다.

[FACT] 확인 요청이 다음 성공 정규 batch까지 무응답이면 `confirmation_no_response` event를 기록합니다. recovery offer는 failure notice·receipt confirmation·processing-delayed full result가 아닌 다음 scheduled regular delivery set의 offer 표시 physical mapping에만 연결하며, 그 mapping의 `discord_2xx` evidence와 message ID가 있을 때만 사용자에게 실제 표시된 성공으로 판단합니다. 같은 recovery case에는 이 mapping을 참조하는 `recovery_offered` offer delivery intent를 한 번만 허용합니다. offer invocation의 응답이 유실되거나 수락 불명확이면 intent와 해당 delivery evidence를 보존하고 다음 batch에 자동으로 재첨부·재발송하지 않습니다. 승인 사용자의 명시적 `recovery_selected` event가 있을 때만 저장 결과를 재전송하며, 무응답이면 수락 불명확을 유지하고 추가 확인·자동 복구를 하지 않습니다.

[FACT] 확인된 미수락 backlog는 다음 성공 정규 발송에서 가장 오래된 원래 batch의 실제 미수락 기사 최대 10개를 현재 기사 최대 10개와 분리해 총 최대 20개까지 제공합니다. 남은 대기 수와 원래 batch를 보존하고, 승인 사용자의 `추가 복구` 선택마다 같은 가장 오래된 원래 batch의 남은 기사 최대 10개만 원래 순서로 재사용합니다. 서로 다른 원래 batch, 이미 수락된 기사 및 처리 지연 full result를 섞지 않습니다.

[FACT] 하나의 delivery scope에 유효한 `받음`과 `못 받음`, 또는 유효한 batch ✅ receipt와 `못 받음`이 상충하고 순서·최신성을 안전하게 판단할 수 없으면 `conflicting_receipt` event와 case 상태로 보존합니다. source selection result가 같아도 delivery scope가 다른 원래 전달·recovery 전달은 상충으로 합치지 않습니다. 상충 scope가 가리키는 item은 새 resend·기존 재전송 취소·품질 feedback·batch review·암묵적 수용 계산의 근거가 아니며, 이미 생성된 event·evidence·재전송 attempt는 삭제하거나 되돌리지 않습니다. 같은 delivery set의 다른 비상충 item은 독립된 근거로 계속 평가할 수 있습니다.

[FACT] 명시적 Discord 미수락 evidence와 같은 item scope의 유효한 recipient-observed receipt는 `conflicting_receipt`가 아닙니다. 전자는 Discord server 오류·수락 상태로, 후자는 실제 수신 관찰 근거로 각각 보존합니다. receipt가 존재하면 해당 item의 자동 recovery 후보만 제외하며, server 미수락을 성공 전달·`discord_2xx`·정시 수락으로 바꾸거나 오류 지표에서 제거하지 않습니다.

[UNKNOWN] `delivery_segment`와 선택된 `batch_item` subset 관계의 물리 표현은 실제 schema 설계에서 확정합니다. 실제 command·reaction 이름, parameter, interaction transport, 확인·추가 복구 UI, 응답 문구 및 MVP-B `retention_purged`에 대한 사용자 UX, 상충 상태의 운영 해소 절차와 CronJob 기동 오차는 sandbox 및 후속 UX 설계에서 확정합니다.

## Decision Review Register

| ID | Decision | Draft status | Next review |
| --- | --- | --- | --- |
| DDI-01 | Raw RSS snapshot, observation, article identity 분리 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-02 | batch 후보·AI 정리 기사·선정 기사 관계 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-03 | Discord delivery set·segment·수락 근거 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-04 | Gateway event·REST snapshot·feedback projection | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-05 | work claim·lease·불명확 외부 효과 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-06 | configuration·cost·backup/restore 운영 증거 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-07 | MVP-A Retention과 MVP-B lifecycle 경계 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-08 | Typed evaluation result·immutable snapshot·Hard Gate 판정 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-09 | Candidate 처리 상태·final selection·failure notice 경계 | [FACT] Approved — 2026-09-02 | 완료 |
| DDI-10 | Missing article·receipt interaction·1회 resend 근거 | [FACT] Approved — 2026-09-02 | 완료 |

### Consolidation Review Register

| ID | Approved consolidation | Status | Detailed review |
| --- | --- | --- | --- |
| MIN-01 | Recovery 세부 record를 `recovery_case`·`recovery_event`로 통합 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-02 |
| MIN-02 | 평가 실행을 work로 통합하고 결과를 typed `evaluation_result`로 통합 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-02 |
| MIN-03 | 설정 snapshot·contract check·비용 evidence·운영 활성화 이력을 분리하고 재사용 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-03 |
| MIN-04 | append-only response·usage·limit evidence와 구조화된 AI 분석 결과를 분리 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-03 |
| MIN-05 | 현재 work 상태·lease와 append-only 실제 attempt 이력을 분리 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-03 |
| MIN-06 | AI intent를 `ai_analysis_attempt.prepared` lifecycle로 통합하고 retry attempt를 분리 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-03 |
| MIN-07 | 제한된 feedback kind의 현재 projection과 raw event 이력을 분리 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-03 |
| MIN-08 | article·analysis·batch item·delivery 간 canonical owner와 reference-only 원칙 적용 | [FACT] Applied — 2026-09-02 | [FACT] 상세 승인 완료 — 2026-09-03 |

[FACT] 2026-09-04 세부 정합성·요구사항 추적성 검토에서 논리 데이터 경계와 Requirements 보완 항목 `VR-012`~`VR-019`가 항목별 승인되었습니다. Workflow 6 승인 기준선 91개와 Workflow 8 추적성 보완 8개를 구분하며, 현재 `requirements.md`에는 총 99개 요구사항이 있습니다.

## Deferred Validation

- [UNKNOWN] GeekNews link 장기 안정성·재사용, ETag/Last-Modified, polling 허용 범위와 `published` 변경 동작
- [UNKNOWN] 단일 무료 AI provider의 한국어 품질, quota, rate limit, 비용 차단, 오류 분류와 100건/일 처리 가능성
- [UNKNOWN] Discord 수락 증거, message 분할, Gateway resume, REST reconciliation, 권한, rate limit 및 interaction transport
- [UNKNOWN] K3s StorageClass, backup 도구·위치, RPO/RTO, CronJob cold start와 clock 오차
- [UNKNOWN] 실제 schema, SQL, migration, ORM, retry/backoff, typed evidence/result의 물리 표현, metric 산식·dashboard/alert, MVP-B retention job·partition·VACUUM
- [UNKNOWN] 전역 keyword 사전·동의어/alias·정규화·분류 체계의 필요성 및 도입 기준

## Stage Boundary

[FACT] 이 문서는 최종 승인된 논리 데이터 모델이며 구현 승인이나 물리 DB schema 승인으로 해석하지 않습니다.

[FACT] 사용자는 2026-09-04 Asia/Seoul에 항목별 결정이 반영된 이 문서 전체를 최종 승인했습니다. `[INFERENCE]`는 설계 이유·추천을 나타내며 개별 결정의 승인 상태는 `Decision Review Register`에서 확인합니다. 남은 `[UNKNOWN]`은 명시된 후속 물리 설계 또는 환경 검증에서 처리합니다.
