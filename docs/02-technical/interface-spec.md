# MVP-A Logical Interface Specification

## Document Status

[FACT] Workflow 단계: 8. Data / Interface Design

[FACT] 상태: Approved logical design — DDI-01~DDI-10, MIN-01~MIN-08 및 세부 정합성 검토를 반영해 2026-09-04 Asia/Seoul에 문서 전체 최종 승인; Workflow 8 단계 종료 Git Review 대기

[FACT] 작성일: 2026-09-02 Asia/Seoul

[FACT] 이 문서는 승인된 [Technical Requirements](requirements.md), [Architecture](architecture.md) 및 [Logical Data Model](data-model.md)의 외부·운영·역할 간 논리 계약을 정의합니다.

[FACT] 이 문서는 실제 HTTP payload, SDK, Discord interaction transport, AI provider/model/prompt, Cron expression, retry/backoff, Kubernetes manifest, backup 도구를 확정하지 않습니다.

## Interface Principles

1. [FACT] PostgreSQL ledger에 기록 가능한 intent와 근거가 없으면 AI·Discord 외부 효과를 시작하지 않습니다.
2. [FACT] Discord Gateway는 feedback 변경 이력의 주 경로이고 REST는 제한된 현재 상태 대조 경로입니다.
3. [FACT] 불명확한 AI·Discord 외부 효과는 자동 재호출·자동 재발송하지 않습니다.
4. [FACT] listener는 RSS 수집·AI 분석·정규 선정·정규 batch 발송을 시작하지 않습니다.
5. [FACT] Recovery는 저장된 결과를 재사용하며, RSS 재수집·AI 재분석·재선정을 자동으로 하지 않습니다.
6. [FACT] interface가 전달하는 canonical business value는 소유 record에 한 번만 저장합니다. 후속 역할은 immutable source ID와 contract/configuration version을 전달하며 같은 기사·AI 결과·평가 근거를 다시 소유하지 않습니다.
7. [FACT] `prepared` attempt, typed evidence/event/result는 논리 contract이며 각각의 subtype이 별도 물리 테이블이어야 한다는 의미가 아닙니다.

## Role Contracts

| Role | Receives | May produce | Must not produce |
| --- | --- | --- | --- |
| Prepare batch role | 예정 batch claim | Raw RSS evidence, candidate processing, AI/selection work, fixed result 및 목표 시각 뒤 완료된 full selection의 delayed delivery work handoff·claim | 목표 시각 뒤 새 예정 batch, Gateway event mutation, selection commit 전 delivery set·attempt |
| Delivery-gate role | target scheduled batch의 delivery release work와 준비된 result·recovery scope | 정시 current/recovery/failure-notice delivery set과 `prepared` delivery attempt 또는 준비 중 관측 | 준비되지 않은 결과를 위한 RSS·AI·선정 시작, 목표 시각 전 attempt |
| Recovery/reconciliation role | 저장된 recovery case/event·reconciliation request 또는 commit된 result의 외부 호출 전 delivery work | 안전한 internal resume, REST snapshot, 확인 request, 저장 결과 recovery, invocation 전 delivery work 재개 | 불명확 외부 효과 자동 재호출·자동 재전송 |
| Gateway listener role | Discord Gateway event | raw event, feedback projection, interaction request와 recovery event | RSS 수집, AI 호출, 정규 선정·정규 발송 |
| Evaluation command | 명시된 evidence scope와 evaluation work claim | 읽기 전용 평가 snapshot·report | 운영 상태·선정 결과 소급 변경 |

[FACT] Prepare와 Delivery-gate는 source `scheduled_batch`가 소유한 Asia/Seoul 일자·slot·예정 시작·예정 전달 시각을 읽습니다. 실제 work attempt 시작, final result 고정, Discord invocation과 acceptance evidence 시각은 이를 덮어쓰지 않습니다. 후보 최신성은 `scheduled_delivery_at`과 RSS observation의 비교 가능한 `published` instant의 차이 `0 ≤ (scheduled_delivery_at - published) ≤ 13시간`으로만 판정하며, 정확히 13시간은 포함합니다. 정확한 timestamp 자료형·정밀도·clock 오차는 [UNKNOWN]입니다.

[FACT] 예정 slot identity는 Asia/Seoul 일자와 오전·오후 slot으로 결정합니다. 목표 전달 시각 전 Prepare는 그 slot을 idempotent하게 등록·claim할 수 있습니다. 목표 전달 시각 뒤 또는 서비스 복구 뒤 발견한 과거 slot의 등록은 historical ledger record만 만들 수 있으며, Prepare work item·work attempt·RSS·AI·selection·Discord 호출을 만들지 않습니다. 이 안전한 기록은 새 예정 batch 실행이 아니므로 Architecture의 목표 시각 뒤 신규 pipeline 금지와 충돌하지 않습니다.

## GeekNews RSS Contract

### Input

[FACT] MVP-A 외부 입력은 GeekNews 공식 RSS 하나입니다.

[FACT] RSS adapter는 endpoint·요청 시각·도메인 fetch 결과를 `rss_fetch`에 기록하고, 안전한 HTTP response 근거는 `external_attempt_evidence`에 연결하며 parsing 전에 Raw body를 `raw_rss_snapshot`으로 보존합니다.

### Output

| Result | Stored output | Downstream effect |
| --- | --- | --- |
| Fetch and parse success | Raw snapshot, entry observations, feed result | 후보 검증으로 진행 |
| Feed parsing failure | fetch/snapshot evidence, feed-level failure | 정상 신규 0건·entry 입력 오류로 변환하지 않음 |
| Entry input failure | observation-level validation evidence | 신규 후보 수에서 제외하고 명시적 입력 제약으로 집계 |
| Existing/duplicate observation | observation-to-article mapping | 새 논리 기사·새 신규 후보를 만들지 않음 |

[FACT] `article`은 exact Raw RSS `link` identity와 최초 observation reference만 소유합니다. RSS title·content·published 등 표시 원값은 `rss_observation`에 남기며, 후속 AI·selection·delivery interface는 source reference를 전달합니다.

[FACT] parsing 가능하고 후보 생성 필수 입력을 만족한 News·Ask·Show 및 source type 미상 entry는 모두 후보 자격을 유지합니다. source type·추정 type, title prefix, 관심 keyword의 존재·부재만으로 candidate interface에서 제외하지 않으며, 최신성·시간 검증과 AI·selection 결과는 그 뒤 별도 contract에서 처리합니다.

[FACT] GeekNews 상세 페이지·외부 원문·검색 결과를 fetch하거나 AI 입력 근거로 사용하지 않습니다.

[UNKNOWN] conditional request, polling 주기, timeout, retry/backoff, link 문법 검증과 HTTP cache contract는 live 검증 뒤 결정합니다.

### Candidate admission contract

[FACT] 유효 observation은 exact Raw RSS `link`로 article identity를 찾거나 만들고, 같은 DB transaction에서 아직 신규 후보로 편입되지 않은 article만 현재 실제 실행 scheduled batch의 `batch_candidate`로 admission합니다. candidate output은 source article·admission observation·source scheduled batch를 참조하며 제목·RSS 시각·AI 결과를 복사하지 않습니다.

[FACT] 하나의 article은 MVP-A에서 최초 candidate admission 하나만 가집니다. 동시·중첩 수집의 경쟁에서 admission에 실패한 observation은 기존 article 재관찰로 보존하며 새 candidate·AI 요청·일별 신규 후보 수를 만들지 않습니다. 이미 후보화된 article은 AI 처리 대기·최신성 terminal 처리·정상 미선정·처리 지연·Discord 수락/미수락/복구 여부와 관계없이 다른 batch의 신규 후보가 되지 않습니다.

[FACT] feed 전체 실패·입력 오류·미실행 slot은 candidate admission을 만들지 않습니다. 따라서 후속 실제 수집에서 처음 유효하게 identity 연결한 article은 그 후속 batch의 최초 후보가 될 수 있으나, 과거 실패·미실행 slot을 소급해 후보화하거나 목표 시각 뒤 pipeline을 시작하지 않습니다. 신규 처리 구간은 Discord 성공 전달 또는 시간 기반 mutable marker가 아니라 이 최초 admission 이력으로만 해석합니다.

[UNKNOWN] uniqueness constraint·lock·isolation과 admission 경쟁의 물리 구현은 DB 상세 설계에서 정합니다.

## Free AI Module Contract

### Preconditions

[FACT] batch role만 AI module을 호출할 수 있습니다.

[FACT] 입력은 저장된 해당 article의 RSS `title`, `content` 또는 `description`에 제한합니다.

[FACT] provider·model·plan·credential·quota·비용 상태가 불명확하거나 유료 가능성이 있으면 호출하지 않습니다.

[FACT] 호출 전 interface는 `ai_analysis_attempt`를 `prepared` 상태로 commit하고 input observation reference, output contract version, source Prepare에 binding된 configuration snapshot 및 비용 안전 근거를 연결해야 합니다. batch 진행 중 새 snapshot이 승인돼도 새 attempt는 이 binding과 다른 provider/model·판단/output contract로 자동 전환하지 않습니다. binding이 없거나 비용·계약 조건을 더는 충족하지 않으면 invocation을 시작하지 않고 후보·batch를 차단 또는 미처리로 유지합니다. 별도 analysis intent record는 만들지 않습니다.

[FACT] `prepared` attempt가 invocation started 전 중단되면 같은 attempt를 안전하게 재개할 수 있습니다. 실제 provider 호출을 시작한 attempt는 prepared로 되돌리지 않으며 retry 가능한 실패 뒤 새 호출을 시도할 때는 새 AI attempt를 prepared로 만듭니다. 이전 attempt·evidence·analysis 결과는 수정하거나 덮어쓰지 않습니다.

### Output boundary

| Output class | Required result |
| --- | --- |
| Normal analysis | 검증 가능한 표시 제목, RSS 근거 범위의 2~3문장 요약, keyword, 포함 추천, 중요도·관심 적합성·홍보성 판단과 RSS 근거·lineage |
| Low information | 후보 자격 유지, `정보 제한`, 검증된 analysis title 또는 RSS title의 출처, RSS 근거 범위의 1문장 이하 또는 승인 문구, 저장 topic link |
| Invalid response | 누락/형식/근거 검증 실패를 정상 결과로 보정하지 않고 원인 기록 |
| Provider or cost failure | quota, rate limit, 인증·설정, timeout, provider 오류, 비용 차단, 불명확 결과를 구분 |

[FACT] 유효 후보의 필요한 AI 처리가 미완료면 article list를 release하지 않습니다.

[FACT] provider 호출 뒤 response·usage·limit의 안전한 공통 근거는 `external_attempt_evidence`에 `evidence_kind`와 schema version으로 기록합니다. 정상 분석값은 `article_analysis`만 소유하며 evidence record가 요약·분류·점수를 복제하지 않습니다.

[FACT] evidence는 append-only입니다. `evidence_kind`는 관측 사실의 종류인 `response`, `usage`, `limit`으로 제한하며 attempt lifecycle state·outcome과 구분합니다. 같은 kind라도 provider별 allowlist와 schema version에 따라 허용 값이 달라질 수 있고, 후속 사실은 기존 row update가 아닌 새 evidence row로 기록합니다.

[FACT] 정상·저정보 `article_analysis` output은 provider 원문 string/JSON blob이 아닌 검증된 구조화 결과이며 정확한 source `ai_analysis_attempt`를 참조합니다. 표시 제목·요약은 text, 중요도·관심 적합성은 numeric value, 홍보성·분석 추천은 controlled code, 판단 근거는 reason code와 필요한 짧은 설명으로 출력합니다. keyword는 analysis별 0개 이상의 `article_analysis_keyword` record로 출력하며, MVP-A에서는 전역 keyword 사전·동의어/alias·정규화를 적용하지 않습니다. 구조 검증 실패·provider/cost failure·external effect uncertain은 analysis output을 만들지 않고 attempt·evidence·candidate 상태로만 보존합니다. 하나의 batch candidate에는 selection-eligible normal 또는 low-information analysis를 최대 하나만 만들며, 새 contract version 또는 사용자 승인 재분석은 MVP-A의 원래 selection input을 변경하지 않습니다.

[FACT] 정상 분석의 summary·keyword·판단 근거는 실제 input `rss_observation`에만 근거를 두며, GeekNews topic link는 AI 출력이 아니라 source `article`의 exact Raw RSS `link` reference로 전달합니다. 저정보 분석은 `low_information`과 `정보 제한`을 출력하고, 표시 제목의 `title_source`를 검증된 analysis title 또는 저장 RSS title로 구분합니다. RSS 근거 범위의 1문장도 충실하게 만들 수 없으면 `RSS 제공 정보가 부족해 상세 요약을 생성하지 못했습니다`를 출력합니다. 누락·형식·근거 검증 실패 응답에 임의 제목·요약·keyword를 보완하지 않습니다.

[UNKNOWN] provider/model/prompt, structured output schema, 오류별 retry/backoff는 sandbox 검증 전 확정하지 않습니다.

## Selection and Delivery Contract

### Selection input/output

[FACT] selection service는 같은 예정 batch의 `batch_candidate`와 후보마다 최대 하나인 selection-eligible 검증 `article_analysis`만 읽습니다. 해당 analysis는 정확한 source `ai_analysis_attempt`까지 추적 가능해야 합니다. 결과로 고정된 `selection_result`, 후보별 `candidate_selection`, 선정된 기사만 담는 `batch_item`을 분리합니다.

[FACT] `selection_result`는 source Prepare에 binding된 configuration snapshot을 직접 참조하여 적용한 판단·output contract version을 한 번 소유합니다. `batch_item`은 source article·analysis 값을 복사하지 않고 `candidate_selection`, `article_analysis`, 표시 순서만 참조하며 output contract는 source selection result에서 상속합니다. delivery interface도 기사·요약을 새 canonical record로 복제하지 않습니다.

[FACT] 미처리 후보를 최대 제한 미선정·홍보성 제외·정상 신규 0건으로 변환하지 않습니다.

[FACT] 정상 또는 저정보 후보 중 홍보성 제외 근거가 충분한 후보를 제외하고, 승인된 중요도 정책에 따라 현재 기사 최대 10개를 선정합니다.

[FACT] 중요도와 관심 적합성은 독립된 analysis input이며, 관심 적합성이 낮거나 관심 주제 밖이라는 사실만으로 후보 자격·선정 가능성을 제거하지 않습니다. 전체 IT 중요도가 높은 후보는 선정 가능성을 유지합니다. `promotional_excluded`는 RSS 근거와 적용 정책상 충분한 판매·가입 유도 또는 과장·자기홍보 근거가 있을 때만 가능하며, source type·회사명·title prefix·keyword 하나 또는 홍보성 판단 불가만으로는 제외하지 않습니다.

[FACT] selection adapter는 모든 분석 대상 후보의 필요한 처리가 완료됐을 때만 `full_selection`을 고정합니다. 실제 선정이 실행된 경우에는 정상·저정보 분석 완료 후보마다 하나의 `candidate_selection`과 선정된 기사만의 `batch_item`을 함께 출력하고, 최신성 초과·시간 검증 불가 후보는 candidate terminal reason과 result summary로만 설명합니다. 개별 AI attempt의 timeout·rate limit·provider 오류만으로 전체 선정 불가능을 확정하지 않습니다.

[FACT] 아직 완료 가능한 AI 대상 후보가 남아 있으면 final selection result를 만들지 않고 article list를 release하지 않습니다. quota 소진·비용 차단·영구 오류 등 승인된 판정 근거로 전체 선정 불가능이 확정된 경우에만 `processing_failure_notice`를 고정하고 `selection_not_run_reason`과 미처리 수를 출력합니다.

[FACT] `processing_failure_notice` output은 정상·저정보 분석 결과가 하나 이상 확정됐는지에 따라 partial 또는 total processing failure를 구분합니다. 두 경우 모두 article list·`candidate_selection`·`batch_item`은 출력하지 않으며, 고정 result summary에서 유효 신규 후보·처리 완료·미처리 수, quota와 rate limit을 구분한 원인 논리 family, 해당 attempt·비용 차단 근거와 유료 전환 없음 표시를 읽습니다. 아직 안전한 재시도가 가능한 상태는 이 output이 아니라 article list 보류 상태이며, provider별 재시도 종료 판정은 [UNKNOWN]입니다.

[FACT] 하나의 scheduled batch에는 하나의 immutable final `selection_result`만 허용합니다. 목표 시각 뒤에 `full_selection`이 고정되면 기존 Prepare pipeline은 selection commit 뒤 별도 delayed delivery release work를 handoff·claim하고, delivery adapter는 그 work를 참조하는 전용 `delivery_set` 안 `processing_delayed_full_result` segment로 처리합니다. selection transaction 안에서는 delivery set·Discord attempt를 만들지 않습니다.

[FACT] selection finalization은 별도 work가 아니라 source scheduled batch의 Prepare work가 수행하는 마지막 내부 DB 단계입니다. 현재 Prepare lease·fencing token을 가진 execution만 하나의 transaction 안에서 RSS 입력 단계 완료, 모든 candidate의 완료·terminal·전체 선정 불가능 조건 및 기존 final result를 재대조할 수 있습니다. 기존 result가 있으면 그대로 재사용하고, 없으면 `selection_result`·result summary·필요한 `candidate_selection`·`batch_item`과 Prepare 완료를 함께 commit합니다. commit 전 중단은 결과 없이 재개하며, commit 뒤 중단은 저장된 result를 다시 계산하지 않습니다. 이 transaction은 delivery set·Discord attempt를 만들지 않고, 별도 delivery adapter가 commit된 result만 읽어 release합니다.

[FACT] `full_selection`의 논리 결과는 `article_list`, `selection_summary_no_articles`, `normal_no_new_candidates` 중 하나입니다. `normal_no_new_candidates`는 해당 source scheduled batch의 RSS 수집·입력·처리가 정상이고 신규 후보·후보 생성 불가능 입력 오류·미처리·실패가 모두 0인 final result이며 source current message를 만들지 않습니다. 다른 원래 batch의 확인된 recovery 대상은 이 결과를 바꾸지 않으며, 수락 불명확 대상은 recovery 대상이 아니므로 recovery-only delivery를 만들지 않습니다. 후보 생성 불가능 입력 오류·최신성 초과 또는 시간 검증 불가·저정보·홍보성 제외·최대 제한 미선정은 고정 result summary의 조합 가능한 display qualifier입니다. `input_constrained_result`는 다른 결과와 경쟁하는 독립 결과가 아니라 입력 오류 수·처리 수·완전한 Top 10이 아니라는 경고를 표시하는 qualifier입니다. 입력 오류가 있거나 신규 후보가 있었지만 선정 기사가 0건이면 `selection_summary_no_articles`와 필요한 qualifier·검증된 원인별 수량 summary를 출력합니다.

[FACT] `selection_result` output은 고정된 result summary로 신규 후보·선정·최대 제한 미선정·홍보성 제외·미처리·저정보·후보 생성 불가능 입력 오류 수량과 필요한 명시적 terminal 처리 사유를 구분합니다. 후보별 source record와 합계를 대조해 만든 이 summary는 표시·delivery에서 재사용하지만, delivery set·Discord mapping·evaluation output에 다시 복사하지 않습니다.

### Delivery segment input/output

[FACT] `selection_result`는 원래 batch의 불변 결과입니다. `delivery_set`은 한 번의 Discord 전달 기회를 묶는 컨테이너이며 자신을 생성한 하나의 delivery release `work_item`을 참조합니다. 같은 logical delivery work는 최대 하나의 delivery set만 만들 수 있습니다. article을 전달하는 각 `delivery_segment`는 하나의 source selection result와 실제 전달할 `batch_item` subset을 참조하며 selection 결과를 복사하거나 Discord 실패 때문에 변경하지 않습니다.

[FACT] 다음 성공 정규 전달의 하나의 `delivery_set`에는 current와 확인된 미수락 recovery segment가 함께 있을 수 있고, 현재 segment 없이 recovery segment만 가진 recovery-only set도 허용합니다. recovery-only set은 그 정규 전달 기회의 source batch가 `normal_no_new_candidates`여도 만들 수 있으나, 그 source batch의 summary·`batch_item`을 포함하거나 recovery source로 바꾸지 않습니다. 처리 지연 full result는 원래 batch의 `full_selection`이 고정되면 전용 `delivery_set`으로 release하며 current 또는 recovery backlog와 같은 delivery set 또는 segment에 섞지 않습니다.

[FACT] 정시 Discord 수락은 source scheduled batch의 final 결과가 목표 시각에 요구한 current article·결과 요약 또는 processing failure notice의 필요한 physical mapping에 필요한 message ID와 `discord_2xx` evidence가 10:00:00 이상 10:01:00 미만 또는 22:00:00 이상 22:01:00 미만일 때만 계산합니다. 정상 신규 0건은 이 분모에서 제외합니다. 목표 시각 뒤의 `processing_delayed_full_result`, 과거 Discord 미수락 recovery와 receipt confirmation은 정시 수락 지표에 넣지 않으며 recipient-observed receipt는 이를 대체하지 않습니다.

[FACT] pipeline 지연은 source scheduled batch의 예정 시작부터 그 batch final 결과의 최초 `discord_2xx` 수락까지이며, 목표 시각 뒤 처리 지연 full result는 원래 batch의 pipeline 지연에 포함합니다. 반면 recovery 수락은 원래 예정 전달 시각부터 실제 recovery 수락까지의 복구 지연으로만 읽으며, 현재 batch의 pipeline 또는 정시 수락을 개선하거나 악화시키지 않습니다.

[FACT] current와 recovery를 함께 표시할 때 delivery adapter는 각 segment의 source `selection_result`에서 원래 batch summary를, 같은 segment의 `batch_item` subset에서 실제 전달 수를 각각 읽어 별도 구간으로 render합니다. recovery 구간은 원래 선정 수와 이번 실제 재전송 수를 모두 구분해 표시하며, current와 recovery의 신규 후보·선정·제외·미처리 수를 합산한 새 summary를 만들지 않습니다. batch 대표 message가 두 구간을 함께 참조하는 경우에도 이는 feedback·receipt 범위만 합친 것이며 source batch summary를 합친 것은 아닙니다.

[FACT] current 전달의 미수락은 원래 segment·attempt·message mapping을 recovery로 이동시키지 않습니다. 저장된 원래 mapping을 근거로 `recovery_case`와 typed `recovery_event`를 만들고, 후속 delivery set의 recovery segment가 원래 selection result와 실제 미수락 item subset을 참조합니다. 수락 불명확은 이 경로에 자동 편입하지 않습니다.

| Segment | Input | Output restriction |
| --- | --- | --- |
| `scheduled_current` | 목표 시각 전에 고정된 현재 selection result | 10:00/22:00보다 이른 Discord attempt 금지 |
| `processing_delayed_full_result` | 목표 시각 뒤 완료된 원래 batch의 고정 결과 | 최대 10개, 전용 delivery set으로 즉시 release; current·recovery backlog와 혼합 금지 |
| `confirmed_non_acceptance_recovery` | 확인된 미수락 원래 selection result | 다음 성공 정규 발송 시 가장 오래된 원래 batch 최대 10개, 현재 최대 10개와 별도 표시 |
| `failure_notice` | partial 또는 total 처리 실패의 고정 result summary | article `batch_item` 0건, 원인·처리 완료·미처리 수와 유료 전환 없음 표시. system notice message의 전달 결과는 selection result와 분리하고 batch review·article feedback·receipt·recovery backlog를 만들지 않음 |
| `receipt_confirmation` | 수락 불명확 attempt의 확인 request | 별도 confirmation delivery이며 article batch item·품질 feedback·batch review와 의미 분리. message 2XX는 원래 전달의 수락·수신이 아니며 정확히 연결된 `받음`/`못 받음`만 기존 recovery case에 적용 |

[FACT] Delivery adapter는 `delivery_attempt`의 `prepared`·`invocation_started` lifecycle, Discord response의 `external_attempt_evidence`, article/batch 대표 message mapping과 acceptance evidence를 분리합니다. 각 delivery attempt는 하나의 delivery set에 속한 실제 Discord invocation입니다. article-bearing mapping만 정확한 segment와 `batch_item` subset을 참조하고, batch 대표 mapping은 segment 하나가 아니라 delivery set 전체의 실제 article scope를 참조합니다.

[FACT] `failure_notice`의 Discord timeout·응답 유실·명시적 미수락은 해당 notice message의 `delivery_attempt`·mapping·acceptance evidence에만 기록합니다. 이 전달 실패는 이미 고정된 AI processing failure를 정상 신규 0건, 처리 성공 또는 notice 전달 성공으로 바꾸지 않으며, Discord가 사용 가능할 때만 사용자에게 failure notice를 표시할 수 있다는 경계를 유지합니다.

[FACT] 유효한 Discord 2XX 응답과 필요한 message ID가 함께 확인되면 해당 physical mapping에 `discord_2xx` acceptance evidence를 추가하고 `accepted`로 기록할 수 있습니다. 응답 유실·message ID 부족은 2XX 수락으로 추정하지 않습니다.

[FACT] non-article failure notice와 receipt confirmation system message의 `discord_2xx` evidence는 해당 message의 전달 수락만 뜻합니다. failure notice의 지원하지 않는 reaction과 confirmation message의 일반 reaction은 raw Gateway event 및 연결 불가 또는 지원하지 않는 mapping 사유만 보존하며, article·batch review·원래 delivery receipt·recovery projection을 update하지 않습니다.

[FACT] Discord message mapping은 source delivery attempt, message ID, article mapping의 source segment 또는 system message reference, 물리 순서, 실제 delivery output/configuration version 및 안전한 payload hash를 보존합니다. 이 physical delivery version은 source selection result의 version과 다를 수 있으나 승인된 Discord 표시·분할·payload 보정만 가능하고 selection·기사 의미·원래 수량 summary를 변경하지 않습니다. article-bearing mapping은 `discord_message_item` association으로 실제 표시한 `batch_item` subset을 연결하며, 같은 segment의 item은 article-bearing mapping 하나에만 연결합니다. batch 대표 mapping은 delivery set의 실제 article scope를 한 번만 참조하고 item별 association을 만들지 않습니다. 실제 전송한 제목·요약·기사 본문을 새 record에 중복 저장하지 않고 source analysis와 delivery contract로 재현합니다.

[FACT] 수락 상태는 `accepted`, `explicitly_not_accepted`, `acceptance_uncertain`, `partially_accepted`, `unattempted`로 구분합니다. 응답 유실 또는 수락 근거 부족은 `acceptance_uncertain`이며 자동 재전송하지 않습니다.

[FACT] 부분 수락에서는 `discord_message_item`이 가리키는 수락된 article을 성공 전달로 유지하고, 나머지를 각 physical mapping의 명시적 미수락 또는 수락 불명확으로 기록합니다. 명시적 미수락 item은 같은 item scope의 유효한 recipient-observed receipt가 없을 때만 recovery 후보가 되며, receipt가 있으면 server 오류 이력은 유지하되 자동 recovery 후보에서는 제외합니다. batch 대표 message는 해당 delivery set에 실제 포함된 article 전체에 연결하며, 정규 current·recovery set과 전용 처리 지연 set의 범위를 섞지 않습니다.

## Discord Gateway and REST Reconciliation Contract

### Gateway input

[FACT] listener는 reaction 추가·삭제, batch review reaction, slash command 및 수신 확인 관련 event의 원본 event를 기록합니다.

[FACT] Gateway 원본 event는 append-only로 보존합니다. 동일 외부 event identity의 재전달은 현재 상태에 한 번만 적용하며, 순서 불명확 또는 event 누락 가능성은 reconciliation request로 처리하고 현재 상태를 추정하지 않습니다.

[FACT] Gateway dispatcher는 subject mapping과 observation 순서를 안전하게 대조할 수 있을 때만 feedback projection을 갱신합니다. 이미 적용한 observation보다 이전임이 확인된 재전달 event는 raw history만 보존하고 state를 되돌리지 않습니다. 순서·누락·mapping이 불명확하면 `present`·`absent`를 만들지 않고 reconciliation 또는 `stale`·`unknown`의 안전한 output으로 연결합니다.

[FACT] event를 처리하려면 승인 사용자, 시스템 message, article/batch mapping 및 허용 reaction을 검증해야 합니다. 검증 실패는 feedback 없음이 아닌 연결 불가/근거 부족으로 기록합니다.

[FACT] 검증된 승인 사용자의 기사별 reaction, batch 대표 message의 ✅, 명시적 `받음`은 source Gateway/interaction event를 참조하는 append-only recipient-observed receipt evidence가 될 수 있습니다. batch ✅ evidence는 같은 delivery set의 실제 article 전체를 한 번만 가리키며 article별 evidence row를 만들지 않습니다. 정규 current·recovery set과 전용 처리 지연 set의 item 범위는 함께 가리키지 않습니다. 이 evidence는 원래 Discord 2XX 수락 시각을 소급 생성하지 않습니다.

### REST reconciliation

[FACT] REST는 새 Gateway 연결, DB 복구, Gateway event 기록 실패, feedback 지표 계산 직전에만 PostgreSQL reconciliation request를 근거로 호출합니다.

[FACT] 이 REST reconciliation은 feedback current state 전용입니다. `acceptance_evidence`, delivery acceptance status와 `recovery_event`를 갱신하는 delivery acceptance resolution과 같은 request·scope·REST 결과를 사용하지 않습니다.

[FACT] reconciliation request는 내부 기록이므로 Discord outbound gate가 닫힌 동안에도 남길 수 있지만, REST adapter는 적용 configuration snapshot, Discord contract check 및 outbound gate가 모두 허용될 때만 HTTP 호출을 시작합니다. 차단·pause·비용 또는 contract 미확인·DB/restore 신뢰 불명에서는 REST attempt를 만들지 않고 request의 내부 차단·대기 결과와 기존 feedback 불확정 상태만 보존합니다.

[FACT] REST adapter는 HTTP 호출 전 exact reconciliation scope와 적용 configuration/contract boundary의 `work_item`을 claim합니다. 같은 scope의 다른 trigger가 유효 lease·완료·차단 또는 `external_effect_uncertain` work를 이미 가리키면 새 REST domain attempt·HTTP 호출을 만들지 않습니다. gate 재개 뒤에는 외부 호출 전 중단된 같은 work만 다시 claim할 수 있고, `invocation_started` 뒤 응답 유실은 자동 재호출하지 않습니다.

[FACT] 범위는 시스템이 mapping한 message, 승인 사용자, 허용 reaction으로 제한합니다.

[FACT] REST 결과는 `rest_state_snapshot`으로 저장하며 Gateway event를 삭제하거나 수정하지 않습니다. feedback 현재 상태는 `present`, `absent`, `stale`, `unknown`, `unmapped`으로 구분하고, `absent`는 현재 reaction 부재의 확인 근거가 있을 때만 사용합니다.

[FACT] REST adapter는 snapshot의 observation 시점·범위와 subject mapping을 기준으로 feedback projection 적용 여부를 판단합니다. 이미 적용한 observation보다 이전임이 확인된 snapshot은 current state를 되돌리지 않으며, 적용 불가·순서 불명확·대조 실패는 안전한 비확정 state와 사유로 남깁니다. feedback reconciliation은 `acceptance_evidence`, `recovery_event`, `conflicting_receipt` 또는 기존 Discord delivery 결과를 update하지 않습니다. sandbox가 original attempt·message mapping·payload/configuration version의 exact relation을 검증한 direct message proof만 별도 acceptance-resolution work에서 `discord_message_reconciliation` evidence로 기록할 수 있으며, 일반 REST snapshot·제목 유사성·시간 추정은 이 evidence를 만들 수 없습니다.

[FACT] Gateway feedback event와 REST 관측이 모두 없는 mapped subject에는 feedback state row를 만들지 않으며 조회상 `not_observed`로만 해석합니다. 이는 `absent`, review 미완료, Discord 미수락, 사용자 미수신을 뜻하지 않습니다. REST가 현재 reaction 부재를 확인한 경우에만 state row를 만들거나 `absent`로 update합니다.

[FACT] REST 실패·message 삭제·권한 부족·mapping 실패의 `stale`, `unknown`, `unmapped` 상태는 reaction 없음·검토 미완료·암묵적 수용으로 추정하지 않고 관련 현재 상태 지표에서 제외합니다.

[FACT] 실제 REST 호출 뒤 rate limit·권한 오류·timeout·응답 유실은 해당 Discord domain attempt와 allowlist된 `external_attempt_evidence`에만 원인으로 기록합니다. 이는 무료 quota 소진·비용 0원·feedback 부재 또는 자동 재시도 허용으로 추정하지 않으며, exact retry/backoff는 [UNKNOWN]입니다.

[UNKNOWN] Gateway/REST 권한, resume, pagination, rate limit, retry/backoff, 실제 event identifiers는 Discord sandbox에서 검증합니다.

## Interaction and Feedback Contract

| Interaction | Input validation | Stored result |
| --- | --- | --- |
| Article negative reaction | article message mapping, 승인 사용자, 😕/🚫/📣 | raw event, 현재 article feedback state, 해당 mapping의 recipient-observed receipt evidence |
| Batch review reaction | 대표 message mapping, 승인 사용자, ✅ | review complete/current cancellation state, delivery-set 단위 recipient-observed receipt evidence와 대상 article set |
| Missing article command | 비어 있지 않은 하나의 GeekNews topic `link` 원값 | `missing_article_case`, exact link 이력 lookup, 답변 근거 |
| `추천해야 했다` reaction | 제외·최대 제한 미선정 회신에 연결된 case·article·승인 사용자 | raw event, `feedback_state`의 `missing_article_recommendation` 현재 상태, recall 근거 |
| Receipt confirmation | 원래 attempt·message·batch·article 및 승인 사용자와의 정확한 연결 | idempotent interaction, typed `recovery_event`, 출처 분리 acceptance evidence |
| Additional recovery selection | 원래 batch의 one-time offer 또는 가장 오래된 확인 미수락 backlog·승인 사용자 | 같은 `recovery_case`의 selection event와 저장 결과 기반 최대 10개 delivery 준비 |

[FACT] link click은 검토 완료·수락·유용함 증거가 아닙니다.

[FACT] `못 받음`은 정확히 연결된 승인 사용자 응답일 때만 1회 즉시 재전송 예외를 만듭니다.

[FACT] Missing article adapter는 exact Raw RSS `link` 원값으로만 저장된 article 이력을 조회합니다. MVP-A output은 `found_in_collection`, `not_collected`, `invalid_reference`이며, Atom id·title·유사 URL 대체, RSS 재수집 및 과거 observation 재검증을 수행하지 않습니다. `retention_purged`는 MVP-A output이 아니라 MVP-B retention gate 뒤 exact link의 `article_identity_tombstone`이 남았을 때만 가능한 reserved output입니다.

[FACT] `추천해야 했다` reaction 입력은 실제 이력상 제외·최대 제한 미선정 사유를 회신한 case에만 제공합니다. 별도 feedback entity 없이 `feedback_state.feedback_kind = missing_article_recommendation`이 승인 사용자·case·article·회신 근거와 현재 상태를 연결합니다. reaction 추가·제거·중복 이력은 raw event에 남기며, 이미 전달됨·입력/AI 미처리·Discord 상태·수집 기록상 누락·원인 미확정에는 제공하거나 recall 근거로 사용하지 않습니다.

[FACT] `feedback_kind`는 article negative, batch review, missing article recommendation의 제한된 business 의미이며 runtime 임의값이 아닙니다. 정확한 reaction은 `reaction_code`로 구분합니다. batch review는 실제 article `batch_item`을 가진 delivery set의 batch 대표 message mapping에만 적용하며, failure notice·receipt confirmation system message에는 적용하지 않습니다. batch review의 현재 상태는 허용된 mapping을 subject로 하는 feedback state에서만 조회하며 delivery set·segment·scheduled batch에 `feedback_received` 상태를 복사하지 않습니다.

[FACT] evaluation-facing feedback reader는 batch review의 delivery-set 대상 article 집합을 source `batch_item`으로 해석합니다. mixed current·recovery delivery set의 ✅는 실제 포함된 각 item에 적용하고, 전용 처리 지연 delivery set의 ✅는 그 지연 item에만 적용하지만, 결과는 각 item의 source `selection_result`·scheduled batch에 귀속합니다. 같은 item에 재전송 등 여러 physical mapping이 있어도 하나의 논리 evaluation subject로 읽으며 mapping들은 검토·수락·부정 feedback의 근거일 뿐 message 수만큼 결과를 만들지 않습니다.

[FACT] Receipt adapter는 원래 `delivery_attempt`, `discord_message_mapping`, `delivery_segment`, `selection_result` 및 승인 사용자를 모두 연결할 수 있을 때만 `받음`/`못 받음`을 같은 원래 전달의 `recovery_case`에 typed event로 적용합니다. confirmation system message 자체의 2XX·일반 reaction은 이 조건을 대체하지 않습니다. 매핑 불가·모호·승인되지 않은 요청은 거부 근거만 저장하며 전달 상태 변경과 resend를 만들지 않습니다.

[FACT] Receipt adapter와 batch review adapter는 `못 받음`과 ✅를 적용하기 전 exact delivery attempt·message mapping 및 실제 대상 `batch_item` scope를 대조합니다. 같은 scope의 유효한 ✅와 `못 받음`은 `conflicting_receipt` safe output으로 보존하고 어느 event·evidence도 삭제·우선하지 않으며, 추가 resend·기존 resend 취소·암묵적 수용 계산을 만들지 않습니다. D1의 `못 받음`과 D2 recovery의 ✅처럼 scope가 다른 경우에는 상충으로 결합하지 않습니다.

[FACT] recovery case는 독립 식별자를 가지며, source `selection_result`, 원래 Discord delivery target reference와 승인 recipient reference가 이루는 immutable receipt scope의 같은 조합에는 최대 하나만 존재합니다. 이 세 논리 값은 합성 문자열이나 새 receipt-scope entity로 합치지 않고 같은 case인지 판단하는 경계로 사용하며, 실제 PK·column·constraint는 후속 물리 설계에서 확정합니다. article·attempt·message는 case를 나누는 기준이 아닙니다. source selection result를 통해 원래 scheduled batch를 조회하고, 하나의 delivery set에 source selection result가 둘 이상이면 source별 case를 분리합니다.

[FACT] 복구 대상 후보는 원래 `discord_message_item`·physical mapping·acceptance evidence에서 item별로 계산합니다. 명시적으로 미수락인 item은 `discord_2xx`, `discord_message_reconciliation` 또는 같은 item scope의 유효한 recipient-observed receipt가 없을 때만 recovery 후보가 됩니다. recipient-observed receipt는 원래 2XX 수락 시각을 만들지 않지만 receipt confirmation·자동 recovery 대상으로 다시 분류하지 않습니다. 명시적 미수락 evidence와 유효한 receipt가 함께 있어도 server 오류는 보존하며, `못 받음`과 receipt가 같은 scope에서 상충하는 경우에만 `conflicting_receipt`로 처리합니다. 실제 선택된 기사 subset은 delivery segment와 기존 batch item 관계만 소유하고, recovery case/event는 해당 segment를 참조하므로 별도 recovery item 목록을 출력하지 않습니다.

[FACT] `받음`은 `user_received` event와 `user_received_confirmation` 출처의 acceptance evidence를 추가합니다. `못 받음`은 `user_not_received`·`immediate_resend_authorized` event를 추가해 1회 즉시 resend만 권한화하며, 원래 Discord 서버 전달을 명시적 미수락으로 바꾸거나 그 자체로 `confirmed_non_acceptance_recovery` segment를 만들지 않습니다. 1회 즉시 resend는 원래 mapping·승인 사용자·예외 유형별 event key로 중복 방지되며 저장된 selection 결과를 재사용합니다.

[FACT] 같은 원래 delivery scope에서 불명확한 physical attempt 중 마지막 `invocation_started_at + 1시간`을 `confirmation_due_at`으로 둡니다. source observation 시각이 due 이하인 Discord 2XX 수락·sandbox 검증 direct message proof·recipient-observed receipt·명시적 수신 근거는 confirmation을 막습니다. Recovery는 due work claim 뒤 외부 invocation 직전에 이 근거를 다시 대조하며, 모두 없을 때만 원래 예정 batch당 하나의 `receipt_confirmation_requested` event를 만듭니다. invocation 시작 뒤 late evidence는 원래 case에 적용하지만 이미 시작한 confirmation을 취소·재호출하지 않습니다. `받음`은 원래 Discord 서버 수락 시각과 정시 수락을 추정하지 않습니다. `못 받음` 즉시 resend가 Discord 2XX 수락 또는 유효한 recipient-observed receipt를 얻으면 backlog를 만들지 않고, 그 resend attempt 자체가 명시적으로 미수락이면 실제 item subset만 확인된 미수락 backlog가 되며, 다시 불명확하면 확인·자동 resend·자동 backlog 편입을 반복하지 않습니다.

[FACT] 확인 요청이 다음 성공 정규 batch까지 무응답이면 같은 case에 `confirmation_no_response`를 기록합니다. recovery offer는 failure notice·receipt confirmation·processing-delayed full result가 아닌 다음 scheduled regular delivery set의 offer 표시 physical mapping에 한 번만 intent로 연결합니다. 해당 mapping의 `discord_2xx`와 message ID가 있어야 offer가 사용자에게 실제 표시된 성공으로 판단되며, 그 mapping이 수락 불명확이면 intent·attempt·evidence만 보존하고 다음 batch에 자동으로 재첨부·재발송하지 않습니다. 명시적 `recovery_selected` event가 있을 때만 재전송하고, 무응답은 수락 불명확으로 유지합니다. 확인된 미수락 backlog는 FIFO 원래 batch 단위로 recovery 최대 10개와 current 최대 10개, 총 최대 20개를 허용하며 남은 건은 `additional_recovery_selected` event마다 같은 가장 오래된 원래 batch에서 최대 10개만 제공합니다.

[FACT] 같은 delivery scope의 유효한 `받음`과 `못 받음`, 또는 유효한 ✅ receipt와 `못 받음`이 상충하면 `conflicting_receipt` event와 case 상태로 기록합니다. 상충 scope의 item은 자동 resend·기존 resend 취소·품질 feedback·batch review·암묵적 수용의 근거가 아니며, 같은 delivery set의 다른 비상충 item은 독립된 근거로 처리합니다.

[FACT] batch 대표 message의 승인 사용자 ✅는 해당 delivery set의 실제 article 전체를 검토 완료 대상과 user-observed receipt 범위로 연결합니다. 정규 current·recovery set과 전용 처리 지연 set의 범위는 함께 연결하지 않습니다. ✅ 제거는 현재 검토 완료를 취소하지만 append-only Gateway event와 이미 성립한 recipient-observed receipt evidence를 삭제하지 않습니다.

[FACT] batch review feedback의 `present`, `absent`, `not_observed`는 원래 Discord 2XX 수락이나 원문 열람을 뜻하지 않습니다. 다만 검증된 `present` ✅는 해당 delivery set의 user-observed receipt 근거가 됩니다. 이 근거와 Discord 2XX·명시적 수신은 source를 구분한 acceptance evidence와 receipt/recovery event에서 별도로 판단합니다.

[FACT] 암묵적 수용은 batch review가 현재 `present`인 delivery set의 article 중 Discord 2XX 수락 또는 그 batch review의 유효한 recipient-observed receipt 근거가 있고, 😕·🚫·📣 상태가 모두 확인된 `absent`인 경우에만 계산합니다. 상태 확인 불가 article은 암묵적 수용률 분자·분모에서 제외하며, review 자체가 없는 delivery 성공 article은 품질 수용률이 아닌 feedback 미관측률로 집계합니다.

[FACT] 누락 기사 command와 `받음`/`못 받음`은 품질 reaction·batch 검토 완료와 다른 의미의 interaction으로 보존·집계합니다.

[UNKNOWN] delivery segment와 선택 item subset 관계의 물리 표현, slash command·reaction 이름, parameter, 확인·추가 복구 UI, interaction transport, MVP-B `retention_purged` 사용자 안내와 상충 상태 운영 해소 절차는 상세 schema 설계·검증 전 확정하지 않습니다.

## Execution and External-effect Contract

[FACT] `work_item`은 logical work가 현재 실행 중인지·완료됐는지·대기/차단됐는지와 현재 claim/lease를 조정하는 현재 요약 record이고, `work_attempt`는 실제 claim 성공 뒤 시작한 실행 이력을 append-only로 보존합니다. RSS·AI·selection·delivery 결과를 저장하는 엔터티가 아닙니다.

[FACT] delivery release work는 scheduled regular delivery의 target scheduled batch, 처리 지연 full result의 source selection result, receipt confirmation·승인된 즉시 재전송·사용자 선택 recovery의 exact source event 또는 interaction 범위를 구분하는 logical key를 가집니다. 별도 delivery-trigger entity를 만들지 않으며, 이 work를 참조하는 delivery set은 최대 하나입니다. work는 생성 계기·idempotency를, delivery set과 segment는 실제 전달 묶음·콘텐츠 출처를 각각 소유합니다.

[FACT] 동일 logical work key에는 하나의 `work_item`과 하나의 현재 유효 lease만 허용합니다. 현재 state와 lease 값은 work item에서 update하고, owner·token·시작·종료·결과 이력은 work attempt에 둡니다. 현재 lease 설정과 실제 attempt 생성은 같은 DB transaction으로 처리하며 별도 canonical work lease record는 만들지 않습니다. claim 실패한 실행은 실제 작업을 시작하지 않으므로 attempt를 만들지 않고 현재 상태를 대조한 뒤 종료합니다.

[FACT] lease 유효성·만료는 worker 또는 Pod local clock이 아닌 PostgreSQL 기준 시각으로 판단합니다. `prepared → invocation_started` 전환은 같은 transaction에서 현재 유효 lease와 claim token이 attempt token과 일치할 때만 허용합니다. 만료·교체된 token의 worker는 외부 invocation을 시작하거나 prepared attempt를 invocation-started로 바꿀 수 없습니다. 정확한 token 표현·lease 기간·SQL/ORM isolation은 [UNKNOWN]입니다.

[FACT] 예정 batch의 실행 이력은 scheduled batch와 prepare work item/attempt를 결합한 `batch_execution` 논리 projection으로 읽습니다. 같은 실행 사실을 별도 interface output으로 중복 생성하지 않습니다.

[FACT] source ledger 완전성이 확인된 예정 slot에 prepare `work_attempt`가 없으면 운영·evaluation output은 `not_executed`로 읽습니다. prepare attempt가 있으나 final result가 없으면 `incomplete` 또는 저장된 work 상태를 읽으며, 어느 경우도 정상 신규 0건이 아닙니다. restore 또는 ledger 완전성을 신뢰할 수 없으면 attempt 부재를 미실행으로 단정하지 않고 `not_measurable`과 원인을 출력합니다. 정확한 projection code와 운영 시작·과거 slot 대조 범위는 [UNKNOWN]입니다.

[FACT] 외부 API 호출이 없는 내부 DB 작업만 lease 만료 뒤 안전 재claim할 수 있습니다. AI·Discord 외부 효과가 있거나 있을 수 있는 work는 lease 만료만으로 재실행하지 않습니다.

[FACT] AI·Discord 호출은 `도메인 attempt prepared commit → invocation started commit → 외부 API 호출 → external_attempt_evidence와 업무 결과 commit` 순서로 진행합니다. invocation started 전환은 유효 lease·fencing token과 outbound gate·비용 안전·적용 configuration 및 외부 contract 확인을 같은 transaction에서 다시 대조한 뒤에만 합니다. invocation started 뒤 응답 근거가 없으면 `external_effect_uncertain`이며 자동 재호출·자동 재발송하지 않습니다.

[FACT] `prepared` commit 후 invocation started 전에 중단된 work는 외부 호출이 시작되지 않았으므로 DB 근거상 안전하게 재개할 수 있습니다. 재개 때 현재 유효 lease·fencing token, outbound gate·비용 안전·configuration snapshot·external contract 확인을 다시 대조하며, 하나라도 맞지 않으면 같은 prepared attempt를 원인과 함께 차단·대기시키고 새 invocation 또는 attempt를 만들지 않습니다. DB commit·무결성·restore 신뢰가 없으면 새 외부 호출을 시작하지 않습니다.

[FACT] lease 만료 또는 worker 교체 뒤에도 source attempt와 correlation 또는 mapping이 명확히 일치하는 late response·usage·acceptance evidence는 해당 invocation-started 도메인 attempt에 append-only·idempotent하게 기록할 수 있습니다. AI late response는 source candidate가 아직 미해결이고 final result가 없을 때만 검증된 유일한 selection-eligible analysis와 연결된 업무 결과를 해소할 수 있으며 새 호출·retry·attempt를 만들지 않습니다. candidate가 이미 다른 analysis로 해결됐거나 final result·failure notice가 고정된 뒤의 response는 evidence와 비적용 사유만 보존하며 selection·delivery를 바꾸지 않습니다. 출처·대응 관계가 불명확하거나 중복·상충하는 evidence는 불명확 상태와 원인을 유지합니다.

[FACT] RSS·AI·Discord의 도메인 attempt는 서로 합치지 않습니다. 각 adapter의 안전한 response·usage·limit 근거만 공통 `external_attempt_evidence`에 typed record로 출력하며, 해당 도메인의 업무 결과와 acceptance evidence를 대체하지 않습니다.

[FACT] 안전한 evidence는 별도 자유형 payload가 아니라 공통 식별자·source attempt·kind·관측 시각·schema version·outcome 및 allowlist된 provider별 값입니다. credential·secret·민감 header·불필요한 전체 응답은 저장하지 않으며, 필요한 provider response digest 또는 제한된 검증 근거만 보존합니다.

## Scheduler, Recovery, Backup, and Evaluation Contracts

| Interface | Input | Safe output | Prohibited output |
| --- | --- | --- | --- |
| Prepare | 목표 전달 시각 전의 예정 batch slot | 이전 commit·work claim 기반 수집/처리 진행, 목표 시각 뒤 full selection commit 후 delayed delivery work handoff·claim | 목표 시각 뒤 새 예정 batch 생성, selection commit 전 delivery set·attempt 생성 |
| Delivery gate | target scheduled batch의 delivery work와 준비된 result·recovery scope | 정시 delivery set·attempt release 또는 준비 중 관측 | 준비되지 않은 결과를 위한 새 처리 시작, 목표 시각 전 attempt |
| Recovery | internal incomplete work, 외부 호출 전 delivery work, `recovery_case`와 저장 event, 발견된 과거 예정 slot | 안전한 내부 재개, 1시간 receipt confirmation, one-time recovery offer, FIFO 확인 미수락·사용자 선택 recovery, 외부 효과 없는 historical slot ledger 등록 | 과거 slot의 Prepare/RSS/AI/selection/Discord 시작, AI/Discord 불명확 attempt 자동 재호출·재발송, 무응답 자동 복구 |
| Reconciliation | 저장된 exact reconciliation scope와 work claim | 범위 제한 REST snapshot 또는 gate 차단·비확정 결과 | 주기 polling, claim 실패·lease 만료·응답 유실에 따른 중복 REST 호출 |
| Backup verification | `backup_run` 실행 근거 | backup 실행 결과·검증 가능성, 실패 시 source를 참조하는 운영 사건 | backup 성공만으로 outbound 자동 재개 |
| Restore validation | source `backup_run`, restore 검증·ledger/Discord reconciliation 근거 | `restore_validation` 결과와 manual approval 대기 상태 | 자동 restore·자동 outbound 재개 |
| Evaluation | 명시된 evidence scope·input manifest | 표본 충족·Hard Gate·품질·서비스 지표 snapshot과 report | 운영 결과·selection 결과 변경 |

## Metric and Evaluation Contract

[FACT] evaluation command는 명시된 원본 evidence 범위와 `metric_definition_version`을 입력으로 하는 읽기 전용 interface입니다. 실행·실패·재시도는 `work_item(type=evaluation)`과 `work_attempt`가 기록하며, 별도 `evaluation_run` canonical record는 만들지 않습니다. 성공한 attempt만 immutable `evaluation_snapshot`과 그 아래 `sample_adequacy`, `quality_review`, `hard_gate`, `quality_metric`, `service_metric`, `final_interpretation` 종류의 typed `evaluation_result`를 출력합니다. 지속적인 metric 원본 복제 record는 만들지 않습니다.

[FACT] 사용자는 2026-09-03 Asia/Seoul에 MVP-A evaluation의 기본 실행을 사용자 요청 기반 command로 승인했습니다. batch별·일별 자동 evaluation은 만들지 않습니다.

[FACT] evaluation snapshot의 compact input manifest는 대상 기간·scheduled batch 범위 또는 ID, `as_of_at`, 성공 work attempt, `metric_definition_version` 및 `input_manifest_scheme_version`을 포함합니다. source별 manifest 항목은 source kind, high-watermark 또는 reconciliation 같은 고정 reference, 선택 input row 수와 deterministic digest를 포함합니다. `input_manifest_scheme_version`은 source kind·선택 projection·canonical ordering의 해석을 구분합니다. 원본 RSS·AI·delivery·feedback payload나 전체 원본 ID 목록은 복사하지 않습니다.

[FACT] `as_of_at`과 high-watermark는 evaluation input의 관측 cutoff이며, feedback 지표는 그 cutoff 아래의 `discord_gateway_event`·`rest_state_snapshot`·reconciliation reference로 당시 상태를 읽습니다. evaluation 뒤에 저장된 event·snapshot 또는 이후 mutable `feedback_state`는 기존 snapshot에 소급 적용하지 않습니다. late observation을 반영하려면 같은 definition version이라도 사용자의 새 evaluation request가 새 input manifest·work attempt·immutable snapshot을 만듭니다.

[FACT] 원본 행이 이용 가능한 동안 같은 scope·cutoff·definition·input manifest scheme의 새 evaluation은 source별 input row 수·digest와 결과를 대조할 수 있습니다. 원본 행이 retention으로 정리된 뒤에는 기존 snapshot의 manifest·result는 보존하되 row-level 재계산 가능 여부를 별도 보고하며, 원본 ID 목록 또는 payload를 snapshot에 복사해 이를 우회하지 않습니다.

[FACT] evaluation 직전의 허용된 reconciliation request가 outbound gate에 막히거나 REST 대조에 실패하면 evaluation은 이를 우회해 호출하지 않습니다. 성공 snapshot의 input manifest와 result는 사용 가능한 reconciliation snapshot reference 또는 대조 불가·차단 사유를 구분하며, feedback 의존 지표를 0·반응 없음·`pass`로 바꾸지 않고 `not_measurable` 또는 명시적 제외 이유로 보존합니다.

| Scope | Input | Allowed interpretation |
| --- | --- | --- |
| 단일 예정 batch | 하나의 scheduled batch ID와 해당 evidence high-watermark | 장애·지연·전달 진단만 가능; MVP-A 품질 통과·실패 판정 금지 |
| Asia/Seoul 하루 | 그 날의 두 예정 batch ID와 해당 evidence high-watermark | 일일 운영 추세만 가능; 미실행 batch도 범위에 포함 |
| 검증 기간 | 명시된 batch 범위 또는 ID와 기간 끝 `as_of_at` | 최소 2주·20 batch·50 후보 및 최대 4주 `판정 불충분` 규칙 적용 |

[FACT] 모든 성공 evaluation은 `final_interpretation`에 `scope_kind`, 운영 진단 또는 검증 기간인 `interpretation_level`, 결론 또는 판정 불가 사유와 참조 결과를 출력합니다. 단일 예정 batch·하루 scope는 운영 진단만 출력하며 MVP-A 품질 통과·실패를 표기하지 않습니다. 검증 기간 scope만 최소 표본, Hard Gate, 품질·서비스 결과를 함께 읽어 MVP-A 품질 검증 통과 후보 여부를 해석할 수 있습니다. 물리 field명과 최종 결론 code는 [UNKNOWN]입니다.

[FACT] 지표는 기존 `scheduled_batch`, `batch_candidate`, `ai_analysis_attempt`, `selection_result`, `delivery_attempt`, `acceptance_evidence`, cutoff 아래의 `discord_gateway_event`·`rest_state_snapshot`·reconciliation reference, `recovery_event`, `cost_safety_evidence`를 읽어 계산합니다. mutable `feedback_state`는 운영의 현재 조회 projection이며 immutable evaluation의 최종 source로 읽지 않습니다. 지표별 source lineage와 2XX·recipient-observed·feedback 미관측·비용 범위의 분리 규칙은 [Logical Data Model](data-model.md)의 DDI-08을 따릅니다.

[FACT] 최소 표본은 2주·20개 예정 batch·50개 후보를 각각 대조합니다. 최대 4주에도 하나라도 부족하면 전체 품질 통과·실패로 추정하지 않고 `판정 불충분`으로 기록하되, 이미 확인된 Hard Gate 위반과 품질·서비스 관측값은 숨기지 않습니다.

[FACT] 여섯 Hard Gate는 각각 위반 0건 기준으로 독립 평가합니다. 최소 표본 충족만으로 품질 통과가 되지 않으며, 승인된 품질·서비스 목표 결과를 별도로 보고합니다. 품질 지표 미달은 원인과 추가 검증 대상으로 유지하고 프로젝트 자동 종료로 변환하지 않습니다.

[FACT] evaluation command는 각 `hard_gate` 결과에 [Logical Data Model](data-model.md)의 DDI-08 Hard Gate 표에서 정한 snapshot cutoff 아래의 read-only source reference, evidence coverage·제외 사유와 `pass`·`fail`·`not_measurable` 판정을 출력합니다. cutoff 뒤 evidence는 기존 출력에 소급 반영하지 않고 새 사용자 요청 evaluation에서만 반영합니다. 이 계약은 새 entity·상시 metric record·result kind를 추가하지 않으며, 허용된 1회 즉시 재전송과 batch 대표 message mapping을 의도되지 않은 article 중복 발송으로 계산하지 않습니다.

[FACT] `unknown`, `stale`, `unmapped` feedback, 누락된 필수 evidence 등은 0·반응 없음·암묵적 수용·Hard Gate `pass`로 대체하지 않습니다. 평가 결과는 `not_measurable` 또는 명시적 제외 이유로 보고합니다.

[FACT] metric definition이 바뀌거나 late observation·새 reconciliation evidence를 반영해 재평가할 때 기존 snapshot을 덮어쓰지 않습니다. 새 definition version 또는 새 source cutoff로 별도 evaluation work item/attempt와 snapshot을 만들며, evaluation adapter는 RSS·AI·selection·delivery·feedback·운영 record를 소급 변경하지 않습니다. MVP-A는 late observation만으로 자동 evaluation을 시작하지 않습니다.

[FACT] 각 비율·품질·서비스 `evaluation_result`는 분자·분모·제외 이유·측정 가능 여부와 source evidence reference를 포함합니다. 원본 RSS·AI·delivery·feedback payload를 snapshot에 다시 복사하지 않습니다.

[FACT] evaluation이 표본별 품질 검토를 포함하면, 성공 snapshot 아래의 `quality_review` 결과가 선택된 검토 대상과 기준별 판정·이유·source reference를 출력합니다. 그 뒤 `quality_metric`과 관련 `hard_gate`가 이를 읽어 집계·판정합니다. 이 결과는 사용자 요청 evaluation에서 선택한 표본에만 작성되며, 평가 대상 전체를 계속 복제하는 interface가 아닙니다.

[UNKNOWN] 검증 기간의 정확한 시작·종료 선택, `quality_review`의 검토자 식별 방식, 확정 기준의 실제 계산 구현, 평가 표본 추출·검토 rubric·보고 형식, dashboard/alert 전송 interface 및 metric 보존 기간은 후속 검증에서 확정합니다.

## Security, Cost, and Operational Gate Contract

[FACT] credential, webhook URL, interaction secret 및 파생 민감값은 DB, 일반 log, metric, trace, AI input, 사용자 표시에 저장하거나 노출하지 않습니다.

[FACT] 실행은 immutable `configuration_snapshot`을 참조합니다. snapshot은 provider/model 식별자, free-only 정책, output contract·판단 정책 version, runtime/image revision을 설명하며 설정 등록·변경 때만 만듭니다. pause·resume·재활성화와 batch 실행은 새 snapshot을 만들지 않고 기존 snapshot을 재사용하며 secret 값은 보존하지 않습니다.

[FACT] 실제 Prepare batch는 첫 내부 commit에서 하나의 processing snapshot을 binding하고, 같은 batch의 AI attempt와 final selection result는 이 binding을 따른다. 새 snapshot의 승인·활성화는 이미 binding된 batch를 소급 변경하거나 새 AI provider/model·판단 정책으로 자동 전환하지 않는다. 기존 binding이 호출 조건을 충족하지 않으면 새 outbound 대신 차단·미처리 상태를 보존하며, 새 snapshot은 후속 batch에서만 사용한다.

[FACT] configuration snapshot은 outbound 활성화 이력이 아닙니다. 활성화·pause·resume과 필요한 사용자 승인·재개 조건은 snapshot, contract check, 비용·backup·DB evidence를 참조하는 `operational_event`로만 기록합니다.

[FACT] RSS·AI·Discord 외부 계약 확인은 reusable `external_contract_check`로 기록하고 필요한 configuration snapshot이 이를 참조합니다. check는 비밀값 없는 적용 설정 version 또는 fingerprint, 확인 계기, 공식 계약·자료 version 또는 fingerprint, 검증 시각, 공식 자료 확인·sandbox·제한 workload 검증의 수행 여부와 결과, 불일치·미확인의 영향 및 활성화 차단 여부를 출력합니다. 서비스별 subject나 별도 activation snapshot은 만들지 않으며, 구현 직전·운영 검증 시작 직전·계약/설정 변경·mismatch·승인된 재검증 외에는 batch마다 새 check를 만들지 않습니다.

[FACT] 하나의 통과 contract check는 관련 조건이 바뀌지 않은 여러 configuration snapshot에서 재사용할 수 있습니다. snapshot은 check 결과나 공식 자료를 복사하지 않고 reference만 가집니다.

[FACT] contract check에는 service key, 비밀값 없는 적용 설정 version 또는 fingerprint, 확인 계기, 공식 계약 version 또는 fingerprint, 검증 방식·시각·결과·영향·활성화 차단 여부만 보존합니다. 공식 문서 원문·전체 외부 응답·credential·secret은 저장하지 않습니다. 확인 불가·미검증·설정 불일치·유료 가능성은 안전한 것으로 추정하거나 자동 활성화·자동 failover로 처리하지 않고, 영향 경로를 차단·검증 대기 상태로 남깁니다.

[FACT] 시스템은 provider·model·credential·과금 경로를 자동 전환하지 않습니다. 비용·plan 불명확 또는 새 설정의 비용 안전 미검증은 해당 비용 가능 AI 경로를 fail-closed로 차단합니다.

[FACT] 하나의 `cost_safety_evidence`는 AI provider, Discord 연동, K3s runtime/host, PostgreSQL/PersistentVolume, backup 저장소, image registry, scheduler/monitoring 중 하나 이상의 비용 확인 범위를 덮을 수 있습니다. 자동 billing 조회나 범위별 별도 비용 interface를 만들지 않고, 사용자가 확인한 월별 billing/usage·공식 무료 조건·quota 근거가 어느 범위를 덮는지만 보존합니다.

[FACT] 사용자 billing·usage 확인과 공식 provider quota/오류 근거는 `cost_safety_evidence`로 보존합니다. 모든 적용 범위에 대해 0원 확인·확인 불가·위반을 구분하되 account identifier·invoice 원문·credential은 저장하지 않습니다. 실제 비용 위반 확인, 수동 pause, 사용자 재확인 및 resume approval은 `operational_event`로 별도 보존합니다.

[FACT] 외부 호출 전 outbound gate는 모든 비용 가능 실행 범위의 무료·과금 불가 설정과 공식 비용 조건을 확인한 사전 비용 안전 근거를 사용합니다. 실제 월별 billing 결과는 해당 기간 뒤 사용자가 확인하는 운영 증거이며, 첫 운영월에 아직 존재하지 않는 월 결과만으로 사전 비용 안전 미확인 또는 자동 차단으로 처리하지 않습니다.

[FACT] 비용·quota 상태의 재확인은 새 cost safety evidence만 추가합니다. 적용 configuration snapshot이나 contract check를 복제하지 않으며, batch와 AI·Discord attempt는 필요한 사전 비용 안전 근거를 참조합니다.

[FACT] 비용 0원 위반·비용 가능 실행 범위의 사전 비용 안전 상태 불명확·backup 공백 초과·restore 검증 대기·DB 신뢰 불명·수동 pause는 outbound gate 차단 근거이며 자동 재개하지 않습니다. 아직 존재하지 않는 실제 월별 billing 결과만으로 gate를 닫지 않지만, 비용 Hard Gate를 `pass` 또는 0원으로 추정하지 않습니다.

[FACT] outbound를 다시 활성화하려면 configuration snapshot, 필요한 external contract check, 비용/backup/DB 검증 evidence 및 필요한 사용자 수동 승인 record가 모두 연결돼야 합니다.

[FACT] `backup_run`과 `restore_validation`은 실행·검증의 source record이고, `operational_event`는 backup 실패·restore 검증 대기·수동 재개 승인처럼 사람이 확인해야 하는 사건만 이 source record를 참조합니다. 성공 결과를 운영 event에 중복 복사하지 않습니다.

[FACT] restore 뒤에는 DB 무결성, ledger·Discord 수락 근거, 필요한 feedback 대조를 완료하고 사용자 승인을 받아야 outbound를 재개할 수 있습니다.

## Retention Lifecycle Contract

[FACT] MVP-A에는 retention 실행 interface가 없습니다. 아래 contract는 미래 retention에서 identity 손실·중복 처리·미해결 외부 효과의 삭제를 막기 위한 reserved safety constraint이며 현재 실행 interface나 최종 MVP-B 계약이 아닙니다. MVP-B에서 별도 승인해 도입한다면 retention 실행은 도메인별 보존 시계와 승인된 policy version을 입력으로 하며, 삭제 전 retention gate와 삭제 대상 manifest를 만들고 실행 결과·실패 근거 및 `article_identity_tombstone`을 출력으로 보존해야 합니다. 실제 필요성·명칭·필드·관계·command는 후속 상세 설계에서 다시 승인합니다.

[FACT] 미래 retention gate는 검증된 월별 Insight snapshot, 유효 work lease 부재, `external_effect_uncertain` 부재, 미해결 recovery·수락 확인 부재, 필요한 feedback/evaluation 근거 및 backup/restore 검증 상태를 확인해야 합니다. gate가 불명확하거나 실패하면 삭제를 시작하지 않습니다.

[FACT] PostgreSQL backup은 database 데이터와 분리된 backup 전용 폐기정책을 따릅니다. Discord system message는 database retention으로 자동 삭제하지 않으며, retention role은 Discord 삭제 API를 호출하지 않습니다.

[UNKNOWN] retention 실행 주기·실제 삭제 순서·backup 보존 기간·도구·저장 위치 및 retention-purged data의 사용자 응답은 MVP-B 환경 검증과 상세 설계에서 확정합니다.

## Deferred Validation

- [UNKNOWN] 실제 AI provider/model/prompt, free plan/quota/rate limit, structured output 및 비용 차단 방식
- [UNKNOWN] Discord payload 크기·message 분할, acceptance evidence, interaction transport, Gateway/REST 권한·rate limit
- [UNKNOWN] RSS conditional request, polling·timeout·retry/backoff 및 link validation
- [UNKNOWN] CronJob 지연·clock 오차, StorageClass, backup/restore 도구, RPO/RTO
- [UNKNOWN] 실제 API payload, schema, SQL, migration, RBAC/Secret manifest
- [UNKNOWN] contract 재검증 주기, typed external evidence/evaluation result의 provider별 allowlist와 물리 저장 형식

## Stage Boundary

[FACT] 이 문서는 최종 승인된 논리 interface이며 실제 외부 API payload·배포·구현 계약을 확정하지 않습니다.

[FACT] Data Model의 DDI-01~DDI-10, MIN-01~MIN-08과 세부 정합성 검토 결과(`VR-012`~`VR-019`)를 반영했으며, 사용자는 2026-09-04 Asia/Seoul에 이 문서 전체를 최종 승인했습니다. 중복을 피하기 위해 항목별 결정·추적 상태는 `data-model.md`의 `Decision Review Register`를 정본으로 사용하며, 이 승인은 실제 외부·구현 계약 승인이 아닙니다.
