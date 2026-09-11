# Integrated Verification Plan

## Document Guide

[FACT] 2026-09-10 승인된 B안에 따라 [구현 계획](implementation-plan.md)의 해당 본문을 이동했습니다. Workflow 9 계획과 F01~F08 승인 범위는 유지하며 실제 설계 결과·구현·검증·배포 완료를 뜻하지 않습니다. 현재 Task·blocker·다음 작업은 [AI Context](../../ai-context.md)를 참조합니다.

[FACT] WBS 간 참조는 [전체 WBS 안내](implementation-plan.md#work-breakdown-structure), 계획 승인 경위는 [검토 이력](implementation-review-history.md#sequential-review-state)을 참조합니다. Product·Requirement·AD·DDI·MIN의 기존 정본은 변경하지 않습니다.

## Quick Navigation

- [WBS-23 계약·단위 테스트 closure 상세](#wbs-23-계약단위-테스트-closure-상세)
- [WBS-24 PostgreSQL concurrency·replay·fault 검증 상세](#wbs-24-postgresql-concurrencyreplayfault-검증-상세)
- [WBS-25 Scenario End-to-End 검증 상세](#wbs-25-scenario-end-to-end-검증-상세)
- [WBS-26 용량·시간·비용 운영 전 검증 상세](#wbs-26-용량시간비용-운영-전-검증-상세)

## Detailed Checkpoints

### WBS-23 계약·단위 테스트 closure 상세

[FACT] 직접 Verification Requirement는 `VR-002`, `VR-004`, `VR-010~019`이고 추적성 기준은 전체 99개 Requirement, 특히 P0-HG 34개, `AD-01~23`, `DDI-01~10`, `MIN-01~08`입니다. 기준선은 `WBS-01`, `WBS-09`, 테스트 대상 구현은 `WBS-10~22`, 후속 검증은 `WBS-24~26`입니다.

[FACT] WBS-23은 미래 검증 Task의 작업 경계를 정의합니다. 현재 승인으로 application/test code, fixture/golden, PostgreSQL test environment, external sandbox request, coverage/evidence report 또는 production fix를 생성·변경·실행하지 않습니다.

[FACT] 전체 99개 Requirement가 WBS-23 unit/contract test만으로 검증된다는 의미가 아닙니다. WBS-23은 각 Requirement를 적절한 unit/contract, concurrency/fault, E2E, capacity/time/cost, spike 또는 운영 검증 owner에 연결하고 자신이 소유한 unit/contract case만 실제 pass evidence로 닫습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-23.A | Closure inventory | WBS-10~22 module/contract/test owner와 unit/contract 범위 | 구현/계약/테스트 orphan·중복 owner 0건 matrix |
| WBS-23.B | Requirement traceability | 99개 ID의 verification layer, case/evidence와 후속 owner | Unit-only false closure·P0-HG negative owner 누락 0건 검사 |
| WBS-23.C | Fixture·golden catalog | Versioned synthetic/redacted input, contract fingerprint, manual expected result | Production data·근거 없는 fixture/golden update 0건 test/review |
| WBS-23.D | Pure unit·serialization | 결정 함수, state/error, schema/version/validation 경계 | 정상/경계/금지 parameter·golden case deterministic pass |
| WBS-23.E | PostgreSQL contract | 실제 PostgreSQL migration/constraint/repository 단일 실행 계약 | SQLite/in-memory 대체·application-only invariant 0건 test |
| WBS-23.F | External adapter contract | Network-free RSS/AI/Discord request/response/error fixture | Live/paid call·unfingerprinted mock·hidden retry 0건 test |
| WBS-23.G | P0-HG negative tests | Module-level six Gate 금지 path와 후속 통합 owner | Silent drop/paid fallback/false zero·acceptance 등 mutation 0건 |
| WBS-23.H | Security·test data | Synthetic data, Secret canary, output/snapshot/redaction 경계 | Production identifier·invoice·credential·payload 노출 0건 scan |
| WBS-23.I | Determinism·test health | Fixed clock/timezone/seed, isolation/order, status/flaky policy | Skip/xfail/flaky/quarantine/blocker 0건과 반복·순서변경 pass |
| WBS-23.J | Evidence·handoff | Command/environment/version/result/semantic coverage와 defect/gap report | WBS-23 owned case pass와 모든 잔여 WBS-24~26/SPK/30 연결 |

#### WBS-23.A Closure inventory

[INFERENCE] WBS-10~22별 승인 implementation checkpoint, public/internal contract, state transition, repository/adapter boundary, explicit forbidden behavior와 test owner를 하나의 closure inventory에 연결합니다. 실제 code path가 계약에 없거나 계약만 있고 implementation/test가 없는 orphan을 완료로 추정하지 않습니다.

| 검증 계층 | WBS-23 범위 | 별도 owner |
| --- | --- | --- |
| Pure unit | Validation, state decision, rendering, selection, metric calculation의 결정적 동작 | 없음 |
| Serialization/contract | Input/output schema, version, rejection/error mapping | 없음 |
| Repository/DB contract | Constraint·repository·transaction의 단일 실행 의미 | 동시 claim/crash/replay는 WBS-24 |
| External adapter contract | Redacted fixture 기반 request/response/error mapping | 실제 sandbox 계약은 SPK-01~03 |
| Scenario composition | 인접 module handoff의 local contract | 전체 Scenario/AC는 WBS-25 |
| Capacity/time/cost | 작은 경계 fixture와 단위 계산 | 0/1/99/100/101·schedule·cost는 WBS-26 |

[FACT] WBS-23에서 production defect가 발견되면 관련 구현 WBS의 defect로 반환하고 사용자 승인 branch/test/rollback 범위에서 별도 수정·재검증합니다. Test closure 변경에 production code, schema, dependency 또는 외부 configuration 수정을 숨기지 않습니다.

#### WBS-23.B Requirement traceability

[INFERENCE] 각 Requirement/Decision row는 최소 primary realization owner, 검증 계층, test/spike/scenario ID, positive/negative/fault expectation, evidence 위치와 현재 상태를 가져야 합니다. 여러 계층이 필요하면 primary와 supporting owner를 구분하고 한 test 이름을 근거 없이 여러 Requirement의 pass로 복제하지 않습니다.

[FACT] WBS-23은 `passed`인 자신의 case만 unit/contract evidence로 기록합니다. WBS-24~26, spike 또는 운영 검증이 남은 Requirement는 `planned/pending/blocked`와 owner를 유지하며 unit test 성공으로 전체 Requirement를 pass로 올리지 않습니다.

[FACT] P0-HG 34개의 모든 보장에는 적어도 하나의 negative/fault evidence owner가 있어야 합니다. WBS-23 범위를 벗어나는 integrated/concurrent/operational Gate는 WBS-24~26·30의 exact case/evidence로 handoff합니다.

#### WBS-23.C Fixture·golden catalog

[FACT] Fixture는 synthetic/redacted data만 사용하고 실제 production DB export, Discord guild/channel/user/message identifier, AI/RSS credential·raw private response, invoice/account/payment 정보 또는 Secret을 복사하지 않습니다.

[INFERENCE] 각 external contract fixture는 source spike/official contract fingerprint, contract/schema version, captured category, redaction method와 적용 adapter/test를 식별해야 합니다. 구현자가 만든 mock shape가 스스로 기대한 adapter와 일치한다는 이유만으로 실제 contract coverage를 주장하지 않습니다.

[INFERENCE] Golden expected result는 승인 Requirement/Decision과 수동 계산·판정 근거를 가지며 input, expected state/output, forbidden mutation, version과 reviewer를 보존합니다. Test 실패를 없애기 위한 자동 snapshot overwrite/update를 금지하고 변경 시 영향 Requirement와 재승인 범위를 검토합니다.

#### WBS-23.D Pure unit·serialization

| 검증군 | 최소 경계 |
| --- | --- |
| State/decision | 모든 승인 state/reason과 illegal transition/rejection |
| Identity/idempotency | Exact key, duplicate/replay, similar-but-different key |
| Time | KST boundary, comparable/uncomparable time, before/equal/after cutoff·deadline |
| Quantity/composition | 0/1/limit, current/delayed/recovery/system-message 의미와 count invariant |
| Validation | Valid, low-information, malformed, unknown field/kind/version |
| Serialization | Canonical order/version, missing/extra/null/type/error mapping |
| Projection | Append-only source와 mutable/read-only projection 분리 |

[FACT] Pure test는 wall clock, host timezone, ambient locale, random seed, unordered collection, test execution order 또는 network 상태에 기대지 않습니다. Clock/random/identifier source를 명시적으로 제어하고 승인 deterministic order를 기대 결과에 포함합니다.

[FACT] Unknown enum/result/event kind, contract version mismatch와 malformed payload를 정상/default로 coercion하지 않습니다. 실패 case는 기대 error category와 source mutation·external invocation 0건을 함께 검증합니다.

#### WBS-23.E PostgreSQL contract

[FACT] PostgreSQL-specific type, constraint, uniqueness, FK, transaction/isolation, DB time, migration/role/permission 의미를 SQLite나 in-memory repository 결과로 대신하지 않습니다. 승인 PostgreSQL version의 disposable test database를 사용하고 test마다 schema/data isolation과 cleanup을 검증합니다.

[INFERENCE] WBS-23은 empty/current migration application, constraint rejection, repository CRUD/query ordering, single-transaction commit/rollback과 least-privilege role의 단일 실행 계약을 대조합니다. Concurrent claim, lease replacement, crash point, commit-unknown과 replay race는 WBS-24에서 검증합니다.

[FACT] Application-only validation을 끄거나 우회한 direct DB fixture에서도 DB가 소유한 invariant가 유지돼야 합니다. 반대로 DB가 소유하지 않기로 승인한 cross-domain 의미를 새 test expectation으로 강제해 physical design을 변경하지 않습니다.

#### WBS-23.F External adapter contract

[FACT] RSS, AI와 Discord delivery/Gateway/REST/interaction adapter contract test는 기본적으로 network egress를 차단하고 versioned redacted fixture를 사용합니다. 실제 external endpoint, paid route, live Discord message/reaction, AI invocation 또는 RSS request를 호출하지 않습니다.

[INFERENCE] Request builder, response/error parser, rate/quota category, pagination/resume/interaction verification, message-ID acceptance와 safe evidence mapping을 actual approved contract fixture에 대조합니다. SDK의 hidden retry/fallback/telemetry/network가 발생하면 test를 실패시킵니다.

[FACT] Fixture만으로 실제 external behavior를 pass로 선언하지 않습니다. SPK-01~03의 sandbox evidence와 fingerprint가 fixture에 연결되고 contract drift 시 영향 test가 stale/blocked가 되도록 해야 합니다.

#### WBS-23.G P0-HG negative tests

| Hard Gate module-level 금지 path | 최소 negative expectation | 별도 통합 owner |
| --- | --- | --- |
| 추가 월 비용·유료 호출·유료 자원 사용 0건 | Paid/fallback account/provider/runtime 선택·invocation 0건 | SPK-06, WBS-26·28~30 |
| 미처리 후보 조용한 제외 0건 | 모든 candidate가 analysis/terminal/final reason에 귀속 | WBS-24~25·30 |
| 의도되지 않은 동일 기사 중복 발송 0건 | 승인 authorization 없는 duplicate work/mapping/invocation 거부 | WBS-24~25·30 |
| AI 실패의 신규 0건 오기록 0건 | AI failure에서 no-message normal-zero 생성 금지 | WBS-24~25·30 |
| Discord 미수락의 성공 기록 0건 | Positive response+required message ID 없이는 accepted 금지 | SPK-03, WBS-24~25·30 |
| 중대한 근거 밖 사실 0건 | Unverifiable/extra-source output 정상 analysis 수락 금지 | SPK-02, WBS-25·30 |

[FACT] WBS-23의 negative pass는 해당 module의 forbidden mutation/output이 0건이라는 evidence입니다. 전체 운영 Gate pass가 아니며 integrated state, real contract, concurrency, capacity와 운영월 coverage는 후속 owner가 닫습니다.

[FACT] P0-HG 관련 skip, xfail, flaky/quarantine, missing fixture 또는 known failure를 accepted risk로 바꿔 closure하지 않습니다. 미해결이면 WBS-23과 후속 milestone을 차단하고 owner를 지정합니다.

#### WBS-23.H Security·test data

[INFERENCE] Canary Secret은 configuration/environment, command arguments, DB/backup fixture, logs/metrics/traces, exception/stack trace, snapshot/golden/report, AI request와 Discord output에 심은 뒤 허용 handle 외 위치에서 발견되지 않아야 합니다. 테스트용 값도 실제 credential처럼 다루고 실패 output에 원문을 출력하지 않습니다.

[FACT] Test artifact에는 external request/response 전체 payload, raw RSS article content 범위 밖 데이터, invoice, user identity 또는 production correlation ID를 저장하지 않습니다. 필요한 identifier는 synthetic bounded value와 safe reference를 사용합니다.

[FACT] Test runner와 fixture generator가 ambient credential, developer local profile, production kube context 또는 shared external account를 자동 탐색·사용하지 않습니다. Unknown environment/credential은 fail-closed하고 테스트 편의를 위한 fallback을 두지 않습니다.

#### WBS-23.I Determinism·test health

| Test 상태 | Closure 의미 |
| --- | --- |
| `passed` | Expected result/forbidden mutation과 실제 결과 일치, evidence 유효 |
| `failed` | 관련 implementation/test contract defect; 완료 불가 |
| `skipped` | 미검증; pass/coverage로 계산 금지 |
| `xfail` | Known failure; 완료로 계산 금지 |
| `flaky/quarantined` | 비결정적 미해결; pass로 계산 금지 |
| `blocked` | Environment/fixture/contract 부재; owner 지정과 완료 차단 |
| `not_applicable` | Requirement 근거와 명시적 제외가 있을 때만 비대상 |

[FACT] Test runner의 retry 중 한 번 성공한 결과를 deterministic pass로 기록하지 않습니다. Fixed seed의 반복 실행, test order randomization, 독립 실행과 승인 parallel mode에서 결과가 일치해야 하며 실패/불일치는 보존합니다.

[INFERENCE] Timezone/locale/environment order, shared DB row/cache, background task, port/file path와 global singleton 누수를 격리합니다. 실제 반복 횟수·parallelism·flaky 판정 기준은 WBS-09/23 실행 전 승인하며 기본값으로 숨기지 않습니다.

#### WBS-23.J Evidence·handoff

[FACT] 실행 evidence는 test command, source revision/image/dependency lock, runtime/OS, PostgreSQL version/config, fixture/contract version, seed/timezone, started/completed time, case별 status/duration와 redacted output reference를 구분합니다. 실행하지 않은 case를 pass로 표시하지 않습니다.

[INFERENCE] Coverage report는 line/branch 수치뿐 아니라 Requirement/Decision, state/transition, error/reason, boundary, forbidden mutation, external contract fixture와 P0-HG negative case의 semantic coverage를 제공합니다. 높은 line coverage가 missing behavior를 대신하지 않습니다.

[FACT] 실패 case는 actual result, expected contract, 영향 Requirement/WBS, 재현 조건과 defect owner를 기록합니다. Production implementation 변경이 필요하면 WBS-23 안에서 즉시 수정하지 않고 승인된 구현 Task 범위로 반환합니다.

[FACT] WBS-23 종료 시 unit/contract owned case는 모두 deterministic pass여야 하고 skip/xfail/flaky/quarantine/blocked가 0건이어야 합니다. 남은 concurrency/fault, E2E, capacity/time/cost, spike와 운영 검증은 exact WBS/case/evidence owner에 연결된 pending 상태로 유지합니다.

[INFERENCE] WBS-23 완료 기준은 unit-only 전체 Requirement pass, line-coverage-only closure, mock/contract drift, SQLite 대체, live/paid external call, production data/Secret 노출, skip/xfail/flaky retry pass와 closure 내 production fix가 각각 0건이고 WBS-23 소유 case의 deterministic evidence와 모든 잔여 검증 handoff가 완결되는 것입니다.

[UNKNOWN] 실제 test framework/command, PostgreSQL test instance/container, network egress 차단 방식, fixture/golden 경로·versioning·update 승인, coverage 기준, parallel isolation·반복 횟수, contract fingerprint 연결, evidence 보존 형식과 flaky 정책은 WBS-09·10·23·27 전 사용자 승인으로 닫아야 합니다. 이 계획 승인은 실제 test/code/fixture/environment 생성·실행, external sandbox 호출 또는 production fix를 승인한 것이 아닙니다.

### WBS-24 PostgreSQL concurrency·replay·fault 검증 상세

[FACT] 관련 Requirement는 `FR-004~005`, `FR-012~024`, `NFR-REL-001~003`, `NFR-DQ-002`, `NFR-OBS-001~002`, `NFR-REC-001`, `NFR-TIME-001`, `VR-004~005`, `VR-012~019`이고 관련 Architecture Decision은 `AD-02~03`, `AD-08`, `AD-10`, `AD-13`, `AD-17~22`, Data / Interface Design Decision은 `DDI-05~06`, `DDI-09~10`, `MIN-05~06·08`입니다. 상위 계약은 `WBS-05`, `WBS-08.D`, 검증 대상 구현은 `WBS-11~22`, 선행 테스트는 `WBS-23`, 후속 검증은 `WBS-25~26`입니다.

[FACT] WBS-24는 미래 검증 Task의 작업 경계를 정의합니다. 현재 승인으로 PostgreSQL test instance, test/fault-injection code, process/container, fixture/evidence report, 실제 RSS·AI·Discord 호출 또는 production fix를 생성·변경·실행하지 않습니다.

[FACT] WBS-24는 외부 효과의 exactly-once를 주장하지 않습니다. DB transaction과 외부 호출은 하나의 원자적 transaction이 아니므로 invocation-started 이후 효과가 불명확하면 durable uncertainty를 보존하고 자동 재호출하지 않는지를 검증합니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-24.A | Test model·fault points | 승인 state transition별 deterministic barrier/crash catalog | Hook 미사용 시 동일 동작·fault point coverage review |
| WBS-24.B | Claim·lease·fence | Actual PostgreSQL concurrent claim, DB time, renew/reclaim, ABA/stale suite | 두 active owner·stale/expired mutation·local-clock 권한 0건 test |
| WBS-24.C | Duplicate·replay | Domain별 logical identity와 concurrent/repeated admission matrix | Duplicate work/result/authorization/business effect 0건 test |
| WBS-24.D | Prepared·invocation | Intent/attempt/prepared/invocation/effect/response 분리 fake ledger | Prepared false success·invocation-uncertain auto-retry 0건 test |
| WBS-24.E | Response loss·commit unknown | Network/response/DB failure 조합과 exact re-read/resolution | 새 invocation·wrong attempt 귀속·근거 없는 success/failure 0건 test |
| WBS-24.F | Late evidence·handoff | Exact attempt late application, finalization와 lost-handoff rediscovery | Terminal 변경 오염·중복 handoff/invocation·silent loss 0건 test |
| WBS-24.G | Partial·recovery·restore | Physical item scope, resend limit, conflict와 restored lease invalidation | Partial 전체화·received resend·cross-scope·restored token 사용 0건 test |
| WBS-24.H | Determinism·isolation·security | Barrier/seed/clock, isolated DB, network/credential deny | Sleep/flaky retry pass·shared/production DB·live external/Secret 0건 |
| WBS-24.I | Evidence·defect closure | State/event/invocation count, schedule/seed/version와 failure owner report | Deterministic pass와 모든 defect의 원 WBS handoff evidence |

#### WBS-24.A Test model·fault points

[INFERENCE] Fault harness는 production state machine과 repository/adapter 경계에 승인된 pause/fail hook를 두되 hook가 꺼졌을 때 control flow, transaction boundary, serialization과 external adapter 입력을 변경하지 않아야 합니다. Test 전용 성공 shortcut이나 production에서 불가능한 상태 mutation을 만들지 않습니다.

| Fault point | 관찰할 경계 | 최소 기대 상태 |
| --- | --- | --- |
| Admission/claim 전·후 | Work/attempt transaction과 owner | Claim 전 no-attempt, commit 뒤 exact owner/attempt |
| Prepare commit 전·후 | Intent/config binding과 invocation 부재 | Partial intent 없음 또는 committed prepared |
| Invocation-started 전·후 | 실제 호출 가능 경계 | 시작 전 safe internal resume 후보, 시작 후 uncertain 가능 |
| Response 전·후 | External observation과 acceptance mapping | Response loss와 observed response 분리 |
| Evidence/result commit 전·후 | External evidence/domain finalization | Commit unknown에서 exact re-read |
| Handoff 생성 전·후 | Committed source와 downstream work | Durable rediscovery, duplicate handoff 금지 |
| Lease renew/reclaim 전·후 | DB time/token/fence authority | Stale owner mutation 금지 |
| Restore/fencing reset 전·후 | 복원 token과 새 epoch | Restored owner authority 없음 |

[INFERENCE] Barrier는 각 worker/DB/fake adapter가 어느 경계에 도달했는지 명시적으로 확인한 뒤 다음 action을 허용합니다. 임의 `sleep`이나 빠른/느린 실행 가정으로 race를 만들지 않으며 timeout은 deadlock/failure detection 용도로만 사용합니다.

#### WBS-24.B Claim·lease·fence

[FACT] 승인 PostgreSQL version과 transaction/isolation contract의 disposable database에서 동일 logical work를 둘 이상의 worker가 동시에 claim하도록 시작합니다. Claim과 attempt 생성의 atomicity, loser의 attempt/domain mutation 0건과 current owner/token을 직접 대조합니다.

[FACT] Lease 시간은 PostgreSQL time authority를 사용합니다. Application host clock을 앞/뒤로 이동해도 claim/renew/reclaim 권한이 바뀌지 않고, renew와 reclaim race에서 한 current fencing token만 guarded write를 수행할 수 있어야 합니다.

[FACT] 이전 worker가 lease expiry/reclaim 뒤 늦게 실행하거나 ABA처럼 같은 worker identity가 재사용돼도 old token/fencing epoch로 work, attempt, domain result, handoff 또는 external invocation state를 변경하지 못해야 합니다.

[INFERENCE] Lock wait, deadlock victim, connection loss와 transaction abort를 typed result로 관찰하고 blind retry가 두 owner/attempt를 만들지 않는지 검증합니다. 실제 retry 횟수·isolation·timeout은 승인 contract를 사용하며 test에서 임의 값을 제품 정책으로 고정하지 않습니다.

#### WBS-24.C Duplicate·replay

| Domain | Replay/duplicate identity 경계 | 금지 결과 |
| --- | --- | --- |
| Scheduled work | Schedule kind·KST slot·configuration boundary | 같은 slot pipeline 두 개 |
| Candidate admission | Exact article identity·최초 candidate boundary | 두 candidate/최초 분석 |
| AI analysis | Candidate·approved analysis/version identity | 적용 analysis 두 개·hidden invocation |
| Selection finalization | Source batch·policy/input version | 두 immutable result/handoff |
| Delivery | Source result·segment/mapping/intent identity | Unapproved duplicate message invocation |
| Gateway event | External/canonical event identity | Business projection 두 번 적용 |
| Interaction | Signed request identity·operation/target | Reply/receipt/recovery effect 두 번 |
| REST reconciliation | Trigger/request exact scope identity | Broad/duplicate HTTP work |
| Recovery | Case/confirmation/offer/resend authorization identity | Confirmation/resend/offer 반복 |
| Evaluation | Explicit request identity | Logical work/snapshot 중복 |

[FACT] Domain마다 승인 logical identity가 다르며 하나의 generic dedupe key로 합치지 않습니다. 동일 key replay는 한 logical work/effect로 수렴하고 similar-but-different key는 부당하게 합쳐지지 않아야 합니다.

[INFERENCE] Sequential replay, concurrent duplicate, commit-response loss 뒤 client replay와 process restart 뒤 rediscovery를 각각 검증합니다. Dedupe 결과가 기존 terminal source를 수정하거나 과거 failure/attempt evidence를 삭제하지 않습니다.

#### WBS-24.D Prepared·invocation

[INFERENCE] Fake external adapter는 최소 `intent_received`, `invocation_started`, `external_effect_possible/observed`, `response_available/lost`와 invocation identity/count를 서로 독립적으로 제어·관찰합니다. 하나의 success boolean으로 invocation과 effect/response를 합치지 않습니다.

| 중단 상태 | 허용 복구 | 금지 복구 |
| --- | --- | --- |
| Prepare commit 전 | Committed intent 없음 확인 뒤 원 work 재판정 | 부분 prepared 성공 추정 |
| Prepared commit·invocation 미시작 입증 | 현재 lease/fence·gate·config로 같은 intent resume 후보 | 이미 호출/성공 추정, 무조건 새 attempt |
| Invocation-started commit 뒤 | Response/effect evidence 대조와 uncertain 유지 가능 | Lease expiry/process restart로 자동 재호출 |
| Response observed | Exact attempt evidence/acceptance mapping | 다른/current attempt로 응답 귀속 |

[FACT] Invocation-started는 외부 효과가 발생했거나 성공했다는 뜻이 아니지만 효과가 없었다는 뜻도 아닙니다. Response/message ID/contract evidence 없이는 성공/accepted를 만들지 않고 명시적 미생성 근거 없이는 safe retry를 만들지 않습니다.

[FACT] Test expectation은 테스트한 code path가 불명확 effect를 자동 반복하지 않는다는 것이며 외부 시스템 전체의 exactly-once를 보증했다는 문구를 만들지 않습니다.

#### WBS-24.E Response loss·commit unknown

| Fault 조합 | 기대 처리 | 금지 처리 |
| --- | --- | --- |
| Durable invocation-started 전이며 호출 없음이 입증된 adapter failure | Invocation count 0과 typed pre-call failure | External effect uncertain/성공 추정 |
| Invocation-started commit 직후 network call 전 crash | DB 시작 의도 1건·fake 호출 0건, runtime은 uncertainty 보존 | Count 차이만으로 실패, 호출 없음 추정 자동 retry |
| Invocation 뒤 response timeout/loss | Exact attempt `external_effect_uncertain` | 자동 새 invocation |
| Explicit non-acceptance response | 계약 evidence에 따른 retry/recovery 후보 | 모든 error의 safe retry 일반화 |
| Positive response+required ID | Exact attempt acceptance evidence | 다른 mapping/batch에 성공 전파 |
| Response 관측 뒤 DB commit loss | Same attempt/source 재조회와 late-resolution handoff | 새 attempt 생성·응답 폐기 |
| DB transaction commit response loss | DB를 다시 읽어 실제 commit 상태 판정 | Client timeout만으로 rollback/재실행 추정 |

[FACT] Commit-unknown handler는 logical key와 expected version/token으로 현재 DB state를 재조회합니다. 이미 완전한 commit이 있으면 중복 mutation/invocation 없이 반환하고, 미완전·상충이면 uncertainty와 repair owner를 보존합니다.

[INFERENCE] Fake response/effect ledger와 DB attempt/evidence는 F05의 crash 단계별 count·identity oracle로 대조합니다. 각 실제 fake invocation에는 정확히 대응하는 승인된 durable attempt·invocation-started 근거가 있어야 하며, 같은 attempt의 중복 호출과 승인 attempt 없는 hidden retry/hedged request는 실패입니다. WBS-05.D의 invocation-started commit 직후 network call 전 crash에서는 DB 시작 의도 1건·실제 fake 호출 0건이 허용되는 기대값입니다. 이 test-only 관찰을 runtime의 무효과 증거로 사용하지 않고 uncertainty·기존 attempt를 보존하며 자동 재호출하지 않아야 합니다. 설명되지 않는 count/identity 차이나 허위 effect/성공 기록은 실패로 처리하되 저장된 시작 의도와 실제 외부 호출 수의 무조건적 동일성을 요구하지 않습니다.

#### WBS-24.F Late evidence·handoff

[FACT] Late response/event는 external correlation, operation/configuration, attempt/mapping과 version이 exact match할 때만 원래 attempt에 append-only로 적용합니다. Current active attempt, 같은 article의 다른 batch, recovery attempt 또는 전체 delivery set으로 전파하지 않습니다.

[FACT] Late evidence가 기존 terminal 의미와 상충하면 둘 중 하나를 자동 우선하거나 과거 evidence를 삭제하지 않고 conflict/unknown resolution owner를 남깁니다. Exact positive acceptance가 확인돼도 원래 scheduled timing을 late receipt 시각으로 소급 통과시키지 않습니다.

[INFERENCE] Committed selection/result/delivery/receipt/evaluation source 뒤 handoff transaction 전 crash를 주입하고 durable scanner가 exact downstream work를 한 번 재발견하는지 검증합니다. Scanner는 source가 uncommitted, stale, terminal-ineligible 또는 external-effect-uncertain이면 신규 외부 invocation work를 자동 만들지 않습니다.

#### WBS-24.G Partial·recovery·restore

[FACT] Multi-message delivery와 recovery fault는 physical mapping/item subset별 accepted, explicitly-not-accepted, uncertain과 unattempted를 유지합니다. 일부 결과를 전체 성공/실패로 확장하거나 성공/received item을 resend/recovery에 포함하지 않습니다.

[FACT] Exact `못 받음` immediate-resend authorization은 동일 original scope에서 최대 한 번만 생성·소비됩니다. Resend가 uncertain이면 confirmation/resend/backlog로 자동 반복하지 않고, conflict가 있으면 어느 receipt를 자동 우선하지 않습니다.

[FACT] Confirmed recovery release의 concurrent worker는 oldest original batch 하나, eligible item 최대 10개와 current 최대 10개/총 20개 경계를 유지합니다. 다른 original batch, processing-delayed, accepted/received/uncertain item이 섞이지 않아야 합니다.

[FACT] Restore fixture는 복원된 lease/token/worker identity를 모두 current authority로 인정하지 않고 새 fencing epoch/token을 요구합니다. Loss window의 DB-missing invocation을 미호출로 추정하거나 historical slot을 RSS/AI/delivery로 backfill하지 않습니다.

#### WBS-24.H Determinism·isolation·security

[FACT] Test는 disposable nonproduction PostgreSQL과 synthetic/redacted fixture를 사용하고 production/shared DB, kube context, external account, ambient credential 또는 실제 RSS/AI/Discord network를 사용하지 않습니다. Egress 또는 unexpected socket invocation이 발생하면 실패합니다.

[INFERENCE] Fixed clock/timezone/seed, named barriers와 exact worker schedule을 evidence에 보존합니다. 같은 schedule 반복, 승인 schedule permutation과 독립 실행에서 state/invocation expectation이 일치해야 하고 retry 중 한 번 성공한 결과를 pass로 기록하지 않습니다.

[FACT] Failure output, SQL/error, fake request/response ledger와 test artifact에 Secret, Authorization, raw external payload, Discord identifier 또는 production data를 넣지 않습니다. Test-only credential도 canary/redaction 검사를 통과해야 합니다.

[UNKNOWN] PostgreSQL test orchestration, process/thread/container kill 방식, connection loss/restart injection, barrier API, fake adapter model, worker 수·repeat/schedule set, lease fixture와 timeout/deadlock 기준은 실행 전 사용자 승인으로 닫아야 합니다.

#### WBS-24.I Evidence·defect closure

[INFERENCE] Case evidence는 fault schedule/seed, source revision/image/dependency, PostgreSQL version/config/isolation, worker/transaction/lease timeline, fake invocation/effect/response ledger, DB before/after state·event count, invariant expectation과 redacted failure output을 포함합니다.

[FACT] 핵심 assertion은 stale mutation, duplicate unauthorized invocation/effect, silent lost committed source/handoff, uncertain auto-retry, wrong late evidence attribution, partial 전체화와 restored token 사용이 각각 0건인지 직접 확인합니다. Alert/log 부재나 최종 row 수만으로 이를 추정하지 않습니다.

[FACT] Deadlock, timeout, schedule-dependent failure, flakiness와 unreproduced fault는 pass가 아닙니다. Actual/expected 차이, 재현 schedule, 영향 Requirement/WBS와 defect owner를 남기고 관련 구현 WBS로 반환하며 WBS-24 closure 안에 production fix를 숨기지 않습니다.

[INFERENCE] WBS-24 완료 기준은 actual PostgreSQL의 claim/lease/fence와 domain별 replay/crash matrix에서 두 active owner, stale mutation, silent loss, unapproved duplicate invocation, uncertain auto-retry, wrong late attribution, partial 전체화와 restored-token 재사용이 0건이고 승인 schedule의 deterministic evidence와 모든 defect handoff가 완결되는 것입니다.

[UNKNOWN] 실제 PostgreSQL version/isolation, fault hook/barrier, fake adapter, process/connection interruption, worker/schedule/repeat 수, lease/test timeout, evidence format/retention은 WBS-05·09·23·24·27 전 사용자 승인으로 닫아야 합니다. 이 계획 승인은 PostgreSQL/test/fault environment나 code 생성·실행, 실제 외부 호출 또는 production fix를 승인한 것이 아닙니다.

### WBS-25 Scenario End-to-End 검증 상세

[FACT] 관련 범위는 Product `Scenario 1~9`, `AC-01~24`, `FR-001~024`, `VR-003`과 각 Scenario에 연결된 NFR/DR/EXT, `AD-01~23`, `DDI-01~10`, `MIN-01~08`입니다. 추적성 기준선은 `WBS-01`, 검증 대상 구현은 `WBS-10~22`, 선행 검증은 `WBS-23~24`, 후속 검증은 `WBS-26`, 배포 준비는 `WBS-27~28`입니다.

[FACT] WBS-25는 미래 검증 Task의 작업 경계를 정의합니다. 현재 승인으로 E2E code/environment/fixture, PostgreSQL database, 실제 RSS·AI·Discord request/message/reaction, K3s resource, AC evidence report 또는 production fix를 생성·변경·실행하지 않습니다.

[FACT] E2E는 actual application role/process와 승인 PostgreSQL contract를 연결하되 RSS·AI·Discord는 SPK-01~03 contract fingerprint에 연결된 nonproduction fake를 사용합니다. 실제 external sandbox/production, capacity/time/cost와 K3s deployment 검증을 WBS-25 pass로 대체하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-25.A | E2E environment | Actual PostgreSQL/application roles, deterministic clock, contract fake, network deny | Production/shared state·ambient credential·live/paid call 0건 preflight/test |
| WBS-25.B | Scenario·AC catalog | Scenario 1~9, AC-01~24, variants·source/output/forbidden evidence matrix | Scenario/AC orphan·근거 없는 다중 pass·pending owner 누락 0건 |
| WBS-25.C | Candidate·analysis·selection | Scenario 1·6~8와 AC-01~09의 input/evidence/result lineage | 조기 제외·외부 근거·13시간/Top10·홍보성 오판 0건 test |
| WBS-25.D | Output·normal-zero | Scenario 1~2와 AC-10~13의 render/no-message 경계 | 필수 field 누락·failure/backlog의 clean-zero/no-message 0건 test |
| WBS-25.E | Failure visibility | Scenario 3~4와 AC-14~16의 미처리·delayed/notice 경계 | Silent drop·paid fallback·partial list·원인/수량 은폐 0건 test |
| WBS-25.F | Delivery·recovery | Scenario 5·8와 AC-17~19의 acceptance/confirmation/receipt/offer/FIFO variants | False success·반복 resend·segment/cross-batch·10/10/20 위반 0건 |
| WBS-25.G | Feedback·missing | Scenario 9와 AC-20~21의 reaction/review/missing/recommendation lineage | Feedback/receipt/2XX·not-collected/recall 의미 혼합 0건 test |
| WBS-25.H | Quality·evaluation | Scenario 7·9와 AC-22~24의 sample/Gate/quality/service/report 경계 | Sample 부족/coverage gap false pass·report 누락/재계산 0건 test |
| WBS-25.I | Cross-scenario negative boundaries | MVP-A/B, current/delayed/recovery/system, source/state/time 의미 분리 | 금지 기술/범위·상태/시간 소급·source mutation 0건 test |
| WBS-25.J | Evidence·determinism·defect closure | DB/attempt/outbound/user-output assertion과 AC report·owner handoff | 9 Scenario·24 AC evidence, deterministic pass와 모든 defect owner |

#### WBS-25.A E2E environment

[INFERENCE] E2E topology는 scheduler/batch와 listener/evaluation의 실제 application entry-point/role, 승인 PostgreSQL version/schema/role, deterministic clock, RSS/AI/Discord contract fake와 evidence collector를 명시적으로 기동합니다. 실제 process composition과 command는 WBS-09/10/25 실행 전 승인합니다.

[FACT] 각 case는 disposable database/schema, isolated fake state, fixed configuration/contract versions와 clock를 사용합니다. 이전 Scenario의 work/event/message/usage/backlog, environment default 또는 test order가 다음 case 결과에 영향을 주지 않아야 합니다.

[FACT] External network와 ambient credential을 차단하고 production/shared DB, live RSS/AI/Discord, billing account, kube context를 사용하지 않습니다. Unexpected socket, hidden SDK retry/telemetry, paid route 또는 실제 message/effect가 감지되면 case를 실패시킵니다.

[INFERENCE] Fake는 request, invocation start, effect/response/error/timeout, message ID, Gateway/interaction/REST event와 time을 승인 contract처럼 독립 제어하고 각 실제 fake invocation을 durable test evidence와 대조할 수 있어야 합니다. Fixture contract가 SPK fingerprint와 다르면 관련 case를 stale/blocked로 둡니다.

#### WBS-25.B Scenario·AC catalog

| Scenario | 주된 AC | E2E 중심 |
| --- | --- | --- |
| Scenario 1 | AC-01~12 | 정상 수집·분석·선정·예정 시각 전달 |
| Scenario 2 | AC-13~14·18~19 | 실제 신규 0건과 failure/backlog 분리 |
| Scenario 3 | AC-14~16 | AI failure/quota·미처리·no-paid-fallback 표시 |
| Scenario 4 | AC-14~16 | Incomplete processing, delayed full result/failure notice |
| Scenario 5 | AC-17~19 | Discord acceptance uncertainty·confirmation·recovery |
| Scenario 6 | AC-03·05·09·11·14 | Low-information과 근거 제한·AI failure 분리 |
| Scenario 7 | AC-08·12·22 | Promotional ambiguity/exclusion와 False Positive review |
| Scenario 8 | AC-04·17~19 | Exact-link duplicate/re-run과 approved recovery 구분 |
| Scenario 9 | AC-20~24 | Feedback·missing·recommendation·evaluation 경계 |

[INFERENCE] 이 표는 주된 연결이며 WBS-01 matrix에서 하나의 AC를 복수 Scenario/variant로 검증할 수 있습니다. 각 연결은 같은 test 이름을 반복 기입하는 대신 AC predicate가 어느 source/state/output/forbidden assertion에서 입증되는지 구체적으로 가리킵니다.

[FACT] 각 case는 Scenario/variant ID, 관련 AC/Requirement/Decision, 초기 DB/config/clock, external fixture/version, trigger/role, expected domain state/evidence/outbound mapping, forbidden mutation/invocation, user-visible outcome, actual evidence와 defect owner를 가집니다.

#### WBS-25.C Candidate·analysis·selection

[FACT] Candidate/input E2E는 News/Ask/Show 자격, source/title/keyword만의 조기 제외 금지, Raw RSS exact `link` identity, 외부 원문/상세 페이지/URL dereference 금지, 반복 observation과 최초 admission을 함께 검증합니다.

[FACT] 정상·저정보·invalid/failed AI 결과를 분리하고 RSS evidence 범위의 title/summary/keyword/importance/interest/promotional과 최소 근거를 검증합니다. Low-information에 RSS 밖 내용을 보완하거나 이를 AI failure/silent exclusion으로 바꾸지 않습니다.

[FACT] 예정 target 시각 기준 `published`가 정확히 13시간인 normal/low-information 후보는 current eligibility이고 초과는 명시적 제외입니다. Interest 밖 고중요 후보 유지, promotional ambiguity 유지와 충분한 promotional suspicion 제외를 stable total order·최대 10개와 대조합니다.

[INFERENCE] 10개 초과 후보, 동점, re-observation/re-run과 서로 다른 raw link를 포함해 input/output order와 candidate/decision/summary count invariant를 검증합니다. Capacity 99/100/101과 실제 성능은 WBS-26으로 남깁니다.

#### WBS-25.D Output·normal-zero

[FACT] Normal selected item은 승인 한국어 title, 2~3문장 summary, keyword, GeekNews topic link를, low-information item은 `정보 제한`, 근거가 허용하는 1문장 이하 설명과 topic link를 갖습니다. Promotional exclusion count와 batch summary가 source result와 일치해야 합니다.

[INFERENCE] User-visible 검증은 semantic field/kind/source mapping과 physical payload fixture를 함께 대조합니다. 전체 문자열 snapshot만 사용해 사소한 formatting에는 취약하고 누락·오귀속 의미에는 둔감한 검증으로 끝내지 않습니다.

[FACT] Normal no-message는 신규 candidate 0, input/AI/selection/delivery failure 0, incomplete work 0, processing-delayed 0, confirmed recovery/offer/confirmation backlog 0인 경우만 허용합니다. Failure, quota, incomplete, acceptance uncertainty 또는 recovery backlog를 clean zero로 처리하지 않습니다.

#### WBS-25.E Failure visibility

[FACT] AI error/free quota exhaustion은 paid provider/path로 전환하지 않고 candidate/normal/low-information/unprocessed count와 typed cause를 보존합니다. Unprocessed candidate를 normal exclusion, selected/delivered 또는 신규 0건으로 바꾸지 않습니다.

[FACT] 필요한 AI 처리가 미완료인 valid candidate가 있으면 partial article list를 보내지 않습니다. 이후 원래 pipeline이 전체 선정까지 완료되면 original result의 processing-delayed full result를 최대 10개로 전달하고, 완료 불가능이면 failure notice에 원인별 미처리 count를 표시합니다.

[FACT] Input/parsing 오류가 포함된 observation은 완전한 Top 10으로 표현하지 않고 신규 candidate, normal processing, input error count와 completeness를 표시합니다. Failure notice 성공/실패가 original AI/selection 상태를 바꾸지 않습니다.

#### WBS-25.F Delivery·recovery

[FACT] 최소 delivery/recovery variant는 다음을 각각 독립 실행·판정합니다.

1. Positive response와 required message ID의 accepted delivery
2. Explicit server non-acceptance
3. Timeout/response loss의 acceptance uncertainty
4. Confirmation 전 exact late acceptance/recipient receipt
5. Confirmation 뒤 `받음`
6. Confirmation 뒤 exact `못 받음`과 immediate resend 1회
7. Immediate resend acceptance uncertainty
8. Confirmation no-response와 다음 성공 regular batch offer 1회
9. Offer acceptance uncertainty와 자동 재첨부 0건
10. Explicit `recovery_selected`
11. Multi-message partial acceptance
12. Confirmed backlog 10개 초과와 explicit additional recovery
13. Current 0건 recovery-only
14. Current 10 + recovery 10, total 20
15. Same-scope conflicting receipt

[FACT] Discord response/message ID, recipient receipt, feedback, confirmation/offer message와 recovery acceptance는 각각 다른 evidence 의미를 유지합니다. `받음`이 original 2XX/정시 acceptance를 만들거나 feedback REST가 acceptance/recovery를 변경하지 않습니다.

[FACT] Processing-delayed full result와 confirmed Discord non-acceptance recovery는 별도 delivery set/segment/summary입니다. Recovery는 oldest original batch 하나의 stored result/order를 사용하고 RSS/AI/reselection/freshness 판단을 다시 실행하지 않으며 다른 batch와 섞지 않습니다.

[FACT] Exact `못 받음` immediate resend가 uncertain이면 confirmation/resend/backlog를 자동 반복하지 않습니다. Offer도 required message ID 없는 불명확 acceptance이면 다음 batch에 자동 재첨부하지 않고 explicit selection 없이는 recovery하지 않습니다.

#### WBS-25.G Feedback·missing

[FACT] Article별 세 negative reaction은 독립·복수 허용되고 batch representative의 승인 check reaction과 구분됩니다. Check add/remove, article reaction add/remove, duplicate/older/unmapped/system/bot/user mismatch가 append-only history와 current projection에 미치는 결과를 검증합니다.

[FACT] Reviewed batch의 negative reaction 없는 item만 implicit acceptance 후보이고 unreviewed/unknown reconciliation scope는 분모에서 제외됩니다. Check remove가 과거 receipt/evidence를 삭제하거나 click·system message reaction이 reviewed/receipt가 되지 않습니다.

[FACT] Missing request는 하나의 structured interaction과 exact raw GeekNews link만 사용합니다. Stored history의 found/not-collected/invalid/unavailable 회신, eligible `추천해야 했다` action과 source request/link 연결을 검증하며 URL normalization·RSS refetch·external page crawl·AI 판단을 수행하지 않습니다.

[FACT] `not_collected`는 system history에 exact link record가 없다는 의미일 뿐 RSS 원천 누락, 중요 기사, recall failure 또는 추천 오류를 확정하지 않습니다. Input/RSS pipeline failure를 individual missing result로 바꾸지 않습니다.

#### WBS-25.H Quality·evaluation

[FACT] Promotional exclusion sample의 approved review/rubric evidence로 False Positive 계산 가능성을 검증하고 review가 없거나 불완전하면 품질 통과로 추정하지 않습니다. 지속적인 article별 evaluation이나 새 AI reviewer를 만들지 않습니다.

[FACT] Batch/day explicit evaluation은 operational diagnostic만 출력하며 MVP-A 전체 pass/fail을 만들지 않습니다. Validation-period는 2주, 20 scheduled batch, 50 candidate를 각각 판단하고 최대 4주에도 부족하면 `판정 불충분`을 유지합니다.

[FACT] 여섯 Hard Gate는 독립 `pass/fail/not_measurable` 결과를 갖고 quality/service metric과 구분됩니다. Confirmed violation은 sample 부족과 무관하게 해당 Gate fail이고 coverage gap은 false zero/pass가 아닙니다.

[INFERENCE] Report는 canonical typed result와 scope/cutoff/manifest/result status를 대조해 재계산·누락이 없는지 검증합니다. Sample 부족, Gate fail, quality/service 미달, not-measurable과 복수 blocker를 함께 표시하고 결과로 deployment/MVP-B를 자동 시작하지 않습니다.

#### WBS-25.I Cross-scenario negative boundaries

| Cross-scenario 경계 | 금지 오판 |
| --- | --- |
| Input/no-new/failure | Parsing/AI/quota/incomplete를 정상 신규 0건으로 전환 |
| Current/delayed/recovery | Source result·segment·summary·count/latency/freshness 혼합 |
| Delivery/receipt/feedback | Recipient/reaction을 original 2XX/message ID/정시 acceptance로 전환 |
| External uncertainty/replay | Timeout/response loss/lease expiry를 safe retry로 전환 |
| Missing/quality | Not-collected/submission을 source missing·importance·recall/recommendation error로 확정 |
| Evaluation/operation | Mutable projection·telemetry로 immutable result/Gate pass 생성 |
| MVP-A/MVP-B | Monthly insight, normalization, automatic retention lifecycle 생성 |
| Prohibited technology/source | Kafka·Spark·paid AI fallback·external original-article crawl 도입 |

[FACT] Scenario 결과로 승인 source record를 임의 수정하거나 늦은 evidence를 기존 immutable selection/evaluation에 소급 적용하지 않습니다. 같은 article이라도 original/current/recovery scope의 identity와 timing을 합치지 않습니다.

#### WBS-25.J Evidence·determinism·defect closure

[INFERENCE] Case evidence는 source revision/image/dependency, PostgreSQL/config/contract/fixture version, clock/timezone/seed, process/role, trigger와 input digest, DB state/event/attempt before-after, fake invocation/effect/response ledger, rendered semantic/physical output, forbidden assertion과 actual result를 포함합니다.

[FACT] Final DB row와 output만 검사하지 않고 intermediate prepared/invocation/evidence/handoff, message/item mapping, non-application reason와 forbidden invocation/mutation 0건을 직접 대조합니다. Telemetry/alert만으로 source success/failure를 추정하지 않습니다.

[FACT] Scenario 9개와 AC 24개는 orphan 없이 actual pass evidence 또는 명시적 failed/blocked case와 owner를 가져야 합니다. Skip/xfail/flaky/quarantine, stale external fixture와 실행하지 않은 variant는 pass가 아닙니다.

[FACT] 실패는 actual/expected, 영향 Scenario/AC/Requirement/WBS와 재현 evidence를 남겨 원 implementation WBS로 반환합니다. WBS-25 closure 안에 production code/schema/configuration fix를 숨기지 않고 수정 뒤 WBS-23/24 및 영향 E2E를 다시 실행합니다.

[FACT] WBS-25 통과는 Scenario/AC application integration evidence이며 실제 external sandbox, maximum capacity/latency/cost, K3s/storage/deployment 또는 production readiness 통과가 아닙니다. 해당 evidence는 SPK와 WBS-26~30에서 별도 판정합니다.

[INFERENCE] WBS-25 완료 기준은 9 Scenario·24 AC orphan, happy-path-only/최종-state-only 검증, live/paid call, scenario state/time leakage, failure→clean-zero, delayed/recovery/receipt/acceptance/Gate 의미 혼합, report 재계산, 금지 MVP-B/기술과 closure 내 production fix가 각각 0건이고 모든 variant의 source→state/evidence→user output lineage가 deterministic하게 통과하는 것입니다.

[UNKNOWN] E2E process topology/command, contract fake/fingerprint, deterministic scheduler/clock, PostgreSQL reset/isolation, Scenario fixture/variant 수, Discord semantic/physical assertion, quality-review input, evidence format, runtime/parallelism/resource budget은 WBS-09·23~27 전 사용자 승인으로 닫아야 합니다. 이 계획 승인은 E2E code/environment/fixture/database/report 생성·실행, actual external 호출 또는 production fix를 승인한 것이 아닙니다.

### WBS-26 용량·시간·비용 운영 전 검증 상세

[FACT] 관련 Requirement는 `FR-002·005·011~016·024`, `NFR-REL-002~003`, `NFR-PERF-001`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-OBS-001~002`, `NFR-TIME-001`, `EXT-AI-002·004~005`, `EXT-DC-001~003`, `VR-006·008~009·011·014`이고 관련 Architecture Decision은 `AD-04`, `AD-06`, `AD-14~16`, `AD-19`, `AD-23`, Data / Interface Design Decision은 `DDI-04~06`, `DDI-08`, `MIN-02~03·05`입니다. 상위 설계는 `WBS-06`, `WBS-08.A·B·E~G`, 외부 검증은 `SPK-02`, `SPK-04`, `SPK-06A·06B`, 선행 구현·검증은 `WBS-10~25`, 후속 배포·운영 검증은 `WBS-27~30`입니다.

[FACT] WBS-26은 미래 검증 Task의 작업 경계를 정의합니다. 현재 승인으로 workload/test code/environment, 실제 AI/Discord/RSS request, K3s resource/deployment, 비용·성능 결과, invoice/billing 연동 또는 production fix를 생성·변경·실행하지 않습니다.

[FACT] `100건/일`은 Asia/Seoul 일자별 고유 신규 후보 수이고 feed entry, 기존/중복 observation, 후보 생성 불가능 input error, AI request/retry, Discord message/attempt 수와 구분합니다. `101건`은 승인 최대를 넘은 후보도 silent drop되지 않는지를 확인하는 overflow fixture이며 101건 모두의 정상 AI 분석을 선결 요구하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-26.A | Validation environment | Nonproduction version/resource/representativeness profile와 no-prod/no-paid preflight | Unknown/production/ambient credential·K3s/운영 과대 claim 0건 review |
| WBS-26.B | Workload census | 0·1·99·100·101 unique candidate와 entry/error/duplicate/retry 축 | Candidate/request 수 혼합·fixture count drift 0건 invariant test |
| WBS-26.C | Pipeline capacity | 단계별 count/outcome/resource/queue·DB timing과 silent-loss check | 100건 candidate 누락·unexplained outcome·paid fallback 0건 test |
| WBS-26.D | Free AI staged workload | Synthetic full-shape와 승인 bounded actual provider usage/quota/latency evidence | 미실행 100건 외삽·budget 초과·유료/다른 provider 전환 0건 |
| WBS-26.E | Batch preparation latency | 09:30/21:30부터 verifiable result/logical output ready까지 측정 | Zero/failed/incomplete/late start 분모 누락·30분 false pass 0건 |
| WBS-26.F | Delivery·freshness·recovery time | 1분 acceptance, 13시간 current, pipeline/recovery delay 분리 | 조기/late/uncertain/receipt·recovery의 정시/current 혼합 0건 |
| WBS-26.G | Cost coverage·stop | 일곱 scope, preflight·invocation usage/quota와 stop/kill handoff | Scope gap의 0원/pass·billing API·paid/account fallback 0건 |
| WBS-26.H | Result classification | `pass/fail/blocked/inconclusive/not_measurable`, actual/synthetic/범위 구분 | Limited evidence extrapolation·실패/미측정 은폐 0건 report test |
| WBS-26.I | Evidence·deployment handoff | Environment/workload/measurement/cost report와 WBS-27~30 pending matrix | 모든 잔여 K3s/smoke/2주·20 batch/monthly owner 연결 |

#### WBS-26.A Validation environment

[INFERENCE] Environment profile은 source revision/image/dependency, Python/PostgreSQL version/configuration, CPU/memory/storage/DB limits, process role/concurrency, network/fake/actual external mode, clock/timezone, warm-up/cache, test data distribution과 실행 host를 기록합니다. 실제 값은 WBS-09/26 실행 전 사용자 승인합니다.

[FACT] WBS-26은 production data/account/credential·live Discord target을 사용하지 않습니다. Actual free-provider 실험은 SPK-06A가 pass하고 사용자가 exact account/project/model, non-billable configuration, call/token/time budget과 stop condition을 승인한 별도 run만 허용합니다.

[FACT] 현재 WBS 순서에서 Image/K3s manifest와 deployed workload는 WBS-27 이후이므로 WBS-26 결과를 K3s scheduler, cold start, network/storage overhead 또는 production performance evidence로 표기하지 않습니다. 그 차이는 WBS-27~29의 별도 smoke/readiness/배포 검증 owner에 넘깁니다.

[INFERENCE] Environment가 목표 환경을 대표하지 못하는 요소는 known gap으로 열거하고 결과별 적용 가능 범위를 제한합니다. 빠른 개발 PC나 warm cache의 성능을 하위 production resource에 그대로 외삽하지 않습니다.

#### WBS-26.B Workload census

| KST unique candidate count | 검증 목적 | 필수 포함/경계 |
| ---: | --- | --- |
| 0 | 정상 zero와 failure/incomplete/backlog 구분 | Valid empty/no-new, fetch/parse failure와 recovery pending 분리 |
| 1 | 최소 candidate lifecycle | Normal·low-information·unprocessed variant |
| 99 | 승인 상한 직전 | Count/order/resource trend와 silent loss |
| 100 | 최대 승인 capacity | 모든 candidate의 explicit outcome·no paid/silent drop |
| 101 | Overflow safety | 101번째 보존과 승인 overflow outcome 또는 unresolved policy |

[FACT] Workload manifest는 feed parsed entry, unique new candidate, existing/duplicate observation, candidate-impossible input error를 먼저 배타적으로 대조합니다. Unique candidate는 normal analysis, low-information, freshness/time terminal과 typed unprocessed outcome으로, selection은 selected/limit-not-selected/promotional-excluded/unprocessed로 다시 대조합니다.

[FACT] Actual AI request/retry/token, parser attempt, DB transaction, Discord physical message와 recovery attempt는 별도 operational count입니다. 이들을 unique candidate, logical analysis/result 또는 successful delivery 수로 합산하지 않습니다.

[INFERENCE] 각 0/1/99/100/101 workload에 representative duplicate/input error, normal/low-information, freshness exceeded/uncomparable, AI retry/quota/rate limit/timeout, promotional/Top10, Discord split와 delayed/recovery reference를 단계적으로 조합합니다. 조합 폭과 seed는 실행 budget 승인 뒤 정합니다.

#### WBS-26.C Pipeline capacity

[FACT] 100 unique candidate workload의 pass 의미는 모든 candidate가 데이터 손실·silent exclusion·paid fallback 없이 normal, low-information 또는 명시적 unprocessed/terminal outcome과 selection reason에 설명된다는 것입니다. 모든 100건이 normal AI analysis여야 한다는 뜻은 아닙니다.

[INFERENCE] 수집/parsing, admission, analysis validation/persistence, finalization, rendering/mapping과 diagnostic/evaluation query의 단계별 elapsed time, CPU/memory, DB connections/query/lock, storage growth와 internal backlog를 관측합니다. 승인 threshold가 없는 resource 값은 측정치로만 보고 pass/fail을 새로 만들지 않습니다.

[FACT] Candidate count와 state reconciliation이 맞지 않거나 memory/resource exhaustion으로 일부 outcome이 사라지면 run을 실패시킵니다. Error/timeout을 정상 0이나 capacity 초과 허용으로 숨기지 않고 원인과 영향 수를 보존합니다.

[FACT] 101 workload의 exact fallback/overflow policy가 아직 승인되지 않았으면 구현자가 drop/defer/partial-send를 선택하지 않습니다. Candidate와 blocking decision evidence를 보존하고 해당 정책 검증을 `blocked/inconclusive`로 보고해 사용자 결정을 요청합니다.

#### WBS-26.D Free AI staged workload

| Stage | 허용 범위 | 판정 한계 |
| --- | --- | --- |
| Synthetic full-shape | 0/1/99/100/101 전체, contract fake response/error/token fixture | Application capacity/logic만 검증, actual provider capacity 아님 |
| Bounded actual free-provider | 승인 exact account/model/config와 call/token/time budget 내 대표 입력 | 실제 실행 범위만 evidence, 미실행 수량으로 외삽 금지 |
| Quota/rate-limit stop | Provider evidence와 승인 stop condition에서 즉시 중단 | Paid/other account/provider로 계속 금지 |

[FACT] Synthetic latency/token/response는 deterministic adapter behavior이며 실제 provider 수치로 보고하지 않습니다. Actual 소량 sample의 평균·처리량을 곱해 100건 완료시간이나 quota pass를 만들지 않습니다.

[FACT] Actual run은 invocation별 candidate/input size category, prepared/invocation/evidence, token/usage/quota/rate-limit/latency와 retry를 logical candidate와 분리해 기록합니다. Hidden SDK retry/parallel call이 승인 budget을 늘리면 즉시 중단하고 fail 또는 inconclusive로 판정합니다.

[FACT] 무료 quota/정책/설정이 부족하거나 actual 100건 실행이 승인 budget 안에서 불가능하면 유료 호출·다른 account/project/model/provider로 전환하지 않습니다. 실행 범위와 unverified range를 명시해 `blocked/inconclusive`로 남기고 synthetic pass로 보완하지 않습니다.

#### WBS-26.E Batch preparation latency

[FACT] Batch preparation duration은 source scheduled start `09:30` 또는 `21:30`부터 하나의 verifiable final batch result와 message가 필요한 경우 발송 가능한 logical result ready까지입니다. Actual process start나 test command start로 예정 시작을 대체하지 않습니다.

[FACT] Normal delivery, valid normal-zero, partial/incomplete, processing failure notice와 delayed finalization처럼 예정 batch에 연결된 결과를 각각 관측합니다. 정상 신규 0건과 늦은 start/missed slot을 분모에서 조용히 제외하지 않고 retry/re-run/recovery를 새 scheduled batch로 중복 계산하지 않습니다.

[INFERENCE] Synthetic clock를 단순 점프해 elapsed processing을 0으로 만들지 않고 application timer/source evidence와 실제 wall/resource elapsed를 분리합니다. Warm/cold/cache state와 clock accuracy를 보고하고 측정 불가이면 30분 pass로 추정하지 않습니다.

[FACT] WBS-26은 30분 경계의 application readiness와 representative run 측정치를 제공하지만 최소 2주·20 scheduled batch의 95% service objective를 최종 pass로 만들지 않습니다. 실제 운영 표본 판정은 WBS-30입니다.

#### WBS-26.F Delivery·freshness·recovery time

| Metric | Source boundary | 정시/유효 조건 | 제외·별도 처리 |
| --- | --- | --- | --- |
| Discord timely acceptance | Scheduled target→required mapping `discord_2xx`+message ID | `[10:00,10:01)` 또는 `[22:00,22:01)` | 적격 batch의 조기/1분 이후/not-accepted/uncertain/receipt-only는 분자 불인정; 분모에서 제거하지 않음 |
| Current freshness | Scheduled target−RSS `published` comparable instant | `≤13시간`, 정확히 13시간 포함 | 초과·누락/오류/비교 불가 explicit outcome |
| Pipeline delay | Scheduled start→original result 최초 confirmed Discord acceptance | Source batch 기준 | Recovery/confirmation/receipt 제외 |
| Recovery delay | Original scheduled target→recovery confirmed acceptance | Original scope 기준 | Current latency/freshness와 합산 금지 |

[FACT] Discord timely-acceptance는 source scheduled batch의 final 결과가 요구한 current article·결과 요약 또는 processing failure notice의 필요한 physical mapping을 대상으로 합니다. 이들 message가 필요한 batch는 분모에 포함하며, 필요한 mapping의 `discord_2xx`와 message ID가 목표 1분 구간 안에 확인된 경우 정시 수락 분자에 반영합니다. 정상 신규 0건/no-message, processing-delayed full result, Discord 미수락 recovery, receipt confirmation·offer는 이 정시 수락 분자·분모에서 제외하고 각 domain timing에 보존합니다. 정본은 [Data metric source 계약](../02-technical/data-model.md)이며 processing failure notice를 정시 수락으로 인정해도 원래 processing failure를 정상 처리 성공으로 바꾸지 않습니다.

[INFERENCE] F06 검증은 적격 processing failure notice의 정시 수락은 분자·분모에, 지각·미수락·수락 불명확은 분모에만 반영하는지 확인합니다. 정상 0건·지연 full result·recovery·confirmation·offer는 제외하고, receipt만으로 원래 2XX·정시 수락을 생성하지 않는지 대조합니다. 실제 집계 구현·물리 evidence는 후속 검증 대상입니다.

[FACT] Recipient `받음`, reaction, feedback REST snapshot, message ID 없는 response와 acceptance uncertainty를 Discord 2XX/정시 수락으로 사용하지 않습니다. Recovery가 성공해도 original current freshness·정시 결과를 소급 변경하지 않습니다.

[INFERENCE] WBS-26의 fake/sandbox timing은 scheduling/instrumentation 경계와 제한된 수치를 검증합니다. 실제 Discord acceptance의 2주·20 batch 95%, K3s cold start와 network jitter는 WBS-29~30에서 별도 측정합니다.

#### WBS-26.G Cost coverage·stop

| Cost scope | WBS-26 evidence | 미완전 시 처리 |
| --- | --- | --- |
| AI provider | Exact free config, invocation/token/usage/quota와 paid event 0 | Actual run 차단/중단 |
| Discord | Sandbox/operation usage·비용 조건 | Live target fallback 금지 |
| K3s runtime/host | SPK-04/06의 기존 환경·예상 coverage | Deployment 전 actual 운영비 pass 금지 |
| PostgreSQL/PV | Test/예정 production storage coverage | 용량 증가 비용 불명 시 readiness 차단 |
| Backup storage/transfer | SPK-05/06 capacity/transfer evidence | WBS-21/28 closure 보류 |
| Image registry | 예정 image storage/pull/traffic evidence | WBS-27/28 차단 |
| Scheduler/monitoring | 예정 tool/service 비용 evidence | 유료 도구 선택 금지 |

[FACT] SPK-06A가 actual cost-capable test 전에 pass해야 하고 각 invocation 직전 WBS-11 gate를 재검증합니다. Quota/rate-limit/plan/usage mismatch, budget 도달 또는 paid possibility 불명 시 신규 호출을 중단하고 다른 credential/account/provider/runtime으로 우회하지 않습니다.

[FACT] WBS-26은 billing API/invoice scraping을 구현하지 않습니다. Test 기간의 실제 billing/usage는 사용자가 직접 확인하고 WBS-20 형식의 기간·scope·판정·redacted reference만 연결합니다.

[FACT] SPK-06B와 WBS-26은 배포 전 비용 safety/coverage evidence이며 실제 운영월 추가 비용 0원 Hard Gate pass가 아닙니다. Evaluation 기간과 모든 비용 scope를 덮는 사용자 monthly billing evidence를 포함한 최종 판정은 WBS-30에서 수행합니다.

#### WBS-26.H Result classification

| 판정 | 적용 기준 |
| --- | --- |
| `pass` | 정의한 environment/scope/workload의 모든 필수 evidence와 기준 충족 |
| `fail` | 실행되어 명시 기준·invariant·stop condition을 위반 |
| `blocked` | 승인 account/environment/policy/fixture 부재로 실행 불가 |
| `inconclusive` | 실행했지만 표본·coverage·comparability가 결론에 불충분 |
| `not_measurable` | 특정 metric의 필수 time/source/evidence가 없어 계산 불가 |

[FACT] 각 결과는 synthetic/actual, environment, workload size/mix, warm/cold, sample count, cutoff, measured value/distribution, source coverage와 제한을 표시합니다. 일부 stage pass를 전체 WBS/NFR/Hard Gate pass로 확장하지 않습니다.

[FACT] 실행하지 않은 actual 100건, K3s 환경, 2주·20 scheduled batch 또는 monthly billing 결과를 추정 pass로 채우지 않습니다. Fail/blocked/inconclusive/not-measurable과 101 overflow unknown을 보고서에서 생략하지 않습니다.

[INFERENCE] 처리시간/usage 표본은 승인 통계 요약을 사용하되 average 하나로 tail/error를 숨기지 않습니다. 실제 percentile/repetition/confidence 기준은 test budget과 requirement를 바꾸지 않는 범위에서 실행 전 승인합니다.

#### WBS-26.I Evidence·deployment handoff

[INFERENCE] Evidence report는 environment/version/resource, workload manifest/digest와 단계별 census, run/attempt/invocation/token/usage, latency source times, resource measurement, cost coverage/stop event, actual/synthetic 구분, 판정·제한·defect와 raw evidence의 safe reference를 포함합니다.

[FACT] WBS-27에는 image/build/runtime 차이, K3s role/manifest/resource/storage/network/clock/schedule smoke owner를, WBS-28에는 blocking unknown·cost/backup/security/runbook 승인 owner를, WBS-29에는 실제 deployment smoke, WBS-30에는 2~4주·20 batch·50 candidate와 monthly billing 최종 evidence owner를 넘깁니다.

[FACT] Capacity/latency/cost defect가 production code/configuration 변경을 요구하면 영향 WBS-14~22로 반환해 승인 범위에서 수정하고 WBS-23~26의 영향 suite를 다시 실행합니다. WBS-26 closure 안에 production fix, dependency/setting 변경 또는 유료 resource 선택을 숨기지 않습니다.

[INFERENCE] WBS-26 완료 기준은 candidate/entry/request count 혼합, 0/1/99/100/101 silent loss, synthetic/limited actual 외삽, budget 초과/paid fallback, 30분·1분·13시간·pipeline/recovery 지표 혼합, predeploy의 K3s/95%/monthly 비용 false pass와 closure 내 production fix가 각각 0건이고 실행한 범위의 evidence와 WBS-27~30 pending handoff가 완결되는 것입니다.

[UNKNOWN] 최종 free provider/model/quota/reset, actual call/token/time budget, 100건 초과 policy, representative input distribution, CPU/memory/DB budget, environment comparability, clock/scheduler/Discord timing precision, warm-up/repetition/statistics, user billing confirmation schedule와 K3s performance delta 기준은 SPK-02·04·06, WBS-06·08·09·26~30에서 사용자 승인으로 닫아야 합니다. 이 계획 승인은 workload/environment/actual external call, K3s deployment, 비용·성능 결과 또는 production fix를 승인한 것이 아닙니다.
