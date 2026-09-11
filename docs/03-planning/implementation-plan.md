# MVP-A Implementation Plan

## Document Status

[FACT] Workflow 단계: 9. Implementation Plan

[FACT] 상태: Approved baseline / Audit corrections approved — WBS-01~31과 PLAN-CONSISTENCY-01의 기준선은 2026-09-09 사용자 승인을 받았습니다. F01·F02 단독 수정에 이어 2026-09-10 사용자의 잔여 항목 일괄 진행 요청에 따라 F03~F08 문서 수정을 반영했으며, 2026-09-10 변경 후 사용자 승인을 받았습니다. 이는 실제 WBS 실행·Coding Readiness 통과가 아닙니다. 현재 작업 상태는 [AI Context](../../ai-context.md), 수정 경위는 [검토 이력](implementation-review-history.md#sequential-review-state)을 참조합니다. Git 확인·commit·push는 사용자가 직접 관리하며 현재 반영 여부를 이 문서에서 추정하지 않습니다.

[FACT] 이 문서는 승인된 Product Specification, 99개 Technical Requirements, Architecture, Logical Data Model과 Logical Interface Specification을 변경하지 않고 구현 순서·작업 단위·의존성·검증·승인 지점을 계획합니다.

[FACT] 이 문서는 애플리케이션 코드, DB migration·SQL schema, 실제 외부 API contract, Kubernetes manifest 또는 배포를 구현하거나 확정하지 않습니다.

[FACT] WBS 항목별 정의는 순차 검토와 사용자 승인을 거쳐 확정하며, Workflow 10 Coding Readiness Check 통과 전 production code 구현을 시작하지 않습니다.

## Planning Context

- [FACT] Workflow 1~8은 사용자 승인과 단계 종료 commit·push를 완료했습니다.
- [FACT] 현재 Requirement는 FR 24개, NFR 17개, DR 14개, EXT 25개, VR 19개로 총 99개이며 우선순위는 P0-HG 34개, P0 44개, P1-V 21개입니다.
- [FACT] 승인된 Architecture Decision은 AD-01~AD-23이고, 승인된 Data / Interface Design Decision은 DDI-01~DDI-10과 MIN-01~MIN-08입니다.
- [FACT] Interface Specification은 별도 Decision ID를 만들지 않고 DDI/MIN register를 정본으로 사용합니다.
- [FACT] Repository에는 애플리케이션 코드, DB schema·migration, 테스트, 실행 설정, container/Kubernetes 구성과 배포 결과가 없습니다.
- [FACT] MVP-A는 일일 큐레이션, 최소 추적·feedback·측정을 포함합니다. 월별 Insight, 장기 재사용·normalization과 자동 Retention lifecycle은 MVP-B입니다.

### Resolved Documentation Consistency Issues

- [FACT] PLAN-CONSISTENCY-01에서 `architecture.md`의 존재하지 않는 `NFR-OBS-003`, `NFR-SEC-003` 참조를 실제 Requirement 범위 `-001~002`로 정정했습니다.
- [FACT] PLAN-CONSISTENCY-01에서 `requirements.md`의 Workflow 8 승인 전 상태 문구를 2026-09-04 최종 승인 기록과 일치시켰습니다.
- [FACT] 두 정정은 승인된 Requirement·Architecture·Logical Data/Interface Design의 의미를 변경하지 않는 reference·상태 정합성 수정입니다.

## Planning Assumptions and Unknowns

### Assumptions

- [ASSUMPTION] 구현은 승인된 하나의 Python 코드베이스·image, PostgreSQL 및 K3s 역할 분리 구조를 따릅니다.
- [ASSUMPTION] 외부 계약 spike는 production 기능이 아닌 제한된 공식 자료·sandbox·fixture 검증이며, 결과가 불충분하면 관련 구현을 시작하지 않습니다.
- [ASSUMPTION] 각 구현 Task는 독립적으로 review·test·rollback할 수 있는 변경 단위로 운영합니다.
- [ASSUMPTION] 단위·계약 테스트는 각 구현 Task에 포함하고 별도 통합 검증이 이를 대체하지 않습니다.
- [ASSUMPTION] MVP-A에서는 자동 Retention, 월별 Insight, 전역 keyword taxonomy·normalization을 구현하지 않습니다.

### Unknowns

- [UNKNOWN] 최종 무료 AI provider·model·SDK·prompt, structured output, retry/backoff와 전체 선정 불가능 판정
- [UNKNOWN] 중요도·관심 적합성의 물리 표현, 홍보성 code·임계값, 동률 처리와 품질 검토 rubric
- [UNKNOWN] PostgreSQL version·driver·ORM 여부, table·column·index·constraint·migration 도구, isolation·lease 기간
- [UNKNOWN] RSS polling·timeout·conditional request·link validation과 장기 update 동작
- [UNKNOWN] Discord identifier·권한·rate limit·resume·pagination·interaction transport·payload 분할·UX
- [UNKNOWN] 장기 Discord 장애 backlog 상한·분할과 receipt 상충 해소 절차
- [UNKNOWN] K3s StorageClass·registry·clock 오차·CronJob cold start·Secret rotation·RBAC
- [UNKNOWN] backup 도구·실패 영역·공백 한계·RPO/RTO·보존 기간
- [UNKNOWN] evaluation 계산·manifest digest·표본 선택·검토자·보고 형식
- [UNKNOWN] MVP-A 품질 검토 완료 이후 임시 데이터의 수동 보존·정리 정책
- [UNKNOWN] 전체 운영 경로의 추가 월 비용 0원 충족 여부

## Implementation Strategy

[INFERENCE] 권장 순서는 `추적성 기준선 → 외부 계약 spike → 물리 설계 → Coding Readiness Check → 내부 상태 기반 → RSS → AI·선정 → Discord 전달 → feedback·recovery → 평가·backup → 통합 검증 → 배포 artifact → Workflow 13~15 Code Review·문서/Context 동기화·Git closure → Deployment Readiness → 단계별 배포·activation → 2~4주 Monitoring·Evaluation → Retrospective·MVP-A disposition → MVP-A 기반 MVP-B incremental-entry 결정`입니다.

1. [INFERENCE] 외부 계약을 먼저 검증해 retry, payload, 상태와 schema에 근거 없는 값을 고정하지 않습니다.
2. [INFERENCE] PostgreSQL schema와 work ledger를 외부 adapter보다 먼저 확정해 `prepared → invocation_started → evidence` 경계를 일관되게 적용합니다.
3. [INFERENCE] configuration/secrets/outbound gate는 첫 AI·Discord 호출보다 먼저 구현합니다.
4. [INFERENCE] RSS와 candidate admission을 먼저 완성해 AI 없이 identity·중복·최신성·수량을 검증합니다.
5. [INFERENCE] immutable selection을 Discord보다 먼저 고정해 전달 실패가 선정 결과를 바꾸지 않게 합니다.
6. [INFERENCE] delivery mapping 뒤에 feedback과 recovery를 구현합니다.
7. [INFERENCE] 관측성·비용·보안 검증은 각 Task 완료 기준에 포함하고 통합 단계에서 다시 검증합니다.
8. [FACT] 배포 준비, 실제 배포와 2~4주 운영 검증은 별도 단계와 승인 지점입니다.

## Work Breakdown Structure

[INFERENCE] 아래는 구현 후보 Task이며, 물리 설계와 spike 결과가 승인되기 전에는 실제 구현 방식이 확정된 것으로 간주하지 않습니다.

| ID | 작업 단위 | 목적 | 선행 조건 | 주요 산출물 | 관련 Requirement / Decision | 완료 기준 | 위험 |
| -- | ----- | -- | ----- | ------ | ------------------------- | ----- | -- |
| [WBS-01](validation-traceability-plan.md#requirement-traceability-plan) | Traceability 기준선과 coverage gate | 99개 Requirement를 설계·spike·구현·검증·승인 Task에 양방향 연결 | 승인된 Workflow 1~8 문서 | 99행 Requirement matrix, AC-01~24 mapping, 6개 Hard Gate evidence map, evidence 경로 규칙, 문서 불일치 register, 자동 coverage 검사 | 전체 99개, VR-001, AD-01~23, DDI-01~10, MIN-01~08 | Requirement 99개·AC 24개·AD 23개·DDI 10개·MIN 8개의 누락·중복·orphan이 없고, 각 Requirement에 primary realization owner와 verification owner가 있으며 모든 P0-HG에 negative/fault evidence가 지정됨 | 초기 정합성 검토 전 누락·잘못된 참조 위험; 완료 후에는 후속 문서 변경에 따른 재발 위험만 남음 |
| [WBS-02](validation-traceability-plan.md#external-validation--spike-plan) | 외부 Validation 승인 gate | 독립적인 SPK-01~06 결과를 취합하고 관련 상세 설계의 시작·완료 허용 여부 판정 | WBS-01 승인, 사용자 승인 sandbox/account 범위, SPK-06A 사전 비용 안전 확인 | spike별 dated evidence, contract/configuration fingerprint, redacted result, pass/fail/blocked/inconclusive 판정, 영향 WBS·결정 owner, 사용자 승인 기록 | EXT 전체, VR-004·008~011, AD-04~06·09·15·19·22 | 각 spike가 독립 판정되고 실패·blocked·inconclusive 항목이 의존 WBS를 차단하거나 명시적 사용자 결정에 연결되며, 선택할 provider·실제 외부 계약과 비용 조건이 승인됨 | 최초 미검증 위험은 해소되지만 외부 계약 변경 위험은 남아 VR-011 재검증 필요 |
| [WBS-03](design-readiness-plan.md#wbs-03-internal-review-checkpoints) | 실행 역할·configuration/secrets·outbound control 상세 설계 | 하나의 Python image에서 역할별 실행·권한을 분리하고 immutable configuration, Secret, contract/cost evidence, 운영 활성화와 작업별 fail-closed 경계를 정의 | WBS-01, WBS-02의 관련 pass evidence와 사용자 승인 외부 계약 | 역할·entry-point 책임표, configuration 계층·precedence·version·batch binding 계약, Secret inventory·주입·rotation·redaction 정책, ServiceAccount·DB 권한 matrix, operation별 outbound/mutation gate decision table, pause/resume·kill-switch handoff, negative verification plan | FR-015~016, NFR-COST-001, NFR-OBS-001, NFR-SEC-001~002, NFR-MNT-001, NFR-REL-003, NFR-REC-001, DR-014, EXT-AI-003~004, EXT-FB-006, VR-009·011·013·018, AD-01~08·10~16·21~23, DDI-04~06·08·10, MIN-01~03·05~07 | 각 외부 호출·business mutation이 해당 operation에 적용되는 role/work·lease 또는 session, DB 신뢰, configuration·contract·cost·credential 조건과 명시적 비적용 항목 및 차단 결과에 연결되고, Secret 원값이 저장·log·AI input에 포함되지 않으며, 진행 중 batch의 snapshot 불변성과 역할별 금지 동작을 fixture로 검증할 수 있음 | 설계 모호성은 해소할 수 있지만 실제 gate 우회·Secret 노출·RBAC·동시성 오설정 위험은 WBS-11·13·20·23~24·27~28까지 잔존 |
| [WBS-04](design-readiness-plan.md#wbs-04-internal-review-checkpoints) | PostgreSQL 물리 schema·migration 설계 | 논리 모델을 물리 구조와 migration 전략으로 변환하고 후속 상세 계약을 반영해 물리 기준선 closure | baseline: WBS-01~03과 WBS-02 관련 evidence; final closure: WBS-05~08 승인 결과 | logical-to-physical disposition, no-table/deferred register, table/column/type·PK/FK/index/constraint 결정안, query-index map, migration·rollback·verification 계획 | DR-001~014, NFR-DQ-002, NFR-OBS-001, NFR-REL-001~002, NFR-SEC-001, AD-02·03·09·10·13·22, DDI-01~10, MIN-01~08, VR-012~019 | 모든 logical 항목의 physical disposition과 canonical owner, append-only·uniqueness·reference 경계가 근거에 연결되고 blocking physical unknown 0건, Secret·자유형 raw payload·MVP-B lifecycle의 무승인 포함 0건 | 설계 순환, 과도한 분리·값 중복, application-only 무결성, 외부 계약 추측 또는 destructive rollback |
| [WBS-05](design-readiness-plan.md#wbs-05-internal-review-checkpoints) | 상태 전이·transaction·lease 상세 설계 | durable work ledger의 logical key·상태·claim/lease/fencing과 내부 재개·불명확 외부 효과의 fail-closed 구현 계약 결정 | WBS-04.A~B baseline, SPK-04 | work key·trigger catalog, 상태 전이·권한표, claim/lease/fencing·transaction semantic, external invocation·late evidence 계약, finalization/handoff·crash-point fault matrix | FR-004~005, NFR-REL-001~003, NFR-REC-001, VR-004~005·013~019, AD-02·03·08·10, DDI-05·09, MIN-05·06 | claim 실패·동시 claim·lease 교체·stale token·commit 전후 중단·DB 불신·prepared/invocation-started 중단·late evidence·finalization별 허용/금지 상태와 후속 owner가 있고 자동 외부 재호출·stale commit·terminal 오판 경로가 없음 | exactly-once 오해, logical key 충돌, application-only fencing, 불명확 외부 효과 자동 재실행 또는 domain-specific 계약과의 순환 |
| [WBS-06](design-readiness-plan.md#wbs-06-internal-review-checkpoints) | AI 처리·선정 상세 계약 | 승인된 단일 무료 AI의 evidence-bounded 입력·version·output validation·attempt/retry와 후보·batch completion·selection/failure notice 계약 확정 | SPK-02·06, WBS-03, WBS-04.A~B baseline, WBS-05와 사용자 provider 승인 | provider/contract/cost gate, input·model·prompt·policy·output version register, 정상·저정보 validator, error/retry terminal map, candidate/batch completion matrix, selection/finalization·delivery handoff | FR-006~014, NFR-COST-001, NFR-DQ-001~002, NFR-PERF-001, NFR-REL-001~002, NFR-SEC-001, EXT-AI-001~007, VR-004·008·011·013·016~019, AD-04·08·15·17·18·20, DDI-02·05·06·09, MIN-04·06·08 | 단일 free-only 계약과 모든 후보의 정상·저정보·명시적 미처리 lineage, retry 가능/terminal·전체 선정 불가능, 최대 10개 immutable result와 current/delayed handoff를 fixture로 판정하며 유료 전환·근거 밖 사실·partial release·미처리 은폐·late result 소급 적용 경로가 없음 | provider 품질·quota·계약 변경, 저정보/실패 오분류, 재시도 폭증, partial list 유출, 중요 기사 누락 또는 평가 rubric과 운영 policy 순환 |
| [WBS-07](design-readiness-plan.md#wbs-07-internal-review-checkpoints) | Discord 전달·feedback·recovery 상세 계약 | operation별 실제 Discord contract, logical rendering·physical mapping, server acceptance, Gateway/REST feedback, interaction와 receipt/recovery의 분리된 실행 계약 확정 | baseline: SPK-03·06, WBS-03, WBS-04.A~B, WBS-05; final closure: WBS-06.F의 immutable result·handoff와 사용자 승인 Discord contract | capability/identity/permission register, segment·rendering·message mapping, delivery attempt·acceptance matrix, Gateway event·feedback projection, bounded REST reconciliation, missing/receipt interaction, confirmation·recovery contract | FR-012~023, NFR-REL-001~003, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-MNT-002, NFR-REC-001, NFR-TIME-001, DR-008~012, EXT-DC-001~006, EXT-FB-001~006, VR-003~005·008·009·010·011·012~013, AD-03·05·07~08·10~13·15~16·19~23, DDI-03~06·08·10, MIN-01·05·07~08 | message별 Discord 수락·recipient receipt·feedback·review·recovery의 canonical owner와 금지 전이가 분리되고, current/delayed/recovery/notice/confirmation segment·10/10/20 상한·부분 수락·상충·lost handoff를 실제 contract evidence와 fixture로 판정 가능 | sandbox 계약·권한·payload·rate limit 불일치, 수락 성공 오판, feedback/receipt 의미 혼합, 수락 불명확 자동 재전송, current/delayed/recovery 혼합 또는 장기 backlog |
| [WBS-08](design-readiness-plan.md#wbs-08-detailed-review-checkpoints) | 운영·backup·evaluation 상세 설계 | 운영·비용 evidence, backup run·restore validation·수동 outbound recovery, metric source lineage와 사용자 요청 기반 immutable evaluation의 구현·검증 계약 확정 | baseline: SPK-04~06, WBS-03, WBS-04.A~B, WBS-05; metric/evaluation closure: WBS-06.F·07 consistency와 사용자 승인 | operational evidence·관측/alert 의미표, cost coverage·pause/resume 계약, backup/restore runbook·RPO/RTO 결정안, metric catalog, evaluation work·manifest·snapshot·typed result/report contract | FR-024, NFR-REL-002~003, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-001~002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-REC-001, NFR-TIME-001, DR-013~014, VR-001·006~011·014, AD-03·05~06·09~12·15~16·22~23, DDI-04~06·08·10, MIN-02~03·05 | 비용 범위·backup restoreability·source completeness가 evidence에 연결되고, 성공 evaluation만 immutable snapshot과 typed result를 만들며, 6개 Hard Gate의 `pass/fail/not_measurable`, 표본의 충족/판정 불충분, 품질·서비스 목표의 충족/미달/측정 불가를 독립적으로 재현하고 자동 evaluation·restore·outbound resume가 없음 | 공통 실패 영역 backup, 검증 없는 restore·자동 재개, 숨은 비용, mutable projection·누락 evidence 기반 false pass, 표본 부족의 품질 통과 또는 evaluation의 운영 source mutation |
| [WBS-09](design-readiness-plan.md#wbs-09--coding-readiness-check-상세-checkpoint) | Coding Readiness Check | 코드 구현 진입 가능 여부 판정 | Workflow 9 계획 승인·문서/context 동기화·Git closure, WBS-01~08의 필요한 실제 산출물·spike evidence·결정 승인 | readiness evidence register, blocker·non-blocking accepted risk, WBS-10 branch/test/rollback 계획, 최종 판정 | 전체 99개, VR-001·011, 전체 P0-HG, AD-01~23, DDI-01~10, MIN-01~08 | 모든 blocking check가 dated evidence로 `pass`이고 owner 없는 미확정 계약·숨은 MVP-B 범위가 없으며 비차단 위험과 WBS-10 구현 진입을 사용자가 승인 | 계획 항목 승인만으로 실제 readiness 통과, 미해결 사항을 기본값·accepted risk로 숨김 |
| [WBS-10](feature-implementation-plan.md#wbs-10--python-실행테스트-기반-상세-checkpoint) | Python 실행·테스트 기반 | 하나의 codebase/image와 두 runtime role·다섯 명시적 command를 수용할 최소 기반 구축 | WBS-09 실제 `READY`와 사용자 승인 WBS-10 branch/test/rollback 범위 | installable package skeleton, explicit command dispatch, 승인 runtime/dependency lock, 비민감 configuration bootstrap, network-free test harness | NFR-MNT-001~002, NFR-SEC-001~002, AD-01·03·06·14·23 | Clean checkout에서 승인 도구로 설치·test·각 command dispatch가 재현되고 미구현 command는 외부 호출·DB mutation·정상 0건 없이 fail-closed하며 실제 network 접근·ambient credential 사용 0건 | framework/plugin 과설계, 미구현 command의 false success, 실제 외부 호출·credential 오사용 또는 WBS-27 배포 범위 혼입 |
| [WBS-11](feature-implementation-plan.md#wbs-11--configurationsecretoutbound-gate-구현-상세-checkpoint) | Configuration·Secret·outbound gate 구현 | 비용·계약·DB 신뢰·pause 상태의 operation/scope별 fail-closed 보장 | WBS-03~05·10; A~B는 WBS-12 전 가능, DB-backed C~H integration closure는 WBS-12 필요 | typed config loader, Secret handle boundary, configuration/evidence repository, operation gate, pause/kill-switch/manual-resume handoff | FR-015~016, NFR-REL-003, NFR-COST-001, NFR-OBS-001, NFR-SEC-001~002, NFR-REC-001, DR-014, EXT-AI-003~004, EXT-FB-006, VR-009·011·013·018, AD-02~04·10·13~16·22, DDI-05~06, MIN-03·05·07 | Unknown/ambient configuration 자동 선택·billing API·Secret 저장 0건, 각 외부 invocation 직전 typed gate reason/evidence 재검증, pause 뒤 신규 invocation·자동 resume 0건과 DB integration·redaction/fault test 통과 | 임시 정본·application-only gate, TOCTOU 우회, Secret 파생값 노출, in-flight 취소 추정 또는 정상화 기반 자동 resume |
| [WBS-12](feature-implementation-plan.md#wbs-12--postgresql-schemamigration-구현-상세-checkpoint) | PostgreSQL schema·migration 구현 | 승인된 physical disposition을 임의 재해석 없이 재현 가능한 migration으로 구현 | WBS-04 final closure, WBS-05 transaction·lease 계약, WBS-09 실제 `READY`, WBS-10과 사용자 승인 WBS-12 branch/test/rollback 범위 | disposition-locked baseline migration, migration metadata·drift guard, constraints·query-index map, role boundary, upgrade·forward-fix·verification evidence | DR-001~014, NFR-DQ-002, NFR-REL-001~002, NFR-OBS-001, NFR-SEC-001, NFR-REC-001, VR-012~019, AD-02·03·09·10·13·22, DDI-01~10, MIN-01~08 | 빈 DB·반복 적용·실제 N-1 upgrade·중단/재시도·drift·권한·invariant·data-preservation test가 적용 가능한 단계별로 통과하고 application auto-migrate·무승인 destructive rollback·MVP-B schema가 없음 | Physical baseline 누락, applied migration drift, 장시간 lock·부분 backfill, application-only 무결성, 과권한 또는 데이터 손실 rollback |
| [WBS-13](feature-implementation-plan.md#wbs-13--예정-batchdurable-work-ledger-구현-상세-checkpoint) | 예정 batch·durable work ledger 구현 | deterministic slot과 typed logical work, atomic claim·attempt, DB-time lease·fencing 및 외부 효과와 분리된 safe internal resume 제공 | WBS-05 final contract, WBS-09 실제 `READY`, WBS-11.C~H, WBS-12와 사용자 승인 WBS-13 branch/test/rollback 범위 | scheduled batch ledger, typed work admission, work item/attempt repository, claim·renew·reclaim·guarded transition, Prepare configuration binding·projection | FR-004~005·024, NFR-REL-001~003, NFR-REC-001, NFR-OBS-001, NFR-TIME-001, NFR-LAT-001, VR-004~005·013~014·017~018, AD-02·03·08·10·19, DDI-05·09, MIN-05~06 | Deterministic slot·과거 slot ledger-only, duplicate coalescing, claim+attempt atomicity, DB-time lease·token ABA/stale-write·commit-unknown 차단, immutable configuration binding과 work/domain 분리 test 통과 | Trigger-key 혼합, 중복 work·attempt, local-clock lease, stale worker write, 외부 불명확 효과 자동 재실행 또는 과거 slot 소급 pipeline |
| [WBS-14](feature-implementation-plan.md#wbs-14--rss-수집raw-evidencecandidate-admission-구현-상세-checkpoint) | RSS 수집·Raw evidence·candidate admission 구현 | 승인된 공식 GeekNews RSS 한정 fetch와 parsing 전 Raw evidence, entry별 대표 입력 결과, exact-link article identity·최초 candidate admission 구현 | WBS-09 실제 `READY`, WBS-11.C~H, WBS-12~13, SPK-01 pass·사용자 승인 RSS 계약과 WBS-14 branch/test/rollback 범위 | RSS operation adapter, fetch/external evidence, raw snapshot, safe parser, observation validation·accounting, article identity·admission transaction | FR-001~005, NFR-PERF-001, NFR-LAT-002, NFR-DQ-002, NFR-REL-001~002, NFR-OBS-001~002, NFR-SEC-001, DR-001~005, EXT-GN-001~006, VR-002·004·013~015, AD-01~03·08·10·13, DDI-01~02·05~06, MIN-05·08 | 공식 endpoint 외 요청 0건, feed/entry/304·오류 분리, parsed entry 대표 결과 수량 불변식, exact-link 재관찰·동시 최초 admission·Raw 재현성과 unsafe XML 차단 test 통과 | 외부 계약 추측, Raw 손실, XML resource 접근, 입력 오류·304를 정상 0건으로 오판, URL normalization·동시 admission 중복 또는 과거 이력 소급 변경 |
| [WBS-15](feature-implementation-plan.md#wbs-15--무료-aianalysis-boundary-구현-상세-checkpoint) | 무료 AI·analysis boundary 구현 | 승인된 단일 free-only provider에서 AI 전 freshness·시간 terminal, RSS-bounded payload, prepared/invocation/evidence와 검증된 최초 analysis·retry/late 경계를 구현 | WBS-06.A~E actual contract, SPK-02·06A·06B pass와 사용자 provider 승인, WBS-09 실제 `READY`, WBS-11~14와 사용자 승인 WBS-15 branch/test/rollback 범위 | candidate analysis-eligibility, 단일 provider adapter, safe request manifest, AI attempt/evidence, output validator, analysis resolution, error/retry/late handler | FR-006~010·013~014, NFR-COST-001, NFR-DQ-001~002, NFR-REL-001~002, NFR-PERF-001, NFR-LAT-002, NFR-OBS-001~002, NFR-SEC-001, NFR-MNT-001, DR-006~007·014, EXT-AI-001~007, VR-004·008·011·013·018~019, AD-01~04·08·10·13·15~18, DDI-02·05~06·09, MIN-03~06·08 | 13시간/시간 불가 pre-AI 판정, 단일 free path·허용 payload·tool/hidden retry 차단, prepared→invocation/evidence, normal/low-information/invalid 분리, 최초 analysis atomicity와 retry/late/fault test 통과 | Provider·비용 계약 변경, SDK hidden invocation, RSS 밖 사실·Secret 전송, output coercion, duplicate analysis, 불명확 자동 retry·late 소급 적용 또는 품질 false assurance |
| [WBS-16](feature-implementation-plan.md#wbs-16--선정finalization-구현-상세-checkpoint) | 선정·finalization 구현 | WBS-15가 고정한 candidate completion·freshness를 소비해 승인된 selection policy로 배타적 결정을 만들고 Prepare lease 아래 immutable result를 원자적으로 고정 | WBS-05.E, WBS-06.E~F actual contract·사용자 승인 selection policy, WBS-09 실제 `READY`, WBS-13~15와 사용자 승인 WBS-16 branch/test/rollback 범위 | completion reconciler, freshness reference consumer, versioned policy·stable total order, candidate decision·summary, selection result·batch item, durable handoff eligibility | FR-005·009~014, NFR-DQ-002, NFR-REL-001~002, NFR-PERF-001, NFR-LAT-002, NFR-OBS-002, DR-007~008, EXT-AI-007, VR-016~019, AD-08·17~20, DDI-02·05·09, MIN-08 | 미처리·retry 대기 finalization 0건, deterministic selected≤10·수량 invariant, clean-zero/summary/failure 분리, lease/fence 원자 commit·replay·lost-handoff·freshness 비재계산 test 통과 | 미승인 score/tie-break, partial article list, count drift, stale/concurrent finalization, mutable result 또는 current/delayed/recovery handoff 혼합 |
| [WBS-17](feature-implementation-plan.md#wbs-17--discord-renderingdelivery-구현-상세-checkpoint) | Discord rendering·delivery 구현 | Committed source를 current·processing-delayed·confirmed-recovery·notice·confirmation/offer로 분리해 deterministic render하고 physical message별 invocation·server acceptance를 증거로 판정 | WBS-07.A~C actual contract, SPK-03·06A·06B pass와 사용자 Discord 승인, WBS-09 실제 `READY`, WBS-11~13·16과 사용자 승인 WBS-17 branch/test/rollback 범위 | operation adapter, delivery set/segment admission, reference-only renderer, physical mapping/split, prepared attempt, acceptance/error·partial/late projection | FR-012~016, NFR-REL-001~003, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, DR-008~009, EXT-DC-001~006, VR-004~005·011~013·016~018, AD-01~03·06~08·10·13·15~21, DDI-03·05~06·09~10, MIN-01·03·05·08 | Segment 10/10/20·delayed 10·no-message, deterministic disjoint mapping, no-silent-truncation, no-early/stale/hidden invocation, response+message-ID acceptance, error/acceptance 분리·partial/late/fault test 통과 | 미검증 Discord 계약, segment/summary 혼합, mapping 중복, 조기·hidden retry, message-ID 없는 성공, uncertain 자동 재발송, Secret 노출 또는 system-message 의미 오염 |
| [WBS-18](feature-implementation-plan.md#wbs-18-gateway-listenerfeedback누락-요청-구현-상세) | Gateway listener·feedback·누락 요청 구현 | 승인 Gateway/interaction의 최소 append-only intake와 exact identity/order validation으로 feedback·review projection, exact-link missing reply와 receipt/recovery handoff 구현 | WBS-07.A·D·F actual contract, SPK-03·06A·06B pass와 사용자 Discord 승인, WBS-09 실제 READY, WBS-11~14·17과 사용자 승인 WBS-18 branch/test/rollback 범위 | Gateway session/continuity, typed event store, mapping/order validator, feedback projection, interaction request, missing reply, recommendation/receipt handoff | FR-017~023, NFR-REL-001~003, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-MNT-002, DR-010~012, EXT-DC-003, EXT-FB-001~006, VR-010·012~013, AD-01~03·05·08·10~13·21, DDI-04~06·10, MIN-01·03·05·07~08 | exact config/guild/channel/message/user/subject validation, duplicate/order/gap, no false absent, feedback/review/receipt separation, exact-link grounded reply, listener direct recovery mutation·Secret/unrestricted payload 0건 test 통과 | event gap·reorder, reaction 오귀속, forged interaction, ack/commit ambiguity, unrestricted identifier payload, false absent/recall 또는 listener recovery owner 침범 |
| [WBS-19](feature-implementation-plan.md#wbs-19-bounded-feedback-reconciliationdelivery-recovery-구현-상세) | Bounded feedback reconciliation·delivery recovery 구현 | A: 네 trigger의 exact-scope REST feedback 관측, B: 수락 불명확 delivery의 confirmation·receipt·1회 resend·offer와 명시적 미수락 item의 FIFO recovery를 서로 독립된 work/state/permission slice로 구현 | WBS-07.A·C·E~G actual contract, SPK-03·04·06A·06B pass와 사용자 Discord 승인, WBS-09 실제 `READY`, WBS-11~13·17~18과 사용자 승인 WBS-19 branch/test/rollback 범위 | A: request admission/coalescing, REST attempt·snapshot completeness, feedback application; B: recovery case/due, confirmation, receipt/resend, offer, confirmed-non-acceptance FIFO release | FR-004~005·015~023, NFR-REL-001~003, NFR-COST-001, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-REC-001, NFR-TIME-001, DR-009~012·014, EXT-DC-003~006, EXT-FB-001~002·006, VR-005·009~013·018, AD-01~03·05·07~08·10~13·15~16·19~23, DDI-03~06·08~10, MIN-01·03·05·07~08 | A의 네 trigger 밖 request/HTTP·broad polling·incomplete absence·acceptance/recovery 변경 0건, B의 조기/중복 confirmation·`받음` resend·uncertain 반복·cross-batch·재처리 0건과 exact `못 받음` authorization 1회·10/10/20 검증 | REST feedback와 acceptance/recovery state·work/credential 혼합, incomplete snapshot의 false absence, stale worker 또는 잘못된 반복 resend·backlog |
| [WBS-20](feature-implementation-plan.md#wbs-20-관측성비용보안-evidence-구현-상세) | 관측성·비용·보안 evidence 구현 | PostgreSQL domain/evidence 정본을 변경하지 않는 파생 telemetry와 operational diagnostic, 전체 비용 coverage·사용자 billing attestation, WBS-11 gate handoff와 구조적 redaction 구현 | WBS-08.A·B·E actual contract, SPK-04~06 pass와 비용 범위 사용자 승인, WBS-09 실제 `READY`, WBS-11~19와 사용자 승인 WBS-20 branch/test/rollback 범위 | Source correlation, structured telemetry, diagnostic query, cost coverage/evidence·user attestation, gate/pause handoff, security/redaction, alert/fault boundary | FR-024, NFR-REL-002~003, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-001~002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-REC-001, NFR-TIME-001, DR-013~014, VR-001·006~009·011·014, AD-02~06·09~16·22~23, DDI-04~06·08·10, MIN-02~03·05 | Source-only lineage, zero/not-executed/incomplete/NA/not-measurable/unknown 분리, 7개 비용 scope와 사용자 billing coverage, no false Gate·auto resume·paid fallback, Secret/high-cardinality 0건 test 통과 | Telemetry 정본화, source 누락의 false zero/pass, attempt 중복 집계, billing coverage 공백, 민감값·고카디널리티 노출 또는 WBS-11/22/30 owner 침범 |
| [WBS-21](feature-implementation-plan.md#wbs-21-backuprestore-및-recovery-gate-구현-상세) | Backup/restore 및 recovery gate 구현 | 별도 failure domain의 일관된 PostgreSQL backup과 nonproduction isolated restore validation을 구현하고 production restore·restricted reconciliation·final resume를 각각 별도 사용자 승인 gate로 제공 | WBS-08.C·D actual contract, SPK-04~06 pass와 사용자 backup tool/storage/RPO·RTO·gap/retention 승인, WBS-09 실제 `READY`, WBS-11~13·20과 사용자 승인 WBS-21 branch/test/rollback 범위; K3s 배포·운영 활성화는 WBS-27~29 | Protection inventory, backup admission/artifact/integrity/failure-domain evidence, lifecycle/gap, isolated restore·domain validation, loss-window reconciliation, production restore/resume gate handoff | FR-024, NFR-REL-001~003, NFR-COST-001, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-REC-001, NFR-TIME-001, DR-013~014, VR-004~005·009·011~019, AD-02~03·05·08~10·13·22, DDI-01~06·08~10, MIN-02~03·05~06·08 | Consistent non-overwritten artifact와 독립 failure-domain evidence, isolated restore schema/data/ledger/domain 검증·RPO/RTO 실측, stale lease·loss-window·no-backfill, production restore/restricted REST/final resume의 자동 전이 0건 test 통과 | 공통 failure domain, partial/inconsistent artifact의 성공 오판, destructive retention/fallback, stale worker·외부 효과 중복, 무승인 production restore/자동 resume 또는 Secret 노출 |
| [WBS-22](feature-implementation-plan.md#wbs-22-evaluation-runner-구현-상세) | Evaluation runner 구현 | 사용자 명시 request의 batch/day/validation-period scope를 consistent source cutoff로 동결해 compact manifest와 여섯 typed result kind를 원자적으로 확정하고 canonical result의 read-only report를 제공 | WBS-08.E~G actual metric/evaluation/result contract와 WBS-04.D·05 physical transaction contract, WBS-09 실제 `READY`, WBS-12·18~21 및 사용자 승인 WBS-22 branch/test/rollback 범위 | Request/scope validator, feedback reconciliation handoff, cutoff/high-watermark consistent reader, manifest/digest, metric calculator, typed-result finalizer, report projection | FR-017~024, NFR-REL-001~002, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-001~002, NFR-OBS-001~002, NFR-SEC-001, NFR-TIME-001, DR-010~013, VR-001·006~010·014, AD-02~03·05·10~12·23, DDI-04~05·08, MIN-02·05 | 명시 request/replay·세 scope, no direct REST/source mutation, consistent cutoff·count/digest, atomic snapshot/result, 여섯 kind·Gate 독립성·not_measurable·report 일치와 late/fault test 통과 | 자동/중복 evaluation, torn/mutable input, direct REST, digest false reproducibility, partial finalize, false Gate/pass·scope 결론 또는 report 재계산 |
| [WBS-23](integrated-verification-plan.md#wbs-23-계약단위-테스트-closure-상세) | 계약·단위 테스트 closure | WBS-10~22의 module/contract별 정상·경계·금지 동작을 deterministic unit/contract suite로 검증하고 99개 Requirement의 적절한 검증 계층·evidence owner와 WBS-24~26 handoff를 닫음 | WBS-01 traceability baseline, WBS-09 실제 `READY`, WBS-10~22 구현·자체 test 완료와 actual external/physical contract, 사용자 승인 WBS-23 branch/test/rollback 범위 | Closure inventory, 99개 verification-layer matrix, versioned fixture/golden catalog, unit/serialization/PostgreSQL/external-adapter contract suite, P0-HG negative/security test, evidence·gap/handoff report | VR-002·004·010~019, 전체 99개 traceability와 P0-HG 34개, AD-01~23, DDI-01~10, MIN-01~08 | WBS-23 소유 case 전부 deterministic pass, skip/xfail/flaky/quarantine/blocker 0건, live/paid 외부 호출·production data·Secret 0건, 각 잔여 검증은 WBS-24~26/SPK/30 owner와 evidence에 연결 | Line coverage 기반 false closure, mock/contract drift, SQLite 대체, 비결정적·skip test, fixture/Golden 오염, 통합 결함 미탐지 또는 test closure에 production fix 은닉 |
| [WBS-24](integrated-verification-plan.md#wbs-24-postgresql-concurrencyreplayfault-검증-상세) | PostgreSQL concurrency·replay·fault 검증 | 실제 PostgreSQL transaction·DB-time lease/fence와 deterministic fake external adapter로 claim race, duplicate/replay, crash/response loss/commit-unknown, late evidence·lost handoff·partial/restore 경계를 검증 | WBS-05·08.D actual fault/transaction contract, WBS-09 실제 `READY`, WBS-11~22 구현·자체 test와 WBS-23 unit/contract closure, 사용자 승인 WBS-24 branch/test/fault/rollback 범위 | Fault-point/barrier catalog, isolated PostgreSQL concurrency harness, fake invocation/effect/response ledger, replay/crash/late/partial/restore suite, state·invocation evidence와 defect report | FR-004~005·012~024, NFR-REL-001~003, NFR-DQ-002, NFR-OBS-001~002, NFR-REC-001, NFR-TIME-001, VR-004~005·012~019, AD-02~03·08·10·13·17~22, DDI-05~06·09~10, MIN-05~06·08 | Claim/lease/fence·domain별 replay와 crash matrix에서 stale mutation·silent loss·unapproved duplicate invocation·uncertain auto-retry·partial 전체화·restored-token 재사용 0건, deterministic 반복 evidence 통과 | Test hook 의미 변경, deadlock/flaky timing, fake/실제 외부 계약 차이, exactly-once 과신, shared DB 오염 또는 closure에 production fix 은닉 |
| [WBS-25](integrated-verification-plan.md#wbs-25-scenario-end-to-end-검증-상세) | Scenario End-to-End 검증 | 실제 PostgreSQL·application role과 승인 contract fake를 사용해 Product Scenario 1~9의 source→state/evidence→user-visible output·금지 전이를 AC-01~24와 양방향 검증 | WBS-01 Scenario/AC baseline, WBS-09 실제 `READY`, WBS-10~22 구현과 WBS-23~24 closure, SPK-01~03 actual contract fixture fingerprint, 사용자 승인 WBS-25 branch/test/rollback 범위; live external/K3s 배포 제외 | Isolated E2E environment, Scenario/AC/variant catalog, candidate/output/failure/delivery-recovery/feedback-missing/quality-evaluation suite, cross-scenario negative assertions, AC evidence·defect report | Scenario 1~9, AC-01~24, FR-001~024, VR-003와 관련 NFR/DR/EXT, AD-01~23, DDI-01~10, MIN-01~08 | Scenario 9개·AC 24개 orphan 0건, 정상·경계·실패 variant의 DB/evidence/outbound/user-output·forbidden assertion 통과, live/paid call·state leakage·false zero/pass·segment/meaning 혼합 0건 | Happy-path false closure, contract fake drift, brittle output snapshot, scenario state/time 오염, AC evidence 누락, capacity/cost/deployment 과대 해석 또는 E2E closure에 production fix 은닉 |
| [WBS-26](integrated-verification-plan.md#wbs-26-용량시간비용-운영-전-검증-상세) | 용량·시간·비용 운영 전 검증 | 0·1·99·100·101 KST 고유 신규 후보의 deterministic full-shape workload와 승인 budget의 bounded actual-free-provider 실험을 분리해 용량·30분 준비·1분 수락·13시간 freshness·비용 safety를 배포 전 측정 | WBS-06·08.A·B·E~G actual contract, SPK-02·04·06A pass와 승인 test call/token/time/cost budget, WBS-09 실제 `READY`, WBS-10~22 구현과 WBS-23~25 closure, 사용자 승인 WBS-26 environment/test/rollback 범위 | Nonproduction environment profile, workload census/generator, pipeline/resource report, staged AI evidence, latency/freshness/recovery timing report, 7-scope cost/stop evidence, 판정·WBS-27~30 handoff | FR-002·005·011~016·024, NFR-REL-002~003, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-OBS-001~002, NFR-TIME-001, EXT-AI-002·004~005, EXT-DC-001~003, VR-006·008~009·011·014, AD-04·06·14~16·19·23, DDI-04~06·08, MIN-02~03·05 | 0/1/99/100/101 수량·terminal outcome·silent loss/paid fallback 0건, synthetic/actual·5개 판정/no-extrapolation, 시간 지표 분리와 7-scope cost coverage; actual 95% 운영/K3s/monthly billing은 WBS-27~30 pending으로 명시 | 비대표 환경·warm cache, 후보/request 수 혼합, synthetic/소량 actual 외삽, actual quota/비용 발생, latency 분모 오류, K3s/운영 목표 false pass 또는 성능 closure에 production fix 은닉 |
| [WBS-27](release-operations-plan.md#wbs-27-imagek3s-배포-artifact-준비-상세) | Image·K3s 배포 artifact 준비 | 검증된 하나의 Python image digest와 역할별 K3s 선언·configuration/Secret/RBAC/storage/schedule/kill-switch package를 재현 가능하게 준비하되 registry push·cluster apply·실제 배포와 분리 | WBS-03·08.C~D actual deployment/operations contract, SPK-04~06 pass와 사용자 K3s/storage/registry/cost 승인, WBS-09 실제 `READY`, WBS-10~26 closure와 사용자 승인 WBS-27 build/manifest/test/rollback 범위 | 재현 가능한 image build 입력, digest/SBOM evidence, 역할별 command inventory, versioned manifest package, Secret/RBAC/network/storage/schedule policy, 정적 검증·WBS-28/29 handoff | FR-024, NFR-REL-001~003, NFR-LAT-001~002, NFR-COST-001, NFR-OBS-001~002, NFR-SEC-001~002, NFR-REC-001, NFR-MNT-001, NFR-TIME-001, VR-001·009·011·013~014·018, AD-01·03·06·08~10·13~16·19·21~23, DDI-05~06·08~10, MIN-02~03·05~07 | 하나의 digest와 역할별 command가 연결되고 Secret·mutable tag·과도한 권한·자동 evaluation이 없으며 schedule/storage/kill-switch 정적 검증 통과; registry push·cluster apply와 cluster-dependent smoke는 실행하지 않음 | Mutable tag/build drift, Secret/RBAC 노출, Cron timezone/concurrency 오설정, PV/reclaim 데이터 손실, registry 비용, 정적 검증의 허위 확신 또는 구현/배포 혼합 |
| [WBS-28](release-operations-plan.md#wbs-28-deployment-readiness-review-상세) | Deployment Readiness Review | WBS-01~27의 동일 baseline evidence와 99개 Requirement의 배포 전·smoke·운영 검증 owner를 대조하고 제한된 WBS-29 진입 가능 여부를 `READY`/`NOT_READY`로 판정 | Workflow 9~15의 실제 closure, WBS-01~27 실행 결과, SPK-01~06 유효 evidence, exact artifact/environment/external-contract/cost/backup/runbook 정보 | Readiness baseline, 99개 phase/evidence matrix, blocker·accepted-risk register, target inventory, cost·security·recovery review, 단계별 배포·activation·rollback plan, final decision record | 전체 99개 Requirement·P0-HG, AD-01~23, DDI-01~10, MIN-01~08 | 모든 predeploy blocker가 dated evidence로 pass하고 stale/orphan/owner 없는 unknown이 없으며 비차단 위험을 사용자가 명시적으로 수용한 경우에만 `READY`; 배포 실행은 별도 승인 | 운영 검증을 predeploy pass로 오판, stale evidence, blocker 위험 수용, 잘못된 target, 비용·Secret·데이터 손실 또는 READY를 배포 승인으로 오해 |
| [WBS-29](release-operations-plan.md#wbs-29-단계별-실제-deployment-상세) | 단계별 실제 Deployment | WBS-28 `READY` baseline을 exact registry·K3s target에 단계별 승인으로 게시·적용하고 outbound-disabled 검증, bounded sandbox smoke와 별도 activation 후 WBS-30에 인계 | WBS-28 실제 `READY`, exact target/artifact, 단계별 사용자 승인, 비용·backup·operator·stop/rollback preflight pass | Registry digest evidence, applied resource/migration inventory, internal·sandbox smoke evidence, activation record, deployment state·stop/rollback 결과, WBS-30 handoff | FR-024, NFR-REL-001~003, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-REC-001, NFR-MNT-001, NFR-TIME-001, VR-001·009·011·013~019, AD-01·03·06·08~10·13~16·19·21~23, DDI-05~06·08~10, MIN-02~03·05~07 | 승인 digest·target만 사용하고 최초 apply에서 outbound 0건, DB/migration·internal/sandbox smoke 통과, 별도 activation 승인과 과거 slot 소급 0건, partial/uncertain 상태 및 WBS-30 baseline 기록 | 오배포, Secret 노출, PV/migration 손실, 조기 Job·외부 효과, 비용 발생, 부분 적용, uncertain effect 자동 재시도 |
| [WBS-30](release-operations-plan.md#wbs-30-baseline-고정-24주-monitoringevaluation-상세) | Baseline 고정 2~4주 Monitoring·Evaluation | 하나의 immutable activation baseline에서 scheduled batch·candidate·delivery·feedback·cost evidence를 수집하고 표본 adequacy, 여섯 Hard Gate, 품질·서비스 목표를 독립 판정 | WBS-29 `activated_monitoring`, 완전한 baseline/cost/owner/stop handoff; evaluation 실행은 WBS-30.I에서 표본·cutoff를 확인한 뒤 별도 사용자 request 승인이 필요 | Window·slot/candidate census, completeness/gap report, service/quality/feedback metric, Gate별 typed result, 사용자 billing coverage, immutable evaluation snapshot/report, WBS-31 handoff | FR-017~024, NFR-REL-001~003, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-001~002, NFR-OBS-001~002, NFR-SEC-001~002, NFR-TIME-001, VR-001·006~010·014~019, AD-02·05·08·10~12·15~16·19~23, DDI-04~06·08~10, MIN-02~03·05·08 | 최소 2주·20 scheduled batch·50 candidate를 모두 충족하거나 최대 4주 부족을 명시하고, Gate·품질·서비스·비용을 독립 판정하며 drift/incident/missing evidence를 숨기지 않고 사용자 승인 결과만 WBS-31로 인계 | 표본 조기 종료·무한 연장, 분모 제외, receipt/acceptance/recovery 혼합, billing coverage 공백, baseline drift 합산, 실패 은폐 또는 자동 MVP-B 진입 |
| [WBS-31](release-operations-plan.md#wbs-31-retrospectivemvp-a-dispositionmvp-b-incremental-entry-decision-상세) | Retrospective·MVP-A disposition·MVP-B incremental-entry decision | WBS-30의 사용자 승인 immutable 결과를 근거로 validation·operation·MVP-B 결정 축을 분리하고, 검증된 MVP-A baseline을 보존한 incremental update의 discovery 여부와 개선·재검증 backlog를 확정 | WBS-30 final result/report digest, limitation·billing coverage·incident/drift와 사용자 결과 승인, exact MVP-A commit/image/schema/configuration baseline | Evidence-based retrospective, 세 결정 축 record, scope-classified backlog, MVP-B delta-impact matrix, baseline·migration·regression 원칙, change-control/revalidation plan, 운영 disposition과 MVP-B authorization | 전체 99개 Requirement·P0-HG, AD-01~23, DDI-01~10, MIN-01~08, 승인된 MVP-A/B 경계 | 결과를 변경하지 않고 defect/risk/debt/MVP-B를 분리하며 Hard Gate 실패를 수용으로 우회하지 않고, 사용자가 MVP-A disposition과 MVP-B incremental discovery 여부를 분리 승인하며 각 B delta가 reuse/extend/migrate/replace/deprecate/defer 중 하나로 분류됨 | 후보 결과의 최종 pass 오판, 실패 은폐, greenfield 재구축, MVP-A/B 선구현 혼합, 데이터 재생성, 기존 Requirement 회귀, backlog를 실행 승인으로 오해 또는 승인 설계 우회 변경 |

## Plan Documents

[FACT] 본문은 역할별 여섯 문서로 이동했습니다. 아래 기존 heading은 링크 호환 안내이며 상세 본문의 정본이 아닙니다. WBS-01·02의 정의는 위 요약표를 유지하고 추가 상세 설계를 만들지 않았습니다.

- [Design and Coding Readiness Plan](design-readiness-plan.md)
- [Feature Implementation Plan](feature-implementation-plan.md)
- [Integrated Verification Plan](integrated-verification-plan.md)
- [Release and Operations Plan](release-operations-plan.md)
- [External Validation and Traceability Plan](validation-traceability-plan.md)
- [Implementation Review History](implementation-review-history.md)

### WBS-03 Internal Review Checkpoints

[FACT] 상세 본문: [WBS-03](design-readiness-plan.md#wbs-03-internal-review-checkpoints).

### WBS-04 Internal Review Checkpoints

[FACT] 상세 본문: [WBS-04](design-readiness-plan.md#wbs-04-internal-review-checkpoints).

### WBS-05 Internal Review Checkpoints

[FACT] 상세 본문: [WBS-05](design-readiness-plan.md#wbs-05-internal-review-checkpoints).

### WBS-06 Internal Review Checkpoints

[FACT] 상세 본문: [WBS-06](design-readiness-plan.md#wbs-06-internal-review-checkpoints).

### WBS-07 Internal Review Checkpoints

[FACT] 상세 본문: [WBS-07](design-readiness-plan.md#wbs-07-internal-review-checkpoints).

### WBS-08 Detailed Review Checkpoints

[FACT] 상세 본문: [WBS-08](design-readiness-plan.md#wbs-08-detailed-review-checkpoints).

### WBS-09 — Coding Readiness Check 상세 checkpoint

[FACT] 상세 본문: [WBS-09](design-readiness-plan.md#wbs-09--coding-readiness-check-상세-checkpoint).

### WBS-10 — Python 실행·테스트 기반 상세 checkpoint

[FACT] 상세 본문: [WBS-10](feature-implementation-plan.md#wbs-10--python-실행테스트-기반-상세-checkpoint).

### WBS-11 — Configuration·Secret·outbound gate 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-11](feature-implementation-plan.md#wbs-11--configurationsecretoutbound-gate-구현-상세-checkpoint).

### WBS-12 — PostgreSQL schema·migration 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-12](feature-implementation-plan.md#wbs-12--postgresql-schemamigration-구현-상세-checkpoint).

### WBS-13 — 예정 batch·durable work ledger 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-13](feature-implementation-plan.md#wbs-13--예정-batchdurable-work-ledger-구현-상세-checkpoint).

### WBS-14 — RSS 수집·Raw evidence·candidate admission 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-14](feature-implementation-plan.md#wbs-14--rss-수집raw-evidencecandidate-admission-구현-상세-checkpoint).

### WBS-15 — 무료 AI·analysis boundary 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-15](feature-implementation-plan.md#wbs-15--무료-aianalysis-boundary-구현-상세-checkpoint).

### WBS-16 — 선정·finalization 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-16](feature-implementation-plan.md#wbs-16--선정finalization-구현-상세-checkpoint).

### WBS-17 — Discord rendering·delivery 구현 상세 checkpoint

[FACT] 상세 본문: [WBS-17](feature-implementation-plan.md#wbs-17--discord-renderingdelivery-구현-상세-checkpoint).

### WBS-18 Gateway listener·feedback·누락 요청 구현 상세

[FACT] 상세 본문: [WBS-18](feature-implementation-plan.md#wbs-18-gateway-listenerfeedback누락-요청-구현-상세).

### WBS-19 Bounded feedback reconciliation·delivery recovery 구현 상세

[FACT] 상세 본문: [WBS-19](feature-implementation-plan.md#wbs-19-bounded-feedback-reconciliationdelivery-recovery-구현-상세).

### WBS-20 관측성·비용·보안 evidence 구현 상세

[FACT] 상세 본문: [WBS-20](feature-implementation-plan.md#wbs-20-관측성비용보안-evidence-구현-상세).

### WBS-21 Backup/restore 및 recovery gate 구현 상세

[FACT] 상세 본문: [WBS-21](feature-implementation-plan.md#wbs-21-backuprestore-및-recovery-gate-구현-상세).

### WBS-22 Evaluation runner 구현 상세

[FACT] 상세 본문: [WBS-22](feature-implementation-plan.md#wbs-22-evaluation-runner-구현-상세).

### WBS-23 계약·단위 테스트 closure 상세

[FACT] 상세 본문: [WBS-23](integrated-verification-plan.md#wbs-23-계약단위-테스트-closure-상세).

### WBS-24 PostgreSQL concurrency·replay·fault 검증 상세

[FACT] 상세 본문: [WBS-24](integrated-verification-plan.md#wbs-24-postgresql-concurrencyreplayfault-검증-상세).

### WBS-25 Scenario End-to-End 검증 상세

[FACT] 상세 본문: [WBS-25](integrated-verification-plan.md#wbs-25-scenario-end-to-end-검증-상세).

### WBS-26 용량·시간·비용 운영 전 검증 상세

[FACT] 상세 본문: [WBS-26](integrated-verification-plan.md#wbs-26-용량시간비용-운영-전-검증-상세).

### WBS-27 Image·K3s 배포 artifact 준비 상세

[FACT] 상세 본문: [WBS-27](release-operations-plan.md#wbs-27-imagek3s-배포-artifact-준비-상세).

### WBS-28 Deployment Readiness Review 상세

[FACT] 상세 본문: [WBS-28](release-operations-plan.md#wbs-28-deployment-readiness-review-상세).

### WBS-29 단계별 실제 Deployment 상세

[FACT] 상세 본문: [WBS-29](release-operations-plan.md#wbs-29-단계별-실제-deployment-상세).

### WBS-30 Baseline 고정 2~4주 Monitoring·Evaluation 상세

[FACT] 상세 본문: [WBS-30](release-operations-plan.md#wbs-30-baseline-고정-24주-monitoringevaluation-상세).

### WBS-31 Retrospective·MVP-A disposition·MVP-B incremental-entry decision 상세

[FACT] 상세 본문: [WBS-31](release-operations-plan.md#wbs-31-retrospectivemvp-a-dispositionmvp-b-incremental-entry-decision-상세).

## External Validation / Spike Plan

[FACT] 본문은 [검증·추적성 계획](validation-traceability-plan.md#external-validation--spike-plan)으로 이동했습니다.

## Requirement Traceability Plan

[FACT] 본문은 [검증·추적성 계획](validation-traceability-plan.md#requirement-traceability-plan)으로 이동했습니다.

[FACT] 실제 WBS-01 산출물은 [추적성 기준선](traceability-baseline.md)입니다. 행별 책임·증거 계획과 자동 정합성 검사를 작성했으며 사용자 검토와 실제 기능 검증은 별도입니다.

### Hard Gate Traceability

[FACT] 본문은 [검증·추적성 계획](validation-traceability-plan.md#hard-gate-traceability)으로 이동했습니다.

## Milestones and Approval Gates

| Milestone | 완료 조건 | 사용자 승인 필요 사항 | 다음 단계 진입 조건 |
| --------- | ----- | ------------ | ----------- |
| M0 — Implementation Plan Approved | WBS-01~31·SPK-01~06·traceability·gate와 PLAN-CONSISTENCY-01 승인, 문서·Context 정합성 검증 | Workflow 9 계획 전체와 정합성 반영 | Workflow 9 단계 종료 Git review·commit·push |
| M1 — External Validation Gate | SPK-01~06의 독립 판정·evidence·후속 영향과 SPK-06B 비용 coverage 기록 | provider·Discord 실제 계약·비용 조건과 fail/blocked/inconclusive 처리 | blocker 없는 상세 설계만 완료·승인 진행 |
| M2 — Physical Design Baseline | WBS-03~08 상세안과 99개 mapping 완료 | schema·lease·retry·UX·RPO/RTO | 승인된 물리 계약 확보 |
| M3 — Coding Readiness | Workflow 9 문서/context·commit/push closure, WBS-01~08 실제 evidence·결정 승인, 모든 blocking check `pass`, owner 없는 미확정·숨은 MVP-B 범위 없음 | 비차단 위험 수용, WBS-10 branch/test/rollback 범위와 Workflow 10 최종 `READY` 승인 | Workflow 11의 WBS-10 구현 시작 |
| M4 — Foundation | WBS-10~14와 관련 test 통과 | schema/work/RSS PR | 내부 상태·입력 기반 안정화 |
| M5 — Daily Value Path | WBS-15~17과 정상·0건·failure notice 통과 | AI·선정·Discord PR | 일일 경로 확보 |
| M6 — Feedback and Recovery | WBS-18~22와 recovery·evaluation·backup 통과 | interaction·복구·운영 증거 PR | 통합 검증 가능 |
| M7 — Integrated Verification | WBS-23~26과 AC·VR·Gate evidence 완료 | 결함 수정·재검증 결과와 남은 비차단 risk | WBS-27 배포 artifact 준비 진입 |
| M7.5 — Release Candidate Closure | WBS-27 artifact 검증 뒤 Workflow 13 Code Review, Workflow 14 문서·Context 동기화, Workflow 15 Git Review·commit·push 완료 | review 지적·문서 동기화·commit/push 범위 | WBS-28 Deployment Readiness 실행 |
| M8 — Deployment Readiness | WBS-28의 artifact·target·security·cost·backup·runbook blocker가 모두 통과해 `READY` | 비차단 risk와 별도 WBS-29 단계별 실행안 | Workflow 16의 WBS-29 staged deployment 시작 |
| M9 — Staged Deployment | WBS-29 publish→suspended apply→internal smoke→bounded sandbox smoke→별도 activation을 완료하고 `activated_monitoring` baseline 인계 | 각 mutation 단계, activation과 필요한 rollback/stop | WBS-30 Monitoring 시작 |
| M10 — MVP-A Validation | 최소 2주 AND 20 scheduled batch AND 50 candidate 충족 뒤, 또는 최대 4주 cutoff에서 별도 사용자 evaluation request로 Gate·품질·서비스·비용 결과 생성 | monthly billing 확인, 결과 해석과 `accepted_pass`·`not_met`·`inconclusive` disposition | WBS-31 Retrospective 실행 |
| M11 — Retrospective and Incremental MVP-B Entry | validation·operation·MVP-B evolution 세 축 결정, remediation/revalidation과 MVP-A baseline·delta disposition 기록 | 운영 지속/중지, 재검증, `increment_discovery_authorized` 여부 | 승인된 다음 Workflow만 시작; MVP-B는 MVP-A 기반 incremental discovery부터 진행 |

## Risks and Sequencing Concerns

- [INFERENCE] AI spike 전에 retry·전체 선정 불가능 규칙을 고정하면 provider 오류 의미와 맞지 않을 수 있습니다.
- [INFERENCE] Discord sandbox 전에 payload·대표 message·receipt UX를 고정하면 실제 API에서 논리 설계를 표현하지 못할 수 있습니다.
- [INFERENCE] schema와 transaction을 분리 승인하면 constraint가 상태 전이를 보장하지 못할 수 있으므로 WBS-04·05를 연속 검토해야 합니다.
- [INFERENCE] outbound gate보다 외부 adapter를 먼저 구현하면 비용·secret·불명확 외부 효과 차단을 우회할 수 있습니다.
- [INFERENCE] selection과 delivery 결합은 Discord 실패가 immutable selection을 변경할 위험을 만듭니다.
- [INFERENCE] 처리 지연 full result와 Discord 미수락 recovery를 같은 상태로 구현하면 승인된 구간이 섞입니다.
- [INFERENCE] mutable `feedback_state`를 evaluation source로 쓰면 과거 평가가 소급 변경됩니다.
- [INFERENCE] 장기 backlog 상한은 기본값을 숨겨 구현하지 않고 WBS-07 사용자 결정으로 남겨야 합니다.
- [INFERENCE] backup 성공만 확인하고 restore·ledger/Discord reconciliation을 생략하면 중복 외부 효과를 막을 수 없습니다.
- [INFERENCE] 비용 0원 검증 실패 시 유료·관리형 서비스로 자동 대체하지 않고 outbound를 차단합니다.
- [INFERENCE] WBS-27 뒤 Workflow 13~15 closure를 생략하면 review되지 않거나 문서·commit과 다른 artifact가 Deployment Readiness에 들어갈 수 있습니다.
- [INFERENCE] WBS-28의 blocker를 일반 risk acceptance로 우회하면 미검증 비용·보안·backup 조건으로 실제 mutation이 시작될 수 있습니다.
- [INFERENCE] WBS-29의 publish·apply·smoke·activation 승인을 하나로 합치면 중간 실패에서 stop/rollback 범위와 외부 효과가 불명확해집니다.
- [INFERENCE] WBS-30의 monitoring 시작과 evaluation request를 같은 사전 승인으로 묶으면 실제 표본·cutoff 확인 전 평가가 고정되거나 운영 evidence 수집이 불필요하게 지연됩니다.
- [INFERENCE] 사용자가 직접 확인하는 monthly billing evidence가 누락되면 telemetry상 0건만으로 비용 Hard Gate를 false pass할 수 있습니다.
- [INFERENCE] WBS-31에서 MVP-B를 greenfield 재생성하거나 MVP-A data/evidence를 reset하면 회귀 기준선·migration·운영 학습을 잃으므로 incremental delta와 data-preserving migration을 우선합니다.
- [FACT] Kafka, Spark, 외부 원문 크롤링, 다중 AI 동시 운영과 유료 자동 fallback은 제안하거나 구현하지 않습니다.

## Proposed Documentation Changes

[FACT] 날짜별 기록은 [검토 이력](implementation-review-history.md#proposed-documentation-changes)으로 이동했습니다. 현재 Task는 [AI Context](../../ai-context.md)를 참조합니다.

## Sequential Review State

[FACT] 날짜별 기록은 [검토 이력](implementation-review-history.md#sequential-review-state)으로 이동했습니다. 현재 Task는 [AI Context](../../ai-context.md)를 참조합니다.

## Recommended Next Action

[INFERENCE] 현재 Task·blocker·다음 작업의 정본은 [AI Context](../../ai-context.md)입니다. 구조 분리 결과와 검증 범위는 [구조 개선 검토](document-structure-review.md)를 참조합니다. WBS 실행·외부 spike·Coding Readiness·구현·배포는 자동으로 시작하지 않습니다.
