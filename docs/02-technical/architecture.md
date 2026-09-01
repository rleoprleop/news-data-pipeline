# MVP-A Architecture

## Architecture Context

[FACT] Workflow 단계: 7. Architecture

[FACT] 상태: Approved

[FACT] 작성일: 2026-09-01 Asia/Seoul

[FACT] 최종 승인일: 2026-09-01 Asia/Seoul

[FACT] 사용자는 2026-09-01 Asia/Seoul에 AD-01의 하나의 Python 코드베이스·두 실행 역할 구조를 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 AD-02의 PostgreSQL 단일 제어 기준과 DB 장애 시 fail-closed 정책을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 AD-03의 PostgreSQL durable work ledger와 lease 기반 작업 조정, 별도 queue 미도입 결정을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 AD-04의 단일 무료 AI 분석 모듈과 비용·plan·quota 상태 불명확 시 fail-closed 호출 차단을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 AD-05의 Discord Gateway event 수신과 REST 기반 현재 상태 대조 조합을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 Gateway-first triggered REST reconciliation, REST 대조 불가 상태의 feedback 없음 미추정, 추적된 시스템 message·승인 사용자·허용 reaction으로의 대조 범위 제한을 AD-11·AD-12로 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 Gateway listener 상시 실행·event dispatcher 구조와 RSS·AI·정규 발송의 Cron batch 실행 후 종료 경계를 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 Cron을 예정 수집 시작과 예정 전달 gate에 사용하고, 후보화·AI·선정은 PostgreSQL commit을 기준으로 이어지는 pipeline으로 처리하는 구조를 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 K3s를 MVP-A 실행 환경으로 사용하고, PostgreSQL도 K3s 내부의 지속 볼륨 기반 상태 저장소로 운영하는 방향을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 CronJob이 시작·전달 gate·복구 기회만 만들고, pipeline의 다음 단계 진행은 직전 PostgreSQL commit과 work claim을 기준으로 하는 AD-08을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 단일 PostgreSQL StatefulSet·PersistentVolume과 별도 실패 영역의 논리 backup, 수동 검증 restore를 사용하는 AD-09와 DB 신뢰 불명 시 외부 효과를 fail-closed하는 AD-10을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 K3s Secret encryption과 역할별 최소 권한, 검증된 image digest 배포, 공개 registry의 조건부 사용, 수동 cost kill switch와 자동 재개 금지를 AD-13~AD-16으로 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 유효 후보 AI 분석 미완료 시 partial 기사 목록을 발송하지 않고, 전체 선정 완료 뒤 원래 batch의 지연 full result를 발송하며, 전체 선정 불가능 시 원인별 처리 실패 notice를 발송하는 AD-17·AD-18을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 Discord 전달 attempt를 10:00·22:00 KST보다 먼저 시작하지 않고 1분 안의 수락을 목표로 하는 AD-19와, 선정이 목표 시각 뒤 완료되면 기존 pipeline이 원래 batch의 최대 10개 지연 full result를 별도 처리 지연 batch로 즉시 발송하는 AD-20을 승인했습니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 수락 불명확 확인·추가 복구 요청을 Gateway listener와 Recovery CronJob이 나누어 처리하는 AD-21, backup 또는 restore 뒤 검증·대조·수동 승인 전 outbound를 재개하지 않는 AD-22, 품질 평가를 같은 Python image의 독립 실행 기능으로 두는 AD-23을 승인했습니다.

[FACT] 이 문서는 승인된 [Product Specification](../01-product/product-spec.md) 및 [Technical Requirements](requirements.md)를 만족하기 위한 MVP-A Architecture 경계와 결정을 정의합니다.

[FACT] 이 문서는 데이터베이스 schema, API payload, prompt, K3s manifest, Cron expression 또는 구현 코드를 확정하지 않습니다.

[FACT] 사용자가 제공한 초기 Notion 계획은 데이터 lifecycle과 상태 기반 배치 처리의 의도를 이해하기 위한 참고 자료입니다. 현재 Repository 문서의 승인된 범위와 요구사항을 대체하지 않습니다.

[FACT] Technical Requirements 단계 종료 commit `0e8214c`는 `main`과 `origin/main`에 반영되어 있으며, 이전의 `commit/push 대기` 상태는 현재 문서 기준이 아닙니다.

[FACT] AD-01~AD-23과 현재 Product Specification·Technical Requirements·README·AI Context의 정책 표현을 승인된 Architecture 결정에 맞게 동기화했고, 사용자가 2026-09-01 Asia/Seoul에 이 문서 전체를 최종 승인했습니다.

## Purpose and Decision Scope

[INFERENCE] 이 Architecture의 목적은 GeekNews RSS 수집부터 Discord 전달·feedback·복구·초기 품질 측정까지를 하나의 추적 가능한 흐름으로 연결하면서, 비용·중복 전달·근거 밖 생성·실패 오표시 Hard Gate를 지키는 것입니다.

[FACT] MVP-A는 GeekNews RSS 하나, 한국어 IT 뉴스, 하루 두 번의 Discord 결과, 최소 판단 근거·결과 version, feedback 및 초기 측정을 포함합니다.

[FACT] MVP-A는 외부 원문 또는 GeekNews 상세 페이지 본문 수집, 다중 수집원, 자동 유료 전환, 여러 AI 제공자의 동시 구현, Kafka, Spark를 포함하지 않습니다.

[FACT] 월별 Insight, 장기 AI 결과 재사용 확장, 자동 Retention lifecycle은 MVP-B 범위입니다.

## Architecture Drivers

| Driver | Architecture implication |
| --- | --- |
| [FACT] Raw RSS `link` 원값이 논리 기사 identity | 원본 관찰과 논리 기사를 연결하되, URL 정규화·Atom `id`·제목으로 identity를 대체하지 않습니다. |
| [FACT] News·Ask·Show 모두 후보 자격 유지 | source type 또는 단순 keyword로 AI 분석 전 조기 제외하지 않으며, 모든 후보에 명시적 결과를 남깁니다. |
| [FACT] 09:30·21:30 시작부터 30분 내 발송 가능 결과 준비 | 예정 batch slot, 시작·결과 준비 시각과 처리 지연 원인을 별도 기록합니다. |
| [FACT] 10:00·22:00부터 1분 안의 Discord 수락 | 목표 시각 전에 전달 attempt를 시작하지 않고 attempt·수락 시각을 분리해 기록합니다. |
| [FACT] 현재 기사는 예정 전달 시각 기준 RSS `published` 13시간 이내 | 시간대와 경계값을 결정적으로 적용하고 누락·오류·비교 불가는 현재 기사로 선정하지 않습니다. |
| [FACT] 추가 월 비용·유료 호출·유료 자원 사용 0건 | 하나의 승인된 무료 AI 경로만 허용하고, 비용 또는 plan 상태가 불명확하면 비용 발생 가능 작업을 차단합니다. |
| [FACT] 동일 기사 의도되지 않은 중복 전달 0건 | 논리적 전달 결과·발송 intent·Discord attempt·수락 근거를 분리하고, 불명확 응답은 자동 재전송하지 않습니다. |
| [FACT] AI 실패를 정상 신규 0건으로 기록 금지 | 수집·입력·AI·전달 상태를 서로 덮어쓰지 않고, 실패·부분·미처리 수량을 보존합니다. |
| [FACT] Discord 미수락을 성공으로 기록 금지 | Discord 응답과 필요한 message 식별자 등 수락 근거를 성공 기록과 연결합니다. |
| [FACT] RSS 근거 밖 중대한 사실 0건 | AI 입력 범위와 결과 검증 근거를 Raw RSS snapshot·관찰 entry·결과 version에 연결합니다. |
| [FACT] 학습·포트폴리오 목적의 운영 구조 가시성 | 상태·멱등성·복구·배포 경계를 실제로 검증할 수 있게 K3s와 PostgreSQL을 사용하되 MVP-A 기능 범위와 금지 기술은 늘리지 않습니다. |

## Candidate Architectures

| Candidate | Structure | Requirements fit | Monthly added cost 0 potential | Operations complexity | Failure recovery and reprocessing | MVP-B extensibility | Implementation and validation | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A. Single long-running Python application | 한 process가 scheduler·RSS pipeline·Discord listener를 모두 담당 | 핵심 기능은 가능하지만 scheduled batch와 listener 장애 경계가 결합됨 | [ASSUMPTION] 기존 무료 host가 있으면 가능 | 낮음 | process 장애가 모든 역할에 영향을 주고 독립 재시작·재처리 검증이 어려움 | 역할 분리 시 재구조화 필요 | 가장 단순하지만 장기 실행 scheduler와 event loop 결합 검증 필요 | [INFERENCE] 로컬 prototype 대안 |
| B. Shared Python image + K3s split roles + PostgreSQL ledger | Prepare·Delivery-gate·Recovery CronJob, Gateway listener Deployment, PostgreSQL StatefulSet | 승인된 시간·feedback·DB commit handoff·복구 요구를 가장 직접적으로 충족 | [ASSUMPTION] 기존 무료 host·storage·registry 조건 검증 시 가능 | 중간 | 역할별 재시작, durable work claim, 외부 효과 불명확 격리가 가능 | 같은 ledger와 역할 경계를 유지한 채 후속 기능 추가 가능 | K3s·storage·backup·Discord 계약 검증이 필요 | [FACT] MVP-A 승인안 |
| C. Separate workers and external queue | 기능별 worker와 별도 broker/managed queue | 비동기 처리에는 적합하지만 MVP-A 규모에 비해 경계와 운영 요소가 증가 | 별도 broker·storage의 0원 조건이 추가로 필요 | 높음 | queue와 DB 간 이중 상태·외부 효과 exactly-once 오해 위험 | 대규모 처리 확장에는 유리 | 장애·중복·운영 검증 범위가 가장 큼 | [FACT] MVP-A 미도입; Kafka·Spark는 금지 |
| D. CronJobs only with periodic Discord polling | 모든 기능을 단기 batch와 polling으로 수행 | reaction·interaction의 적시 수집과 Gateway 기반 변경 이력 요구를 충분히 충족하지 못함 | 가능성은 있으나 REST rate limit 검증 필요 | 낮음~중간 | event 누락·삭제 구분과 즉시 사용자 요청 처리가 약함 | feedback 확장에 불리 | 단순하지만 Discord 계약 적합성 위험이 큼 | [INFERENCE] 미추천 |

[INFERENCE] Candidate B는 학습·포트폴리오 목적의 배포·재시작·CronJob 관리 경험을 제공하면서도, 별도 queue 없이 PostgreSQL을 단일 제어 기준으로 유지하므로 현재 요구사항과 승인 결정을 가장 잘 만족합니다.

## Recommended Architecture Draft

[FACT] MVP-A는 하나의 Python 코드베이스와 PostgreSQL 기반 상태·증거·durable work ledger를 중심으로 구성합니다. 승인된 실행 구조는 scheduled batch role과 long-running Discord listener role의 두 역할이며, 별도 queue나 worker platform을 도입하지 않습니다.

```text
                 Scheduled batch trigger
                          |
                          v
                 Batch orchestration
                          |
GeekNews RSS --> Collection / validation --> PostgreSQL evidence ledger
                                              |        |        |
                                              |        |        +--> Metrics / recovery queries
                                              |        |
                                              |        +--> Discord delivery adapter --> Discord
                                              |
                                              +--> Free-AI provider adapter
                                                           |
                                                           v
                                                    Decision / selection

Discord Gateway event + REST reconciliation --> Feedback boundary --> PostgreSQL evidence ledger
```

[INFERENCE] PostgreSQL은 단순 처리 대상 목록이 아니라, 외부 효과 전후의 상태·근거·시각을 보존하는 transaction boundary입니다.

[ASSUMPTION] PostgreSQL과 Python runtime은 추가 월 비용 없이 운용 가능한 기존 또는 실제 무료 실행 환경에 배치할 수 있습니다. 이 가정은 운영 전 검증해야 합니다.

## Execution Roles

| Role | Pipeline responsibilities | Boundary |
| --- | --- | --- |
| Scheduled collection and batch pipeline role | Cron 수집 trigger가 예정 slot을 시작하고 RSS 수집·검증을 수행합니다. 이후 후보화·AI·선정은 PostgreSQL commit을 기준으로 이어지며, 정시 전달 gate 또는 목표 시각 뒤 완료된 지연 full result의 전달 처리가 끝나면 role은 종료합니다. | reaction·slash command event를 직접 수신하거나 AI 재분석 없이 복구하지 않음 |
| Long-running Discord listener role | 상시 Gateway 연결을 유지하며 event dispatcher로서 Discord event 인증·수신, reaction·slash command 검증, 사용자·article·batch·message mapping, feedback 상태 반영, 사용자 요청 기반 재전송 요청 기록 | RSS 수집, AI 분석, 재선정 또는 자동 재전송을 직접 수행하지 않음 |

[FACT] 두 역할은 process memory가 아니라 PostgreSQL에 보존된 상태·근거·작업 요청으로 handoff합니다.

[INFERENCE] 두 역할은 공통 delivery·validation·state access 모듈을 재사용할 수 있지만, MVP-A에서 별도 마이크로서비스로 분리하지 않습니다.

## Listener Event Dispatch

[FACT] Gateway listener는 상시 실행하지만, event마다 전체 뉴스 처리 파이프라인을 실행하지 않습니다. 수신한 event 유형에 따라 필요한 작은 기능만 호출합니다.

| Discord event | Listener-dispatched function | Result |
| --- | --- | --- |
| 기사별 reaction 추가·삭제 | event 검증, 원본 event 기록, 현재 feedback 상태 반영 | article feedback 상태 또는 수집·연결 실패 기록 |
| batch 대표 message의 검토 완료 reaction | 승인 사용자·batch mapping 검증, 현재 검토 완료 상태 반영 | batch 검토 완료 또는 취소 상태 |
| slash command | 입력 검증, 저장된 실제 이력·복구 backlog 조회, 허용된 Discord 응답 또는 추가 복구 request 생성 | 누락 기사 요청·이력 회신·사용자 선택 기반 추가 복구 또는 입력·연결 오류 |
| 승인된 사용자의 `못 받음` 확인 | 원래 delivery attempt 검증, 1회 재전송 request 기록, 공통 delivery module 호출 조건 생성 | 저장된 원래 결과 기반의 사용자 요청 재전송 또는 명시적 불가 상태 |

[FACT] listener는 RSS 수집·AI 분석·정규 선정·정규 batch 발송을 직접 시작하지 않습니다.

## Scheduled Pipeline and Delivery Gate

[FACT] 09:30·21:30 KST의 Cron trigger는 예정 batch를 시작하고 RSS 수집을 개시합니다. 후보화·AI 분석·결과 검증·선정은 각각 이전 단계의 PostgreSQL commit을 근거로 이어지는 pipeline 기능입니다.

[FACT] 10:00·22:00 KST의 전달 gate는 준비된 논리적 발송 결과만 release합니다. Discord 전달 attempt는 목표 시각보다 먼저 시작하지 않으며, 수락이 10:00:00 이상 10:01:00 미만 또는 22:00:00 이상 22:01:00 미만에 확인되어야 정시 수락으로 계산합니다. 이 gate는 준비되지 않은 결과를 위해 RSS 수집·AI 분석·선정을 새로 시작하지 않습니다.

[FACT] 처리 결과가 목표 시각 뒤에 완전히 준비되면 해당 처리를 이어 온 pipeline이 저장된 원래 batch의 최대 10개 결과를 `처리 지연 full result`로 claim해 즉시 발송합니다. 이 결과는 Discord 미수락 복구 backlog의 `이전 Discord 장애로 지연된 기사`와 섞지 않으며, 정시 전달로 계산하지 않고 처리 지연 원인·준비·attempt·수락 시각을 별도로 기록합니다.

[FACT] 실행 기회는 아래 세 CronJob으로 구분합니다. 이들은 별도 pipeline이 아니라 durable work ledger에 저장된 상태에 대해 허용된 기능만 실행하는 동일 Python image의 역할별 실행입니다.

| CronJob | 역할 | 시작 또는 재개하지 않는 작업 |
| --- | --- | --- |
| Prepare | 09:30·21:30에 예정 batch를 claim하고 RSS 수집을 시작합니다. 이후 후보화·AI·선정은 직전 PostgreSQL commit이 성공한 단계만 이어서 실행합니다. | 목표 시각이 지난 뒤 새 예정 batch를 만들지 않습니다. |
| Delivery-gate | 10:00·22:00에 준비된 논리적 발송 결과만 claim·release합니다. 준비 중이면 gate 관측을 기록하고 종료합니다. | 목표 시각 전 전달 attempt를 시작하거나, 준비되지 않은 결과를 위해 RSS·AI·선정을 새로 시작하지 않습니다. |
| Recovery / reconciliation | 만료 lease, 중단된 내부 단계, 준비됐지만 attempt가 없는 저장 결과, 1시간 확인 시점이 도래한 수락 불명확 attempt와 REST 대조 request를 조회하여 DB 근거상 안전한 작업만 claim·재개합니다. | 외부 호출 결과가 불명확한 AI·Discord 작업을 자동 재호출·자동 재발송하지 않습니다. |

[FACT] Prepare와 Delivery-gate 또는 Recovery가 동시에 같은 결과를 관찰해도, 같은 논리 작업 key의 delivery claim·intent는 하나의 실행만 얻습니다. claim을 얻지 못한 실행은 이미 처리 중·완료·확인 대기 상태를 대조하고 종료합니다.

[FACT] 유효 후보 중 필요한 AI 분석이 미완료인 동안 전달 gate는 partial 기사 목록을 release하지 않습니다. 기존 pipeline이 모든 유효 후보의 필요한 처리와 선정까지 완료하면 목표 시각 뒤에도 원래 batch의 처리 지연 full result를 release합니다. pipeline이 결과를 commit한 뒤 전달 attempt 전에 중단된 경우에만 Recovery가 같은 결과를 claim할 수 있습니다. quota 소진·비용 차단·영구 오류 등으로 전체 선정이 불가능하면 기사 목록 대신 원인별 처리 실패 notice를 발송합니다.

## Component Boundaries and Responsibilities

| Component | Responsibility | Must not do |
| --- | --- | --- |
| Scheduled batch orchestrator | 예정 slot 실행, 중복 실행 제어, 처리·전달·복구 순서 조정 | 정상 신규 0건과 장애를 같은 결과로 기록하지 않음 |
| RSS adapter | GeekNews RSS fetch, Raw snapshot 보존, parsing과 입력 검증 | GeekNews 상세 페이지·외부 원문을 fetch하지 않음 |
| Article and processing ledger | `link` identity, 관찰·후보·처리·결과·시각의 연결 | Raw 관찰 이력을 단일 처리 flag로 소거하지 않음 |
| AI analysis module / free-AI provider adapter | batch role의 요청에 따라 허용 RSS 입력만 전달하고 구조화 결과·provider 오류를 반환 | listener role이 호출하거나 유료 provider·model·자동 fallback을 호출하지 않음 |
| Decision and selection service | 결과 검증, 최신성·홍보성·중요도 정책 적용, 논리적 발송 결과 고정 | 미처리 후보를 정상 제외·성공으로 바꾸지 않음 |
| Delivery adapter | Discord payload 구성, attempt 기록, 응답·message 식별자 대조 | 응답 유실을 성공·실패로 추정하지 않음 |
| Feedback boundary | Gateway event 수신, triggered REST 현재 상태 대조, 승인 사용자·시스템 message·article·batch mapping 검증 | event 부재 또는 REST 대조 실패를 feedback 없음·검토 완료로 추정하지 않음 |
| Recovery and metrics service | 미처리·미수락·수락 불명확·backlog·품질·지연·비용 증거 조회 | 원래 결과 없이 자동 재선정·재분석·재전송하지 않음 |
| Evaluation runner | 저장된 표본·판단 결과·feedback·Hard Gate·서비스 목표 근거를 정해진 평가 실행 단위로 계산 | 운영 결과를 소급 변경하거나 MVP-B Insight를 생성하지 않음 |

## PostgreSQL State, Evidence, and Idempotency Role

[INFERENCE] 아래는 논리적 보존 책임이며 table·column 설계가 아닙니다.

| Evidence domain | Required role |
| --- | --- |
| Raw input | fetch 시점의 변경 불가 RSS snapshot과 parsing된 entry를 연결합니다. |
| Logical article | Raw RSS `link` 원값이 정확히 같은 관찰을 하나의 논리 기사에 연결합니다. |
| AI processing | 실제 request attempt, 허용 입력 범위, provider/model·정책 version, 응답·검증·오류를 분리 보존합니다. |
| Batch and selection | 예정 batch, 후보 수량, 선정·제외·미처리·최대 제한 결과와 근거를 고정합니다. |
| Delivery | 논리적 발송 결과, physical message attempt, Discord 수락·미수락·불명확 근거를 연결합니다. |
| Feedback | reaction·interaction 원본 이력과 현재 유효 상태, 사용자·message·article·batch mapping을 보존합니다. |
| Recovery and measurement | 원래 batch, 사용자 확인 예외, backlog, latency, 품질·비용 검증 근거를 연결합니다. |

[INFERENCE] 같은 `link`의 반복 수집은 논리 기사를 중복 생성하지 않아야 하지만, 각 Raw RSS snapshot의 관찰 사실은 재현성을 위해 별도로 남겨야 합니다.

[INFERENCE] batch slot과 전달 intent에는 transactionally 획득하는 lease 또는 동등한 동시성 제어가 필요합니다. 정확한 lock·constraint·키 구조는 Data / Interface Design에서 결정합니다.

## PostgreSQL Control-plane and Database Failure Policy

[FACT] PostgreSQL은 예정 batch, 실행 attempt, 처리 intent, 외부 응답, 전달 근거, feedback 및 복구의 단일 제어 기준입니다.

[FACT] 각 예정 batch는 실제 실행 여부와 관계없이 하나의 논리적 실행 단위로 식별하며, retry·재시작·수동 재실행은 새 예정 batch가 아닌 기존 batch에 연결된 별도 attempt입니다.

[FACT] RSS 처리 결과 확정, AI 호출, Discord 전달과 feedback 상태 반영은 필요한 intent·대상·근거를 PostgreSQL에 기록할 수 있을 때만 진행합니다.

```text
이전 단계의 확정 상태
  → 현재 단계 작업
  → 결과·근거의 PostgreSQL commit
  → 다음 단계 진행
```

[INFERENCE] 외부 API 호출은 짧은 DB transaction으로 intent와 attempt 시작을 기록한 뒤 수행하고, 실제 응답·오류·수락 근거는 별도 transaction으로 기록합니다.

| Failure condition | Required treatment |
| --- | --- |
| 외부 호출 전 DB 기록 실패 | 외부 API를 호출하지 않고 이전 확정 상태에서 중단합니다. |
| RSS snapshot 저장 실패 | 수집 성공·후속 후보 생성으로 처리하지 않습니다. |
| AI 호출 후 결과 기록 실패 | 정상 분석으로 처리하지 않고, 복구 시 결과 불명확 attempt로 대조합니다. |
| Discord 호출 후 응답 기록 실패 | 성공·미수락 어느 쪽으로도 추정하지 않고 수락 불명확으로 유지하며 자동 재전송하지 않습니다. |
| feedback event 저장 실패 | reaction 없음·검토 미완료로 추정하지 않고 feedback 수집 실패로 유지합니다. |
| DB 일시 장애 | AI·Discord 외부 효과를 중단하고 복구 후 미완료 intent를 대조합니다. |
| DB 데이터 손실 또는 무결성 불명 | 자동 발송·자동 복구를 중단하고 복원 또는 수동 확인 전 재개하지 않습니다. |

## K3s PostgreSQL Durability and Restore Boundary

[FACT] MVP-A PostgreSQL은 하나의 K3s StatefulSet replica와 PersistentVolume으로 운영합니다. PostgreSQL Pod 또는 Python workload의 재시작은 commit된 durable work ledger·전달 근거·feedback 상태를 보존한 채 재개할 수 있어야 합니다.

[FACT] PersistentVolume은 PostgreSQL Pod 생명주기와 데이터를 분리하지만, 단일 노드·디스크·volume 손실에 대한 고가용성을 제공하지 않습니다. MVP-A는 DB cluster·자동 failover를 도입하지 않고, 해당 범위의 일시 중단을 수용합니다.

[FACT] 논리 backup은 PostgreSQL PVC와 다른 실패 영역에 보관합니다. 같은 Pod·PVC·노드에만 존재하는 backup은 노드 또는 디스크 손실의 복구 근거로 취급하지 않습니다.

[FACT] restore는 자동 실행하지 않습니다. 복원 후에는 batch·delivery intent·Discord 수락 근거를 대조하여 이미 수락된 결과의 재발송을 차단하고, 수락 불명확 결과는 자동 재발송하지 않습니다. commit된 내부 단계만 Recovery가 안전하게 재개할 수 있습니다.

[FACT] PostgreSQL 연결·commit·무결성이 불명확한 동안 batch role은 AI·Discord 외부 호출을 시작하지 않으며, listener role은 feedback business mutation을 반영하지 않습니다. DB 복구 뒤 listener는 Gateway event와 REST 현재 상태 대조로 feedback 상태를 재확인합니다.

[FACT] backup 실패는 원인·시각·영향을 기록하고 경보합니다. 최근 검증 가능한 backup이 있는 허용 공백 안에서는 backup 작업만 재시도할 수 있지만, 공백이 승인된 한계를 넘으면 신규 AI·Discord outbound pipeline을 중단합니다.

[FACT] backup 작업이 다시 성공한 경우에는 새 backup의 생성·복원 가능성 검증과 현재 PostgreSQL ledger 무결성 확인 뒤 사용자가 명시적으로 승인해야 outbound를 재개합니다. 실제 DB restore가 수행된 경우에는 여기에 batch·delivery intent·Discord 수락 근거와 Gateway·REST feedback 상태 대조까지 완료해야 하며 자동 재개하지 않습니다.

[UNKNOWN] backup·restore 도구, 보관 위치, StorageClass, volume 장애 범위, backup 공백 한계, 복원 목표 시간 및 월 비용 0원 근거는 Data / Interface Design과 실행 환경 검증에서 결정합니다.

## DB-based Work Coordination

[FACT] MVP-A는 Kafka, RabbitMQ 또는 관리형 queue를 사용하지 않습니다. PostgreSQL의 durable work ledger와 lease가 예정 batch·처리 intent·delivery intent·recovery request의 작업 조정을 담당합니다.

[INFERENCE] 논리 작업 key는 처리해야 할 대상을 식별하고, attempt는 실제 실행을 구분하며, lease는 현재 실행 역할의 임시 점유권을 나타냅니다. 다음 내부 pipeline 단계는 이전 단계의 PostgreSQL commit과 현재 작업 claim이 모두 있을 때만 진행합니다.

```text
logical work key
  → lease claim
  → execution attempt
  → result or uncertainty evidence
```

[FACT] 유효한 lease가 있는 작업은 다른 실행 역할이 동시에 처리하지 않습니다.

[FACT] 외부 효과가 있을 수 있는 작업은 lease 만료만으로 재실행하지 않습니다. 특히 Discord 전달은 기존 attempt·수락 근거·사용자 요청 기반 예외를 대조한 뒤에만 후속 처리를 결정합니다.

[UNKNOWN] 논리 작업 key, lease timeout·갱신, attempt 상태와 동시성 constraint의 정확한 구현은 Data / Interface Design에서 결정합니다.

## Logical Data Flow

1. [FACT] 09:30 또는 21:30 KST 예정 slot이 시작되면 orchestrator가 해당 batch의 실행 책임을 확보합니다.
2. [FACT] RSS adapter는 GeekNews RSS만 fetch하고, parsing 전 Raw RSS snapshot을 보존합니다.
3. [FACT] parsing 결과는 입력 오류, 기존·중복 관찰, 신규 후보 가능 관찰을 구분합니다.
4. [FACT] 후보는 Raw RSS `link` 원값으로 논리 기사에 연결합니다. 현재 기사 대상은 Asia/Seoul의 10:00 또는 22:00 예정 전달 시각과 RSS `published`의 차이가 13시간 이내인 경우이며, 정확히 13시간은 포함하고 누락·오류·미래 시각·초과·비교 불가는 명시적 결과로 보존합니다.
5. [FACT] AI adapter는 승인된 단일 무료 경로와 비용 안전 상태가 확인된 경우에만 허용 RSS 입력을 처리합니다.
6. [FACT] 정상 분석·저정보·검증 실패·provider 오류·quota 소진·미처리 결과는 서로 다른 상태와 영향 후보 수를 갖습니다.
7. [FACT] selection service는 모든 유효 후보의 필요한 AI 처리가 완료된 경우에만 승인된 정책에 따라 최대 10개 선정 결과와 제외·미처리 수량을 포함한 논리적 발송 결과를 고정합니다. 완료 불가능이 확정되면 기사 목록 대신 처리 실패 notice를 고정합니다.
8. [FACT] 10:00 또는 22:00 전달 gate는 준비된 논리적 발송 결과만 release하며, 준비되지 않은 경우 처리 중인 pipeline을 새로 시작하지 않습니다.
9. [FACT] delivery adapter는 정시 release 결과, 목표 시각 뒤 완전히 준비된 별도 처리 지연 full result, 또는 확인된 Discord 미수락의 저장 복구 결과를 서로 다른 논리 구간으로 Discord에 전달하고 수락 근거를 대조합니다.
10. [FACT] reaction·slash command 등 feedback은 원본 event와 현재 상태를 article·batch·message에 연결해 반영합니다.
11. [FACT] recovery는 저장된 원래 결과만 사용하며, 승인된 복구 규칙 밖의 RSS 재수집·AI 재분석·재선정·자동 재전송을 하지 않습니다.
12. [FACT] 품질 평가는 저장된 후보·결과·feedback·시간·비용 근거를 읽는 독립 실행 기능으로 수행하고 pipeline 상태나 선정 결과를 소급 변경하지 않습니다.

## External Integration Boundaries

### GeekNews RSS

[FACT] MVP-A 외부 입력은 GeekNews 공식 RSS 하나입니다.

[UNKNOWN] conditional request, ETag·Last-Modified, 허용 polling 빈도, feed 갱신·삭제 동작은 운영 전 실제 관찰과 공식 근거로 검증해야 합니다.

### Free-AI Provider

[FACT] AI analysis module은 batch role이 후보 처리 시 호출하는 독립 기능 경계입니다. 별도 상시 worker·queue·서비스가 아니며, Discord listener role은 호출하지 않습니다.

[FACT] module 입력은 저장된 RSS `title`, `content` 또는 `description`에 제한하고, 결과는 정상 분석·저정보·명시적 미처리·오류 중 하나로 PostgreSQL에 기록합니다.

[INFERENCE] provider adapter는 한 구현에서 하나의 승인된 무료 provider·account·model 경로만 활성화하도록 설계합니다.

[FACT] provider·model·plan·credential·quota·비용 상태가 확인되지 않거나 유료 가능성이 있으면 호출하지 않습니다.

[FACT] quota 소진은 공식 오류 근거가 있을 때만 해당 상태로 기록하며, rate limit·인증·권한·네트워크·원인 불명 오류와 혼동하지 않습니다.

[UNKNOWN] Gemini는 우선 검증 후보이지만, 최종 provider·model·SDK·prompt는 아직 확정하지 않습니다.

### Discord Delivery and Feedback

[FACT] Discord 전달 성공은 Discord 수락 근거와 필요한 message 식별자를 확보한 경우에만 기록합니다.

[FACT] reaction 등 변경 event의 주 수신 경로는 Discord Gateway이며, REST 기반 현재 상태 대조로 listener 중단·event 누락·reaction 삭제 뒤의 상태를 보완합니다.

[FACT] Gateway event와 REST 대조는 중복 수집 수단이 아니라 각각 변경 이력과 현재 상태를 확인하는 보완 경로입니다.

[FACT] REST 현재 상태 대조는 정상 Gateway event마다 또는 서버 전체를 주기적으로 polling하지 않습니다. Gateway session을 resume하지 못한 새 연결, DB 복구, Gateway event 기록 실패, feedback 기반 지표 계산 직전에만 PostgreSQL reconciliation request를 기록하고 범위 제한된 REST 대조를 실행합니다.

[FACT] REST 대조 대상은 시스템이 전달·mapping한 기사별 message와 batch 대표 message 중 품질 검토 기간에 feedback 대상인 것, 승인된 사용자 및 허용된 reaction으로 한정합니다. 다른 channel·message·사용자·reaction은 MVP-A 품질 feedback으로 처리하지 않습니다.

[FACT] Gateway event 원본 이력은 보존합니다. REST snapshot은 관측 시점의 현재 유효 상태만 갱신하며, Gateway 기록과 다르더라도 과거 event를 삭제하거나 오류로 단정하지 않습니다.

[FACT] REST 대조 실패, message 삭제 또는 권한 부족은 현재 feedback 없음으로 바꾸지 않고 `stale` 또는 `unknown` 대조 상태로 기록합니다. 해당 현재 상태가 필요한 품질 지표의 분자·분모에서는 제외하고 대조 불가 수를 별도 보고합니다.

[INFERENCE] listener는 reconnection·DB 복구를 감지하면 reconciliation request를 기록하고, 즉시 처리하지 못한 request는 승인된 Recovery / reconciliation CronJob이 durable work ledger에서 claim할 수 있습니다.

[UNKNOWN] slash command의 정확한 interaction transport·응답 방식, Gateway·REST 권한, REST rate limit·pagination, event resume·대조의 실제 동작과 reconciliation request의 retry·backoff는 Discord sandbox 검증 및 Data / Interface Design에서 결정합니다. 주기 조회만으로 feedback을 수집하는 경로는 채택하지 않습니다.

## Reliability and Recovery

[INFERENCE] 외부 AI·Discord API 호출은 PostgreSQL transaction 안에서 완료를 기다리지 않습니다. 호출 전 처리 intent를 기록하고, 호출 뒤 실제 응답 또는 오류 근거를 별도 기록하는 상태 기반 workflow를 사용합니다.

| Situation | Required treatment |
| --- | --- |
| AI 전체 실패 또는 quota 소진 | 정상 신규 0건으로 기록하지 않고, 처리 실패·영향 후보 수·비용 차단 근거를 유지합니다. |
| 유효 후보 일부의 AI 처리 미완료 | partial 기사 목록을 발송하지 않고 기존 pipeline을 계속 처리합니다. 전체 선정 완료 시 지연 full result를 발송하며, 전체 선정 불가능 시 원인별 처리 실패 notice와 미처리 수를 기록합니다. |
| Discord 명시적 미수락 | 저장된 원래 발송 결과를 자동 복구 backlog로 유지합니다. |
| Discord 수락 불명확 | 성공·미수락·자동 재전송으로 추정하지 않고, 확인 절차와 사용자 선택 상태를 유지합니다. |
| 승인된 사용자 `못 받음` | 원래 attempt·사용자 확인·재전송 attempt를 연결한 1회 즉시 재전송 예외만 허용합니다. |
| process restart 또는 batch replay | 기존 lease·처리·전달·수락 상태를 대조하고, 이미 수락된 논리 기사를 다시 전달하지 않습니다. |

[FACT] 확인된 Discord 미수락 backlog는 다음 성공 정규 발송에서 가장 오래된 원래 batch의 실제 미수락 선정 기사 최대 10개를 원래 순서로 제공합니다. 현재 기사 최대 10개와는 별도 구역으로 표시하여 총 최대 20개를 허용합니다.

[FACT] backlog가 10개를 초과하면 남은 대기 수와 가장 오래된 원래 batch를 표시하고, 승인된 사용자가 `추가 복구`를 선택할 때마다 가장 오래된 원래 batch의 남은 실제 미수락 선정 기사 최대 10개만 즉시 제공합니다. 서로 다른 원래 batch와 처리 지연 full result를 섞지 않습니다.

[FACT] 수락 불명확 attempt는 원래 attempt 뒤 1시간 안에 연결된 수신 근거가 없을 때 원래 예정 batch당 한 번의 확인 요청 대상이 됩니다. Recovery CronJob이 도래한 확인 작업을 claim해 확인 메시지를 보내고, Gateway listener가 `받음`·`못 받음`·무응답 후 사용자 복구 선택을 기록합니다. `못 받음` 또는 명시적 `추가 복구`만 저장 원래 결과의 즉시 재전송을 허용합니다.

## Scheduling and Execution Environment Candidates

[FACT] 서비스 목표는 09:30·21:30 KST 시작부터 30분 안의 발송 가능 결과 준비와, 10:00·22:00 KST 이후 1분 안의 Discord 수락입니다. 준비와 수락은 서로 다른 지표입니다.

| Candidate | Advantages | Constraints | MVP-A disposition |
| --- | --- | --- | --- |
| Existing host scheduler + long-running Python listener | 추가 플랫폼이 없고 batch·feedback 경계를 한 runtime에서 검증 가능 | host 가용성, 재시작, secret 운영을 확인해야 함 | [INFERENCE] K3s 대안 또는 로컬 검증 환경 |
| K3s CronJob + listener Deployment + PostgreSQL StatefulSet | 공통 Python 이미지를 역할별로 재사용하고, scheduled workload·상시 listener·DB를 선언적으로 배포·재시작 관리할 수 있음 | cluster, image 접근, Secret, PersistentVolume, backup/restore 및 월 0원 실행 근거가 필요 | [FACT] MVP-A 승인 방향; 구체 manifest와 storage 구현은 후속 단계 |
| Managed scheduler/queue platform | 운영 편의 가능 | 과금·free tier 변경·외부 의존성이 Hard Gate 위험을 높임 | [INFERENCE] 기본 선택 아님 |

[FACT] K3s CronJob만으로는 reaction·slash command를 즉시 수신하는 장기 실행 listener를 대체할 수 없습니다.

[FACT] K3s 배치에서 Discord Gateway listener는 Deployment로 상시 실행하고, RSS 수집 시작과 예정 전달 gate는 각각 CronJob으로 실행 후 종료합니다. 하나의 Python container image를 역할별 command로 재사용합니다.

[FACT] PostgreSQL은 K3s 내부 StatefulSet과 PersistentVolume을 사용해 durable work ledger·전달 증거·feedback 상태를 Pod 생명주기와 분리해 보존합니다.

[UNKNOWN] 실제 StorageClass, volume 장애 범위, 논리 backup·restore 실행 방식, 보관 위치 및 복원 목표는 Data / Interface Design과 실행 환경 검증에서 결정합니다.

## Observability, Security, and Cost Controls

[FACT] 각 예정 batch는 시작·결과 준비·Discord 수락·복구 수락 시각과 후보·처리·전달·미처리 수량을 구분해 기록해야 합니다.

[FACT] 계획된 예정 batch와 실제 시작·미실행, 각 CronJob claim·완료·실패, listener 연결·resume·재연결·event 기록 실패, backup 생성·검증·복원 연습 상태를 서로 구분해 관측해야 합니다.

[FACT] Hard Gate 관측은 비용 발생, 미처리 후보 조용한 제외, 의도되지 않은 중복 전달, AI 실패의 신규 0건 오표시, Discord 미수락의 성공 오표시, 중대한 RSS 근거 밖 사실 생성을 각각 독립적으로 집계합니다.

[FACT] 비용 검증에는 실행 경로별 무료 설정, 사용량·유료 사용 event, 공식 quota·과금 근거와 사용자 확인 월 청구 결과가 필요합니다.

[FACT] Discord credential, webhook URL, interaction verification secret, AI credential과 파생 민감값은 코드·문서·DB·일반 log·metric·trace·AI 입력·사용자 표시에서 노출하지 않습니다.

[INFERENCE] 운영 기록에는 비밀값을 제거한 오류 분류·시각·대상 수량·attempt 식별 근거만 남깁니다.

[FACT] 비밀값은 K3s Secret으로만 runtime 주입하고, K3s 저장소의 Secret encryption at rest를 활성화합니다. 역할별 ServiceAccount와 Secret 주입을 분리하며, 각 workload는 필요한 Secret만 받고 cluster-admin, 다른 namespace 접근, broad Secret `list`·`watch` 권한을 받지 않습니다.

[FACT] 하나의 Python container image를 Listener·CronJob 역할별 command로 재사용합니다. production 배포는 검증된 image digest와 대응 Git revision을 기준으로 하며, mutable tag 또는 image 내부의 비밀값에 의존하지 않습니다.

[FACT] 공개 image registry는 코드 공개를 수용하고 실제 storage·transfer·pull 비용 0원 조건이 검증된 경우에만 사용할 수 있습니다. registry 비용·정책·공개 범위가 불명확하면 production deployment에 활성화하지 않습니다.

[FACT] 실제 월 비용은 사용자가 직접 billing·usage·free-plan 상태로 확인합니다. 사용자가 비용 0원 위반을 확인하면, 해당 비용 발생 가능 production 경로를 중지하고 사용자 재확인 전 자동 재개하지 않습니다.

[FACT] MVP-A는 별도 운영 UI를 만들지 않습니다. 사용자는 문서화된 K3s 수동 cost kill switch로 Prepare·Delivery-gate·Recovery CronJob을 suspend하고 Listener Deployment를 scale 0으로 만들어 신규 RSS·AI·Discord 작업을 중지할 수 있습니다. PostgreSQL·PersistentVolume은 자동 삭제·중지하지 않습니다.

[FACT] workload 중지는 AI·Discord 등의 신규 호출을 차단하지만, K3s host·PersistentVolume·backup 저장소·image registry 비용을 자동으로 제거하지 않습니다. 유료 인프라의 중지·해제는 데이터 보존 상태를 확인한 뒤 사용자가 별도 판단합니다.

[FACT] 품질 평가는 별도 상시 서비스나 queue가 아니라 같은 Python image의 독립 command 또는 function으로 실행합니다. 최소 표본이 쌓인 뒤 예약 또는 사용자 요청으로 실행할 수 있으며, 정확한 실행 시점·입력 snapshot·산식·보고 형식은 Data / Interface Design에서 결정합니다.

[UNKNOWN] Secret rotation·mount 방식, namespace·RBAC·Pod security manifest, registry 제공자·공개 범위, image build/push 방식, cost kill switch의 구체 명령 및 host·storage 비용 기준은 Data / Interface Design과 실행 환경 검증에서 결정합니다.

## MVP-A and MVP-B Boundary

| Area | MVP-A | MVP-B or later |
| --- | --- | --- |
| Data preservation | feedback·품질 검토에 필요한 최소 증거 보존 | 장기 AI 결과 재사용 확장과 자동 Retention lifecycle |
| Insight | 초기 사용량·지연·품질 측정 근거 | 월별 normalization·aggregation·Insight 생성 |
| Lifecycle tuning | 삭제 정책을 자동화하지 않음 | retention 기간, 삭제 순서, VACUUM, partition 검토 |
| Performance tuning | 100건/일과 30분 목표의 실제 검증 | COPY·대량 DELETE·partition benchmark |
| Runtime | 비용 0원·feedback 가능성 검증 | 검증된 운영 규모에 따른 인프라 확장 |

[FACT] 초기 Notion 계획의 월별 Insight, 한 달 단위 삭제, VACUUM, partition은 MVP-A Architecture의 구현 범위가 아닙니다.

## Key Architecture Decisions

| ID | Decision | Recommendation | Status |
| --- | --- | --- | --- |
| AD-01 | Application boundary | 하나의 Python 코드베이스에서 Cron 수집 trigger와 PostgreSQL commit 기반 batch pipeline·전달 gate를 담당하는 role, 상시 Gateway event dispatcher인 listener role을 책임 분리 | [FACT] 2026-09-01 사용자 승인 |
| AD-02 | Durable state | PostgreSQL을 예정 batch·attempt·intent·외부 응답·전달 근거·feedback·복구의 단일 제어 기준으로 사용하고, DB 장애·무결성 불명 시 외부 효과를 fail-closed | [FACT] 2026-09-01 사용자 승인 |
| AD-03 | Work coordination | 별도 queue 없이 PostgreSQL durable work ledger와 lease로 작업을 조정하며, 외부 효과 불명확 작업은 lease 만료만으로 재실행하지 않음 | [FACT] 2026-09-01 사용자 승인 |
| AD-04 | AI safety boundary | batch role이 호출하는 단일 무료 AI analysis module을 두고, 비용·plan·quota 상태 불명확 시 fail-closed로 호출을 차단 | [FACT] 2026-09-01 사용자 승인 |
| AD-05 | Discord feedback | 상시 Gateway listener event dispatcher를 변경 event의 주 경로로 사용하고 REST 현재 상태 대조로 event 누락·삭제·재시작을 보완 | [FACT] 2026-09-01 사용자 승인; 외부 계약은 sandbox 검증 필요 |
| AD-06 | Execution environment | K3s에서 Gateway listener Deployment, RSS 수집·전달 gate CronJob, PostgreSQL StatefulSet + PersistentVolume을 운영하고 하나의 Python container image를 역할별로 재사용 | [FACT] 2026-09-01 사용자 승인; storage·backup·비용 검증은 필요 |
| AD-07 | Delivery ambiguity | 수락 불명확 자동 재전송 금지, 사용자 확인 기반 1회 예외 | [FACT] 승인된 요구사항 |
| AD-08 | Pipeline handoff and recovery | Prepare·Delivery-gate·Recovery/Reconciliation CronJob은 실행 기회만 만들고, 다음 단계는 PostgreSQL commit·work claim으로 진행합니다. 외부 효과 불명확 건은 Recovery가 자동 재호출·재발송하지 않습니다. | [FACT] 2026-09-01 사용자 승인; 실제 주기·retry·backoff는 후속 설계 |
| AD-09 | DB durability and restore | 단일 PostgreSQL StatefulSet + PersistentVolume, 별도 실패 영역의 논리 backup, 수동 검증 restore를 사용하고 HA DB cluster는 MVP-A에 도입하지 않음 | [FACT] 2026-09-01 사용자 승인; backup 구현·RTO/RPO는 후속 설계 |
| AD-10 | DB trust failure boundary | DB 연결·commit·무결성 불명 시 AI·Discord 외부 효과와 feedback business mutation을 중단하고, 복구·ledger 대조 뒤에만 재개 | [FACT] 2026-09-01 사용자 승인; backup 공백 한계는 후속 설계 |
| AD-11 | Feedback reconciliation trigger | Gateway를 변경 이력의 주 경로로 사용하고, 새 Gateway 연결·DB 복구·event 기록 실패·지표 계산 직전에만 추적 대상 REST 현재 상태를 대조 | [FACT] 2026-09-01 사용자 승인; 실제 retry·backoff는 후속 설계 |
| AD-12 | Feedback reconciliation failure | REST 대조 실패·message 삭제·권한 부족을 feedback 없음으로 처리하지 않고 `stale` 또는 `unknown`으로 보존해 관련 현재 상태 지표에서 제외 | [FACT] 2026-09-01 사용자 승인; status 구현은 후속 설계 |
| AD-13 | Secret and least privilege | K3s Secret encryption at rest, 역할별 ServiceAccount·필요 Secret 주입, 비밀값의 코드·image·DB·log 비노출을 사용 | [FACT] 2026-09-01 사용자 승인; rotation·manifest는 후속 설계 |
| AD-14 | Image deployment | 하나의 Python image를 역할별 command로 재사용하고 검증된 image digest·Git revision으로 배포. 공개 registry는 코드 공개 수용 및 비용 0원 검증 시에만 사용 | [FACT] 2026-09-01 사용자 승인; registry 선택은 실행 환경 검증 |
| AD-15 | Cost activation gate | 사용자가 모든 실행 경로의 비용 0원을 직접 확인하고, 위반 확인 시 비용 발생 가능 production 경로를 중지하며 사용자 재확인 전 자동 재개하지 않음 | [FACT] 2026-09-01 사용자 승인; 비용 기준·증거 형식은 후속 설계 |
| AD-16 | Manual cost kill switch | 별도 운영 UI 대신 문서화된 K3s CronJob suspend와 Listener Deployment scale 0으로 신규 외부 작업을 중단. PostgreSQL·PVC 자동 삭제·중지는 금지 | [FACT] 2026-09-01 사용자 승인; 실제 명령·인프라 해제 절차는 후속 설계 |
| AD-17 | AI 선정 완결성 | 유효 후보의 AI 판단이 미완료인 동안에는 부분 기사 목록을 발송하지 않음. 모든 유효 후보의 판단과 선정이 완료되면 원래 batch의 지연 full result로 최대 10개를 발송 | [FACT] 2026-09-01 사용자 승인; 후보별 재시도·backoff·전체 선정 불가 판정 기준은 후속 검증 |
| AD-18 | 전체 선정 불가 처리 | quota 소진·비용 차단·영구 오류로 전체 선정을 완료할 수 없으면 기사 목록 대신 원인과 미처리 건수를 포함한 처리 실패 notice 발송. 유료 또는 다른 provider 자동 fallback 금지 | [FACT] 2026-09-01 사용자 승인; 원인별 상태 코드와 notice 표시 형식은 후속 설계 |
| AD-19 | Scheduled delivery timing | Discord 전달 attempt는 10:00·22:00 KST보다 먼저 시작하지 않고, 해당 시각부터 1분 안의 Discord 수락을 정시 목표로 측정 | [FACT] 2026-09-01 사용자 승인; CronJob 기동·clock 오차 검증 필요 |
| AD-20 | Processing-delayed full result | 선정이 목표 시각 뒤 완료되면 기존 pipeline이 원래 batch의 최대 10개 결과를 별도 처리 지연 batch로 즉시 발송. Discord 미수락 복구 backlog와 혼합하지 않고, commit 뒤 attempt 전 중단에만 Recovery가 같은 결과를 claim | [FACT] 2026-09-01 사용자 승인; 상태·claim 세부는 후속 설계 |
| AD-21 | Confirmation and recovery execution | 수락 불명확의 1시간 확인·대조 작업은 Recovery CronJob이 claim하고, Gateway listener는 `받음`·`못 받음`·추가 복구 선택을 기록. 확인된 미수락 backlog는 다음 정규 발송에서 가장 오래된 원래 batch 최대 10개를 우선 복구 | [FACT] 2026-09-01 사용자 승인; interaction 계약·주기 세부는 후속 검증 |
| AD-22 | Backup recovery gate | backup 공백 한계 초과 또는 DB restore 뒤 outbound를 중지하고, 새 backup 복원 가능성·DB 무결성·필요한 ledger/Discord 대조를 완료한 뒤 사용자 수동 승인으로만 재개 | [FACT] 2026-09-01 사용자 승인; 공백 한계·RPO·RTO·도구는 후속 설계 |
| AD-23 | Evaluation execution boundary | 같은 Python image의 독립 command/function이 저장된 표본과 운영 근거를 읽어 품질·Hard Gate·서비스 목표를 평가하며 별도 상시 service·queue는 두지 않음 | [FACT] 2026-09-01 사용자 승인; 실행 시점·snapshot·산식은 후속 설계 |

## Deferred to Data / Interface Design

- [UNKNOWN] table·column·index·constraint·migration과 정확한 transaction 구현
- [UNKNOWN] 상태명·상태 전이·lease 키·동시성 제어와 idempotency 세부 구현
- [UNKNOWN] RSS polling·conditional request·timeout·retry·backoff 값
- [UNKNOWN] AI provider·model·SDK·prompt·structured output schema·원인별 retry·backoff·전체 선정 불가능 판정
- [UNKNOWN] Discord message 분할, article·batch·message mapping, reaction·button·slash command UI
- [UNKNOWN] 10:00·22:00 전달 gate의 실제 CronJob 기동 지연·clock 동기화 허용치와 처리 지연 full result claim 상태 전이
- [UNKNOWN] 수락 불명확 1시간 확인, 다음 성공 정규 발송, `추가 복구` request의 정확한 상태·idempotency·interaction contract
- [UNKNOWN] GeekNews topic link 문법과 제출값 validation 경계
- [UNKNOWN] secret 주입·회전·권한, 정확한 runtime·deployment·scheduler 설정
- [UNKNOWN] backup 공백 한계·RPO·RTO, backup 생성·복원 검증 도구와 수동 outbound 재개 절차
- [UNKNOWN] 지표 산식, snapshot 시각, 품질 평가 표본·독립 evaluation 실행 시점과 보고 형식
- [UNKNOWN] MVP-A 검증 이후 retention·월별 Insight·VACUUM·partition 정책

## Risks and Validation Experiments

| Risk | Minimum experiment | Expected evidence |
| --- | --- | --- |
| 무료 AI 처리량과 비용 안전성 | 0·1·99·100·101 후보 workload와 quota·형식·timeout fault에서 전체 선정 완료·불가를 검증 | 실제 요청 수, 처리 시간, 지연 full result·실패 notice, 유료 경로 0건 근거 |
| 품질 평가 실행 | 최소 2주·20개 예정 batch·50개 후보 표본을 독립 evaluation runner로 재계산 | 동일 snapshot 재실행 결과, 6개 Hard Gate와 품질·서비스 목표의 분리 보고 |
| Discord feedback 적합성 | sandbox에서 reaction 추가·삭제·중복·재수신, slash command, listener restart 후 범위 제한 REST 대조 | 사용자·article·batch·message mapping과 현재 상태 복원·대조 불가 보존 |
| Discord 전달·복구 | 429·5xx·timeout·응답 유실, 1시간 확인, `받음`·`못 받음`·무응답·추가 복구 fixture | 성공 오기록·자동 중복 재전송 0건, 가장 오래된 원래 batch 최대 10개와 현재 최대 10개의 분리 |
| RSS 계약과 시간 경계 | feed 변동, parsing 오류, conditional request, `published` 누락·오류·미래·정확히 13시간·초과 관찰 | snapshot·입력 검증·Asia/Seoul 최신성 판정 재현성 |
| DB 기반 recovery | 내부 commit 전후 process 중단, lease 만료, batch replay, 동시 실행, delivery replay | 후보 유실·의도되지 않은 중복 전달 0건, 불명확 외부 효과 자동 재호출 0건 |
| K3s scheduling and listener | 실제 CronJob cold start·clock 오차와 listener disconnect·resume을 포함한 2주·20개 예정 batch 실행 | 30분 준비율, 목표 시각 후 1분 수락률, 미실행 batch와 listener 가용성 근거 |
| PostgreSQL backup and restore | 별도 실패 영역 backup 생성·검증, 복원 rehearsal, ledger·Discord 대조와 수동 재개 | 목표 RPO/RTO 근거, 손실 범위, 재개 전 검증·승인 기록, 중복 외부 효과 0건 |
| 월 추가 비용 0원 | K3s host·storage·registry·backup·AI·Discord 실행 경로와 kill switch 검증 | 사용자 확인 billing·usage·plan 근거, 위반 시 차단과 자동 재개 0건 |

## Traceability

| Architecture concern | Primary requirements |
| --- | --- |
| RSS input, identity, raw evidence | FR-001~005, DR-001~005, EXT-GN-001~005 |
| Evidence-bounded AI and cost safety | FR-006~014, NFR-COST-001, NFR-DQ-001, EXT-AI-001~007 |
| Discord delivery, recovery, duplicate guardrail | FR-015~016, NFR-REL-001~002, EXT-DC-001~006 |
| Feedback and quality measurement | FR-017~024, DR-010~014, EXT-FB-001~006, VR-006~010 |
| Scheduling, freshness and latency | NFR-PERF-001, NFR-LAT-001, NFR-LAT-002, DR-006~009, EXT-GN-006, VR-008 |
| PostgreSQL state, idempotency and recovery | NFR-REL-001~003, NFR-DQ-002, DR-006~009, VR-004~005 |
| Observability, security and cost controls | NFR-OBS-001~003, NFR-SEC-001~003, NFR-COST-001, VR-006·VR-009·VR-011 |
| Runtime, backup and variable external contracts | NFR-MNT-001~002, VR-001~005, VR-008~011 |

## Approval Checkpoint

[FACT] 이 문서는 승인된 Product Specification과 Technical Requirements를 변경하지 않고 MVP-A Architecture를 정의합니다.

[FACT] 사용자는 2026-09-01 Asia/Seoul에 AD-01~AD-23의 문서 반영과 정합성 검증 결과를 확인한 뒤 Architecture 문서 전체를 최종 승인했습니다.

[UNKNOWN] 무료 AI·Discord sandbox 검증과 K3s storage·backup·비용 검증 결과는 사용자 승인 전 확정사항이 아닙니다.

[FACT] 이 문서의 승인만으로 DB schema, API contract, infrastructure, code, test 또는 deployment 구현을 시작할 수 없습니다. 다음 단계인 Data / Interface Design에서 해당 상세 항목을 별도로 설계·승인해야 합니다.

## User Confirmation Checklist

| ID | 확인할 결정 | 선택지/기준 | 추천안 | 승인 필요 여부 |
| --- | --- | --- | --- | --- |
| UC-01 | Application·work coordination | 단일 장기 process / K3s 역할 분리 + PostgreSQL ledger / 외부 queue | AD-01·03·06의 Candidate B | [FACT] 승인됨 |
| UC-02 | AI·Discord 경계 | 단일 무료 AI fail-closed, Gateway-first + triggered REST, 불명확 자동 재전송 금지 | AD-04·05·07·11·12·17·18 | [FACT] 승인됨 |
| UC-03 | 시간·지연·복구 | 정시 attempt·1분 수락, 처리 지연 full result, 가장 오래된 Discord 미수락 batch 복구 | AD-19·20·21 | [FACT] 승인됨 |
| UC-04 | K3s·PostgreSQL·보안·비용 | StatefulSet/PV, 별도 backup, 최소 권한·암호화, 수동 kill switch와 재개 gate | AD-09·10·13~16·22 | [FACT] 승인됨 |
| UC-05 | 품질 평가 실행 경계 | 운영 pipeline 내장 / 독립 command / 별도 service | 같은 image의 독립 command/function인 AD-23 | [FACT] 승인됨 |
| UC-06 | Architecture Draft 전체 | 개별 결정의 문서 반영·정합성 검증 결과를 기준으로 단계 완료 여부 판단 | 검증 결과 확인 뒤 전체 승인 | [FACT] 2026-09-01 승인됨 |

## Recommended Next Action

[INFERENCE] 다음 한 가지 작업은 Workflow 7 단계 종료 Git Review를 수행하고 Architecture 승인 문서를 commit·push할지 결정하는 것입니다. commit·push 완료 또는 사용자의 명시적 연기 전에는 Data / Interface Design으로 이동하지 않습니다.
