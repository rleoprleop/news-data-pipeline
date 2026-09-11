# Feature Implementation Plan

## Document Guide

[FACT] 2026-09-10 승인된 B안에 따라 [구현 계획](implementation-plan.md)의 해당 본문을 이동했습니다. Workflow 9 계획과 F01~F08 승인 범위는 유지하며 실제 설계 결과·구현·검증·배포 완료를 뜻하지 않습니다. 현재 Task·blocker·다음 작업은 [AI Context](../../ai-context.md)를 참조합니다.

[FACT] WBS 간 참조는 [전체 WBS 안내](implementation-plan.md#work-breakdown-structure), 계획 승인 경위는 [검토 이력](implementation-review-history.md#sequential-review-state)을 참조합니다. Product·Requirement·AD·DDI·MIN의 기존 정본은 변경하지 않습니다.

## Quick Navigation

- [WBS-10 — Python 실행·테스트 기반 상세 checkpoint](#wbs-10--python-실행테스트-기반-상세-checkpoint)
- [WBS-11 — Configuration·Secret·outbound gate 구현 상세 checkpoint](#wbs-11--configurationsecretoutbound-gate-구현-상세-checkpoint)
- [WBS-12 — PostgreSQL schema·migration 구현 상세 checkpoint](#wbs-12--postgresql-schemamigration-구현-상세-checkpoint)
- [WBS-13 — 예정 batch·durable work ledger 구현 상세 checkpoint](#wbs-13--예정-batchdurable-work-ledger-구현-상세-checkpoint)
- [WBS-14 — RSS 수집·Raw evidence·candidate admission 구현 상세 checkpoint](#wbs-14--rss-수집raw-evidencecandidate-admission-구현-상세-checkpoint)
- [WBS-15 — 무료 AI·analysis boundary 구현 상세 checkpoint](#wbs-15--무료-aianalysis-boundary-구현-상세-checkpoint)
- [WBS-16 — 선정·finalization 구현 상세 checkpoint](#wbs-16--선정finalization-구현-상세-checkpoint)
- [WBS-17 — Discord rendering·delivery 구현 상세 checkpoint](#wbs-17--discord-renderingdelivery-구현-상세-checkpoint)
- [WBS-18 Gateway listener·feedback·누락 요청 구현 상세](#wbs-18-gateway-listenerfeedback누락-요청-구현-상세)
- [WBS-19 Bounded feedback reconciliation·delivery recovery 구현 상세](#wbs-19-bounded-feedback-reconciliationdelivery-recovery-구현-상세)
- [WBS-20 관측성·비용·보안 evidence 구현 상세](#wbs-20-관측성비용보안-evidence-구현-상세)
- [WBS-21 Backup/restore 및 recovery gate 구현 상세](#wbs-21-backuprestore-및-recovery-gate-구현-상세)
- [WBS-22 Evaluation runner 구현 상세](#wbs-22-evaluation-runner-구현-상세)

## Detailed Checkpoints

### WBS-10 — Python 실행·테스트 기반 상세 checkpoint

[FACT] 관련 Requirement는 NFR-MNT-001~002, NFR-SEC-001~002이고 관련 Decision은 AD-01·03·06·14·23입니다. 선행 조건은 WBS-09의 실제 `READY`와 사용자가 승인한 starting commit·branch·test·rollback 범위이며, 직접 후속 owner는 WBS-11~13이고 image·K3s 배포 산출물은 WBS-27이 소유합니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-10.A | Repository·package bootstrap | 하나의 installable Python project, 최소 source/test directory와 clean-checkout setup evidence |
| WBS-10.B | Runtime·dependency lock | 승인 Python/build/dependency/test tool version, runtime/dev dependency 구분과 재현 가능한 lock |
| WBS-10.C | Role·command dispatch | 두 runtime role과 Prepare·Delivery-gate·Recovery/Reconciliation·Listener·Evaluation 다섯 command의 explicit dispatch |
| WBS-10.D | Configuration bootstrap | Secret 없는 비민감 startup input, 명시적 source·precedence handoff와 누락·불일치 fail-closed skeleton |
| WBS-10.E | Test harness | Fake adapter, controllable clock·identity·environment와 실제 network 없는 unit/contract test entry |
| WBS-10.F | Quality·security baseline | 승인 format/lint/type/test·secret scan 후보와 network/ambient-credential negative check |
| WBS-10.G | Branch·rollback·handoff | File-only rollback, changed-file allowlist와 WBS-11~13 후속 책임 연결 |

[FACT] 상위 application role은 scheduled batch role과 long-running Discord listener role 두 개입니다. 하나의 role이 여러 command entry point를 가질 수 있으며, command 수를 별도 deployment service·microservice 수로 해석하지 않습니다.

| Command boundary | 상위 role·형태 | WBS-10 skeleton 책임 | 실제 업무 owner |
| --- | --- | --- | --- |
| Prepare | Scheduled batch | Explicit dispatch, lifecycle·dependency port, 미구현 fail-closed | WBS-13~16 |
| Delivery-gate | Scheduled batch | Explicit dispatch, target-time input port, 미구현 fail-closed | WBS-13·17 |
| Recovery/Reconciliation | Scheduled batch | Explicit dispatch, work-claim port, 미구현 fail-closed | WBS-13·19 |
| Gateway listener | Long-running listener | Startup/shutdown·signal hook와 event adapter port, 미구현 fail-closed | WBS-18~19 |
| Evaluation | Independent command/function | User request·read-only dependency port, 외부 credential 없는 미구현 fail-closed | WBS-22 |

[INFERENCE] Package 책임은 command dispatch, application orchestration, domain type/policy, persistence/external adapter port, runtime configuration·clock·identity와 test fixture/fake를 구분해야 합니다. 실제 directory·module 이름은 WBS-09 실제 실행에서 승인하되 별도 provider plugin framework, dependency-injection framework 또는 다섯 service scaffold를 기본값으로 도입하지 않습니다.

[FACT] WBS-10은 RSS·AI·Discord·REST adapter, PostgreSQL schema/migration·실제 persistence, business state transition, container image 또는 K3s manifest를 구현하지 않습니다. Interface/port skeleton이 존재해도 실제 외부 호출·DB mutation 또는 정상 업무 결과를 만들지 않습니다.

| Skeleton invocation | 요구 결과 | 금지 결과 |
| --- | --- | --- |
| `--help` 또는 동등한 usage 조회 | 비민감 command 목적·argument contract 표시 | Credential·환경 원문·미승인 default 표시 |
| 필수 configuration 누락 | Typed startup/configuration error와 non-zero 종료 | 정상 0건·batch 성공·listener 정상 종료 |
| 아직 연결되지 않은 업무 handler | 명시적 `not_implemented` 또는 readiness error와 non-zero 종료 | No-op exit 0, source/evidence row 생성 |
| 예상하지 못한 role/command | 실행 전 validation 거부 | 다른 role 또는 default command 자동 선택 |
| Shutdown/signal fixture | 새 업무 시작 중단과 bounded lifecycle hook 관측 | 외부 호출이 없는데 성공 work 생성 |

[INFERENCE] Python version, build backend, package/dependency manager와 test·format·lint·type 도구는 WBS-09의 evidence-backed 선택 없이 문서나 code default로 고정하지 않습니다. Runtime dependency와 development-only dependency를 구분하고, 실제 필요가 증명되지 않은 web framework·ORM·task queue·plugin system·cloud SDK를 foundation dependency에 추가하지 않습니다.

[FACT] Dependency lock은 같은 승인 runtime/platform 범위의 clean checkout에서 설치와 test를 재현할 수 있어야 하고 직접·전이 dependency와 source/version을 식별해야 합니다. 취약점·license·update 도구와 lock hash 정책은 WBS-09 실제 선택 전 [UNKNOWN]이며, 유료 registry·service 사용을 dependency 편의로 자동 추가하지 않습니다.

[FACT] Configuration bootstrap은 실제 API key·token·webhook·interaction secret·DB password를 포함하거나 Repository의 `.env`를 신뢰 source로 자동 탐색하지 않습니다. Ambient provider credential·SDK default·cloud metadata를 자동 선택하지 않고 예상하지 못한 환경 변수는 승인 configuration으로 취급하지 않습니다. 실제 Secret 주입·활성화·rotation·outbound gate는 WBS-11이 구현합니다.

[INFERENCE] Test harness는 clock, ID/UUID·randomness, environment/configuration와 외부 adapter를 명시적으로 제어할 수 있어야 합니다. 기본 unit/contract test는 실제 DNS·HTTP·socket 또는 provider SDK 호출을 금지하고 fake가 없는 outbound 시도를 실패시키며, external sandbox test는 후속 WBS의 별도 marker·환경·사용자 승인 없이는 실행하지 않습니다.

| Foundation verification | 기대 결과 |
| --- | --- |
| Clean checkout setup | 승인된 단일 setup 절차와 lock으로 install/test 재현 |
| Package import | Import만으로 network·DB·credential lookup·background task 시작 0건 |
| Command dispatch | 다섯 command가 정확한 boundary로만 dispatch되고 unknown/default fallback 0건 |
| Fail-closed startup | 누락·불일치·미구현 상태가 non-zero이며 정상 0건/성공 결과 0건 |
| Network canary | 기본 test suite의 실제 outbound connection attempt 0건 |
| Credential canary | Ambient·fixture secret이 log·error·snapshot에 노출되거나 자동 사용된 경우 0건 |
| Determinism | 고정 clock·ID 입력에서 같은 command/test 결과 재현 |
| Scope check | Migration·Docker/K3s·실제 adapter·business implementation 포함 0건 |

[FACT] WBS-10 branch는 실제 Feature Implementation 변경이므로 WBS-09에서 승인된 starting `main` commit과 `codex/` prefix의 기능 단위 branch를 사용하고 PR review 대상으로 둡니다. 실제 branch 이름은 사용자 승인 전 [UNKNOWN]이며, 대화마다 새 branch를 만들지 않습니다.

[INFERENCE] WBS-10 rollback은 DB migration·외부 호출·배포 상태가 없는 file/branch 범위여야 합니다. Branch 폐기 또는 PR revert가 다른 사용자 변경이나 Workflow 9 문서를 되돌리지 않으며, dependency/bootstrap 변경은 하나의 검토 가능한 slice로 유지합니다.

[INFERENCE] WBS-10 완료 기준은 clean-checkout setup과 승인된 quality/test command가 통과하고 import·다섯 command에서 실제 외부 호출·DB mutation·ambient credential 선택·background side effect·false success가 각각 0건이며, changed-file allowlist와 dependency inventory·test evidence가 review에 연결되는 것입니다.

[UNKNOWN] 실제 Python version, project metadata 파일, source layout, command 이름·argument·exit code, build/dependency/test/quality 도구, signal/graceful-shutdown timeout, platform matrix와 branch 이름은 WBS-09의 실제 `READY` 결정 전 확정되지 않습니다. 이 계획 승인은 파일·dependency·branch·code·test·image·manifest 생성을 승인한 것이 아닙니다.

### WBS-11 — Configuration·Secret·outbound gate 구현 상세 checkpoint

[FACT] 관련 Requirement는 FR-015~016, NFR-REL-003, NFR-COST-001, NFR-OBS-001, NFR-SEC-001~002, NFR-REC-001, DR-014, EXT-AI-003~004, EXT-FB-006, VR-009·011·013·018이고 관련 Decision은 AD-02~04·10·13~16·22, DDI-05~06, MIN-03·05·07입니다. 선행 설계는 WBS-03~05이고 실행 기반은 WBS-10, DB-backed integration 선행은 WBS-12입니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-11.A | 비민감 configuration load·validation | 승인 source·precedence·typed validation error, unknown/default/ambient fallback 0건 |
| WBS-11.B | Secret handle·access boundary | 역할·service·purpose별 opaque reference와 raw value 최소 lifetime·redaction test |
| WBS-11.C | Configuration snapshot repository | 등록·불변성·활성화·batch binding 분리와 WBS-12 schema integration |
| WBS-11.D | Contract/cost evidence resolver | 적용 scope·configuration·version·freshness·coverage 판정과 source reference |
| WBS-11.E | Operation-specific outbound gate | Invocation 직전 DB trust·pause·work/session·configuration·contract·cost·credential 조건과 typed decision |
| WBS-11.F | Pause·kill-switch state handoff | Scope별 신규 invocation 차단, in-flight uncertainty와 source evidence 보존 |
| WBS-11.G | Manual resume·rotation·mismatch | 전체 readiness·사용자 승인, 자동 resume·credential/provider fallback 0건 |
| WBS-11.H | Contract·security·fault tests | Pure unit, DB integration, evidence-change concurrency와 redaction/rollback evidence |

[INFERENCE] WBS-11.A~B는 DB에 canonical state를 만들지 않는 pure configuration/Secret access boundary이므로 WBS-10 뒤 독립적으로 구현·시험할 수 있습니다. Configuration snapshot·contract/cost evidence·operational event를 실제로 읽고 쓰는 WBS-11.C~H는 WBS-12의 승인 schema/migration 뒤에 integration closure합니다. 중간 단계에 임시 JSON/file/in-memory 정본을 만들지 않습니다.

| Configuration 계층 | 소유 내용 | 금지 내용 |
| --- | --- | --- |
| 비민감 runtime input | 명시된 environment/CLI/file source의 승인 field와 reference | Secret 원값, ambient SDK/cloud default |
| `configuration_snapshot` | Provider/model·free-only·policy/output/runtime revision 등 실행 기준 | Secret 값, 현재 pause/active boolean, 반복 cost/contract 결과 |
| Secret boundary | Runtime에 필요한 raw credential의 제한된 access와 opaque reference/version | DB·snapshot·log·metric·trace·error·AI input에 원값/파생 민감값 보존 |
| `external_contract_check` | 공식 계약·sandbox·적용 configuration의 dated 판정 | Configuration 복제, 공식 원문·전체 응답·credential |
| `cost_safety_evidence` | 적용 비용 scope·기간·무료/불명/위반과 redacted evidence reference | 자동 billing API, invoice 원문·account identifier |
| `operational_event` | 활성화·pause·resume·violation·사용자 승인과 source reference | Snapshot/evidence 결과 내용 복사 |

[FACT] Secret 원값뿐 아니라 credential에서 계산한 hash·fingerprint처럼 공격이나 상관에 이용될 수 있는 파생 민감값도 일반 configuration·DB·log에 저장하지 않습니다. Secret reference/version은 비밀 자체에서 계산하지 않은 opaque identifier를 사용해야 하며 실제 생성·rotation 방식은 WBS-11.B·27 전 [UNKNOWN]입니다.

[FACT] Configuration loader는 승인된 source와 precedence만 읽습니다. 예상하지 못한 environment variable, SDK credential chain, cloud metadata, home-directory credential file, 다른 account/project/provider/model 또는 비용 경로를 자동 선택하지 않습니다. Unknown field·중복 source·서로 다른 값·필수값 누락은 override하지 않고 typed mismatch/validation failure로 차단합니다.

[FACT] `configuration_snapshot`은 설정 등록·변경 시에만 생성하며 process startup, batch 실행, pause/resume마다 복제하지 않습니다. 실제 Prepare batch는 첫 내부 commit에서 하나의 processing snapshot을 binding하고, 후속 설정 활성화·Secret rotation은 기존 batch의 provider/model·판단/output contract를 소급 변경하거나 재binding하지 않습니다.

[INFERENCE] Secret rotation은 같은 승인 service·account/project·purpose·cost boundary 안에서 별도 credential lifecycle로 처리하고 snapshot의 정책 의미가 바뀌지 않으면 snapshot 자체를 자동 복제하지 않습니다. Scope·provider·model·account/project·비용 또는 계약 조건이 바뀌면 새 configuration/contract/cost 검증과 사용자 승인이 필요합니다. 실제 compatibility 판정은 WBS-03.B~C·09에서 승인합니다.

| Gate input category | 호출 직전 최소 질문 | 부족·불일치 결과 |
| --- | --- | --- |
| Operation/scope | 어느 RSS·AI·Discord delivery·REST·Gateway operation인가 | Unknown operation은 실행 금지 |
| DB trust | Source ledger 연결·commit·integrity가 신뢰 가능한가 | 신규 외부 효과와 business mutation 차단 |
| Pause/restore/backup | 적용 scope pause, backup gap, restore validation 상태가 허용되는가 | 해당 scope 차단, 자동 resume 금지 |
| Work/session authority | Exact work claim·lease/fence 또는 listener session 권한이 유효한가 | Invocation 시작 금지 |
| Configuration binding | 신규/기존 batch에 적용할 승인 snapshot이 정확히 하나인가 | Default/rebinding 없이 차단 |
| External contract | Service·operation·configuration에 적용되는 check가 유효한가 | 다른 service/operation evidence 재사용 금지 |
| Cost | 비용 가능 전체 적용 scope의 사전 evidence가 유효한가 | 해당 비용 가능 invocation 차단 |
| Credential | 승인 reference/version·purpose·permission·status가 유효한가 | 다른 credential fallback 없이 차단 |
| Domain prerequisite | Committed source result·timing·recovery 권한 등 operation 조건이 충족되는가 | 업무 결과를 만들지 않고 typed reason 유지 |

[INFERENCE] Gate decision은 최소한 operation·exact scope, work/session과 적용 configuration, contract/cost/credential/DB/pause evidence reference, 판정 시각·freshness, allow 또는 typed blocking reason과 재검증 owner를 반환해야 합니다. 실제 field·enum·cache·transaction은 WBS-04.D·05·12 전 [UNKNOWN]입니다.

[FACT] Gate `allow`는 그 시점에 외부 invocation 준비를 진행할 수 있다는 판정일 뿐 외부 호출 성공, AI 분석 완료, Discord 수락, feedback 적용 또는 업무 완료를 의미하지 않습니다. Domain attempt는 WBS-05의 prepared→invocation-started→evidence 경계를 별도로 따라야 합니다.

[FACT] Gate는 process startup에서 한 번 확인하고 재사용하지 않습니다. 각 비용 가능 외부 invocation의 `invocation_started` commit 직전에 적용 조건을 다시 읽고, 그 사이 pause·DB trust·contract·cost·credential·lease가 바뀌면 같은 attempt를 원인과 함께 차단하며 새 attempt나 fallback을 만들지 않습니다. 실제 isolation/lock 방식은 WBS-05·12에서 닫습니다.

[FACT] Pause와 kill switch는 적용 scope의 신규 work/invocation을 차단하고 source·영향·사용자 조치를 `operational_event`에 연결합니다. Process 종료나 Pod scale-down은 invocation-started 외부 효과가 발생하지 않았음을 증명하지 않으므로 late usage/response/acceptance와 `external_effect_uncertain`을 유지합니다. PostgreSQL·PVC·backup을 자동 삭제하지 않습니다.

[FACT] Resume는 configuration·contract·cost·credential 정상화만으로 자동 수행하지 않습니다. DB/ledger trust, backup gap·restore validation, 필요한 external-effect reconciliation과 적용 scope의 사용자 승인을 모두 대조한 뒤 `operational_event`에 수동 resume를 기록하고 승인 범위만 활성화합니다. 과거 violation·pause·failure evidence를 삭제하지 않습니다.

[FACT] 실제 월별 billing·usage는 사용자가 직접 확인합니다. WBS-11은 billing API·invoice download/scraping을 구현하지 않고 WBS-20이 보존한 기간·scope·판정·redacted reference를 gate/evaluation source로 읽습니다. 월 결과 미존재를 사전 비용 안전으로 대신하거나 invoice/account identifier를 저장하지 않습니다.

| WBS-11 verification layer | 필수 fixture |
| --- | --- |
| Pure configuration unit | Missing/unknown/duplicate/conflicting field, precedence, ambient env·SDK/cloud default 차단 |
| Secret boundary unit | Role/purpose mismatch, inactive/rotated reference, raw/derived secret canary redaction |
| DB integration | Snapshot immutability, activation/binding 분리, evidence/reference completeness, operational event append |
| Gate matrix | Operation×DB trust×pause×work/session×configuration×contract×cost×credential×domain prerequisite |
| Concurrency/fault | Gate 직전 evidence 변경, lease 교체, pause 경쟁, invocation-started 뒤 종료·late evidence |
| Resume/rotation | Same-scope rotation, changed scope/configuration, restore pending, user approval 누락, automatic fallback/resume 0건 |
| Cost/privacy | Billing coverage 누락, invoice·account/credential canary의 DB/log/error 노출 0건 |

[INFERENCE] WBS-11 rollback은 A~B의 pure module 변경과 C~H의 DB integration 변경을 분리합니다. Schema rollback은 WBS-12가 소유하고, 이미 기록된 configuration/evidence/operational history를 rollback 명목으로 삭제·수정하지 않습니다. Gate regression이 발견되면 영향 신규 invocation을 fail-closed로 막고 검증된 이전 code/configuration 활성화는 별도 사용자 승인 절차를 따릅니다.

[INFERENCE] WBS-11 완료 기준은 명시하지 않은 configuration·ambient credential·다른 provider/account/cost path 선택, Secret 원값/파생 민감값 저장·노출, stale/startup-only gate, pause 뒤 신규 invocation, process 종료 기반 외부 효과 취소 추정, 자동 credential fallback·resume와 billing API 호출이 각각 0건이고 operation×condition matrix·DB integration·concurrency/redaction test가 통과하는 것입니다.

[UNKNOWN] 실제 configuration field/source/name·precedence, Secret store/mount·opaque reference·rotation, gate reason enum·evidence freshness·cache, activation/resume command, DB transaction/isolation, K3s ServiceAccount/RBAC/network와 사용자 monthly evidence 입력 interface는 WBS-04.D·05·09·12·20·27 전 확정되지 않습니다. 이 계획 승인은 configuration·Secret·DB·code·billing/외부 API·K3s 변경을 승인한 것이 아닙니다.

### WBS-12 — PostgreSQL schema·migration 구현 상세 checkpoint

[FACT] 관련 Requirement는 DR-001~014, NFR-DQ-002, NFR-REL-001~002, NFR-OBS-001, NFR-SEC-001, NFR-REC-001, VR-012~019이고 관련 Decision은 AD-02~03·09~10·13·22, DDI-01~10, MIN-01~08입니다. 선행 조건은 WBS-04의 최종 physical closure, WBS-05의 transaction·lease 계약, WBS-09의 실제 `READY`, WBS-10 실행 기반과 사용자가 승인한 WBS-12 branch/test/rollback 범위입니다.

[FACT] WBS-12는 미래 Workflow 11의 구현 Task 계획입니다. 현재 Workflow 9에서는 SQL schema·migration 파일·PostgreSQL instance·data·credential을 생성하거나 변경하지 않으며, 계획 승인만으로 WBS-09를 통과하거나 구현 진입을 승인한 것으로 보지 않습니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-12.A | Physical baseline 입력 잠금 | 승인 disposition·identity/reference/type·constraint·query-index register 전부의 version/fingerprint와 coverage, blocking physical `[UNKNOWN]` 0건 |
| WBS-12.B | Migration 실행 기반·metadata | 승인 도구와 PostgreSQL version, migration identity·순서·적용 이력·checksum, clean apply·same-set reapply·applied-file drift fail-closed evidence |
| WBS-12.C | Canonical schema slice | Disposition에 승인된 MVP-A physical relation·reference·history만 dependency order로 생성하고 no-table·projection·external-reference·MVP-B-deferred 항목의 무승인 relation 0건 |
| WBS-12.D | Constraint·reference·query-index | DB가 강제 가능한 identity·uniqueness·reference·append-only·fencing invariant와 query-index map 검증, application-only 예외의 근거·위험·사용자 승인 |
| WBS-12.E | 실행 identity·권한 경계 | Migration owner와 application role 분리, application DDL·runtime auto-migrate·Secret persistence·권한 자체 확대 0건 |
| WBS-12.F | Upgrade·backfill·cutover | Additive schema change, bounded backfill, validation, compatible cutover와 destructive cleanup을 분리하고 단계별 중단·재개·data-preservation evidence |
| WBS-12.G | Rollback·forward-fix·recovery handoff | 명시적 test DB reset, compatible application rollback, forward-fix 기본 경로와 WBS-21·28 production restore 승인 경계 |
| WBS-12.H | 전체 migration 검증·handoff | 빈 DB, same-set reapply, 실제 이전 version부터 upgrade, interruption/retry, drift, constraint negative, 권한, fingerprint와 data-preservation evidence 후 WBS-11.C~H·13에 인계 |

[FACT] Schema 대상은 WBS-04.A의 disposition register와 WBS-04.B~D의 승인된 physical 결정에 존재하는 항목으로 제한합니다. Logical entity마다 relation을 자동 생성하거나 view/query projection·reference-only·no-table 항목을 별도 canonical relation으로 승격하지 않으며, Raw RSS·AI/Discord evidence의 승인 범위를 넘어 자유형 payload를 추가하지 않습니다.

[FACT] MVP-A migration에는 MVP-B의 월별 Insight, 장기 결과 재사용·normalization, 자동 retention lifecycle을 포함하지 않습니다. 이후 MVP-B 승인이 있더라도 적용 완료 MVP-A migration을 수정하지 않고 별도의 새 migration과 upgrade 검증을 사용합니다.

| Migration 상태 | 필수 동작 | 금지 동작 |
| --- | --- | --- |
| 빈 DB | 승인 baseline을 순서대로 적용하고 expected schema fingerprint·constraint를 검증 | 누락 항목을 runtime이 임의 생성 |
| 동일 승인 set 재실행 | 이미 적용된 identity·checksum을 확인하고 중복 DDL·data mutation 없이 종료 | 기존 migration을 재해석하거나 다시 적용 |
| 적용 파일·checksum drift | 실행 전 fail-closed하고 운영자 검토 evidence 생성 | DB 상태에 맞춰 history를 자동 수정 |
| 새 upgrade | 이전 승인 version에서 순서대로 적용하고 전후 data·constraint를 검증 | Version 건너뛰기·순서 자동 변경 |
| 적용 중 중단 | 실제 transaction boundary와 완료 evidence에 따라 안전하게 재개 또는 차단 | 부분 적용을 성공으로 기록 |

[INFERENCE] PostgreSQL이 transaction으로 보호할 수 있는 DDL은 승인 도구의 실제 동작을 검증한 뒤 transaction 경계 안에 두고, transaction 밖에서 실행해야 하는 단계가 있으면 별도 migration step·precondition·completion evidence·retry/forward-fix를 정의해야 합니다. 정확한 DDL, lock·statement timeout과 isolation은 공식 문서·승인 tool/version evidence 없이 기본값으로 고정하지 않습니다.

[INFERENCE] Schema change와 기존 data backfill이 함께 필요한 upgrade는 `additive schema → bounded backfill → completeness/invariant validation → compatible cutover → 별도 승인 cleanup` 단계로 분리합니다. 중단된 backfill은 이미 검증된 행을 파괴하지 않고 재개 가능해야 하며, destructive cleanup은 호환 기간·backup/restore readiness·사용자 승인이 없으면 실행하지 않습니다.

[INFERENCE] Identity·uniqueness·reference·허용 값·필수값·불변 history·current lease/fencing처럼 DB가 강제할 수 있는 불변식은 physical constraint 또는 승인된 DB atomicity로 보호합니다. Application-only 검사가 필요한 예외는 근거, 경쟁 조건, fail-closed 동작, verification owner와 사용자의 명시적 승인이 있어야 하며 구현 편의만으로 예외를 만들지 않습니다.

[INFERENCE] Index는 WBS-04의 query-index map에 있는 canonical query·filter·join·ordering과 연결하고, 존재 여부뿐 아니라 대표 fixture의 query plan·write cost·constraint 역할을 검증합니다. 승인 query가 없는 speculative index, MVP-B용 index와 중복 index를 기본값으로 추가하지 않습니다.

| Identity | 허용 권한 | 금지 권한·동작 |
| --- | --- | --- |
| Migration owner | 승인된 target·migration set의 schema 변경과 필요한 검증 | AI·Discord credential 사용, 다른 DB/schema 광범위 변경 |
| Application runtime | 승인 relation의 역할별 제한된 DML·조회 | DDL, role/GRANT 변경, migration history 조작, startup auto-migrate |
| Test migration identity | 명시적으로 격리된 disposable test DB의 apply/reset | Production 또는 사용자 DB를 이름 추정·glob로 선택 |
| Backup/restore identity | WBS-21·28에서 별도 승인된 backup/isolated restore 범위 | WBS-12 test가 production restore·자동 resume 수행 |

[FACT] Migration credential·Secret 원값은 source, migration metadata, DB, log, test fixture와 error에 저장하지 않습니다. Target database/schema는 명시적 allowlist와 environment identity로 확인하며, broad/default target이나 연결 대상 불명확 상태에서는 실행하지 않습니다.

[FACT] Rollback은 네 가지를 구분합니다. Disposable nonproduction DB는 명시적으로 확인된 target만 reset/recreate할 수 있고, application rollback은 호환되는 schema를 유지하며, schema defect는 data-preserving forward-fix를 기본으로 하고, production restore는 WBS-21의 검증과 WBS-28의 별도 사용자 승인 없이 수행하지 않습니다. Data loss 가능 down migration·drop·history rewrite는 일반 자동 rollback 경로가 아닙니다.

| 검증군 | 최소 검증 내용 |
| --- | --- |
| Baseline | Empty DB apply, expected object/constraint/index coverage, schema fingerprint |
| Reapply·drift | 같은 승인 set 재실행의 no duplicate mutation, applied-file/order/checksum mismatch fail-closed |
| Upgrade | 실제 N-1 fixture부터 순차 upgrade, 전후 canonical identity·row·reference·history preservation |
| Fault | 각 transactional/nontransactional boundary 중단, retry, partial-step success 오판 0건 |
| Invariant | Duplicate identity, invalid reference/value, immutable history mutation, stale fence write의 negative test |
| Permission | Application DDL/history mutation·migration credential 혼용·Secret canary 노출 0건 |
| Scope | Disposition coverage 100%, 무승인 relation·raw payload·MVP-B schema 0건 |
| Recovery handoff | Migration version/fingerprint가 WBS-21 restore compatibility와 WBS-28 runbook 입력으로 연결됨 |

[FACT] 최초 baseline만 존재하는 시점에는 존재하지 않는 N-1 upgrade를 통과했다고 기록하지 않습니다. 이 단계에서는 empty apply·same-set reapply·중단/재시도·drift·invariant를 검증하고, 두 번째 migration부터 실제 직전 승인 schema fixture를 보존해 N-1 upgrade와 data preservation을 필수 검증합니다.

[INFERENCE] WBS-12 완료 뒤 WBS-11.C~H는 configuration/evidence/gate repository integration을 닫고 WBS-13은 같은 schema의 work·attempt·lease/fence 계약 위에서 구현합니다. WBS-12가 application repository·business transition·RSS/AI/Discord adapter·backup/restore·K3s deployment를 대신 구현하지 않습니다.

[INFERENCE] WBS-12 완료 기준은 승인 disposition coverage 100%, blocking physical unknown 0건, 빈 DB와 적용 가능한 실제 upgrade path의 재현, migration drift·부분 성공·권한 우회·application auto-migrate·Secret 노출·MVP-B 포함·무승인 destructive rollback이 각각 0건이며 migration/invariant/data-preservation evidence가 관련 Requirement·Decision과 연결되는 것입니다.

[UNKNOWN] 실제 PostgreSQL version·extension, driver·migration/ORM 도구, schema/table/column/type·constraint/index 이름, migration identity와 metadata 표현, transaction/lock/statement timeout, schema fingerprint, 이전-version fixture 보존 방식과 production-compatible upgrade window는 WBS-04 final closure·WBS-09 실제 readiness에서 결정해야 합니다. 이 계획 승인은 해당 값, SQL·migration file, DB·credential·data 변경 또는 production migration 실행을 승인한 것이 아닙니다.

### WBS-13 — 예정 batch·durable work ledger 구현 상세 checkpoint

[FACT] 관련 Requirement는 FR-004~005·024, NFR-REL-001~003, NFR-REC-001, NFR-OBS-001, NFR-TIME-001, NFR-LAT-001, VR-004~005·013~014·017~018이고 관련 Decision은 AD-02~03·08·10·19, DDI-05·09, MIN-05~06입니다. 선행 조건은 WBS-05의 최종 semantic contract, WBS-09의 실제 `READY`, WBS-11.C~H, WBS-12와 사용자가 승인한 WBS-13 branch/test/rollback 범위입니다.

[FACT] WBS-13은 미래 Workflow 11의 공통 coordination 구현 Task 계획입니다. 현재 Workflow 9에서는 application code·SQL·DB·scheduler·K3s resource 또는 외부 호출을 생성하거나 변경하지 않으며, 계획 승인만으로 구현 진입을 승인한 것으로 보지 않습니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-13.A | Scheduled slot ledger | Asia/Seoul 일자·오전/오후 slot의 단일 identity, 예정 시작·전달 시각 불변성과 목표 시각 뒤 historical-ledger-only 경계 |
| WBS-13.B | Typed work key·admission | Namespace·canonical target·external-effect scope 기반 create/reuse/historical-only/no-admission/completed-result no-op 판정 |
| WBS-13.C | Claim·attempt transaction | Current state/version·DB time·lease를 대조하고 claim 성공과 append-only attempt 생성을 원자적으로 commit하며 실패 attempt 0건 |
| WBS-13.D | Lease renewal·reclaim·fencing | Exact token·DB clock, expiry·renewal·replacement, worker restart·token ABA와 stale write 차단 |
| WBS-13.E | Guarded internal transition | Logical key·expected state/version·current token·domain precondition을 같은 commit에서 재검증하는 내부 mutation boundary |
| WBS-13.F | Safe internal resume | Commit된 내부 결과 재사용, DB acknowledgement 불명확 재조회와 invocation-started 외부 효과 자동 재실행 금지 |
| WBS-13.G | Prepare binding·projection | 실제 Prepare 첫 내부 commit의 immutable configuration snapshot binding과 `batch_execution` projection-only 조회 |
| WBS-13.H | Concurrency·fault·handoff | 동시 claim·중단·restart·lease 교체·과거 slot·DB trust fixture와 WBS-14~19·22 domain integration owner 연결 |

[FACT] 예정 slot identity는 Asia/Seoul 일자와 오전·오후 slot으로 결정합니다. Scheduler trigger 시각, CronJob·Job·Pod 이름/UID, process·thread, claim owner, attempt ID와 임의 run ID는 실행 evidence일 수 있지만 예정 batch나 logical work의 canonical identity가 아닙니다.

| Slot 관측 시점·상태 | 허용 결과 | 금지 결과 |
| --- | --- | --- |
| 목표 전달 시각 전, slot 미등록 | 동일 deterministic `scheduled_batch` create 또는 concurrent winner 재조회 | Trigger마다 새 batch 생성 |
| 목표 전달 시각 전, Prepare 미시작 | Exact Prepare work create/reuse와 claim 검토 | Configuration·gate 확인 없는 실행 |
| 목표 전달 시각 전 시작, 목표 시각 뒤 미완료 | 저장된 내부 상태와 외부-effect 경계를 대조한 safe resume·processing-delayed owner handoff | 새 scheduled batch·새 source pipeline 생성 |
| 목표 전달 시각 뒤 처음 발견한 과거 slot | Historical ledger record와 미실행/측정 불가 판정용 evidence | Prepare work/attempt·RSS·AI·selection·Discord 시작 |
| Ledger/restore completeness 불명 | 원인과 `not_measurable` owner로 차단 | Attempt 부재를 `not_executed`·정상 0건으로 추정 |

[INFERENCE] 목표 전달 시각 전 admission·claim 판정은 승인 schedule과 PostgreSQL에서 비교 가능한 기준 시각을 다시 읽어야 합니다. 목표 시각 전에 이미 시작한 Prepare의 내부 재개와 목표 시각 뒤 처음 시작하는 pipeline을 동일하게 취급하지 않으며, 정확한 timestamp type·precision·clock-error allowance는 WBS-04/WBS-09의 승인값을 소비합니다.

[FACT] 공통 ledger는 예정 batch Prepare, batch candidate AI analysis, delivery release, reconciliation request, recovery case 처리와 사용자 요청 evaluation의 여섯 namespace를 인식합니다. WBS-13은 namespace 충돌 방지와 공통 admission/claim primitive 및 Prepare work를 구현하고, 나머지 work의 exact target·scope·domain eligibility는 WBS-15·17·19·22가 승인 계약에 따라 연결합니다. 임의 새 work type이나 trigger별 placeholder work를 만들지 않습니다.

[FACT] Typed key는 work namespace, canonical target과 외부 효과 scope의 원래 구성요소·interpretation version을 비교 가능하게 보존합니다. 문자열 구분자 조합이나 hash/digest 하나만으로 원본 identity를 대체하지 않으며, digest를 보조값으로 쓸 때는 승인 canonical serialization·ordering·algorithm version과 collision 대조가 필요합니다.

| Admission 결과 | 의미 | 후속 행동 |
| --- | --- | --- |
| `create` | Exact logical obligation이 처음 확인됨 | 단일 work 생성 뒤 상태·gate 판정 |
| `reuse` | 동일 key work가 이미 존재함 | 기존 work·result·attempt를 읽고 새 key 생성 금지 |
| Historical-ledger-only | 과거 예정 slot 기록만 허용 | Prepare work·attempt·pipeline 생성 금지 |
| No-admission | Scope 부적합·대상 부재 등 logical work 자체를 만들지 않음 | 성공·정상 0건으로 변환하지 않고 typed reason 유지 |
| Completed-result no-op | Canonical immutable result가 이미 존재함 | 저장 결과 재사용, 재계산·새 attempt·외부 호출 금지 |

[FACT] Work가 configuration·contract·cost·DB trust 또는 pause 조건 때문에 실행될 수 없더라도 logical obligation 보존이 필요한 경우에는 exact key의 create/reuse 뒤 waiting/blocked reason을 durable하게 기록합니다. 이를 대상 부재나 과거 slot의 no-admission과 혼동하지 않습니다.

[FACT] Claim에서 current lease 설정과 `work_attempt` 생성은 같은 transaction입니다. 경쟁에서 claim하지 못한 실행은 attempt·domain attempt·외부 invocation을 만들지 않고 기존 work의 current 상태를 읽어 종료합니다. Claim owner 이름만으로 권한을 인정하지 않습니다.

| Guarded operation | 같은 commit에서 재검증할 최소 조건 | 차단 결과 |
| --- | --- | --- |
| Claim + attempt creation | Logical key, expected state/version, DB time, 기존 lease, 새 unique token과 attempt lineage | Claim 실패, attempt 0건 |
| Lease renewal | Current exact token, DB time, expected state와 승인 renewal 범위 | 만료·교체 token 부활 금지 |
| Internal result/state commit | Current token, expected state/version, domain precondition과 중복 canonical result | Stale/duplicate write 0건 |
| Invocation-start authorization handoff | Prepared attempt, exact token, WBS-11 outbound gate와 domain evidence | 외부 invocation 시작 금지 |
| Work completion/release | Exact token·state, canonical result reference와 attempt outcome | 결과·근거 없는 성공 완료 금지 |

[FACT] Lease 유효성·만료는 worker/Pod local clock이 아닌 PostgreSQL 기준 시각으로 판단합니다. Token은 동일 worker 이름·Pod 재시작·만료·교체 뒤에도 이전 권한이 되살아나는 ABA를 막아야 하며, current token이 아닌 execution은 내부 결과·invocation-started·work completion을 commit할 수 없습니다.

[INFERENCE] Lease 기간·renewal cadence·최대 연장·reclaim 순서와 starvation 방지는 하나의 임의 global default를 쓰지 않고 SPK-04의 cold start·scheduler/DB 지연과 work type별 workload evidence를 근거로 결정합니다. Renewal 실패 또는 token 교체를 확인한 worker는 local computation 결과를 폐기하고 protected write·외부 invocation을 시도하지 않습니다.

[FACT] Lease 만료는 새 coordination claim을 검토할 수 있다는 뜻이며 이전 외부 invocation이 없었다는 증거가 아닙니다. 외부 호출이 없는 내부 단계는 committed domain result를 재대조한 뒤 재개할 수 있지만, `invocation_started` 뒤 안전한 response/error 근거가 없는 작업은 `external_effect_uncertain`을 유지하고 lease 만료·process 종료·새 trigger만으로 호출하지 않습니다.

[INFERENCE] DB timeout·connection 종료·commit acknowledgement 유실로 결과를 알 수 없으면 같은 mutation을 즉시 반복하지 않습니다. 새 transaction에서 logical key·expected token·attempt·canonical result를 재조회해 `committed`, `not_committed` 또는 계속 `unknown`으로 판정하고, DB/restore trust가 불명확하면 신규 외부 효과를 차단합니다.

[FACT] 실제 Prepare의 첫 내부 commit은 승인된 processing `configuration_snapshot` reference를 한 번 binding합니다. 진행 중 새 configuration이 활성화돼도 기존 batch를 재binding하지 않으며, 기존 configuration의 contract/cost evidence가 불충분해지면 신규 outbound를 차단하고 다른 snapshot/provider로 자동 전환하지 않습니다.

[FACT] `work_item`은 logical work의 현재 coordination 요약이고 `work_attempt`는 실제 claim execution 이력입니다. `batch_execution`은 `scheduled_batch`와 Prepare work/attempt를 읽는 projection이며 별도 canonical relation을 만들지 않습니다. Work 완료를 AI 성공·selection 완료·Discord 수락·evaluation pass로 추정하거나 domain 결과를 work 상태에 복사하지 않습니다.

| 검증군 | 최소 검증 내용 |
| --- | --- |
| Slot identity | 오전/오후 정상·중복·동시 등록, 경계시각, 과거 slot과 service recovery |
| Admission | 동일 trigger 재실행·다른 trigger 동일 key·상이한 target/scope, create/reuse/no-admission 분리 |
| Claim | 두 worker 동시 claim, winner 한 개·attempt 한 개, loser side effect 0건 |
| Lease/fence | Renewal 경계, W1 token α 만료 뒤 W2 token β claim, W1 restart·stale commit 0건 |
| Crash/DB ambiguity | Claim commit 전/후 중단, acknowledgement 유실, internal result commit 전/후와 재조회 |
| External boundary | Prepared 전후 중단, invocation-started worker 교체, 자동 외부 재호출 0건 |
| Configuration | C1 binding batch와 C2 활성화 후속 batch, 진행 중 rebind·fallback 0건 |
| Projection/completeness | `not_executed`·`incomplete`·`not_measurable`·정상 신규 0건 분리와 별도 batch-execution record 0건 |

[INFERENCE] WBS-13 rollback은 common ledger code와 Prepare integration의 검토 slice를 분리하되 이미 생성된 scheduled batch·work·attempt history를 rollback 명목으로 삭제·수정하지 않습니다. Schema rollback은 WBS-12 경계를 따르고, concurrency regression이 발견되면 새 claim·outbound를 fail-closed로 중지한 뒤 검증된 code/configuration 재활성화에 별도 승인을 요구합니다.

[INFERENCE] WBS-13 완료 기준은 deterministic slot·typed key·duplicate coalescing, claim+attempt atomicity, DB-time lease, token ABA·stale write·commit-unknown·과거 slot pipeline·claim-loser attempt·외부 불명확 효과 자동 재실행·configuration rebind·work/domain cross-state가 각각 검증되고 금지 결과가 0건인 것입니다. 실제 non-deterministic concurrency/fault closure는 WBS-24에서 같은 evidence를 재검증합니다.

[UNKNOWN] 실제 운영 시작일·과거 slot scan 범위, timestamp type·precision·clock error, key physical type·serialization/digest, 상태/reason code, token 전략, lease 기간·renewal·최대 연장, reclaim fairness, PostgreSQL isolation·lock/CAS/constraint, attempt finalize 표현과 safe-resume dispatch 방식은 WBS-04·05·09, SPK-04와 work별 계약에서 승인돼야 합니다. 이 계획 승인은 code·SQL·DB·scheduler/K3s·외부 호출 구현 또는 그 값을 승인한 것이 아닙니다.

### WBS-14 — RSS 수집·Raw evidence·candidate admission 구현 상세 checkpoint

[FACT] 관련 Requirement는 FR-001~005, NFR-PERF-001, NFR-LAT-002, NFR-DQ-002, NFR-REL-001~002, NFR-OBS-001~002, NFR-SEC-001, DR-001~005, EXT-GN-001~006, VR-002·004·013~015이고 관련 Decision은 AD-01~03·08·10·13, DDI-01~02·05~06, MIN-05·08입니다. 외부 선행은 SPK-01의 실제 `pass`와 사용자 승인 RSS 계약이고 구현 선행은 WBS-09 실제 `READY`, WBS-11.C~H, WBS-12~13 및 사용자가 승인한 WBS-14 branch/test/rollback 범위입니다.

[FACT] WBS-14는 미래 Workflow 11의 RSS input implementation Task 계획입니다. 현재 Workflow 9에서는 application code·SQL·DB·HTTP client 설정 또는 실제 RSS 요청을 생성·실행하지 않으며 계획 승인만으로 SPK-01이나 Coding Readiness를 통과한 것으로 보지 않습니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-14.A | RSS operation activation | 공식 endpoint·method·redirect·polling·conditional/retry 계약과 WBS-11 operation gate를 승인 SPK-01 evidence에 결합 |
| WBS-14.B | Fetch lifecycle·HTTP evidence | Prepare work/attempt와 endpoint·request/response 시각, HTTP status·network·timeout·응답 미수신의 source-confirmed 분류 |
| WBS-14.C | Raw snapshot capture | Parsing 전에 수신 body와 byte count·digest·encoding/HTTP reference·완전성 evidence를 승인 physical contract로 보존 |
| WBS-14.D | Safe feed parsing | 외부 entity/DTD resource resolution 없는 XML 처리, feed 구조·namespace·encoding 검증과 feed-level 결과 |
| WBS-14.E | Entry validation·accounting | 필수/선택 field 원값·validation detail, parsed entry별 단일 대표 결과와 count invariant |
| WBS-14.F | Exact article identity | Raw RSS `link` exact match, 최초 observation reference 불변성과 재관찰·field change·미관찰 보존 |
| WBS-14.G | Candidate admission transaction | 현재 실제 scheduled batch에서 article 연결과 MVP-A 최초 candidate admission의 atomicity·동시성·source reference |
| WBS-14.H | Contract·fault·handoff | HTTP/XML/entry/duplicate/concurrency fixture와 WBS-15·16·20, WBS-23~25 verification handoff |

[FACT] MVP-A 수집 요청 대상은 승인된 공식 GeekNews RSS endpoint 하나입니다. GeekNews 상세 페이지·댓글·외부 원문·검색 결과, entry link와 Atom id의 dereference 또는 다른 feed를 요청하지 않습니다. Redirect를 따를지, 동일 host/path만 허용할지와 method/header allowlist는 SPK-01의 실제 contract evidence와 사용자 승인 없이 구현자가 정하지 않습니다.

| HTTP 결과 | 저장·판정 경계 | 금지 해석 |
| --- | --- | --- |
| Body가 있는 검증 대상 응답 | Fetch/evidence와 parsing 전 Raw snapshot을 연결하고 feed parse로 진행 | HTTP 성공만으로 feed·entry 성공 처리 |
| `304` | SPK-01에서 승인한 conditional contract와 validator lineage로 별도 결과 보존 | 유효 빈 feed·정상 신규 후보 0건 |
| 4xx·5xx | 실제 status와 안전한 response evidence 기반 상위 오류 분류 | Entry 입력 오류·RSS 미존재·정상 0건 |
| Network·timeout·응답 미수신 | 확인 가능한 transport evidence와 원인 불명확 여부 보존 | 원격 처리·응답 부재를 임의 확정하거나 blind retry |
| 잘림·encoding/XML 구조 오류 | 수신 Raw evidence와 feed-level parsing failure | 부분 entry를 정상 candidate로 처리 |
| 구조적으로 유효한 빈 feed | Raw snapshot·feed success·parsed entry 0건 | WBS-16의 최종 `normal_no_new_candidates` 선행 생성 |

[FACT] 각 fetch는 WBS-13의 current Prepare work·attempt와 WBS-11의 DB trust·pause·configuration·contract 조건을 외부 invocation 직전에 재대조합니다. Polling·timeout·conditional request·retry/backoff는 SPK-01에서 승인된 범위만 사용하며, provider와 무관하다는 이유로 unknown/default 설정이나 무제한 재요청을 사용하지 않습니다.

[INFERENCE] Conditional validator는 exact endpoint와 적용 contract/configuration lineage에 연결해야 하며 다른 endpoint나 확인되지 않은 stale validator를 재사용하지 않습니다. `304`의 downstream 처리·기존 snapshot 참조 방식이 SPK-01에서 닫히지 않으면 WBS-14 구현을 차단하고 정상 empty/no-new로 대체하지 않습니다.

[FACT] HTTP response body는 parsing 또는 text normalization 전에 승인된 Raw representation으로 보존합니다. Raw evidence의 byte count·digest, 수신 완전성, content type·encoding과 안전한 HTTP reference를 parsing output과 분리해 원래 입력과 parser 결과를 대조할 수 있어야 합니다. 응답을 받지 못한 attempt에는 존재하지 않는 Raw snapshot을 만들지 않습니다.

[UNKNOWN] 최대 허용 response 크기, 압축 해제·byte 보존 범위, truncated body 표현과 Raw retention의 실제 물리 형식은 SPK-01·WBS-04 final closure에서 결정해야 합니다. 크기 제한을 넘었다는 이유로 수신 일부를 완전한 Raw snapshot처럼 기록하거나 조용히 entry를 잘라 처리하지 않습니다.

[FACT] XML parser는 external entity·DTD 기반 file/network resource resolution과 parser-triggered outbound를 허용하지 않습니다. Feed 전체가 구조적으로 parse되지 않으면 entry 단위 결과를 만들지 않고 feed-level failure로 남기며, unsafe XML·namespace·encoding·잘린 문서 fixture를 명시적으로 검증합니다.

| Parsed entry 대표 결과 | 의미 | Candidate count 영향 |
| --- | --- | --- |
| Unique new candidate | 필수 입력이 유효하고 exact link article의 최초 admission이 현재 실제 batch에서 성공 | 신규 후보 +1 |
| Existing/re-observed/duplicate | 동일 exact link article 또는 이미 admission된 article에 연결 | 신규 후보 +0, observation 보존 |
| Candidate-impossible input error | 후보 생성 필수 입력이 누락·빈값·형식 오류·검증 불가 | 신규 후보 +0, 입력 제약 +1 |

[FACT] Parsing된 entry 수는 세 대표 결과 수의 합계와 일치해야 합니다. 하나의 entry에 여러 validation detail이 있어도 대표 결과는 하나이며, 상세 오류를 잃지 않습니다. 대표 오류 우선순위·필수/선택 field 경계가 승인되지 않으면 구현자가 임의로 정상·신규 또는 제외를 선택하지 않습니다.

[FACT] Parsing 가능하고 후보 생성 필수 입력을 만족한 News·Ask·Show 및 source type 미상 entry는 후보 자격을 유지합니다. Source type·추정 type, title prefix와 관심 keyword의 존재·부재만으로 observation이나 candidate를 제거하지 않으며 최신성·시간 검증·AI 처리·selection은 WBS-15~16에서 별도로 수행합니다.

[FACT] `article` identity는 Raw RSS `link` 원값의 exact equality만 사용합니다. Atom `id`, title/content, trim·대소문자 변경·percent decode·fragment/query 변경·redirect target·URL normalization 또는 유사성 비교를 identity로 사용하지 않습니다. Link 문법상 허용·거부 범위는 SPK-01과 승인 input contract가 닫아야 하며 외부 HTTP dereference로 유효성을 판정하지 않습니다.

[FACT] `article`은 exact link identity와 최초 observation reference만 소유하고 title·content·published·updated 원값은 각 `rss_observation`에 남깁니다. 이후 snapshot에서 같은 link의 field·순서가 바뀌어도 새 observation으로 기록하며 기존 article·최초 admission·과거 처리·selection·delivery를 변경하지 않습니다. 과거 link가 현재 snapshot에 없으면 미관찰로만 남기고 삭제·원천 누락·retention purge로 추정하지 않습니다.

[UNKNOWN] 같은 snapshot에 동일 link가 여러 번 존재하면서 후보 필수 field가 상충할 때 최초 admission observation을 선택하는 deterministic rule과 대표 결과가 확정되지 않았습니다. WBS-09 전에 실제 fixture와 데이터 계약으로 닫고, feed 순서에 따라 canonical history가 비결정적으로 달라지는 구현을 허용하지 않습니다.

[FACT] 유효 observation은 exact link로 article을 찾거나 만들고 같은 DB transaction에서 아직 MVP-A 신규 후보 admission이 없는 article만 현재 실제 scheduled batch의 `batch_candidate`로 연결합니다. Candidate는 source article·admission observation·scheduled batch를 참조하고 RSS 값·AI 결과를 복제하지 않습니다.

[FACT] 동시·중첩 수집에서 하나의 exact link admission만 성공하고 경쟁에서 진 observation은 기존 article 재관찰로 보존합니다. 이미 admission된 article은 AI 대기·최신성 terminal·정상 미선정·처리 지연·Discord 수락/미수락·recovery 상태와 관계없이 후속 batch의 신규 후보가 되지 않습니다. Feed 실패·entry 입력 오류·미실행 과거 slot은 candidate를 만들지 않지만 이후 실제 유효 수집이 처음 admission하는 것은 허용합니다.

[FACT] 목표 전달 시각 전에 시작된 실제 Prepare가 목표 시각 뒤에도 내부 처리를 계속하는 경우 원래 batch의 source를 유지할 수 있지만, 목표 시각 뒤 처음 발견한 과거 slot에는 WBS-13 계약에 따라 RSS fetch·article·candidate pipeline을 시작하지 않습니다.

| 검증군 | 최소 검증 내용 |
| --- | --- |
| HTTP contract | 공식/비공식 target, redirect, 2xx·304·4xx·5xx·network·timeout·응답 미수신, conditional lineage |
| Raw fidelity | 정상·빈·잘린·encoding 오류·큰 body의 수신 byte/digest와 parsing input 대조 |
| Parser security | DTD·external entity·file/network reference, malformed XML, namespace·encoding과 parser outbound 0건 |
| Entry accounting | 0·1·100·계약 초과 entry, 정상·중복·복수 오류 혼합과 parsed=대표 결과 합계 |
| Eligibility | News·Ask·Show·unknown type, prefix·keyword 유무와 조기 제외 0건 |
| Identity | 같은 link/id, link만 같음, id만 같음, field·순서 변경과 normalization 미사용 |
| Admission concurrency | Same snapshot duplicate, 중첩 fetch, 두 worker·두 batch 경쟁에서 article/admission 하나와 observation 보존 |
| Failure boundary | Feed failure·entry error·valid empty·0 new·미실행 slot과 정상 신규 0건 오판 0건 |

[INFERENCE] WBS-14 rollback은 HTTP adapter, Raw/parser, observation/accounting과 candidate admission integration을 독립 검토 slice로 유지합니다. 이미 보존한 fetch·Raw·observation·article·candidate evidence는 rollback 명목으로 삭제·수정하지 않으며, 계약 또는 parser/admission 결함이 발견되면 새 RSS invocation/admission을 fail-closed로 차단하고 검증된 code/configuration 재활성화에 별도 승인을 요구합니다.

[INFERENCE] WBS-14 완료 기준은 공식 endpoint 외 요청·parser-triggered network/file access·Raw 손실·parsed entry 조용한 제외·feed failure/304/input error의 정상 0건 오판·URL normalization identity·article/candidate 중복·과거 admission/history 소급 변경이 각각 0건이고, 정상·빈·혼합 오류·재관찰·동시 admission evidence가 Requirement/Decision과 연결되는 것입니다.

[UNKNOWN] 실제 polling·timeout·retry/backoff, redirect, conditional validator와 `304` 처리, HTTP client/parser library, response size·encoding/압축·Raw physical format, 필수/선택 field·복수 오류 우선순위, link 문법, 동일 link 상충 entry 선택과 transaction/lock/isolation은 SPK-01·WBS-04·05·09에서 승인돼야 합니다. 이 계획 승인은 dependency·code·SQL·DB·실제 RSS 요청 또는 해당 값을 승인한 것이 아닙니다.

### WBS-15 — 무료 AI·analysis boundary 구현 상세 checkpoint

[FACT] 관련 Requirement는 FR-006~010·013~014, NFR-COST-001, NFR-DQ-001~002, NFR-REL-001~002, NFR-PERF-001, NFR-LAT-002, NFR-OBS-001~002, NFR-SEC-001, NFR-MNT-001, DR-006~007·014, EXT-AI-001~007, VR-004·008·011·013·018~019이고 관련 Decision은 AD-01~04·08·10·13·15~18, DDI-02·05~06·09, MIN-03~06·08입니다. 외부 선행은 SPK-06A→SPK-02→SPK-06B의 실제 pass와 exact provider/model/configuration에 대한 사용자 승인이고 구현 선행은 WBS-06.A~E actual contract, WBS-09 실제 `READY`, WBS-11~14 및 사용자가 승인한 WBS-15 branch/test/rollback 범위입니다.

[FACT] WBS-15는 미래 Workflow 11의 단일 무료 AI implementation Task 계획입니다. 현재 Workflow 9에서는 provider/account/project/model을 선택·변경하거나 SDK/dependency·prompt·code·SQL·DB·실제 AI request를 생성·실행하지 않으며 계획 승인만으로 Gemini 또는 다른 후보를 activation한 것으로 보지 않습니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-15.A | Candidate analysis eligibility | Source scheduled delivery instant와 parsed `published` 기반 13시간 freshness·시간 validation을 AI 호출 전에 고정하고 비대상 terminal을 분리 |
| WBS-15.B | Provider adapter activation | 승인된 단일 provider/model/project/configuration, free-only·capability·data-use와 hidden retry/routing/tool 경계 |
| WBS-15.C | Evidence-bounded request | RSS field allowlist·provenance, 승인된 normalization·serialization, instruction/data 분리와 safe manifest/digest |
| WBS-15.D | Prepared·invocation lifecycle | AI attempt 생성, current lease·configuration·contract·cost·credential gate 재검증, invocation-started와 실제 호출 경계 |
| WBS-15.E | Response evidence·validation | Append-only typed response/usage/limit evidence, structural·type·lineage validation과 normal·low-information·invalid 분리 |
| WBS-15.F | Analysis resolution transaction | Candidate unresolved·source attempt·configuration·기존 analysis/final result를 재검증하고 최초 selection-eligible analysis를 원자적으로 고정 |
| WBS-15.G | Error·retry·budget/deadline | Source-confirmed 원인·external certainty, new-attempt retry, candidate/batch/day call·token budget와 처리 마감 |
| WBS-15.H | Late evidence·fault·handoff | Exact correlation, late usage 보존·결과 적용/비적용, candidate completion과 WBS-16·20·23~25 인계 |

[FACT] 현재 기사 freshness는 source scheduled batch의 예정 Discord 전달 시각과 candidate admission observation의 비교 가능한 `published` instant로 `0 ≤ scheduled_delivery_at - published ≤ 13시간`을 판정하며 정확히 13시간을 포함합니다. 이 결과와 reason은 candidate 처리 축에 한 번 고정하고 예정 시각·RSS 시각을 analysis에 복사하지 않습니다.

| Candidate 시간 결과 | AI 호출 | 후속 의미 |
| --- | --- | --- |
| 0~13시간 포함 | 승인 AI 처리 대상으로 진행 가능 | 다른 gate와 analysis 필요 조건을 계속 확인 |
| 13시간 초과 | 호출 금지 | 명시적 freshness terminal, AI 실패 아님 |
| `published` 누락·오류·비교 불가 | 호출 금지 | 시간 검증 불가 terminal, provider 오류 아님 |
| 미래 시각으로 음수 차이 | 호출 금지 | 승인 time-validation reason, 임의 보정 금지 |

[FACT] WBS-16은 WBS-15에서 고정한 freshness·시간 결과와 source reference를 소비하고 finalization 현재 시각으로 재계산하지 않습니다. 목표 전달 시각 뒤 AI 처리가 완료됐다는 사실도 원래 freshness 결과를 바꾸지 않으며 full selection의 processing-delayed handoff 여부만 후속에서 결정합니다.

[FACT] 최종 provider·model·SDK는 SPK-02의 official/sandbox evidence와 SPK-06의 사전·사후 비용 coverage, exact 사용자 승인 뒤 하나만 구현합니다. Gemini 무료 API는 우선 검증 후보일 뿐 기본값이 아니며 rejected·blocked·inconclusive이면 다른 provider를 자동 선택하거나 동시에 구현하지 않습니다.

| Provider 실행 경계 | 필수 evidence | 금지 동작 |
| --- | --- | --- |
| Exact target | Provider/service·account/project·resolved model·API operation·configuration | `latest`/자동 routing을 승인 model로 추정 |
| Free-only | 청구 불가능 설정·plan/quota·적용 cost evidence와 호출 직전 gate | 유료 endpoint·quota 초과 유료 처리·다른 billing path |
| Capability | Browsing·grounding·search·tool·URL fetch 비활성/차단 확인 | RSS 밖 source 자동 보완 |
| Physical invocation | 저장 attempt와 실제 provider request 수·correlation 대조 | SDK hidden retry·fallback·hedged request |
| Data use | 승인 RSS payload의 적용 data-use contract와 재검증 조건 | 조건 불명 상태의 전송 |

[INFERENCE] SDK가 retry·model routing·telemetry 또는 추가 network call을 내부적으로 수행할 수 있으면 해당 기능을 명시적으로 차단하거나 각 실제 inference invocation을 별도 durable attempt와 evidence로 증명할 수 있어야 합니다. 그렇지 않으면 SDK를 편의상 사용하지 않으며 실제 SDK/HTTP client 선택은 WBS-09 blocker로 둡니다.

[FACT] AI 사실 입력 allowlist는 해당 source `rss_observation`의 `title`과 승인 precedence로 선택한 `content` 또는 `description`입니다. GeekNews topic link·Atom id·author·published/updated/observed 시각·source type, batch/work/attempt identity, Discord·사용자·feedback, 다른 저장 data와 Secret·credential·민감 운영값은 request payload에 포함하지 않습니다.

[INFERENCE] Request builder는 source observation/configuration reference, 선택 field provenance, input-normalization·serialization·prompt·policy·output-contract version과 안전한 manifest/digest를 연결합니다. 전체 RSS text·prompt·request를 새 canonical blob으로 중복 저장하지 않으며 digest는 원본 source나 version owner를 대체하지 않습니다.

[FACT] Raw RSS text는 instruction이 아닌 untrusted data로 구조적으로 구획합니다. RSS 안의 prompt injection·role/tool syntax·외부 URL 방문·Secret 요청·schema 변경 지시를 따르지 않으며 browsing·grounding·tool capability가 비활성임을 실제 request/configuration evidence로 검증합니다.

[FACT] Content/description precedence, markup·entity·Unicode·공백 처리와 context/token limit 처리는 승인된 결정적 단계만 사용합니다. Provider limit을 넘는 입력을 조용히 자르지 않고 full-input, 승인된 근거 보존 제한 또는 처리 불가 결과를 구분하며 제한된 입력을 전체 RSS 근거처럼 표현하거나 외부 지식으로 보완하지 않습니다.

[FACT] AI 호출 전 `ai_analysis_attempt`를 `prepared`로 commit하고 source candidate·article·observation, source Prepare configuration, provider/model, input/output contract와 비용 evidence reference를 연결합니다. 별도 analysis intent record를 만들지 않으며 새 attempt가 기존 attempt를 덮어쓰지 않습니다.

| Attempt 단계 | 허용 동작 | 금지 동작 |
| --- | --- | --- |
| Prepared, invocation 미시작이 DB로 확인됨 | Current lease·fence와 전체 gate 재검증 뒤 같은 attempt 진행 | 다른 configuration/provider로 변경, gate 없이 호출 |
| Invocation-start transition | Exact attempt·lease·configuration·contract·cost·credential을 같은 DB commit에서 재검증 | Stale worker 호출, DB commit 전 요청 |
| Invocation started | 실제 request와 correlation/evidence 수집 | Prepared로 되돌림, timeout만으로 자동 retry |
| Terminal retryable failure | 승인 근거·budget·deadline 재검증 뒤 새 prepared attempt | 기존 attempt 수정·재사용 |
| External effect uncertain | Late evidence와 수동/정책 owner를 기다림 | 성공·실패 추정, 새 호출 자동 시작 |

[FACT] Outbound gate의 `allow`는 요청 성공이나 analysis 완료를 뜻하지 않습니다. Invocation-started commit 뒤 process가 중단돼 실제 network 시작 여부가 불명확한 crash gap도 안전하다고 추정하지 않고 source attempt를 불명확 상태로 유지합니다.

| Output class | Canonical 결과 | 금지 처리 |
| --- | --- | --- |
| Normal analysis | 검증된 `article_analysis`와 analysis별 keyword·판단·최소 RSS 근거 lineage | 누락 field 기본값·RSS 밖 사실 보완 |
| Low information | 명시적 정보 제한과 검증된 범위의 `article_analysis` | Provider 오류·refusal·빈 출력을 저정보로 coercion |
| Parse/schema/type failure | Attempt validation failure·typed evidence | 부분 field 추출·자동 정상화로 analysis 생성 |
| Grounding/lineage failure | Attempt failure와 근거 mismatch | 구조 성공만으로 canonical analysis 생성 |
| Provider/cost/security/uncertain | Attempt·candidate 상태·영향 수량 | Normal/low-information·정상 미선정으로 변환 |

[INFERENCE] Machine validator는 schema·type·필수값·허용 범위·source lineage·금지 URL/metadata와 명백한 근거 불일치를 검증하지만 구조 통과만으로 환각 0건이나 품질 목표 달성을 선언하지 않습니다. RSS 충실도·중대한 근거 밖 사실·중요도·관심·홍보성 품질은 WBS-08·22·30의 승인 human/evaluation evidence로 별도 판정합니다.

[FACT] 정상 또는 저정보 결과가 validation을 통과하면 current candidate가 unresolved이고 source attempt·configuration이 일치하며 final selection result가 없는지 같은 transaction에서 다시 확인합니다. 최초로 candidate를 analysis-resolved로 고정한 결과만 selection-eligible `article_analysis`가 되며 경쟁·중복 response는 새 canonical analysis를 만들지 않습니다.

[FACT] `article_analysis`와 keyword child는 canonical 분석 결과 owner이고 provider response evidence가 제목·요약·keyword·판단을 다시 복제하지 않습니다. Mutable current-analysis pointer나 최신 analysis 교체 규칙을 만들지 않으며 향후 승인 재분석도 MVP-A 원래 selection·delivery를 소급 변경하지 않습니다.

| Retry 판단 축 | 필수 조건 |
| --- | --- |
| 원인·confidence | 실제 provider response/contract 또는 source event에 근거한 cause; 불명확하면 `unknown` |
| External certainty | 호출 미시작, 명확한 terminal failure 또는 uncertain을 분리 |
| Retry eligibility | 실제 계약상 retryable terminal 근거; 오류 이름·HTTP family만으로 추정 금지 |
| Current authority | Candidate unresolved, final result 없음, current lease/fence와 configuration/gate 유효 |
| Budget | Candidate·batch·Asia/Seoul day call/token 한도와 free quota·cost evidence |
| Timing | Retry-after/reset, backoff·jitter와 승인 내부 처리 마감 전 남은 시간 |

[FACT] Retry는 모든 조건을 만족하는 명확한 terminal·retryable failure에서만 새 prepared attempt로 생성하며 provider·model·credential·project·prompt·policy를 자동 변경하지 않습니다. Quota, rate limit, 인증/설정, safety/policy refusal, timeout/no response, server, schema/grounding failure와 unknown을 source evidence에 따라 구분하고 각각을 같은 retry 기본값으로 취급하지 않습니다.

[FACT] 내부 처리 마감 뒤 새 retry는 시작하지 않지만 마감 경과 자체를 quota·영구 provider 오류로 바꾸지 않습니다. Candidate별 시도 이력·대표 미처리 reason과 batch completion 가능성을 분리하며, WBS-15는 candidate completion/failure-notice 자격을 제공하고 WBS-16만 final result·notice를 원자적으로 고정합니다.

[FACT] Late response·usage·limit evidence는 exact source attempt와 provider correlation이 확인될 때 append-only·idempotent하게 보존합니다. Late usage는 결과 적용 여부와 무관하게 비용 evidence에서 제외하지 않습니다. Candidate가 아직 unresolved이고 final result가 없으며 동일 source/configuration/contract validation을 통과할 때만 분석 적용을 검토하고, 이미 canonical analysis 또는 final result가 있으면 evidence와 비적용 사유만 남깁니다.

| 검증군 | 최소 검증 내용 |
| --- | --- |
| Freshness/time | 0·정확히 13시간·13시간 초과·누락·오류·미래·offset과 AI invocation 수 |
| Payload/security | 허용 title/text, link/id/time/source/batch/Discord/user/Secret canary, prompt injection·tool/grounding |
| Provider boundary | Exact/alias model, free/paid path, changed account/project/configuration, SDK hidden retry/routing |
| Attempt/fault | Prepared 전후·invocation-start commit 전후 중단, stale token, timeout·응답 유실과 request 수 |
| Output | Normal·low-information·빈/partial/wrong type·schema·근거 mismatch·refusal과 analysis 수 |
| Concurrency | 두 valid response·late response·retry 경쟁에서 candidate별 selection-eligible analysis 최대 하나 |
| Retry/budget | Quota·429·auth·policy·5xx·unknown, retry-after/reset·deadline·call/token budget와 유료 fallback 0건 |
| Late evidence | Unresolved/resolved/finalized candidate의 exact·duplicate·conflicting response/usage 적용·비적용 |

[INFERENCE] WBS-15 rollback은 freshness eligibility, provider/request adapter, attempt/evidence, validator/analysis resolution과 retry/late handler를 독립 slice로 유지합니다. 이미 보존된 candidate result·attempt·evidence·analysis를 rollback 명목으로 삭제·수정하지 않고 contract/cost/validator 결함이 발견되면 새 AI invocation을 fail-closed로 차단하며 과거 analysis·selection을 새 version으로 소급 교체하지 않습니다.

[INFERENCE] WBS-15 완료 기준은 freshness 비대상 AI 호출, 승인 provider/free path 밖 invocation, hidden retry/routing/tool, 금지 payload·Secret 전송, 조용한 truncation, invalid/refusal의 analysis coercion, duplicate selection-eligible analysis, stale invocation/write, uncertain 자동 retry, paid/provider fallback, late result 소급 적용과 usage 누락이 각각 0건이고 candidate별 정상·저정보·명시적 미처리 lineage가 WBS-16 입력으로 연결되는 것입니다.

[UNKNOWN] 최종 provider/service/account/project/model/SDK, 강제 과금 차단, quota/rate/reset·data-use·structured output·error/correlation, content/description precedence, normalization/serialization·prompt·schema·validator, context/token limit, cause mapping, candidate/batch/day budget, retry/backoff/jitter/deadline과 human quality rubric은 SPK-02·06, WBS-04·06·09에서 승인돼야 합니다. 이 계획 승인은 provider 선택·account/configuration 변경·SDK 설치·code·SQL·DB·실제 AI request 또는 해당 값을 승인한 것이 아닙니다.

### WBS-16 — 선정·finalization 구현 상세 checkpoint

[FACT] 관련 Requirement는 FR-005·009~014, NFR-DQ-002, NFR-REL-001~002, NFR-PERF-001, NFR-LAT-002, NFR-OBS-002, DR-007~008, EXT-AI-007, VR-016~019이고 관련 Decision은 AD-08·17~20, DDI-02·05·09, MIN-08입니다. 선행 조건은 WBS-05.E, WBS-06.E~F의 actual contract와 사용자 승인 selection policy, WBS-09 실제 `READY`, WBS-13~15 및 사용자가 승인한 WBS-16 branch/test/rollback 범위입니다.

[FACT] WBS-16은 미래 Workflow 11의 selection/finalization implementation Task 계획입니다. 현재 Workflow 9에서는 importance·interest·promotional score·threshold·tie-break 값을 확정하거나 code·SQL·DB·실제 selection·delivery work·Discord 호출을 생성하지 않으며 계획 승인만으로 미정 정책을 승인한 것으로 보지 않습니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-16.A | Candidate completion reconciliation | 같은 source batch·configuration·판정 시점의 정상·저정보·freshness/time terminal·retry 대기·불가능·입력 결과와 finalization eligibility |
| WBS-16.B | Selection input set | Source batch를 최초로 해결한 selection-eligible analysis와 candidate reference의 배타적 집합·version lineage |
| WBS-16.C | Promotional exclusion | 충분한 RSS 근거·승인 policy 기반 제외와 애매·불가 후보의 선정 가능성 유지 |
| WBS-16.D | Importance/interest ranking | 독립 판단의 승인 조합, 판단 불가와 stable total order·최대 10개 적용 |
| WBS-16.E | Candidate decision·summary | Selected·promotional-excluded·limit-not-selected와 source-derived count invariant·reference-only item |
| WBS-16.F | Immutable result taxonomy | Article list·selection-summary-no-articles·clean-zero·partial/total processing failure notice 조건 |
| WBS-16.G | Atomic finalization | Current Prepare lease/fence·configuration·input completion·기존 result를 재검증하고 result·Prepare completion을 원자 commit |
| WBS-16.H | Durable handoff·fault·rollback | Scheduled-current·processing-delayed·notice·no-message eligibility, lost-handoff discovery와 immutable replay |

[FACT] WBS-16은 WBS-14의 feed·entry 결과와 WBS-15의 candidate 처리 결과를 같은 source batch·configuration·판정 기준으로 대조합니다. 개별 AI attempt 실패를 candidate 또는 batch terminal로 즉시 승격하지 않으며 안전한 retry·processing·원인 미확정 candidate가 하나라도 있으면 final result·failure notice·article list를 만들지 않습니다.

| Candidate 대표 상태 | Finalization completion 기여 | Selection input |
| --- | --- | --- |
| Normal resolved | 처리 완료 | 최초 selection-eligible analysis 포함 |
| Low-information resolved | 처리 완료, 실패가 아님 | 최초 selection-eligible analysis 포함 |
| Freshness exceeded | 명시적 비-AI terminal | 제외, `candidate_selection` 생성 금지 |
| Time validation unavailable | 명시적 비-AI terminal | 제외, `candidate_selection` 생성 금지 |
| Safe retry waiting·processing | 미완료 | Finalization 전체 금지 |
| Analysis impossible | 승인 근거가 있는 처리 불가능 | Failure-notice eligibility에 포함 |
| Unknown/inconsistent | 완료 판단 불가 | Fail-closed, 정상·실패 추정 금지 |

[INFERENCE] Candidate completion reconciliation은 finalization 전 검사용 derived view/query이며 승인 disposition에 없는 새로운 canonical snapshot relation을 기본값으로 만들지 않습니다. 사전 계산 결과를 그대로 신뢰하지 않고 finalization transaction에서 canonical source와 count를 다시 대조합니다.

[FACT] 선정 input은 해당 source batch candidate를 처음 analysis-resolved로 고정한 정상 또는 저정보 `article_analysis` reference로 제한합니다. Late·중복·다른 batch·실패/invalid/uncertain attempt, candidate 생성 불가능 입력 오류, 기존 observation과 freshness/time terminal을 selection pool에 넣거나 최하위·홍보성 제외·최대 제한 미선정으로 변환하지 않습니다.

| Selection policy 축 | 필수 승인 내용 | 금지 기본값 |
| --- | --- | --- |
| Policy/configuration version | Batch에 binding된 판단·선정 기준과 적용 시점 | 현재 활성 설정으로 과거 batch 재평가 |
| Promotional exclusion | 충분한 RSS 근거와 exclusion threshold·판단 불가 처리 | 회사/제품명·type·prefix·keyword 단독 제외 |
| Importance | 전체 IT 중요도의 label/score와 정렬 기여·불가 처리 | 판단 불가를 낮음으로 coercion |
| Interest relevance | 사용자 관심 적합성의 별도 label/score·기여 | 관심 낮음·주제 밖만으로 탈락 |
| Combination/order | Importance 중심 조합·가중·정렬 방향 | 구현자가 임의 수식 선택 |
| Stable tie-break | 모든 동률을 해소하는 승인 total-order key | Feed·DB 반환 순서·query plan·현재 시각 |
| Maximum | Promotional 제외 뒤 같은 pool에서 최대 10개 | 저정보 별도 상한·recovery와 합산 |

[FACT] 충분한 근거로 홍보성이 확인된 후보만 `promotional_excluded`로 설명합니다. 애매·판단 불가인 후보는 선정 가능성을 유지하며, 관심 적합성이 낮거나 관심 주제 밖이라도 전체 IT 중요도가 높으면 선정 가능성을 유지합니다. 중요도·관심·홍보성 원 판단과 최소 RSS 근거를 하나의 불명확한 종합 label로 덮어쓰지 않습니다.

[INFERENCE] 같은 batch binding과 canonical input에서 재실행·feed 순서·DB plan에 관계없이 동일한 후보 결정·순위·표시 순서가 나와야 합니다. Stable total-order가 승인되지 않으면 selection code를 작성하지 않고 WBS-09 blocker로 유지합니다.

| Finalization 조건 | Immutable 결과 | Candidate selection / batch item |
| --- | --- | --- |
| 선정 후보 1건 이상 | `full_selection / article_list` | 분석 완료 candidate마다 배타적 결정, selected에만 최대 10개 item |
| 신규 후보 또는 입력 오류가 있으나 선정 0건 | `full_selection / selection_summary_no_articles` | 분석 완료 candidate는 promotional/limit decision, freshness/time은 candidate reason |
| RSS·입력·처리 정상, 신규·입력 오류·미처리·실패 모두 0 | `full_selection / normal_no_new_candidates` | 0건, source current message 없음 |
| 전체 선정 불가능이 승인 근거로 확정 | `processing_failure_notice` | Candidate selection·batch item 0건, partial article list 금지 |
| 처리·safe retry·unknown이 남음 | Final result 없음 | 0건, 계속 보류 |

[FACT] `input_constrained_result`, 저정보, 후보 생성 불가능 입력 오류, freshness/time terminal, promotional 제외와 maximum-limit 미선정은 독립 completion이 아니라 immutable summary의 qualifier·수량·사유입니다. 입력 오류가 있거나 신규 candidate가 있었는데 선정 0건이면 `normal_no_new_candidates`가 아니라 `selection_summary_no_articles`입니다.

[FACT] Processing failure notice의 partial/total은 selected count가 아니라 검증된 normal·low-information analysis 존재 여부로 구분합니다. 완료 analysis가 하나 이상이면 partial, 하나도 없으면 total이며 두 경우 모두 article list·candidate selection·batch item을 만들지 않습니다. 아직 retry 가능한 candidate가 있으면 failure notice 자체를 만들지 않습니다.

[UNKNOWN] Feed 전체 실패·collection completion 불가와 AI 외 원인이 최종 notice의 어떤 physical reason/subtype 및 partial/total 표시와 결합되는지는 WBS-06.E actual contract에서 닫아야 합니다. 어떤 경우에도 collection failure를 정상 신규 0건이나 AI quota 원인으로 바꾸지 않습니다.

[INFERENCE] `full_selection`은 같은 source batch·configuration·판정 시점에서 최소 다음 count invariant를 만족해야 합니다.

```text
selection 대상 분석 완료 candidate 수
  = selected
  + promotional_excluded
  + limit_not_selected

batch_item 수 = selected 수 ≤ 10
```

[FACT] Result summary 수량은 candidate·analysis·selection·input/failure canonical source에서 재계산·대조하고 별도 mutable 누적 counter를 정본으로 사용하지 않습니다. `batch_item`은 selected `candidate_selection`·`article_analysis`·표시 순서를 reference하며 title·summary·keyword·link·policy version을 복제하지 않습니다.

[FACT] WBS-15가 source scheduled delivery instant 기준으로 고정한 freshness/time 결과를 소비합니다. Finalization wall clock, 목표 시각 경과, late AI evidence 또는 새 policy version으로 이 결과를 다시 계산하지 않습니다. 목표 시각 뒤 full selection 완료는 처리 실패가 아니라 processing-delayed delivery handoff 분류 조건입니다.

[FACT] Finalization은 별도 logical work가 아니라 source Prepare work의 마지막 내부 단계입니다. Current Prepare lease·fencing token을 가진 execution만 짧은 transaction에서 RSS/input completion, candidate representative state·count, batch configuration binding, selection input과 기존 final result 부재를 다시 확인합니다.

[FACT] 신규 결과이면 `selection_result`, immutable summary, 필요한 `candidate_selection`·`batch_item`, Prepare work 완료와 attempt 종료를 같은 commit에서 고정합니다. 기존 final result가 있으면 저장 결과를 재사용하고 selection을 재계산하거나 decision/item을 추가하지 않습니다.

| Fault 지점 | 요구 결과 | 금지 결과 |
| --- | --- | --- |
| Finalization commit 전 중단 | Final result·decision·item·Prepare 완료 모두 없음 | Partial output |
| Commit acknowledgement 유실 | 새 transaction으로 canonical result 재조회 | 동일 결과 재생성 |
| Commit 뒤 process 중단 | 저장 immutable result 재사용·handoff 재발견 | 재선정·item 추가 |
| 동시 finalization | 정확히 하나의 result commit, loser는 기존 결과 읽음 | 복수 result·summary |
| Lease α 만료 뒤 β 교체 | α의 result/write 0건 | Stale finalization |
| Finalization 뒤 late analysis | Evidence·비적용 reason 보존 | Result·순위·item 변경 |

[FACT] Selection transaction은 `delivery_set`, Discord domain attempt·message mapping·acceptance evidence 또는 외부 호출을 생성하지 않습니다. Producer commit 뒤 downstream work admission 전에 중단돼도 application memory나 같은 Pod 생존에 의존하지 않고 committed result에서 동일 logical delivery work를 idempotent하게 재발견해야 합니다.

| Committed result·timing | Downstream eligibility | 분리 조건 |
| --- | --- | --- |
| 목표 시각 전 사용자 표시 필요 full result | Scheduled-current delivery work | Discord attempt는 목표 시각 전 시작 금지 |
| 목표 시각 뒤 사용자 표시 필요 full selection | 원래 batch의 processing-delayed 전용 work | Current·confirmed recovery와 같은 set/segment 혼합 금지 |
| Processing failure notice | Article 없는 failure-notice work | Partial article item 0건 |
| Normal no-new-candidates | Source current no-message | 다른 원래 batch recovery-only 기회 차단·합산 금지 |

[UNKNOWN] Delivery work를 finalization transaction과 함께 등록할지 committed-result post-discovery로 admission할지는 WBS-04.C·05.E·07 actual physical handoff 결정이 필요합니다. 어떤 방식을 승인하더라도 delivery set·Discord attempt·외부 호출을 selection commit에 결합하지 않고 lost-handoff owner와 replay evidence를 가져야 합니다.

| 검증군 | 최소 검증 내용 |
| --- | --- |
| Completion | Normal·low-information·freshness/time terminal·retry waiting·analysis impossible·unknown 조합 |
| Policy | 중요도/관심 경계·판단 불가, promotional 충분/애매, 관심 밖 고중요도 |
| Determinism | Feed/DB 순서 변경, 전체 동률, 재실행과 stable total-order·동일 output |
| Capacity | 0·1·9·10·11·30·100 candidate, selected≤10과 저정보 별도 상한 0건 |
| Result taxonomy | Clean zero, input error only, selected zero, full list, partial/total processing failure |
| Count/reference | Candidate 결정·summary·item 수 대조, 복제 field·orphan reference 0건 |
| Transaction/fault | Commit 전후 중단·ack loss·동시 실행·lease 교체·late analysis와 partial/stale output 0건 |
| Handoff | Pre/post-target result, notice, no-message, process kill과 current/delayed/recovery 혼합 0건 |

[INFERENCE] WBS-16 rollback은 completion/policy, decision/summary, finalization과 handoff integration을 독립 slice로 유지합니다. 이미 commit된 selection result·summary·decision·item을 rollback 명목으로 삭제·수정·재계산하지 않으며 policy/code 결함이 발견되면 새 finalization·delivery를 fail-closed로 차단하고 호환 가능한 code/configuration 재활성화에 별도 승인을 요구합니다.

[INFERENCE] WBS-16 완료 기준은 owner 없는 policy 값, 처리·retry 대기 중 final result, partial failure article list, normal-zero 오판, input/decision/count 누락·중복, selected 10개 초과, 비결정 순서, freshness 재계산, partial/stale/concurrent finalization, mutable result와 lost·duplicate/mixed handoff가 각각 0건이고 모든 결과가 source evidence·policy/configuration version에 연결되는 것입니다.

[UNKNOWN] 실제 importance·interest label/score·combination/weight/order, promotional threshold, 판단 불가·stable tie-break, candidate/result/reason physical code, feed/collection failure notice mapping, transaction isolation·constraint와 delivery-work admission 방식은 WBS-04·05·06·07·09에서 실제 evidence와 사용자 승인으로 닫아야 합니다. 이 계획 승인은 해당 policy 값·code·SQL·DB·실제 selection·delivery/Discord 구현을 승인한 것이 아닙니다.

### WBS-17 — Discord rendering·delivery 구현 상세 checkpoint

[FACT] 관련 Requirement는 FR-012~016, NFR-REL-001~003, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-002, NFR-OBS-001~002, NFR-SEC-001~002, DR-008~009, EXT-DC-001~006, VR-004~005·011~013·016~018이고 관련 Decision은 AD-01~03·06~08·10·13·15~21, DDI-03·05~06·09~10, MIN-01·03·05·08입니다. 외부 선행은 SPK-06A→SPK-03→SPK-06B의 실제 pass와 exact Discord interface/principal/target/configuration에 대한 사용자 승인이고 구현 선행은 WBS-07.A~C actual contract, WBS-09 실제 `READY`, WBS-11~13·16 및 사용자가 승인한 WBS-17 branch/test/rollback 범위입니다.

[FACT] WBS-17은 미래 Workflow 11의 Discord output implementation Task 계획입니다. 현재 Workflow 9에서는 Discord Application/bot/webhook·guild/channel/user·credential/permission을 생성·변경하거나 SDK/dependency·payload·code·SQL·DB·실제 message를 생성·전송하지 않으며 계획 승인만으로 어떤 interface도 activation한 것으로 보지 않습니다.

| ID | 구현 계획 범위 | 완료 evidence·후속 owner |
| --- | --- | --- |
| WBS-17.A | Discord operation activation | 승인 interface·principal·target·permission·credential·cost·acceptance/correlation contract와 변경 재검증 gate |
| WBS-17.B | Delivery set·segment admission | Committed result/recovery source와 current·delayed·recovery·notice·confirmation/offer·no-message 구성·상한 |
| WBS-17.C | Reference-only renderer | Article·analysis·summary source, 필수 표시·안전한 escaping·render failure와 원본 의미 불변 |
| WBS-17.D | Physical mapping·split | Deterministic message plan, disjoint item subset·대표 mapping·physical version/safe payload hash |
| WBS-17.E | Prepared·invocation boundary | Work claim·lease/fence·gate·target timing 재검증, mapping별 durable attempt와 hidden invocation 차단 |
| WBS-17.F | Response·acceptance decision | Positive response+required message ID, error cause와 accepted/not-accepted/uncertain의 독립 판정 |
| WBS-17.G | Partial·late·timing projection | Mapping/item별 partial acceptance, exact late evidence·logical completion과 정시 acceptance 경계 |
| WBS-17.H | Contract·fault·rollback·handoff | Split·timeout·response loss·restart fixture와 WBS-18~20·23~25 integration owner 연결 |

[FACT] WBS-17은 WBS-16에서 commit된 selection result와 WBS-19가 이후 제공할 승인 recovery source를 읽습니다. Selection·analysis·freshness·원래 batch summary를 현재 policy로 재계산하거나 Discord 전송 결과 때문에 변경하지 않습니다. Confirmation·offer·resend를 render하고 전송할 수 있지만 이를 권한화하는 recovery case/event는 WBS-19가 소유합니다.

| Segment/result | Article 상한 | 허용 구성·금지 경계 |
| --- | ---: | --- |
| `scheduled_current` | 최대 10 | 목표 시각 전 invocation 금지, source result 재계산 금지 |
| `confirmed_non_acceptance_recovery` | 최대 10 | 저장된 원래 selection result의 실제 미수락 item subset만 사용 |
| Scheduled current + recovery | Current 10 + recovery 10, 총 최대 20 | 두 source summary·candidate 수량을 합친 새 결과 생성 금지 |
| Recovery-only | 최대 10 | Current item이 없어도 가능하나 source clean-zero를 recovery source로 변경 금지 |
| `processing_delayed_full_result` | 최대 10 | 원래 batch 전용 set, current·confirmed recovery와 동일 set/segment 혼합 금지 |
| `failure_notice` | 0 | Article item·article feedback·batch review·recovery 생성 금지 |
| `receipt_confirmation` | 0 | 원래 server acceptance·사용자 receipt·recovery 성공 추정 금지 |
| Recovery offer mapping | 0 | WBS-19의 exact no-response/event authorization 없이 생성·재첨부 금지 |
| `normal_no_new_candidates` | 0 | Source current message 생성 금지, 별도 recovery-only 기회는 차단하지 않음 |

[FACT] `selection_summary_no_articles`와 사용자 표시가 필요한 input/failure summary는 clean `normal_no_new_candidates`가 아닙니다. 승인된 원인별 수량·경고를 article item 없는 physical output으로 render할 수 있지만 article-bearing feedback·batch review mapping을 만들지 않습니다.

[FACT] Rendering은 `batch_item`·`candidate_selection`·selection-eligible `article_analysis`·source article과 immutable result summary를 reference합니다. Article identity·순서, 제목·요약·정보 제한, keyword, exact topic link와 source별 수량·reason을 delivery용 canonical 복사본으로 만들지 않으며 failure·format 보정 때문에 source 의미를 변경하지 않습니다.

[INFERENCE] Discord Markdown·mention·link·emoji·component escaping과 content/embed/field/component/message 제한은 SPK-03에서 검증한 actual contract/version을 적용합니다. Untrusted RSS/AI text가 mention·command·link 또는 layout control로 해석되는 것을 막되 의미를 조용히 삭제·변경하지 않고, 승인 layout으로 안전하게 render할 수 없으면 invocation 전 typed rendering failure와 영향 item을 보존합니다.

[FACT] Payload 제한을 맞추기 위해 필수 기사, 정보 충분성에 따른 요약·제한 문구, keyword, topic link, 원래 summary·원인별 수량을 조용히 삭제·축약하거나 selection을 다시 실행하지 않습니다. Optional field와 deterministic fallback layout은 실제 rendering contract에 명시돼야 하며 구현자가 임의로 중요 정보를 떨어뜨리지 않습니다.

[INFERENCE] Physical split은 source item order와 승인 Discord limit/layout version에서 deterministic해야 합니다. Feed/DB 반환 순서·worker·재실행에 따라 mapping 수·순서·payload hash가 바뀌지 않고 한 segment의 동일 item을 둘 이상의 article-bearing physical mapping에 연결하지 않습니다.

```text
article-bearing physical mapping별 item subset의 합집합
  = 해당 segment가 실제 전달하려는 item subset

서로 다른 article-bearing mapping의 item subset 교집합
  = 공집합
```

[FACT] Article-bearing delivery set에는 feedback·recipient receipt 범위를 위한 batch 대표 mapping을 최대 하나 둡니다. 대표 mapping은 실제 delivery set의 article item scope를 한 번 reference하고 item별 association을 복제하지 않습니다. Failure notice·receipt confirmation·item 없는 summary에는 article batch-review mapping을 만들지 않습니다.

[FACT] Physical output/configuration version과 safe payload hash는 source selection output contract와 분리합니다. Hash/manifest에는 credential·Authorization·webhook URL·cookie·interaction secret 또는 불필요한 전체 원문을 넣지 않으며 실제 serialization·algorithm·field allowlist는 승인 physical contract를 사용합니다.

[FACT] 최종 Discord interface·principal·credential·permission·guild/channel/recipient, positive response·message ID와 비용 조건은 SPK-03·06 evidence 및 사용자 승인 뒤 하나의 operation 경로로 활성화합니다. 다른 interface·credential·target/channel로 자동 fallback하지 않으며 delivery credential로 Gateway/REST/관리 권한을 편의상 확대하지 않습니다.

[INFERENCE] SDK/client가 retry·fallback·hedged request·telemetry 또는 추가 message invocation을 내부적으로 수행하면 이를 명시적으로 차단하거나 각 실제 message creation을 별도 durable attempt와 evidence로 증명해야 합니다. 저장 attempt보다 실제 message invocation이 많을 가능성을 배제할 수 없으면 해당 client configuration을 승인하지 않습니다.

| Invocation 직전 gate | 필수 재검증 |
| --- | --- |
| Source authority | Exact delivery work·set·mapping, current claim·lease/fence와 승인 recovery event |
| Source integrity | Committed immutable result/item subset과 rendering version/hash 일치 |
| DB/operation | DB trust·pause·operation activation·target scope |
| Contract/cost/credential | 적용 Discord contract·cost evidence·exact credential/version/permission |
| Timing | Scheduled current의 10:00·22:00 이전 금지와 result/segment별 승인 release 조건 |
| Duplicate guard | 동일 mapping/item의 accepted 또는 이미 invocation-started uncertain attempt 부재 |

[FACT] 하나라도 충족하지 않으면 `prepared → invocation_started`를 commit하거나 Discord를 호출하지 않습니다. 차단 원인·영향 mapping/item을 보존하고 다른 target·credential·interface로 바꾸지 않습니다. Scheduled current는 source target 시각보다 먼저 호출하지 않으며 local clock만으로 timing authority를 판단하지 않습니다.

| Attempt 단계 | 허용 동작 | 금지 동작 |
| --- | --- | --- |
| Before prepared | Source·mapping·gate 검증 | Discord 호출·성공 추정 |
| Prepared committed | 외부 intent·mapping·payload version/hash 보존 | 호출 시작으로 기록 |
| Prepared 중단 | Invocation 미시작이 DB로 확인되고 전체 gate가 유효할 때 같은 attempt 재개 | 새 attempt/message 무조건 생성 |
| Invocation-started committed | 실제 외부 호출 시작 | Prepared 복귀·불명확 호출 자동 반복 |
| Response/error observed | Append-only safe evidence와 acceptance 판정 | 기존 evidence·selection·summary 수정 |
| Effect uncertain | 원래 attempt·mapping과 WBS-19 confirmation/reconciliation handoff 유지 | 성공·명시적 미수락·자동 recovery 추정 |

| 관찰 결과 | Server acceptance | 후속 경계 |
| --- | --- | --- |
| 계약상 긍정적 response와 required message ID가 exact mapping됨 | `accepted` | 동일 mapping 재호출 금지 |
| 긍정 response이나 ID 누락·형식 오류·mapping 불가 | `acceptance_uncertain` | 자동 retry 금지 |
| Timeout·network·응답 미수신/유실 | `acceptance_uncertain` | 자동 retry 금지, WBS-19 owner |
| 실제 계약이 message 미생성을 보장하는 명시적 거부 | `explicitly_not_accepted` 후보 | 승인 retry/recovery만 허용 |
| 429·rate-limit evidence | Cause는 rate-limited, acceptance는 별도 판정 | `Retry-After`·deadline·중복 위험 대조 |
| Render/gate 차단 | `unattempted` | 조건 회복 뒤 exact intent 재대조 |
| Response·ID·body evidence 상충 | Cause/acceptance unknown | 최신 evidence나 성공을 임의 우선하지 않음 |

[FACT] Error cause와 acceptance state는 별도 축입니다. 4xx·429·5xx·auth/config·payload·permission·network·timeout 원인을 기록해도 message 미생성 근거가 없으면 confirmed non-acceptance로 추정하지 않고, 명시적 미수락이어도 source selection·AI 결과를 실패로 변경하지 않습니다.

[FACT] 여러 physical message에서는 mapping별 acceptance와 실제 item subset을 유지합니다. 필요한 mapping이 모두 accepted일 때만 논리 delivery 전체 성공을 projection하고, 일부 accepted이면 해당 item은 성공 범위로 유지하며 나머지를 각각 explicitly-not-accepted·acceptance-uncertain·unattempted로 남깁니다. 한 mapping의 acceptance를 다른 message/item으로 전파하지 않습니다.

```text
logical article item scope
  = accepted item
  + explicitly-not-accepted item
  + acceptance-uncertain item
  + unattempted item
```

[FACT] Exact original attempt의 늦은 긍정 response와 required message ID만 원래 mapping에 append-only acceptance evidence로 적용합니다. Recipient reaction·batch check·`받음`은 실제 item의 recipient-observed evidence가 될 수 있지만 원래 Discord 2XX·server acceptance·정시 수락 시각을 만들지 않습니다. Direct message proof의 허용 여부는 SPK-03 actual mapping contract 없이는 확정하지 않습니다.

[FACT] 정시 acceptance는 source scheduled batch의 사용자 message 필요 current 결과에서 required physical mapping의 message ID와 `discord_2xx` evidence가 `10:00:00 ≤ accepted_at < 10:01:00` 또는 `22:00:00 ≤ accepted_at < 22:01:00`일 때만 계산합니다. Processing-delayed, confirmed recovery, receipt confirmation, direct/recipient evidence는 원래 정시 분자·분모 또는 acceptance 시각을 만들지 않습니다.

[FACT] Failure notice·receipt confirmation·offer physical message의 acceptance/error는 그 system message의 전달 결과만 변경합니다. 원래 AI processing failure, selection summary, article delivery, user receipt·recovery·feedback을 성공·실패·normal-zero로 변경하지 않습니다.

| 검증군 | 최소 검증 내용 |
| --- | --- |
| Composition | Current 0/1/10, recovery 0/1/10, total 20, delayed 10, notice/confirmation/offer/no-message |
| Rendering | 필수·optional field, 정보 제한, Markdown/mention/link injection, payload limit·render failure와 silent truncation 0건 |
| Mapping | Multi-message split·order·hash 재현, disjoint item subset·대표 mapping·system-message scope |
| Gate/timing | Target 전/경계/후, stale lease, pause/DB/contract/cost/credential mismatch와 invocation 0건 |
| Client behavior | Hidden retry·fallback·hedged request·additional message와 stored/actual invocation count 대조 |
| Acceptance/error | Positive+ID, missing/malformed ID, 4xx·429·5xx·network·timeout·response loss·conflict |
| Partial/late | 일부 accepted·not-accepted·uncertain·unattempted, exact/duplicate/conflicting late evidence와 item scope |
| Meaning separation | System message·reaction·receipt의 selection/AI/server acceptance/정시 지표 변경 0건 |

[INFERENCE] WBS-17 rollback은 operation adapter, rendering/mapping, attempt/acceptance와 partial/late projection을 독립 slice로 유지합니다. 이미 commit된 delivery set·mapping·attempt·response·acceptance evidence를 rollback 명목으로 삭제·수정하지 않고 contract/rendering defect가 발견되면 신규 invocation을 fail-closed로 차단하며 과거 selection/result를 새 layout으로 소급 전송하지 않습니다.

[INFERENCE] WBS-17 완료 기준은 무승인 interface/target/credential, current/delayed/recovery·summary 혼합, item 누락/중복, nondeterministic split, silent truncation, 조기/stale/hidden invocation, message-ID 없는 accepted, uncertain 자동 retry, 한 mapping의 전체 성공 확장, recipient evidence의 2XX/정시 전환, system-message 의미 오염과 Secret 노출이 각각 0건이고 physical mapping별 source→attempt→evidence→acceptance lineage가 완결되는 것입니다.

[UNKNOWN] 실제 delivery interface·Application/bot/webhook, principal·guild/channel/user identifier, permission·credential, payload/content/embed/component limit와 escaping/layout/split, response/message-ID·4xx/429/5xx·rate-limit contract, invocation cardinality, retry/backoff, direct/late proof, multi-message completion과 failure-notice timing은 SPK-03·06, WBS-04·05·07·09에서 사용자 승인으로 닫아야 합니다. 이 계획 승인은 Discord resource·permission·credential·SDK·payload·code·SQL·DB·실제 message 또는 retry 값을 승인한 것이 아닙니다.

### WBS-18 Gateway listener·feedback·누락 요청 구현 상세

[FACT] 관련 Requirement는 `FR-017~023`, `NFR-REL-001~003`, `NFR-DQ-002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-MNT-002`, `DR-010~012`, `EXT-DC-003`, `EXT-FB-001~006`, `VR-010·012~013`이고 관련 Architecture Decision은 `AD-01~03`, `AD-05`, `AD-08`, `AD-10~13`, `AD-21`, Data / Interface Design Decision은 `DDI-04~06`, `DDI-10`, `MIN-01·03·05·07~08`입니다. 외부 검증은 `SPK-03`, `SPK-06A·06B`, 상위 설계는 `WBS-07.A·D·F`, 선행 구현은 `WBS-11~14`, `WBS-17`, 후속 소유자는 `WBS-19.A·B`입니다.

[FACT] WBS-18은 미래 구현 후보의 작업 경계를 정의합니다. 현재 승인으로 application code, DB migration·SQL, Discord Gateway/interaction resource·permission·credential, 실제 연결·REST 조회·응답·message·recovery를 생성하거나 변경하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-18.A | Gateway session·continuity | 승인 session authority, resume/sequence·gap 상태, bounded reconciliation request handoff | 정상 reconnect와 continuity 실패를 구분하고 listener의 직접 REST/recovery 0건 test |
| WBS-18.B | Append-only event intake | 허용 event type, 최소 typed field, safe digest/reference, commit/application 결과 | duplicate·malformed·storage failure에서도 raw history 수정·Secret/unrestricted payload 0건 test |
| WBS-18.C | Identity·order·subject validation | config/guild/channel/message/user/reaction/subject mapping과 order validator | unmapped·stale·older·unknown·bot event가 projection을 오염하지 않는 test |
| WBS-18.D | Feedback/review projection | append-only event와 mutable current projection 분리, article feedback·batch review·receipt 의미 | add/remove·중복·순서·충돌과 evaluation source 분리 test |
| WBS-18.E | Interaction intake·idempotency | 서명·target·approved user·action·request identity 검증과 acknowledgement/commit 상태 | forged·duplicate·ack/commit ambiguity에서 business effect 최대 1회 test |
| WBS-18.F | Missing-article lookup·reply | exact raw link lookup, grounded status/reply, recommendation eligibility | 외부 dereference·RSS fetch·AI·직접 resend·허위 source/recall 0건 test |
| WBS-18.G | Recommendation·receipt handoff | eligible recommendation, typed `받음`/`못 받음` evidence와 WBS-19 request | 2XX·server acceptance 조작 또는 listener 직접 recovery mutation 0건 test |
| WBS-18.H | Security·contract·fault·rollback | allowlist/redaction, contract fingerprint, fault matrix, fail-closed/rollback 절차 | credential·민감 payload 비보존, ambiguous effect 보존, append-only history 손실 0건 test |

#### WBS-18.A Gateway session·continuity

[INFERENCE] Gateway 연결은 WBS-11의 operation/session authority가 유효하고 승인된 exact application/principal, intents, guild/channel scope, credential version, interface contract, 비용 evidence와 DB trust를 모두 확인한 뒤에만 활성화하는 구현 slice로 분리합니다. Listener는 delivery credential이나 관리 권한을 편의상 공유·확대하지 않습니다.

[FACT] 정상 reconnect 또는 계약상 resume 성공만으로 누락 feedback이 있다고 추정하거나 reconciliation request를 만들지 않습니다. 다음 직접 증거가 있을 때만 exact config/channel/sequence/time 범위를 가진 bounded internal request를 WBS-19.A에 넘깁니다.

| 직접 증거 | WBS-18 동작 | 금지 동작 |
| --- | --- | --- |
| Resume 실패 또는 continuity 상실 | 마지막 확정 sequence와 불확실 구간을 보존하고 bounded request 생성 | 전체 history 조회·absence 확정 |
| 관찰 sequence gap | 앞뒤 sequence·수신/commit 시각·영향 scope를 보존하고 bounded request 생성 | gap 밖 message/reaction 광역 조회 |
| Event storage 실패·commit 불명확 | 저장 시도와 불확실 scope를 보존하고 bounded request 생성 | 저장 성공 또는 event 부재 추정 |
| 정상 reconnect/resume | session evidence만 갱신 | reconciliation request·REST 호출 |

[INFERENCE] WBS-18은 request를 durable하게 기록해 후속 소유자에게 넘길 뿐 Discord REST를 직접 호출하지 않습니다. Listener가 관찰하지 못한 시간, 권한 오류, process 중단 또는 config 불일치는 event가 없었다는 증거가 아니며 feedback·receipt를 `absent`로 projection하지 않습니다.

#### WBS-18.B Append-only event intake

[INFERENCE] Raw Gateway/interaction history는 승인 contract의 event만 받는 typed allowlist로 구현하고, 최소 필드는 external event identity·kind, config/guild/channel/message/user/bot identity, reaction/action, source sequence/order/timestamp, safe payload digest/reference, received/committed time, validation/application 결과와 non-application reason입니다. 실제 field name/type/nullability는 WBS-07 actual contract와 WBS-12 physical design에서 확정합니다.

[FACT] 원본 전체 JSON, message content 전체, interaction token, signature secret, Authorization, cookie, webhook URL, credential 또는 불필요한 identifier를 범용 payload column에 저장하지 않습니다. 계약상 필요한 민감 identifier는 최소화·분류·접근통제하고 log/metric/error에는 raw 값 대신 승인 safe reference를 사용합니다.

[INFERENCE] 외부 event identity가 계약상 제공되면 이를 primary dedupe key 후보로 사용하고, 제공되지 않으면 승인된 canonical field 조합과 contract version으로 deterministic identity를 정의합니다. 수신·저장·검증·projection 적용은 서로 다른 상태/evidence로 남겨 `received`를 `committed/applied`로 추정하지 않습니다.

#### WBS-18.C Identity·order·subject validation

| 검증 축 | 적용 조건 | 불일치 처리 |
| --- | --- | --- |
| Configuration | 활성 config/application/contract version과 일치 | Append-only non-application evidence, projection 금지 |
| Guild/channel | 승인 exact target scope와 일치 | 다른 guild/channel로 확장하지 않음 |
| Message | WBS-17의 원래 delivery attempt·message ID·physical mapping과 event의 exact 연결 확인; Discord server acceptance는 선행조건이 아님 | Unmapped/stale event로 보존, article/batch 귀속 금지 |
| User/bot | 승인 사용자이고 self/bot/system event가 아님 | Feedback·receipt·review 적용 금지 |
| Reaction/action | 승인 emoji·structured command/action과 exact match | 유사 문자열·일반 message를 의미로 추정하지 않음 |
| Subject | Article item, batch representative 또는 system message 종류가 정확히 매핑 | 한 mapping의 의미를 다른 item/batch로 전파하지 않음 |
| Order | 계약 sequence와 해당 subject의 최신 적용 version 대조 | Older/duplicate/unknown order가 current projection을 되돌리지 않음 |

[FACT] Duplicate event는 append-only receipt evidence를 중복 생성하지 않고 business effect를 최대 한 번만 적용합니다. 늦게 도착한 valid event는 source order가 입증될 때 해당 event-time 의미로 보존할 수 있지만, 더 최신의 확인된 projection을 무조건 되돌리지 않습니다. Order를 판별할 evidence가 없으면 conflict/unknown으로 보존하고 임의의 수신 순서 우선 규칙을 적용하지 않습니다.

[FACT] Listener 비가동·관찰 범위 밖·권한 부족·sequence 불명확·storage 실패는 `반응 없음`, `못 받음 없음`, `batch 확인 없음`으로 계산하지 않습니다. Absence는 WBS-19.A의 bounded reconciliation이 완결된 exact scope에서만 후속 규칙에 따라 판정할 수 있습니다.

#### WBS-18.D Feedback/review projection

[FACT] Append-only reaction/interaction event history와 mutable `feedback_state` projection을 분리합니다. Projection 변경은 검증된 exact subject event에서만 허용하고 add/remove·중복·older/conflict의 원인 event identity와 적용 version을 역추적할 수 있어야 합니다.

[FACT] 기사별 😕·🚫·📣 부정 reaction은 FR-017·019의 승인 meaning catalog에 따라 각각 독립 상태로 보존하며 동일 article에 복수로 존재할 수 있습니다. 복수 부정 reaction 자체는 conflict가 아니고, 기사 단위 부정 여부는 한 건으로 계산하되 원인별 지표에는 각 reaction을 별도로 포함합니다. Batch ✅는 기사에 대한 긍정 평가가 아니라 별도 review/receipt 의미입니다. 동일 event/subject의 순서 불명확은 WBS-18.C의 order 계약을 따르고, 같은 전달 scope의 receipt와 `못 받음` 충돌은 승인된 `conflicting_receipt` 계약을 따릅니다. Reaction remove는 해당 현재 상태만 해제하며 append-only history 또는 이미 발생한 recipient receipt evidence를 삭제하지 않습니다.

[FACT] Batch 대표 message의 승인 `확인` reaction add는 그 대표 mapping이 가리키는 exact article scope에 한해 recipient-observed receipt evidence를 만들 수 있습니다. Remove는 과거 receipt를 삭제하거나 원래 Discord server acceptance·2XX·정시 acceptance를 취소하지 않습니다. Failure notice·receipt confirmation·offer 또는 item 없는 system message의 reaction은 article feedback이나 batch receipt로 사용하지 않습니다.

[FACT] `feedback_state`는 현재 UX projection이며 immutable evaluation source가 아닙니다. Evaluation은 cutoff 이전의 검증된 append-only event와 reconciliation completeness를 사용하고, 현재 projection만 읽어 과거 상태·remove·late evidence를 재구성하지 않습니다.

#### WBS-18.E Interaction intake·idempotency

[INFERENCE] Structured interaction은 계약상 signature/timestamp 검증, exact application/config/guild/channel, 승인 사용자, 승인 command/action, target message/item/batch와 request identity를 검증한 뒤에만 처리합니다. 일반 Discord message, 자유 형식 문장 또는 비슷한 command 문자열을 missing/receipt/recovery 의도로 해석하지 않습니다.

[FACT] 같은 request identity는 business effect를 최대 한 번만 commit합니다. Discord acknowledgement 전송 여부, interaction request 저장 여부, business effect commit 여부와 reply acceptance는 각각 별도 evidence/state입니다. Ack 성공을 business commit이나 reply 수락으로 추정하지 않고, ack/commit 결과가 불명확하면 자동으로 동일 effect를 반복하지 않습니다.

[UNKNOWN] 실제 interaction signature scheme, acknowledgement deadline·response mode, command/component 이름·field, token 수명, duplicate delivery와 late response 계약은 SPK-03과 WBS-07 actual contract에서 확정해야 합니다.

#### WBS-18.F Missing-article lookup·reply

[FACT] MVP-A missing-article 요청은 승인된 하나의 structured interaction에 포함된 exact raw link 하나만 입력으로 받습니다. URL normalization, redirect/dereference, 외부 원문 조회, RSS 재수집, 검색 또는 AI 호출을 수행하지 않습니다.

| Grounded lookup 결과 | 허용 회신 의미 | 금지 추정 |
| --- | --- | --- |
| `found_in_collection` | 기존 저장 record와 수집·후속 상태를 승인 필드로 설명 | 전달됨·읽음·중요/비중요·누락 아님 단정 |
| `not_collected` | Exact raw link와 일치하는 저장 record가 현재 조회 scope에 없음을 설명 | GeekNews/RSS에 없었음, 원문 부재, 중요도·recall failure 단정 |
| `invalid_reference` | 입력 형식 또는 허용 link contract 불일치 설명 | 임의 교정·다른 URL 조회 |

[FACT] MVP-B의 자동 retention lifecycle이 구현되지 않은 MVP-A에서는 `retention_purged`를 현재 원인으로 만들지 않습니다. 조회 scope·cutoff·DB trust가 불완전하면 `not_collected`로 답하지 않고 unavailable/unknown으로 보존합니다.

[INFERENCE] 회신은 저장된 RSS/Raw evidence, candidate·analysis·selection·delivery 상태와 각 version만 근거로 구성하고 현재 시점의 새 AI 분석이나 재선정을 수행하지 않습니다. 추천 가능 상태는 승인 recommendation eligibility를 모두 충족한 기존 결과에 한정하며, 미처리·실패·outdated·eligibility 불명확 항목을 즉석에서 추천하지 않습니다.

#### WBS-18.G Recommendation·receipt handoff

[FACT] `받음`은 원래 article-bearing delivery의 `delivery_attempt`, `discord_message_mapping`, `delivery_segment`, `selection_result`와 승인 recipient를 모두 정확히 연결할 수 있을 때 durable recipient receipt와 typed `user_received` event를 만듭니다. 원래 Discord server acceptance가 불명확해도 이 조건을 충족하면 적용하며, `user_received_confirmation` 출처의 receipt evidence를 추가하고 해당 scope는 재전송하지 않습니다. Receipt만으로 원래 WBS-17의 Discord 2XX, server acceptance, message ID 또는 정시 acceptance를 생성·수정하지 않습니다. 매핑 불가·모호·미승인 사용자 요청은 거부 근거만 보존하며 receipt·전달 상태 변경·resend를 만들지 않습니다. 같은 scope의 receipt/non-receipt 충돌은 기존 conflict 계약을 유지합니다. 정본은 [Receipt adapter 계약](../02-technical/interface-spec.md)과 [수신 evidence 계약](../02-technical/data-model.md)입니다.

[FACT] `못 받음`은 exact original delivery/mapping과 승인 recipient를 검증해 typed non-receipt/recovery-request evidence를 만들고 WBS-19.B에 넘길 뿐, listener가 Discord message를 직접 재전송하거나 recovery backlog를 직접 선택·변경하지 않습니다. 이미 receipt와 non-receipt가 상충하면 최신 수신만 자동 우선하지 않고 양쪽 evidence와 conflict를 보존합니다.

[FACT] 추천 회신과 receipt confirmation은 각각 자신의 interaction reply/system message 결과만 표현합니다. 원래 article delivery acceptance, selection, AI 처리 상태, feedback, missing/recall 또는 recovery 성공으로 전환하지 않습니다.

#### WBS-18.H Security·contract·fault·rollback

| 검증군 | 최소 검증 내용 |
| --- | --- |
| Session/continuity | 정상 reconnect, resume 성공/실패, sequence gap, listener downtime, permission/config drift |
| Intake/storage | Valid, malformed, duplicate, storage failure, commit unknown, unrestricted/secret-bearing payload 거부 |
| Mapping/identity | 다른 config/guild/channel/message/user/bot/system message, stale/unmapped physical mapping |
| Ordering | Add→remove, remove→add, duplicate, older arrival, unknown order, conflict와 current projection 비회귀 |
| Feedback/receipt | 😕·🚫·📣 동시 입력은 conflict 없이 기사 부정 1건·원인별 3건; 각 add/remove 반영, batch check add/remove, 같은 scope receipt/non-receipt conflict, system reaction, evaluation cutoff source |
| Interaction | Valid/forged signature, wrong user/target/action, duplicate request, ack success/failure와 DB commit 조합 |
| Missing/recommendation | Found/not-collected/invalid/unavailable, exact-link only, eligibility 경계, 외부 fetch·AI 0건 |
| Recovery boundary | `받음`/`못 받음`, conflict, listener 직접 REST/retry/resend/backlog mutation 0건 |
| F01 receipt prerequisite | Server acceptance 불명확 + exact original attempt/message/segment/selection·승인 사용자 + 유효 `받음`은 recipient receipt만 추가하고 no-resend; 원래 server uncertainty·2XX·정시 수락 evidence 불변. Mapping 불가·모호·다른 사용자 및 confirmation system message 자체의 2XX·일반 reaction만으로는 원래 article receipt를 만들지 않음 |

[INFERENCE] Contract/config/permission drift, DB trust 상실, signature 실패, sequence/commit ambiguity 또는 secret/redaction 위반이 있으면 신규 effect를 fail-closed로 차단합니다. Rollback은 listener/session adapter, typed intake, validation, projection, interaction/reply를 독립 slice로 비활성화할 수 있어야 하며 이미 commit된 append-only event, receipt, request, reply/ack evidence를 삭제·수정하지 않습니다.

[INFERENCE] WBS-18 완료 기준은 승인되지 않은 event/interaction, 다른 scope/user/bot/system message, duplicate/older/unknown-order event가 feedback·review·receipt·missing projection을 변경한 건수와 Secret/unrestricted payload 저장, false absent/not-collected/recall, listener 직접 REST·retry·resend·recovery mutation이 각각 0건이고 event→validation→projection/request/reply lineage가 완결되는 것입니다.

[UNKNOWN] 실제 Gateway interface, intents·resume/sequence 계약, application/principal·guild/channel/user identifiers, reaction/command/component catalog, signature·acknowledgement·token contract, event field와 safe identifier policy, REST reconciliation capability, missing reply wording·recommendation eligibility는 SPK-03·06, WBS-04·05·07·09에서 사용자 승인으로 닫아야 합니다. 이 계획 승인은 Discord resource·permission·credential·listener·interaction·REST·reply·code·SQL·DB 또는 recovery 실행을 승인한 것이 아닙니다.

### WBS-19 Bounded feedback reconciliation·delivery recovery 구현 상세

[FACT] 관련 Requirement는 `FR-004~005`, `FR-015~023`, `NFR-REL-001~003`, `NFR-COST-001`, `NFR-DQ-002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-REC-001`, `NFR-TIME-001`, `DR-009~012·014`, `EXT-DC-003~006`, `EXT-FB-001~002·006`, `VR-005·009~013·018`이고 관련 Architecture Decision은 `AD-01~03`, `AD-05`, `AD-07~08`, `AD-10~13`, `AD-15~16`, `AD-19~23`, Data / Interface Design Decision은 `DDI-03~06`, `DDI-08~10`, `MIN-01·03·05·07~08`입니다. 외부 검증은 `SPK-03`, `SPK-04`, `SPK-06A·06B`, 상위 설계는 `WBS-05`, `WBS-07.A·C·E~G`, `WBS-08.D`, 선행 구현은 `WBS-11~13`, `WBS-17~18`, 후속 검증은 `WBS-20~25`입니다.

[FACT] WBS-19은 미래 구현 후보의 작업 경계를 정의합니다. 현재 승인으로 application code, DB migration·SQL, Discord REST resource·permission·credential, 실제 HTTP/message/confirmation/resend/recovery 또는 K3s scheduling을 생성하거나 변경하지 않습니다.

[FACT] `WBS-19.A` feedback REST reconciliation과 `WBS-19.B` delivery confirmation/recovery는 목적·logical work key·claim/attempt·credential/permission·state owner·rollback을 공유하지 않는 독립 slice입니다. A의 결과로 B를 시작·완료하거나 B의 evidence로 A의 pagination·feedback observation을 완결하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-19.A1 | Reconciliation request admission | 네 trigger register, direct evidence, exact scope, dedupe/coalescing | 허용 trigger 밖·정상 reconnect·broad preventive request 0건 test |
| WBS-19.A2 | REST invocation gate | 별도 work/claim/attempt, DB·contract·permission·cost/outbound gate | Request-only·closed/stale gate의 HTTP invocation 0건 test |
| WBS-19.A3 | Snapshot completeness·ordering | Pagination/coverage/response/order evidence와 append-only snapshot | Partial/error/older/unknown-order 기반 `absent`·rollback 0건 test |
| WBS-19.A4 | Feedback application·handoff | Exact current projection과 evaluation completeness handoff | Acceptance·receipt·recovery·delivery timing mutation 0건 test |
| WBS-19.B1 | Recovery case admission·due | Source-scoped case uniqueness, 명시적 미수락 복구와 uncertainty 전용 confirmation 분리, durable work | 직접 명시적 미수락의 FIFO 진입, non-uncertain confirmation·duplicate case·wrong due·message별 case 0건 test |
| WBS-19.B2 | Confirmation execution | Invocation 직전 recheck, original scheduled batch당 intent 1회 | 조기·중복·known-received confirmation과 의미 오염 0건 test |
| WBS-19.B3 | Receipt·immediate resend | Exact `받음`/`못 받음`, conflict, resend authorization 1회 | `받음` resend·unauthorized/duplicate/uncertain 반복 0건 test |
| WBS-19.B4 | No-response offer·selection | 다음 성공 정규 batch의 offer intent와 explicit recovery selection | Uncertain offer 재첨부·무응답 자동 recovery 0건 test |
| WBS-19.B5 | Confirmed-non-acceptance FIFO release | Item eligibility, oldest-batch queue, 10/10/20 segment handoff | Cross-batch·uncertain/received item·processing-delayed 혼합 0건 test |
| WBS-19.B6 | Fault·security·rollback | Lost-handoff matrix, partial/late/conflict, redaction, slice rollback | Stale mutation·evidence 손실·Secret·RSS/AI/reselection 0건 test |

#### WBS-19.A1 Reconciliation request admission

[FACT] Feedback REST reconciliation request는 다음 네 trigger 중 하나에 직접 evidence와 exact 영향 scope가 연결될 때만 생성합니다.

| 허용 trigger | Request 생성에 필요한 직접 evidence | Request 금지 사례 |
| --- | --- | --- |
| Gateway resume 실패·continuity 상실 | Resume 실패, continuity 불입증과 영향 config/channel/sequence/time scope | 정상 reconnect/resume, 근거 없는 일반적 event 불신 |
| DB recovery·restore | 실제 recovery/restore run과 대조 대상 mapping/scope | DB를 신뢰할 수 있는 일반 process restart |
| Gateway event 저장 실패·gap | 수신 event commit 실패, sequence gap 또는 ordering 불가와 영향 scope | Listener 정상 상태의 예방성 polling |
| 승인 evaluation 계산 직전 | 하나의 evaluation request와 exact batch/기간/cutoff/subject scope | 정기 전체 scan, evaluation과 무관한 조회 |

[FACT] Request 생성은 내부 durable 기록이며 Discord REST 호출, reaction 관측 성공 또는 `absent` 판정을 뜻하지 않습니다. Request는 trigger/evidence identity, configuration/contract boundary, tracked message, approved user, allowed reaction, subject와 evaluation scope/cutoff reference를 보존합니다.

[INFERENCE] 동일 configuration boundary와 exact message/user/reaction/subject/evaluation scope의 중복 request만 하나의 logical work로 수렴시킵니다. 다른 scope를 편의상 합치거나 일부 결과를 다른 request에 전파하지 않습니다. 부분 중첩 범위의 physical merge/split은 승인된 WBS-05/07 physical contract 없이는 구현자가 정하지 않습니다.

#### WBS-19.A2 REST invocation gate

[FACT] Request admission과 REST invocation은 별도 transaction/attempt입니다. 실제 HTTP 직전 다음을 모두 재검증합니다.

| Gate | 필수 조건 | 닫힘·불명확할 때 |
| --- | --- | --- |
| Work authority | A 전용 work key, 유효 claim·lease/fence, 현재 request | Waiting/blocked reason 보존, HTTP 금지 |
| DB trust | Ledger·delivery mapping·feedback scope를 신뢰 가능 | Restore/integrity 및 사용자 outbound 재개 승인 전 금지 |
| Discord contract | Exact endpoint capability, config, permission, credential version | 다른 endpoint/credential/권한으로 fallback 금지 |
| Cost/outbound | 적용 무료·usage·operation gate evidence 유효 | 유료 전환·gate 우회 금지 |
| Scope | Tracked message·approved user·allowed reaction·subject가 bounded | Server/channel 전체 polling·scope 확대 금지 |

[FACT] Restore 사실은 request trigger일 수 있지만 REST 실행 허가는 아닙니다. DB/mapping 무결성과 outbound gate가 회복되고 필요한 사용자 재개 승인을 받은 뒤에만 별도 claim의 REST attempt를 시작합니다.

[FACT] WBS-19은 billing API를 호출하거나 비용 0원을 자동 확정하지 않습니다. REST invocation은 WBS-08.B의 승인 무료 조건·usage/quota·operation gate와 적용 scope의 사전 비용 evidence가 유효할 때만 허용하며, 해당 사전 근거가 없거나 stale·mismatch이면 차단합니다. 첫 운영월이 끝나지 않아 월별 billing 결과가 아직 존재하지 않는다는 사실만으로 사전 승인 scope를 차단하지 않습니다. 실제 사용자 billing/usage evidence에 따른 기간별 비용 Hard Gate 판정은 별도이며, 필수 기간·scope coverage가 없으면 `pass` 또는 실제 0원으로 추정하지 않고 pending/not-measurable로 남깁니다. 실제 비용 위반은 pause·incident와 해당 기간 Gate `fail`, 기간 종료 뒤 필요한 billing 확인 누락은 WBS-08.B의 재확인 정책을 따릅니다.

[INFERENCE] F03 검증은 사전 근거가 유효하고 첫 운영월 결과만 미존재한 경우 승인 scope의 REST 호출 후보를 허용하되 비용 Hard Gate는 미확정으로 유지하는지, 사전 근거 불명·stale·mismatch에서는 호출을 차단하는지, 실제 과금에서는 pause·Gate fail을 보존하는지를 각각 대조합니다. 다른 invocation 선행조건은 그대로 적용합니다.

[INFERENCE] SDK/client의 hidden retry, fallback, hedged request 또는 scope 확장을 차단합니다. 실제 REST invocation마다 durable attempt/evidence가 하나씩 대응하지 않으면 client configuration을 승인하지 않습니다.

#### WBS-19.A3 Snapshot completeness·ordering

| Snapshot evidence | 필수 내용 | 불완전·실패 처리 |
| --- | --- | --- |
| Observation identity | Request/work/attempt, config, message/user/reaction/subject, 관측 시각 | Mapping 불가이면 `unmapped/unknown` |
| Pagination | Page/cursor 진행, 종료 조건, page별 safe digest와 completeness | 일부 page로 `absent` 판정 금지 |
| Response | Redacted status/error/rate-limit/receipt와 response coverage | Timeout/response loss를 성공·부재로 추정 금지 |
| Scope coverage | 요청 exact scope와 실제 응답 범위의 일치 | 누락·초과·불명확이면 `stale/unknown` |
| Ordering | Gateway/이전 REST observation과 비교 가능한 source order | 비교 불가이면 최신 state 덮어쓰기 금지 |

[FACT] `rest_state_snapshot`은 관측 시점 current-state evidence를 append-only로 보존하며 WBS-18의 Gateway event history를 삭제·수정하지 않습니다. Pagination과 exact scope coverage가 완결된 경우에만 관측 reaction은 `present`, 미관측 reaction은 해당 exact subject의 `absent` 후보가 됩니다.

[FACT] Permission 부족, rate-limit, timeout, 오류, response loss, incomplete pagination, mapping/coverage 실패 또는 ordering 불명확이면 미관측 reaction을 `absent`로 바꾸지 않습니다. 안전한 evidence에 따라 `stale`, `unknown`, `unmapped` 또는 `not_observed`를 유지합니다.

[FACT] 더 과거인 snapshot은 history로만 보존하고 current projection을 되돌리지 않습니다. Gateway와 REST의 순서를 안전하게 비교할 수 없으면 한쪽을 임의로 최신으로 선택하지 않으며, 완결 관측이 전혀 없으면 state row를 새로 만들어 `absent`로 채우지 않습니다.

#### WBS-19.A4 Feedback application·handoff

[FACT] 완결되고 안전하게 최신인 REST observation만 WBS-18의 exact subject `feedback_state` current projection에 적용할 수 있습니다. 적용은 source snapshot, prior projection version, 적용 판단과 non-application reason을 역추적할 수 있어야 합니다.

[FACT] Feedback reconciliation은 Discord server acceptance/rejection/uncertainty, recipient receipt, recovery case/event, original delivery attempt/result, message ID 또는 정시 acceptance를 생성·삭제·수정하지 않습니다. Reaction absence는 feedback current projection만 바꿀 수 있고 과거 receipt나 recovery 사실을 취소하지 않습니다.

[FACT] Evaluation trigger에서는 성공한 reconciliation 또는 알려진 실패/불확실성이 고정된 뒤 exact cutoff와 completeness를 WBS-22에 넘깁니다. Mutable current projection만 평가 source로 사용하거나 `unknown/not_observed`를 feedback 0건으로 바꾸지 않습니다.

#### WBS-19.B1 Recovery case admission·due

[FACT] Recovery case는 원래 article-bearing delivery의 receipt·복구 절차를 연결하며, 수락 불명확 전달의 확인 경로와 명시적 미수락 item의 복구 경로를 모두 수용합니다. 하나의 source `selection_result`, original delivery target reference와 승인 recipient reference 조합당 최대 하나이며 physical message/attempt/item마다 case를 중복 생성하지 않습니다. Case 존재는 confirmation·resend·backlog 편입 허가가 아닙니다. Item별 실제 acceptance/receipt 근거와 conflict를 대조해 각 후속 작업의 자격을 별도로 판정하며, 처음부터 명시적 미수락이고 같은 item scope의 유효 server acceptance·direct proof·recipient receipt와 conflict가 없는 item은 과거 uncertainty나 confirmation을 요구하지 않고 B5의 FIFO 복구 후보로 연결합니다. 정본은 [Data recovery case·item 계약](../02-technical/data-model.md)과 [Interface recovery 계약](../02-technical/interface-spec.md)입니다.

[FACT] Confirmation due는 같은 original scope의 수락 불명확 physical attempt에만 적용하며, 여러 불명확 attempt가 있으면 그중 마지막 `invocation_started_at + 1시간`입니다. 명시적 미수락만 있는 case에 confirmation due/work를 만들지 않습니다. Process start, response timeout, evidence commit 또는 worker claim 시각으로 임의 대체하지 않습니다. 실제 timestamp/clock authority와 scheduling tolerance는 승인 WBS-03/07/08 및 SPK-03/04 contract를 사용합니다.

[INFERENCE] Case admission·due work·confirmation·immediate resend·offer·FIFO recovery는 각각 durable logical intent/work identity를 사용합니다. 하나의 generic retry key나 A의 feedback reconciliation key/credential/permission을 공유하지 않습니다.

#### WBS-19.B2 Confirmation execution

[FACT] Due work를 claim한 뒤에도 외부 invocation 직전에 대상의 수락 불명확 상태와 due, latest Discord 2XX, SPK-03에서 검증된 exact direct proof, recipient-observed receipt, explicit user-received evidence와 conflict를 재검사합니다. 대상이 더 이상 수락 불명확하지 않거나 신뢰 가능한 수신 근거가 있거나 conflict로 안전한 판정이 불가능하면 confirmation을 보내지 않습니다.

[FACT] Confirmation은 original scheduled batch당 intent를 최대 한 번만 가집니다. Confirmation message는 WBS-17의 별도 system-message delivery attempt/mapping/acceptance를 사용하며 그 2XX·message ID는 confirmation message 자체의 수락만 의미합니다. Original delivery의 2XX·receipt·정시 acceptance를 만들지 않습니다.

[FACT] Confirmation invocation이 이미 시작된 뒤 late receipt/acceptance가 도착하면 원래 case에 append-only로 보존하되 시작된 호출을 취소·재호출하거나 article resend를 자동 생성하지 않습니다.

#### WBS-19.B3 Receipt·immediate resend

| Receipt 결과 | 허용 transition | 금지 동작 |
| --- | --- | --- |
| Exact `받음` | `user_received` evidence와 no-resend | Original 2XX·정시 acceptance 생성, resend |
| Exact `못 받음` | `user_not_received`와 immediate-resend authorization 최대 1회 | Original server 상태를 explicit non-acceptance로 변경 |
| Mapping/user 불명 | 거부/불명확 evidence만 보존 | Case 완료·resend |
| Same-scope conflict | `conflicting_receipt`, 자동 transition 중단 | 최신 수신 자동 우선·evidence 삭제 |

[FACT] Exact `못 받음`의 resend authorization은 원래 message/article-or-batch mapping, 승인 recipient와 explicit missing-receipt 예외 유형을 기준으로 최대 한 번만 생성합니다. Structured interaction identity는 같은 요청의 재전달을 업무 결과에 한 번만 적용하고 원본 요청을 추적하는 기준이며, 재전송 권한의 업무 key를 나누는 값이 아닙니다. 서로 다른 interaction identity로 같은 예외를 반복·동시 요청해도 권한은 최대 1회입니다. 같은 업무 key의 `immediate_resend_authorized` event 또는 연결된 delivery가 이미 있으면 기존 결과를 조회·참조할 뿐 새 권한이나 추가 Discord 호출을 만들지 않습니다. 아직 실행되지 않은 기존 work의 처리는 기존 claim·invocation gate 계약을 따르며, 새 요청이 재실행 허가가 되지는 않습니다. 실제 resend는 B 전용 work claim과 WBS-17 invocation gate를 다시 통과하며 저장된 original `selection_result`와 `batch_item`만 사용합니다. 정본은 [Data의 1회 재전송 예외 계약](../02-technical/data-model.md)과 [Interface receipt 계약](../02-technical/interface-spec.md)입니다.

[UNKNOWN] 이 논리 중복 방지 경계의 실제 unique constraint·transaction·동시성 구현은 후속 물리 설계에서 결정하며, 이번 F02 수정에서 schema·SQL 또는 구현값을 확정하지 않습니다.

| Immediate-resend 결과 | 다음 처리 | 반복 제한 |
| --- | --- | --- |
| Discord 2XX 또는 exact recipient receipt | 해당 scope recovery 완료 후보 | 같은 authorization 재실행 금지 |
| Explicit Discord non-acceptance | 실제 미수락 item subset만 backlog 후보 | Original 전체 batch 편입 금지 |
| Acceptance uncertain | 불확실 evidence와 미해결 case 유지 | Confirmation·resend·backlog 자동 반복 금지 |
| Partial physical result | Accepted/received/non-accepted/uncertain item scope 분리 | 성공/수신 item 재전송 금지 |

#### WBS-19.B4 No-response offer·selection

[FACT] Confirmation 요청이 다음 성공 정규 scheduled delivery까지 무응답이면 `confirmation_no_response`를 기록하고, 원래 case당 offer intent를 최대 한 번만 해당 정규 delivery set의 별도 offer mapping에 연결합니다. Failure notice, receipt confirmation 또는 processing-delayed full result를 성공 정규 batch로 간주하지 않습니다.

[FACT] Offer가 표시됐다는 근거는 해당 physical mapping의 Discord 2XX와 required message ID입니다. Offer acceptance가 불명확하면 intent/attempt/evidence를 보존하고 다음 batch에 자동 재첨부·재발송하지 않습니다.

[FACT] 승인 recipient의 exact structured `recovery_selected`가 있을 때만 저장된 original result의 recovery work를 만듭니다. 무응답, 일반 message, reaction 유사 표현 또는 offer 전송 시도만으로 recovery를 선택하지 않습니다.

#### WBS-19.B5 Confirmed-non-acceptance FIFO release

```text
confirmed non-acceptance candidate
  = item별 explicit Discord server non-acceptance
  + 같은 item scope의 valid recipient receipt 없음
  + acceptance/recovery conflict 없음
```

[FACT] `못 받음`만으로 original item을 confirmed-non-acceptance backlog에 넣지 않습니다. Explicit server non-acceptance가 있어도 같은 item의 유효 recipient receipt가 있거나 acceptance/recovery conflict가 있으면 자동 recovery 후보에서 제외합니다. Server 오류 evidence 자체는 삭제하거나 2XX로 바꾸지 않습니다.

| Release 경계 | 허용 범위 | 금지 범위 |
| --- | --- | --- |
| 다음 성공 정규 발송 | 가장 오래된 original batch의 eligible item 최대 10개 | 서로 다른 original batch 혼합 |
| Current와 함께 | Current 최대 10 + recovery 최대 10, 별도 segment/summary, 총 최대 20 | 수량/summary 합산·상한 초과 |
| Recovery-only 정규 기회 | Current 신규 0건이어도 승인 recovery segment 가능 | Current source를 recovery로 변경 |
| Additional recovery | Explicit selection마다 같은 oldest batch의 남은 item 최대 10개 | 무응답 자동 전송·다른 batch 혼합 |
| 남은 backlog | 수량·oldest original batch와 wait reason 보존 | 조용한 삭제·성공·정상 0건 처리 |

[FACT] Confirmed-non-acceptance recovery와 processing-delayed full result는 별도 logical delivery set/segment입니다. Recovery는 original selection order·stored item·summary/source reference를 재사용하며 상한 밖 미선정 article, received/accepted/uncertain item을 편입하지 않습니다.

[FACT] Recovery 실행은 RSS 수집, 외부 원문 조회, AI 분석, freshness 판단, selection 또는 summary 생성을 다시 수행하지 않습니다. Original version이 없거나 integrity를 입증할 수 없으면 fail-closed로 차단하고 현재 데이터로 재생성하지 않습니다.

#### WBS-19.B6 Fault·security·rollback

[INFERENCE] F08 검증은 처음부터 명시적 미수락인 item이 같은 scope의 유효 server acceptance·direct proof·recipient receipt와 conflict가 없을 때 case에 연결되어 confirmation 없이 B5 FIFO 후보가 되는지, 수락·수신 근거가 있는 item은 복구 후보에서 제외되는지, uncertainty item은 confirmation 조건만 따르고 자동 backlog에 들어가지 않는지 확인합니다. 같은 source/target/recipient에 uncertain·명시적 미수락 item이 함께 있어도 case는 하나이고 item별 자격과 작업은 분리해야 하며, case 생성만으로 외부 호출을 허용하지 않습니다.

[INFERENCE] F02 검증은 동일 interaction 재전달의 업무 효과 중복 0건, 서로 다른 interaction identity로 같은 업무 key를 반복·동시 요청할 때 authorization 최대 1회, 이미 재전송을 시도한 뒤 새 요청의 추가 권한·호출 0건을 포함합니다. Mapping 불명확·미승인 사용자·같은 scope receipt 충돌은 기존 차단 규칙을 유지하며, invocation 결과 불명확을 새 interaction으로 우회해 재호출하지 않는지 확인합니다. 이는 후속 검증 계획이며 실제 테스트 실행 결과가 아닙니다.

| Fault 경계 | 안전한 복구 | 금지 결과 |
| --- | --- | --- |
| Receipt commit 전 중단 | 같은 interaction identity replay | Event 없이 resend work 생성 |
| Receipt commit 후 handoff 전 중단 | Durable state에서 exact work 재발견 | 중복 authorization/work |
| Prepared 후 invocation 전 중단 | 현재 claim/lease/fence/gate 재판정 | Prepared만으로 발송 성공 추정 |
| Invocation-started 후 결과 불명 | Uncertain evidence와 case 유지 | 자동 retry/resend/backlog |
| Response 후 DB commit 불명 | Exact attempt 재조회와 late evidence handoff | 새 invocation·성공/실패 추정 |
| Partial/late/conflict | Item/scope별 append-only evidence 유지 | 전체 case 성공·자동 우선·evidence 삭제 |

[FACT] WBS-19.A와 B는 별도 operation gate·least-privilege permission·credential handle을 사용합니다. Discord identifier·REST response·receipt content를 AI input으로 보내지 않고 credential, Authorization, interaction token/secret, webhook URL 또는 unrestricted response payload를 DB/log/metric/error에 저장하지 않습니다.

[INFERENCE] Rollback은 A request/admission, REST adapter/snapshot/application과 B case/due, confirmation, receipt/resend, offer/FIFO release를 독립적으로 비활성화할 수 있어야 합니다. 이미 commit된 request, attempt, snapshot, case, receipt, authorization, mapping, response/acceptance evidence를 rollback 명목으로 삭제·수정하지 않습니다.

[INFERENCE] WBS-19 완료 기준은 A의 네 trigger 밖 request/HTTP, broad polling, incomplete/older/unknown observation 기반 absence/rollback과 acceptance/receipt/recovery mutation이 0건이고, B의 조기/중복 confirmation, `받음` resend, unauthorized/duplicate/uncertain 반복, uncertain offer 재첨부, cross-batch·processing-delayed 혼합, RSS/AI/reselection이 0건이며 exact `못 받음` authorization 1회와 FIFO 10/10/20 lineage를 재현하는 것입니다.

[UNKNOWN] 실제 REST endpoint/request/response/pagination/rate-limit/permission/ordering contract, feedback scope merge/split, confirmation CronJob 주기·허용 기동 오차, “다음 성공 정규 batch” 판정, confirmation/offer/additional recovery UI, 장기 backlog 상한, conflict 수동 해소와 recovery retry/backoff는 SPK-03·04·06, WBS-04·05·07·09에서 사용자 승인으로 닫아야 합니다. 이 계획 승인은 Discord REST/message/resource·permission·credential, code·SQL·DB·scheduler·K3s 또는 recovery 실행을 승인한 것이 아닙니다.

### WBS-20 관측성·비용·보안 evidence 구현 상세

[FACT] 관련 Requirement는 `FR-024`, `NFR-REL-002~003`, `NFR-PERF-001`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-DQ-001~002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-REC-001`, `NFR-TIME-001`, `DR-013~014`, `VR-001·006~009·011·014`이고 관련 Architecture Decision은 `AD-02~06`, `AD-09~16`, `AD-22~23`, Data / Interface Design Decision은 `DDI-04~06`, `DDI-08·10`, `MIN-02~03·05`입니다. 외부 검증은 `SPK-04~06`, 상위 설계는 `WBS-03`, `WBS-08.A·B·E`, `WBS-11`, 선행 구현은 `WBS-12~19`, 후속 작업은 `WBS-21~26`, `WBS-28~30`입니다.

[FACT] WBS-20은 미래 구현 후보의 작업 경계를 정의합니다. 현재 승인으로 application code, DB migration·SQL/query, observability stack·exporter·dashboard·alert, billing 연동·invoice 처리, K3s resource/command 또는 운영 pause/resume를 생성하거나 변경하지 않습니다.

[FACT] 업무·평가의 source of truth는 PostgreSQL의 승인 domain record와 append-only evidence입니다. Structured log, metric, trace, dashboard와 alert는 파생 관측 수단이며 source record 없이 업무 성공·실패·수량·Hard Gate 판정을 만들지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-20.A | Source correlation | Domain/evidence reference와 batch/work/attempt/article/config/operation 관계 adapter | Telemetry-only 성공·수량·상태 생성 0건과 lineage test |
| WBS-20.B | Structured telemetry | Allowlist log/metric/trace event, safe opaque correlation, time/result semantics | Raw payload·Secret·identifier label·무제한 cardinality 0건 test |
| WBS-20.C | Operational diagnostics | 승인 catalog 기반 read-only query/projection과 여섯 관측 의미 | Missing/error→zero, attempt→logical result, recovery→current 합산 0건 test |
| WBS-20.D | Cost coverage evidence | 일곱 비용 scope register와 official/configured/usage/incident evidence | Scope/config/time coverage 누락의 confirmed/pass 전환 0건 test |
| WBS-20.E | User billing attestation | 기간·scope·확인 시각·판정·redacted reference 입력/조회 경계 | Billing API/scraping·invoice/account identifier 저장 0건 test |
| WBS-20.F | Gate·pause handoff | Evidence freshness/violation과 WBS-11 operation gate·manual resume handoff | Paid/account fallback·자동 resume·WBS-11 owner 중복 0건 test |
| WBS-20.G | Security·redaction | Structured field policy, cardinality/access/retention boundary, canary matrix | Repository부터 출력까지 Secret/민감 파생값 노출 0건 test |
| WBS-20.H | Alert·fault·rollback | Source-backed alert candidate, telemetry failure isolation, slice rollback | No-alert→healthy/pass·telemetry 장애의 domain mutation 0건 test |

#### WBS-20.A Source correlation

[FACT] WBS-20은 WBS-12~19의 승인 physical source를 조회·상관할 뿐 별도 telemetry 정본이나 중복 domain state를 만들지 않습니다. 실제 source table/column/query는 WBS-04/08 actual contract와 WBS-12 migration을 그대로 사용하고 구현자가 편의를 위해 임시 JSON/file/cache를 canonical source로 추가하지 않습니다.

| Correlation 축 | 보존할 관계 | 금지 집계 |
| --- | --- | --- |
| Scheduled batch/slot | Asia/Seoul 예정 일자·시작·target time | Retry/restart를 새 scheduled batch로 계산 |
| Logical work/attempt | Work key, claim/lease/fence, attempt lifecycle | Attempt 수를 logical result 수로 계산 |
| Article/candidate | Exact identity, observation과 최초 admission | Re-observation/parser retry를 신규 article로 계산 |
| Configuration/evidence | 적용 snapshot, contract/cost reference/version | 현재 default 또는 Secret 값으로 대체 |
| Domain operation | RSS·AI·delivery·Gateway·REST·recovery·evaluation·backup | 서로 다른 operation의 error/usage/state 혼합 |
| External attempt | Prepared/invocation/evidence와 safe external correlation | Response 부재로 성공/명시적 실패 추정 |
| Recovery source | Original result/attempt와 recovery work/delivery | Recovery를 current 수량·정시 성공으로 합산 |

[INFERENCE] 파생 telemetry에는 stable internal opaque reference 또는 제한된 safe correlation만 전달합니다. 상세 조사는 권한 있는 source lookup으로 수행하며 article link/title/summary, Discord user/message identifier와 전체 external request/response를 correlation label로 복제하지 않습니다.

[FACT] `operational_event`는 모든 log를 복사하는 저장소가 아닙니다. 비용 불명/위반과 pause/resume, backup gap/failure, restore 검증/재개 승인, contract/credential mismatch 등 사람의 확인·승인·운영 전환이 필요한 사건만 source evidence를 참조해 기록합니다.

#### WBS-20.B Structured telemetry

| Allowlist 범주 | 허용 내용 | 제외 내용 |
| --- | --- | --- |
| Identity/correlation | 비민감 internal reference, role, work/attempt kind | Credential, token, webhook URL, interaction secret |
| State/reason | 승인 state, typed reason, gate decision | Raw exception/header/body의 민감값 |
| Time | Source/observation instant, duration, clock/time-source 표시 | 비교 불가 문자열을 ordering 근거로 사용 |
| Quantity | Candidate/attempt/item count와 coverage | Article content/link·user ID를 metric label로 사용 |
| External result | Safe endpoint/status/error/limit category와 redacted reference | Authorization/cookie/전체 request-response payload |
| Version | Configuration/contract/policy/image revision reference | Secret/hash/credential fingerprint 원값 |

[INFERENCE] Log/metric/trace producer는 자유형 context dictionary보다 승인 structured field allowlist를 사용합니다. 추가 field·label은 review와 cardinality/redaction test를 거쳐야 하며 library/SDK의 자동 request/response logging과 telemetry export도 같은 경계를 적용합니다.

[FACT] 외부 시각, DB time, application observation time과 예정 KST 시각은 서로 다른 field/source로 보존합니다. 비교 불가 또는 clock trust 부족이면 ordering·duration·정시 목표를 충족한 것으로 계산하지 않습니다.

#### WBS-20.C Operational diagnostics

| 관측 의미 | 적용 조건 | 금지 해석 |
| --- | --- | --- |
| `zero` | 완전한 정의 범위와 source coverage에서 실제 count 0 | Query 실패·범위 미확정·source 누락 |
| `not_executed` | 예정 work 미실행 evidence 존재 | 정상 신규 0건·성공 |
| `incomplete` | 시작했으나 terminal completion 부재 | 성공·명시적 실패·0건 |
| `not_applicable` | 정의상 대상이 아닌 범위 | Source 부족으로 측정 불가 |
| `not_measurable` | 필수 evidence coverage/비교 가능성 부족 | 0·pass·fail 자동 확정 |
| `unknown` | 상태·원인을 신뢰 가능하게 분류 불가 | 일반 오류·정상·무제한 retry |

[FACT] Diagnostic query/projection은 WBS-08.E의 승인 metric definition/version, scope/cutoff, logical subject, numerator/denominator, exclusion, unit/precision과 measurability를 읽습니다. WBS-20이 새로운 품질 threshold·Gate 산식·분모/제외 규칙을 정하지 않습니다.

[FACT] Retry·external attempt·recovery attempt와 usage/latency는 별도로 관측하되 article/candidate/selection result/successful delivery/original batch 수에 합산하지 않습니다. Logical key와 attempt key를 구분하지 못하거나 source coverage를 입증하지 못하면 수치를 출력하지 않고 `not_measurable` 또는 query/definition 오류로 처리합니다.

[FACT] WBS-20은 6개 Hard Gate 계산에 필요한 source lineage와 coverage diagnostic을 제공하지만 immutable `pass/fail/not_measurable` result는 만들지 않습니다. WBS-22가 명시적 evaluation request로 snapshot/result를 만들고 WBS-30이 운영월과 사용자 billing coverage를 포함한 최종 후보 판정을 수행합니다.

#### WBS-20.D Cost coverage evidence

| 비용 scope | 필요한 사전/운영 evidence | 누락·불명확 시 경계 |
| --- | --- | --- |
| AI provider | Exact account/project/model/path의 official free, non-billable config, quota/usage | AI 신규 invocation 차단, provider/account fallback 금지 |
| Discord | Application/Gateway/REST/interaction/delivery의 비용·quota 조건 | 영향 Discord operation 활성화/호출 금지 |
| K3s runtime/host | 기존 host 사용과 추가 월 비용 범위 | Production workload 활성화 보류 |
| PostgreSQL/PV | DB/volume 용량·운영 비용 범위 | 신규 production data path 보류 |
| Backup storage/transfer | 저장·보관·전송·restore rehearsal 비용 | Backup/readiness 완료 금지 |
| Image registry | Image 저장/pull/traffic 조건 | 배포 준비 차단 |
| Scheduler/monitoring | Cron/listener/log/metric/alert 도구 비용 | 유료 도구 선택·운영 활성화 금지 |

[FACT] 비용 evidence는 official free condition, non-billable configuration check, usage/quota evidence, user monthly billing confirmation과 cost incident evidence를 구분합니다. 하나가 다른 종류를 대신하지 않으며 configuration boolean이나 sandbox 성공만으로 실제 월 비용 0원을 만들지 않습니다.

[INFERENCE] 하나의 evidence가 여러 scope를 덮더라도 exact environment/configuration, 비민감 account/project reference, scope, 확인 시각, evidence kind, 판정, 확인자와 유효성/재검증 조건이 식별돼야 합니다. Scope·기간·configuration coverage가 불완전하면 confirmed 또는 Hard Gate pass 후보로 바꾸지 않습니다.

[FACT] Free quota 소진, rate limit, 인증/권한/network 오류와 실제 비용 위반은 서로 다른 typed cause입니다. Quota 소진은 영향 free operation을 차단하지만 실제 비용 발생으로 기록하지 않고, 비용 위반은 호출 성공 여부와 무관하게 독립 source evidence와 incident를 보존합니다.

#### WBS-20.E User billing attestation

[FACT] 실제 월별 billing/usage는 사용자가 직접 확인합니다. WBS-20은 billing API, invoice download/scraping 또는 외부 account 자동 조회를 구현하지 않습니다.

[FACT] 시스템에는 확인 대상 billing month/기간, 일곱 scope coverage, 확인 시각, 확인자, `0원/불명/위반` 판정과 비민감 redacted evidence reference만 보존합니다. Invoice 원문·credential·billing account identifier·결제수단 정보는 Repository, DB, backup, log/metric/trace, AI input, Discord output에 저장하지 않습니다.

[FACT] 첫 운영월이 끝나지 않아 월별 결과가 존재할 수 없는 사실만으로 사전 승인 scope를 자동 차단하지 않지만 비용 Hard Gate `pass`나 실제 0원으로 기록하지 않습니다. 기간 종료 뒤 확인이 누락되거나 evaluation 기간과 billing coverage가 맞지 않으면 최종 비용 판정은 `not_measurable`입니다.

[INFERENCE] 사용자 attestation 입력은 다른 source record를 수정하지 않는 append-only evidence와 정정/대체 관계로 구현해야 합니다. 새 확인으로 과거 비용 위반·미확인 기간을 삭제하거나 pass로 소급 변경하지 않습니다.

#### WBS-20.F Gate·pause handoff

[FACT] WBS-20은 비용/contract/security evidence의 유효·stale·불명·위반과 영향 operation/scope를 WBS-11 gate에 제공합니다. Invocation 허용/차단, pause/resume의 canonical owner를 새로 만들거나 WBS-11 상태를 telemetry/dashboard에서 직접 변경하지 않습니다.

| Evidence 상황 | WBS-20 handoff | 금지 동작 |
| --- | --- | --- |
| 사전 evidence 유효 | Exact evidence/version/coverage 제공 | 월별 결과까지 자동 pass 생성 |
| Evidence stale/mismatch/불명 | 영향 scope와 차단 reason 제공 | 다른 credential/account/provider로 전환 |
| Free quota 소진 | Reset/reopen 불명 상태와 영향 호출 제공 | 유료 quota·provider fallback |
| 실제 비용 위반 | Incident와 영향 production scope 제공 | 일시 오류로 축소·과거 evidence 삭제 |
| Source/DB trust 불명 | Gate가 판단할 신뢰 불가 evidence 제공 | Telemetry 값만으로 resume |

[FACT] Resume는 자동 수행하지 않습니다. 적용 configuration, contract/cost/security evidence, credential, DB/restore trust와 in-flight uncertainty를 재검증하고 필요한 사용자 수동 승인 `operational_event`가 연결된 뒤 WBS-11이 해당 scope만 재활성화합니다.

#### WBS-20.G Security·redaction

[INFERENCE] Redaction은 사후 문자열 치환이 아니라 raw credential/header/body를 telemetry API에 전달하지 않는 구조적 allowlist를 우선합니다. 예외와 third-party SDK가 만드는 log/trace도 테스트에서 검사하고, 민감값이 포함될 수 있는 자유형 error/context는 안전한 typed category와 source reference로 대체합니다.

[FACT] Metric label에는 article link/title/summary, Discord guild/channel/user/message identifier, external request ID 원문, account/project 식별자, credential/Secret/hash를 넣지 않습니다. High-cardinality subject는 bounded dimension과 opaque reference로 제한하고 상세 조회는 승인 access path를 사용합니다.

[INFERENCE] Canary Secret test는 Repository/image, environment/configuration, command argument, DB/backup, log/metric/trace, exception/test snapshot, AI request와 Discord output 전 범위를 대상으로 해야 합니다. 실제 canary 형식·도구·retention/access policy는 승인 전 확정하지 않습니다.

#### WBS-20.H Alert·fault·rollback

| Alert candidate | Source condition | Alert가 증명하지 못하는 것 |
| --- | --- | --- |
| Scheduled work 미실행/미완료 | Batch/work source와 관측 기한 | 신규 0건·pipeline 성공/실패 확정 |
| External error/quota/rate limit | Domain attempt와 영향 scope | Retry·유료 fallback 승인 |
| Discord uncertainty/backlog | Delivery/recovery source state | Original 수락·명시적 미수락 |
| Backup failure/gap | Backup run과 승인 gap 기준 | Restore 가능·outbound resume |
| Cost evidence 불명/위반 | Cost scope/coverage/source evidence | 비용 0원·Hard Gate pass |
| DB trust/integrity | DB/restore validation evidence | Domain source 수정·삭제 |

[FACT] Alert는 condition, observation time, affected scope, severity/action owner와 source reference를 가져야 합니다. Alert 발송 성공/실패 또는 alert 부재는 원래 source condition의 발생·해결·업무 성공·Hard Gate 결과를 변경하지 않습니다.

[INFERENCE] Telemetry exporter, metric query, dashboard 또는 alert가 실패해도 domain transaction과 external invocation state를 수정하거나 재실행하지 않습니다. Source evidence가 성공적으로 commit된 경우 파생 telemetry만 안전하게 재생성할 수 있고, source commit이 불명확하면 telemetry로 성공을 복구하지 않습니다.

[INFERENCE] Rollback은 source correlation adapter, telemetry producer, diagnostic query, cost evidence/attestation input, gate handoff, redaction 검사와 alert adapter를 독립적으로 비활성화할 수 있어야 합니다. 이미 commit된 domain/evidence, cost incident, user attestation과 operational event를 rollback 명목으로 삭제·수정하지 않습니다.

[INFERENCE] WBS-20 완료 기준은 telemetry-only 성공/수량/Gate, missing/error→zero, attempt/recovery 중복 집계, scope/기간 coverage 없는 비용 confirmed/pass, paid/account/provider fallback, 자동 resume, alert 부재의 healthy/pass가 0건이고 일곱 비용 scope와 사용자 billing attestation lineage가 완결되며 Secret·민감 identifier·고카디널리티 label 노출이 0건인 것입니다.

[UNKNOWN] 실제 observability stack/exporter/dashboard/alert channel, metric/query name과 label allowlist/cardinality budget, trace sampling, timestamp precision/clock synchronization, telemetry retention/access, cost evidence 유효기간·재검증 trigger, 사용자 billing 입력 interface·확인일·redacted reference 형식, 기존 host/storage/registry/monitoring의 추가 비용 증명과 incident escalation은 SPK-04~06, WBS-04·08·09·11·21·26·28~30에서 사용자 승인으로 닫아야 합니다. 이 계획 승인은 실제 도구·query·dashboard·alert·billing 연동·K3s 설정·비용 0원 또는 운영 활성화를 승인한 것이 아닙니다.

### WBS-21 Backup/restore 및 recovery gate 구현 상세

[FACT] 관련 Requirement는 `FR-024`, `NFR-REL-001~003`, `NFR-COST-001`, `NFR-DQ-002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-REC-001`, `NFR-TIME-001`, `DR-013~014`, `VR-004~005·009·011~019`이고 관련 Architecture Decision은 `AD-02~03`, `AD-05`, `AD-08~10`, `AD-13`, `AD-22`, Data / Interface Design Decision은 `DDI-01~06`, `DDI-08~10`, `MIN-02~03·05~06·08`입니다. 외부 검증은 `SPK-04~06`, 상위 설계는 `WBS-03`, `WBS-05`, `WBS-08.C·D`, 선행 구현은 `WBS-11~13`, `WBS-20`, 후속 검증·배포는 `WBS-23~25`, `WBS-27~29`입니다.

[FACT] WBS-21은 미래 구현 후보의 작업 경계를 정의합니다. 현재 승인으로 application code, DB migration·SQL/query, backup/restore command·artifact, K3s workload/storage/schedule, production data, Discord REST 또는 operation pause/resume를 생성하거나 변경하지 않습니다.

[FACT] Backup artifact 생성, artifact integrity/readability 확인, isolated restoreability 검증, production restore와 general outbound resume는 서로 다른 lifecycle·evidence·승인 단계입니다. 앞 단계 성공만으로 다음 단계를 자동 시작하거나 성공으로 projection하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-21.A | Protection inventory | MVP-A DB/schema/migration/role 보호·제외·재구성 disposition | “전체 DB” 추정·필수 source 누락·Secret 포함 0건 review/test |
| WBS-21.B | Backup admission·consistency | Work/gate, exact source, consistency point, run lifecycle | Request/start/file 존재의 success 전환·inconsistent artifact 인정 0건 test |
| WBS-21.C | Artifact·failure domain | 고유 immutable artifact, integrity/readability와 independent storage evidence | Same Pod/PVC/node/backend-only 인정·overwrite/fallback 0건 test |
| WBS-21.D | Lifecycle·gap·cost | Retry/history, valid backup gap, RPO/RTO measurement, retention decision handoff | 과거 실패 삭제·무측정 목표·gap 초과 운영·무승인 삭제 0건 test |
| WBS-21.E | Isolated restore | Production 분리 target, read-only source artifact, no-prod credential/egress | Production mutation·external invocation·artifact 변경 0건 test |
| WBS-21.F | Restore validation | Schema/data/ledger/delivery/feedback/operation/evaluation invariant report | Exit 0/table 존재 기반 restoreable 판정 0건과 corruption test |
| WBS-21.G | Loss-window reconciliation | Stale lease/fence, missing evidence, external-effect uncertainty, no historical backfill | DB 없음→호출 없음·자동 replay/backfill·accepted resend 0건 test |
| WBS-21.H | Production restore·resume gate | Production approval, restricted feedback REST, new backup, final resume approval | 단계 자동 진입·restricted approval의 general 재사용·자동 resume 0건 test |
| WBS-21.I | Security·fault·rollback | Least privilege, redaction, partial failure isolation, implementation rollback | Secret 노출·partial target 연결·history/evidence 삭제 0건 test |

#### WBS-21.A Protection inventory

[FACT] Backup 보호 범위는 승인된 MVP-A PostgreSQL domain record와 Raw RSS, work/attempt, configuration metadata, external/acceptance/feedback/recovery/operational/evaluation evidence 및 이를 해석하는 schema/migration state입니다. 실제 K3s Secret 원값, 외부 account 상태, container image와 Git repository 자체는 DB backup artifact가 대체하지 않습니다.

[INFERENCE] Database/schema/extension/role/privilege 중 artifact에 포함할 항목과 별도 재구성 절차가 소유할 항목을 disposition register에 하나씩 연결합니다. “전체 DB” 또는 tool default만으로 누락 없는 보호를 추정하지 않고 excluded/deferred/reconstructed 항목마다 owner와 검증을 둡니다.

[FACT] Discord/AI/RSS의 비민감 logical reference와 이미 기록된 external evidence는 보호하지만 외부 Discord message나 provider response를 backup/restore로 다시 생성하지 않습니다. Credential, Authorization, interaction/backup secret과 불필요한 identifier는 artifact metadata·command·telemetry에 포함하지 않습니다.

#### WBS-21.B Backup admission·consistency

| Admission/gate | 필수 조건 | 닫힘·불명확할 때 |
| --- | --- | --- |
| Work authority | Exact backup work, 유효 claim/lease/fence와 trigger | Invocation/성공 기록 금지 |
| Source identity | PostgreSQL instance/database/environment와 configuration | 다른 DB/default target fallback 금지 |
| DB/tool contract | 승인 tool/version, consistency capability, schema disposition | Best-effort export로 대체 금지 |
| Cost/storage | 승인 failure domain, capacity, 0원 evidence와 credential | 임시 local/PVC·유료 storage fallback 금지 |
| Security | 최소 DB read/export와 target write 권한 | Application/AI/Discord credential 주입 금지 |

[FACT] Backup 중 동시 mutation이 가능하면 tool이 제공하는 일관성 계약과 source DB position/reference를 evidence로 남깁니다. 동일 consistency point에서 schema/data 관계가 복원된다는 근거가 없으면 artifact 생성이나 command exit 0만으로 성공을 판정하지 않습니다.

| Lifecycle | 의미 | 자동으로 만들 수 없는 상태 |
| --- | --- | --- |
| `requested/eligible` | Trigger와 gate가 유효한 work | `started/artifact_created` |
| `started` | 실제 backup invocation 시작 | Success/integrity/restoreability |
| `artifact_created` | 고유 출력 artifact 관찰 | Integrity/readability/restoreable |
| `integrity_verified` | 승인 기본 integrity/readability 통과 | Full restore/domain recovery |
| `failed/inconclusive` | 실패 또는 evidence 불충분 | 이전 실패 삭제·success |
| `restore_rehearsed` | WBS-21.E~F 결과와 exact artifact 연결 | Production restore/resume |

#### WBS-21.C Artifact·failure domain

[FACT] Artifact identity는 backup run, source configuration/database, consistency point, schema/migration reference, tool/format version, creation time, safe size/integrity reference와 storage location evidence를 구분할 수 있어야 합니다. 실제 hash/format/compression/encryption은 SPK-05와 physical contract 승인 전 확정하지 않습니다.

[FACT] Retry와 새 run은 새 artifact identity/path를 사용하고 이전 artifact와 성공·실패 evidence를 덮어쓰지 않습니다. 이름 충돌, partial output 또는 기존 artifact 존재 시 자동 overwrite하거나 다른 artifact를 성공 결과로 fallback하지 않습니다.

| Failure-domain 확인 | 최소 통과 조건 | 불인정 조건 |
| --- | --- | --- |
| Pod | PostgreSQL Pod 삭제/재생성 뒤 artifact 생존 | 같은 Pod filesystem만 사용 |
| PVC/volume | 원본 PVC 손상/삭제와 독립 | 같은 PVC 내부 복사 |
| Node/disk | Node/disk 상실과 독립 | 같은 node의 같은 disk |
| Storage backend | 원본 volume backend 장애와 독립 | 이름만 다른 동일 장애 경로 |
| Access | Source workload가 backup을 임의 삭제하기 어려운 최소 권한 | Broad overwrite/delete 권한 |

[FACT] 별도 directory, 다른 filename 또는 별도 PVC라는 이름만으로 failure-domain 독립성을 확정하지 않습니다. SPK-04 topology와 SPK-05 artifact survival experiment가 실제 장애 가정에 대해 pass해야 합니다.

#### WBS-21.D Lifecycle·gap·cost

[FACT] Backup 실패는 run/attempt, 원인, 시각, 최신 유효 artifact, gap과 영향 scope를 append-only로 기록합니다. Retry가 성공해도 원래 실패와 gap evidence를 삭제·성공으로 변경하지 않습니다.

[FACT] Backup interval은 RPO가 아니고 artifact 생성 소요만 RTO가 아닙니다. RPO는 장애 시 허용 data loss와 실제 backup/restore consistency 차이를, RTO는 isolated restore 시작부터 schema/data/domain validation·reconciliation·resume 승인 준비까지를 SPK-04/05에서 실측한 뒤 사용자 승인합니다.

[FACT] 승인 allowed gap 안에서는 backup work만 승인 retry policy로 재시도할 수 있습니다. Gap을 넘으면 WBS-11에 영향 신규 pipeline/outbound 차단을 handoff하고 정상 신규 0건·정상 운영으로 표시하지 않습니다. 새 artifact 하나가 다시 생성됐다는 이유만으로 gate를 열지 않습니다.

[INFERENCE] Retention/cleanup은 RPO/RTO, investigation/evaluation 보존, capacity 증가율, failure-domain과 추가 월 비용 0원을 함께 검토해 사용자 승인합니다. 승인 전 자동 삭제/lifecycle을 구현하지 않고 무제한 보존을 무료·안전하다고 추정하지 않습니다.

#### WBS-21.E Isolated restore

[FACT] 정기 restore rehearsal target은 production PostgreSQL과 다른 명시적 database/instance 경계입니다. Production application/RSS/AI/Discord credential을 주입하지 않고 외부 API egress를 허용하지 않으며 production workload가 해당 target에 연결할 수 없게 합니다.

[FACT] 선택 artifact는 read-only source로 취급합니다. Rehearsal 과정과 결과가 source artifact 또는 production record를 수정하지 않고 partial restore target은 격리 상태를 유지해 일반 runtime이 연결하지 못하게 합니다.

[INFERENCE] Rehearsal admission은 exact verified artifact, integrity evidence, tool/version, isolated target identity, 예상 schema/image compatibility, no-production-credential/egress와 비용 evidence를 invocation 직전에 재검증합니다. 조건 불일치 시 다른 artifact/tool/target으로 자동 fallback하지 않습니다.

#### WBS-21.F Restore validation

| 검증 영역 | 최소 대조 | 금지 shortcut |
| --- | --- | --- |
| Artifact/schema | Integrity, schema/migration/tool/image compatibility, required extension/role disposition | Exit 0·table 존재만으로 호환 판정 |
| Data integrity | PK/FK/uniqueness/append-only, 승인 count/digest/invariant | 일부 sample만으로 전체 완전성 추정 |
| Identity/input | Raw RSS/observation, exact article identity, candidate admission | 누락 record를 현재 RSS로 재생성 |
| AI/selection | Attempt/analysis/finalization, immutable result/item/handoff | 현재 provider/policy로 재계산 |
| Work ledger | Scheduled batch, work/attempt, claim/lease/fence, prepared/invocation | 복원 lease/token을 현재 권한으로 처리 |
| Delivery | Set/segment/message/item mapping, external/acceptance evidence | Mapping 없는 accepted/failed 추정 |
| Feedback/recovery | Gateway/REST history, projection, interaction/case/event | Mutable projection만으로 history 완전 판정 |
| Operations/evaluation | Config/contract/cost, backup/restore, immutable evaluation | 기존 snapshot/result 재작성 |

[FACT] Restore command exit code 0은 실행 결과일 뿐 application compatibility, DB/domain integrity, restoreability, RPO/RTO 충족 또는 outbound resume을 뜻하지 않습니다. 각 검증 결과는 selected artifact와 restore attempt에 연결하고 operational event나 success state에 내용을 복제해 대체하지 않습니다.

#### WBS-21.G Loss-window reconciliation

[FACT] Restore 시작 전 일반 workload의 신규 claim, prepared→invocation transition과 외부 호출을 차단하고 기존 worker가 종료·격리됐음을 확인합니다. 복원된 lease/token을 재사용하지 않으며 새 fencing epoch/token 설정은 승인 WBS-05 physical contract에 따라 별도 검증합니다.

[FACT] Artifact consistency point 이후 DB evidence가 손실됐더라도 외부 AI/Discord invocation 가능성이 있으면 “DB에 없음”을 “호출하지 않음”으로 해석하지 않습니다. 영향 scope를 `external_effect_uncertain` 또는 `not_measurable`로 유지하고 lease 만료·process 종료만으로 재호출하지 않습니다.

| Loss-window 상태 | 허용 처리 | 금지 동작 |
| --- | --- | --- |
| Historical slot record 부재 | Deterministic identity와 completeness에 따른 ledger-only/not-measurable | 과거 RSS/AI/delivery 시작 |
| Work 시작 근거 없고 ledger 완전 | `not_executed` 후보 | 정상 신규 0건 처리 |
| Work/attempt 일부 존재 | `incomplete` 또는 저장 state/uncertainty 유지 | 처음부터 자동 replay |
| Invocation 가능성/evidence gap | Exact scope `external_effect_uncertain` | 미호출·explicit failure 추정 |
| Source completeness 불명 | `not_measurable` | Count 0·Hard Gate pass |

[FACT] 손실된 과거 scheduled slot을 현재 RSS 수집·AI 분석·selection·Discord delivery로 backfill하지 않습니다. Restore 후 첫 정상 processing은 최종 승인 뒤 현재 또는 다음 scheduled slot만 대상으로 합니다.

[FACT] 복원 delivery는 original selection, physical mapping/item scope, response/message ID, receipt와 recovery evidence를 대조합니다. Accepted/received item을 재전송하지 않고 uncertain item을 confirmed non-acceptance로 바꾸거나 feedback REST 결과로 server acceptance를 만들지 않습니다.

#### WBS-21.H Production restore·resume gate

| 단계 | 승인·evidence | 자동 다음 단계 |
| --- | --- | --- |
| Isolated rehearsal | 격리 restore와 schema/data/domain 검증 | Production restore 금지 |
| Production restore approval | Exact 장애/손실 scope, artifact, 영향, 일반 outbound closed와 사용자 승인 | 실행 금지 |
| Production restore execution | 제한 operator, target, attempt/result와 loss window | Reconciliation/resume 금지 |
| Restricted feedback reconciliation | DB trust 뒤 exact WBS-19.A request/scope/credential에 대한 별도 사용자 승인 | 일반 RSS/AI/delivery/recovery 금지 |
| New backup/readiness | 복원 상태의 새 artifact integrity와 승인 restoreability·cost/contract/security evidence | Resume 금지 |
| Final resume | External uncertainty·feedback/recovery 결과와 사용자 최종 scope 승인 | 승인 scope만 WBS-11에서 활성화 |

[FACT] Production restore는 실제 장애/손상 범위와 artifact를 특정한 별도 사용자 승인 없이는 시작하지 않습니다. Restricted Discord REST 승인은 general outbound 승인으로 재사용하지 않으며 reconciliation 실패/unknown을 숨기지 않습니다.

[FACT] 새 backup 생성, restore success, process 정상화 또는 alert 해제만으로 자동 resume하지 않습니다. DB trust, ledger/external-effect reconciliation, 필요한 feedback 대조, backup protection, configuration/contract/cost/security evidence와 사용자 final approval가 모두 있어야 합니다.

#### WBS-21.I Security·fault·rollback

[FACT] Backup workload에는 승인 DB read/export와 target artifact write에 필요한 최소 credential만 주입합니다. Restore operator와 rehearsal target도 역할을 분리하고 application/RSS/AI/Discord credential, broad artifact delete 권한과 production access를 제공하지 않습니다.

[INFERENCE] Command argument, environment, artifact metadata/content, DB/backup, log/metric/trace, exception과 test output에서 DB password, backup access secret, Authorization 또는 민감 identifier가 노출되지 않는지 WBS-20 canary/redaction 경계로 검증합니다.

[INFERENCE] Partial backup/restore, integrity mismatch, storage loss, permission failure, timeout, process crash와 commit-unknown은 기존 verified artifact/source evidence를 보존한 채 fail-closed로 종료합니다. 자동 fallback, partial target의 일반 연결, 성공 projection 또는 production mutation을 허용하지 않습니다.

[INFERENCE] Rollback은 inventory/adapter, backup admission/run, artifact verifier, gap observer, isolated restore runner, validation, loss-window report와 approval gate handoff를 독립 비활성화할 수 있어야 합니다. 이미 생성된 artifact/run/restore/validation/approval evidence는 rollback 명목으로 삭제·수정하지 않습니다.

[INFERENCE] WBS-21 완료 기준은 보호 누락, inconsistent/partial/file-only backup 성공, same failure-domain 인정, overwrite/fallback, 무측정 RPO/RTO, gap 초과 정상 운영, 무승인 retention 삭제, production rehearsal mutation, restored lease 재사용, DB 없음→미호출, historical backfill, 단계 자동 진입/auto-resume와 Secret 노출이 각각 0건이고 isolated restore의 schema/data/ledger/domain 검증과 measured recovery evidence가 완결되는 것입니다.

[UNKNOWN] Backup tool/format/version, database/schema/extension/role inventory, consistency point 표현, StorageClass/volume backend/failure domain, artifact storage/hash/compression/encryption, RPO/RTO/interval/allowed gap, capacity/retention/manual cleanup, isolated target/network, restore invariant query/count/digest, fencing reset과 restricted reconciliation gate는 SPK-04~06, WBS-04·05·08·09·20·27~29에서 사용자 승인으로 닫아야 합니다. 이 계획 승인은 실제 backup/restore 도구·artifact·schedule·storage·수치·retention·production restore·Discord REST·K3s 또는 resume를 승인한 것이 아닙니다.

### WBS-22 Evaluation runner 구현 상세

[FACT] 관련 Requirement는 `FR-017~024`, `NFR-REL-001~002`, `NFR-PERF-001`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-DQ-001~002`, `NFR-OBS-001~002`, `NFR-SEC-001`, `NFR-TIME-001`, `DR-010~013`, `VR-001·006~010·014`이고 관련 Architecture Decision은 `AD-02~03`, `AD-05`, `AD-10~12`, `AD-23`, Data / Interface Design Decision은 `DDI-04~05`, `DDI-08`, `MIN-02·05`입니다. 상위 설계는 `WBS-05`, `WBS-08.E~G`, 선행 구현은 `WBS-12`, `WBS-18~21`, feedback 대조 의존은 `WBS-19.A`, 후속 검증은 `WBS-23~26`, `WBS-30`입니다.

[FACT] WBS-22는 미래 구현 후보의 작업 경계를 정의합니다. 현재 승인으로 application code, DB migration·SQL/query, 실제 evaluation/snapshot/result/report, Discord REST·AI 호출 또는 운영 source mutation을 생성하거나 변경하지 않습니다.

[FACT] Evaluation은 사용자의 명시적 요청으로만 시작합니다. Batch/day 종료, late evidence 도착, monitoring schedule 또는 source 변경을 trigger로 자동 evaluation을 만들지 않으며, 결과가 deployment·MVP-B 진입·프로젝트 종료를 자동 실행하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-22.A | Request admission | Explicit request identity, replay dedupe, 새 요청/work 분리 | 자동·중복 logical work/snapshot 0건과 concurrency test |
| WBS-22.B | Scope validation | Batch/day/validation-period validator와 허용 interpretation | 미실행 slot 누락·batch/day 전체 통과 결론·invalid 실행 0건 test |
| WBS-22.C | Reconciliation handoff | Feedback 필요성·exact scope와 WBS-19.A request/fixed result 경계 | Runner 직접 REST·scope 확대·실패→feedback 0/pass 0건 test |
| WBS-22.D | Cutoff·consistent read | `as_of_at`, source high-watermark/fixed reference와 일관된 read | Cutoff 이동·late 소급·torn source 선택 0건 test |
| WBS-22.E | Compact manifest | Definition/scheme version, source kind/count/digest와 ordering contract | Payload·전체 ID 복사·scheme 없는 digest 0건 test |
| WBS-22.F | Metric calculation | 승인 catalog의 subject·분자/분모·제외·단위·measurability 적용 | 임의 threshold/분모·attempt 중복·missing→zero 0건 test |
| WBS-22.G | Typed results | 여섯 result kind, sample/quality/service/Gate/final 의미 분리 | Unknown kind·Gate 전파·false pass·batch/day 종합 결론 0건 test |
| WBS-22.H | Atomic finalization | Attempt, manifest, snapshot와 complete typed results 원자 확정 | 실패/partial snapshot-result 공개·retry overwrite 0건 test |
| WBS-22.I | Report projection | Canonical result의 read-only complete projection/export | 재계산·실패/미달/not-measurable/exclusion 누락 0건 test |
| WBS-22.J | Security·resource·rollback | Read-only DB role, no external credential, execution budget와 slice rollback | External call/source mutation·Secret/payload copy·기존 결과 수정 0건 test |

#### WBS-22.A Request admission

[FACT] Evaluation request는 승인 사용자의 명시적 action과 request identity, scope kind, exact batch IDs 또는 기간, `as_of_at`, metric definition version과 input manifest scheme version을 요구합니다. 실제 command/UI/field는 WBS-04/08 physical contract 승인 전 확정하지 않습니다.

[FACT] 같은 request identity의 전달 replay와 concurrent duplicate는 하나의 logical `work_item(type=evaluation)`으로 수렴하고 snapshot을 중복 생성하지 않습니다. 사용자가 동일 scope/cutoff를 새 request identity로 다시 명시하면 새 logical work·attempt·immutable snapshot을 만들며 기존 snapshot을 갱신하지 않습니다.

[INFERENCE] 존재하지 않는 batch, scope와 batch ID 불일치, 필수 version 누락, 허용되지 않은 interpretation 또는 미래/진행 중 범위의 미승인 요청은 실행 전 validation error로 거부합니다. Invalid request를 source 부족이나 successful-not-measurable evaluation으로 바꾸지 않습니다.

#### WBS-22.B Scope validation

| Scope | 입력 경계 | 허용 interpretation | 금지 interpretation |
| --- | --- | --- | --- |
| Single batch | 지정 scheduled batch ID 하나와 cutoff 아래 evidence | 해당 batch 운영 진단 | MVP-A 전체 품질 통과/실패 |
| Asia/Seoul day | 해당 KST 일자의 예정 batch ID 두 개를 명시 | 일별 운영 진단과 미실행/incomplete 포함 | 미실행 slot 제외·전체 통과/실패 |
| Validation period | 승인 batch 범위/IDs와 기간 끝 `as_of_at` | Sample, 6 Gate, quality/service, 통과 후보 해석 | 자동 최종 승인·deployment/MVP-B 시작 |

[FACT] Validation-period scope만 최소 2주, 20개 예정 batch, 50개 후보와 최대 4주 판정 불충분 경계를 사용합니다. 세 조건을 각각 판정하고 하나라도 부족하면 전체 품질 결론은 `판정 불충분`으로 유지하되 이미 확인된 Hard Gate 위반·품질/서비스 관측을 숨기지 않습니다.

#### WBS-22.C Reconciliation handoff

[FACT] Feedback 의존 metric에 reconciliation이 필요하면 calculation attempt 전에 exact evaluation scope/cutoff를 확정하고 WBS-19.A의 bounded internal request를 등록합니다. Evaluation runner는 Discord REST를 직접 호출하거나 request scope를 확대하거나 feedback state를 수정하지 않습니다.

[FACT] Reconciliation이 성공하면 cutoff 아래 고정 snapshot reference와 completeness를 입력으로 사용합니다. 차단·실패·partial·stale·unknown이면 해당 evidence/reference와 대조 불가 이유를 manifest에 연결하고 feedback 의존 결과를 반응 없음, 실제 0 또는 Gate `pass`로 변경하지 않습니다.

[FACT] Calculation 시작 뒤 새로운 reconciliation 결과가 도착해도 현재 evaluation에 소급 포함하지 않습니다. 사용자가 새 cutoff로 새 evaluation을 요청해야 새 evidence를 반영할 수 있습니다.

#### WBS-22.D Cutoff·consistent read

[FACT] `as_of_at`은 사용자가 승인한 관측 cutoff이고 runner가 자동으로 뒤로 이동시키지 않습니다. Source별 high-watermark 또는 fixed reconciliation reference는 실제로 읽힌 저장 범위를 고정합니다.

[FACT] 외부 event 발생 시각이 cutoff 이전이어도 cutoff/high-watermark 뒤에 저장된 late evidence는 기존 snapshot에 넣지 않습니다. 반대로 source record의 저장 시각만으로 외부 발생/수락/정시 의미를 재판정하지 않습니다.

[INFERENCE] Source별 high-watermark와 선택 행은 하나의 일관된 read 경계에서 확정하고, 서로 다른 시점의 source view를 조합한 torn snapshot을 성공으로 finalize하지 않습니다. 실제 transaction isolation/snapshot/lock 방식은 승인 physical contract를 사용합니다.

[FACT] 계산 source는 scheduled batch, work/attempt, RSS/observation/article/candidate, AI attempt/analysis, immutable selection result/item, delivery mapping/attempt/acceptance, cutoff 아래 Gateway/REST/feedback/recovery, configuration/contract/cost, backup/restore와 필요한 review evidence입니다. Log/metric/dashboard/alert를 누락 source의 대체 정본으로 사용하지 않습니다.

#### WBS-22.E Compact manifest

[FACT] 성공 input manifest는 evaluation scope/batch IDs, `as_of_at`, successful work attempt, `metric_definition_version`, `input_manifest_scheme_version`과 source별 kind, high-watermark/fixed reference, 선택 행 수, deterministic digest를 포함합니다.

[FACT] Manifest scheme은 source projection, canonical serialization과 ordering의 해석 version입니다. Digest만 저장하고 projection/order/version을 생략해 재현 가능하다고 주장하지 않으며 실제 algorithm은 승인 전 확정하지 않습니다.

[FACT] Manifest에 원본 RSS/AI/delivery/feedback payload나 전체 source row/ID 목록을 복사하지 않습니다. 미래 retention 뒤 기존 manifest/result를 보존하되 row-level 재계산 가능 여부를 별도로 표시하고 payload 복제로 retention을 우회하지 않습니다.

[INFERENCE] 동일 scope/cutoff/definition/scheme의 새 evaluation은 원본 source가 남아 있는 동안 source별 count/digest/result를 이전 snapshot과 비교합니다. 불일치는 기존 결과를 수정하지 않고 새 결과와 investigation evidence로 보존합니다.

#### WBS-22.F Metric calculation

[FACT] Calculator는 WBS-08.E의 승인 metric catalog에서 definition version, scope/time basis, logical subject/key, read-only source lineage, numerator/denominator, exclusion/exception, unit/precision과 measurability 규칙을 읽습니다. 구현자가 새 threshold, 분모, 제외 또는 rounding을 임의로 만들지 않습니다.

[FACT] 실제 zero, denominator zero, not applicable, source/evidence gap, not measurable, unknown과 execution error를 구분합니다. Missing row/query failure/권한 문제/불완전 reconciliation을 수치 0이나 성공으로 coercion하지 않습니다.

[FACT] Retry, parser/external/delivery attempt, physical message, representative/system message와 recovery invocation은 승인 logical subject count와 분리합니다. Exact one-time resend exception은 source identity와 authorization이 완결된 경우에만 중복 전달 Gate의 승인 제외로 사용합니다.

[UNKNOWN] Metric physical registry, ratio/duration/currency type, precision/rounding, calculation execution limit과 query plan은 WBS-04/08/09/22 readiness에서 확정해야 합니다.

#### WBS-22.G Typed results

[FACT] 성공 snapshot 아래 canonical result는 `sample_adequacy`, `quality_review`, `hard_gate`, `quality_metric`, `service_metric`, `final_interpretation` 여섯 `result_kind`만 사용합니다. 일곱 번째 종합 kind, 상시 metric source 또는 MVP-B 월별 Insight entity를 추가하지 않습니다.

[FACT] Parent snapshot이 scope, cutoff, definition/manifest version을 소유하고 result는 이를 상속합니다. Kind별로 의미가 있는 subject/criterion, status, reason, source reference와 numerator/denominator/exclusion/threshold 등의 payload를 분리하며 의미 없는 공통 field나 상충하는 version을 강제하지 않습니다.

| Result 경계 | 판정 원칙 | 금지 전환 |
| --- | --- | --- |
| Evaluation success | 고정 input 계산과 전체 finalize 완료 | 모든 지표 measurable/pass로 전환 |
| Sample adequacy | 2주·20 batch·50 candidate 각각 판정 | 일부 충족으로 전체 충분 처리 |
| Quality review | 승인 sample/rubric/reviewer evidence | 누락을 AI 판단·implicit pass로 대체 |
| Quality/service metric | 값, 분자/분모/제외, 측정 가능성과 목표 대조 | Hard Gate status를 기계적으로 복사 |
| Hard Gate | Gate별 violation과 source coverage | 다른 Gate/metric 판정 전파 |
| Final interpretation | Sample·6 Gate·quality/service와 blockers 참조 | Deployment/MVP-B/최종 승인 자동 실행 |

[FACT] 각 Hard Gate는 snapshot×Gate identity별로 독립 판정합니다. 확인된 logical violation이 하나 이상이면 `fail`, 필수 scope/evidence completeness가 부족하면 `not_measurable`, 완전한 범위에서 violation이 0일 때만 `pass`입니다.

[FACT] 표본 부족과 Gate fail이 동시에 존재하면 `판정 불충분`과 해당 Gate `fail`을 모두 보존합니다. 한 결과로 다른 실패·미달·측정 불가를 숨기지 않으며 validation-period의 모든 조건 충족도 최종 승인 아닌 사용자 검토용 통과 후보입니다.

#### WBS-22.H Atomic finalization

[FACT] Evaluation 실행·실패·retry는 logical evaluation work 아래 append-only work attempt로 기록합니다. 별도 canonical `evaluation_run`을 만들지 않으며 retry는 새 attempt로 남기고 이전 실패를 삭제·성공으로 변경하지 않습니다.

[INFERENCE] 성공 attempt 하나만 compact manifest, immutable snapshot과 필요한 typed results 전체를 원자적으로 연결·공개합니다. Manifest만, snapshot만 또는 일부 result만 commit/public 상태가 되는 partial finalize를 허용하지 않습니다.

[FACT] 실행 실패와 commit-unknown은 성공 snapshot/result를 생성하지 않습니다. Exact work/attempt/result identity를 재조회한 뒤 이미 완전한 success가 확인되면 재호출 없이 반환하고, 그렇지 않으면 같은 logical work의 새 attempt 여부를 승인 retry contract로 판단합니다.

[FACT] 성공 snapshot 안의 `not_measurable`, `not_applicable`, exclusion 또는 목표 미달은 실행 실패가 아닙니다. 반대로 calculation/transaction 실패를 모든 결과 `not_measurable`인 성공 snapshot으로 위장하지 않습니다.

#### WBS-22.I Report projection

[INFERENCE] Report는 하나의 immutable snapshot과 그 canonical typed results를 읽는 read-only projection/export입니다. Report 계층이 별도 source query·threshold·rounding·Gate 조합으로 결과를 재계산하거나 새로운 종합 판정을 만들지 않습니다.

[FACT] Report는 scope/cutoff/definition/manifest scheme, row-level 재계산 가능 여부, sample adequacy, 여섯 Gate, quality/service 결과, numerator/denominator/exclusion, not-measurable 이유와 final interpretation을 source result와 일치하게 표시합니다. 실패·미달·측정 불가·제외·복수 blocker를 조용히 생략하지 않습니다.

[FACT] Report 생성/표시 실패는 canonical snapshot/result를 변경하지 않고 deployment/MVP-B/운영 action을 실행하지 않습니다. 실제 file/CLI/UI 형식과 저장 위치는 후속 승인 전 확정하지 않습니다.

#### WBS-22.J Security·resource·rollback

[FACT] Evaluation role에는 승인 source의 read-only 접근과 evaluation work/snapshot/result finalize에 필요한 최소 DB 권한만 부여합니다. RSS/AI/Discord/backup credential, 외부 egress, source domain state mutation, WBS-19 REST invocation과 WBS-11 operation gate 변경 권한을 부여하지 않습니다.

[INFERENCE] Input rows/time/memory/output budget을 승인 configuration으로 제한하고 budget 초과·query timeout·memory pressure를 partial success나 source 0으로 처리하지 않습니다. Actual limit은 representative fixture와 실행 환경 검증 후 사용자 승인합니다.

[FACT] Raw payload, credential, Discord identifier, invoice/account identifier와 전체 source ID 목록을 manifest/result/report/log/metric/error에 복제하지 않습니다. Quality review도 판정·이유·safe source reference를 저장하고 원문을 복사하지 않습니다.

[INFERENCE] Rollback은 request/scope validator, reconciliation handoff, consistent reader, manifest builder, calculators/result finalizer와 report projection을 독립적으로 비활성화할 수 있어야 합니다. 기존 immutable snapshot/result/manifest와 source evidence를 rollback 명목으로 삭제·수정하지 않습니다.

[INFERENCE] WBS-22 완료 기준은 자동/duplicate evaluation, batch/day 전체 품질 결론, direct REST/source mutation, cutoff 이동/late 소급/torn read, payload/전체-ID manifest 복사, missing→zero/pass, unknown result kind/Gate 전파, partial finalize, report 재계산/누락과 결과 기반 자동 deployment/MVP-B action이 각각 0건이고 같은 고정 input의 count/digest/typed result/report가 재현 가능한 것입니다.

[UNKNOWN] Evaluation request key/command/UI, 미래·진행 중 scope 허용, transaction isolation, digest algorithm/canonical serialization/ordering, input/time/memory budget, metric registry와 result field/encoding/precision, quality sample/reviewer/rubric/manual input, report format/location은 WBS-04·08·09·22·25~26 전 사용자 승인으로 닫아야 합니다. 이 계획 승인은 실제 evaluation code·SQL/query·snapshot/result/report, AI/Discord 호출 또는 운영 source 변경을 승인한 것이 아닙니다.
