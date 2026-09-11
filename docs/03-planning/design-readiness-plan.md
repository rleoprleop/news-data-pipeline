# Design and Coding Readiness Plan

## Document Guide

[FACT] 2026-09-10 승인된 B안에 따라 [구현 계획](implementation-plan.md)의 해당 본문을 이동했습니다. Workflow 9 계획과 F01~F08 승인 범위는 유지하며 실제 설계 결과·구현·검증·배포 완료를 뜻하지 않습니다. 현재 Task·blocker·다음 작업은 [AI Context](../../ai-context.md)를 참조합니다.

[FACT] WBS 간 참조는 [전체 WBS 안내](implementation-plan.md#work-breakdown-structure), 계획 승인 경위는 [검토 이력](implementation-review-history.md#sequential-review-state)을 참조합니다. Product·Requirement·AD·DDI·MIN의 기존 정본은 변경하지 않습니다.

## Quick Navigation

- [WBS-03 Internal Review Checkpoints](#wbs-03-internal-review-checkpoints)
- [WBS-04 Internal Review Checkpoints](#wbs-04-internal-review-checkpoints)
- [WBS-05 Internal Review Checkpoints](#wbs-05-internal-review-checkpoints)
- [WBS-06 Internal Review Checkpoints](#wbs-06-internal-review-checkpoints)
- [WBS-07 Internal Review Checkpoints](#wbs-07-internal-review-checkpoints)
- [WBS-08 Detailed Review Checkpoints](#wbs-08-detailed-review-checkpoints)
- [WBS-09 — Coding Readiness Check 상세 checkpoint](#wbs-09--coding-readiness-check-상세-checkpoint)

## Detailed Checkpoints

### WBS-03 Internal Review Checkpoints

[FACT] WBS-03은 하나의 control-boundary 설계이며 아래 checkpoint를 독립적으로 검토합니다. 네 checkpoint가 서로 일치하고 전체 완료 기준을 충족해야 WBS-03을 완료합니다. 이 ID는 새로운 상위 Workflow Task가 아닙니다.

| ID | 검토 범위 | 계획 산출물 | 완료 전 남는 위험 |
| --- | --- | --- | --- |
| WBS-03.A | 역할·entry-point 책임 | 두 application role과 Prepare, Delivery-gate, Recovery/Reconciliation, Gateway listener, Evaluation의 관계, entry point별 허용·금지 책임, PostgreSQL handoff와 공통 module 경계 | 실제 command·module signature·종료 semantics 미확정 |
| WBS-03.B | configuration·version·batch binding | configuration snapshot, Secret, contract/cost evidence, operational event의 책임 분리, 신규 batch 활성 설정과 기존 batch binding의 구분, C1/C2·rollback·호출 직전 evidence precedence | 물리 field·activation interface·query 미확정 |
| WBS-03.C | Secret·ServiceAccount·DB 권한 | K3s identity·Secret 주입·외부 credential·DB role·운영자·network 계층, 역할별 필요/금지 권한, 동일 범위 rotation·redaction·canary negative verification | 실제 manifest·DB role·mount·rotation 도구와 provider scope 미확정 |
| WBS-03.D | outbound gate·pause/resume·kill switch | 전역 신뢰 조건과 RSS·AI·Discord·REST·feedback·evaluation별 gate, scope별 차단, 안전한 late evidence, 계획/긴급 pause와 수동 resume handoff | 실제 gate enum·query·운영 명령·배포 검증 미완료 |

#### WBS-03.A Role and Entry-point Contract

[FACT] 승인된 application boundary는 scheduled collection/batch pipeline과 long-running Discord listener라는 두 상위 역할입니다. Prepare·Delivery-gate·Recovery/Reconciliation은 batch pipeline role의 실행 기회이고 Gateway listener는 listener role의 entry point이며, Evaluation은 같은 Python code/image의 독립 command/function입니다. 이들은 별도 마이크로서비스 다섯 개가 아닙니다.

[UNKNOWN] Evaluation의 실제 K3s 실행 형태와 schedule은 WBS-08·22·27에서 확정합니다.

| Entry point | Trigger·claim | 허용된 외부 효과 | 허용된 주요 변경 | 반드시 금지 |
| --- | --- | --- | --- | --- |
| Prepare | 목표 전달 시각 전 scheduled batch의 Prepare work | GeekNews RSS, 승인된 무료 AI, 조건을 충족한 processing-delayed full result의 Discord 전달 | RSS evidence, candidate·analysis, final selection, selection commit 뒤 delayed delivery work | 과거 slot 신규 실행, Gateway mutation, selection commit 전 delivery, regular recovery |
| Delivery-gate | 10:00·22:00 target delivery-release work | Discord 전달 | current·recovery·failure-notice delivery set/attempt과 gate 관측 | RSS·AI·selection 시작, 목표 시각 전 attempt |
| Recovery/Reconciliation | 만료·중단 work와 exact recovery/reconciliation scope | 범위가 확정된 Discord 또는 REST 호출 | 안전한 내부 재개, receipt confirmation, reconciliation snapshot, 확인된 recovery | 불명확 AI·Discord 자동 재호출, 과거 slot pipeline 실행, 범위 없는 주기적 REST polling |
| Gateway listener | 검증된 Discord Gateway event | Gateway interaction response, 승인 event commit 뒤 별도 claim된 즉시 재전송 | raw event, feedback projection, interaction, recovery event와 delivery handoff | RSS·AI·재선정·정규 발송, handler 내부 무기록 재전송 |
| Evaluation | 명시적 사용자 request admission과 evaluation work claim | 없음 | evaluation work, 계산 전 필요한 exact reconciliation request handoff, immutable snapshot·typed result | 직접 외부 API 호출, 운영 source·selection·delivery·feedback·outbound gate 변경 |

[FACT] 각 entry point는 자신에게 허용된 logical work type만 claim하며 process 간 handoff는 PostgreSQL commit과 durable work를 통합니다. 공통 delivery executor는 독립적인 여섯 번째 서비스가 아니며, 공통 module 재사용은 호출 entry point의 허용 작업을 확대하지 않습니다.

[FACT] Prepare는 final selection commit 전 delivery work·attempt를 만들지 않고 목표 시각 전 regular delivery를 release하지 않습니다. 목표 시각 뒤 완성된 원래 batch의 processing-delayed full result만 별도 delivery work claim을 통해 처리할 수 있습니다.

[INFERENCE] 승인 사용자의 `못 받음`에 따른 즉시 재전송은 listener가 원래 message·attempt·사용자와 1회 제한을 검증하고 `immediate_resend_authorized` event와 delivery-release work를 commit한 뒤, 같은 listener process가 실행하더라도 공통 delivery executor에서 별도 work를 claim하는 경계를 사용합니다. 중단 시 Recovery는 `invocation_started` 전 work만 DB 근거상 안전하게 재claim합니다. 실제 command와 module 조립 방식은 WBS-10에서 확정합니다.

[FACT] Evaluation의 읽기 전용 경계는 운영 source record를 변경하지 않는다는 의미입니다. Request-admission 단계는 feedback 의존 metric에 필요한 exact scope가 있을 때 calculation attempt 전에 WBS-07.E 소유의 bounded reconciliation request를 내부 handoff로 등록할 수 있지만 직접 외부 API를 호출하거나 feedback state를 변경하지 않습니다. 실제 Discord REST는 WBS-19.A만 수행하며, evaluation claim은 명시된 work·dependency를 사용해 immutable snapshot·typed result만 append합니다. 이는 새 application role이나 service를 추가하지 않습니다.

[FACT] 모든 AI·Discord 외부 호출은 `prepared commit → invocation_started commit → 외부 API 호출 → evidence commit` 경계를 우회하지 않습니다. process 종료·재시작이나 lease 만료만으로 이미 시작됐을 가능성이 있는 외부 효과를 자동 재실행하지 않습니다.

[UNKNOWN] 실제 CLI command 이름·argument, Python package/module signature, exit code, graceful shutdown timeout, CronJob deadline·Recovery 주기와 같은 물리 실행 계약은 WBS-10·27에서 확정합니다.

#### WBS-03.B Configuration, Evidence, and Binding Contract

[FACT] Configuration 설명, 실제 credential, 외부 계약 확인, 비용 안전 근거와 운영 활성화 사건은 다음과 같이 서로 다른 책임과 변경 주기를 가집니다.

| 구분 | 책임 | 변경 방식 | 포함하지 않는 것 |
| --- | --- | --- | --- |
| `configuration_snapshot` | provider/model과 비밀이 아닌 account/project reference, free-only 정책, prompt·output·검증·판정 정책 version, runtime/image revision 등 실행 기준 설명 | 설정 등록·변경 시 새 immutable snapshot 생성 | Secret 원값, 현재 활성 상태, 반복되는 contract/cost 결과 |
| Secret | API key, token, webhook URL, interaction secret 등 실제 credential | 전용 Secret 경계에서 개별 교체·폐기 | DB snapshot·일반 설정·log·metric·trace·AI input |
| `external_contract_check` | 외부 계약·공식 자료·sandbox 또는 제한 workload 검증 결과 | 구현 직전·운영 검증 전·계약/설정 변경·mismatch·승인된 재검증 때 append | 공식 원문·전체 외부 응답·credential |
| `cost_safety_evidence` | 무료·과금 불가·quota와 실제 비용 확인의 시점·적용 범위·결과 | 사전 조건 또는 운영 비용 재확인 때 append | configuration 복제, invoice 원문·account identifier·credential |
| `operational_event` | 신규 batch 활성화, pause·resume, 사용자 승인과 차단 사건 | 승인·운영 상태 변경 때 source evidence를 참조해 append | snapshot·contract·cost·backup 결과의 내용 복사 |

[FACT] 활성 상태는 하나의 boolean으로 축약하지 않습니다. 신규 Prepare가 선택할 snapshot, 기존 batch에 이미 binding된 processing snapshot, 해당 snapshot으로 현재 새 외부 호출을 시작할 수 있는지와 전체 workload pause 상태를 구분합니다. C2가 후속 신규 batch에 활성화되어도 이미 C1에 binding된 batch를 변경하지 않으며, 조건이 유효한 C1의 제한된 in-flight 완료 허용은 두 신규 batch 설정을 동시에 활성화하는 것이 아닙니다.

| 우선순위 | 판단 | 결과 |
| --- | --- | --- |
| 1 | DB 신뢰 불명, restore 검증 대기, backup 공백 초과, 수동 pause 또는 비용·계약 차단 | 관련 신규 외부 호출 차단 |
| 2 | 기존 batch에 processing snapshot이 이미 binding됨 | 해당 snapshot 유지, 재binding 금지 |
| 3 | 신규 실제 Prepare이고 승인·활성화된 snapshot이 정확히 하나임 | 첫 내부 commit에서 해당 snapshot을 한 번 binding |
| 4 | binding된 snapshot에 적용되는 현재 contract·cost·credential 근거가 유효함 | 허용된 외부 호출의 prepared 단계 진행 가능 |
| 5 | 환경변수·CLI·SDK default가 binding 또는 승인 설정과 불일치함 | override하지 않고 configuration mismatch로 차단 |
| 6 | 신규 batch의 승인된 active snapshot이 없거나 둘 이상으로 해석됨 | 신규 Prepare outbound 차단 |

[FACT] Batch binding과 invocation 허가는 서로 다른 판단입니다. Batch의 processing snapshot은 immutable하지만 AI·Discord·REST 호출 직전에는 현재 유효 lease·fencing token, DB 신뢰, outbound gate와 해당 snapshot에 적용되는 contract·cost·credential 근거를 다시 대조합니다. C1 근거가 더는 유효하지 않으면 C2로 자동 전환하지 않고 C1에 binding된 후보·batch를 원인별 차단·미처리로 유지합니다.

[INFERENCE] 같은 snapshot의 재검증에서는 snapshot 본문을 바꾸지 않고 새 contract/cost evidence를 append하며, 새 operational event가 기존 snapshot과 새 근거를 함께 참조하도록 계획합니다. 실제 관계 table·현재 상태 projection·query는 WBS-04에서 결정합니다.

| 시점 | 사건 | 기대 결과 |
| --- | --- | --- |
| T1 | C1 등록·검증·활성화 | 후속 신규 Prepare에 C1 사용 가능 |
| T2 | B1의 첫 내부 commit | B1에 C1을 한 번 binding |
| T3 | C2 등록·검증·활성화 | 이후 신규 batch 선택 기준만 C2로 변경 |
| T4 | B1의 AI retry | C1의 현재 비용·계약 조건이 유효할 때만 C1로 실행 |
| T5 | C1 조건 불충족 | B1 차단·미처리, C2 자동 전환 금지 |
| T6 | 신규 B2 시작 | B2에 C2 binding |
| T7 | C1로 rollback 승인 | 새 activation event 이후 신규 batch만 C1 사용 |
| T8 | 과거 slot ledger 등록 | configuration binding과 Prepare/RSS/AI/selection/delivery 생성 없음 |

[FACT] 의미적 processing version은 기사 분석·판단·선정 결과를 결정합니다. 실제 Discord physical message는 승인된 transport-only output/configuration version과 payload hash를 별도로 기록할 수 있지만 원래 selection, 기사 의미·사유와 원래 batch 수량을 변경하지 않습니다. 처리 의미와 transport-only 설정의 실제 field 분류는 WBS-04·17에서 확정합니다.

[FACT] 환경변수와 CLI는 role·DB 연결 같은 bootstrap 정보만 제공하며 provider/model/prompt/output·판정 정책과 free-only 기준을 binding된 snapshot과 다르게 덮어쓰지 않습니다. SDK의 ambient credential·provider·유료 경로 자동 발견도 허용하지 않습니다.

[FACT] Configuration rollback은 snapshot 수정이나 진행 중 batch 재binding이 아니라, 과거 승인 snapshot을 후속 신규 batch에 다시 선택하는 새 activation event입니다. 이미 다른 snapshot에 binding된 batch와 과거 결과를 재분석·재선정하지 않습니다.

[UNKNOWN] Snapshot·evidence의 물리 field·ID·관계 table, active-state projection과 activation interface, processing/transport 설정의 정확한 field 목록, 환경변수·CLI 이름과 동시 activation transaction은 WBS-04·10·17에서 확정합니다.

#### WBS-03.C Secret and Least-privilege Contract

[FACT] 하나의 Python image를 공유해도 권한은 다음 계층별로 분리합니다. 한 계층의 통제가 다른 계층의 권한을 대신한다고 간주하지 않습니다.

| 권한 계층 | 통제 대상 | 계획 경계 |
| --- | --- | --- |
| K3s ServiceAccount | Kubernetes API 접근 | 일반 application workload는 Kubernetes API·다른 namespace·RBAC 변경 권한을 받지 않음 |
| Secret 주입 | 실제 credential 접근 | 해당 workload에 필요한 Secret만 주입하고 broad Secret `list`·`watch` 권한을 주지 않음 |
| 외부 credential | 외부 service/account/project API | 승인된 환경·목적·operation과 무료 조건으로 제한 |
| PostgreSQL runtime role | DB 읽기·쓰기 | entry point가 소유한 업무 영역과 허용 work type으로 제한 |
| 운영자 identity | migration·kill switch·backup·restore | 일반 application identity와 분리하고 사용자 승인 절차에만 사용 |
| Network egress | 접근 가능한 외부 endpoint | 역할에 불필요한 외부 목적지 접근을 제한하는 보조 경계로 WBS-27~28에서 검증 |

[INFERENCE] 일반 application workload는 Kubernetes API를 직접 사용할 필요가 없으므로 ServiceAccount token 자동 mount 비활성화를 기본 후보로 두고, workload Pod에 Secret을 주입하기 위해 해당 ServiceAccount에 Secret `get`·`list`·`watch` 권한을 부여하지 않습니다. 실제 K3s 동작과 manifest는 WBS-27~28에서 검증합니다.

| Workload | 필요한 외부 credential | 불필요하거나 금지할 credential |
| --- | --- | --- |
| Prepare | 승인된 AI credential, processing-delayed full result에 필요한 Discord 전달 credential | Gateway interaction secret, 운영자·migration·backup credential |
| Delivery-gate | Discord 전달 credential | AI credential, Gateway 전용 secret, 운영자 credential |
| Recovery/Reconciliation | Discord 전달·제한적 REST 대조 credential | AI credential, migration·backup credential |
| Gateway listener | Discord Gateway·interaction credential, 승인된 즉시 재전송에 필요한 전달 credential | AI credential, migration·backup credential |
| Evaluation | 외부 credential 없음 | AI·Discord·운영자 credential 전체 |
| Migration | PostgreSQL schema owner credential | AI·Discord credential과 application runtime 사용 |
| Backup | 검증된 backup 실행에 필요한 DB·저장소 credential | AI·Discord·application runtime credential |
| Restore validation | 격리된 복원 환경의 제한적 고권한 credential | production AI·Discord credential |
| Kill-switch operator | CronJob suspend·Deployment scale 변경 권한 | Secret 원값 조회와 DB schema owner 권한 |

[FACT] Prepare의 delayed full result와 listener가 승인 event 뒤 연결하는 즉시 재전송 때문에 일부 역할에는 Discord 전달 credential이 필요합니다. Discord가 목적별 credential scope를 제공하지 않으면 Secret 주입만으로 정시·지연·사용자 승인 전송을 구분할 수 없으므로 WBS-03.D의 durable work claim과 application outbound gate를 함께 적용합니다.

| DB role 범주 | 허용 범위 | 금지 범위 |
| --- | --- | --- |
| Prepare runtime | scheduled/Prepare work, RSS·candidate·AI·selection, 조건부 delayed delivery | schema DDL, feedback·evaluation·backup 관리 |
| Delivery runtime | committed selection/recovery 조회, delivery work·attempt·evidence | RSS·AI·selection 변경, schema DDL |
| Recovery runtime | 명시적으로 허용된 safe-resume work, recovery·reconciliation·delivery 상태 | 임의 selection 변경, 불명확 외부 효과의 성공 처리, schema DDL |
| Listener runtime | message mapping 조회, raw Gateway event·feedback·interaction·recovery 기록 | RSS·AI·selection 변경, schema DDL |
| Evaluation runtime | 업무 source 조회, evaluation work·snapshot·result append | source 업무 record·outbound gate 변경 |
| Migration owner | 승인된 migration의 DDL | application runtime 사용 |
| Backup role | 승인된 backup 방식의 읽기·export | 업무 mutation·외부 호출 |
| Restore role | 격리된 restore·validation에 필요한 권한 | 일반 runtime 상시 사용 |

[INFERENCE] Recovery는 안전한 내부 재개 때문에 과권한이 되기 쉬우므로 범용 DB owner가 아니라 허용 work type과 source-domain operation으로 제한합니다. 실제 table·view·procedure·`GRANT` 설계는 WBS-04에서 확정합니다.

[FACT] 실제 Secret 값·Authorization header·webhook URL·cookie와 파생 민감값은 DB의 lifecycle metadata에 저장하지 않습니다. 비밀이 아닌 opaque credential reference/version, 대상 service·account/project, 환경·목적·권한·비용 조건, 상태와 등록·검증·활성화·교체·폐기 시각만 추적합니다. Secret 값이나 그 hash를 업무 식별자로 사용하지 않습니다.

[INFERENCE] 동일 service/account/project/environment/purpose 안의 검증된 key 교체는 credential rotation으로 처리하고, 실제 invocation에 사용한 credential reference/version을 기록합니다. Provider·account/project·환경·목적·비용 경로가 달라지는 교체는 configuration 변경이므로 새 검증·사용자 승인 없이 기존 batch가 자동 전환하지 않습니다.

[FACT] 새 credential 접근·권한·비용 검증과 사용자 활성화 승인 전에는 runtime에 사용하지 않습니다. 활성화 뒤 새 credential이 실패해도 이전 credential·다른 account·provider·유료 경로로 자동 fallback하지 않습니다. 이전 credential은 대상 서비스 접근 실패 또는 제공자의 명확한 폐기 근거가 없으면 폐기 완료로 추정하지 않습니다.

[INFERENCE] Redaction은 사후 문자열 치환에만 의존하지 않고 raw credential·민감 header를 logging/evidence API에 전달하지 않는 구조화 allowlist를 기본으로 합니다. Canary Secret fixture로 Repository·image·DB·backup·command argument·일반 설정·log·metric·trace·exception·AI request·Discord message·test snapshot과 external evidence를 검사해 노출 0건을 확인합니다.

[FACT] Application workload는 schema 변경, CronJob suspend·Deployment scale 변경, 다른 workload 재시작, backup 삭제, production restore, Secret 생성·교체·폐기 또는 자기 DB 권한 확대를 수행하지 않습니다. Migration·kill switch·backup·restore 권한은 별도 운영자 identity와 승인 절차에 둡니다.

[UNKNOWN] 실제 provider scope는 WBS-02 evidence로 제한하고, PostgreSQL role·`GRANT`는 WBS-04·12, Secret loader·rotation은 WBS-11, redaction·canary 검증은 WBS-20·23, Secret·ServiceAccount·RBAC·NetworkPolicy manifest와 배포 검토는 WBS-27~28에서 확정합니다.

#### WBS-03.D Outbound Gate and Operational Pause Contract

[FACT] Outbound gate는 하나의 전역 boolean으로 축약하지 않습니다. 전역 신뢰 조건, operation scope pause, work claim·lease/fencing, configuration binding, service별 contract·credential·cost와 operation별 업무 선행 조건을 순서대로 대조합니다. 조건을 확인할 수 없으면 허용으로 추정하지 않습니다.

```text
전역 신뢰 조건
  → operation scope pause
  → work claim·lease/fencing
  → configuration binding
  → service별 contract·credential·cost
  → operation별 업무 선행 조건
  → invocation 허용 또는 원인별 차단
```

| Operation | 필수 허용 조건 | 차단 시 결과 | Gate가 닫혀도 가능한 안전 동작 |
| --- | --- | --- | --- |
| Prepare/RSS | 목표 시각 전 batch, Prepare claim, DB 신뢰, scope 미중지, RSS contract, runtime 비용 안전 | fetch/attempt 없이 미실행·차단 원인 유지 | deterministic slot·operational event 기록 |
| AI invocation | Prepare binding, valid lease/fencing, prepared attempt, DB 신뢰, AI contract·credential·cost·quota, input allowlist | 새 invocation 없이 후보 차단·미처리 | 기존 attempt의 정확한 late evidence append |
| Discord delivery | committed source result, delivery work claim, timing/recovery 권한, DB 신뢰, Discord contract·credential·cost | 성공으로 기록하지 않고 미전달·차단 | 기존 invocation의 정확한 acceptance evidence append |
| REST reconciliation | exact request/scope, work claim, DB 신뢰, Discord contract·credential·cost | REST attempt 없이 request 대기, feedback `stale`·`unknown` 유지 | 내부 reconciliation request 보존 |
| Feedback mutation | DB 신뢰, 검증된 event identity·사용자·mapping·순서 | feedback 없음으로 추정하지 않고 business projection 차단·근거 부족 유지 | DB 신뢰 시 이미 수신한 raw event append와 reconciliation request; DB 복구 뒤 단절 범위 대조 |
| Gateway session/interaction | Listener scope 미중지, DB event 기록 가능, Discord contract·credential·cost, event/request 검증 | business response·mutation을 정상 처리하지 않고 비확정 상태 유지 | DB 신뢰 시 이미 수신한 raw event·interaction request 보존; 연결 유지·종료 세부는 WBS-07 검증으로 이관 |
| Evaluation | source ledger 신뢰, 명시된 work/scope, 비용 검증된 runtime, 필요한 reconciliation terminal reference 또는 명시된 대조 불가 사유 | `not_measurable` 또는 실행 차단 | calculation 전 exact reconciliation request handoff와 운영 source 불변의 evaluation result append |
| Late evidence | DB 신뢰, exact source attempt·correlation/mapping | 불명확 상태 유지 | 새 외부 호출 없이 append-only evidence 기록 |
| Backup/restore validation | 승인된 범위·identity·저장 위치·DB 절차 | outbound 계속 차단 | backup·restore validation evidence 기록 |

[FACT] AI service만 quota·계약·비용 조건으로 차단돼도 Discord 경로가 안전하면, DB에 전체 선정 불가능 결과가 확정되고 정확한 delivery work를 claim한 뒤 원인별 processing failure notice를 전달할 수 있습니다. Discord gate도 닫혔다면 notice를 보냈다고 기록하지 않고 미전달과 Discord 차단 원인을 보존합니다.

[INFERENCE] Backup 공백 한계 초과, global cost kill switch 또는 DB 신뢰 불명에서는 새 Prepare claim과 RSS fetch를 시작하지 않습니다. 해당 예정 slot은 정상 신규 0건으로 바꾸지 않고 source ledger 신뢰에 따라 `not_executed` 또는 `not_measurable`로 유지하며, 복구 뒤 historical ledger만 등록하고 과거 slot의 RSS·AI·selection·delivery를 소급 실행하지 않습니다.

[FACT] Gate closure는 해당 차단 scope의 신규 domain attempt, `prepared → invocation_started`, 새 외부 호출과 불명확 attempt의 자동 retry·재전송을 금지합니다. DB가 신뢰 가능하면 차단 사유·영향 범위, operational event, 이미 invocation-started인 attempt와 정확히 대응되는 late response·usage·acceptance evidence, 이미 수신한 raw Gateway event, backup/restore validation과 평가 가능한 범위의 결과는 계속 append할 수 있습니다.

[FACT] K3s workload 중지는 이미 외부에 도달한 호출을 되돌리지 않습니다. Kill switch 직전에 invocation-started가 commit된 attempt는 process 종료를 실패 증거로 사용하지 않고, 정확한 late evidence만 연결하며 결과가 없거나 대응이 불명확하면 `external_effect_uncertain`을 유지합니다.

[INFERENCE] 계획된 pause는 `operational_event 기록 → application gate closure·신규 invocation 0건 확인 → 대상 CronJob suspend·Listener scale 0 → 이미 시작된 attempt 대조` 순서로 수행합니다. 비용 발생·credential 침해 같은 긴급 pause는 K3s workload를 먼저 중지하고, DB가 신뢰 가능해지는 즉시 중지 사유·범위·재개 조건을 operational event로 보완합니다.

[FACT] Resume는 자동으로 수행하지 않습니다. DB·restore·backup과 필요한 Discord/feedback reconciliation, configuration·contract·cost·credential 근거, 불명확 외부 효과를 대조하고 필요한 사용자 수동 승인을 operational event에 연결한 뒤 workload를 활성화합니다. Rate/quota 대기 뒤 재시도는 공식 reset 근거와 별도 승인된 retry 정책이 있을 때만 그 scope에서 수행합니다.

[FACT] Listener Deployment가 scale 0이던 기간의 Gateway event는 feedback 없음으로 추정하지 않습니다. 재연결 뒤 exact mapping 범위의 reconciliation request를 만들고 REST 대조 전에는 `stale`·`unknown`을 유지합니다. Feedback REST 결과만으로 delivery acceptance나 recovery 상태를 자동 확정하지 않습니다.

[INFERENCE] Pause scope는 전체 external operation, RSS, AI, Discord delivery, Discord REST, Gateway listener/interaction, 특정 configuration·credential·workload와 backup/restore 재개 차단을 구분합니다. 정확한 enum은 WBS-04에서 정하지만 AI-only 차단이 안전한 Discord failure notice를 막거나 Discord-only 차단이 내부 selection 보존을 막지 않도록 조합 규칙을 검증합니다.

[FACT] Outbound pause 중에도 runtime 비용 0원과 DB/source ledger 신뢰가 확인되면 외부 API 없는 Evaluation을 실행할 수 있습니다. Source가 불완전하면 Hard Gate를 통과시키지 않고 `not_measurable`을 기록하며 Evaluation 결과가 outbound를 자동 재개하지 않습니다.

[FACT] 외부 호출 전 비용 gate는 유료 청구 불가능 설정·무료 plan/quota·승인 account/project/credential 및 runtime 등 전체 실행 경로의 사전 근거를 사용합니다. 실제 월별 billing 결과가 아직 없다는 이유만으로 첫 운영 호출을 차단하지 않지만, 월별 근거가 부족한 상태를 Cost Hard Gate `pass` 또는 0원으로 기록하지 않습니다.

[UNKNOWN] Gate state·reason code와 query·transaction은 WBS-04·11·13, provider별 rate/quota reset·retry는 WBS-06·15·17·19·23, backup 공백·recovery gate는 WBS-08·21, 비용 evidence는 WBS-20·26·30, 실제 K3s pause/resume·부분 실패·runbook은 WBS-27~29에서 확정합니다.

[INFERENCE] WBS-03의 planned negative verification은 다음을 포함합니다.

- C1 configuration으로 시작한 batch는 C2 활성화 뒤에도 C1을 유지합니다.
- C1이 비용·계약 조건을 더는 충족하지 않으면 C2로 자동 전환하지 않고 차단합니다.
- Prepare 이외 역할은 AI credential에 접근할 수 없고 Evaluation 역할은 외부 credential을 받지 않습니다.
- Secret 원값·부분값·파생 민감 header는 DB·log·metric·trace·AI input에 나타나지 않습니다.
- RSS·AI·Discord delivery·REST의 신규 외부 효과는 해당 work/trigger·contract·cost와 필요한 유효 lease/fencing token이 없으면 시작하지 않습니다. Gateway session/interaction은 listener scope·DB 기록 가능성·Discord contract·credential·cost 조건을 별도로 검증합니다.
- kill switch 뒤에는 차단 scope의 신규 외부-effect work claim·attempt·invocation이 없고, 안전한 evidence·backup/restore·조건부 Evaluation만 명시된 경계에서 허용하며 재개 근거나 필요한 사용자 승인이 없으면 자동 재개하지 않습니다.
- RSS·AI·Discord delivery·REST reconciliation·feedback mutation의 차단 사유를 서로 구분합니다.

[FACT] 위 검증은 이 단계의 계획이며 아직 실행 결과가 아닙니다. 실제 구현·negative/fault test·K3s 검증은 WBS-11·13·20·23~24·27~28에서 수행합니다.

### WBS-04 Internal Review Checkpoints

[FACT] WBS-04는 논리 모델을 즉시 SQL로 변환하는 단일 구현 작업이 아니라, 안정된 physical baseline을 먼저 제공하고 WBS-05~08의 상세 계약을 반영해 최종 closure하는 설계 work package입니다. 아래 checkpoint는 독립 검토 단위이며 새로운 상위 WBS Task가 아닙니다.

| ID | 검토 범위 | 계획 산출물 | 선행·closure 조건 |
| --- | --- | --- | --- |
| WBS-04.A | Logical-to-physical disposition·canonical ownership | 승인된 37개 logical entity의 disposition·canonical fact owner·reference-only·mutation class·role·중복 금지와 no-table/MVP-B-deferred register | WBS-01~03, WBS-02 관련 evidence; 37/37 coverage와 사용자 baseline 승인 |
| WBS-04.B | Identity·reference·type·integrity | identity/reference·type decision·integrity enforcement register, physical PK·logical key·external ID·lineage 분리, null·polymorphic reference·delete policy·type evidence | WBS-04.A; WBS-05 필수 baseline에는 blocking unknown 0건, provider·Discord field는 WBS-04.D owner 명시 |
| WBS-04.C | Mutation·transaction·query/index | append-only/current state 경계, WBS-05 transaction·lease 반영, query-access path와 index/constraint mapping | WBS-04.A~B baseline과 WBS-05 승인 |
| WBS-04.D | External·evaluation·operation closure | WBS-06~08의 provider/Discord/evaluation/backup 계약을 반영한 typed field·allowlist·size·reference closure | WBS-06~08 승인과 관련 spike evidence |
| WBS-04.E | Migration·rollback·verification | baseline/upgrade/forward-fix, 비production reset, data-safe production rollback·restore handoff와 schema 검증 계획 | WBS-04.C~D 승인; WBS-09 전 최종 closure |

```text
WBS-04.A~B baseline 승인
  → WBS-05~08 상세 계약
  → WBS-04.C~E 최종 정합성·migration closure
  → WBS-09 Coding Readiness Check
```

[FACT] WBS-04.A disposition register는 각 논리 항목을 physical table, association table, view/query projection, 기존 canonical record에 통합, external evidence reference, MVP-B deferred 또는 명시적 no-table 중 하나로 분류합니다. 논리적 책임 분리는 table-per-entity를 뜻하지 않습니다.

[FACT] 별도 `batch_execution`, `evaluation_run`, `work_lease`, AI intent, delivery-trigger, selection-finalization work, recovery item, receipt-scope, Hard Gate 또는 activation snapshot canonical table을 기본안으로 만들지 않습니다. 중복 article·analysis·delivery payload를 복제하지 않고, `article_identity_tombstone`과 자동 Retention lifecycle은 MVP-B deferred로 유지합니다.

[INFERENCE] WBS-04.B~C의 invariant register는 각 불변식에 대해 DB constraint, transaction/lock, application validation 또는 외부 계약 검증 중 어느 계층이 강제하는지와 negative fixture owner를 지정합니다. Query-index mapping은 실제 filter·ordering·예상 cardinality와 검증 owner가 없는 추측성 index를 승인하지 않습니다.

[FACT] WBS-04.D 전에는 provider별 미확정 field를 자유형 raw payload로 숨기지 않습니다. JSON/JSONB 사용 여부도 WBS-06~08의 evidence kind·field allowlist·schema version·size 제한·secret 제외·canonical 결과 중복 금지 기준을 받은 뒤 결정합니다.

[INFERENCE] Migration rollback은 비production 빈 DB의 reset/recreate, application/image rollback, backward-compatible schema 유지, forward-fix migration과 backup restore를 구분합니다. Production destructive down migration이나 데이터 삭제는 기본 복구 방법으로 계획하지 않고 별도 backup·restore 증거와 사용자 승인이 필요합니다.

[UNKNOWN] 실제 schema/table/column/type·ID·constraint·index·partition, migration/ORM 도구, SQL transaction·lock/isolation과 upgrade 호환 범위는 checkpoint별 승인 전 확정하지 않습니다. WBS-04 최종 closure에는 모든 logical 항목 disposition, blocking physical unknown 0건, Secret·자유형 raw payload·MVP-B lifecycle의 무승인 포함 0건이 필요합니다.

#### WBS-04.A Disposition and Ownership Review Contract

[FACT] 현재 승인된 Logical Data Model의 최상위 logical entity는 37개입니다. WBS-04.A 실행 시 각 entity는 disposition register에 정확히 한 번 나타나야 하며, DDI-01~10과 MIN-01~08은 최소 하나 이상의 disposition 근거에 연결돼야 합니다.

| Register field | 계획 목적 |
| --- | --- |
| Logical entity·domain | 승인된 37개 entity와 책임 영역 식별 |
| Related DDI/MIN/DR | disposition과 ownership의 승인 근거 |
| Disposition class | table·association·consolidated typed relation·view/query projection·reference-only·no-table·MVP-B deferred 구분 |
| Canonical fact owner | 원본 값을 소유하는 단 하나의 logical owner |
| Reference-only facts | 다른 owner에서 FK/reference로만 조회할 값 |
| Mutation class | immutable·append-only·current mutable·projection 구분 |
| Creating/updating/reading role | 최초 생성, 허용 변경과 조회 역할 경계 |
| Forbidden duplication | association·summary·evidence에 반복 저장하면 안 되는 값 |
| MVP scope | MVP-A 또는 MVP-B deferred |
| Downstream closure | WBS-04.B~D 중 field·constraint 결정을 받을 owner |
| Realization / verification owner | 해당 WBS-12~22 realization owner와 WBS-23~25 verification owner의 구현·검증 연결 |

[FACT] Logical entity와 physical table은 1:1 관계로 가정하지 않습니다. Disposition은 독립 table, association, subtype을 구분하는 consolidated typed relation, SQL view/application query projection, 다른 canonical record의 reference-only 표현, 명시적 no-table 또는 MVP-B deferred 후보를 비교합니다. 실제 relation 수와 통합 단위는 WBS-04.A 실행·승인 전 확정하지 않습니다.

[FACT] 다음 개념은 별도 canonical relation을 기본안으로 만들지 않는 negative disposition register에 포함합니다.

- `batch_execution`, `evaluation_run`은 projection입니다.
- 별도 `work_lease`, AI intent, delivery-trigger, selection-finalization work를 만들지 않습니다.
- 별도 recovery item·receipt-scope·Hard Gate·activation snapshot·external-service subject canonical relation을 만들지 않습니다.
- 별도 missing-article feedback entity 대신 제한된 `feedback_state.feedback_kind`를 사용합니다.
- `article_identity_tombstone`과 자동 Retention lifecycle은 MVP-B deferred입니다.

[FACT] No-table은 사실을 버린다는 뜻이 아니라 승인된 canonical record·association 또는 projection에서 같은 사실을 재사용한다는 뜻입니다. Association은 관계의 순서·범위·역할 같은 고유 속성과 source/target reference만 소유하고, 제목·요약·link·AI 결과·delivery payload 같은 canonical 값을 복제하지 않습니다.

[INFERENCE] 각 후보 값은 canonical source value, 당시 immutable result snapshot이 소유할 값, reference-only 값, 재계산 가능한 projection, 감사 목적 append-only observation 또는 금지된 중복 중 하나로 분류합니다. 같은 canonical fact의 owner가 둘 이상이면 WBS-04.A baseline을 승인하지 않습니다.

[FACT] WBS-03.C의 최소권한 설계와 연결하기 위해 disposition register는 entity별 creating/updating/reading role을 기록합니다. 이는 실제 PostgreSQL `GRANT`가 아니며 role과 physical relation 권한은 WBS-04.B~C·12에서 확정·구현합니다.

[FACT] MVP-A physical baseline에 외부 원문 기사 본문, Secret·credential 원값·민감 header, 불필요한 provider 전체 응답, data lake/object storage 또는 MVP-B lifecycle을 암묵적으로 포함하지 않습니다. PostgreSQL로 수용할 수 없다는 근거가 발견되면 새 저장 기술을 자동 추가하지 않고 Architecture 영향과 사용자 승인을 별도로 요청합니다.

[INFERENCE] WBS-04.A disposition checkpoint 완료 조건은 37/37 unique disposition, DDI 10개·MIN 8개 coverage, canonical fact별 owner 1개, projection/no-table의 별도 canonical relation 0건, association payload 복제 0건, Secret·민감 storage 후보 0건과 MVP-B의 MVP-A 포함 0건입니다. 미결정 항목은 근거·차단 영향·후속 owner가 있는 `[UNKNOWN]`으로 남기고 사용자 disposition checkpoint 승인 뒤 WBS-04.B로 진행합니다. Physical baseline 승인은 WBS-04.A와 WBS-04.B를 함께 완료·검토한 뒤에만 부여합니다.

#### WBS-04.B Identity, Reference, Type, and Integrity Review Contract

[FACT] WBS-04.B는 실제 SQL schema를 작성하는 작업이 아니라 WBS-04.A의 disposition별 identity·reference·type·integrity 결정을 누락 없이 기록하고 후속 구현·검증 owner를 지정하는 계획 checkpoint입니다. 실행 산출물은 다음 세 register로 분리합니다.

| Register | 필수 계획 항목 |
| --- | --- |
| Identity / reference register | logical identity, physical PK 후보, logical unique key, source·lineage reference, internal/external ID 구분, ID scope, nullable 조건, deletion policy와 canonical owner |
| Type decision register | 값 category·의미, 후보 type, precision·length·collation 고려사항, invalid·unknown 표현, migration 영향과 evidence 의존성 |
| Integrity enforcement register | invariant, primary·supporting enforcement layer, concurrency 경계, 위반 시 결과, negative fixture와 구현·검증 owner |

[FACT] Surrogate physical PK, domain의 logical business key, 외부 시스템 ID와 lineage reference는 동일 개념으로 취급하지 않습니다. 복합 logical key를 구분자 문자열 하나로 합치거나 hash/digest만을 canonical identity로 사용하는 안은 원본 구성요소·scope·collision 처리와 재현 가능한 검증 근거 없이 baseline 후보로 승인하지 않습니다. Digest는 무결성·중복 탐지 보조값일 수 있지만 canonical source value를 대체하지 않습니다.

[INFERENCE] Reference register는 일반 FK 후보 외에도 여러 source 종류를 가리키는 polymorphic reference가 필요한지, subtype별 typed relation 또는 명시적 reference 쌍으로 제한할지를 비교합니다. 어느 표현이든 허용 source 종류, exactly-one 규칙, 존재성 검증, scope 일치, nullable 사유와 잘못된 조합의 negative fixture가 필요합니다.

[FACT] `NULL`은 관측되지 않음, 적용 불가, 알 수 없음, stale, 측정 불가, 불확실 또는 정상적인 0 값을 하나로 합치는 기본 표현으로 사용하지 않습니다. 각 nullable 후보는 부재 의미, 생성·갱신 주체, 허용 상태와 조회·평가 영향을 기록하고, 의미가 다른 상태는 승인된 상태 값 또는 별도 evidence로 구분합니다.

[INFERENCE] 시간 값은 실제 type 이름보다 먼저 instant·KST local civil time·calendar date·daily slot 중 의미를 정하고, occurred·observed·recorded·invocation·acceptance·lease·cutoff 시각을 구분합니다. Lease·claim 만료처럼 동시성 판단에 쓰이는 시각은 DB clock 등 단일 권위 후보와 precision·비교 규칙을 명시해야 하며 application host clock을 암묵적 기준으로 두지 않습니다.

[FACT] Raw RSS의 exact link와 원문 식별 evidence는 수집 당시 값을 보존하며, URL normalization을 승인되지 않은 동일성 판정으로 사용하지 않습니다. 외부 ID는 내부 PK와 분리하고 provider·Discord가 정의하는 문자열·숫자 표현, scope, 길이와 lossless round-trip을 evidence로 확인합니다. Provider·Discord별 최종 field 결정은 WBS-06·07과 WBS-04.D가 소유합니다.

[INFERENCE] Status·outcome·reason처럼 세 가지 이상의 의미를 갖는 값은 boolean으로 축소하지 않습니다. PostgreSQL enum, check-constrained text 또는 reference relation 후보는 값 집합의 안정성, forward compatibility, migration 비용과 invalid value 검증을 비교한 뒤 결정합니다. 숫자 값은 count·money·ratio·duration·token/usage처럼 단위와 exactness를 먼저 정의합니다.

[FACT] JSON/JSONB는 미확정 외부 계약이나 여러 canonical field를 숨기는 escape hatch로 사용하지 않습니다. 필요 후보는 WBS-04.D에서 evidence kind, field allowlist, schema version, size 제한, Secret·민감값 제외, canonical 값 중복 금지와 조회 필요성을 근거로 별도 승인합니다.

[INFERENCE] FK deletion policy의 기본 검토 후보는 canonical evidence와 감사 관계를 보존하는 `RESTRICT`/`NO ACTION` 계열입니다. MVP-B Retention 정책이 승인되기 전에 광범위한 `ON DELETE CASCADE`, 자동 purge 또는 연쇄 물리 삭제를 기본안으로 확정하지 않습니다. 삭제 대신 상태 전이·비활성화·참조 보존이 필요한지는 entity별로 기록합니다.

| Enforcement layer | 주 책임 후보 |
| --- | --- |
| DB constraint | 단일 row 또는 declarative cross-row identity·reference·domain invariant |
| Transaction·lock | 경합하는 claim·lease·상태 전이와 원자적 갱신 |
| Application validation | 승인된 상태 machine·command precondition·external input validation |
| External contract validation | provider·Discord·RSS의 실제 계약과 수락 evidence 확인 |
| Evaluation | 운영 write를 강제하지 않는 품질·gate 판정과 재현 증거 |

[INFERENCE] 각 invariant는 primary enforcement layer 하나와 필요한 supporting layer를 구분합니다. Application 검사만으로 경쟁 조건을 막는다고 가정하거나, DB constraint만으로 외부 수락·품질 의미를 보장한다고 표현하지 않습니다. 위반 시 상태·재시도 가능성·notice·관측 evidence와 negative fixture owner를 함께 지정합니다.

[INFERENCE] WBS-04.A~B baseline 완료 조건은 WBS-05가 요구하는 내부 identity, reference, null/time 의미와 핵심 integrity invariant에 blocking `[UNKNOWN]`이 0건이고, 모든 항목에 근거·primary owner·negative verification owner가 있는 것입니다. Provider·Discord 의존 field는 임의 placeholder type으로 닫지 않습니다. Logical 의미, canonical owner, ID scope, lossless 보존 조건과 null·invalid 의미를 baseline에서 먼저 확정하고, evidence-dependent 물리 parameter만 차단 영향과 WBS-04.D closure owner를 명시해 baseline 이후로 이관할 수 있습니다.

[UNKNOWN] 실제 PK 전략, PostgreSQL type·precision·length·collation, enum/check 선택, FK·unique·exclusion constraint, polymorphic reference 표현, deletion/cascade 정책과 JSON/JSONB 채택 여부는 WBS-04.B 실행 evidence와 사용자 승인 전 확정되지 않습니다. 이 review contract의 승인은 그 물리 결정을 승인했다는 뜻이 아닙니다.

### WBS-05 Internal Review Checkpoints

[FACT] WBS-05는 exactly-once 외부 실행을 가정하는 단일 설계 작업이 아니라, 중복 trigger·worker 교체·중단·late evidence에서도 저장된 상태와 근거로 금지 동작을 차단하는 의미적 concurrency contract입니다. 아래 checkpoint는 독립 검토 단위이며 새로운 상위 WBS Task가 아닙니다.

| ID | 검토 범위 | 계획 산출물 | 선행·closure 조건 |
| --- | --- | --- | --- |
| WBS-05.A | Logical work key·trigger·admission | typed work key register, target·external-effect scope, trigger/identity 분리, duplicate coalescing·admission 판정, no-table/projection 경계 | WBS-04.A~B baseline; 물리 key는 WBS-04.C, 일부 중첩 reconciliation·evaluation 재실행 key는 WBS-07·08 owner 명시 |
| WBS-05.B | 상태 전이·결과 경계 | coordination·execution·external attempt·business result·projection state-axis register, terminality와 transition authority·precondition·evidence·illegal transition | WBS-05.A; work attempt mutation은 WBS-04.C, AI·선정·Discord·evaluation domain terminal은 WBS-06~08 closure |
| WBS-05.C | Claim·lease·fencing·transaction | claim/attempt·renew·expire/reclaim·internal commit·invocation start·completion transaction catalog, DB clock·token ABA 방지·commit 불명확 재조회 계약 | WBS-05.A~B와 SPK-04 evidence; external uncertainty는 WBS-05.D, SQL lock/isolation/constraint는 WBS-04.C closure |
| WBS-05.D | External invocation·불명확 효과 | operation-class·crash-window matrix, prepared/resume·new-attempt retry 분리, uncertain 자동 재호출 금지, late evidence applicability·보안·capability handoff | WBS-05.A~C; RSS는 WBS-14, provider·Discord idempotency/correlation은 WBS-06·07, physical evidence는 WBS-04.D closure |
| WBS-05.E | Finalization·handoff·fault closure | finalization invariant·durable handoff register, committed-result-only delivery, current/delayed/recovery 구간 분리, DB trust·lost-handoff·crash-point closure | WBS-05.A~D; handoff 물리화는 WBS-04.C·07, backup trust는 WBS-08, fault owner는 WBS-23~25 확인 |

```text
WBS-05.A~B logical work·state contract
  → WBS-05.C claim·lease·transaction semantic
  → WBS-05.D external-effect uncertainty boundary
  → WBS-05.E finalization·handoff·fault closure
  → WBS-04.C physical transaction·constraint closure
```

[FACT] `work_item`의 현재 실행 요약, append-only `work_attempt`와 RSS·AI·선정·전달 domain result를 서로 대체하지 않습니다. 별도 `work_lease`, `batch_execution` 또는 selection-finalization canonical work를 기본안으로 만들지 않으며, 승인된 projection·Prepare work 경계를 따릅니다.

[INFERENCE] Idempotency는 동일 logical key의 중복 work·result·외부 invocation을 저장 상태로 억제하고 이미 확인된 결과를 재사용하는 내부 계약입니다. 외부 서비스가 exactly-once를 제공한다고 가정하지 않으며 provider·Discord의 실제 idempotency key·correlation·acceptance capability는 WBS-06·07의 evidence로 닫습니다. 지원이 불명확하거나 없는 경우 WBS-05의 기본 경계는 자동 재호출·재발송 금지와 명시적 `external_effect_uncertain` 유지입니다.

[FACT] WBS-05는 상태 전이의 precondition·authority·원자성·금지 결과를 결정하지만 실제 PostgreSQL PK·constraint·lock·isolation·SQL 표현을 확정하지 않습니다. 의미적 invariant와 필요한 동시성 강도를 WBS-04.C에 입력하고, WBS-04.C가 승인된 물리 enforcement와 query/index 결정을 반환합니다.

[FACT] WBS-05는 외부 호출의 공통 prepared/invocation/evidence 경계와 DB 신뢰 fail-closed 정책을 결정합니다. Provider별 retry terminal·late AI 결과 수용은 WBS-06, Discord acceptance·reconciliation·receipt·resend는 WBS-07, backup trust·evaluation work는 WBS-08이 소유하며 미확정 domain 계약을 WBS-05의 일반 상태나 placeholder로 숨기지 않습니다.

[INFERENCE] 각 checkpoint는 transition source/target, initiating role·trigger, required lease/token·gate, 읽고 쓰는 canonical record, transaction 전후 crash 결과, 재claim·retry 가능성, 사용자 notice·운영 evidence, 금지 동작과 negative fixture owner를 포함합니다. Claim에 실패한 trigger가 새 attempt·domain attempt·외부 호출을 만들지 않는지 별도로 검증합니다.

[INFERENCE] WBS-05 완료에는 최소한 동시 claim, lease 만료·교체, stale worker 재개, claim commit 전후 중단, internal result commit 전후 중단, prepared 전후 중단, invocation-started 후 응답 유실, 정확한·중복·상충·불명확 late evidence, finalization commit 전후 중단과 DB 무결성 불명 fixture가 필요합니다. 각 fixture는 work·attempt·domain result·external invocation 수, 상태·token·evidence lineage와 후속 owner를 대조해야 합니다.

[UNKNOWN] 실제 lease 기간·갱신 cadence·token 표현, SQL isolation·lock·constraint, reconciliation scope의 부분 중첩, provider correlation과 Discord idempotency/acceptance capability는 관련 spike와 WBS-04.C·06·07 승인 전 확정되지 않습니다. 이 `[UNKNOWN]`은 owner·차단 영향·fail-closed 기본 동작 없이 WBS-05 closure를 통과할 수 없습니다.

#### WBS-05.A Logical Work Key, Trigger, and Admission Review Contract

[FACT] WBS-05.A 실행 산출물은 logical work 종류별 typed key·trigger·admission register입니다. 실제 key 값·column·constraint를 정하는 문서가 아니며 다음 필드를 빠짐없이 계획합니다.

| Register field | 계획 목적 |
| --- | --- |
| Work type / namespace | Prepare·AI analysis·delivery release·reconciliation·recovery·evaluation 사이 key 충돌 방지 |
| Canonical target | scheduled batch, batch candidate, selection result, recovery event 등 처리 대상과 owner 식별 |
| External-effect scope | 같은 target에서도 별도로 허용되는 외부 효과의 idempotency 경계 |
| Typed key components | 원래 구성요소·scope를 보존하고 문자열 결합·hash-only identity 방지 |
| Configuration / contract boundary | key 구성요소인지 admission precondition인지 후속 검토할 version 경계 |
| Trigger sources | 같은 logical work를 요청할 수 있는 scheduler·state change·recovery·operator 원인 |
| Eligible role | work 등록·조회·claim을 요청할 수 있는 역할과 금지 역할 |
| Admission result | create·reuse·historical-ledger-only·blocked·completed-result no-op 후보 구분 |
| Duplicate / coalescing rule | 동일·부분 중첩·상이한 scope가 기존 work에 수렴하는 조건 |
| Closure owner | WBS-04.C·06·07·08 중 미확정 key·contract 결정을 닫을 owner |

[FACT] Register는 예정 batch Prepare, batch candidate AI 분석, delivery release, reconciliation request, recovery case 처리와 사용자 요청 evaluation의 여섯 logical work 종류를 최소 coverage로 사용합니다. 새로운 work type을 암묵적으로 추가하거나 trigger마다 별도 canonical work를 만들지 않습니다. Backup·restore 등 후속 운영 작업의 ledger 사용 여부는 WBS-08에서 승인된 logical model 범위 안에서 별도로 닫습니다.

[FACT] Logical work identity는 실행시킨 trigger의 발생 시각, CronJob·Job·Pod 이름이나 UID, process·thread, claim owner, `work_attempt` ID 또는 임의 run ID가 아닙니다. 이러한 값은 실행·관측 evidence가 될 수 있지만 동일 의무의 재실행마다 새 logical work를 만드는 canonical key로 사용하지 않습니다.

[INFERENCE] Typed key는 work namespace와 원래 canonical reference·scope 구성요소를 비교 가능하게 보존하고 key interpretation version을 식별해야 합니다. 문자열 구분자 조합이나 digest만으로 원본 key를 대체하지 않으며, digest를 보조값으로 검토할 경우 canonical serialization·ordering·algorithm version·collision 검증과 원본 구성요소 대조가 필요합니다. 실제 물리 표현과 uniqueness enforcement는 WBS-04.C가 소유합니다.

[FACT] Delivery release key는 scheduled regular delivery의 target `scheduled_batch`, 처리 지연 full result의 source `selection_result`, receipt confirmation·승인된 1회 즉시 재전송·사용자 선택 recovery의 exact source `recovery_event` 또는 interaction scope를 구분합니다. 같은 logical delivery work가 만드는 `delivery_set`은 최대 하나이며, work 생성 계기와 segment가 참조하는 원래 selection result를 서로 대체하지 않습니다.

[FACT] Reconciliation key는 trigger 시각이나 원인이 아니라 추적된 system message·승인 사용자·허용 reaction의 exact scope와 적용 configuration/contract boundary를 나타냅니다. Resume 실패·DB 복구·Gateway event 기록 실패·evaluation 직전 trigger가 같은 exact scope를 가리키면 기존 `work_item`을 재사용합니다. 일부만 겹치는 scope의 병합·분할과 실제 Discord identifier 계약은 WBS-07의 blocking `[UNKNOWN]`으로 이관합니다.

[FACT] 예정 전달 시각 전의 slot은 deterministic `scheduled_batch`를 idempotent하게 등록하고 Prepare work admission을 검토할 수 있습니다. 목표 시각 뒤 또는 서비스 복구 뒤 발견한 과거 slot은 historical ledger record만 등록하며 Prepare work item·work attempt·RSS fetch·AI 분석·selection·Discord delivery를 만들지 않습니다. 미실행·불완전·측정 불가는 정상 신규 0건으로 변환하지 않습니다.

| Admission 판정 후보 | 계획상 의미 | 금지 동작 |
| --- | --- | --- |
| create | 같은 typed logical key가 없고 등록 조건을 충족 | trigger instance 값을 새 canonical identity로 사용 |
| reuse | 같은 exact key의 기존 work가 존재 | 새 work 또는 중복 domain work 생성 |
| historical-ledger-only | 목표 시각 뒤 과거 scheduled slot 보완 | Prepare work·attempt 또는 pipeline 시작 |
| no-admission | target·scope·시각 조건상 logical obligation을 만들 수 없거나 아직 만들 대상이 아님 | 존재하지 않는 work의 `blocked` 상태를 가장하거나 key를 임의 생성 |
| completed-result no-op | immutable 완료 결과가 이미 존재 | 새 attempt·결과 재계산·외부 효과 반복 |

[INFERENCE] Identity/admission 판정과 post-admission coordination 판정을 분리합니다. `create` 또는 `reuse`로 존재가 확인된 work만 WBS-05.B의 transition contract에 따라 claimable·waiting·blocked 여부를 가질 수 있습니다. Configuration·contract·cost·DB trust 조건이 충족되지 않아도 logical obligation을 보존해야 하는 work는 먼저 exact key로 create/reuse한 뒤 durable blocked/waiting 사유를 기록하며, 단순 scope 부적합·과거 slot 금지·대상 부재의 no-admission과 혼동하지 않습니다.

[INFERENCE] Active·waiting·blocked·`external_effect_uncertain` work를 만난 trigger는 새 key를 만들어 우회하지 않고 같은 work를 읽어 후속 상태 판정을 요청합니다. 실제 재claim 가능 여부와 transition은 WBS-05.B~D가 결정하며, claim 실패는 새 `work_attempt`·domain attempt·외부 호출을 만들지 않습니다.

[FACT] Evaluation은 사용자 요청 기반 logical work입니다. 같은 scope·cutoff·metric definition·input manifest scheme의 검증 재실행, 새 definition 또는 late evidence를 반영한 새 요청이 기존 work의 새 attempt인지 별도 logical work인지에 대한 정확한 key 경계는 WBS-08이 닫습니다. 어떤 경우에도 기존 immutable evaluation snapshot을 update하거나 late observation만으로 자동 evaluation을 시작하지 않습니다.

[INFERENCE] WBS-05.A 완료 조건은 승인된 여섯 work 종류의 register coverage, key 구성요소별 canonical owner, trigger와 identity의 분리, 동일 key의 단일 work 수렴, delivery effect scope의 구분, 과거 slot의 pipeline admission 0건, 미확정 항목의 blocker·fail-closed 동작·closure owner 지정입니다. 동일 의무의 반복·동시 trigger, 다른 target의 유사 key, 완료·차단·불명확 work와 과거 slot fixture를 후속 negative verification에 연결합니다.

[UNKNOWN] 실제 key 자료형·column·constraint·canonical serialization과 digest 사용, configuration/contract version의 key 포함 여부, reconciliation 부분 중첩, evaluation 재실행 key 및 backup·restore의 work ledger 적용 여부는 WBS-04.C·07·08 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 logical key catalog 결과를 승인했다는 뜻이 아닙니다.

#### WBS-05.B State Transition and Result Boundary Review Contract

[FACT] WBS-05.B 실행 산출물은 하나의 전역 상태표가 아니라 canonical owner별 state-axis register와 transition register입니다. 실제 enum·code·column을 정하는 문서가 아니며, 다음 축을 서로 대체하거나 한 상태 값으로 합치지 않습니다.

| 상태 축 | Canonical owner | 계획상 책임 | 다른 축으로 추정하면 안 되는 것 |
| --- | --- | --- | --- |
| Work coordination | `work_item` | logical work의 현재 claim·lease·대기·차단·완료 요약 | AI 성공, selection 결과, Discord 수락, evaluation 판정 |
| Work execution history | `work_attempt` | claim 성공 execution의 owner·token·시작·종료·outcome 이력 | domain result payload·외부 수락 결과 |
| External domain attempt | AI·delivery·REST domain attempt | 호출 준비·시작·응답·오류 또는 외부 효과 불명확 경계 | logical work 전체 성공·재실행 권한 |
| Business result | candidate·selection·delivery·recovery·evaluation owner | 사용자·운영 의미의 canonical 처리·선정·수락·복구·평가 결과 | worker lifecycle·lease 상태 |
| Read projection | ledger와 domain result 조합 조회 | 미실행·불완전·측정 불가와 운영·평가 해석 | 새로운 canonical work 또는 result 상태 생성 |

[FACT] Work 실행 종료는 AI 분석 성공, `full_selection`, Discord `accepted` 또는 Hard Gate `pass`를 의미하지 않습니다. 반대로 domain result가 이미 immutable하게 고정됐으면 후속 trigger는 저장된 결과를 읽어 work를 완료·no-op 처리할 수 있지만, 해당 결과를 재계산하거나 다른 상태 축에 복사하지 않습니다.

| Transition register field | 계획 목적 |
| --- | --- |
| State axis·canonical owner | 전이가 어느 entity와 책임 축에 속하는지 식별 |
| Source / target category | 허용 전이 방향과 되돌림·재진입 금지 여부 |
| Initiating role·trigger | 전이를 요청할 수 있는 역할과 계기 |
| Preconditions | 필요한 source record·domain result·completion·evidence 조건 |
| Lease / token requirement | 현재 fencing 권한이 필요한 전이와 late evidence 예외 구분 |
| Gate requirements | DB trust·configuration·contract·cost·credential 조건 |
| Transaction boundary | 함께 고정하거나 대조해야 하는 work·attempt·domain result |
| Terminality·retry/reclaim | 축별 terminal 의미와 재claim·새 attempt 가능 여부 |
| Required evidence | 전이 근거, 관측 시각, source lineage와 사유 |
| Illegal transition·fixture owner | 반드시 거부할 전이와 WBS-23~25 검증 owner |

[INFERENCE] Terminality는 상태 축별로 판정합니다. 하나의 `work_attempt`가 종료돼도 logical work가 승인된 새 attempt를 허용할 수 있고, 개별 AI attempt 실패만으로 candidate나 batch 전체가 terminal이 되지 않습니다. `blocked`, `waiting`, safe retry 대기와 `external_effect_uncertain`은 성공이 아니며, lease 만료·시간 경과·새 trigger만으로 성공·실패 또는 자동 재시도 가능 상태로 바꾸지 않습니다.

[FACT] `external_effect_uncertain`은 invocation이 시작됐으나 안전한 응답·오류 근거가 없는 domain attempt의 불명확 경계입니다. 정확히 대응하는 late evidence가 도착해 승인된 domain 조건을 충족할 때만 그 source attempt와 관련 업무 결과를 해소할 수 있으며, 중복·상충·출처 불명 evidence는 불명확 상태와 사유를 유지합니다. 구체적인 AI·Discord 적용은 WBS-06·07이 닫습니다.

[FACT] `not_executed`, `incomplete`, `not_measurable`은 source ledger 완전성·Prepare attempt·final result를 읽어 만든 projection이며 일반 `work_item` 상태로 간주하지 않습니다. `normal_no_new_candidates`, `selection_summary_no_articles`, `processing_failure_notice`는 immutable selection result의 completion·logical result·qualifier이고 work execution 상태가 아닙니다.

[FACT] Discord delivery acceptance, recipient-observed receipt, feedback `present`·`absent`·`stale`·`unknown`, recovery event와 evaluation `pass`·`fail`·`not_measurable`도 각각 승인된 domain owner에 남습니다. Work·REST·evaluation execution의 종료 상태로 이 결과를 추정하거나, 관련 근거가 없다는 이유로 정상 0·없음·수락·통과를 만들지 않습니다.

[INFERENCE] Work coordination transition은 current logical key, expected state/version, lease·token과 필요한 domain precondition을 다시 읽어 stale write를 차단해야 합니다. Claim 실패는 execution이 시작되지 않았으므로 새 `work_attempt`나 상태 성공 전이를 만들지 않습니다. 실제 compare-and-set, lock, isolation과 constraint는 WBS-05.C의 의미 계약을 거쳐 WBS-04.C에서 물리화합니다.

[UNKNOWN] `work_attempt`의 append-only 이력을 물리적으로 insert 후 종료 정보 finalize-once로 표현할지, 종료 event를 별도로 append할지와 correction 처리 방식은 WBS-04.C에서 mutation class·constraint·감사 보존 기준으로 결정합니다. 어떤 후보도 owner·token·시작·종료·outcome 이력을 덮어쓰거나 삭제해 과거 claim을 잃게 해서는 안 됩니다.

[INFERENCE] WBS-05.B 완료 조건은 모든 planned state category가 정확히 하나의 canonical 축·owner에 속하고, 각 transition에 initiator·precondition·lease/gate·transaction·evidence·terminality·illegal fixture owner가 있으며, 축간 추정 전이가 0건인 것입니다. Work 완료/AI 실패/selection 미완료/Discord 응답 유실/REST 실패/evaluation 실행 성공의 조합 fixture에서 정상 0건·수락·feedback 없음·Hard Gate pass 오판이 없어야 합니다.

[UNKNOWN] 실제 상태 enum·reason code, work attempt finalize 방식, provider별 retry terminal, 전체 선정 불가능 판정, Discord acceptance·recovery terminal 및 evaluation 결과 code는 WBS-04.C·06~08 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 state machine 결과를 승인했다는 뜻이 아닙니다.

#### WBS-05.C Claim, Lease, Fencing, and Transaction Review Contract

[FACT] WBS-05.C 실행 산출물은 claim/lease/fencing decision register, transaction semantic catalog와 DB 결과 불명확 재조회·fault matrix입니다. 실제 lease 값·token type·SQL/ORM 구현을 정하는 문서가 아니며, 각 의미 계약을 WBS-04.C의 physical enforcement owner에 전달합니다.

| Lease / fencing register field | 계획 목적 |
| --- | --- |
| Logical work type·key | claim 대상과 동시 실행 경계 식별 |
| Eligible state·role | claim·renew·complete를 요청할 수 있는 상태와 역할 |
| Authoritative clock | lease 획득·유효·만료 비교에 사용할 PostgreSQL 기준 시각 |
| Owner·token semantics | owner identity와 재사용되지 않는 fencing 권한의 분리 |
| Acquisition·expiry boundary | 유효성 비교, 경계 시각 동률과 교체 조건 |
| Renewal policy candidate | work type별 갱신 가능 여부·cadence·최대 연장과 실패 결과 |
| Reclaim eligibility | 내부 작업과 외부 효과 work의 lease 만료 뒤 처리 차이 |
| Stale-worker prohibitions | 새 invocation·내부 result·완료·lease 부활 금지 |
| Evidence dependency | SPK-04 cold start·restart·scheduling·DB latency 측정 근거 |
| Physical closure owner | WBS-04.C의 lock·isolation·constraint·index와 WBS-12·24 검증 연결 |

[FACT] 동일 logical work key에는 동시에 하나의 current lease만 존재하며, lease owner 이름만으로 권한을 판단하지 않습니다. Fencing token은 과거 권한과 현재 권한을 구분하고 만료·교체 뒤 재사용되어서는 안 됩니다. 단조 증가 generation과 재사용 불가 opaque token 후보 중 실제 표현은 확정하지 않지만, 동일 worker 이름·Pod 재시작·token ABA가 stale 권한을 되살리지 않는 근거가 필요합니다.

[INFERENCE] Lease 유효성 사전 검사는 권한의 증거가 아닙니다. Internal result write, `prepared → invocation_started`, work completion처럼 외부 효과·immutable result·현재 요약을 전진시키는 transaction은 current logical key·expected state/version·DB 기준 시각·exact token과 domain precondition을 같은 commit 경계에서 다시 대조해야 합니다.

| Transaction semantic | 함께 검사·기록할 계획 항목 | 실패·불명확 시 기본 경계 |
| --- | --- | --- |
| Claim + attempt creation | logical key, expected state, DB time, 기존 lease, 새 owner·token과 attempt lineage | claim 실패 시 work attempt·실제 작업 없음 |
| Lease renewal | current exact token, DB time, expected state, 갱신 허용 범위 | 만료·교체 token의 lease 부활 금지 |
| Expire / reclaim | DB time, 기존 token·state, domain attempt·외부 효과 상태 | invocation 불명확 work 자동 재실행 금지 |
| Internal step commit | current token·lease, source version, domain precondition, 기존 result | stale write 거부, canonical result 재조회 |
| Invocation-started transition | current token·lease, prepared attempt, outbound·configuration·contract·cost gate | commit 확인 전 외부 호출 금지 |
| Work completion / release | expected token·state, canonical result reference, attempt outcome | result·근거 없는 성공 완료 금지 |
| Commit outcome unknown | logical key·token·attempt·domain result를 새 transaction에서 재조회 | blind transaction retry·외부 호출 시작 금지 |

[FACT] Claim에서 current lease 설정과 실제 `work_attempt` 생성은 같은 transaction입니다. 경쟁에서 claim하지 못한 실행은 attempt를 만들지 않고 기존 work의 current 상태를 읽어 종료합니다. 실제 lock wait, skip, ordering과 starvation 방지 방식은 WBS-04.C의 query·transaction 설계에서 결정합니다.

[FACT] Lease 만료는 새 coordination claim을 검토할 수 있다는 뜻이지 외부 invocation이 없었다는 증거가 아닙니다. 외부 API 호출이 없는 내부 DB 작업은 commit된 domain result를 재대조한 뒤 안전한 재claim 가능성을 판단할 수 있지만, `invocation_started` 외부 작업은 lease 만료·worker 종료·새 trigger만으로 다시 호출하지 않습니다. 후속 late evidence·불명확 효과 처리는 WBS-05.D가 소유합니다.

[INFERENCE] DB 연결 종료, timeout 또는 commit acknowledgement 유실로 transaction 결과를 알 수 없으면 실패로 추정해 같은 write나 외부 효과를 즉시 반복하지 않습니다. 새 DB transaction에서 logical key, expected token, work attempt와 canonical domain result를 재조회하고 `committed`, `not_committed` 또는 여전히 `unknown`으로 판정할 evidence와 후속 경로를 계획합니다. DB·restore 신뢰가 불명확하면 AD-10에 따라 outbound를 계속 차단합니다.

[INFERENCE] Lease renewal은 current token을 가진 실행만 요청할 수 있고, 만료·교체된 token을 갱신해 되살리지 않습니다. 경계 시각 비교, renewal 실패 뒤 진행 중 local computation 폐기, work type별 기간·cadence·최대 연장·grace와 장기 외부 호출 처리 방식은 SPK-04 측정 및 WBS-06~08 workload 계약을 근거로 결정하며 하나의 임의 global default를 사용하지 않습니다.

[FACT] SPK-04는 비production 환경의 cold start, scheduler 지연·clock 관측, process/Pod restart, DB 연결·transaction latency를 측정해 lease·renewal 후보의 근거를 제공합니다. 측정 실패·환경 불일치·대표 workload 부재는 안전한 기본값으로 간주하지 않고 WBS-05.C closure blocker 또는 제한된 가정으로 사용자에게 보고합니다.

[INFERENCE] WBS-05.C의 semantic output은 각 invariant에 필요한 atomicity·serialization strength, 경쟁 주체, 예상 cardinality와 허용 실패 결과를 기록합니다. WBS-04.C는 이를 PostgreSQL constraint, row/advisory lock 후보, compare-and-set, isolation과 query/index로 물리화합니다. WBS-05.C에서 특정 SQL 기법을 이미 선택된 것처럼 표현하거나 application 선검사만으로 fencing을 완료했다고 간주하지 않습니다.

[INFERENCE] 최소 fault matrix는 claim commit 전·후 중단, commit acknowledgement 유실, renewal 경계·실패, W1 token α 만료 뒤 W2 token β claim과 W1 재개, internal result commit 전·후 중단, DB network partition, invocation-started commit 전·후 중단을 포함합니다. Work·attempt·domain result·external invocation 수와 current token·상태·evidence lineage를 대조하고 stale write·lease 부활·blind retry가 0건이어야 합니다.

[UNKNOWN] token 전략, lease 유효성의 정확한 경계 비교, work type별 기간·renewal cadence·최대 연장, reclaim ordering·fairness, PostgreSQL isolation·row/advisory lock·compare-and-set·unique/exclusion constraint·`SKIP LOCKED` 사용 여부는 SPK-04와 WBS-04.C 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 transaction 설계를 승인했다는 뜻이 아닙니다.

#### WBS-05.D External Invocation, Uncertain Effect, and Late Evidence Review Contract

[FACT] WBS-05.D 실행 산출물은 external operation-class register, invocation crash-window matrix와 late-evidence applicability register입니다. 공통 fail-closed 경계를 정의하되 실제 provider·Discord API, idempotency key, retry 횟수·backoff 또는 payload schema를 확정하지 않습니다.

| External operation class | 계획상 효과·위험 | Domain closure owner |
| --- | --- | --- |
| GeekNews RSS read | 원격 입력 관측·rate limit·응답 유실과 Raw evidence 중복 | SPK-01, WBS-14 |
| Free AI invocation | quota·usage·비용 안전과 구조화 결과·correlation 불명확 | SPK-02·06, WBS-06·15 |
| Discord send | 사용자에게 보이는 message 외부 효과와 acceptance·message mapping 불명확 | SPK-03, WBS-07·17·19 |
| Discord REST reconciliation | 제한된 현재 상태 read, rate limit과 snapshot observation·scope 불명확 | SPK-03, WBS-07·18~19 |

[INFERENCE] HTTP method, client timeout 또는 SDK exception만으로 재실행 안전성을 판정하지 않습니다. Read operation도 quota·rate limit·observation identity와 downstream projection 중복을 만들 수 있고, timeout·connection reset·client 취소는 외부 서비스가 요청을 처리하지 않았다는 증거가 아닙니다. Operation별 안전한 retry 조건은 실제 계약 evidence로 닫습니다.

```text
domain attempt prepared commit
  → invocation_started commit
  → external call
  → append-only evidence와 허용된 business result commit
```

| 중단 지점 | DB에서 확인 가능한 사실 | 계획상 허용 | 계획상 금지 |
| --- | --- | --- | --- |
| prepared commit 전 | domain attempt 없음 | logical work·domain precondition 재판정 | 호출 성공·실패 추정 |
| prepared commit 후, invocation 전환 전 | prepared attempt 존재 | current token·gate 재검증 뒤 같은 attempt 재개 | 새 attempt·외부 호출 즉시 생성 |
| invocation_started commit 전 또는 결과 불명확 | prepared 또는 commit 불명확 | DB에서 attempt state 재조회 | commit 실패 추정 뒤 외부 호출 |
| invocation_started commit 후, network call 전 | invocation 시작 의도만 확인 | 불명확 효과로 보존·계약상 대조 가능성 검토 | 호출이 없었다고 추정한 자동 retry |
| network call 중 또는 응답 전 | 외부 처리 여부 불명확 | evidence 대기·승인된 제한 대조 | AI 자동 재호출·Discord 자동 재발송 |
| 응답 수신 후 evidence commit 전 | process memory에만 exact 응답이 있을 수 있음 | 살아 있는 exact 응답을 source attempt에 기록 시도 | 다른 attempt에 귀속·기존 attempt 초기화 |
| evidence/result commit 불명확 | 저장 성공 여부 불명확 | attempt·evidence·canonical result 재조회 | blind insert/update·새 외부 호출 |
| evidence/result commit 후 | canonical evidence·result 존재 | 저장 결과 재사용·후속 handoff | 결과 재계산·invocation 반복 |

[FACT] `prepared` attempt는 invocation이 시작되지 않았다는 DB 근거가 있고 현재 lease·fencing token, outbound gate, 비용 안전, 적용 configuration snapshot과 external contract가 모두 일치할 때만 같은 attempt로 재개할 수 있습니다. 하나라도 불일치하면 같은 attempt를 차단·대기로 유지하고 새 attempt나 호출을 만들지 않습니다.

[FACT] 명확한 terminal failure가 실제 계약과 승인된 domain retry 정책상 retryable일 때만 새 domain attempt를 `prepared`로 만들 수 있습니다. 기존 attempt를 prepared로 되돌리거나 evidence·outcome을 덮어쓰지 않습니다. `invocation_started` 뒤 응답·오류 근거가 없거나 상충하면 `external_effect_uncertain`이며 lease 만료·새 trigger·시간 경과만으로 자동 retry하지 않습니다.

| Late-evidence register field | 계획 목적 |
| --- | --- |
| Source attempt·invocation | evidence가 속한 유일한 호출 lineage 고정 |
| Correlation / mapping proof | provider correlation 또는 Discord exact message·attempt 관계 확인 |
| Evidence source/type·observed time | `external_attempt_evidence`의 response·usage·limit과 별도 `acceptance_evidence` owner·type·관측 시각 구분 |
| Duplicate identity | 같은 evidence의 반복 저장·business 적용 방지 |
| Conflict classification | 기존 근거와 상충하거나 source가 불명확할 때 자동 해소 금지 |
| Business applicability | candidate 미해결·selection 미고정 등 적용 precondition |
| Non-application reason | 이미 immutable 결과가 있을 때 evidence만 보존하는 이유 |
| Domain closure owner | AI는 WBS-06, Discord는 WBS-07, RSS는 WBS-14 |
| Physical evidence owner | allowlist·type·size·constraint는 WBS-04.D |

[FACT] Late evidence는 exact source attempt와 correlation 또는 mapping이 확인될 때 append-only·idempotent하게 보존합니다. Local attempt ID·request digest·제목 유사성·근접 시각만으로 provider 처리나 Discord 수락을 증명하지 않습니다. 중복·상충·출처 불명 evidence는 불명확 상태와 원인을 유지하며 새 invocation·attempt를 만들지 않습니다.

[FACT] AI late response는 source candidate가 아직 미해결이고 final `selection_result`가 없을 때만 WBS-06의 validation을 거쳐 유일한 selection-eligible `article_analysis` 후보가 될 수 있습니다. 다른 analysis가 이미 candidate를 해결했거나 final result·failure notice가 고정된 뒤에는 evidence와 non-application reason만 보존하고 analysis·selection·delivery를 소급 생성·변경하지 않습니다.

[FACT] Discord late evidence의 수락·명시적 미수락·recipient-observed receipt 적용은 WBS-07의 exact mapping·scope 계약을 따릅니다. Feedback REST snapshot은 delivery acceptance·recovery event를 갱신하는 근거로 재사용하지 않으며, invocation 뒤 late evidence가 도착해도 이미 시작한 confirmation·resend를 취소하거나 반복하지 않습니다.

[FACT] `external_attempt_evidence`는 lifecycle state·business outcome과 분리된 append-only observation입니다. Evidence kind·provider별 field allowlist·schema version·size 제한·Secret·credential·민감 header redaction, canonical payload 중복 금지와 실제 물리 type은 WBS-03.C·WBS-04.D·WBS-20이 닫습니다. 미확정 계약을 unrestricted raw response로 저장하지 않습니다.

[INFERENCE] WBS-05.D 완료 조건은 모든 outbound operation의 effect class·domain owner, 각 crash window의 허용/금지 행동, same-attempt resume와 new-attempt retry 구분, uncertain 자동 재호출 0건, late evidence의 exact lineage·중복·상충·business applicability·non-application 규칙과 보안 closure owner가 있는 것입니다. Process kill·timeout·응답 유실·중복/상충/late response fixture에서 attempt·invocation·evidence·domain result·delivery 수를 대조합니다.

[UNKNOWN] 실제 RSS observation attempt 표현, provider/Discord idempotency·correlation·상태 조회 capability, Discord message ID 확보 시점, retryable terminal 오류·횟수·backoff, evidence field allowlist·physical type은 SPK-01~03·06과 WBS-04.D·06·07·14 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 외부 계약이나 retry 정책을 승인했다는 뜻이 아닙니다.

#### WBS-05.E Finalization, Durable Handoff, and Fault Closure Review Contract

[FACT] WBS-05.E 실행 산출물은 selection finalization invariant register, durable handoff register와 finalization 이후 downstream claim 전까지의 fault closure matrix입니다. 실제 SQL·handoff 구현 방식·Discord 계약을 정하지 않고 WBS-04.C·07·08과 WBS-16~19의 closure 조건을 정의합니다.

| Finalization register field | 계획 목적 |
| --- | --- |
| Source Prepare work·scheduled batch | finalization 책임과 logical scope 고정 |
| Required lease·token·state | stale execution의 final result commit 차단 |
| Input completion predicate | RSS 입력과 모든 candidate 완료·terminal·전체 선정 불가능 조건 대조 |
| Processing configuration binding | 같은 immutable configuration snapshot과 contract lineage 사용 |
| Existing result check | 이미 고정된 `selection_result` 재사용과 중복 finalization 금지 |
| Atomic outputs | result·summary·필요한 candidate selection·batch item·Prepare work/attempt 종료 |
| No-output / no-op condition | 미완료·stale·기존 result 상황에서 금지할 write |
| Downstream eligibility | current·delayed·failure notice·no-message 결과의 handoff 분류 |
| Physical closure owner | WBS-04.C의 transaction·constraint·reference enforcement |
| Verification owner | WBS-16·23~25의 commit 전후·동시 finalization fixture |

[FACT] Finalization은 source Prepare work의 마지막 내부 단계입니다. 하나의 짧은 transaction 안에서 current lease·fencing token, RSS 입력 완료, candidate completion/terminal 조건, processing configuration binding과 기존 final result를 다시 대조합니다. Result가 이미 있으면 재사용하고, 조건이 충족되지 않거나 token이 stale이면 result·후보별 결정·batch item·성공 완료를 만들지 않습니다.

[FACT] 신규 final result를 고정할 때는 `selection_result`, immutable result summary, 필요한 `candidate_selection`·`batch_item`, Prepare work 완료와 해당 attempt 종료 결과를 분리해 남기지 않습니다. Commit 전 중단이면 partial final output이 없어야 하고, commit 뒤 중단·동시 trigger는 저장된 immutable result를 읽으며 selection을 재계산하거나 항목을 추가하지 않습니다.

[FACT] Selection transaction은 `delivery_set`, delivery domain attempt, Discord message mapping 또는 외부 호출을 만들지 않습니다. Delivery consumer는 commit된 immutable result와 승인된 recovery source만 읽을 수 있으며 uncommitted·partial·application memory의 result를 release하지 않습니다.

| Durable handoff register field | 계획 목적 |
| --- | --- |
| Producer commit | downstream 진행을 허용하는 canonical immutable result·event |
| Eligibility predicate | 어떤 결과가 어떤 delivery work 또는 no-message로 이어지는지 |
| Downstream logical work key | 반복 trigger가 같은 work로 수렴하는 idempotency 경계 |
| Admission trigger | Delivery gate·Prepare post-commit·Recovery 등 실행 기회 구분 |
| Duplicate guard | 같은 producer scope의 downstream work·delivery set 최대 하나 |
| Lost-handoff repair | producer commit 후 process 중단을 저장 결과에서 재발견하는 경로 |
| Consumer precondition | committed result·source lineage·gate·work claim 재대조 |
| Forbidden coupling | selection transaction 안 delivery set·attempt·Discord invocation 금지 |
| Closure owner | WBS-04.C의 물리 atomicity와 WBS-07의 delivery domain 계약 |

[INFERENCE] Producer commit 뒤 downstream work admission 전에 process가 중단돼도 in-memory callback이나 동일 Pod 생존에 의존하지 않고 canonical result·event에서 같은 logical work를 idempotent하게 재발견할 수 있어야 합니다. Selection transaction과 같은 transaction에서 delivery work만 등록하는 후보와 post-commit discovery 후보를 비교할 수 있지만, 어떤 후보도 delivery set·Discord attempt·외부 호출을 selection commit에 결합할 수 없습니다.

[FACT] Handoff는 scheduled current result, 목표 시각 뒤 완료된 `processing_delayed_full_result`, `processing_failure_notice`, receipt confirmation과 확인된 미수락·사용자 선택 recovery의 source와 logical work key를 구분합니다. Processing-delayed full result는 current 또는 recovery backlog와 혼합하지 않고 원래 batch의 최대 10개 full result를 전용 delivery set으로 release합니다.

[FACT] `normal_no_new_candidates`는 source current Discord message를 만들지 않는 final result입니다. 그러나 다른 원래 batch의 확인된 recovery는 이 source batch 상태와 분리된 recovery-only delivery work로 진행할 수 있습니다. 정상 신규 0건을 batch 전체의 generic no-op로 사용해 recovery·confirmation을 누락하거나 수락 불명확 대상을 확인된 recovery로 바꾸지 않습니다.

[FACT] Delivery 실패는 source selection result를 다시 계산·변경하지 않습니다. 확인된 미수락 recovery는 저장된 원래 result와 실제 미수락 item subset을 재사용하고, 수락 불명확 external effect는 자동 recovery backlog에 포함하지 않습니다. Receipt confirmation·승인된 1회 즉시 재전송·사용자 선택 recovery는 각 source event와 attempt lineage를 유지합니다.

[FACT] DB commit 결과, 무결성 또는 restore 신뢰가 불명확하면 downstream outbound를 자동 시작하지 않습니다. Work ledger, final result, prepared/invocation-started attempt, Discord mapping·acceptance evidence와 필요한 feedback/recovery 상태를 대조합니다. WBS-08은 restore/recovery 계약을 설계하고 WBS-21은 승인된 계약을 구현하며, 운영 runtime에서는 검증된 restore evidence와 사용자 수동 승인이 확인된 뒤에만 재개합니다. 이는 WBS-05 계획 정의가 WBS-21 구현 완료에 의존한다는 뜻이 아닙니다. Result 부재나 attempt 부재를 정상·미실행·미수락으로 추정하지 않습니다.

| Fault point | Canonical 재조회 대상 | 허용된 repair 방향 | 금지 동작 |
| --- | --- | --- | --- |
| Finalization transaction 전 중단 | Prepare work·candidate completion·기존 result | 현재 claim에서 precondition 재판정 | partial result·delivery 생성 |
| Finalization commit 결과 불명확 | token·selection result·summary·Prepare 상태 | 새 transaction에서 commit 여부 판정 | blind finalization retry |
| Finalization commit 후 process 중단 | immutable result와 downstream work key | idempotent handoff discovery | selection 재계산 |
| Downstream work admission 결과 불명확 | producer result·logical work key | 기존 work 재조회·단일 admission | 다른 key로 우회 생성 |
| Delivery claim 전 중단 | committed producer·work state | 같은 work claim 재시도 | 새 delivery work 생성 |
| DB/restore trust 불명 | ledger·result·attempt·acceptance·restore evidence | 차단·대조·수동 승인 | 자동 outbound·성공/실패 추정 |

[INFERENCE] WBS-05.E 완료 조건은 모든 finalization precondition·atomic output·no-op·금지 write, delivery-eligible producer별 단일 downstream logical key, lost-handoff repair와 committed-result-only consumer 조건, current/delayed/notice/confirmation/recovery 분리, DB trust failure의 수동 재개 및 각 fault point의 verification owner가 있는 것입니다. Commit 전후·동시 finalization·handoff 직후 process kill·중복 trigger·restore gap fixture에서 result·work·delivery set·attempt·external invocation 수를 대조합니다.

[UNKNOWN] Delivery work를 producer commit과 같은 transaction에서 등록할지 post-commit discovery로 admission할지, 실제 handoff query·constraint·lock·polling 기회, delivery eligibility의 물리 표현과 restore 대조 절차는 WBS-04.C·07·08 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 finalization·handoff 구현을 승인했다는 뜻이 아닙니다.

#### WBS-05 Overall Closure Contract

[INFERENCE] WBS-05 계획 정의 closure에는 여섯 logical work의 typed identity·admission, canonical state axis·transition, current lease·fencing·transaction semantic, external operation별 crash/uncertainty와 finalization·durable handoff가 하나의 정방향 lineage로 연결돼야 합니다. Work와 domain result의 cross-axis 추정, claim 실패 attempt 생성, stale write, 불명확 외부 효과 자동 재실행, partial finalization, uncommitted result delivery와 lost handoff의 owner 없는 경로는 0건이어야 합니다.

[FACT] Physical key·state·lease·SQL, provider·Discord/RSS capability, reconciliation·evaluation key와 durable handoff 구현은 WBS-04.C·06~08·14의 승인된 closure owner에 남길 수 있습니다. 다만 각 `[UNKNOWN]`에는 차단 영향, fail-closed 기본 동작, 필요한 spike/evidence, 결정·구현·verification owner가 있어야 하며 WBS-09 Coding Readiness 전에는 blocking 항목을 실제 승인 결정으로 닫아야 합니다.

[INFERENCE] WBS-05 순차 검토 완료는 plan의 계약·owner·gate 정합성 완료를 뜻하며, 실제 동시성·중복 외부 효과·복구 위험이 사라졌다는 의미가 아닙니다. 해당 위험은 WBS-04.C·06~08의 상세 설계, WBS-12~21 구현과 WBS-23~25의 negative/concurrency/fault evidence가 통과할 때 닫힙니다.

### WBS-06 Internal Review Checkpoints

[FACT] WBS-06은 provider 선택과 AI·selection 전체 계약을 한 번에 확정하는 단일 작업이 아니라, 외부 evidence부터 finalization handoff까지 순차적으로 닫는 설계 work package입니다. 아래 checkpoint는 독립 검토 단위이며 새로운 상위 WBS Task가 아닙니다.

| ID | 검토 범위 | 계획 산출물 | 선행·closure 조건 |
| --- | --- | --- | --- |
| WBS-06.A | Provider·contract·cost activation | provider decision register, official/configured/sandbox/cost evidence 분리, SPK-06A→02→06B gate, selected/rejected/blocked/inconclusive·재검증 조건 | SPK-02·06 판정과 사용자 승인; 단일 free-only·no-paid-fallback, 실제 호출 구현 없음 |
| WBS-06.B | Evidence-bounded input·prompt·version | input contract·version register, RSS field provenance·deterministic normalization/serialization·limit 결과, instruction/data·tool/grounding 경계와 safe request lineage | WBS-03과 WBS-06.A 승인 계약 및 SPK-01 source field evidence; 입력 결정은 WBS-06.B, physical manifest는 WBS-04.D, 구현은 WBS-15 owner |
| WBS-06.C | Output schema·validation·low-information | normal·low-information·invalid/provider/uncertain output-class matrix, structural·lineage validator와 semantic/human evaluation owner, no-coercion·canonical evidence 경계 | WBS-06.B; retry는 WBS-06.D, physical field는 WBS-04.D, semantic evaluation은 WBS-08 closure |
| WBS-06.D | Attempt·error·retry·uncertainty | AI error-decision register, attempt phase·evidence confidence·external effect certainty, retry eligibility·budget/deadline, new-attempt lineage와 late response의 결과 적용·증거 보존 분리 | WBS-05.D와 WBS-06.A~C; candidate/batch completion은 WBS-06.E, 실제 provider code·값은 SPK-02·06 evidence 필요 |
| WBS-06.E | Candidate completion·batch failure | candidate-resolution register, batch-completion decision register, 처리 마감 terminalization, 정상·저정보·명시적 미처리 수량 불변식과 partial/total processing failure notice 자격 | WBS-06.C~D와 DDI-09; immutable result·selection은 WBS-06.F, 실제 enum·마감·원인 우선순위는 후속 evidence 필요 |
| WBS-06.F | Selection·finalization·delivery handoff | selection-policy decision register, deterministic eligibility·홍보성 제외·정렬·tie-break·최대 10개, immutable result taxonomy·원자적 finalization과 current/delayed/notice/no-message durable handoff | WBS-05.E와 WBS-06.B~E; 실제 score·가중치·tie-break는 Coding Readiness 전 승인 필요, Discord 실행은 WBS-07, evaluation은 WBS-08 owner |

```text
SPK-02·06 evidence와 사용자 provider 승인
  → WBS-06.B input·version boundary
  → WBS-06.C output·validation
  → WBS-06.D attempt·retry
  → WBS-06.E candidate·batch completion
  → WBS-06.F selection·finalization
  → WBS-04.D external physical field closure
```

[FACT] 최종 provider·model·SDK는 SPK-02의 공식 계약·sandbox evidence, SPK-06의 사전·사후 비용 coverage와 사용자 승인을 받기 전에는 검증 후보입니다. Gemini 무료 API는 우선 검증 후보일 뿐 확정 provider가 아닙니다. 동시에 여러 provider를 구현하거나 유료 호출·자동 유료 fallback·provider 자동 전환을 계획하지 않습니다.

[FACT] AI 입력의 사실 근거는 수집된 해당 entry의 RSS title과 content 또는 description으로 제한합니다. 외부 원문 기사, GeekNews 상세 페이지·댓글·검색 결과·브라우징 또는 모델 외부 지식을 사실 보완에 사용하지 않습니다. RSS content는 실행 지시가 아닌 신뢰할 수 없는 데이터이며 Secret·credential·민감 운영값을 input에 포함하지 않습니다.

[INFERENCE] Input serialization version, model/provider version, prompt version, judgment policy version과 output contract version은 변경 원인과 lineage가 다르므로 하나의 불명확한 version 문자열로 합치지 않습니다. 실제 식별자 형식은 확정하지 않지만 진행 중 batch의 configuration binding과 attempt·analysis·selection result에서 적용 version을 역추적할 수 있어야 합니다.

[FACT] 검증된 정상·저정보 결과만 `article_analysis`가 될 수 있습니다. Provider/cost failure, schema·근거 validation 실패, retry 대기와 `external_effect_uncertain`은 attempt·typed evidence·candidate 처리 상태로 남기며 정상 분석·정상 미선정·홍보성 제외로 변환하지 않습니다.

[FACT] 개별 AI attempt 오류는 batch 전체 선정 불가능을 자동 확정하지 않습니다. 승인된 무료 한도·retry 정책상 완료 가능한 후보가 하나라도 남아 있으면 article list·final `selection_result`·processing failure notice를 만들지 않습니다. 전체 선정 불가능이 승인된 근거로 확정된 경우에만 partial 또는 total processing failure notice를 고정하며 partial article list는 만들지 않습니다.

[FACT] Importance, interest relevance와 promotional judgment는 서로 다른 원 판단과 최소 RSS 근거를 유지합니다. 관심 밖 고중요도와 홍보성 불명확 후보의 선정 가능성을 임의로 제거하지 않고, 중요 기사 누락을 비중요 기사 포함보다 더 심각하게 취급합니다. 실제 label·score·threshold·tie-break와 human evaluation rubric은 후속 checkpoint에서 근거와 별도 owner를 갖습니다.

[FACT] 목표 시각 뒤 `full_selection`이 완료되면 원래 scheduled batch의 최대 10개 processing-delayed full result를 별도 delivery set으로 handoff합니다. 처리 지연 결과를 current batch·확인된 미수락 recovery backlog와 혼합하거나 새 예정 batch의 신규 후보로 재편입하지 않습니다.

[FACT] WBS-05는 공통 work·invocation·uncertainty 계약을, WBS-06은 AI/domain completion·selection 계약을 소유합니다. WBS-04.D는 evidence/output의 physical field·allowlist·size·constraint를 닫고 WBS-08은 운영 selection policy와 분리된 immutable evaluation·human review rubric을 소유합니다. Domain 계약을 generic work state·자유형 payload·평가 결과에 중복 저장하지 않습니다.

[INFERENCE] WBS-06 완료 조건은 단일 free-only provider의 dated contract/cost evidence와 사용자 승인, 허용 input·version lineage, 정상/저정보/validation failure 구분, attempt 오류·retry terminal·uncertain 경계, 모든 candidate의 배타적 처리 설명, full selection 또는 processing failure notice 조건, 최대 10개 immutable result와 delivery handoff가 하나의 lineage로 연결되는 것입니다. 근거 밖 사실·유료 전환·미처리 은폐·부분 article list·late result 소급 적용의 negative fixture owner가 모두 있어야 합니다.

[UNKNOWN] 최종 provider·model·SDK, 무료 quota·rate limit·reset·structured output·data-use, input 정리·직렬화, output field·keyword·label·score, retry 횟수·backoff·terminal 오류, 100건 초과 처리, selection threshold·tie-break와 평가 rubric은 SPK-02·06 및 WBS-06.A~F 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 AI 계약이나 selection policy를 승인했다는 뜻이 아닙니다.

#### WBS-06.A Provider, Contract, and Cost Activation Review Contract

[FACT] WBS-06.A 실행 산출물은 단일 무료 AI 후보의 provider decision register와 SPK-06A·02·06B evidence handoff입니다. 이 계획 검토에서는 account/project 설정을 변경하거나 API를 호출하지 않으며, 실제 evidence가 제출되기 전 Gemini 무료 API를 포함한 모든 후보는 미확정 상태입니다.

| Provider decision register field | 계획 목적 |
| --- | --- |
| Candidate provider·service | 검증 대상 AI service와 API 경계 식별 |
| Account·project boundary | billing·quota·credential이 적용되는 exact scope 고정 |
| Exact model identifier | `latest` alias·자동 routing과 사용자 승인 model 구분 |
| Official contract evidence | free plan·quota·rate limit·reset·data-use·structured output·오류 계약과 확인 시각 |
| Configured-state evidence | 실제 billing·paid route·quota·credential·region·model 설정의 비밀값 없는 fingerprint |
| Sandbox observation | 정상·저정보·오류·structured output·latency·usage와 공식 계약 일치 여부 |
| Cost evidence | 호출 전 안전 근거, 실제 spike usage·유료 event·청구 coverage |
| Data-use compatibility | 승인된 공개 RSS input 경계와 서비스 개선·사람 검토 등 적용 조건의 적합성 |
| Capability limitation | 확인하지 못했거나 제공하지 않는 기능과 영향 범위 |
| Decision·rationale | selected·rejected·blocked·inconclusive와 근거·판정 시각 |
| Blocked downstream | 완료할 수 없는 WBS-06.B~F·15·26·28 범위 |
| Revalidation trigger | provider/account/project/model/runtime/계약·정책·설정 변경과 VR-011 연결 |
| User approval | 선택 provider·model·configuration 범위의 명시적 승인 evidence |

[FACT] Official contract, configured state, sandbox observation과 usage/billing evidence는 서로 대체하지 않습니다. 공식 문서의 free tier 존재는 실제 project의 청구 불가능 설정을 증명하지 않고, sandbox 정상 응답은 데이터 이용 조건·quota reset·월 청구 결과를 증명하지 않으며, usage 0 또는 청구 내역 부재도 필수 billing evidence가 없는 비용 Hard Gate를 `pass`로 만들지 않습니다.

| 단계 | 필요한 evidence와 gate | 실패·불명확 시 처리 | 해당 단계가 증명하지 못하는 것 |
| --- | --- | --- | --- |
| SPK-06A | 사전 billing/free-only/paid-route 차단, 호출·token·시간 budget, kill switch와 승인 범위 | AI 호출을 시작하지 않고 blocked/fail/inconclusive 판정 | 실제 품질·처리량·최종 월 비용 |
| SPK-02 | 승인된 제한 workload의 품질·구조·quota·오류·latency·usage와 data-use 계약 적합성 | 자동 대체 없이 영향 WBS 차단·사용자 결정 | 전체 환경 비용·운영월 청구 결과 |
| SPK-06B | 실제 spike usage, 유료 usage/event 0건과 선택 실행환경의 배포 전 비용 coverage | provider activation과 후속 완료 차단 | 운영월 Cost Hard Gate 최종 통과 |
| 사용자 승인 | candidate evidence·제약·잔존 위험과 exact provider/model/configuration 승인 | selected 판정 불가 | 향후 계약·설정 변경 뒤 영구 보장 |
| 운영월 검증 (`WBS-30`) | 운영월 usage·billing·유료 event와 전체 환경 추가 비용 대조 | `pass` 추정 없이 실제 결과 보고 | 이후 정책 변경의 영구 안전성 |

[FACT] SPK-06A가 pass하지 않으면 SPK-02의 실제 provider 호출을 시작하지 않습니다. SPK-02 뒤 SPK-06B가 실제 spike 사용량과 비용 coverage를 대조하기 전에는 provider activation을 승인하지 않습니다. 각 단계는 WBS-02의 pass/fail/blocked/inconclusive 판정과 연결하며 evidence가 부족한 상태를 안전으로 추정하지 않습니다.

[INFERENCE] 무료 quota가 존재한다는 설명만으로 0원 조건을 충족하지 않습니다. Billing 활성화, quota 초과 뒤 유료 처리, 다른 유료 endpoint/model 접근 또는 자동 routing 가능성이 있으면 제공자·project 수준의 강제 차단이나 요청 당시 청구 불가능함을 증명하는 동등한 evidence가 필요합니다. 자체 usage 감시·사후 alert·application kill switch만으로 사전 비용 안전을 대신하지 않습니다.

[FACT] 시스템은 provider·model·credential·project 또는 과금 경로를 자동 전환하지 않습니다. Candidate가 rejected·blocked·inconclusive이면 다른 후보를 자동 선택하거나 동시에 구현하지 않고, 영향 WBS를 차단한 채 대안 검증 범위와 비용 안전 조건에 대한 별도 사용자 승인을 요청합니다. 유료 fallback은 대안으로 제안하거나 구현하지 않습니다.

[INFERENCE] `latest` 등 이동 가능한 alias, 자동 model fallback·routing 또는 provider가 model을 암묵적으로 변경하는 경로는 exact identifier·실제 resolution·변경 감지와 재검증 근거 없이 승인하지 않습니다. Exact version pin이 제공되지 않는 경우에는 관찰 가능한 resolved model·contract fingerprint, 차단 가능한 변경 조건과 잔존 위험을 사용자에게 명시해야 합니다.

[FACT] Provider 검증 payload는 승인된 공개 RSS title과 content 또는 description 및 비밀정보 없는 최소 처리 지시로 제한합니다. 외부 원문·GeekNews 상세 페이지·댓글·검색 결과, RSS link·author·시각 등 금지 metadata, Discord·사용자·batch identifier, 다른 저장 데이터, Secret·credential을 전송하지 않습니다. Redacted request manifest와 allowlist 검사가 실제 payload를 대체하는 검증 evidence로 연결돼야 합니다.

[INFERENCE] 실제 workload 검증은 SPK-06A에서 승인한 최대 call·token·시간 budget, 단계적 증가, quota/비용 stop condition과 수동 kill switch를 넘지 않습니다. 0·1·99·100·101 후보를 실제 무료 범위에서 모두 수행할 수 없으면 유료로 계속하지 않고 실행 범위·미검증 범위·측정 결과를 분리해 fail/blocked/inconclusive로 판정합니다. 제한 실험의 단순 추정치를 실제 100건 처리 pass로 기록하지 않습니다.

[FACT] Provider/account/project/model/credential/billing·무료 정책·data-use·runtime 또는 관찰된 contract가 변경되면 VR-011 재검증을 수행합니다. Implementation 직전과 운영 검증 시작 전에도 영향을 받는 공식 계약·configured state·sandbox·cost evidence를 다시 확인하며, 새 결과로 과거 batch configuration·analysis·selection을 소급 변경하지 않습니다.

[INFERENCE] WBS-06.A 완료 조건은 SPK-06A·02·06B의 독립 판정·dated evidence, official/configured/observed/cost 근거 분리, 청구 가능 경로·자동 routing·data-use·quota 실패의 차단 결과, downstream 영향, VR-011 재검증 trigger와 exact 사용자 승인이 있는 단일 selected provider입니다. 유료 호출·자동 대체·Secret 전송·미검증 capability의 pass 판정은 0건이어야 합니다.

[UNKNOWN] 최종 provider·service·account/project·model·SDK, 강제 과금 차단, quota·rate limit·reset·data-use·structured output·error/correlation, safe workload budget과 alias pinning 가능성은 실제 SPK-06A·02·06B 및 사용자 승인 전 확정되지 않습니다. 이 review contract의 승인은 Gemini 또는 다른 provider의 선택·activation을 뜻하지 않습니다.

#### WBS-06.B Evidence-Bounded Input, Prompt, and Version Review Contract

[FACT] WBS-06.B 실행 산출물은 AI input contract register와 version-lineage register입니다. 실제 prompt 문구·provider request body·token limit 또는 serializer code를 만들지 않으며, 승인된 RSS source와 configuration으로부터 요청을 재현·검증할 계획 경계를 정의합니다.

| Input contract register field | 계획 목적 |
| --- | --- |
| Source candidate·article·observation | 실제 처리 대상과 입력 RSS observation lineage 고정 |
| Allowed source fields | RSS `title`과 선택된 `content` 또는 `description`으로 제한 |
| Field-selection provenance | 어느 source field를 어떤 승인 규칙으로 선택했는지 기록 |
| Denied-field assertion | link·Atom id·author·시각·운영 metadata·Discord·사용자·Secret 제외 확인 |
| Normalization steps·version | HTML·entity·Unicode·공백 정리의 결정적 재현과 의미 보존 |
| Instruction / data boundary | RSS를 실행 지시가 아닌 untrusted data로 구획·escape |
| Size·token observation | 입력 길이·token 추정과 provider limit 판단 근거 |
| Limit-handling result | full input·명시적 제한·처리 불가를 구분하고 조용한 절단 금지 |
| Serialization version·digest | 같은 source/version request의 재현·대조와 collision 고려 |
| Configuration binding | 진행 중 batch의 immutable processing 기준과 provider 계약 연결 |
| Provider capability state | browsing·grounding·tool·자동 외부 접근의 비활성·차단 evidence |
| Verification owner | WBS-15·23·25의 실제 payload·근거·금지 field 검사 |

[FACT] AI 사실 입력 allowlist는 저장된 해당 `rss_observation`의 title과 content 또는 description입니다. GeekNews topic link, Atom id, author, published/observed 시각, source type과 운영 metadata, 외부 원문·상세 페이지·댓글·검색 결과, Discord reaction·message·사용자·batch identifier, 다른 저장 데이터, Secret·credential·민감 운영값은 요청 payload에 포함하지 않습니다.

[INFERENCE] `content`와 `description`이 모두 존재하거나 하나가 비어 있거나 parsing·형식 검증에 실패한 경우의 선택 precedence와 처리 결과를 명시해야 합니다. SPK-01이 GeekNews RSS 실제 field·parser evidence를 제공하고 WBS-06.B가 그 근거로 AI에 전달할 단일 source text·provenance 규칙을 승인하며, WBS-04.D가 physical manifest를 닫고 WBS-14가 승인 계약을 구현합니다. 어느 경우에도 구현 중 규칙을 새로 결정하거나 두 값을 임의 결합하고 누락 부분을 외부 정보로 보완하지 않습니다.

[FACT] Raw RSS 원값과 observation은 그대로 canonical source로 보존합니다. AI input 정리는 markup 제거, entity 해석, Unicode·공백 처리 등 승인된 결정적 단계만 수행하며 새 사실·문장·해설을 추가하거나 link를 fetch하지 않습니다. 각 단계는 순서·version·입출력 길이와 의미 손실 fixture를 가지며 동일 source와 serializer version에서 같은 digest를 재현할 수 있어야 합니다.

[INFERENCE] Provider context/token limit을 넘는 입력을 조용히 자르지 않습니다. Full input 사용, 승인된 근거 보존 제한 또는 처리 불가 후보를 구분하고, 절단 위치·누락 범위·말줄임표·정보 충분성에 미치는 영향을 기록합니다. 제한된 입력을 정상 전체 RSS 근거처럼 표현하거나 외부 지식으로 보완하지 않으며 정확한 threshold·전략은 WBS-06.A의 provider evidence와 WBS-06.C validation 계약 후 결정합니다.

[FACT] RSS text는 system/developer instruction이 아니라 untrusted data입니다. Prompt contract는 고정 instruction과 RSS data의 구조적 구획, escaping/delimiter, 예상치 못한 role·tool syntax와 embedded instruction의 무효화를 검증합니다. RSS 안의 지시, 외부 URL 방문 유도, Secret 요청, output schema 변경 요구와 말줄임표 뒤 추정을 따르는 결과는 정상 analysis로 승인하지 않습니다.

[FACT] Provider browsing·grounding·search·URL fetch·tool execution 또는 자동 외부 source 보완 기능은 비활성화·차단돼야 합니다. 해당 기능의 상태나 강제 차단을 확인할 수 없으면 안전하다고 추정하지 않고 관련 호출을 차단하거나 WBS-06.A의 provider 결정을 재검토합니다. Model의 사전 지식 혼입 가능성은 prompt 설정만으로 제거됐다고 간주하지 않고 WBS-06.C validator와 SPK-02·WBS-23·25 quality evidence로 탐지합니다.

| Version axis | 변경 의미와 lineage 책임 |
| --- | --- |
| Input contract / serialization | 허용 field·selection·normalization·구획·limit 처리 변경 |
| Provider / model | 실제 inference service, resolved model과 capability 변경 |
| Prompt | 고정 지시문·data envelope·출력 요청 구조 변경 |
| Judgment policy | 중요도·관심·홍보성 기준·근거 요구 변경 |
| Output contract | required field·type·label·구조·validation 변경 |
| Configuration snapshot | 한 batch에 적용된 위 version 조합과 contract·cost evidence binding |

[FACT] 실제 Prepare batch의 첫 내부 commit에 binding된 configuration snapshot은 진행 중 batch의 provider/model·input/prompt/policy/output contract 기준을 고정합니다. 새 snapshot이 활성화돼도 기존 batch를 자동 전환·재분석·재선정하지 않으며, 기존 binding의 비용·contract 조건이 더는 유효하지 않으면 새 outbound를 차단합니다.

[INFERENCE] 전체 request payload·RSS text·prompt를 새 canonical blob으로 중복 저장하지 않습니다. Source observation reference, configuration/version reference, 선택 field provenance, normalization·serialization version, 비밀정보 없는 safe manifest와 digest로 실제 request를 재현·대조합니다. Digest는 lineage 보조값이며 source RSS나 version owner를 대체하지 않고 algorithm·serialization version·collision 검증이 필요합니다.

[INFERENCE] WBS-06.B 완료 조건은 허용/금지 field가 배타적으로 정의되고, content/description provenance, 결정적 normalization·serialization, limit 결과, instruction/data 구획, tool/grounding 차단, 여섯 version axis와 batch binding, safe manifest/digest 및 canonical owner가 검증 owner에 연결되는 것입니다. 금지 metadata·Secret·prompt injection·외부 URL·경계 길이·C1/C2 configuration fixture에서 무승인 전송·조용한 절단·batch 중 기준 전환이 0건이어야 합니다.

[UNKNOWN] 실제 content/description precedence, HTML·entity·Unicode·공백 처리, prompt envelope·delimiter, provider context/token limit·tokenizer, 입력 제한 처리, digest algorithm·canonical serialization과 version 식별자 형식은 SPK-01·02 evidence와 WBS-06.A~C 결정, WBS-04.D physical closure 전 확정되지 않습니다. WBS-15는 이 미확정 항목의 결정 owner가 아니라 승인 계약의 구현 owner입니다. 이 review contract의 승인은 실제 prompt·request schema·serializer를 승인했다는 뜻이 아닙니다.

#### WBS-06.C Output Class, Validation, and Low-Information Review Contract

[FACT] WBS-06.C 실행 산출물은 output-class matrix와 validation responsibility register입니다. 실제 JSON schema·field명·label·numeric scale·keyword 수 또는 validator code를 만들지 않으며, 어떤 결과가 canonical `article_analysis`가 될 수 있는지와 실패를 어느 owner에 남기는지 정의합니다.

| Output class | Canonical output | 필수 계획 경계 | 금지 처리 |
| --- | --- | --- | --- |
| Normal analysis | `article_analysis` | 검증된 표시 제목, RSS 근거 2~3문장, keyword, 분석 추천·중요도·관심·홍보성 판단과 최소 근거·lineage | 누락 field 기본값 보완·RSS 밖 사실 추가 |
| Low information | `article_analysis` | `정보 제한`, 검증된 analysis title 또는 RSS title의 출처, 1문장 이하 또는 승인 문구, 확인 가능한 keyword와 stored link | 2~3문장 강제·외부 지식 보완 |
| Invalid response | AI attempt·safe evidence·candidate 상태 | 누락·형식·type·label·JSON·근거 validation 실패와 영향 | `article_analysis` 생성·임의 coercion |
| Provider / cost failure | AI attempt·safe evidence·candidate 상태 | quota·rate limit·인증·설정·provider·비용 원인 또는 원인 미확정 | 정상·저정보 결과 생성 |
| External effect uncertain | AI attempt·safe evidence·candidate 상태 | invocation 불명확과 근거 부족·late evidence 대기 | 자동 retry·analysis 성공/실패 추정 |

[FACT] 검증된 normal 또는 low-information output만 `article_analysis`가 될 수 있고 정확한 source article·RSS observation·batch candidate·AI attempt와 configuration/version lineage를 참조합니다. Invalid response, provider/cost failure와 external effect uncertainty는 analysis row를 만들지 않고 attempt·evidence·candidate 처리 축에 남습니다.

[FACT] Normal analysis는 검증 가능한 표시 제목, RSS 근거 범위의 보수적인 한국어 2~3문장 요약, analysis별 keyword, 포함 추천, 중요도·관심 적합성·홍보성 판단과 각 최소 근거를 분리합니다. 제품명·고유 명사·약어와 널리 사용하는 영문 IT 용어는 원문 의미를 유지할 수 있지만, 강제 번역·수식어 추가·말줄임표 뒤 추정은 허용하지 않습니다.

[FACT] Low-information output은 후보 자격을 유지하면서 `정보 제한`을 명시합니다. 표시 제목은 검증된 analysis title 또는 저장된 RSS title 중 하나이고 `title_source`를 구분합니다. RSS 근거 범위에서 충실한 설명이 가능하면 1문장 이하를 사용하고, 불가능하면 승인 문구 `RSS 제공 정보가 부족해 상세 요약을 생성하지 못했습니다`를 사용합니다. Topic link는 AI output이 아니라 저장된 exact Raw RSS link reference입니다.

[INFERENCE] Provider가 low-information class를 반환했다는 사실만으로 판정을 승인하지 않습니다. 사용된 RSS input, 정보 충분성 규칙, required low-information field·근거와 정상 결과 회피 여부를 검증합니다. 반대로 부족한 입력에 2~3문장을 강제해 외부 지식을 채우지 않으며 정확한 sufficiency rubric과 경계 표본은 SPK-02 및 WBS-08 evaluation 근거로 결정합니다.

| Validation layer | 검사 대상 | Primary plan owner |
| --- | --- | --- |
| Transport / parse | 응답 존재·encoding·structured response parsing | WBS-06.C·15 |
| Schema / type | required field·type·controlled code·numeric 범위 | WBS-06.C·15 |
| Text / cardinality | 빈값·문장 수·허용 길이·keyword cardinality | WBS-06.C·15 |
| Lineage / version | source attempt·observation·configuration·input/output contract | WBS-06.C·15 |
| Evidence boundary | AI 생성 link 금지, source RSS 근거 reference와 denied field | WBS-06.B~C·15·23 |
| Class consistency | normal·low-information·invalid·failure·uncertain의 배타성 | WBS-06.C·E·23 |
| Semantic faithfulness | RSS 밖 핵심 사실·왜곡·말줄임표 추정 | WBS-08·22·25의 독립 evaluation/human review |
| Quality judgment | 중요도·관심·홍보성 오류와 low-information 적절성 | WBS-08·22·25 |

[INFERENCE] Deterministic validator는 parse, required field, type, controlled code, numeric range, 문장·cardinality, lineage와 명시적 forbidden value를 강제할 수 있습니다. RSS 근거 충실도·중대한 외부 사실·판단 품질은 같은 provider의 자기평가만으로 완전 검증됐다고 간주하지 않고 독립 evaluation snapshot·human review 및 source RSS 대조를 통해 측정합니다.

[FACT] 누락·빈값·잘못된 type·label·JSON, required 근거 부재 또는 승인된 evidence boundary 위반을 default title·summary·keyword·score로 보정하지 않습니다. 안전한 syntax normalization 후보도 원 응답 의미를 변경하지 않는 범위와 output contract 근거가 필요하며, validation 실패는 attempt failure로 전달해 WBS-06.D가 실제 retry 가능성을 판정합니다.

[FACT] Provider response의 원문 string/JSON blob은 canonical analysis가 아닙니다. 검증된 title·summary·keyword·score·judgment·reason은 `article_analysis` aggregate만 소유하고 safe response·usage·limit observation은 `external_attempt_evidence`가 소유합니다. Evidence가 분석값을 복제하거나 unrestricted raw payload·Secret·민감 header를 저장하지 않으며 physical field·allowlist·size는 WBS-04.D가 닫습니다.

[FACT] Keyword는 analysis별 원값·순서의 0개 이상 자식 record 후보이며 MVP-A에서 전역 사전, 대소문자·공백 normalization, synonym/alias 병합 또는 전역 taxonomy를 만들지 않습니다. 전역 normalization을 output validation 명목으로 도입하지 않고 MVP-B deferred로 유지합니다.

[INFERENCE] WBS-06.C 완료 조건은 모든 output class의 canonical owner·required/forbidden result, normal/low-information의 배타적 validator, invalid response no-analysis, deterministic validation과 semantic evaluation의 분리, source/version lineage, no-coercion과 safe evidence/physical closure owner가 있는 것입니다. 필드별 누락·type·label·JSON·근거 위반, limited/insufficient RSS, prompt injection·외부 사실·중복 response fixture를 WBS-15·23·25에 연결합니다.

[UNKNOWN] 실제 output field·JSON schema·controlled code·numeric scale·keyword 수·length, 문장 판정·한국어 기준, information sufficiency·reason code·validation 우선순위와 safe syntax normalization 범위는 SPK-02와 WBS-04.D·06.D·08 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 output schema·validator·quality rubric을 승인했다는 뜻이 아닙니다.

#### WBS-06.D Attempt, Error, Retry, and Uncertainty Review Contract

[FACT] WBS-06.D 실행 산출물은 AI error-decision register와 retry·late-response responsibility matrix입니다. 실제 provider error code, backoff·retry 횟수·시간 값, SDK 예외 mapping 또는 실행 code를 확정하지 않으며, SPK-02·06 evidence를 근거로 구현 전 승인할 판단 축과 fail-closed 기본 동작을 정의합니다.

| Register field | 계획상 의미 | 미확정 시 기본 처리 |
| --- | --- | --- |
| Provider·model·contract version | 오류를 관찰한 외부 계약과 실행 대상 | 다른 provider·model 계약으로 추정하거나 자동 전환하지 않음 |
| Source attempt·phase | `prepared`, invocation 시작, 응답·검증 등 오류가 발생한 단계 | invocation 여부를 알 수 없으면 external effect uncertain |
| Observed evidence | redacted response·error·header·usage·limit·timestamp 등 실제 관찰 근거 | 메시지 문구만으로 효과·quota를 단정하지 않음 |
| Logical cause family | provider별 code를 안정적인 내부 원인군으로 mapping | 근거 부족은 `unknown`으로 유지 |
| Evidence confidence | 공식 계약과 관찰 evidence가 판정을 지지하는 정도 | 불충분하면 확정 원인으로 승격하지 않음 |
| External effect certainty | 호출 미발생·발생·결과 수신·효과 불명확의 구분 | 불명확하면 자동 재호출 금지 |
| Retry eligibility | retryable·terminal·blocked·uncertain 판단과 근거 | retryable로 추정하지 않음 |
| New-attempt preconditions | 동일 후보·source·configuration·contract·gate·lease·budget·deadline 재검증 | 하나라도 불충족이면 새 attempt 금지 |
| Budget·schedule | candidate·batch·Asia/Seoul day별 call/token 한도와 backoff·reset·deadline | 무료 한도와 deadline을 초과하는 retry 금지 |
| Candidate outcome handoff | 분석 성공, 대기, 명시적 실패·불확실 상태를 WBS-06.E로 전달 | batch 결과나 notice를 WBS-06.D에서 임의 확정하지 않음 |
| Verification owner | SPK·unit/contract/fault/integration·운영 evidence owner | owner 없는 오류 분류는 Coding Readiness 차단 |

[FACT] AI attempt는 외부 호출 전에 `prepared`로 durable 기록하고 invocation 시작을 별도 phase로 남깁니다. Invocation 전이고 configuration·비용 gate·lease가 여전히 유효한 경우에만 동일 prepared attempt를 재개할 수 있습니다. Invocation이 시작된 attempt를 다시 prepared로 되돌리지 않으며, 승인된 retry는 기존 attempt를 덮어쓰지 않고 새 attempt를 생성해 source attempt와 원인·근거를 연결합니다.

| Cause family | 계획 경계 | 금지되는 추정·자동 처리 |
| --- | --- | --- |
| Quota exhausted | 무료 quota의 소진·reset evidence와 영향 범위를 보존 | 유료 전환, 다른 project·credential·provider 자동 사용 |
| Rate limited | quota 소진과 구분하고 retry-after·reset·deadline·budget 근거로 판정 | 모든 제한 응답을 동일 backoff로 처리 |
| Authentication / configuration | credential·project·model·endpoint 계약 불일치를 분리 | credential·project·model 자동 교체 |
| Safety / policy refusal | provider 정책 거절과 입력·출력 근거를 보존 | 정상 또는 low-information analysis로 coercion |
| Timeout / no response | 호출 단계와 응답 부재를 기록하고 효과 불명확 여부 판정 | 불명확한 호출의 즉시 자동 retry |
| Provider server error | 공식 계약상 처리 미발생·retry 가능 evidence가 있을 때만 retry 후보 | 5xx 계열이라는 이유만으로 결과 미생성을 단정 |
| Parse / schema / type | WBS-06.C validation failure로 analysis를 만들지 않음 | 기본값 보완; 승인 정책 없는 재호출 |
| RSS evidence validation | 허용 evidence·lineage 위반으로 정상 결과와 분리 | 외부 지식이나 원문 기사로 보정 |
| Cost / contract blocked | free-only·no-paid-fallback gate가 닫히면 호출하지 않음 | 비용 확인 전 호출 또는 자동 유료 fallback |
| External effect uncertain | late evidence를 기다리고 별도 불확실 상태 유지 | 성공·실패 추정 또는 자동 재호출 |
| Unknown | 원인·confidence·추가 evidence owner를 그대로 유지 | 편의를 위한 retryable·terminal 임의 분류 |

[INFERENCE] Retry eligibility는 오류 이름 하나가 아니라 같은 candidate와 source observation, 승인 configuration·provider contract, 유효 비용 gate, current lease/fencing, candidate·batch·일별 call/token budget, backoff/reset 시각과 내부 처리 deadline을 모두 재확인한 결합 판정이어야 합니다. 명시적 retryable terminal failure만 새 prepared attempt를 만들 수 있고, retry 과정에서 model·provider·credential·project·prompt·judgment policy를 자동 변경하지 않습니다.

[INFERENCE] 물리 호출 수와 token/usage는 논리 candidate 수와 분리해 candidate·batch·Asia/Seoul day 단위로 집계합니다. 재시도는 처리 준비 마감 이전의 남은 시간과 승인 budget 안에서만 예약하며, deadline 경과를 정상 미선정으로 바꾸지 않습니다. Deadline 뒤 추가 retry가 불가능한 candidate의 terminalization 근거와 batch 완료 가능성은 WBS-06.E가 판정합니다.

[FACT] Late response·usage·limit evidence는 정확한 source attempt와 correlation을 확인한 뒤 append-only로 보존합니다. 관찰된 사용량·제한 evidence는 늦게 도착했다는 이유로 비용 evidence에서 제외하지 않습니다. 다만 분석 결과 적용은 해당 candidate가 아직 unresolved이고 selection result가 final이 아니며 동일 source·configuration·contract의 validation을 통과한 경우에만 검토할 수 있습니다. 이미 canonical analysis 또는 immutable selection result가 있으면 late result는 evidence와 비적용 사유만 남기고 결과를 교체하지 않습니다.

[INFERENCE] WBS-06.D 완료 조건은 모든 오류가 원인군·근거 confidence·외부 효과 certainty·retry 자격·budget/deadline·candidate handoff와 검증 owner를 가지며, invocation 시작 뒤 동일 attempt 재사용, 불명확 효과 자동 재호출, 무승인 model/provider 전환, 유료 fallback, late result의 final 결과 덮어쓰기와 관찰 usage 누락이 0건이 되도록 WBS-15·23·25 검증에 연결되는 것입니다.

[UNKNOWN] 실제 provider error code·HTTP/SDK exception mapping, retry-after·reset 신뢰 기준, candidate·batch·일별 call/token budget, backoff·jitter·최대 attempt·내부 처리 deadline, correlation 수단, late-response 관찰 가능성과 safety/policy·schema 실패의 retry 허용 여부는 SPK-02·06과 WBS-04.D·06.E 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 retry 정책 값·provider mapping·schema·code를 승인했다는 뜻이 아닙니다.

#### WBS-06.E Candidate Completion and Batch Failure Review Contract

[FACT] WBS-06.E 실행 산출물은 candidate-resolution register와 batch-completion decision register입니다. 개별 AI attempt의 실패를 candidate 또는 batch 실패로 즉시 승격하지 않고, candidate별 대표 처리 결과와 전체 batch의 완료 가능성을 단계적으로 판정해 WBS-06.F에 finalization 자격과 근거를 전달합니다. 실제 상태 enum·schema·SQL 또는 immutable `selection_result`는 이 checkpoint에서 만들지 않습니다.

| Candidate resolution class | 계획상 의미 | Batch 판정 기여 |
| --- | --- | --- |
| Awaiting / processing | 필요한 분석이 아직 시작되지 않았거나 유효한 attempt가 진행 중 | final result·기사 목록·failure notice 모두 금지 |
| Safe retry waiting | WBS-06.D의 retry 자격·gate·budget·deadline을 충족해 새 attempt가 가능 | 처리 중으로 유지하고 finalization 금지 |
| Normal resolved | 검증된 normal `article_analysis`가 최초로 candidate를 해결 | 처리 완료 수량과 selection input 후보에 포함 |
| Low-information resolved | 검증된 low-information `article_analysis`가 최초로 candidate를 해결 | 정상 실패가 아닌 처리 완료 수량과 selection input 후보에 포함 |
| Freshness terminal | 승인 최신성 기준으로 현재 기사 선정 자격이 없음 | AI 실패로 바꾸지 않고 terminal reason·summary로 설명 |
| Time-validation terminal | `published` 누락·오류·비교 불가로 현재 기사 선정 자격이 없음 | AI 실패로 바꾸지 않고 terminal reason·summary로 설명 |
| Analysis impossible | quota·비용 차단·영구 오류·승인된 처리 마감 등으로 필요한 분석을 더 완료할 수 없음 | 원인·근거와 함께 failure-notice 자격 판단에 포함 |
| Cause unresolved | 근거 부족으로 완료 가능성이나 원인을 확정하지 못함 | 정상·실패·0건으로 추정하지 않고 finalization 차단; 승인 마감 정책 적용 시 별도 terminalization 근거 필요 |

[FACT] 위 class는 계획상 배타적 대표 결과 범주이며 실제 enum 이름이 아닙니다. Attempt의 timeout·rate limit·provider 오류·validation 실패는 append-only attempt 결과로 남고, 승인된 retry가 가능하면 candidate는 safe retry waiting입니다. Retry 불가 또는 종료 근거가 확정돼야만 analysis impossible로 전환할 수 있으며, 이전 attempt 원인과 evidence를 덮어쓰지 않습니다.

| Batch decision | 필수 조건 | 허용되는 다음 동작 | 금지되는 동작 |
| --- | --- | --- | --- |
| Processing in progress | awaiting·processing·safe retry waiting 또는 마감 전 원인 미확정 candidate가 1건 이상 | WBS-06.D에 attempt/retry를 위임하고 기사 목록 보류 | final result·failure notice·부분 기사 목록 생성 |
| Full-selection eligible | RSS·입력 단계가 완료되고 모든 고유 신규 candidate가 normal·low-information 또는 승인된 비-AI terminal reason으로 설명되며 필요한 AI 미처리가 0건 | WBS-06.F의 lease·fencing·transaction 재대조로 selection 수행 | WBS-06.E에서 candidate selection·batch item·delivery 생성 |
| Partial-failure eligible | analysis impossible인 candidate가 1건 이상이고, 정상 또는 low-information resolved candidate가 1건 이상이며 전체 선정 완료 불가능이 승인 근거로 확정 | WBS-06.F에 partial `processing_failure_notice` 자격·수량·원인 전달 | 완료 분석의 기사 목록·candidate selection·batch item 생성 |
| Total-failure eligible | 고유 신규 candidate가 존재하고 정상·low-information resolved가 0건이며 전체 선정 완료 불가능이 승인 근거로 확정 | WBS-06.F에 total `processing_failure_notice` 자격·수량·원인 전달 | `normal_no_new_candidates`, 기사 목록 또는 유료 fallback |
| Clean-zero eligible | 정상적인 RSS·입력 완료, 고유 신규 후보·후보 생성 불가능 입력 오류·미처리·실패가 모두 0 | WBS-06.F에 `normal_no_new_candidates` 자격 전달 | 다른 batch recovery를 source batch 신규 결과로 합산 |
| Inconsistent / not measurable | candidate count·lineage·근거가 불일치하거나 restore/ledger 완전성을 확인할 수 없음 | fail-closed 차단과 관측·복구 owner로 전달 | 정상·실패·0건 추정 또는 수량 보정 |

[INFERENCE] 승인된 내부 처리 마감은 무한 대기를 막는 scheduling gate입니다. 마감 경과 뒤 새 AI retry는 시작하지 않고, 남은 candidate마다 `마감 정책으로 추가 처리가 허용되지 않음`이라는 terminalization 근거와 직전 attempt 원인·external effect certainty를 함께 보존합니다. 마감 경과 자체를 quota·영구 provider 오류로 바꾸지 않지만, 승인 정책상 더 처리할 수 없다는 근거가 완비되면 analysis impossible과 batch failure 자격을 판정할 수 있습니다. 원인·candidate·수량 또는 마감 적용 근거가 불완전하면 임의로 failure notice를 고정하지 않습니다.

[FACT] Partial과 total processing failure는 선정 기사 수가 아니라 검증된 normal·low-information analysis 확보 여부로 구분합니다. 완료 분석이 하나 이상이면 partial, 하나도 없으면 total입니다. 두 경우 모두 일부 article list, `candidate_selection`, `batch_item`을 만들지 않으며, 실패 notice 자격에는 전체 신규 후보 수·처리 완료 수·미처리 수·원인별 영향 수량·유료 전환 없음 근거가 포함돼야 합니다.

[INFERENCE] Candidate reconciliation snapshot은 같은 source batch와 같은 판정 기준 시점에서 다음 불변식을 검증해야 합니다.

```text
고유 신규 candidate 수
  = normal resolved
  + low-information resolved
  + 명시적 미처리 candidate

명시적 미처리 candidate
  = 처리 중·재시도 대기·원인 미확정
  + freshness terminal·time-validation terminal
  + analysis impossible
```

[FACT] 진행 중 snapshot의 처리 중·재시도 대기·원인 미확정 수량은 가시성을 위한 미처리 수량이지만 final failure를 뜻하지 않습니다. Full-selection 자격에서는 필요한 AI 미처리가 0이어야 하고, failure-notice 자격에서는 처리 중·재시도 대기가 0이며 남은 미처리가 승인된 terminal 근거로 설명돼야 합니다. 정상·저정보 후보는 선정·홍보성 제외·최대 제한 미선정 중 하나의 최종 결정을 WBS-06.F에서 가져야 하며, freshness·time-validation terminal을 억지로 selection decision으로 바꾸지 않습니다.

[INFERENCE] 복수 attempt 원인은 모두 append-only evidence로 유지하되 candidate 대표 terminal reason과 batch summary의 원인별 영향 수량은 같은 판단 규칙·시점으로 도출합니다. 대표 원인을 선택하더라도 다른 원인을 삭제하거나 같은 candidate를 여러 원인 수량에 중복 합산하지 않으며, multi-cause 표시가 필요하면 배타적 대표 수량과 보조 원인 evidence를 구분합니다.

[FACT] WBS-06.E는 finalization eligibility와 immutable input snapshot 후보만 제공합니다. WBS-06.F는 current Prepare lease·fencing 아래 RSS/input 완료, candidate 대표 결과·수량, 기존 final result 부재를 transaction 안에서 다시 대조한 뒤 `full_selection` 또는 `processing_failure_notice`를 원자적으로 고정합니다. 실패 notice의 Discord payload·전달·수락 evidence는 WBS-07이 담당하며 처리 지연 full result와 Discord 미수락 recovery backlog를 섞지 않습니다.

[INFERENCE] WBS-06.E 완료 조건은 candidate마다 배타적 대표 결과·원인·근거·판정 시점이 있고, attempt 실패와 candidate/batch 실패가 분리되며, 마감 전 retry 대기에는 final result가 없고, 마감 후 terminalization과 partial/total 기준·수량 불변식·WBS-06.F handoff가 검증 owner에 연결되는 것입니다. 미처리 후보의 정상 미선정·정상 0건 변환, 일부 기사 목록, 원인·수량 없는 failure notice, candidate 누락·중복 집계와 무한 대기는 WBS-15·23·25 fixture에서 0건이어야 합니다.

[UNKNOWN] 실제 candidate 상태 enum, 내부 처리 마감 값, provider별 terminal·retry 우선순위, 복수 오류의 대표 원인 규칙, 마감 시 external-effect-uncertain 처리, late response 관찰 capability, reconciliation 기준 시점과 물리 constraint는 SPK-02·06과 WBS-04.D·06.F 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 enum·deadline·원인 우선순위·schema·SQL·code를 승인했다는 뜻이 아닙니다.

#### WBS-06.F Selection, Finalization, and Delivery Handoff Review Contract

[FACT] WBS-06.F 실행 산출물은 selection-policy decision register, deterministic selection execution contract, immutable result/finalization matrix와 delivery-handoff eligibility register입니다. 승인된 논리 결과를 구현 가능한 결정 항목으로 분해하되 실제 중요도 score·가중치·threshold·tie-break를 확정하지 않으며, 미승인 정책은 WBS-09 Coding Readiness blocker로 유지합니다.

| Selection-policy field | 계획상 필요한 결정 | 승인 전 기본 경계 |
| --- | --- | --- |
| Policy·configuration version | batch에 binding된 판단·선정 기준과 적용 시점 | 현재 설정이나 새 snapshot으로 소급 대체 금지 |
| Eligible analysis | source batch candidate를 최초로 해결한 selection-eligible normal 또는 low-information analysis | late·중복·다른 batch·실패 attempt 결과 혼입 금지 |
| Promotional exclusion | 충분한 RSS 근거와 승인 정책 version에 따른 제외 조건 | 애매·판단 불가·회사/제품명·source type·keyword 단독 제외 금지 |
| Importance contribution | 전체 IT 중요도의 정렬 기여와 판단 불가 처리 | 판단 불가를 낮음으로 coercion 금지 |
| Interest contribution | 사용자 관심 적합성의 별도 기여 | 관심 낮음·주제 밖만으로 탈락 금지 |
| Combination and order | 중요도·관심의 조합·가중과 전체 정렬 방향 | 미승인 임의 수식 사용 금지 |
| Deterministic tie-break | 모든 동률을 stable total order로 해소하는 승인 규칙 | feed 순서·DB 반환 순서·현재 시각 의존 금지 |
| Maximum selection | 홍보성 제외 뒤 정렬된 normal·low-information 후보 중 최대 10개 | 저정보 별도 상한·복구 기사와 상한 합산 금지 |
| Candidate decision | selected·promotional excluded·limit not selected, rank·reason·policy lineage | 미처리·입력 오류·기존/중복·freshness terminal의 selection 결정 생성 금지 |
| Verification owner | 경계·동률·순서 변경·재실행·정책 version fixture | owner 없는 정책은 Coding Readiness 차단 |

[FACT] 선정 입력은 해당 source batch의 분석 완료 candidate와 최초 selection-eligible `article_analysis` reference로 제한합니다. Freshness·시간 검증 terminal, 미처리, 후보 생성 불가능 입력 오류, 기존·중복 observation, 실패·불확실 attempt와 다른 batch의 analysis는 선정 pool에 넣거나 순위 최하위·홍보성 제외·최대 제한 미선정으로 변환하지 않습니다.

[FACT] 충분한 근거의 홍보성 후보를 먼저 `promotional_excluded`로 설명하고, 애매하거나 판단 불가인 후보는 선정 가능성을 유지합니다. 남은 normal·low-information 후보는 같은 pool에서 승인된 중요도 중심 정책과 관심 적합성의 별도 판단을 reference해 정렬합니다. 관심 적합성이 낮거나 관심 주제 밖이라는 이유만으로 제거하지 않으며 전체 IT 중요도가 높은 후보의 선정 가능성을 유지합니다.

[INFERENCE] 재실행·feed 순서·DB query plan이 바뀌어도 같은 batch binding과 같은 canonical input에는 같은 candidate 결정·순위·표시 순서가 나와야 합니다. 따라서 중요도·관심 조합뿐 아니라 판단 불가 처리와 모든 동률을 해소하는 stable total-order key가 사용자 승인돼야 하며, 그전에는 실제 selection code 작업을 시작하지 않습니다.

| Final result eligibility | Immutable result | Candidate selection / batch item | 사용자 표시·handoff 경계 |
| --- | --- | --- | --- |
| 선정 후보 1건 이상 | `full_selection / article_list` | 분석 완료 candidate마다 배타적 selection 결정, selected에만 최대 10개 `batch_item` | article result와 원래 batch summary를 재사용 |
| 신규 후보 또는 입력 오류가 있으나 선정 0건 | `full_selection / selection_summary_no_articles` | 분석 완료 candidate는 홍보성 제외·최대 제한 미선정으로 설명; freshness/time terminal은 candidate reason으로 설명 | 정상 0건이 아닌 원인별 summary가 필요한 결과 |
| RSS·입력·처리 정상이며 신규 후보·입력 오류·미처리·실패 모두 0 | `full_selection / normal_no_new_candidates` | 0건 | source current Discord message 없음 |
| WBS-06.E가 전체 선정 불가능을 확정 | `processing_failure_notice` | `candidate_selection`·`batch_item` 0건 | partial/total, 완료·미처리·원인별 수량과 유료 전환 없음 표시 |

[FACT] `input_constrained_result`, 저정보, 후보 생성 불가능 입력 오류, freshness·시간 검증 terminal, 홍보성 제외와 최대 제한 미선정은 독립 completion과 경쟁하는 새 final result가 아니라 immutable summary의 qualifier·수량·사유입니다. 입력 오류가 있거나 신규 후보가 있었던 선정 0건을 `normal_no_new_candidates`로 바꾸지 않습니다.

[INFERENCE] `full_selection` 수량 closure는 같은 source batch·configuration·판정 시점에서 다음을 만족해야 합니다.

```text
selection 대상 분석 완료 candidate 수
  = selected
  + promotional_excluded
  + limit_not_selected

batch_item 수 = selected 수 ≤ 10
```

[FACT] Freshness·시간 검증 결과는 source scheduled batch의 예정 전달 시각을 기준으로 candidate 단계에서 고정한 reference를 사용합니다. Finalization이 늦었다는 이유로 현재 wall clock에 맞춰 freshness를 재계산하거나 기존 analysis·선정 자격을 변경하지 않습니다. 목표 전달 시각 경과 자체도 처리 실패 원인이 아니며, 목표 뒤 `full_selection` 고정 여부는 delivery handoff 종류만 결정합니다.

[FACT] Selection finalization은 source Prepare work의 마지막 내부 단계입니다. Current Prepare lease·fencing token을 가진 execution만 짧은 transaction에서 RSS·입력 완료, WBS-06.E candidate 결과·수량, batch configuration binding과 기존 final result 부재를 재대조합니다. 신규 결과이면 `selection_result`, immutable summary, 필요한 `candidate_selection`·`batch_item`, Prepare work 완료와 attempt 종료를 함께 고정하고, 기존 result가 있으면 재사용합니다.

[FACT] Commit 전 중단·stale token·미충족 predicate에는 partial result·candidate decision·batch item·성공 완료가 남지 않습니다. Commit 뒤 중단·동시 trigger·late AI result는 고정 결과를 다시 계산·추가·교체하지 않습니다. Selection transaction은 `delivery_set`, Discord domain attempt·message mapping 또는 외부 호출을 만들지 않습니다.

| Committed result·timing | Downstream eligibility | 분리 조건 |
| --- | --- | --- |
| 목표 시각 전 고정된 사용자 메시지 필요 full result | scheduled-current delivery work | Discord attempt는 10:00·22:00보다 먼저 시작하지 않음 |
| 목표 시각 뒤 고정된 사용자 메시지 필요 `full_selection` | 원래 batch의 `processing_delayed_full_result` 전용 work | 즉시 release 대상으로 하되 current·recovery backlog와 같은 set/segment에 혼합 금지 |
| `processing_failure_notice` | article 없는 `failure_notice` work | no-early-attempt gate와 post-target release timing의 실제 scheduling은 WBS-07 closure |
| `normal_no_new_candidates` | source current no-message | 다른 원래 batch의 확인된 recovery-only work를 막거나 source 결과로 합산하지 않음 |

[INFERENCE] Producer commit 뒤 delivery work admission 전에 process가 중단돼도 application memory·같은 Pod 생존에 의존하지 않고 committed result에서 동일 logical delivery work를 idempotent하게 재발견해야 합니다. Selection transaction과 같은 transaction의 delivery-work 등록 후보와 post-commit discovery 후보는 WBS-04.C에서 비교하되, 어떤 방식도 delivery set·Discord attempt·외부 호출을 selection commit에 결합할 수 없습니다.

[INFERENCE] WBS-06.F 완료 조건은 selection input이 배타적이고, 홍보성 제외·중요도·관심·판단 불가·tie-break·최대 10개가 versioned deterministic policy로 결정 가능하며, 모든 full-selection candidate와 summary 수량이 대조되고, current/delayed/notice/no-message handoff가 immutable result에서 유실·중복 없이 파생되는 것입니다. 순서 변경·동률·0·1·9·10·11·30·100건, 전부 홍보성 제외, freshness/time terminal, 처리 실패, commit 전후 중단·stale lease·late result fixture를 WBS-15~16·23~25에 연결합니다.

[UNKNOWN] 실제 importance·interest label/score·가중·정렬 방향, promotional threshold, 판단 불가 처리와 deterministic tie-break key는 WBS-06.F의 evidence-backed 후속 결정과 사용자 승인 전 확정되지 않습니다. Candidate reason code·result/summary 물리 field·transaction isolation·constraint와 delivery work admission 방식은 WBS-04.C~D physical closure 전 확정되지 않습니다. WBS-08은 고정된 운영 policy version과 결과를 독립 평가할 뿐 운영 selection policy를 결정·소급 변경하지 않으며, WBS-09는 이 blocking 결정을 검증합니다. 이 review contract의 승인은 실제 selection 정책·schema·SQL·code 또는 Discord 전달 계약을 승인했다는 뜻이 아닙니다.

#### WBS-06.A~F Consistency and Closure Review

[FACT] WBS-06.A~F의 항목별 사용자 승인은 implementation-plan의 작업 정의와 검토 경계를 승인한 것입니다. 실제 provider evidence·입출력 계약·retry 값·candidate terminal·selection policy가 아직 미확정이므로 WBS-06의 evidence-backed 구현 계약 완료 또는 Coding Readiness 통과를 뜻하지 않습니다.

| WBS-06 lifecycle state | 의미 | 진입 조건 | 허용되는 다음 동작 |
| --- | --- | --- | --- |
| Plan definition approved | A~F의 작업 단위·owner·gate·검증 계획 승인 | 이번 순차 검토와 정합성 승인 | spike·상세 결정·physical closure 수행 |
| Evidence pending / blocked | 외부 evidence 또는 사용자 결정이 부족 | SPK fail·blocked·inconclusive 또는 blocking `[UNKNOWN]` 존재 | fail-closed 유지, 보완 evidence·명시적 사용자 결정만 허용 |
| Evidence-backed contract approved | 실제 provider·입출력·retry·completion·selection 계약 승인 | 아래 closure checklist 전부 충족 | WBS-04.D closure와 WBS-09 Coding Readiness 판정 |
| Contract invalidated | 공식 계약·configuration·비용·capability fingerprint 변경 | VR-011 trigger | 영향 outbound 차단, 재검증·재승인 전 자동 재개 금지 |

[INFERENCE] WBS-06의 정방향 canonical lineage와 owner는 다음과 같이 고정합니다.

```text
SPK-01 RSS field evidence
  → WBS-06.B input/provenance decision
  → WBS-04.D physical manifest
  → WBS-14 implementation

SPK-06A → SPK-02 → SPK-06B → 사용자 provider 승인
  → WBS-06.A provider/contract binding
  → WBS-06.B request input/version
  → WBS-06.C validated output class
  → WBS-06.D attempt/error/retry evidence
  → WBS-06.E candidate resolution/batch eligibility
  → WBS-06.F immutable selection result/durable handoff
  → WBS-07 delivery contract
```

[FACT] WBS-04.D는 field·type·allowlist·size·constraint의 physical owner이고, WBS-05는 generic work·lease·fencing·external uncertainty owner입니다. WBS-06은 AI domain 결과와 selection owner이며, WBS-07은 Discord delivery·acceptance owner입니다. WBS-08은 immutable evaluation·human review owner로서 운영 selection 결과를 평가하지만 그 결과로 원래 analysis·candidate·selection result를 변경하지 않습니다.

| Time basis | Canonical input | 결정하는 것 | 결정하지 않는 것 |
| --- | --- | --- | --- |
| AI 내부 처리 마감 | source batch와 승인 processing policy에 binding된 시각 | 새 retry 허용 여부, 마감 terminalization 절차 | current/delayed delivery 구간, provider 오류 원인 |
| 예정 Discord 전달 시각 | source `scheduled_batch`의 10:00·22:00 KST target | scheduled-current와 processing-delayed handoff | AI partial/total failure |
| Candidate freshness 기준 | 예정 전달 시각과 source observation의 parsed `published` | 13시간 경계·시간 검증 terminal | finalization wall clock 기준 재평가 |
| Final result 고정 시각 | selection transaction의 committed timestamp | 결과 준비시간·delivery eligibility | 원래 RSS·analysis·candidate 판단 변경 |

[FACT] 내부 처리 마감 경과는 승인 정책상 추가 retry가 허용되지 않는다는 terminalization 근거가 될 수 있지만 quota·영구 provider 오류로 바꾸지 않습니다. 예정 전달 시각 경과만으로는 processing failure가 되지 않으며, 이후 완료된 `full_selection`은 원래 batch의 `processing_delayed_full_result` handoff로 분류합니다. WBS-16은 candidate에 이미 고정된 freshness·시간 결과를 reference하고 finalization 현재 시각으로 재계산하지 않습니다.

[INFERENCE] Cross-checkpoint 수량과 결과 closure는 같은 source batch·configuration binding·판정 시점을 사용해야 합니다.

```text
고유 신규 candidate
  = normal analysis + low-information analysis + 명시적 미처리

full-selection 대상 분석 완료 candidate
  = selected + promotional_excluded + limit_not_selected

batch_item = selected ≤ 10
```

[FACT] 첫 번째 식의 처리 중·retry 대기·원인 미확정은 가시성용 미처리이지 failure notice 자격이 아닙니다. Full selection에는 필요한 AI 미처리 0건이 필요하고, failure notice에는 처리 중·retry 대기 0건과 승인된 analysis-impossible 근거가 필요합니다. 어떤 식에서도 physical attempt·retry·token·Discord message 수를 candidate·selection 수에 합치지 않습니다.

[FACT] Canonical owner를 역방향으로 변경하지 않습니다. Provider evidence는 analysis 값을 소유하지 않고, evaluation은 operational selection을 변경하지 않으며, delivery 실패는 selection result를 재계산하지 않습니다. Late AI response는 candidate가 미해결이고 final result가 없을 때만 검증 대상이며, final result 뒤에는 evidence와 non-application reason만 남깁니다.

[INFERENCE] WBS-06의 evidence-backed contract closure checklist는 다음 항목을 모두 요구합니다.

- SPK-06A·02·06B pass와 단일 free-only provider의 명시적 사용자 승인
- SPK-01 evidence 기반 content/description precedence·normalization·serialization 승인
- 실제 input/prompt/output/version 계약과 runtime deterministic validator 승인
- provider 오류 mapping, retry/backoff/budget·내부 처리 마감과 external uncertainty 처리 승인
- candidate terminal·복수 원인·batch completion/partial/total failure 판정 승인
- importance·interest·promotional·판단 불가·deterministic tie-break·최대 10개 운영 selection policy 승인
- WBS-04.C~D에 전달할 physical field·allowlist·transaction·handoff 요구가 누락 없이 정의
- P0-HG negative/fault fixture owner와 WBS-15~16·23~25 검증 연결

[INFERENCE] 위 checklist 중 하나라도 미충족이면 WBS-06은 plan-definition 승인 상태에 머물며 WBS-09를 통과하지 않습니다. 문서 정합성 검토로 owner·순환·시간 기준 모호성은 줄어들지만 provider 계약 변경, 품질·quota, 구현 결함, 동시성·외부 장애와 실제 0원 비용 위험은 해당 spike·구현·검증 evidence가 통과할 때까지 남습니다.

[UNKNOWN] 현재 evidence-backed closure를 차단하는 실제 값은 최종 provider/model/SDK·비용 안전 configuration, RSS input precedence·정규화, input/output contract, 오류 mapping·retry·마감, candidate reason/terminal, selection score·조합·tie-break와 physical schema/transaction입니다. 이 consistency 승인은 이 값들을 확정하지 않으며 각 owner의 후속 Proposed Changes와 사용자 승인이 필요합니다.

### WBS-07 Internal Review Checkpoints

[FACT] WBS-07은 Discord 전달, feedback과 recovery를 하나의 외부 호출·상태 축으로 합치는 작업이 아닙니다. 아래 checkpoint는 독립 검토 단위이며 새로운 상위 WBS Task가 아닙니다. 이번 승인은 분해 구조와 계획 경계를 승인한 것이고 실제 Discord interface·권한·payload·command·reaction·retry 계약 승인이 아닙니다.

| ID | 검토 범위 | 계획 산출물 | 선행·closure 조건 |
| --- | --- | --- | --- |
| WBS-07.A | Discord contract·identity·permission·cost activation | delivery·Gateway·REST·interaction·recovery operation contract/decision register, official/configured/sandbox/cost evidence, principal·target·identifier·permission·Secret·acceptance/correlation·VR-011 재검증 경계 | SPK-06A→03→06B와 사용자 승인; selected/rejected/blocked/inconclusive 분리, 실제 Discord 호출·설정·credential 입력 없음 |
| WBS-07.B | Logical rendering·segment·physical mapping | source-reference rendering contract, scheduled current·processing delayed·confirmed recovery·failure notice·receipt confirmation composition matrix, 10/10/20 상한, deterministic split·item subset·대표 mapping·delivery version/safe payload hash | WBS-06.F committed result·handoff와 WBS-07.A; invocation·acceptance는 WBS-07.C, physical field는 WBS-04.D closure |
| WBS-07.C | Delivery attempt·acceptance·uncertainty | physical mapping별 prepared/invocation/evidence lifecycle, 호출 직전 lease·DB·contract·cost·timing gate, response+message ID acceptance matrix, error/retry·late evidence와 item-scope partial/unattempted reconciliation | WBS-05.C~E와 WBS-07.A~B; confirmation/recovery는 WBS-07.G, 실제 acceptance·error·retry 계약은 SPK-03 evidence 필요 |
| WBS-07.D | Gateway event·feedback projection | Gateway event register, configuration·guild/channel·message/item·승인 사용자·reaction mapping, append-only history·dedupe·ordering/gap 판정, article reaction·batch ✅ current projection과 recipient receipt·system-message·evaluation 분리 | WBS-07.A~C와 DDI-04; REST 대조는 WBS-07.E, missing/receipt interaction은 WBS-07.F, 실제 event identity·sequence·resume은 SPK-03 evidence 필요 |
| WBS-07.E | REST feedback reconciliation | 네 가지 허용 trigger와 event 불신 근거, request/REST invocation 분리, exact bounded scope·idempotent work, snapshot·pagination 완결성, observation ordering과 present/absent/stale/unknown/unmapped 판정, delivery acceptance·receipt·recovery·evaluation 분리 | WBS-05와 WBS-07.A·D; 정상 resume·일반 polling은 request 사유가 아니며 실제 endpoint·권한·rate limit·pagination·retry는 SPK-03 evidence 필요 |
| WBS-07.F | Interaction·missing article·receipt | operation/action register, interaction 진위·configuration·승인 사용자·대상·idempotency 검증, 단일 GeekNews topic `link` 원값 validation·exact history lookup·근거 회신, 제한된 `추천해야 했다`, exact delivery scope의 `받음`/`못 받음` typed event와 conflict·지원/거부 경계 | WBS-05와 WBS-07.A~E·DDI-10; 일반 message 추정·URL 정규화·외부 접근·RSS 재수집·현재 AI 재판단 금지, resend·recovery 실행은 WBS-07.G |
| WBS-07.G | Confirmation·recovery·reconciliation | Acceptance·receipt·late-evidence recovery case, 마지막 invocation+1시간 due·claim 후 호출 직전 재대조, 원래 batch당 confirmation 1회, exact `못 받음`의 idempotent immediate resend 1회, resend 결과·무응답 offer, confirmed non-acceptance FIFO original-batch 10개·10/10/20·additional recovery, conflict·lost-handoff closure | WBS-05와 WBS-07.B~F·AD-07·21; feedback REST와 분리, 수락 불명확·offer 불명확의 반복 confirmation/resend/재첨부 및 처리 지연 full result 혼합 금지 |

```text
WBS-06.F immutable selection result·durable handoff
  → WBS-07.B delivery set·segment·render plan
  → WBS-07.C physical invocation·server acceptance evidence
  → WBS-07.D Gateway raw event·feedback projection
  → WBS-07.E bounded feedback reconciliation
  → WBS-07.F structured interaction·receipt evidence
  → WBS-07.G confirmation·confirmed recovery
```

[FACT] 서버 수락, recipient-observed receipt, 품질 feedback, batch review와 사용자 열람은 서로 대체하지 않습니다. 유효한 Discord 2XX와 필요한 message ID가 함께 확인돼야 physical mapping의 server acceptance를 기록할 수 있고, reaction·`받음`·✅는 원래 2XX·정시 수락 시각을 소급 생성하지 않습니다. Link click이나 일반 reaction은 열람·유용함·수락 근거가 아닙니다.

[FACT] `processing_delayed_full_result`는 목표 시각 뒤 완료된 원래 batch의 full result이고 전용 delivery set으로 release합니다. `confirmed_non_acceptance_recovery`는 과거 Discord 미수락 item의 저장 결과를 재사용합니다. 두 구간은 모두 늦게 전달될 수 있지만 source work key·segment·상한·지표가 다르며 같은 delivery set 또는 segment에 섞지 않습니다.

[FACT] Scheduled regular delivery set에는 current와 확인된 미수락 recovery segment가 함께 있을 수 있고 각각 최대 10개, 합계 최대 20개입니다. Current 0건이어도 recovery-only set은 가능하지만 source batch의 `normal_no_new_candidates` 결과·summary·item을 recovery source로 바꾸지 않습니다. Recovery는 원래 batch의 selected item subset과 원래 summary를 reference하며 AI 재분석·재선정·freshness 재판정을 하지 않습니다.

[FACT] Article-bearing physical message mapping은 실제 표시한 `batch_item` subset을 정확히 한 번 연결하고, batch 대표 mapping은 delivery set의 실제 article scope를 한 번 참조합니다. 한 physical message의 수락을 다른 message·item 또는 delivery set 전체 성공으로 확장하지 않으며 부분 수락은 item scope에서 accepted·explicitly not accepted·acceptance uncertain을 분리합니다.

[FACT] Gateway는 변경 이력의 주 경로이고 REST는 새 연결·DB 복구·event 기록 실패·지표 계산 직전의 bounded current-state 대조에만 사용합니다. Feedback REST snapshot은 `feedback_state` projection만 보완하고 delivery acceptance·recovery event를 변경하지 않습니다. 일반 REST snapshot·제목 유사성·시간 추정은 original Discord message acceptance proof가 아닙니다.

[FACT] Failure notice와 receipt confirmation은 article-bearing message가 아닙니다. 해당 system message의 2XX·실패·일반 reaction은 그 message의 전달 근거만 변경하고, article feedback·batch review·원래 receipt·AI failure 분류·recovery backlog를 만들거나 수정하지 않습니다.

[FACT] Missing-article interaction은 비어 있지 않은 하나의 승인 GeekNews topic `link` 원값만 검증하고 저장된 exact Raw RSS link 이력을 조회합니다. Article이 없으면 MVP-A에서 `수집 기록상 누락`으로 회신하지만 실제 RSS 원천 누락·중요 기사·recall 누락으로 확정하지 않습니다. RSS 재수집, 과거 observation 재검증, GeekNews 상세 페이지·외부 원문·검색 조회를 수행하지 않습니다.

[FACT] Feedback current-state reconciliation과 delivery acceptance resolution은 trigger·scope·work·evidence owner가 다릅니다. 수락 불명확은 자동 재발송·성공·확인된 미수락으로 바꾸지 않습니다. 정확히 연결된 승인 사용자의 `못 받음`만 1회 즉시 resend를 권한화하고, 그 자체로 confirmed recovery backlog를 만들지 않습니다.

| Checkpoint | Primary realization owner | Primary verification owner |
| --- | --- | --- |
| Delivery checkpoints (`WBS-07.A~C`) | WBS-17 article/system-message rendering·delivery | WBS-23 contract/fault, WBS-24 concurrency/replay, WBS-25 E2E |
| Gateway checkpoint (`WBS-07.D`) | WBS-18 Gateway·feedback | WBS-23·25와 VR-010 |
| REST checkpoint (`WBS-07.E`) | WBS-19.A bounded REST reconciliation, WBS-18 feedback reader | WBS-23~25와 VR-010·013 |
| Interaction checkpoint (`WBS-07.F`) | WBS-18 raw interaction·missing/recommendation·receipt handoff, WBS-19.B receipt business event | WBS-23·25와 VR-003·010 |
| Recovery checkpoint (`WBS-07.G`) | WBS-19.B confirmation·receipt·recovery | WBS-23~25와 VR-004~005·012~013 |

[INFERENCE] WBS-07의 plan-definition closure에는 operation별 contract evidence owner, logical result→segment→physical message→attempt→acceptance의 정방향 lineage, Gateway/REST/interaction의 입력 검증, feedback·receipt·recovery 의미 분리, item-scope partial acceptance와 confirmation/recovery의 idempotent work key가 모두 있어야 합니다. Selection·원래 summary 역변경, 수락 근거 없는 성공, feedback 부재 추정, 수락 불명확 자동 resend, system-message feedback, 외부 기사 조회와 delayed/recovery 혼합 경로는 0건이어야 합니다.

[UNKNOWN] 실제 delivery interface, Discord Application/Gateway/REST/interaction transport, server acceptance response와 message identifier, target/channel/user identifier scope, permission·intent·resume·pagination·rate limit, payload limit·split·대표 message, command·reaction·signature 검증, retry/backoff·전체 성공·UI와 long backlog 경계는 SPK-03·06과 WBS-07.A~G의 evidence-backed 후속 승인 전 확정되지 않습니다. 이 분해 승인은 실제 Discord contract·schema·SQL·code를 승인했다는 뜻이 아닙니다.

#### WBS-07.A Discord Contract, Identity, Permission, and Cost Activation Review Contract

[FACT] WBS-07.A 실행 산출물은 operation별 Discord contract register와 interface decision register입니다. 실제 Discord Application·bot·webhook을 생성·변경하거나 credential을 입력하고 guild/channel 권한을 바꾸거나 API·Gateway·interaction을 호출하지 않습니다. SPK-03·06 evidence와 후속 사용자 승인을 받기 전 모든 interface 조합은 검증 후보입니다.

| Operation class | 검증할 capability | 다른 operation으로 대체할 수 없는 근거 |
| --- | --- | --- |
| Article·summary·notice·confirmation delivery | message 생성, positive server acceptance, 생성 message identifier, payload·분할·rate-limit·오류 evidence | Gateway event 수신이나 reaction만으로 원래 delivery acceptance를 만들 수 없음 |
| Gateway session and event intake | 연결·identify/resume, 허용 reaction·interaction event와 stable event/message/user identifiers | REST snapshot은 append-only 변경 event history를 대체하지 않음 |
| Bounded REST feedback reconciliation | 추적 message·승인 사용자·허용 reaction의 current state, pagination·rate limit·관측 시각 | Feedback REST 결과는 delivery acceptance resolution이 아님 |
| Slash command and interaction | 구조화 command, 요청 진위·승인 사용자 검증, acknowledgement/follow-up와 interaction identifier | 일반 message parsing이나 delivery response로 대체하지 않음 |
| Confirmation·resend·recovery delivery | 정확한 source recovery event에 따른 별도 message 생성·수락·mapping | 정규 current delivery나 automatic fallback으로 합치지 않음 |

[INFERENCE] Webhook은 delivery operation 후보가 될 수 있지만 Gateway event·reaction current state·slash command capability를 제공한다고 추정하지 않습니다. Bot/Application 기반 interface도 모든 delivery acceptance·REST·interaction 요구를 충족한다고 이름만으로 판단하지 않습니다. 전체 operation coverage는 명시적으로 승인된 interface와 principal 조합으로 닫되 동일 logical delivery를 여러 interface로 자동 전환·중복 발송하지 않습니다.

| Decision-register field | 필수 evidence·판정 내용 |
| --- | --- |
| Operation ID and candidate interface | 어떤 외부 효과를 어떤 공식 interface로 수행하는지 |
| Official contract fingerprint | 확인 URL·문서/revision·확인 시각·payload/response/error/rate-limit 조건 |
| Configured environment fingerprint | 비밀값을 제외한 Application·principal·target·permission·intent·endpoint class |
| Sandbox scope | 사용자 승인 test guild/channel/user와 금지 production 범위 |
| Request and response evidence | redacted request class, response/error, message/event/interaction identifier와 관측 시각 |
| Acceptance / correlation capability | physical attempt와 exact message/event/interaction을 lossless하게 연결 가능한지 |
| Permission and Secret boundary | 필요한 최소 permission·intent, credential 종류·consumer·rotation/redaction owner |
| Cost evidence | Discord 기능과 listener/runtime를 포함한 0원·유료 fallback 부재 근거 |
| Decision | selected·rejected·blocked·inconclusive와 이유·영향 operation |
| Revalidation trigger | interface·credential·permission·intent·payload·rate-limit·identity scope·비용 변경 |
| Downstream blocker | 완료할 수 없는 WBS-07.B~G·17~20·09 범위 |

[FACT] Official, configured, sandbox와 cost evidence는 서로 대체하지 않습니다. 공식 문서상 가능하다는 사실은 현재 설정·권한·sandbox 동작을 증명하지 않고, sandbox 성공은 운영 cost·contract drift 또는 장기 Gateway resume를 자동 증명하지 않습니다. Evidence가 없거나 서로 불일치하면 pass로 추정하지 않고 blocked 또는 inconclusive로 유지합니다.

[ASSUMPTION] SPK-03은 사용자 승인 sandbox/test guild·channel·identity에서만 수행하고 production channel이나 실제 운영 사용자에게 메시지를 보내지 않습니다. Sandbox·Application 생성 권한·테스트 사용자 범위가 없으면 production으로 우회하지 않고 blocked로 판정합니다. 실제 sandbox scope와 테스트 message 보존·삭제 방식은 spike 실행 전 별도 승인이 필요합니다.

[INFERENCE] Identity register는 Application, bot/webhook principal, guild/server, channel, target recipient, approved project user, message, interaction, Gateway event와 delivery attempt를 서로 다른 type과 scope로 보존해야 합니다. 표시 문자열·이름·제목 유사성이나 현재 설정으로 동일성을 추정하지 않고, provider가 반환하는 identifier의 실제 형식·길이·scope·lossless round-trip과 변경 가능성을 SPK-03에서 검증합니다.

[FACT] Permission register는 delivery create, Gateway connect/event, bounded REST read, slash-command/interaction verify/respond와 recovery delivery의 허용·금지 operation을 구분합니다. 하나의 credential로 여러 capability를 제공할 수 있는지는 실제 계약 evidence로 판정하되, 필요하지 않은 permission·intent를 편의를 위해 추가하지 않습니다. Secret 원값은 전용 Secret 경계에서만 주입하고 DB·configuration snapshot·문서·일반 log/metric/trace·AI input·사용자 출력에 저장하지 않습니다.

[FACT] Delivery success capability는 실제 선택 interface의 긍정적 Discord server response와 생성된 physical message identifier를 같은 attempt에 연결할 수 있어야 합니다. Request 실행·client 무예외·일반 2XX·reaction·사용자 receipt만으로 이 조건을 보완하지 않습니다. 필요한 message identifier나 exact mapping을 sandbox에서 확보할 수 없는 candidate는 delivery operation에 selected로 판정하지 않습니다.

[INFERENCE] Gateway·REST·interaction capability는 stable identifier뿐 아니라 reconnect/resume·event duplicate/order, bounded query scope·pagination, interaction authentication·response lifecycle, rate limit과 timeout/response-loss 상태를 관찰할 수 있어야 합니다. 이 capability의 세부 처리 계약은 WBS-07.D~F가 닫고, WBS-07.A는 실제 interface가 이를 검증할 수 있는지 activation 전에 판정합니다.

[FACT] 비용 activation 순서는 SPK-06A 사전 무료·비용 안전 범위 확인, 사용자 승인 sandbox의 SPK-03 제한 실험, SPK-06B의 실제 usage와 전체 K3s listener·storage·network·registry·monitoring 비용 coverage 대조, 사용자 최종 activation 승인입니다. 어느 단계라도 fail·blocked·inconclusive이면 영향 Discord operation을 활성화하지 않고 유료 runtime·plan·interface 또는 다른 delivery interface로 자동 전환하지 않습니다.

| Decision | 의미 | 후속 동작 |
| --- | --- | --- |
| selected | operation별 공식/configured/sandbox/cost evidence와 필수 capability 충족 | 사용자 activation 승인 범위에서 후속 상세 계약 입력으로 사용 |
| rejected | 필수 capability·보안·비용·운영 조건 불충족 | 해당 candidate 사용 금지; 대안 검증은 별도 사용자 승인 |
| blocked | sandbox·권한·credential·환경 부족으로 검증 불가 | 성공으로 추정하지 않고 owner·영향 WBS 기록 |
| inconclusive | 실험은 했지만 acceptance·identifier·resume·비용 등 evidence 불충분 | 보완 검증 전 downstream 완료 차단 |

[FACT] Interface·Application/principal·credential·permission/intent·guild/channel/user scope, payload/response/message ID·rate-limit·resume·interaction 또는 비용 조건이 변경되면 VR-011 재검증 trigger입니다. 영향 operation의 신규 session·attempt·외부 호출은 차단하고 공식/configured/sandbox/cost evidence와 사용자 재승인 전 자동 재개하지 않으며 과거 selection·delivery·feedback·recovery 결과를 소급 변경하지 않습니다.

[INFERENCE] WBS-07.A 완료 조건은 모든 Discord operation에 selected interface와 exact capability·identity·permission·Secret·acceptance/correlation·cost evidence가 있고, 필요한 interface 조합과 금지 fallback이 사용자 승인되며, 변경 trigger·차단 범위·verification owner가 존재하는 것입니다. Production 우회, message ID 없는 성공 판정, 과도 권한, Secret 노출, 미확인 비용과 automatic interface fallback은 0건이어야 합니다.

[UNKNOWN] 실제 delivery interface와 Application/bot/webhook 조합, sandbox guild/channel/user, principal·identifier 자료형·scope, permission·Gateway intent, response/message ID·event·interaction contract, resume·pagination·rate limit, interaction signature와 listener/runtime 비용은 SPK-06A·03·06B와 사용자 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 Discord interface·credential·권한·설정·payload·code를 승인한 것이 아닙니다.

#### WBS-07.B Logical Rendering, Segment, and Physical Mapping Review Contract

[FACT] WBS-07.B 실행 산출물은 delivery rendering contract, segment composition matrix와 physical message mapping manifest입니다. Immutable `selection_result`와 원래 `batch_item`을 source로 사용해 Discord에 전달할 deterministic message plan을 만들되 실제 Discord payload·message·API invocation을 생성하지 않습니다. Rendering 성공은 Discord 전달 성공이나 server acceptance를 뜻하지 않습니다.

```text
selection_result
  → delivery_set
    → delivery_segment
      → source batch_item subset
        → physical Discord message mapping plan
          → WBS-07.C delivery attempt
```

| Segment / result | 허용 구성 | Article 상한 | 필수 분리·금지 경계 |
| --- | --- | ---: | --- |
| `scheduled_current` | 목표 시각 전에 고정된 current article list 또는 사용자 표시가 필요한 result summary | 최대 10 | 10:00·22:00 이전 invocation 금지; source result 재계산 금지 |
| `confirmed_non_acceptance_recovery` | 확인된 미수락 원래 selection result의 실제 item subset | 최대 10 | AI 재분석·재선정·freshness 재판정·과거 미선정 편입 금지 |
| Scheduled current + recovery | 한 정규 delivery set 안의 두 별도 segment와 source별 summary | current 10 + recovery 10, 총 20 | source batch 수량·summary 합산 금지 |
| Recovery-only | current item 없이 확인된 recovery segment | 최대 10 | current source의 `normal_no_new_candidates`를 recovery source로 변경 금지 |
| `processing_delayed_full_result` | 목표 시각 뒤 완료된 원래 batch의 사용자 표시 필요 full result 전용 set | 최대 10 | scheduled current·confirmed recovery와 동일 set/segment 혼합 금지 |
| `failure_notice` | partial/total, 처리 완료·미처리·원인별 수량과 유료 전환 없음 | 0 | article item·article feedback·batch review·recovery 생성 금지 |
| `receipt_confirmation` | 정확한 원래 acceptance-uncertain 전달에 대한 확인 요청 | 0 | 원래 server acceptance·사용자 수신·recovery 성공 추정 금지 |
| `normal_no_new_candidates` | source current no-message | 0 | 빈 current message 생성 금지; 별도 recovery-only 기회는 차단하지 않음 |

[FACT] 신규 후보 또는 후보 생성 불가능 입력 오류가 있었지만 선정 기사가 0건인 `selection_summary_no_articles`는 깨끗한 `normal_no_new_candidates`가 아닙니다. 검증된 원인별 summary와 필요한 input-constrained warning을 사용자 표시 대상으로 유지하고 정상 빈 batch로 숨기지 않습니다.

| Rendering-manifest input | Canonical source | Rendering 책임 |
| --- | --- | --- |
| Article identity·순서 | `batch_item`·`candidate_selection` | 실제 segment와 표시 순서를 reference |
| 제목·요약·정보 제한 | selection-eligible `article_analysis`와 title source | 승인된 output을 의미 변경 없이 표시 |
| Keyword | analysis별 keyword child record | 원값·순서를 유지하고 전역 normalization하지 않음 |
| Topic link | source article의 exact Raw RSS `link` | AI 생성·URL normalization·외부 원문 치환 금지 |
| Source counts·reason | immutable `selection_result` summary와 candidate terminal reference | current/recovery source별 수량을 별도로 표시 |
| Output lineage | selection result와 delivery contract/configuration version | logical·physical version을 구분해 재현 가능하게 연결 |

[FACT] Delivery rendering은 기사·analysis·selection·원래 batch summary의 새 canonical 복사본을 만들지 않습니다. Physical output은 source reference와 승인된 delivery contract/version에서 재현하며 Discord 전송 실패나 format 수정 때문에 원래 title·summary·선정 판단·수량을 변경하지 않습니다.

[INFERENCE] Physical split은 SPK-03에서 확인한 content·embed·field·component·message 제한과 승인된 안전한 escaping 규칙을 적용한 뒤 deterministic해야 합니다. Feed/DB 반환 순서나 worker마다 split 결과가 달라지지 않아야 하며, 한 segment의 같은 item을 둘 이상의 article-bearing physical message에 연결하지 않습니다.

```text
각 article-bearing physical message의 item subset 합집합
  = 해당 segment가 실제 전달하려는 batch_item subset

서로 다른 article-bearing message의 item subset 교집합
  = 0

각 mapping의 item 순서
  = source batch_item 표시 순서의 부분 순서
```

[FACT] 한 physical message의 수락은 다른 physical message·item 또는 delivery set 전체의 수락 근거가 아닙니다. WBS-07.B는 각 mapping에 실제 item subset·physical 순서와 logical source를 고정하고, mapping별 invocation·server acceptance·부분 성공 판정은 WBS-07.C로 넘깁니다.

[INFERENCE] Discord limit을 충족하기 위해 필수 기사, 제목, 정보 충분성에 맞는 요약·제한 문구, keyword, topic link, source별 수량·경고를 조용히 삭제·축약·혼합하거나 selection을 다시 계산하지 않습니다. 승인 rendering 계약 안에서 안전하게 분할할 수 없으면 외부 invocation 전에 rendering 차단 결과와 영향을 WBS-07.C에 전달하며, 정확한 상태명은 WBS-04.D·07.C 전에는 확정하지 않습니다.

[FACT] Article-bearing delivery set은 feedback·recipient-observed receipt 범위를 확인할 batch 대표 mapping을 최대 하나 가집니다. 이 mapping은 delivery set에 실제 포함된 article item 전체를 한 번 reference하고 item별 association을 복제하지 않습니다. Scheduled current+recovery set이면 두 segment의 실제 item scope를 포함하고, processing-delayed 전용 set이면 해당 set의 item만 포함합니다. Failure notice·receipt confirmation과 item 없는 result summary에는 article batch review mapping을 만들지 않습니다.

[INFERENCE] Article별 feedback 입력은 정확한 article-bearing physical mapping과 item을 연결할 수 있어야 합니다. Batch 대표 mapping의 scope는 feedback/receipt 대상 범위일 뿐 서로 다른 source selection result의 신규 후보·선정·제외·미처리 수를 합친 새 summary가 아닙니다.

[FACT] Physical delivery output/configuration version과 safe payload hash는 source selection result·output contract version과 구분합니다. Discord 제한에 대응한 승인된 split·escaping·layout 보정은 physical version으로 추적하지만 article 의미와 원래 summary를 변경하지 않습니다. Payload evidence에는 credential·Authorization·webhook URL·cookie·interaction secret 또는 불필요한 전체 원문을 넣지 않으며 실제 allowlist·hash algorithm·canonical serialization·size는 WBS-04.D가 닫습니다.

[INFERENCE] WBS-07.B 완료 조건은 모든 result가 허용 segment·상한·조합·no-message 규칙을 가지고, source reference에서 필수 표시값·summary를 재현하며, deterministic split·item 단일 mapping·대표 scope·logical/physical version이 WBS-07.C·D 검증 owner에 연결되는 것입니다. Item 누락·중복, current/recovery summary 합산, processing-delayed 혼합, silent truncation, non-article feedback mapping과 rendering 성공의 delivery 성공 오판은 WBS-17·23~25에서 0건이어야 합니다.

[UNKNOWN] 실제 Discord content/embed/component, payload·field·message 제한, Markdown·mention·link·emoji escaping, message 분할·대표 message 위치·순서, 0-item summary 표현, physical multi-message 전체 성공 표시, delivery version·payload hash의 물리 형식은 SPK-03과 WBS-04.D·07.C~D 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 payload·표시 디자인·schema·message·code를 승인한 것이 아닙니다.

#### WBS-07.C Delivery Attempt, Acceptance, and Uncertainty Review Contract

[FACT] WBS-07.C 실행 산출물은 delivery-attempt lifecycle register, invocation precondition matrix, Discord acceptance/error decision register와 late-evidence/partial-acceptance reconciliation contract입니다. WBS-07.B의 committed physical mapping plan을 외부 호출 단위로 처리하되 실제 Discord API·payload·credential을 사용하거나 retry 값·오류 code를 확정하지 않습니다.

```text
committed delivery work·render mapping
  → prepared attempt
  → invocation_started
  → Discord call
  → response/error evidence
  → physical mapping·item acceptance
```

| Attempt-register field | 계획 목적 |
| --- | --- |
| Source work·delivery set | invocation의 logical trigger와 idempotency scope 고정 |
| Intended physical mapping | article/batch/system message 종류, segment와 실제 item subset 연결 |
| Delivery contract/configuration version | 선택 interface·target·rendering·credential boundary 추적 |
| Lease·fencing and gate snapshot | stale worker·DB 불신·cost/contract 차단 호출 방지 |
| Attempt phase and timestamps | prepared·invocation started·response observation 분리 |
| Safe response/error evidence | redacted status·message ID·rate-limit·오류·관측 시각 연결 |
| Acceptance source·state | server 2XX·direct proof·recipient receipt의 서로 다른 효과 보존 |
| Retry/confirmation handoff | 자동 retry 금지·별도 WBS-07.G 판단과 source lineage |
| Verification owner | SPK-03, WBS-17·23~25 fault/replay evidence |

[INFERENCE] Discord invocation 직전에는 다음 조건을 하나의 결합 gate로 다시 확인해야 합니다.

- Committed immutable source result와 WBS-07.B physical mapping plan
- 유일한 logical delivery work·current claim·lease·fencing token
- DB·restore trust와 outbound gate
- 승인된 Discord interface·contract/configuration fingerprint
- 유효 credential·target·permission·Secret boundary
- 비용 0원 gate와 유료 fallback 부재
- 이미 accepted인 동일 mapping/item 또는 완료된 동일 logical work 부재
- Scheduled current인 경우 10:00·22:00 이전이 아님
- Confirmation·resend·recovery이면 정확한 source event와 승인 권한 존재

[FACT] 하나라도 충족하지 않으면 `prepared → invocation_started` 전이를 commit하거나 외부 호출하지 않습니다. 차단 원인과 영향 mapping/item을 보존하며 다른 credential·target·interface로 자동 전환하지 않습니다.

| Lifecycle point | 허용 동작 | 금지 동작 |
| --- | --- | --- |
| Before prepared | Source·mapping·gate 검증 | Discord 호출·성공 추정 |
| `prepared` committed | 외부 호출 intent와 source mapping durable 보존 | 호출이 이미 시작됐다고 기록 |
| Prepared 중단 | Invocation 전임이 DB로 확인되고 gate가 여전히 유효하면 같은 attempt 재개 | 무조건 새 attempt·message 생성 |
| `invocation_started` committed | 실제 외부 호출 시작 | prepared로 되돌리기·불명확 호출 자동 반복 |
| Response/error observed | Append-only safe evidence와 acceptance 판정 | 기존 evidence·selection·summary 덮어쓰기 |
| Effect uncertain | 원래 attempt·mapping을 confirmation/reconciliation 대상으로 유지 | 성공·명시적 미수락·자동 recovery 추정 |

| 관찰 결과 | Server acceptance 기본 판정 | Retry·후속 경계 |
| --- | --- | --- |
| 계약상 긍정적 Discord response와 필요한 message ID가 모두 정확히 mapping됨 | `accepted` | 재호출 금지 |
| 긍정 response지만 message ID 누락·형식 오류·mapping 불가 | `acceptance_uncertain` | 자동 retry 금지 |
| Timeout·network 오류·응답 미수신·유실 | `acceptance_uncertain` | 자동 retry 금지; WBS-07.G 대조 |
| 실제 계약이 message 미생성을 보장하는 명시적 거부 | `explicitly_not_accepted` 후보 | 승인된 retry/recovery 정책으로만 후속 처리 |
| 429와 검증된 rate-limit evidence | Cause는 rate limited, acceptance는 실제 계약 evidence로 별도 판정 | `Retry-After`·deadline·중복 위험을 함께 검토 |
| 5xx·불완전 error response | 기본적으로 external effect uncertain | 명시적 no-effect 근거 없이는 자동 retry 금지 |
| 외부 호출 전 render·gate 차단 | `unattempted` | 조건 회복 뒤 같은 prepared intent 재개 가능성 재대조 |
| Response code·body·message ID·관측 근거가 상충 | 원인·acceptance 미확정 | 편의상 최신/성공 evidence 우선 금지 |

[FACT] Error cause와 acceptance state는 서로 다른 축입니다. 429·5xx·auth/config·payload·permission·network·timeout 원인을 기록해도 message가 생성되지 않았다는 계약 근거가 없으면 `explicitly_not_accepted`로 추정하지 않습니다. 반대로 명시적 미수락 근거가 있어도 source selection result나 article 처리 결과를 실패로 변경하지 않습니다.

[INFERENCE] 새 delivery attempt 허용 여부는 accepted/uncertain/not-accepted 상태, selected interface의 retry 계약, `Retry-After`, current lease·gate·target timing, 동일 article의 중복 위험과 recovery 정책을 함께 판정해야 합니다. 정확한 즉시 retry 가능 오류·횟수·backoff는 WBS-07.G와 SPK-03 evidence 전에는 확정하지 않으며, acceptance-uncertain은 자동 retry 대상이 아닙니다.

| Late evidence | 허용 효과 | 금지 효과 |
| --- | --- | --- |
| Exact original attempt의 늦은 긍정 response+message ID | 원래 mapping에 `discord_2xx` acceptance evidence append | 새 delivery·selection 생성 |
| SPK-03이 exact original mapping을 검증한 direct positive message proof | 별도 `discord_message_reconciliation` source로 accepted 판정 가능 | 원래 2XX response·수락 시각·정시 수락 생성 |
| 정확히 연결된 article reaction·batch ✅·`받음` | Recipient-observed receipt로 confirmation/recovery 대상에서 제외 가능 | Server acceptance·정시 수락으로 변경 |
| 출처·attempt·mapping 불명 또는 상충 evidence | 불확실 상태·원인과 검증 owner 유지 | 임의 matching·기존 근거 삭제 |

[FACT] Recipient-observed evidence는 원래 server response와 source가 다릅니다. 유효한 receipt가 있으면 해당 item을 수신 확인 근거로 자동 recovery 대상에서 제외할 수 있지만 Discord server 오류·미수락 이력을 삭제하거나 `discord_2xx`와 정시 수락 시각을 만들지 않습니다. 동일 scope의 `못 받음`과 receipt가 상충하는 처리는 WBS-07.G가 담당합니다.

[FACT] 여러 physical message로 분할된 delivery에서는 mapping별 acceptance와 실제 item subset을 유지합니다. 필요한 모든 physical mapping이 accepted일 때야 논리 전달 단위를 완전 성공으로 projection할 수 있으며, 일부 accepted이면 해당 item은 성공 전달로 유지하고 나머지는 각각 explicitly-not-accepted·acceptance-uncertain·unattempted로 남깁니다. Aggregate `partially_accepted`는 하위 evidence를 요약할 뿐 원본 상태를 대체하지 않습니다.

```text
대조 시점의 전달 대상 item 수
  = accepted item
  + explicitly-not-accepted item
  + acceptance-uncertain item
  + unattempted item
```

[FACT] Physical attempt·retry·message 수는 논리 article 수와 합산하지 않습니다. 같은 item이 복수 mapping에 중복 연결되지 않는 WBS-07.B invariant가 선행하며, 한 message의 수락을 다른 mapping/item에 전파하지 않습니다.

[FACT] 정시 수락은 source scheduled batch의 사용자 메시지 필요 결과에 대해 필요한 physical mapping의 message ID와 `discord_2xx` evidence가 10:00:00 이상 10:01:00 미만 또는 22:00:00 이상 22:01:00 미만에 확인된 경우만 계산합니다. Processing-delayed full result, confirmed recovery, receipt confirmation과 recipient-observed evidence는 원래 정시 수락 분자·분모 또는 수락 시각을 만들지 않습니다.

[FACT] Failure notice·receipt confirmation의 Discord 2XX·거부·timeout·응답 유실은 해당 system message attempt와 acceptance만 변경합니다. 원래 AI partial/total failure, selection summary, article delivery, receipt/recovery 상태를 성공·실패·정상 0건으로 바꾸지 않습니다.

[INFERENCE] WBS-07.C 완료 조건은 모든 physical mapping이 durable prepared intent·invocation·safe evidence·대표 acceptance·item scope와 연결되고, 호출 전 gate·동시성·late evidence·partial acceptance·정시 측정·후속 owner가 정의되는 것입니다. Stale invocation, message ID 없는 성공, uncertain 자동 retry, 한 message의 전체 성공 확장, accepted item 재전송, recipient receipt의 2XX/정시 전환과 system-message source 결과 변경은 WBS-17·23~25에서 0건이어야 합니다.

[UNKNOWN] 실제 Discord 2XX·message ID·4xx/429/5xx/error body·rate-limit header 계약, 한 invocation과 mapping의 cardinality, no-effect를 보장하는 오류, retryable 조건·횟수·backoff, direct message proof·late response capability, multi-message 전체 성공 projection과 정확한 상태 enum은 SPK-03과 WBS-04.D·07.G 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 오류 mapping·retry 값·schema·Discord 호출·code를 승인한 것이 아닙니다.

#### WBS-07.D Gateway Event and Feedback Projection Review Contract

[FACT] WBS-07.D 실행 산출물은 Gateway event register, subject-mapping validation matrix, ordering/deduplication contract와 article/batch feedback projection contract입니다. 실제 Gateway session을 연결하거나 event를 수신하고 Discord 설정·schema·code를 만들지 않으며, append-only 원천 observation과 운영 조회용 mutable `feedback_state`를 분리합니다.

```text
Discord Gateway raw event
  → configuration·user·message·subject 검증
  → identity·ordering·gap·dedupe 판정
  → feedback_state current projection
  → 필요 시 WBS-07.E reconciliation request
```

| Gateway-event register field | 계획 목적 |
| --- | --- |
| External event identity | 동일 event 재전달의 current projection 중복 적용 방지 |
| Event kind | Reaction add/remove, batch review, slash/receipt interaction 등 원천 종류 구분 |
| Interface/configuration version | 당시 Gateway contract·Application·mapping 규칙 추적 |
| Guild/channel/message/user references | 허용 프로젝트·target·principal scope 검증 |
| Reaction/interaction value | 허용 reaction code·interaction kind와 원값 분리 |
| Subject mapping | Article message/item, batch representative set, missing case, receipt scope 또는 unmapped |
| Ordering evidence | Provider sequence/cursor·event/receive 시각 등 실제 비교 근거 |
| Application result | Applied·duplicate·older·unsupported·unmapped·reconciliation-needed 계획 분류 |
| Safe failure reason | 권한·mapping·순서·gap·저장 문제의 비민감 원인 |
| Reconciliation handoff | Exact tracked message·approved user·allowed reaction scope와 trigger |

[FACT] `application result`는 계획 분류이며 실제 enum이 아닙니다. Gateway 원천 observation은 기존 event를 수정·삭제하지 않는 append-only history로 보존합니다. 동일 external identity가 재전달되면 current projection에는 한 번만 적용하며, 중복 observation을 한 row로 수렴할지 별도 observation으로 연결할지는 WBS-04.D physical constraint에서 결정합니다.

| Validation axis | 유효 조건 | 실패 시 처리 |
| --- | --- | --- |
| Configuration | 수신 event가 승인 contract/configuration boundary와 일치 | Raw evidence와 불일치 원인 보존, projection 금지 |
| Guild/channel | 승인 project scope와 일치 | Unsupported/out-of-scope, business mutation 금지 |
| Message mapping | 저장된 article/batch/system mapping과 exact identifier 일치 | `unmapped`, 유효 feedback·receipt 추정 금지 |
| User | 승인된 project user이고 bot/system이 아님 | Raw event와 제외 사유 보존, 품질·review 적용 금지 |
| Reaction | Subject kind에 허용된 exact code | Unsupported reaction, 다른 feedback kind로 변환 금지 |
| Subject scope | Article item 또는 delivery-set 대표 mapping의 실제 범위와 일치 | 임의 article·batch 귀속 금지 |
| Ordering | 현재 applied observation과 안전하게 비교 가능 | `present/absent` 추정 금지, reconciliation handoff |

[FACT] 다른 사용자·bot, 잘못된 guild/channel/message, 허용되지 않은 reaction 또는 mapping 불명 event는 유효 article feedback·batch review·recipient receipt로 적용하지 않습니다. Source evidence와 비적용 이유는 보존하되 비슷한 title·link·시각으로 다른 message/item에 연결하지 않습니다.

| Event condition | Append-only history | Current projection | 후속 처리 |
| --- | --- | --- | --- |
| 유효한 새 add/remove | 원천 observation 보존 | 안전한 순서일 때 적용 | 없음 |
| 동일 external event 재전달 | Identity와 중복 관측 근거 보존 | 두 번 적용 금지 | 기존 application result 재사용 |
| 현재보다 과거임이 확인됨 | 보존 | 현재 state를 되돌리지 않음 | History only |
| 순서가 불명확함 | 보존 | `present/absent` 추정 금지 | WBS-07.E request |
| Event gap·resume 실패 가능성 | 근거 보존 | 영향 subject를 `stale/unknown`으로 유지 | WBS-07.E request |
| Mapping·사용자·reaction 검증 실패 | 보존 또는 안전한 거부 근거 연결 | 유효 feedback 생성 금지 | `unmapped`/unsupported reason |
| Gateway·REST observation 모두 없음 | 없음 | State row 생성 금지 | 조회상 `not_observed` |

[FACT] `feedback_state`의 계획상 현재 상태는 `present`, `absent`, `stale`, `unknown`, `unmapped`이며 row 부재는 조회상 `not_observed`입니다. `absent`는 WBS-07.E REST snapshot 등 현재 reaction 부재를 확인한 evidence가 있을 때만 사용하고, event 미수신·listener 중단·권한 부족·mapping 실패를 absence로 바꾸지 않습니다. 실제 state value와 transition은 WBS-04.D closure 전 확정하지 않습니다.

[FACT] Article negative feedback은 😕 `별로였음`, 🚫 `불필요함`, 📣 `홍보성 의심`을 독립된 reaction action으로 유지합니다. 같은 article에 복수 kind가 동시에 present일 수 있고, 같은 user·article·kind의 duplicate event는 하나의 current 상태만 만듭니다. Remove는 해당 current action을 철회하지만 add/remove 원천 history를 삭제하지 않습니다.

[FACT] 기사 단위 부정 여부는 하나 이상의 유효 negative reaction이 present이면 하나의 article 부정으로 읽고, 원인별 metric은 각 reaction kind를 별도로 읽습니다. 같은 article의 복수 reaction을 암묵적 수용 분자·분모에서 여러 article로 중복 계산하지 않으며 실제 metric 산출은 WBS-08·22가 담당합니다.

[FACT] Batch ✅의 subject는 하나의 article-bearing `delivery_set`과 그 batch 대표 physical mapping입니다. Current+confirmed-recovery 정규 set이면 실제 포함된 두 segment의 item scope를, processing-delayed 전용 set이면 그 set의 item만 한 번 reference합니다. 같은 item의 여러 physical mapping을 여러 검토 대상으로 복제하거나 서로 다른 source batch summary를 하나로 합치지 않습니다.

[FACT] 승인 사용자의 유효한 ✅ add는 현재 batch review를 present로 만들고 해당 delivery-set item scope의 append-only recipient-observed receipt evidence가 될 수 있습니다. ✅ remove는 현재 review projection을 취소하지만 이미 저장한 Gateway event·recipient receipt·Discord server acceptance를 삭제하지 않습니다. 이 receipt는 원래 `discord_2xx` response·수락 시각·정시 수락, 각 article의 명시적 유용함이나 원문 열람을 뜻하지 않습니다.

| Observation | 허용 의미 | 금지 해석 |
| --- | --- | --- |
| Article 😕·🚫·📣 | 현재 negative feedback | Server 2XX·원문 열람 |
| Batch ✅ | 현재 검토 완료와 delivery-set 범위 user-observed receipt | 기사별 명시적 유용함·source batch summary 병합 |
| Reaction remove | 현재 feedback/review 철회 | 과거 event·receipt·server acceptance 삭제 |
| `not_observed` | 관측 근거 없음 | Reaction absent·검토 미완료·사용자 무응답 |
| `absent` | 현재 부재를 확인한 observation | 과거 reaction이 존재하지 않았음 |
| Link click | 품질·수락 evidence가 아님 | 검토 완료·유용함·receipt |
| Failure-notice 일반 reaction | Unsupported system-message event | Article feedback·batch review |
| Receipt-confirmation 일반 reaction | Unsupported system-message event | `받음`/`못 받음` interaction |

[FACT] Missing-article command·`추천해야 했다`와 `받음`/`못 받음`은 Gateway 원천 event를 가질 수 있지만 WBS-07.F의 별도 business mapping과 validation을 통과해야 합니다. 이를 article negative feedback·batch review로 바꾸거나 일반 reaction을 receipt interaction으로 추정하지 않습니다.

[FACT] Mutable `feedback_state`는 사용자·운영 현재 조회 projection입니다. Immutable evaluation은 WBS-08에서 지정 cutoff 이하의 `discord_gateway_event`·`rest_state_snapshot`·reconciliation reference로 같은 predicate를 재구성하며, cutoff 뒤 remove·late event·late REST result가 기존 snapshot을 소급 변경하지 않습니다.

[FACT] Discord user·message·channel identifier와 feedback은 무료 AI input에 포함하지 않습니다. Credential·webhook URL·interaction secret은 raw event·projection·일반 log/metric/trace·사용자 출력에 저장하지 않으며, identifier의 최소 보존·접근·redaction과 자동 Retention을 도입하지 않는 MVP-A 경계는 WBS-04.D·08·20이 닫습니다.

[INFERENCE] WBS-07.D 완료 조건은 모든 적용 event가 exact identity·configuration·user·message·subject·reaction·ordering evidence에 연결되고, duplicate/older/gap/unmapped가 fail-closed로 처리되며, article reaction·batch review·recipient receipt·system message·interaction 의미와 current/evaluation owner가 분리되는 것입니다. Duplicate projection, out-of-order state rollback, not-observed→absent, 다른 user/bot 적용, scope 밖 ✅, remove에 의한 history/receipt 삭제와 mutable projection 기반 immutable evaluation은 WBS-18·23·25에서 0건이어야 합니다.

[UNKNOWN] 실제 Gateway event identity·sequence/cursor·timestamp 신뢰도, identify/resume·session invalidation, event duplicate/order/gap 탐지, user/bot·message mapping contract, reaction code 표현, raw duplicate physical 저장, feedback state enum·transition, identifier 보존·접근·redaction은 SPK-03과 WBS-04.D·07.E~F 승인 전 확정되지 않습니다. 이 review contract의 승인은 실제 Gateway contract·schema·event handler·code를 승인한 것이 아닙니다.

#### WBS-07.E REST Feedback Reconciliation Review Contract

[FACT] REST feedback reconciliation은 Gateway 원천 변경 이력을 대체하지 않고, 허용된 불신·복구·평가 경계에서 추적 대상의 현재 reaction 상태를 제한적으로 관측하는 보조 절차입니다.

```text
허용 trigger와 event 불신 evidence
  → reconciliation_request 내부 기록
  → exact bounded scope와 동일 logical work 판정
  → claim·lease/fence·DB trust·contract·outbound gate
  → Discord REST invocation attempt
  → pagination 완결성·observation evidence 판정
  → append-only rest_state_snapshot
  → newer observation 보호와 feedback_state current projection
  → evaluation 또는 운영 조회에 상태·불확실성 제공
```

| 허용 trigger | Request 생성 조건 | Request를 만들지 않는 경우 |
| --- | --- | --- |
| 새 Gateway 연결의 resume 실패 | Resume 실패 또는 continuity를 입증할 수 없는 직접 evidence가 있고 영향 scope를 식별할 수 있음 | 정상 resume으로 event 연속성을 신뢰할 수 있는 단순 재연결 |
| DB recovery·restore | 복구·restore 사실과 대조 대상 scope를 연결할 수 있음 | 일반 process restart 또는 DB 상태를 신뢰할 수 있는 재기동 |
| Gateway event 저장 실패 | 수신 event의 영속화 실패·gap·안전한 ordering 불가가 evidence로 확인되고 승인된 trigger 범주에 귀속됨 | 근거 없는 일반적 event 불신, listener health 정상인 상태의 예방성 polling |
| Feedback 지표 계산 직전 | 하나의 승인된 evaluation request가 exact batch·기간·cutoff scope를 요구함 | 정기 전체 polling, evaluation과 무관한 broad scan |

[FACT] Event gap·순서 불명확 같은 불신은 위 네 trigger 중 하나에 연결되는 직접 evidence가 있을 때만 request를 만듭니다. 포괄적인 “event가 불안할 수 있음”은 새 trigger가 아니며, 정상 resume 자체도 request 생성 사유가 아닙니다. 실제 gap·resume·저장 실패를 네 trigger에 귀속하는 판정 필드는 WBS-04.D와 SPK-03 전에 확정하지 않습니다.

[FACT] `reconciliation_request` 생성은 내부 DB 기록이며 Discord REST 호출, Discord domain attempt 또는 reaction 부재 판정을 뜻하지 않습니다. Request는 trigger evidence, configuration/contract boundary, tracked system message, approved user, allowed reaction, 대상 subject, evaluation scope·cutoff가 있으면 그 reference를 보존하는 계획 단위입니다.

[INFERENCE] 동일 configuration boundary와 exact message·user·reaction·subject·evaluation scope를 공유하는 중복·겹친 trigger는 하나의 logical work로 수렴시켜야 합니다. Exact scope가 다른 work를 임의로 합치거나 일부 결과를 다른 scope에 재사용하지 않습니다. 부분 중첩 범위의 merge/split 방식과 physical work key는 WBS-04.D·05 closure 전 확정하지 않습니다.

| Invocation 전제 | Gate가 열림 | Gate가 닫힘·불명확함 |
| --- | --- | --- |
| Work ownership | 유효 claim·현재 lease/fence가 있음 | HTTP attempt를 만들지 않고 waiting/blocked reason 유지 |
| DB trust | Ledger와 mapping을 신뢰할 수 있음 | Restore·integrity 검증과 사용자 outbound 재개 승인 전 호출 금지 |
| Discord contract | 적용 configuration, endpoint capability, permission, credential와 scope가 검증됨 | Contract 재검증 owner에게 넘기고 호출 금지 |
| Outbound·cost safety | Outbound gate와 월 0원 evidence coverage가 유효함 | 자동 유료 경로 전환·우회 호출 금지 |
| Exact scope | Tracked message·approved user·allowed reaction·subject 범위가 bounded함 | Broad server/channel polling 금지 |

[FACT] Restore는 request trigger가 될 수 있지만 REST 실행 허가는 아닙니다. DB 무결성, mapping 및 outbound gate가 신뢰 가능하고 사용자가 요구된 재개 승인을 한 뒤에만 별도 claim을 가진 REST work가 실행될 수 있습니다. Gate가 닫혀 있으면 request는 대기 사유를 가진 내부 work로 남고 feedback을 `absent`로 바꾸지 않습니다.

| Snapshot evidence | 필수 계획 기준 | 불완전할 때의 처리 |
| --- | --- | --- |
| Observation identity | Request/work attempt, configuration, message·user·reaction·subject scope와 관측 시각 reference | Mapping 불가이면 `unmapped` 또는 `unknown` |
| Pagination | Page·cursor 진행, 예상 종료와 완결성 판정 evidence | 일부 page만으로 `absent` 판정 금지 |
| Response result | Redacted status·rate-limit·error·response receipt와 safe digest/reference | Timeout·response loss는 성공 또는 부재로 추정 금지 |
| Scope coverage | 요청한 exact scope와 실제 응답 coverage 대조 | 누락·초과·불명확 범위는 `stale/unknown` |
| Ordering | 적용된 최신 Gateway/REST observation과 안전하게 비교 가능한 근거 | 순서 불명확 시 current `present/absent`를 덮어쓰지 않음 |

[FACT] `rest_state_snapshot`은 관측 시점의 현재 상태 evidence를 append-only로 보존하고 기존 `discord_gateway_event`를 삭제·수정하지 않습니다. Pagination이 완결되고 exact scope coverage가 확인된 경우에만 관측된 reaction은 `present`, 관측되지 않은 reaction은 `absent`의 후보가 됩니다.

[FACT] Pagination incomplete, permission 부족, mapping 실패, rate limit, timeout, 오류 또는 response loss가 있으면 reaction 미관측을 `absent`로 해석하지 않습니다. 안전한 evidence에 따라 `stale`, `unknown` 또는 `unmapped`를 유지하고 실패 원인과 영향 scope를 기록합니다.

| Observation 관계 | Current projection 처리 |
| --- | --- |
| 안전하게 더 새로운 완결 관측 | Subject의 현재 state에 적용 가능 |
| 현재보다 과거임이 확인된 snapshot | History로 보존하되 current state rollback 금지 |
| Gateway와 REST 순서를 비교할 수 없음 | 기존 확정 state를 추정으로 교체하지 않고 `stale/unknown` 근거 유지 |
| Gateway·REST 관측이 모두 없음 | State row를 만들지 않고 조회상 `not_observed` |
| 완결 REST가 현재 reaction 부재를 확인 | 해당 exact subject에만 `absent` 적용 가능 |

[FACT] REST auth·rate-limit·timeout·오류·response loss는 invocation attempt와 안전한 evidence에 기록합니다. SPK-03에서 실제 Discord 계약과 안전성이 입증되고 WBS-05의 재시도 권한·lease/fence를 통과하기 전에는 자동 retry, 정기 polling 또는 scope 확대를 계획하지 않습니다.

[FACT] Feedback reconciliation은 `acceptance_evidence`, `recovery_event`, `conflicting_receipt`, 기존 delivery attempt 결과 또는 원래 Discord 수락 시각을 생성·삭제·수정하지 않습니다. Reaction 부재는 feedback current projection만 바꿀 수 있고 recipient receipt·정시 수락·recovery 사실을 취소하지 않습니다.

[FACT] Sandbox가 original delivery attempt·exact message mapping·payload/configuration version의 직접 관계를 검증한 경우에도 delivery acceptance 확인은 feedback reconciliation과 분리된 logical work입니다. 일반 REST snapshot, 제목·내용 유사성 또는 시간 추정으로 `discord_message_reconciliation` evidence를 만들지 않습니다.

[FACT] Evaluation 직전 trigger는 해당 evaluation의 bounded scope에 대한 request만 만들고, 성공한 reconciliation 또는 알려진 실패·불확실성이 고정된 뒤 WBS-08의 immutable input cutoff에 연결합니다. 평가에서는 mutable `feedback_state`를 최종 evidence로 사용하지 않으며, unknown·not-observed를 feedback 0건 또는 `absent`로 바꾸지 않습니다.

[FACT] Discord identifier와 feedback REST 결과는 무료 AI input으로 보내지 않습니다. Credential·authorization header·interaction secret·원문 response의 민감값은 snapshot·일반 log/metric/trace·사용자 출력에 저장하지 않으며, 실제 redaction·최소 보존·접근 기준은 WBS-04.D·07.A·20이 닫습니다.

[INFERENCE] WBS-07.E 완료 조건은 네 trigger 외 request 0건, request-only 단계의 무승인 HTTP attempt 0건, exact scope 밖 조회 0건, incomplete pagination 기반 `absent` 0건, older snapshot rollback 0건, feedback reconciliation의 acceptance·receipt·recovery 변경 0건을 WBS-19·23~25 fixture로 판정할 수 있는 것입니다.

[UNKNOWN] 실제 REST endpoint·request/response shape, required permission, pagination token·종료 조건, rate-limit header, timeout·오류 taxonomy, 안전한 retry/backoff, Gateway/REST ordering key 및 부분 중첩 scope merge/split은 SPK-03과 WBS-04.D·05 closure 전 확정되지 않습니다. 이 review contract의 승인은 실제 REST 호출·schema·retry·code를 승인한 것이 아닙니다.

#### WBS-07.F Interaction, Missing Article, and Receipt Review Contract

[FACT] WBS-07.F는 Discord에서 들어온 구조화 interaction을 검증하고, 누락 기사 조회·`추천해야 했다`·delivery receipt의 서로 다른 business action을 원래 대상에 연결해 기록하는 경계입니다. Gateway listener 또는 interaction adapter가 receipt를 수신했다는 이유만으로 Discord 재전송을 실행하지 않습니다.

```text
Discord interaction/event
  → source identity·진위·configuration/interface mapping 검증
  → 승인 사용자·operation·target scope 검증
  → interaction_request idempotency 판정
  ├─ missing article: link validation → exact stored-history lookup → grounded reply
  ├─ recommendation: eligible case/reply/article → feedback current projection
  └─ receipt: exact original delivery scope → typed recovery event
       → WBS-07.G durable confirmation/recovery work
```

| Operation | Required target | 저장·출력 책임 | 금지된 의미 확장 |
| --- | --- | --- | --- |
| Missing article command | 원 interaction, 승인 사용자, 제출 원값 | Validation, exact history lookup, case outcome와 근거 회신 | 중요 기사·실제 RSS 원천 누락·recall 누락 자동 확정 |
| `추천해야 했다` | Eligible missing case·article·회신·승인 사용자 | Raw event와 `missing_article_recommendation` current state | 별도 feedback entity·제출 자체의 중요도 판정 |
| `받음` | Exact original delivery scope·승인 recipient | Recipient-observed receipt와 typed recovery event | 원래 Discord 2XX·정시 수락 시각 생성 |
| `못 받음` | Exact original delivery scope·승인 recipient | 사용자 미수신 typed event와 WBS-07.G handoff | Listener의 직접 resend·반복 confirmation |
| 추가 복구 선택 | Exact recovery case·offer·승인 recipient | Typed selection event와 WBS-07.G handoff | 다른 batch 혼합·무승인 자동 복구 |

[FACT] 모든 operation은 원천 interaction/event identity, 수신 시각, 적용 configuration·interface mapping/version, operation/action, 승인 사용자, 확인 가능한 target과 validation result에 연결합니다. 일반 message·link click·지원하지 않는 reaction·다른 사용자 또는 bot 입력을 구조화 operation으로 추정하지 않습니다.

[INFERENCE] 같은 external interaction identity의 재수신은 동일 logical interaction request에 한 번만 적용해야 하며, 성공·거부·불명확 결과도 idempotent하게 재조회할 수 있어야 합니다. 서로 다른 interaction으로 같은 link가 반복 제출되면 각 요청 이력은 보존하되 article identity·recall 판단을 요청 수만큼 중복 생성하지 않습니다. 실제 key·constraint·동시성 구현은 WBS-04.D·05에서 닫습니다.

| Missing link validation 단계 | 판정 기준 | 허용되는 다음 단계 |
| --- | --- | --- |
| 구조 검증 | 비어 있지 않은 입력 하나 | GeekNews topic link 문법 검증 |
| Source 경계 검증 | 승인된 GeekNews topic link 형식 | 제출 원값 그대로 exact lookup |
| Invalid·unsupported | 빈 값, 복수 link, 외부 URL, 형식 오류 또는 검증 불가 | `invalid_reference`와 거부·지원 불가 근거 |
| Exact identity lookup | 저장된 Raw RSS `link` 원값과 정확히 일치 | Article·observation·처리·선정·delivery·recovery 이력 조회 |

[FACT] Link 입력은 URL 정규화·redirect 확인·다른 URL 추출·Atom `id`·title·유사 URL·검색 결과로 대체하지 않습니다. GeekNews 상세 page·외부 원문에 접근하지 않고, RSS 재수집이나 과거 observation 재검증도 시작하지 않습니다. 공백·fragment·encoding·query parameter의 실제 허용 문법은 SPK-01·03과 후속 interface mapping 승인 전 확정하지 않습니다.

| MVP-A case outcome | 의미 | 회신·후속 경계 |
| --- | --- | --- |
| `invalid_reference` | 입력이 승인된 단일 exact link lookup 대상이 아님 | 누락 기록·recall에 포함하지 않고 오류·지원 불가 표시 |
| `found_in_collection` | Exact link의 저장 article과 근거 이력이 있음 | 당시 version의 실제 처리·선정·delivery·recovery 사실만 회신 |
| `not_collected` | 유효 exact link가 article 기록에 없음 | 수집 기록상 누락으로 기록하되 RSS 원천 누락·중요 기사·recall 누락으로 확정 금지 |

[FACT] `retention_purged`는 MVP-A output이 아닙니다. MVP-B retention gate 뒤 exact link의 identity tombstone이 남은 미래 조건에서만 사용할 수 있는 reserved 결과이며, MVP-A의 기록 부재를 이 값으로 추정하지 않습니다.

[FACT] `found_in_collection` 회신은 보존된 Raw RSS observation, 입력 검증, AI attempt·analysis, selection, delivery attempt·acceptance 및 recovery evidence를 당시 version과 함께 읽습니다. 현재 AI·현재 prompt·현재 선정 정책으로 과거 판단을 다시 계산하거나 외부 자료로 과거 이유를 보완하지 않습니다.

| 저장 이력 상태 | 회신 경계 | `추천해야 했다` 제공 |
| --- | --- | --- |
| 이미 수락 또는 유효 receipt가 확인된 전달 | 전달·수신 근거와 현재 확인 상태 | 금지 |
| 실제 홍보성 의심 제외 | 저장된 당시 제외 결과·version·근거 범주 | 허용 |
| 최대 10개 제한 미선정 | 저장된 당시 미선정·순위/정책 근거 | 허용 |
| 입력 오류·AI 미처리·quota·전체 선정 불가 | 실제 미처리·실패 원인과 영향 | 금지 |
| Discord 미수락·수락 불명확·복구 상태 | 실제 delivery/recovery 상태 | 금지 |
| `not_collected`·batch RSS 실패 | 수집 기록상 누락 또는 별도 pipeline 실패 | 금지 |
| 기록 부족·상충·분류 불가 | `원인 미확정`과 부족·상충 reference | 금지 |

[FACT] `추천해야 했다`는 eligible 회신 message/interface mapping과 원래 `missing_article_case`, 수집 article, 승인 사용자에 정확히 연결합니다. Reaction add·remove·duplicate history는 WBS-07.D의 raw Gateway event에 남고, 현재 projection은 `feedback_state.feedback_kind = missing_article_recommendation`으로 관리합니다. Reaction 부재는 동의·만족·비중요 또는 시스템 판단 수용이 아닙니다.

[FACT] 동일 logical article의 반복 case와 중복 reaction은 모든 원천 이력을 보존하되 평가에서 하나의 logical recommendation subject로 읽습니다. 현재 유효한 recommendation이 있는 수집 article만 WBS-08의 후보 기반 중요 기사 recall 분모 후보가 되며, `not_collected`는 별도 수집 기록상 누락 지표로 유지합니다.

| Receipt validation | 유효 조건 | 실패·불명확 처리 |
| --- | --- | --- |
| Source | 원 interaction/event와 적용 mapping을 확인 | 일반 reaction·message parsing으로 receipt 추정 금지 |
| Recipient | 원래 target의 승인 recipient와 일치 | 다른 user·bot은 거부 근거만 보존 |
| Original scope | Source selection result, delivery attempt, message mapping, segment와 실제 item scope를 연결 | 모호·부분 연결은 전달 상태 변경·resend 금지 |
| Recovery case | 같은 selection result·delivery target·recipient의 logical case를 확인 | 중복 case·event 생성 금지 |
| Action | Exact `받음`, `못 받음` 또는 승인된 추가 복구 선택 | 지원하지 않는 action은 no-op/unsupported evidence |

[FACT] 유효한 `받음`은 recipient-observed receipt와 사용자 수신 확인의 typed event를 추가하지만 원래 `discord_2xx`, 원래 server acceptance 시각 또는 정시 전달 근거를 만들지 않습니다. 유효한 `못 받음`은 사용자 미수신의 typed event와 WBS-07.G의 durable work handoff를 만들 수 있지만 listener가 직접 resend하지 않습니다.

[FACT] 같은 actual item scope의 유효한 article reaction·batch ✅ receipt와 `못 받음`이 함께 있으면 `conflicting_receipt` safe output으로 둘 다 보존합니다. 어느 evidence도 삭제하거나 자동 우선하지 않고, 추가 resend·기존 resend 취소·암묵적 수용을 만들지 않습니다. 서로 다른 original/recovery delivery scope의 event는 단지 article이 같다는 이유로 상충 처리하지 않습니다.

[FACT] Interaction 검증 실패, 대상 mapping 불명, DB trust 불명 또는 commit 실패에서는 business state와 outbound handoff를 만들지 않습니다. 외부 acknowledgement가 이미 발생했는지 불명확한 경우에도 저장 성공을 추정하지 않고 WBS-05의 external-effect uncertainty와 WBS-07.A 실제 interaction 계약에 연결합니다.

[FACT] Discord user·message·interaction identifier와 feedback은 무료 AI input으로 보내지 않습니다. Interaction verification secret·token·authorization·webhook URL은 DB·문서·일반 log/metric/trace·사용자 회신에 저장하거나 노출하지 않으며, 정확한 signature 검증·redaction·응답 공개 범위는 SPK-03과 WBS-07.A·20에서 닫습니다.

[INFERENCE] WBS-07.F 완료 조건은 일반 message 추정, invalid→not_collected 오분류, exact link 외 lookup·외부 접근·RSS 재수집, 현재 AI 재판단, ineligible recommendation 제공, interaction/recommendation/recall 중복, receipt 기반 원래 2XX 생성, listener 직접 resend 및 same-scope conflict 자동 우선이 WBS-18~19·23~25 fixture에서 각각 0건인 것입니다.

[UNKNOWN] 실제 command·subcommand·parameter·언어, Discord interaction signature·acknowledgement/follow-up timing, link 공백·fragment·encoding·parameter 문법, 회신 공개 범위·문구·우선순위, 반복 제출 UI, recommendation·receipt·additional recovery UI mapping, physical key·constraint·state는 SPK-03과 WBS-04.D·05·07.G closure 전 확정되지 않습니다. 이 review contract의 승인은 실제 interaction endpoint·payload·schema·handler·resend code를 승인한 것이 아닙니다.

#### WBS-07.G Confirmation and Recovery Reconciliation Review Contract

[FACT] WBS-07.G의 reconciliation은 수락 불명확 original delivery에 대한 acceptance·recipient receipt·late evidence와 recovery 진행 대조입니다. WBS-07.E의 REST feedback current-state reconciliation과 logical work·evidence·state owner를 공유하지 않으며, feedback REST 결과로 recovery를 시작하거나 완료하지 않습니다.

```text
acceptance_uncertain original delivery
  → recovery_case와 confirmation_due_at
  → due work claim
  → 외부 invocation 직전 acceptance·receipt 재대조
  ├─ 신뢰 가능한 근거 있음: confirmation 미발송, case evidence 갱신
  └─ 근거 없음: original scheduled batch당 confirmation intent 1회
       ├─ `받음`: user-received evidence, resend 없음
       ├─ `못 받음`: immediate-resend authorization 1회
       └─ 다음 성공 정규 batch까지 무응답: offer intent 1회
```

[FACT] `recovery_case`의 logical uniqueness 경계는 하나의 source `selection_result`, 원래 Discord delivery target reference와 승인 recipient reference의 조합입니다. Physical attempt·message·article마다 case를 중복 생성하지 않으며, 한 delivery set에 서로 다른 source selection result가 있으면 source별 case를 분리합니다. 실제 key·constraint는 WBS-04.D에서 확정합니다.

| Recovery evidence/domain | Canonical owner | 다른 의미로 변환 금지 |
| --- | --- | --- |
| Discord server acceptance·rejection·uncertainty | WBS-07.C delivery attempt/evidence | Recipient receipt나 feedback으로 server 2XX 생성 금지 |
| Gateway article/batch recipient observation | WBS-07.D acceptance evidence | Reaction remove로 과거 receipt 삭제 금지 |
| REST feedback current state | WBS-07.E snapshot/projection | Acceptance·recovery case 변경 금지 |
| `받음`/`못 받음` interaction | WBS-07.F typed event | Listener 직접 resend 금지 |
| Confirmation·resend·backlog·offer execution | WBS-07.G durable work | Selection result·article·AI 결과 재생성 금지 |

[FACT] 같은 original delivery scope에서 수락 불명확한 physical attempt가 여러 개이면 `confirmation_due_at`은 마지막 `invocation_started_at + 1시간`입니다. Due 이하 source observation 시각을 가진 Discord 2XX, SPK-03에서 검증된 exact direct message proof, recipient-observed receipt 또는 명시적 user-received evidence는 confirmation을 막는 후보입니다. 실제 timestamp 표현·clock 신뢰·CronJob 기동 오차는 WBS-03.D·08과 SPK-03~04 전에 확정하지 않습니다.

| Confirmation 단계 | 필수 판정 | 금지 동작 |
| --- | --- | --- |
| Due 등록 | Original scope, 마지막 invocation, 계산 근거 | Process 시작·응답 timeout 시각으로 임의 대체 |
| Work claim | 현재 lease/fence와 DB trust | Stale worker의 상태 변경·외부 호출 |
| Pre-invocation recheck | 최신 2XX·direct proof·receipt·user-received 및 conflict | Claim 시 snapshot만 신뢰하고 호출 진행 |
| Intent commit | Original batch의 기존 confirmation intent/event 없음 | Batch·message별 중복 confirmation 생성 |
| Invocation | WBS-07.C의 별도 confirmation delivery attempt | 발송 사실로 original 수락·수신 추정 |
| Evidence commit | Confirmation message 자체의 response·message ID | Confirmation 2XX를 original 2XX로 복사 |

[FACT] Due work를 claim했더라도 외부 confirmation invocation 직전에 저장된 수락·receipt 근거를 다시 대조합니다. 근거가 확인되면 confirmation을 보내지 않습니다. Invocation 시작 뒤 late evidence가 도착하면 원래 case에 보존하지만 이미 시작한 호출을 취소·재호출하거나 article resend를 만들지 않습니다.

[FACT] Confirmation은 원래 예정 batch당 한 번만 intent를 가질 수 있고 confirmation message 자체는 별도 delivery attempt·mapping·acceptance evidence를 가집니다. Confirmation message의 2XX·message ID는 그 확인 message의 server acceptance만 의미하며 원래 delivery의 수락·recipient receipt·정시 수락을 만들지 않습니다.

| Receipt 결과 | Recovery transition 경계 | 금지 동작 |
| --- | --- | --- |
| Exact `받음` | `user_received`와 별도 출처 acceptance evidence, no-resend | Original 2XX·정시 시각 생성 |
| Exact `못 받음` | `user_not_received` 후 idempotent `immediate_resend_authorized` 1회 | Original server 상태를 명시적 미수락으로 변경 |
| Mapping·user 불명 | 거부/불명확 evidence만 보존 | Resend·case 완료 |
| Same-scope conflict | `conflicting_receipt`, 자동 transition 중단 | 어느 evidence의 자동 우선·삭제 |

[FACT] `못 받음`의 즉시 재전송 권한은 원래 mapping, 승인 사용자와 explicit missing-receipt exception을 묶은 logical dedupe 경계에 한 번만 생성합니다. 실제 재전송은 WBS-05의 work claim과 WBS-07.C의 invocation gate를 통과하며 저장된 original `selection_result`·`batch_item`만 재사용합니다. RSS 수집·AI 분석·selection·최신성 판단을 다시 실행하지 않습니다.

| Immediate-resend 결과 | 다음 상태 | 반복 제한 |
| --- | --- | --- |
| Discord 2XX 또는 exact recipient receipt | 해당 scope recovery 완료 후보, backlog 생성 안 함 | 같은 exception resend 재실행 금지 |
| 명시적 Discord 미수락 | 실제 미수락 item subset만 confirmed non-acceptance backlog 후보 | Original 전체 batch 자동 편입 금지 |
| 수락 불명확 | 불명확 evidence와 미해결 case 유지 | 같은 batch confirmation·자동 resend·자동 backlog 편입 반복 금지 |
| Partial physical result | 수락·receipt·명시적 미수락·불명확 item scope 분리 | 성공 item 재전송 금지 |

[FACT] 확인 요청이 다음 성공 정규 batch까지 무응답이면 `confirmation_no_response`를 기록합니다. Recovery offer는 failure notice·receipt confirmation·processing-delayed full result가 아닌 해당 scheduled regular delivery set의 offer 표시 physical mapping에 원래 case당 한 번만 intent로 연결합니다.

[FACT] Offer가 실제 표시됐다는 근거는 그 physical mapping의 Discord 2XX와 message ID입니다. Offer invocation이 수락 불명확이면 intent·attempt·evidence를 보존하고 다음 batch에 자동 재첨부·재발송하지 않습니다. 승인 recipient의 exact `recovery_selected`가 있을 때만 저장된 original result의 resend work를 만듭니다. Offer·selection UI와 “다음 성공 정규 batch”의 실제 판정 조건은 SPK-03 및 WBS-03.D·08 전에 확정하지 않습니다.

```text
confirmed non-acceptance candidate
  = item별 explicit server non-acceptance
  + 같은 item scope의 valid recipient-observed receipt 없음
  + acceptance/recovery conflict 없음
```

[FACT] `못 받음`만으로 original item을 confirmed non-acceptance backlog에 넣지 않습니다. Discord 명시적 미수락 evidence가 있어도 같은 item scope의 유효한 recipient-observed receipt가 있으면 server 오류는 그대로 보존하되 자동 recovery 후보에서는 제외합니다. 이는 server 오류를 성공이나 2XX로 바꾸는 것이 아닙니다.

| Backlog release | 허용 범위 | 금지 범위 |
| --- | --- | --- |
| 다음 성공 정규 발송 | 가장 오래된 original batch의 실제 미수락 item 최대 10개 | 서로 다른 original batch 혼합 |
| Current와 함께 전달 | Current 최대 10개 + recovery 최대 10개, 별도 segment·summary | 수량·summary 합산, 총 20개 초과 |
| Recovery-only 정규 기회 | Current 신규 0건이어도 승인된 recovery segment 가능 | Current source를 recovery source로 변경 |
| 남은 backlog | 대기 수·oldest original batch 보존 | 조용한 삭제·성공·정상 0건 처리 |
| Additional recovery | 승인 selection마다 같은 oldest batch의 남은 item 최대 10개 | 무응답 자동 전송·다른 batch 혼합 |

[FACT] Confirmed non-acceptance backlog와 처리 지연 full result는 별도 logical 구간·delivery set입니다. Recovery item은 original selection order·수량 summary와 source reference를 재사용하고, 상한 미선정 article·이미 수락된 item·수락 불명확 item을 편입하지 않습니다.

[FACT] 같은 delivery scope의 `받음`과 `못 받음`, 또는 recipient receipt가 되는 ✅와 `못 받음`의 순서·최신성을 안전하게 판단할 수 없으면 `conflicting_receipt`를 보존합니다. 상충 item은 새 resend·기존 resend 취소·batch review·암묵적 수용의 근거로 사용하지 않고, 이미 저장된 evidence·attempt도 삭제하지 않습니다. 다른 scope의 original delivery와 recovery delivery는 article이 같아도 상충으로 합치지 않습니다.

| Lost-handoff 경계 | 복구 기준 | 금지 결과 |
| --- | --- | --- |
| Receipt event commit 전 중단 | 같은 interaction identity replay | Event 없이 resend work 생성 |
| Receipt event commit 후 work 생성 전 중단 | Durable state에서 handoff work 재발견 | 두 authorization·두 work 생성 |
| Delivery prepared 후 invocation 전 중단 | 현재 lease/fence·gate로 claim 재판정 | Prepared만으로 발송 성공 추정 |
| Invocation 시작 후 response 전 중단 | `acceptance_uncertain`, 자동 재호출 금지 | Lease 만료만으로 중복 resend |
| External evidence 뒤 DB commit 전 중단 | Late evidence/acceptance-resolution owner 연결 | 근거 없는 성공·미수락 확정 |
| Segment 일부 수락 뒤 중단 | Physical mapping/item별 결과 유지 | 전체 성공·전체 recovery 추정 |

[INFERENCE] Recovery case 결과 catalog는 최소한 user received, immediate resend accepted, explicit non-acceptance backlog, resend uncertainty, confirmation no-response/offer pending, conflict 및 completed/non-terminal 사유를 구분해야 합니다. 실제 enum이나 mutable aggregate field는 WBS-04.D에서 정하되 append-only event와 source delivery evidence를 복사하거나 덮어쓰지 않습니다.

[FACT] Discord credential·interaction secret·webhook URL은 recovery event·log·metric·trace·사용자 출력에 포함하지 않습니다. Recipient·message identifier와 receipt evidence는 무료 AI input으로 보내지 않으며, restore·DB trust·cost/outbound gate가 닫힌 동안 confirmation·resend·recovery delivery를 실행하지 않습니다.

[INFERENCE] WBS-07.G 완료 조건은 early/duplicate confirmation, pre-invocation recheck 누락, confirmation 2XX의 original acceptance 전환, duplicate immediate resend, uncertain resend loop, offer 자동 재첨부, non-FIFO·cross-batch recovery, 10/10/20 위반, processing-delayed 혼합, conflict 자동 우선, lost-handoff 중복 외부 호출이 WBS-19·23~25 fixture에서 각각 0건인 것입니다.

[UNKNOWN] 실제 CronJob 주기·기동 오차, clock·timestamp 표현, “다음 성공 정규 batch” 판정, confirmation·offer·additional-recovery UI, backlog 장기 운영 상한, conflict 수동 해소, physical uniqueness·item-subset query, Discord recovery retry/backoff는 SPK-03~04와 WBS-03.D·04.D·05 closure 전 확정되지 않습니다. 이 review contract의 승인은 실제 scheduler·Discord recovery 호출·schema·retry·code를 승인한 것이 아닙니다.

#### WBS-07 A~G Consistency Review

[FACT] WBS-07.A~G의 계획 경계는 다음 dependency를 따릅니다. 후행 checkpoint는 선행 evidence와 immutable source reference를 사용하며, 후행 결과로 선행의 selection·delivery attempt·raw event를 덮어쓰지 않습니다.

```text
07.A external contract·identity·permission·cost
  → 07.B logical rendering·physical mapping
  → 07.C invocation·server acceptance
  → 07.D Gateway raw event·feedback projection
      ├─ 07.E bounded REST feedback reconciliation
      └─ 07.F structured interaction·receipt intake
            → 07.G confirmation·resend·recovery
```

| Domain mutation | Canonical plan owner | Realization owner | 금지된 중복 owner |
| --- | --- | --- | --- |
| Discord operation activation·contract evidence | WBS-07.A | WBS-11과 WBS-17~19 operation gate | Adapter별 임의 endpoint·permission·cost 판단 |
| Delivery set/segment·message/item render plan | WBS-07.B | WBS-17 | WBS-18/19의 payload·selection 재작성 |
| Physical invocation·server acceptance evidence | WBS-07.C | WBS-17 | Gateway/REST/receipt의 original 2XX 생성 |
| Gateway event history·feedback current projection | WBS-07.D | WBS-18 | Recovery worker의 raw event 수정 |
| REST feedback request·snapshot·current application | WBS-07.E | WBS-19.A, WBS-18 feedback reader | Delivery acceptance·recovery mutation |
| Missing/recommendation·receipt raw intake·validation | WBS-07.F | WBS-18 intake와 WBS-19.B handoff | Listener의 직접 resend |
| Recovery case/event·confirmation·resend·backlog | WBS-07.G | WBS-19.B | REST feedback worker·Gateway listener의 recovery 실행 |

[FACT] WBS-19는 하나의 상위 구현 Task 번호를 유지하되 `WBS-19.A bounded REST feedback reconciliation`과 `WBS-19.B confirmation and recovery`를 독립 구현·테스트·rollback slice로 사용합니다. 두 slice는 WBS-05의 공통 ledger·claim·lease/fence와 WBS-07.A의 operation activation을 재사용하지만 work type·outbound operation·evidence·state transition·retry 판정을 공유하지 않습니다.

| 유사 용어 | 정확한 의미 | 다른 의미로 바꿀 수 없는 항목 |
| --- | --- | --- |
| `discord_2xx` acceptance | 특정 physical Discord request의 server 수락 | 사용자 수신·정시 이전 시각·전체 batch 성공 |
| Recipient-observed receipt | 정확히 mapping된 승인 사용자의 기사 reaction·batch ✅·`받음` | Original server 2XX·원문 열람·유용함 |
| Feedback current state | Article negative, batch review, recommendation의 mutable projection | Immutable evaluation evidence·delivery acceptance |
| `receipt_confirmation` | 수락 불명확 original delivery를 묻는 별도 system message | Original article delivery·batch review 대상 |
| `받음` | 승인 recipient의 exact original-scope user-received confirmation | Original Discord response·정시 수락 시각 |
| `못 받음` | 승인 recipient의 user-not-received event와 1회 resend 권한 | Original server 명시적 미수락·자동 backlog |
| `confirmation_no_response` | 다음 성공 정규 batch까지 exact 응답 미관측 | 미수신·동의·자동 recovery 승인 |
| `conflicting_receipt` | Same-scope 상충 evidence의 안전한 비자동 상태 | 어느 evidence의 우선·삭제·resend 근거 |

| Message/segment kind | Source owner | 함께 포함 가능 | Feedback·receipt 적용 경계 |
| --- | --- | --- | --- |
| `scheduled_current` | Current immutable selection result | Confirmed recovery와 별도 segment로 같은 regular set 가능 | 실제 article mapping과 대표 scope만 허용 |
| `processing_delayed_full_result` | 목표 시각 뒤 완료된 original immutable result | 전용 delivery set만 허용 | 자체 actual item scope만 허용 |
| `confirmed_non_acceptance_recovery` | Original result의 실제 미수락 item subset | Current와 10+10으로 가능 | Original/recovery physical scope를 구분 |
| `failure_notice` | 처리 실패 final summary | Article segment와 혼합 금지 | Article feedback·batch review·receipt·recovery 금지 |
| `receipt_confirmation` | 수락 불명확 recovery case | 별도 system-message delivery | Exact `받음`/`못 받음`만 원 case에 적용 |
| Recovery offer | Confirmation no-response case와 target regular set | Regular delivery의 별도 offer mapping | Explicit selection만 recovery handoff 생성 |

[FACT] WBS-18은 reaction·slash command·receipt interaction을 raw intake하고 진위·configuration·user·target을 검증해 durable handoff까지 담당합니다. Missing-article 회신과 recommendation feedback projection은 WBS-18이 담당하지만, receipt business event 적용·recovery case mutation·confirmation/resend/offer 실행은 WBS-19.B만 담당합니다.

[FACT] WBS-17의 공통 rendering·physical invocation·acceptance 계약은 article delivery뿐 아니라 failure notice, receipt confirmation과 recovery offer system message에도 적용합니다. System-message 전용 의미 규칙은 WBS-07.B·F·G가 제공하며, WBS-19.B가 직접 무증거 Discord 발송 경로를 따로 만들지 않습니다.

| Cross-domain 금지 전이 | 판정 |
| --- | --- |
| REST feedback snapshot → delivery acceptance/recovery case 변경 | 금지 |
| Gateway event 또는 receipt → original `discord_2xx`·정시 수락 생성 | 금지 |
| Reaction remove → append-only recipient receipt·delivery evidence 삭제 | 금지 |
| `못 받음` → original server explicit non-acceptance 또는 자동 backlog | 금지 |
| Acceptance uncertainty → lease 만료 기반 자동 resend/recovery | 금지 |
| Confirmation·offer 2XX → original article delivery 수락 | 금지 |
| Processing-delayed result ↔ confirmed non-acceptance backlog 혼합 | 금지 |
| Recovery·missing lookup → RSS·AI·selection·최신성 재실행 | 금지 |
| Mutable feedback projection → 기존 immutable evaluation 소급 변경 | 금지 |

[FACT] REST request trigger는 네 승인 범주로 제한합니다. Architecture·Interface의 “새 Gateway 연결” 축약 표현은 Data Model과 2026-09-08 사용자 확인에 따라 정상 resume을 포함하는 일반 trigger로 사용하지 않습니다. Resume 실패 또는 event gap·저장 실패·ordering 불신이 네 범주 중 하나에 직접 귀속되는 evidence가 있을 때 request만 만들며, request 자체로 REST 호출을 실행하지 않습니다.

| Verification layer | WBS-07 consistency 검증 책임 |
| --- | --- |
| WBS-23 contract/unit | Operation allowlist, mapping, state·error matrix, segment composition, system-message 의미 분리 |
| WBS-24 concurrency/replay/fault | Duplicate event/interaction, lease replacement, response loss, late evidence, lost handoff, duplicate resend 방지 |
| WBS-25 E2E | Current/delayed/recovery/notice/confirmation/offer, feedback·missing·receipt·recovery와 사용자 표시·Hard Gate 대조 |

[INFERENCE] 최소 negative fixture는 정상 resume REST request 0건, request-only HTTP call 0건, incomplete pagination `absent` 0건, receipt 기반 original 2XX 0건, listener 직접 resend 0건, exact `못 받음` 예외 외 resend 0건, uncertain resend loop 0건, processing-delayed/recovery 혼합 0건과 same-scope conflict 자동 우선 0건을 각각 독립적으로 식별해야 합니다.

| WBS-07 closure gate | 완료에 필요한 evidence | 미충족 시 상태 |
| --- | --- | --- |
| External contract | SPK-03 pass와 SPK-06 비용 coverage, 사용자 승인 Discord operation register | WBS-07 실제 완료 불가 |
| Logical contract | WBS-07.A~G 계획·fixture owner 승인 | 상세 계획만 승인, 구현 계약 미완료 |
| Physical closure | WBS-04.D의 key·reference·constraint·query·redaction 결정 | Schema coding 진입 불가 |
| Work/external-effect closure | WBS-05의 claim·fence·uncertainty·lost-handoff와 실제 Discord 계약 결합 | Adapter coding 진입 불가 |
| Verification readiness | WBS-23~25 fixture ID·expected state·negative invariant 연결 | WBS-09 통과 불가 |

[FACT] 현재 WBS-07.A~G 승인은 계획 정의의 순차 검토 완료를 뜻합니다. SPK-03·06 evidence, 사용자 실제 Discord contract 선택, WBS-04.D 물리 closure와 WBS-05 결합 검증 전에는 WBS-07 실행 완료 또는 Coding Readiness 통과로 기록하지 않습니다.

[INFERENCE] 파일 검토와 정합성 검토는 모호한 owner·추적 누락·문언 충돌 위험을 줄이지만 실제 외부 계약 불일치, rate limit, 동시성, 중복 외부 효과, 운영 backlog 위험을 제거하지 않습니다. 이 잔존 위험은 spike, 물리 설계, 구현과 WBS-23~25의 실행 evidence가 통과할 때만 닫힙니다.

[UNKNOWN] WBS-07의 남은 blocker는 실제 Discord capability·permission·positive acceptance·Gateway identity/resume·REST pagination/rate limit·interaction transport, physical schema·constraint, retry/backoff, Cron scheduling 오차, 장기 backlog와 conflict 운영 해소입니다. 이를 기본값이나 library 관행으로 숨기지 않고 SPK-03~04, WBS-04.D·05·08 및 WBS-09 blocker register에 연결합니다.

### WBS-08 Detailed Review Checkpoints

[FACT] WBS-08은 논리 설계를 변경하지 않고 운영 evidence·비용·backup·restore·metric·evaluation을 독립 검토 가능한 일곱 checkpoint로 나눕니다. 각 checkpoint 승인은 계획 정의 승인이고 실제 도구·수치·운영 실행 승인이 아닙니다.

| ID | 검토 경계 | 계획 산출물 | Closure 전제·후속 owner |
| --- | --- | --- | --- |
| WBS-08.A | Operational evidence·observability | PostgreSQL domain/evidence 정본과 파생 log/metric/trace/alert 분리, operational-event catalog, batch·work·attempt·article·configuration correlation, 0/미실행/미완료/해당 없음/측정 불가/원인 미확정 의미, error/attempt 집계, structured allowlist·cardinality·redaction·time·alert 비증거 경계 | WBS-03·05~07; physical reference는 WBS-04.D, 도구·query는 WBS-20, contract/redaction/E2E는 WBS-23·25, 실제 stack·threshold·retention은 후속 승인 |
| WBS-08.B | Cost safety·pause/resume | AI·Discord·K3s·PostgreSQL/PV·backup·registry·scheduler/monitoring 전체 coverage register, 공식 무료 조건·과금 불가 설정·usage/quota와 사용자 직접 월별 billing 확인 분리, 확인/불명/위반·first-month Hard Gate, configuration/attempt evidence binding, 원인별 차단·kill switch·수동 resume·redaction | SPK-06A/B와 WBS-03.D; 자동 billing API·유료/다른 account/provider fallback 없음, 구현 WBS-11·20·26·28~30 |
| WBS-08.C | Backup run·RPO/RTO | PostgreSQL 보호/제외 inventory, 일관성 시점·source DB/configuration·DB position reference, Pod/PVC/node/storage-backend failure-domain 독립성, run/artifact/integrity/restoreability 분리, retry·non-overwrite·gap escalation, RPO/RTO·schedule·보존/용량/비용·security 결정 gate | SPK-04~06과 WBS-08.A~B; physical WBS-04.D, restore contract WBS-08.D, 구현/drill WBS-21·23~24·28, 실제 도구·수치·retention은 후속 승인 |
| WBS-08.D | Restore validation·manual recovery | 격리 rehearsal·별도 승인 production restore·전체 resume 분리, read-only artifact와 no-production-credential/egress isolation, schema/migration/data·work/lease/fence·selection/delivery/acceptance/recovery 검증, loss-window no-backfill, DB trust 뒤 exact feedback REST만 여는 제한 승인과 최종 수동 resume, 단계별 RPO/RTO evidence | WBS-05·07 consistency·08.A~C; physical WBS-04.D, 구현 WBS-21, fault WBS-24, 운영 WBS-28~29, 실제 restore·DB mutation 없음 |
| WBS-08.E | Metric catalog·source lineage | Metric ID/definition version·category·scope/time·logical subject, PostgreSQL source lineage, numerator/denominator·exclusion/exception·unit/precision·measurability/owner, 6개 Hard Gate 독립 판정, attempt/message dedupe, time/service·feedback·missing/recall 의미와 정의 변경 불변성 | WBS-06.F·07 consistency·08.A~D; physical WBS-04.D, query/계산 WBS-20·22, golden/E2E WBS-23·25~26·30, 상시 metric source entity 없음 |
| WBS-08.F | Evaluation work·scope·snapshot | 사용자 요청 work, batch/day/validation-period scope, as-of/high-watermark, manifest scheme·digest·immutable snapshot과 실패 경계 | WBS-05·08.E; physical WBS-04.D, runner WBS-22, replay WBS-24~25 |
| WBS-08.G | Typed result·Hard Gate·report | sample adequacy·quality review·6 hard gates·quality/service metric·final interpretation, 독립 판정과 report contract | WBS-08.E~F; runner/report WBS-22·25~26·30 |

[INFERENCE] 권장 순서는 `08.A → 08.B → 08.C → 08.D → 08.E → 08.F → 08.G → consistency`입니다. 운영·비용 evidence의 공통 의미를 먼저 닫고, backup과 restore를 분리한 뒤, 안정된 source lineage를 기준으로 evaluation snapshot과 결과를 정의합니다.

[FACT] WBS-08.A~G는 `configuration_snapshot`, `external_contract_check`, `cost_safety_evidence`, `operational_event`, `backup_run`, `restore_validation`, evaluation work/attempt, `evaluation_snapshot`과 typed `evaluation_result`의 승인된 logical owner를 재사용합니다. 별도 canonical metric 원본, `evaluation_run`, backup 상태 복제 또는 범위별 비용 entity를 새로 제안하지 않습니다.

[FACT] RPO/RTO·backup 공백·도구·저장 위치·manifest digest·quality review·report의 실제 값은 checkpoint 안에서 근거와 승인 owner를 결정할 대상입니다. SPK-04~06 및 후속 물리 설계 전에 구현 기본값으로 확정하지 않습니다.

[FACT] WBS-08 계획의 완료는 backup command 성공, alert 존재 또는 metric 문서 작성만을 뜻하지 않습니다. Backup restoreability와 실패 영역, 비용 coverage, source completeness, evaluation 불변성 및 `pass/fail/not_measurable` 판정 경계가 구현·검증 owner까지 연결돼야 합니다.

[INFERENCE] 파일 검토는 owner·의존성·판정 모호성을 줄이지만 실제 backup 복원 가능성, 추가 월 비용 0원과 평가 산식의 정확성을 제거하지 않습니다. 해당 위험은 SPK-04~06, WBS-21~26과 WBS-28~30의 실행 evidence 전까지 잔존합니다.

#### WBS-08.A Operational Evidence and Observability Review Contract

[FACT] 업무·평가의 source of truth는 PostgreSQL에 보존되는 승인된 domain record와 append-only evidence입니다. Structured log·metric·trace·dashboard·alert는 이를 조회·상관·요약하는 파생 관측 수단이며, source record 없이 업무 성공·실패·수량·Hard Gate 판정을 새로 만들지 않습니다.

```text
domain source/evidence
  → stable correlation context
  → structured log / metric / trace
  → dashboard / alert
  → 운영자 확인·조치
  → 필요한 경우 source를 참조하는 operational_event
```

| 관측 계층 | 계획 역할 | 정본으로 사용할 수 없는 항목 |
| --- | --- | --- |
| Domain record/evidence | Batch·article·attempt·result·external response·acceptance·feedback·recovery의 실제 사실 | 파생 dashboard 상태로 원본 덮어쓰기 |
| Structured log | 실행 흐름·오류·차단·correlation의 운영 조사 | Log 한 줄만으로 delivery/AI/backup 성공 확정 |
| Metric | 상태·수량·지연·사용량의 제한된 시계열/집계 관측 | High-cardinality 개별 업무 원본·evaluation snapshot 대체 |
| Trace | 허용된 내부 단계·외부 attempt의 비민감 관계 조사 | Credential·원문 payload·장기 canonical evidence 저장 |
| Dashboard | 현재 운영 상태·추세 표시 | 데이터 누락을 0 또는 정상으로 확정 |
| Alert | Actionable condition과 source scope를 운영자에게 알림 | Alert 부재를 정상·Hard Gate pass로 확정 |

[FACT] `operational_event`는 모든 실행 log를 복제하지 않습니다. 비용 위반·비용 불명확 차단, 수동 pause/resume, backup 실패·공백 초과, restore 검증 대기·사용자 재개 승인, contract/credential mismatch와 같은 사람의 확인·승인·운영 전환이 필요한 사건만 source evidence를 참조해 기록합니다.

| Correlation 축 | 관측에서 필요한 관계 | 중복·혼합 금지 |
| --- | --- | --- |
| Scheduled batch/slot | Asia/Seoul 예정 일자·시작·전달 시각 | Retry·재실행을 새 예정 batch로 계산 |
| Work item/attempt | Logical work, claim/lease/fence, attempt lifecycle | Attempt 수를 logical result 수로 계산 |
| Article/candidate | Exact article identity와 batch candidate | 재관찰·retry를 신규 article로 계산 |
| Configuration/evidence | Processing snapshot, contract·cost reference/version | Secret 값·현재 default로 대체 |
| Domain operation | RSS·AI·Discord delivery·Gateway·REST·evaluation·backup/restore | 서로 다른 오류·response·usage 합치기 |
| External attempt | Prepared/invocation/evidence와 안전한 external correlation | 응답 없음으로 성공·명시적 실패 추정 |
| Recovery source | Original batch/result/attempt와 recovery work·delivery | Recovery를 current 수량·정시 성공으로 합산 |

[INFERENCE] 파생 telemetry는 source record의 안정적인 opaque reference 또는 제한된 correlation key를 사용할 수 있지만, 원문 link·제목·요약·Discord user/message ID·전체 external request/response를 metric label로 복제하지 않습니다. 상세 조사는 허가된 source reference 조회로 수행하고 실제 identifier의 저장·표시·접근 방식은 WBS-04.D·20에서 닫습니다.

| 관측 의미 | 정의 | 금지 해석 |
| --- | --- | --- |
| `zero` | 완전한 정의 범위와 source coverage에서 실제 count가 0 | Query 실패·범위 미확정·source 누락 |
| `not_executed` | 예정 work가 실행되지 않았다는 evidence가 있음 | 정상 신규 0건·성공 |
| `incomplete` | 시작했으나 terminal completion이 없음 | 실패 확정·성공·0건 |
| `not_applicable` | 정의상 대상이 아닌 범위 | Source가 없어 측정할 수 없음 |
| `not_measurable` | 필수 evidence coverage·비교 가능성이 부족함 | 0·pass·fail 자동 확정 |
| `unknown` | 원인·상태를 신뢰 가능하게 분류할 수 없음 | 일반 오류·정상·무제한 retry |

[FACT] 외부 API response·error·rate/quota·usage는 RSS·AI·Discord domain attempt에 각각 연결하고, logical 업무 결과와 분리합니다. Timeout·network 오류·response loss·mapping 부족·명시적 rejection·rate limit을 하나의 `error`로 축약해 delivery 수락·AI 완료·retry 가능성을 추정하지 않습니다.

[FACT] Retry·재실행·recovery의 attempt·외부 usage·latency는 각각 관측하되 article·candidate·selection result·성공 delivery·원래 batch 수량으로 다시 합산하지 않습니다. 파생 metric이 source logical key와 attempt key를 구분하지 못하면 값을 출력하지 않고 `not_measurable` 또는 query/definition 오류로 처리합니다.

| Structured telemetry allowlist 범주 | 허용 예 | 반드시 제외 |
| --- | --- | --- |
| Identity/correlation | 비민감 internal reference, role, work/attempt kind | API key, token, webhook URL, interaction secret |
| State/reason | Approved state·typed reason·gate decision | Raw exception에 포함된 credential/header/body |
| Time | Source 시각, observation 시각, duration과 clock/source 표시 | 비교 불가 문자열을 정렬 근거로 사용 |
| Quantity | Candidate·attempt·item count와 coverage | 기사 제목·요약·link·사용자 식별자를 label로 사용 |
| External result | Safe endpoint category, status/error/limit category, redacted reference | Authorization·cookie·전체 request/response payload |
| Version | Configuration·contract·policy·image revision reference | Secret 값 또는 secret hash를 version으로 사용 |

[INFERENCE] Redaction은 사후 문자열 치환만이 아니라 logging/metric/trace API에 raw credential·민감 header를 전달하지 않는 구조화 allowlist를 기본 계획으로 사용합니다. Canary Secret은 Repository·image·DB·backup·command argument·configuration·log·metric·trace·exception·test snapshot·AI request·Discord output 전 범위를 WBS-20·23에서 검사합니다.

[FACT] 외부에서 제공된 시각은 원값·offset 또는 time source와 비교 가능한 instant를 구분하고, 예정 KST 시각·실제 시작·invocation·response·수락·관측·recovery 시각을 서로 덮어쓰지 않습니다. 비교 불가 또는 clock 신뢰가 부족하면 순서·지연·정시 목표를 충족한 것으로 추정하지 않습니다.

| Alert candidate | Source condition | Alert가 대신하지 못하는 것 |
| --- | --- | --- |
| Scheduled work 미실행·미완료 | Scheduled batch/work 상태와 관측 기한 | 신규 0건·pipeline 실패 자동 확정 |
| External error·quota·rate limit | Domain attempt의 typed evidence와 영향 scope | 자동 retry·유료 fallback 승인 |
| Discord acceptance uncertainty·backlog | Delivery/recovery source state | 원래 수락·미수락 확정 |
| Backup 실패·공백 초과 | Backup run history와 승인 공백 기준 | Restore 가능·outbound resume |
| Cost evidence 불명·위반 | Cost coverage와 source evidence | 비용 0원·Hard Gate pass |
| DB trust·integrity 문제 | DB/restore validation evidence | Source 업무 record 수정·삭제 |

[FACT] Alert는 condition, 관측 시각, 영향 범위, severity/action owner와 source reference를 가져야 하지만, alert 발송 성공·실패 또는 alert 부재는 원래 장애의 발생·해결·Hard Gate 결과를 바꾸지 않습니다. 실제 alert channel·threshold·dedupe·silence·escalation은 WBS-20·28~30의 후속 승인 전 확정하지 않습니다.

[INFERENCE] WBS-08.A 완료 조건은 source 없는 성공/수량/Gate 판정, missing→zero, timeout→명시적 실패·성공, attempt→logical result 중복 집계, identifier high-cardinality label, raw secret 유출, no-alert→healthy/pass와 비교 불가 시간의 정시 판정이 WBS-20·23·25 fixture에서 각각 0건이 되도록 계획 owner와 기대 결과가 연결되는 것입니다.

[UNKNOWN] 실제 observability stack·exporter·dashboard·alert channel, metric name·label allowlist·cardinality budget, trace sampling, timestamp type·precision·clock synchronization, telemetry 보존·접근·redaction 구현과 incident response는 WBS-04.D·20·23·25·28~30 전 확정되지 않습니다. 이 review contract의 승인은 특정 도구·schema·query·dashboard·alert threshold를 승인한 것이 아닙니다.

#### WBS-08.B Cost Safety, Pause, and Resume Review Contract

[FACT] MVP-A는 모든 적용 실행 경로의 추가 월 운영비 0원을 요구하며, 실제 월별 billing·usage 확인은 사용자가 직접 수행합니다. 자동 billing API를 추가하지 않고, 시스템은 사용자가 확인한 대상 기간·비용 범위·판정과 비민감 evidence reference만 `cost_safety_evidence`에 연결합니다.

```text
공식 무료·과금 불가 조건과 configuration
  → SPK-06A 사전 비용 안전 확인
  → 승인된 configuration/contract/cost evidence 활성화
  → 비용 가능 invocation별 evidence binding
  → SPK-06B 제한 실험 사용량·전체 범위 대조
  → 사용자 월별 billing/usage 직접 확인
  → evaluation의 비용 Hard Gate
```

| 비용 coverage scope | 최소 확인 질문 | 누락 시 경계 |
| --- | --- | --- |
| AI provider | 승인 account/project/model/API 경로가 무료·과금 불가이고 quota·usage가 확인되는가 | AI 호출 차단, 다른 provider·account·유료 경로 전환 금지 |
| Discord | Application·Gateway·REST·interaction·delivery 사용에 추가 비용 경로가 없는가 | 영향 Discord operation 활성화 금지 |
| K3s runtime/host | 기존 환경 사용이 추가 월 비용을 만들지 않는가 | Workload 운영 활성화 보류 |
| PostgreSQL/PV | DB·volume 용량·운영이 추가 비용 범위 밖인가 | 신규 production 데이터 경로 활성화 보류 |
| Backup storage/transfer | 저장·보관·전송·restore rehearsal가 추가 비용을 만들지 않는가 | Backup 선택·outbound readiness 완료 금지 |
| Image registry | Image 저장·pull·traffic 조건이 0원 범위를 유지하는가 | 배포 준비 차단 |
| Scheduler/monitoring | Cron·listener·log/metric/alert가 추가 유료 service를 사용하지 않는가 | 해당 도구 선택·운영 활성화 금지 |

[FACT] 하나의 `cost_safety_evidence`는 하나 이상의 scope를 덮을 수 있지만 적용 scope, 환경, configuration 또는 비민감 account/project reference, 확인 시각, 근거 종류, 판정과 확인자를 식별할 수 있어야 합니다. 범위별 별도 비용 entity를 만들거나 같은 evidence를 매 batch 복제하지 않습니다.

| Evidence kind | 목적 | 대신할 수 없는 것 |
| --- | --- | --- |
| Official free condition | Plan·quota·과금 조건의 공식 근거 | 실제 활성 account/project 설정 확인 |
| Non-billable configuration check | 승인 경로가 과금 불가로 설정됐는지 확인 | 운영 뒤 실제 청구 결과 |
| Usage/quota evidence | 호출량·제한·공식 quota 상태와 오류 근거 | 월별 invoice/청구액 확인 |
| User monthly billing confirmation | 사용자가 해당 기간의 실제 billing/usage를 직접 확인한 결과 | Credential·invoice 원문 저장 또는 자동 billing API |
| Cost incident evidence | 실제 비용·유료 사용·범위 위반과 영향 | 이후 정상화로 과거 위반 삭제 |

[FACT] Configuration snapshot은 free-only 정책과 실행 경로를 설명하고, external contract check는 공식 조건·sandbox 결과를 보존하며, cost safety evidence는 비용 판정을 보존합니다. 실제 pause·violation·resume approval은 이 source들을 참조하는 `operational_event`가 소유합니다. 하나를 다른 record에 내용 복사해 대체하지 않습니다.

[INFERENCE] 비용 scope의 계획상 판정은 최소한 `confirmed_for_activation`, `confirmation_unavailable`, `violation`과 아직 해당 기간의 월별 결과가 존재할 수 없는 상태를 구분해야 합니다. 실제 enum은 WBS-04.D 전에 확정하지 않으며, configuration 값만으로 confirmed 상태를 만들지 않습니다.

| 비용 상황 | Runtime gate | 비용 Hard Gate |
| --- | --- | --- |
| 모든 비용 가능 scope의 사전 공식·설정 근거가 유효 | 승인 scope의 첫 운영 invocation 가능 | 월별 운영 결과가 아직 없으면 `pass` 미확정 |
| 첫 운영월이 끝나지 않아 월별 결과가 아직 존재하지 않음 | 이 사실만으로 사전 승인 scope를 자동 차단하지 않음 | `pass`·실제 0원 추정 금지, evidence pending/not-measurable 경계 |
| 적용 scope의 사전 비용 조건 확인 불가·stale·mismatch | 영향 신규 비용 가능 invocation 차단 | 필수 coverage 부족이면 `not_measurable` |
| 실제 유료 사용 또는 추가 비용 확인 | 영향 production 경로 pause와 incident 보존 | 해당 기간 비용 Gate `fail` |
| 기간 종료 뒤 필요한 월별 billing confirmation 누락 | 후속 운영 정책에 따른 재확인 대기; 자동 무료 추정 금지 | `not_measurable` |

[FACT] 무료 quota 소진, rate limit, 인증·권한·network 오류와 실제 비용 위반은 별도 원인입니다. 공식 무료 quota 소진은 영향 호출을 중단하고 공식 reset/reopen 근거를 기다리지만 그 자체를 실제 청구 비용으로 기록하지 않습니다. 반대로 비용 위반은 정상 usage·성공 호출 여부와 무관하게 독립 Hard Gate 위반입니다.

[FACT] 비용·plan·account/project 상태가 불명확하거나 위반되면 다른 credential·account·project·provider·model·유료 plan·runtime으로 자동 전환하지 않습니다. 사용자가 외부 설정을 직접 바꾼 경우에도 새 configuration·contract·cost 검증과 명시적 승인 없이 운영 활성화로 간주하지 않습니다.

| Pause boundary | 계획 동작 | 금지 동작 |
| --- | --- | --- |
| Scope-specific cost uncertainty | 영향 scope의 신규 work/invocation 차단, 내부 evidence·영향 보존 | 무관한 안전한 failure notice까지 무조건 차단 |
| Cost violation | 비용 가능 production 경로의 긴급 또는 계획 pause, source와 영향 기록 | 위반을 quota·일시 오류로 축소 |
| Already invocation-started | 중지 뒤 late usage/response와 불확실성 대조 | Process 종료로 호출 미발생 추정 |
| Kill switch | 신규 invocation 0건 확인을 목표로 workload pause | PostgreSQL·PVC·backup 자동 삭제·파괴 |
| DB trust 불명 | 비용 여부와 별개로 신규 외부 효과 차단 | Cost evidence만으로 resume |

[FACT] Kill switch의 실제 K3s CronJob suspend·listener 중지 명령과 검증 절차는 WBS-27~28에서 결정합니다. WBS-08.B에서는 중지 scope·순서·expected observation·in-flight uncertainty와 rollback 없는 데이터 보존 조건만 계획하며 실제 명령을 작성하지 않습니다.

[FACT] Resume는 자동으로 수행하지 않습니다. 적용 configuration snapshot, 필요한 contract check, 비용 evidence, credential, DB/backup/restore trust와 영향 scope의 미확정 외부 효과를 대조하고 필요한 사용자 수동 승인을 `operational_event`에 연결한 뒤 해당 scope만 재활성화합니다.

[FACT] 실제 비용 위반 뒤 정상화·환불·설정 수정·재승인이 있어도 위반 기간의 source evidence와 비용 Hard Gate `fail`을 삭제하거나 `pass`로 변경하지 않습니다. 새 기간·새 cutoff·새 evidence에 대한 별도 evaluation만 이후 상태를 판정할 수 있습니다.

[FACT] 사용자 월별 확인은 전체 invoice나 account identifier를 Repository·DB에 저장하는 작업이 아닙니다. 확인 대상 월·scope·확인 시각·확인자·0원/불명/위반 판정과 redacted reference만 보존하고 invoice 원문·credential·billing account 식별자는 저장·log·metric·trace·AI input·Discord 출력에서 제외합니다.

[INFERENCE] 비용 확인 checklist는 각 scope에 대해 적용 configuration, 공식 조건 확인일, 사전 과금 불가 판정, 운영 usage/quota, 사용자의 기간 종료 billing 확인, 누락·불명·위반과 후속 owner를 요구해야 합니다. 사용자가 직접 확인하더라도 범위·기간·판정 근거를 기록하지 않으면 비용 Gate를 `pass`로 만들 수 없습니다.

[INFERENCE] WBS-08.B 완료 조건은 scope 누락, config boolean-only 무료 판정, 월 결과 없는 first-month false pass, quota/error→비용 위반 오분류, 다른 credential/provider/유료 fallback, pause 뒤 신규 invocation, DB/PVC 삭제, 자동 resume, 과거 비용 fail 삭제와 billing 민감정보 노출이 WBS-11·20·23·26·28~30 fixture/checklist에서 각각 0건인 것입니다.

[UNKNOWN] Scope별 실제 무료 조건·설정 확인 방식, 기존 host/storage의 추가 비용 증명, evidence 유효기간·재검증 trigger, 월별 확인일·담당자·redacted reference 형식, 실제 K3s kill-switch 명령과 registry/backup/monitoring 경로는 SPK-06A/B와 WBS-04.D·11·20·21·26·28 전 확정되지 않습니다. 이 review contract의 승인은 외부 billing 연동·실제 비용 0원·운영 활성화·K3s 명령을 승인한 것이 아닙니다.

#### WBS-08.C Backup Run, RPO, and RTO Review Contract

[FACT] MVP-A의 승인된 durability 방향은 하나의 PostgreSQL StatefulSet·PersistentVolume과 그 PVC·Pod·node에만 의존하지 않는 별도 실패 영역의 논리 backup입니다. HA cluster·자동 failover·자동 restore는 이 계획에 포함하지 않습니다.

```text
backup work·gate
  → source PostgreSQL scope·일관성 지점 고정
  → logical backup artifact 생성
  → artifact integrity/readability 확인
  → 별도 failure-domain 보관 evidence
  → backup_run source record
  → 공백·실제 손실 가능 범위 관측
  → WBS-08.D isolated restore rehearsal
```

| Backup 보호 inventory | 포함 경계 | 제외·별도 복구 경계 |
| --- | --- | --- |
| PostgreSQL schema/data | 승인된 MVP-A domain record, raw RSS, work/attempt, configuration metadata, external/acceptance/feedback/recovery/operational/evaluation evidence | 실제 K3s Secret 원값·외부 account 상태 |
| Schema/migration state | 복원된 data를 해석하는 데 필요한 적용 migration/version 근거 | Container image·Git repository 자체의 backup 대체 |
| Logical references | Discord/AI/RSS의 비민감 reference와 이미 기록된 external evidence | 외부 Discord message·provider response를 다시 생성 |
| Backup metadata | Source DB/configuration, 일관성 지점, run/artifact/verification reference | Credential·Authorization·backup access secret |

[INFERENCE] 실제 database·schema·extension·role/privilege metadata 중 어느 항목을 artifact와 별도 재구성 절차가 소유할지는 WBS-04.D와 SPK-05가 inventory로 닫아야 합니다. “전체 DB”라는 표현만으로 누락 없는 backup을 추정하지 않습니다.

| Consistency evidence | 계획 목적 | 미확정 physical detail |
| --- | --- | --- |
| Source DB/environment | 어느 PostgreSQL instance·database/configuration의 backup인지 식별 | 실제 connection/reference field |
| Started/completed/observed time | Backup 실행·소요·공백 관측 | Timestamp type·precision |
| Consistent database point | 서로 다른 table의 업무 관계를 같은 일관성 기준으로 복원 | Transaction/snapshot/LSN 또는 tool-specific 표현 |
| Schema/migration reference | 복원 data와 해석 가능한 schema의 결합 | Migration fingerprint 방식 |
| Artifact identity/integrity | 이전 artifact와 구분하고 손상·덮어쓰기를 탐지 | Hash·size·format·compression |

[FACT] Backup 중 동시 업무 mutation이 가능하면 tool이 제공하는 일관성 계약과 source DB position/reference를 evidence로 검증합니다. 이를 입증할 수 없으면 artifact 생성 성공만으로 일관된 backup이라 판정하지 않고 SPK-05를 fail 또는 inconclusive로 둡니다.

| Failure-domain 요소 | 최소 질문 | 유효성 경계 |
| --- | --- | --- |
| Pod | PostgreSQL Pod 삭제·재생성 뒤에도 artifact가 남는가 | 같은 Pod filesystem만이면 무효 |
| PVC/volume | 원본 PVC 삭제·손상과 독립적인가 | 같은 PVC 내부 복사만이면 무효 |
| Node/disk | K3s node·disk 상실과 독립적인가 | 같은 node의 같은 disk만이면 무효 |
| Storage backend | 원본 volume backend 장애와 독립적인가 | 이름만 다른 동일 장애 경로면 미입증 |
| Access/credential | 원본 workload 침해·오작동이 backup까지 삭제할 수 있는가 | Broad delete 권한이면 잔존 위험 기록 |

[FACT] 실제 별도 실패 영역은 SPK-04에서 K3s storage topology를 확인하고 SPK-05에서 원본 장애 가정과 backup artifact 생존을 실험해 결정합니다. 저장 위치 이름이나 별도 directory라는 사실만으로 failure-domain 독립성을 확정하지 않습니다.

| Backup lifecycle evidence | 의미 | 금지된 상태 변경 |
| --- | --- | --- |
| Requested/eligible | Trigger와 DB·cost·credential gate가 유효 | Request만으로 artifact 생성 기록 |
| Started | 실제 backup invocation이 시작됨 | 시작만으로 success 기록 |
| Artifact created | 출력 artifact가 관측됨 | Integrity·restoreability 자동 확정 |
| Integrity/readability verified | 승인된 기본 검사가 통과 | Full restore·업무 무결성 자동 확정 |
| Failed/inconclusive | 원인·시각·영향·공백 상태 기록 | 이전 성공 run/artifact 덮어쓰기 |
| Restore-rehearsed | WBS-08.D 격리 restore 결과에 연결 | Production restore·outbound resume 자동 실행 |

[FACT] 각 실제 retry는 원래 실패·trigger와 연결된 별도 실행 evidence를 가지며 이전 실패를 success로 덮어쓰지 않습니다. Artifact reference는 불변·구분 가능해야 하고 새 실행이 이전 검증 artifact를 같은 이름·경로에서 파괴하지 않는 계약을 요구합니다. 실제 run/work 관계와 filename/object key는 WBS-04.D·21에서 정합니다.

[FACT] Backup 성공은 최소한 artifact 생성·기본 integrity/readability·보관 위치 evidence를 의미하지만 실제 업무 복원 가능성은 WBS-08.D의 restore validation으로 별도 판정합니다. Backup tool의 exit code 0이나 file 존재만으로 RPO/RTO·restoreability를 통과시키지 않습니다.

| Recovery objective | 계획 정의 | 승인 방식 |
| --- | --- | --- |
| RPO | 장애 시 허용 가능한 최대 data loss와 이를 입증하는 backup/restore 시점 차이 | SPK-04~05 측정·손실 분석 뒤 사용자 승인 |
| RTO | 격리 restore 시작부터 필요한 integrity·reconciliation·재개 승인 준비까지의 목표 시간 | SPK-05 rehearsal 단계별 실측 뒤 사용자 승인 |
| Backup interval | RPO를 만족하기 위한 실행 빈도 후보 | Tool/runtime/cost/scheduling evidence 뒤 승인 |
| Allowed backup gap | 최근 유효 backup 이후 outbound 보호 경계 | 측정·운영 영향 뒤 별도 사용자 승인 |

[FACT] Schedule 간격을 RPO 실측값으로 대신하거나 artifact 생성 시간만 RTO로 보고하지 않습니다. RTO에는 restore와 무결성·ledger/Discord/feedback 대조 및 사용자 승인 준비에 필요한 단계가 포함되며 실제 범위는 WBS-08.D에서 닫습니다.

[FACT] Backup 실패는 source run, 시각, 원인, 최신 유효 backup과의 gap, 영향 scope를 기록하고 alert 후보로 연결합니다. 승인된 공백 안에서는 backup work만 검증된 정책으로 retry할 수 있지만, 공백을 넘으면 WBS-03.D의 신규 pipeline/outbound gate를 닫고 정상 신규 0건이나 정상 운영으로 표시하지 않습니다.

[FACT] Backup이 다시 생성됐다는 사실만으로 gate를 열지 않습니다. 새 artifact의 생성·integrity·restoreability evidence, 현재 PostgreSQL ledger 무결성, 비용·configuration·contract 조건과 사용자 수동 승인이 WBS-08.D의 resume gate에 연결돼야 합니다.

[INFERENCE] Backup artifact의 보존·정리 정책은 RPO/RTO, 장애 조사·평가 근거, 용량 증가율과 추가 월 비용 0원을 함께 만족해야 합니다. 승인 전 자동 삭제·lifecycle을 구현하지 않고, 무제한 보존을 무료라고 추정하지도 않습니다. SPK-05~06의 capacity/cost evidence와 사용자 결정이 WBS-09 blocker를 닫아야 합니다.

[FACT] Backup workload에는 승인된 DB read/export와 target write에 필요한 최소 credential만 주입합니다. Application·AI·Discord credential을 주입하지 않고, backup artifact·command argument·log·metric·trace에 backup access secret·DB password·Authorization 값을 포함하지 않습니다. Artifact 접근 제어·암호화 at rest/in transit의 실제 방식은 SPK-05와 WBS-20·21·23에서 검증합니다.

[INFERENCE] WBS-08.C 완료 조건은 보호 대상 누락, inconsistent artifact 성공 판정, 같은 Pod/PVC/node-only backup 인정, 이전 artifact overwrite, retry의 과거 실패 삭제, file-created→restoreable 전환, 측정 없는 RPO/RTO, gap 초과 운영 지속, backup 재성공 자동 resume, 무승인 retention 삭제와 secret 노출이 SPK-04~05·WBS-21·23~24·28 fixture에서 각각 0건인 것입니다.

[UNKNOWN] Backup tool·format/version, database/schema/extension/role inventory, consistent DB point 표현, StorageClass·volume backend·failure domain, artifact storage·hash·compression·encryption, RPO/RTO·interval·gap, capacity·retention·manual cleanup 및 비용 0원 경로는 SPK-04~06과 WBS-04.D·08.D·21·28 전 확정되지 않습니다. 이 review contract의 승인은 실제 backup 도구·schedule·storage·수치·retention 또는 production restore를 승인한 것이 아닙니다.

#### WBS-08.D Restore Validation and Manual Recovery Review Contract

[FACT] Restore rehearsal, 실제 production restore와 일반 outbound resume는 별도 승인·evidence 단계입니다. 정기 검증은 production DB를 변경하지 않는 격리 환경에서 수행하고, 실제 production restore는 장애·손상 범위와 artifact를 특정한 별도 사용자 승인 없이는 시작하지 않습니다.

```text
일반 outbound closed
  → exact backup artifact 선택·무결성 확인
  → isolated restore rehearsal
  → schema·data·ledger·domain invariant 검증
  → 실제 장애 시 별도 승인 production restore
  → stale worker·lease·external-effect uncertainty 대조
  → restricted feedback-reconciliation 승인
  → exact bounded Gateway/REST 대조
  → 새 backup·restoreability와 전체 readiness 확인
  → 사용자 final outbound-resume 승인
```

| 단계 | 환경·권한 | 완료 evidence | 다음 단계 자동 진입 |
| --- | --- | --- | --- |
| Isolated rehearsal | 격리 DB, source artifact read-only, production 외부 credential/egress 없음 | Restore·schema·data·업무 invariant와 단계별 시간 | 금지 |
| Production restore approval | 장애·손실 범위, 선택 artifact, 예상 영향과 rollback 불가 가능성에 대한 명시적 승인 | Approval reference와 전체 outbound closed evidence | 금지 |
| Production restore execution | 제한된 restore operator와 대상 DB | 실제 restore attempt/result·손실 window | 금지 |
| Restricted reconciliation | DB trust 뒤 exact scope의 Discord REST만 별도 승인 | Request/snapshot·known failure와 feedback state 검증 | 일반 AI/delivery resume 금지 |
| Final resume | 모든 validation·new backup·cost/contract/credential와 사용자 최종 승인 | Scope별 operational resume event | 승인 범위만 활성화 |

[FACT] 격리 rehearsal target은 production PostgreSQL과 다른 명시적 database/instance 경계이고, production application·AI·Discord·RSS credential을 주입하지 않으며 외부 API egress를 허용하지 않습니다. Backup source artifact는 read-only로 취급하고 rehearsal 결과가 source artifact나 production record를 수정하지 않습니다.

| Restore lifecycle evidence | 계획 질문 | 실패 시 상태 |
| --- | --- | --- |
| Artifact selected | 어느 verified backup run/artifact와 consistency point를 사용하는가 | 선택 불가·무결성 불명은 시작 차단 |
| Restore started/completed | 어떤 tool/version·target에서 실제 실행됐는가 | Command 실패와 partial target 격리 유지 |
| Schema compatibility | Migration/schema와 intended image/revision이 호환되는가 | Incompatible, 일반 runtime 연결 금지 |
| Data integrity | Reference·uniqueness·append-only·count/digest/invariant가 만족되는가 | DB trust closed |
| Ledger/domain reconciliation | Work·selection·delivery·feedback·recovery가 source rules와 일치하는가 | General outbound closed |
| External uncertainty closure | 유실 window의 invocation·acceptance·usage가 안전하게 분류되는가 | 자동 재호출·성공 추정 금지 |
| Approval readiness | 새 backup·cost·contract·credential·manual approvals가 연결됐는가 | Resume pending |

[FACT] Restore command exit code 0은 restore 실행 결과일 뿐 application compatibility·DB integrity·업무 복구·RTO 달성·outbound resume을 뜻하지 않습니다. 각 validation 단계의 source와 결과를 `restore_validation`에 연결하고 성공 결과를 `operational_event`에 복제하지 않습니다.

| 기술/업무 검증 영역 | 최소 대조 항목 | 금지된 shortcut |
| --- | --- | --- |
| Artifact/schema | Artifact integrity, schema/migration/version, required extension/role disposition | Table 존재만으로 호환 판정 |
| Identity/input | Raw RSS snapshot/observation, exact article identity, candidate admission | 누락 record를 현재 RSS로 재생성 |
| AI/selection | Attempt·analysis·finalization·immutable selection result·handoff | 현재 provider/policy로 재계산 |
| Work ledger | Scheduled batch, work/attempt, claim·lease/fence, prepared/invocation-started | 복원된 lease를 그대로 유효 처리 |
| Delivery | Set/segment/message/item mapping, external/acceptance evidence | Mapping 없는 accepted 추정 |
| Feedback/recovery | Gateway event, REST snapshot, feedback projection, interaction·recovery case/event | Mutable projection만으로 history 완전 판정 |
| Operations/evaluation | Configuration/contract/cost, backup/restore, 기존 immutable evaluation | 기존 snapshot/result 재작성 |

[FACT] Restore 시작 전에 모든 일반 workload의 신규 claim·prepared→invocation transition·외부 호출을 차단하고 기존 worker가 종료·격리됐음을 확인해야 합니다. 복원된 lease/token을 현재 worker 권한으로 재사용하지 않고 실제 fencing epoch/token 재설정 방식은 WBS-04.D·05·21·24에서 검증합니다.

[FACT] Artifact consistency point 이후의 DB evidence가 손실됐지만 외부 AI·Discord invocation이 실제로 발생했을 가능성이 있으면 “DB에 없음”을 “호출하지 않음”으로 해석하지 않습니다. 영향 work·article·delivery scope를 external-effect uncertain 또는 `not_measurable`로 유지하고 lease 만료·process 종료만으로 재호출하지 않습니다.

| Loss-window 대상 | Restore 후 처리 | 금지 동작 |
| --- | --- | --- |
| 과거 scheduled slot 자체가 없음 | Deterministic identity와 ledger completeness에 따라 historical record 또는 `not_measurable` | 과거 Prepare/RSS/AI/delivery 시작 |
| Work 시작 근거가 없고 ledger 완전 | `not_executed` 후보 | 정상 신규 0건 처리 |
| Work/attempt 일부만 존재 | `incomplete` 또는 저장된 state·불확실성 유지 | 처음부터 자동 replay |
| Invocation 가능성·evidence gap | 영향 scope를 `external_effect_uncertain` | 호출 미발생·명시적 실패 추정 |
| Source completeness 불명 | `not_measurable` | 수량 0·Hard Gate pass 추정 |

[FACT] 손실된 historical slot은 현재 RSS 수집·AI 분석·selection·Discord delivery로 backfill하지 않습니다. Restore 이후 첫 정상 신규 processing은 승인된 현재 또는 다음 scheduled slot만 대상으로 하며 과거 slot identity·일자·수량을 새 batch로 바꾸지 않습니다.

[FACT] 복원된 delivery/acceptance 대조는 original selection result, physical mapping/item scope, response evidence, message ID, recipient receipt와 recovery case/event를 읽습니다. Accepted item을 재전송하지 않고, 수락 불명확 item을 confirmed non-acceptance로 바꾸지 않으며, feedback REST 결과로 delivery acceptance를 만들지 않습니다.

[FACT] Production restore는 Gateway event 단절과 feedback current-state 불신을 만들 수 있으므로 exact scope의 reconciliation request를 생성합니다. 그러나 DB trust가 회복되기 전에는 REST invocation을 시작하지 않습니다.

[FACT] DB integrity와 exact mapping이 확인된 뒤 사용자가 별도로 승인한 restricted reconciliation 단계에서만 WBS-07.E의 bounded Discord REST operation을 열 수 있습니다. 이때 RSS·AI·Discord article/notice/confirmation/recovery delivery와 일반 pipeline은 계속 차단합니다. Reconciliation 성공·실패·stale/unknown 결과를 고정한 뒤에야 final resume readiness를 평가합니다.

[INFERENCE] 위 2단계 승인은 “feedback 대조가 resume 선행인데 모든 outbound가 닫혀 있음”이라는 순환을 해소합니다. Restricted approval은 general outbound 승인으로 재사용하지 않고, exact request/scope·credential·contract·cost·lease/fence를 별도로 검증합니다.

| Final resume checklist | 필수 조건 | 누락 시 결과 |
| --- | --- | --- |
| DB trust | Schema/data/invariant와 ledger 완전성 또는 알려진 gap | General outbound closed |
| External-effect reconciliation | AI/Discord invocation-started·late evidence·acceptance uncertainty 분류 | 자동 replay 금지 |
| Discord/feedback | Delivery/receipt/recovery와 필요한 bounded feedback 대조 | 영향 scope stale/unknown, resume 보류 |
| Backup protection | 복원 상태의 새 backup 생성·integrity 및 승인된 restoreability evidence | Resume 보류 |
| Configuration/security/cost | Contract, credential, cost coverage와 no-secret exposure | 영향 scope 차단 |
| User approval | Validation report·잔존 risk·resume scope의 명시적 승인 | 자동 resume 금지 |

[FACT] Validation이 실패하거나 선택 artifact의 손상·호환 불가·손실 범위 확대가 확인되면 일반 outbound를 닫은 채 source artifact와 실패 evidence를 보존합니다. 다른 artifact로 자동 전환하지 않고 새 artifact, 더 큰 data-loss window, 기대 RPO/RTO 영향과 복구 계획을 보고해 별도 승인을 받습니다.

[FACT] RPO evidence는 선택 artifact consistency point와 장애/복원 기준 사이 실제 손실 범위를, RTO evidence는 restore 준비·실행·schema/data/ledger 검증·restricted reconciliation·final approval readiness까지 단계별 소요를 보존합니다. Command duration 하나를 전체 RTO로 사용하지 않습니다.

[INFERENCE] WBS-08.D 완료 조건은 production에서의 정기 rehearsal, production credential/egress가 있는 isolated test, exit-0 false success, restored stale lease invocation, DB-missing→call-not-made 추정, historical backfill, feedback REST→acceptance, restricted approval→general resume 확장, failed validation의 자동 artifact 변경과 manual approval 없는 resume가 WBS-21·24·28~29 fixture에서 각각 0건인 것입니다.

[UNKNOWN] Isolated target·network boundary, restore tool/command, schema/migration/image compatibility 검사, integrity query·count/digest, fencing reinitialization, external-effect loss-window reconciliation, restricted approval의 physical gate, 단계별 RTO 측정과 operator identity는 SPK-04~05와 WBS-04.D·05·21·24·28 전 확정되지 않습니다. 이 review contract의 승인은 실제 restore·production DB mutation·외부 reconciliation 호출·K3s 명령 또는 outbound resume를 승인한 것이 아닙니다.

#### WBS-08.E Metric Catalog and Source Lineage Review Contract

[FACT] Metric catalog는 dashboard 항목 목록이나 저장된 현재값 목록이 아니라, 각 결과를 어떤 logical subject와 source evidence에서 어떤 범위·분모·제외 규칙으로 계산하는지 고정하는 versioned 계약입니다. 승인된 Requirement의 목표·분모·예외를 변경하지 않습니다.

| Catalog field | 필수 계획 내용 | 누락 시 결과 |
| --- | --- | --- |
| Metric ID/category | Sample, hard gate, quality, service 또는 operational diagnostic 구분 | 다른 결과의 pass/fail로 대체 불가 |
| Definition version | Predicate·scope·분모·제외·단위 해석 version | 과거 결과와 혼합 금지 |
| Scope/time basis | Scheduled batch, Asia/Seoul day, validation period, billing month와 cutoff | 범위 불명은 계산 금지 |
| Logical subject/key | Article, candidate, scheduled batch, batch item, delivery scope, cost scope 등 | Attempt/message 수로 대체 금지 |
| Read-only source lineage | 계산에 필요한 PostgreSQL domain/evidence와 reference | Telemetry-only 결과 금지 |
| Numerator/denominator | 포함 조건·분모 0 처리·중복 제거 | 암묵적 기본값 금지 |
| Exclusion/exception | 제외 사유, known uncertainty, 승인된 one-time resend 예외 | 조용한 제외 금지 |
| Unit/precision | Count·ratio·duration·currency와 비교 기준 | 임의 반올림·문자열 비교 금지 |
| Measurability | `zero`·`not_applicable`·`not_measurable`·`unknown` 경계 | Evidence gap→0/pass 금지 |
| Verification owner | Golden fixture·수동 계산·contract/E2E owner | 구현 결과만으로 완료 금지 |

[FACT] 계산 source는 `scheduled_batch`, domain work/attempt, Raw RSS/observation·article·candidate, AI attempt/analysis, immutable selection result/item, delivery attempt/message mapping/acceptance, cutoff 아래 Gateway/REST/reconciliation, recovery event, configuration/contract/cost evidence와 backup/restore source record입니다. Log·metric exporter·dashboard·alert는 source completeness를 대신하지 않습니다.

| 집계 축 | Logical count | 별도 관측하되 logical count에 합치지 않음 |
| --- | --- | --- |
| Article/candidate | Exact article와 최초 candidate admission | Re-observation, duplicate feed entry, parsing attempt |
| AI result | Candidate에 적용된 승인 analysis/terminal outcome | Retry request·response·usage event 수 |
| Selection | Source batch의 immutable candidate decision/item | Policy evaluation step·정렬 comparison 횟수 |
| Delivery | Actual article item scope의 검증된 acceptance | Physical message split, attempt·retry·representative message 수 |
| Feedback | Logical subject/user/kind의 cutoff 상태 | Duplicate/add/remove Gateway event 수 |
| Recovery | Original scope와 승인된 recovery outcome | Confirmation·offer·attempt 수를 current delivery로 합산 |
| Violation | Gate별 logical violation key | Retry·replay에서 반복 관측한 같은 위반 evidence |

[FACT] 하나의 사건이 서로 다른 Hard Gate 정의를 동시에 위반하면 각 Gate에 독립 반영할 수 있습니다. 그러나 같은 Gate 안에서 동일 logical violation이 retry·재실행·recovery·중복 telemetry로 여러 번 관측돼도 위반 수를 중복 생성하지 않습니다.

| Hard Gate | 핵심 read-only source·coverage | 승인 예외·특수 경계 |
| --- | --- | --- |
| 추가 월 비용·유료 호출·유료 자원 사용 0건 | 모든 WBS-08.B scope의 cost evidence·usage·유료 event·사용자 월별 확인 | 첫 달 결과 미존재·scope 누락은 0원/pass가 아닌 `not_measurable` |
| 미처리 후보 조용한 제외 0건 | Candidate, AI/terminal outcome, selection/failure notice와 미처리 수 | Terminal·final result 연결 불완전은 `not_measurable` |
| 의도되지 않은 동일 기사 중복 발송 0건 | Exact article, batch item, article-bearing mapping, acceptance, recovery event | 승인된 exact `못 받음` immediate resend 1회와 representative mapping 제외 |
| AI 실패의 신규 0건 오기록 0건 | Candidate·AI attempt/result·selection not-run/final result | Ledger/candidate source 불완전은 0건 추정 금지 |
| Discord 미수락의 성공 기록 0건 | Delivery attempt·response evidence·message mapping·acceptance evidence | Recipient receipt는 original 2XX/accepted를 만들지 않음 |
| 중대한 근거 밖 사실 0건 | Quality review와 source analysis/RSS observation | 검토 표본·근거 부족은 위반 0건이 아닌 `not_measurable` |

[FACT] 여섯 Hard Gate는 동일 snapshot의 cutoff 아래에서 각각 `pass`, `fail`, `not_measurable`과 근거·coverage를 출력합니다. 하나의 Gate fail은 다른 Gate 결과를 자동 변경하지 않고, 품질·서비스 metric 통과도 Gate pass를 대신하지 않습니다. 확인된 위반은 표본 부족과 무관하게 해당 Gate `fail`입니다.

[FACT] Duplicate-delivery Gate는 article-bearing mapping의 actual `batch_item` scope만 계산합니다. Batch representative message와 system message는 article delivery 수에 넣지 않고, exact `immediate_resend_authorized`와 원래/재전송 attempt에 연결된 승인된 1회 예외는 의도되지 않은 중복으로 계산하지 않습니다. 예외 연결이나 acceptance mapping이 부족하면 정상 예외로 추정하지 않고 `not_measurable`입니다.

| Time/service 계열 | Source time·subject | 반드시 분리할 시간·범위 |
| --- | --- | --- |
| Batch preparation | Scheduled start와 final result ready | 미실행 batch를 분모에서 조용히 제외 금지 |
| Discord timely acceptance | Scheduled target과 필요한 mapping의 `discord_2xx` | Recipient receipt·recovery·confirmation·조기/1분 이후 acceptance 제외 |
| Current freshness | Scheduled delivery target과 RSS `published` comparable instant | 실제 start/acceptance와 복구 시각으로 재판정 금지 |
| Pipeline delay | Source scheduled start와 original final result의 최초 Discord 2XX | Recovery·receipt confirmation 제외, delayed full result는 original pipeline에 귀속 |
| Recovery delay | Original scheduled delivery와 실제 recovery acceptance | Current batch latency·freshness에 합산 금지 |

[FACT] Scheduled batch ledger completeness가 검증된 경우 미실행 batch는 준비시간 분모에서 제거하지 않고 목표 미달 또는 승인된 진단 의미로 다룹니다. Ledger 완전성 자체가 불명확하면 미실행 수·비율을 추정하지 않고 `not_measurable`입니다. 정확한 Requirement 판정 문구는 WBS-08.G가 source metric을 참조해 출력합니다.

| Feedback/quality 계열 | Evaluation source | 제외·분리 경계 |
| --- | --- | --- |
| Article negative feedback | Cutoff 아래 article mapping·Gateway/REST state reconstruction | Unknown/stale/unmapped를 negative 없음으로 처리 금지 |
| Batch review coverage | Representative mapping과 actual delivery-set item scope의 ✅ state | Failure/confirmation system message, review 없는 delivery 제외 |
| Implicit acceptance | Reviewed actual item, 2XX 또는 valid recipient receipt, 세 negative state의 confirmed absence | 미검토·수락/receipt 없음·상태 불명 article 제외 |
| Missing-article recommendation | Exact case/article/reply와 cutoff 아래 current recommendation | 반복 case/reaction을 logical article 수만큼 중복 계산 금지 |
| Candidate-based important recall | 현재 유효 recommendation이 있는 수집 article의 처리·selection·acceptance | `not_collected`를 recall 분모에 포함 금지 |
| Collection-record missing | Valid exact link의 `not_collected` case | 실제 RSS 원천 누락·중요 article·candidate miss로 확정 금지 |
| RSS fidelity/promotion quality | 선택된 quality review와 source analysis/RSS/selection | Review sample과 aggregate metric 혼합 금지 |

[FACT] Feedback-dependent metric은 mutable `feedback_state` 현재값을 immutable evaluation의 최종 source로 읽지 않습니다. WBS-08.F가 고정한 cutoff·high-watermark·reconciliation reference 아래 Gateway event와 REST snapshot으로 당시 predicate를 재구성하고 late add/remove는 새 evaluation에서만 반영합니다.

[FACT] Metric output의 값 0은 source scope와 필수 coverage가 완전하고 정의 predicate 결과가 실제 0일 때만 허용합니다. 대상이 정의상 없으면 `not_applicable`, 필수 source가 부족하면 `not_measurable`, 원인·상태를 판정할 수 없으면 `unknown` 또는 명시된 exclusion reason을 사용합니다. 실제 physical value/code는 WBS-04.D·08.G 전 확정하지 않습니다.

[FACT] Metric definition의 predicate·분모·제외·단위·정밀도·source-kind interpretation이 바뀌면 새 definition version이 필요합니다. 새 version은 새 evaluation에만 적용하고 과거 snapshot/result를 update하거나 새 정의로 소급 해석하지 않습니다.

[FACT] MVP-A는 candidate·attempt·feedback·recovery마다 별도의 상시 metric source record를 만들지 않습니다. WBS-20의 운영 query는 source record를 읽어 현재 진단을 제공하고, WBS-22의 evaluation은 성공 snapshot 아래 typed `evaluation_result`만 보존합니다. 새로운 `metric_event`, `evaluation_run` 또는 월별 Insight entity를 제안하지 않습니다.

[INFERENCE] WBS-08.E verification catalog는 정상·실제 0·분모 0·source gap·retry/replay·physical split·partial acceptance·recipient receipt·one-time resend·feedback add/remove·late event·missing link·비용 evidence 부족·복수 Gate 위반 fixture마다 수동 expected numerator/denominator/exclusion/status와 WBS-23·25~26 owner를 연결해야 합니다.

[INFERENCE] WBS-08.E 완료 조건은 telemetry-only metric, missing→zero/pass, attempt/message/logical-result 중복, 대표 mapping의 article 전달 집계, 승인 resend의 false violation, 무승인 resend의 누락, receipt→2XX/정시, mutable feedback 기반 과거 변경, not-collected→recall, 미검토→implicit acceptance, 비용/quality evidence gap의 false pass와 정의 변경의 과거 결과 update가 WBS-20·22·23·25~26 fixture에서 각각 0건인 것입니다.

[UNKNOWN] 실제 metric ID/name, definition registry·physical type, SQL/query/module, ratio/duration precision·rounding, validation-period selection, quality sample/reviewer/rubric, operational display와 report layout은 WBS-04.D·08.F~G·20·22·25~26 전 확정되지 않습니다. 이 review contract의 승인은 실제 산식 코드·SQL·dashboard·metric 수치나 새로운 data entity를 승인한 것이 아닙니다.

#### WBS-08.F — Evaluation work·scope·snapshot 상세 checkpoint

[FACT] 관련 Requirement는 FR-024, NFR-REL-001~002, NFR-DQ-002, NFR-OBS-001~002, NFR-TIME-001, DR-013, VR-001, VR-006~010, VR-014이고, 관련 Decision은 AD-03·05·11~12·23, DDI-04~05·08, MIN-02·05입니다. 선행 계획은 WBS-05·07.D~E·08.A·08.E이며, physical realization과 검증 owner는 WBS-04.D·19.A·22·24~25·30입니다.

| Checkpoint | 승인된 계획 경계 | 후속 owner·검증 |
| --- | --- | --- |
| WBS-08.F-PC-01 | Evaluation은 사용자의 명시적 요청으로만 시작하고 batch별·일별·late evidence 기반 자동 evaluation을 만들지 않음 | WBS-22·24~25 |
| WBS-08.F-PC-02 | 같은 request identity의 replay는 하나의 logical evaluation work로 수렴 | WBS-04.D·05·22·24 |
| WBS-08.F-PC-03 | 같은 scope·cutoff라도 새로운 명시적 사용자 요청은 새 work·attempt·immutable snapshot을 생성 | WBS-05·22·24~25 |
| WBS-08.F-PC-04 | 단일 batch·Asia/Seoul 하루·검증 기간의 입력 검증과 허용 interpretation을 분리 | WBS-04.D·22·25~26 |
| WBS-08.F-PC-05 | Feedback 지표 직전 필요한 reconciliation은 bounded internal request로 handoff하고 evaluation runner가 Discord REST를 직접 호출하지 않음 | WBS-07.E·19.A·22·24 |
| WBS-08.F-PC-06 | Reconciliation 차단·실패·불확실성을 feedback 없음·실제 0·Hard Gate `pass`로 변환하지 않음 | WBS-19.A·22·25~26 |
| WBS-08.F-PC-07 | `as_of_at`, source별 high-watermark와 고정 reconciliation reference를 함께 고정 | WBS-04.D·22·24~25 |
| WBS-08.F-PC-08 | Compact manifest는 source kind·projection/order scheme·선택 행 수·digest를 보존하고 payload·전체 source ID 목록을 복사하지 않음 | WBS-04.D·22·25 |
| WBS-08.F-PC-09 | Source read의 일관성과 snapshot·manifest·typed result의 원자적 확정을 physical design 입력으로 전달 | WBS-04.D·05·22·24~25 |
| WBS-08.F-PC-10 | 실패 attempt는 성공 snapshot을 생성하지 않고 retry는 같은 logical work 아래 새 attempt로 기록 | WBS-05·22·24 |
| WBS-08.F-PC-11 | 요청 validation 오류, evaluation 실행 실패, source 불완전의 `not_measurable`, 정의상 대상 없음과 실제 측정값 0을 분리 | WBS-08.E·22·25~26 |
| WBS-08.F-PC-12 | Late evidence·새 reconciliation·definition 변경은 기존 snapshot을 수정하지 않고 새 사용자 요청 evaluation에서만 반영 | WBS-22·24~25 |
| WBS-08.F-PC-13 | Evaluation runner에 외부 credential·직접 REST 호출·source domain state mutation 권한을 부여하지 않음 | WBS-03·11·22·23~24 |
| WBS-08.F-PC-14 | 같은 입력의 새 evaluation은 source별 행 수·digest·result 비교 가능성을 보고하고 retention 뒤 row-level 재계산 가능 여부를 별도 표시 | WBS-22·25~26 |

[FACT] 단일 예정 batch scope는 지정한 `scheduled_batch` ID 하나와 그 evidence 범위만 읽고 장애·지연·전달 진단만 출력합니다. Asia/Seoul 하루 scope는 그 날의 예정 batch ID 두 개를 명시적으로 포함하며 미실행 slot을 범위에서 조용히 제거하지 않습니다. 두 scope 모두 MVP-A 품질 통과·실패를 표기하지 않습니다.

[FACT] 검증 기간 scope는 명시된 batch 범위 또는 ID와 기간 끝 `as_of_at`을 사용합니다. 이 scope만 최소 2주·20개 예정 batch·50개 후보와 최대 4주 `판정 불충분` 경계를 적용하고, sample adequacy·Hard Gate·품질·서비스 결과를 함께 읽어 MVP-A 품질 검증 통과 후보 여부를 해석할 수 있습니다.

[INFERENCE] Evaluation logical request는 최소한 사용자 request identity, scope kind, 정확한 batch ID 또는 기간 선택, 요청한 metric definition version과 input manifest scheme을 구분할 수 있어야 합니다. 동일 request identity의 전달 replay는 중복 work·snapshot을 만들지 않지만, 사용자가 다시 명시한 별도 request는 같은 scope·cutoff라도 새 logical work와 새 snapshot을 만듭니다. 실제 key field·constraint는 WBS-04.D 전 [UNKNOWN]입니다.

[FACT] Evaluation 실행·실패·retry는 `work_item(type=evaluation)`과 append-only `work_attempt`로 기록하며 별도 canonical `evaluation_run`을 만들지 않습니다. 실패 attempt는 성공한 `evaluation_snapshot`이나 부분 성공 typed result를 공개하지 않고, retry는 같은 logical work 아래 새 attempt로 기록합니다. 성공 attempt 하나만 compact input manifest·immutable snapshot·그 아래 typed results를 완전하게 연결합니다.

[INFERENCE] Request validation은 존재하지 않는 batch, scope와 batch ID 불일치, 필요한 version 누락, 허용되지 않은 해석 요청을 source 부족과 구분해 실행 전 거부해야 합니다. 유효한 scope 안에서 evidence가 부족하거나 아직 확인되지 않은 경우에는 실제 0이나 실행 성공으로 추정하지 않고 지표별 `not_measurable` 또는 승인된 exclusion reason을 출력합니다. 미래·진행 중 기간을 허용할 정확한 규칙과 physical status code는 WBS-04.D·08.G·22 전 [UNKNOWN]입니다.

[FACT] Feedback 의존 metric에 reconciliation이 필요하면 evaluation request-admission 단계가 calculation attempt를 시작하기 전에 exact scope를 확정하고 WBS-07.E 소유의 bounded reconciliation request를 내부 handoff로 등록합니다. Evaluation runner 자체는 request를 임의 확대하거나 Discord REST를 호출하거나 feedback state를 수정하지 않으며, 실제 REST는 WBS-19.A의 claim·gate·실행 경계만 사용합니다. Reconciliation이 차단·실패하거나 외부 효과가 불확실하면 이를 우회 호출하지 않고 사용 가능한 고정 reference 또는 대조 불가 사유를 manifest에 연결하며 feedback 의존 결과를 0·반응 없음·`pass`로 바꾸지 않습니다.

[FACT] 사용자가 고정한 `as_of_at`보다 뒤에 관측·저장된 reconciliation snapshot은 외부 상태의 대상 시각이 더 과거라고 추정되더라도 그 evaluation 입력에 소급 포함하지 않습니다. 해당 cutoff 아래 충분한 feedback evidence가 없으면 관련 결과를 `not_measurable` 또는 승인된 제외 사유로 보존하며, 이후 reconciliation을 반영하려면 사용자가 새 cutoff를 명시한 새 evaluation을 요청해야 합니다. Request admission은 사용자가 지정한 cutoff를 자동으로 뒤로 이동시키지 않습니다.

[FACT] `as_of_at`은 의미상 관측 cutoff이고 source별 high-watermark 또는 reconciliation fixed reference는 실제로 읽힌 source 범위를 고정합니다. 외부 발생 시각이 `as_of_at` 이전이더라도 해당 high-watermark 뒤에 저장된 late event는 기존 snapshot에 들어가지 않으며, 반영하려면 새 사용자 request가 새 manifest·attempt·snapshot을 생성해야 합니다.

[INFERENCE] Source별 high-watermark와 선택 행 범위는 서로 모순되지 않는 consistent read에서 확정하고, 성공 attempt의 manifest·snapshot·typed result는 부분 공개가 불가능하도록 원자적으로 finalize해야 합니다. 실제 transaction isolation, lock·snapshot 방식과 물리 제약은 WBS-04.D·05에서 승인할 [UNKNOWN]이며 이번 계획 승인으로 SQL transaction 설계를 확정하지 않습니다.

[FACT] Compact input manifest는 대상 scope·batch ID, `as_of_at`, 성공 work attempt, `metric_definition_version`, `input_manifest_scheme_version`과 source별 kind·high-watermark/fixed reference·선택 input 행 수·deterministic digest를 포함합니다. `input_manifest_scheme_version`은 선택 projection과 canonical ordering의 해석을 구분하며 원본 RSS·AI·delivery·feedback payload 또는 전체 원본 ID 목록을 복사하지 않습니다.

[FACT] 원본 행이 이용 가능한 동안 같은 scope·cutoff·definition·manifest scheme의 새 evaluation은 source별 선택 행 수·digest·result를 이전 snapshot과 대조할 수 있습니다. 미래 retention으로 원본 행이 정리되면 기존 manifest·result는 보존하되 row-level 재계산 가능 여부를 별도 보고하고 payload나 전체 ID 목록 복제로 retention을 우회하지 않습니다.

[INFERENCE] WBS-08.F verification catalog는 같은 request replay, 같은 scope의 새 request, concurrent duplicate request, 세 scope의 허용·금지 interpretation, 미실행 day slot, invalid scope, reconciliation 성공·차단·실패, late event, torn-read 방지, attempt 실패·retry·partial finalize, source gap·실제 0, definition·scheme 변경과 retention 뒤 재계산 불가 fixture를 포함해야 합니다.

[INFERENCE] WBS-08.F 완료 기준은 자동 evaluation 0건, 동일 request의 중복 logical work·snapshot 0건, 성공 전 부분 snapshot/result 공개 0건, evaluation runner의 직접 외부 호출·source mutation 0건, late evidence의 기존 snapshot 소급 변경 0건, payload·전체 ID manifest 복제 0건이며, 각 성공 snapshot이 재현성 확인에 필요한 compact manifest와 typed result를 완전하게 참조하는 것입니다.

[UNKNOWN] 실제 request key field, digest 알고리즘·canonical serialization, transaction isolation, 날짜·기간 입력 UI/command, 진행 중 범위 허용 규칙, 최대 입력 행·실행 시간·memory budget과 report layout은 WBS-04.D·08.G·22·25~26 전 확정되지 않습니다. 이 checkpoint 승인은 실제 evaluation code·SQL·digest 값·Discord 호출 또는 새 entity를 승인한 것이 아닙니다.

#### WBS-08.G — Typed result·Hard Gate·report 상세 checkpoint

[FACT] 관련 Requirement는 FR-024, NFR-PERF-001, NFR-LAT-001~002, NFR-COST-001, NFR-DQ-001~002, NFR-OBS-001~002, NFR-TIME-001, DR-013, VR-001, VR-006~010, VR-014이고, 관련 Decision은 AD-23, DDI-04·08, MIN-02입니다. 선행 계획은 WBS-08.E~F이며 physical realization과 검증 owner는 WBS-04.D·22·25~26·30입니다.

| Checkpoint | 승인된 계획 경계 | 후속 owner·검증 |
| --- | --- | --- |
| WBS-08.G-PC-01 | `sample_adequacy`, `quality_review`, `hard_gate`, `quality_metric`, `service_metric`, `final_interpretation` 외 새 canonical result kind를 만들지 않음 | WBS-04.D·22·23 |
| WBS-08.G-PC-02 | Result의 공통 envelope와 kind-specific payload를 분리하고 의미가 없는 공통 field를 강제하지 않음 | WBS-04.D·22·23 |
| WBS-08.G-PC-03 | Scope·cutoff·definition·manifest는 parent snapshot에서 상속하고 불필요한 반복 저장·상충을 만들지 않음 | WBS-04.D·22·24 |
| WBS-08.G-PC-04 | Evaluation 실행 성공, 결과 측정 가능, 목표 충족과 Hard Gate 판정을 서로 분리 | WBS-22·25~26 |
| WBS-08.G-PC-05 | 최소 2주·20개 예정 batch·50개 후보를 각각 판정하고 최대 4주에도 부족하면 `판정 불충분`을 유지 | WBS-22·25·30 |
| WBS-08.G-PC-06 | `quality_review`는 선택 표본·기준·판정·이유·source reference만 보존하고 원본 payload를 복사하지 않음 | WBS-22·23·25 |
| WBS-08.G-PC-07 | 필수 review evidence가 없거나 불완전하면 관련 품질 결과를 자동 통과시키거나 다른 AI 판단으로 대체하지 않음 | WBS-22·25·30 |
| WBS-08.G-PC-08 | 비율·품질·서비스 결과에 분자·분모·제외 수·제외 이유·측정 가능 여부와 source reference를 보존 | WBS-04.D·22·25~26 |
| WBS-08.G-PC-09 | 검증 기간 snapshot은 여섯 Hard Gate를 각각 독립 결과로 출력 | WBS-22·25·30 |
| WBS-08.G-PC-10 | Gate별 `fail`·`not_measurable`·`pass` 조건과 승인된 예외를 분리하고 다른 Gate·metric 결과로 대체하지 않음 | WBS-08.E·22·25~26 |
| WBS-08.G-PC-11 | 단일 batch·하루 scope는 운영 진단만 허용하고 MVP-A 전체 통과·실패를 표시하지 않음 | WBS-22·25 |
| WBS-08.G-PC-12 | `final_interpretation`은 표본·Gate·품질·서비스 결과와 복수 판정 불가·차단 사유를 reference | WBS-04.D·22·25·30 |
| WBS-08.G-PC-13 | Report는 canonical typed result의 read-only projection으로 제한하고 별도 산식으로 재계산하지 않음 | WBS-22·25 |
| WBS-08.G-PC-14 | 실패·미달·측정 불가·제외와 각 Gate 결과를 report에서 조용히 제거하지 않음 | WBS-22·25~26·30 |
| WBS-08.G-PC-15 | 통과 후보·미달·판정 불충분 결과가 자동 deployment·MVP-B 진입·프로젝트 종료를 실행하지 않음 | WBS-28~31 |
| WBS-08.G-PC-16 | Golden fixture와 수동 expected result로 typed result·final interpretation·report 일치를 검증 | WBS-23·25~26 |

[FACT] 성공 `evaluation_snapshot` 아래의 typed `evaluation_result`는 승인된 여섯 `result_kind`만 사용합니다. 새로운 상시 metric source, 별도 `evaluation_run`, 종합 판정을 위한 일곱 번째 result kind 또는 월별 Insight entity를 추가하지 않습니다.

[INFERENCE] 모든 result가 논리적으로 공유해야 할 envelope는 parent snapshot reference, `result_kind`, kind별 subject 또는 criterion identity, 측정·판정 상태, 이유와 source evidence reference입니다. 분자·분모·threshold·판정 상세처럼 특정 종류에만 의미가 있는 값은 kind-specific payload로 분리해야 합니다. 실제 field·type·constraint와 확장 저장 형식은 WBS-04.D 전 [UNKNOWN]입니다.

[FACT] Snapshot의 scope·`as_of_at`·input manifest·`metric_definition_version`은 그 아래 result가 상속하는 공통 문맥입니다. Result가 definition version을 포함한다는 논리 계약은 parent snapshot reference로 추적 가능해야 한다는 의미이며, 같은 값을 모든 row에 반복 저장해 서로 다른 version으로 상충시키지 않습니다. 실제 denormalization 필요성은 WBS-04.D에서만 결정합니다.

[FACT] Evaluation attempt의 성공은 고정된 입력으로 계산과 snapshot/result finalize가 완료됐다는 뜻이며 모든 지표가 측정 가능하거나 목표를 충족했다는 뜻이 아닙니다. 성공 snapshot도 source coverage에 따라 `not_measurable`, `not_applicable`, exclusion 또는 목표 미달 결과를 가질 수 있고, 이러한 결과 때문에 성공 work attempt를 실행 실패로 소급 변경하지 않습니다.

[FACT] `sample_adequacy`는 검증 기간의 최소 2주, 최소 20개 예정 batch, 최소 50개 후보를 각각 대조합니다. 최대 4주에도 하나라도 부족하면 전체 품질 결과를 `통과` 또는 `실패`로 추정하지 않고 `판정 불충분`으로 보존하며, 이미 확인된 Hard Gate 위반과 품질·서비스 관측값을 숨기지 않습니다. 하나의 result 내부 표현 또는 세부 row 분할은 WBS-04.D 전 [UNKNOWN]입니다.

[FACT] `quality_review`는 사용자 요청 evaluation에서 선택된 표본 하나와 검토 기준 하나의 판정·이유·source reference를 보존합니다. RSS 충실도는 source analysis와 RSS observation을, 홍보성 오선정·누락 검토는 source selection·analysis·article을 연결하며 원본 RSS·AI payload를 복사하지 않습니다. 모든 article에 지속적으로 review result를 생성하지 않고 재검토는 새 snapshot 아래 새 result로 기록합니다.

[UNKNOWN] Quality sample 추출, reviewer identity, rubric·rubric version, 수동 검토 입력·승인 방식과 자동·수동 평가 비율은 후속 검증 대상입니다. 필수 review evidence가 없거나 불완전한 상태를 통과로 추정하거나 승인되지 않은 AI provider 판단으로 대신하지 않습니다.

[FACT] `quality_metric`과 `service_metric`은 승인된 logical subject 기준으로 분자·분모, 제외 수와 이유, 측정 가능 여부, 단위·목표 대조와 source evidence reference를 제공합니다. Hard Gate의 `pass`·`fail`·`not_measurable` 상태를 모든 metric에 기계적으로 재사용하지 않고 목표 충족·미달, 실제 값 0, 정의상 해당 없음과 evidence 부족을 구분합니다. 실제 상태 code·수치 type·rounding은 WBS-04.D·22·26 전 [UNKNOWN]입니다.

[FACT] 검증 기간의 성공 snapshot은 추가 월 비용·유료 호출·유료 자원, 미처리 후보 조용한 제외, 의도되지 않은 동일 기사 중복 전달, AI 실패의 정상 신규 0건 오기록, Discord 미수락의 성공 오기록, 중대한 RSS 근거 밖 사실의 여섯 Hard Gate를 snapshot×Gate identity별로 각각 독립 평가합니다. 실제 uniqueness constraint는 WBS-04.D 전 [UNKNOWN]입니다.

[FACT] 같은 Gate의 확인된 logical violation이 하나 이상이면 표본 부족과 무관하게 해당 Gate는 `fail`입니다. 필수 evidence의 범위·연결·완전성이 부족하거나 불명확하면 `not_measurable`이고, 승인 범위가 완전하며 위반이 0건일 때만 `pass`입니다. 한 Gate나 품질·서비스 metric의 결과는 다른 Gate 판정을 자동 변경하거나 대신하지 않습니다.

[FACT] 의도되지 않은 중복 전달 Gate는 승인된 exact `못 받음` 기반 1회 즉시 재전송과 batch representative/system message를 article 중복으로 계산하지 않습니다. Recipient-observed receipt는 원래 Discord 2XX·정시 수락을 만들지 않고, feedback의 `unknown`·`stale`·`unmapped`와 source 누락은 반응 없음·실제 0·Gate `pass`로 바꾸지 않습니다.

[FACT] 단일 예정 batch와 Asia/Seoul 하루 scope의 `final_interpretation`은 `interpretation_level=운영 진단` 의미만 출력하고 MVP-A 전체 품질 통과·실패를 만들지 않습니다. Scope에 적용 가능한 Gate·quality·service 관측을 진단으로 표시할 수 있지만 검증 기간의 여섯 Gate completeness 또는 품질 검증 결론을 대신하지 않습니다. 실제 code는 WBS-04.D·22 전 [UNKNOWN]입니다.

[FACT] 검증 기간 scope의 `final_interpretation`만 최소 표본·여섯 Hard Gate·승인된 품질·서비스 목표를 함께 reference해 MVP-A 품질 검증 통과 후보 여부를 해석합니다. 표본 부족과 확인된 Gate 위반이 함께 있으면 `판정 불충분`과 Gate `fail`을 모두 보존하며 어느 하나로 다른 evidence를 숨기지 않습니다. 모든 조건을 충족한 결과도 통과 확정이 아니라 사용자 검토 대상인 통과 후보입니다.

[FACT] 품질 또는 서비스 목표 미달은 원인과 개선·추가 검증 대상으로 남기며 자동으로 프로젝트를 종료하지 않습니다. 통과 후보도 deployment·MVP-B를 자동 시작하지 않고 WBS-28~31의 별도 사용자 승인 경계를 따릅니다.

[INFERENCE] Evaluation report는 별도 정본이나 재계산 계층이 아니라 하나의 immutable snapshot과 그 typed results를 읽는 projection/export여야 합니다. Scope·cutoff·definition·manifest scheme·row-level 재계산 가능 여부, sample adequacy, 여섯 Gate, 품질·서비스 결과, 분자·분모·제외·측정 불가 사유와 final interpretation을 source result와 다르게 재판정하거나 실패 항목을 생략하지 않습니다.

[INFERENCE] WBS-08.G verification catalog는 여섯 result kind 허용, unknown kind 거부, snapshot 공통 문맥 상속, 실행 성공+`not_measurable`, 세 표본 기준의 독립 경계, 4주 판정 불충분, review 부족, 실제 0·분모 0·제외, Gate 0/1 violation·coverage gap·복수 Gate 위반, 승인 resend 예외, batch/day 금지 결론, 품질·서비스 미달, 복수 blocker와 report 누락·재계산 fixture를 포함해야 합니다.

[INFERENCE] WBS-08.G 완료 기준은 승인되지 않은 result kind 0건, 공통 snapshot 문맥 상충 0건, source gap의 false zero/pass 0건, Gate 간 판정 전파 0건, batch/day 전체 품질 결론 0건, report의 canonical result 재계산·누락 0건과 fixture별 typed result·final interpretation·report의 수동 expected 결과 일치입니다.

[UNKNOWN] 실제 result key·field·value encoding·conclusion code, reviewer/rubric·sample selection, threshold registry, ratio/duration precision·rounding, report 파일 형식·CLI 표시·저장 위치와 dashboard/alert 연동은 WBS-04.D·22·25~26 전 확정되지 않습니다. 이 checkpoint 승인은 실제 산식 code·SQL·report UI·dashboard 또는 외부 전송을 승인한 것이 아닙니다.

#### WBS-08.A~G Consistency Review

[FACT] WBS-08.A~G의 source ownership, runtime/evaluation gate, backup/restore recovery, metric definition, evaluation request·snapshot·typed result와 후속 owner를 교차 검토했습니다. 이 consistency 승인은 승인된 Product Specification·99개 Requirement·Architecture·Logical Data/Interface Design을 변경하지 않고 Implementation Plan의 누락·모호한 handoff·traceability를 정리한 것입니다.

| 연결 구간 | 일관된 owner·handoff | 금지되는 결합 |
| --- | --- | --- |
| 08.A → 08.E | PostgreSQL domain/evidence가 source of truth이고 metric catalog가 read-only lineage를 정의 | Telemetry·dashboard·alert가 성공·수량·Gate 정본 생성 |
| 08.B → runtime gate | 사전 contract/configuration/cost evidence가 앞으로의 비용 가능 invocation을 통제 | 월별 결과 미존재만으로 자동 pause 또는 비용 안전 추정 |
| 08.B → 08.E~G | 사용자가 직접 확인한 기간·scope별 billing/usage evidence를 비용 metric·Gate가 읽음 | 자동 billing API, invoice 원문 저장, coverage 없는 비용 `pass` |
| 08.C → 08.D | Backup run·artifact·integrity와 restore validation·RPO/RTO·resume evidence를 분리 | Artifact 생성·exit 0을 restoreability·resume로 승격 |
| 08.D → 07.E·19.A | DB trust 뒤 별도 승인된 exact feedback reconciliation만 제한적으로 실행 | REST feedback snapshot으로 delivery acceptance 생성 또는 general outbound resume |
| 08.E → 08.F | Metric 의미·source lineage version을 evaluation request가 선택하고 manifest가 실제 읽은 source 범위를 고정 | 현재 mutable projection이나 telemetry로 과거 입력 대체 |
| 08.F request admission → 07.E·19.A | Feedback 의존 scope가 필요할 때 calculation 전 bounded request를 handoff하고 terminal reference를 기다림 | Evaluation runner의 직접 REST·feedback mutation, calculation 중 외부-effect 시작 |
| 08.F → 08.G | 성공 attempt의 immutable snapshot과 compact manifest 아래 typed result만 finalize | 실패 attempt의 부분 snapshot/result, 기존 snapshot update |
| 08.G → report·WBS-30 | Canonical typed result를 read-only projection하고 사용자에게 모든 Gate·미달·측정 불가를 표시 | Report 재계산, 실패 숨김, 자동 deployment·MVP-B·프로젝트 종료 |

[FACT] Evaluation request admission은 새 application role이나 service가 아닙니다. 동일 Python code/image의 명시적 사용자 command가 evaluation work를 등록하는 내부 경계이며, 필요한 feedback reconciliation request도 calculation attempt 전에 WBS-07.E의 exact scope로만 handoff합니다. 외부 REST invocation은 계속 WBS-19.A가 단독 소유합니다.

[FACT] Evaluation이 고정한 `as_of_at`보다 뒤에 저장·관측된 Gateway event 또는 REST snapshot은 기존 input manifest에 포함하지 않습니다. Post-cutoff reconciliation을 반영하려면 사용자가 더 늦은 cutoff의 새 evaluation을 요청해야 하며, 기존 cutoff 아래 필수 feedback evidence가 부족하면 `not_measurable` 또는 승인된 제외 사유로 남깁니다.

| Version owner | 변경을 요구하는 내용 | 다른 version만으로 대신할 수 없는 것 |
| --- | --- | --- |
| `metric_definition_version` | Predicate, logical subject, scope/time 의미, numerator/denominator, exclusion/exception, unit·precision·threshold, source-kind interpretation | Projection·canonical ordering·digest 입력 형식만의 변경 |
| `input_manifest_scheme_version` | Source kind별 선택 projection, canonical ordering, row selection serialization과 deterministic digest 입력 구성 | Metric 의미·판정 기준 변경 |
| Both | Metric 의미와 source extraction/digest 방식이 함께 변경 | 한 version만 올려 과거 결과와 비교 가능한 것으로 표시 |

[INFERENCE] 두 version 중 하나라도 다르면 새 evaluation은 새 snapshot을 만들고 결과 비교에서 차이를 명시해야 합니다. 기존 snapshot/result를 update하거나 새 definition으로 소급 해석하지 않으며 실제 version ID 형식과 compatibility rule은 WBS-04.D·22 전 [UNKNOWN]입니다.

[FACT] WBS-22의 재현성 대상은 기존 immutable snapshot을 다시 실행하는 것이 아니라 같은 고정 input manifest·metric definition을 사용한 사용자의 새 evaluation입니다. 새 request는 새 work·attempt·snapshot을 생성하고 source별 row count·digest·typed result를 이전 snapshot과 대조합니다.

[FACT] 2~4주 validation period와 사용자 월별 billing 확인의 시간 범위는 서로 자동 일치한다고 가정하지 않습니다. 비용 Hard Gate `pass`는 평가 대상 운영 기간과 모든 비용 가능 scope를 덮는 실제 사용자 billing/usage evidence가 있을 때만 가능하며, 일부 기간·scope가 빠지면 runtime 사전 gate가 유효하더라도 evaluation 비용 Gate는 `not_measurable`입니다. 정확한 billing period 정렬·확인일·coverage 표현은 WBS-08.B·09·30의 [UNKNOWN]입니다.

| Coding Readiness 전 차단 결정 | 결정·승인 owner | 구현·검증 owner | 미결정 시 상태 |
| --- | --- | --- | --- |
| Quality sample selection·rubric·reviewer evidence·manual input 경계 | WBS-08.G 결과를 근거로 WBS-09에서 사용자 승인 | WBS-22·25·30 | Quality evaluation coding 진입 차단 |
| 최소 machine-readable result/report contract와 필수 표시 | WBS-08.G 결과를 근거로 WBS-09에서 사용자 승인 | WBS-22·25 | Runner/report coding 진입 차단 |
| Metric/result physical key·type·constraint·transaction | WBS-04.D·05 승인 | WBS-12·22·24 | Schema/runner coding 진입 차단 |
| Digest·canonical serialization과 version compatibility | WBS-04.D·08.F~G 결과를 근거로 WBS-09 승인 | WBS-22·24~25 | Reproducibility 완료 불가 |
| RPO/RTO·backup interval/gap·storage·retention/cost | SPK-04~06과 WBS-08.C~D 결과를 근거로 사용자 승인 | WBS-21·24·28 | Backup/restore 구현·배포 readiness 차단 |
| Evaluation 기간과 사용자 billing coverage 정렬 | WBS-08.B·G 결과를 근거로 WBS-09·30 승인 | WBS-22·26·30 | 비용 Gate `pass` 불가 |

[INFERENCE] WBS-08 consistency verification은 최소한 source-only/telemetry-only, runtime gate와 historical Gate 분리, backup-created/restoreable 분리, restricted reconciliation/general resume 분리, calculation 전 request handoff, pre/post-cutoff evidence, metric-definition/manifest-scheme 단독·동시 변경, failed attempt·successful `not_measurable`, report canonical-result 일치와 billing partial coverage fixture를 WBS-23~26·30 owner에 연결해야 합니다.

| WBS-08 closure layer | 현재 상태 | 위험이 닫히는 조건 |
| --- | --- | --- |
| Plan 문언·owner·traceability | [FACT] A~G 및 consistency 사용자 승인 반영 | 후속 문서 변경 때 coverage 검사 재실행 |
| External/runtime evidence | [UNKNOWN] | SPK-04~06 pass·사용자 환경/비용 승인 |
| Physical design | [UNKNOWN] | WBS-04.D·05의 key·transaction·constraint·permission 결정 승인 |
| Implementation correctness | [UNKNOWN] | WBS-20~22 구현과 contract/unit test 통과 |
| Fault/E2E/capacity evidence | [UNKNOWN] | WBS-23~26의 실행 결과 통과 |
| Deployment/operational evidence | [UNKNOWN] | WBS-28~30의 별도 승인·실제 관측·evaluation 완료 |

[FACT] 파일 검토와 consistency review는 계획 문서의 owner 누락·시간 순환·재실행 표현·traceability 위험을 줄이지만 실제 external contract, backup failure-domain 독립성, RPO/RTO, 비용 0원, SQL 동시성, 산식 정확성, 운영 장애 위험을 제거하지 않습니다. 남은 위험은 위 closure layer의 실제 evidence가 통과할 때만 닫힙니다.

[INFERENCE] WBS-08 plan-definition 완료 기준은 A~G의 source owner·handoff·금지 경계, 관련 Requirement/Decision과 realization/verification owner, Coding Readiness blocker가 누락 없이 연결되고 Evaluation runner의 직접 외부 호출·운영 source mutation, coverage 없는 false pass, 자동 evaluation·restore·resume·MVP-B 진입 경로가 계획상 0건인 것입니다.

[UNKNOWN] WBS-08 이후에도 실제 observability stack, cost evidence 유효기간, backup 도구·storage·RPO/RTO, metric physical registry, evaluation key·digest·transaction, quality review workflow와 report 형식은 확정되지 않았습니다. WBS-09는 이러한 항목을 기본값으로 숨기지 않고 코드 진입 전 blocker 또는 명시적 비차단 근거로 판정해야 합니다.

### WBS-09 — Coding Readiness Check 상세 checkpoint

[FACT] 관련 범위는 전체 99개 Requirement, 특히 P0-HG 34개와 VR-001·011, AD-01~23, DDI-01~10, MIN-01~08입니다. WBS-09는 Workflow 9에서 미래의 Coding Readiness 실행·판정 절차를 정의하는 계획 Task이며, 이 상세 checkpoint의 승인은 Workflow 10 통과나 production code 구현 승인이 아닙니다.

| ID | Readiness 검토 범위 | 통과 evidence·조건 |
| --- | --- | --- |
| WBS-09.A | Source·Workflow closure | 승인 source 문서, 99개 Requirement/AC/Decision coverage, 승인된 정합성 수정, Workflow 9 문서/context 동기화와 단계 종료 Git commit/push |
| WBS-09.B | External contract·cost | SPK-01~06 실제 dated evidence·독립 판정, 선택 provider·Discord contract·환경/비용 조건의 사용자 승인 |
| WBS-09.C | Physical data·work contract | Schema disposition, key/type/constraint/index, transaction/isolation, work/attempt·lease/fence, migration·rollback 결정 승인 |
| WBS-09.D | Domain·evaluation decision | RSS·AI·selection·Discord·feedback/recovery·backup·metric/evaluation의 blocking policy·contract 승인 |
| WBS-09.E | Test·security·operations | P0-HG negative fixture, Secret/redaction, fault/E2E owner, cost/backup/kill-switch 검증과 evidence location 연결 |
| WBS-09.F | Implementation slice·branch | WBS-10의 시작 commit, branch, 허용 변경, test·rollback·review와 완료/중단 조건 승인 |
| WBS-09.G | Final readiness decision | Blocking check 전부 pass, 비차단 위험 사용자 수용, 최종 `READY`와 WBS-10 진입 승인 |

[FACT] Workflow 9 계획 문구의 순차 승인은 WBS-01~08의 미래 실행 산출물·spike evidence·물리 결정이 완료됐다는 뜻이 아닙니다. 실제 Coding Readiness는 Workflow 9 문서가 승인·동기화·commit/push된 뒤, readiness 준비에서 WBS-01~08에 지정된 필수 산출물과 결정을 실제로 확보한 다음 WBS-09.A~G를 순서대로 판정합니다.

| Final status | 의미 | 허용되는 다음 동작 |
| --- | --- | --- |
| `READY` | 모든 blocking check가 dated evidence로 pass이고 필요한 비차단 위험을 사용자가 명시적으로 수용 | 승인된 WBS-10 branch/slice만 시작 |
| `NOT_READY` | 하나 이상의 blocking check가 fail·blocked·inconclusive·stale·not-run 또는 미승인 | 원인별 owner의 선행 검증·결정만 수행, production code 진입 금지 |

[INFERENCE] `READY_WITH_ACCEPTED_RISK` 같은 별도 우회 상태를 만들지 않습니다. 비차단 위험 수용은 evidence·owner·검증 시점·rollback을 가진 상태에서 사용자가 `READY`를 승인하기 위한 입력이며, blocking check를 통과한 것으로 변환하지 않습니다.

| Blocking category | 차단 대상 | 위험 수용만으로 우회할 수 없는 이유 |
| --- | --- | --- |
| P0-HG contract/evidence | 해당 보장에 의존하는 모든 구현 | 한 건의 위반도 품질 통과 후보 불가 |
| Cost·free-only | 비용 가능 외부 호출·자원·배포 | 추가 월 비용·유료 경로 0건 계약 |
| Secret·credential·permission | 외부 adapter와 배포 identity | 노출·과권한·잘못된 account는 사후 rollback으로 복구 불가 가능 |
| DB integrity·data loss | Schema/migration/work/selection/delivery/evaluation | Identity·증거·중복 방지 손상 가능 |
| External-effect uncertainty | AI·Discord·REST retry/recovery | 중복 호출·전달을 안전하게 추정할 수 없음 |
| Unverified external contract | RSS·AI·Discord·K3s·backup 의존 구현 | Payload·수락·rate/quota·복구 semantics를 기본값으로 정할 수 없음 |
| Physical concurrency contract | Transaction/isolation/lease/fence/finalization | Application-only check로 stale write·중복 외부 효과를 보장할 수 없음 |
| Verification gap | Requirement·Gate expected result가 없는 구현 | 구현 완료 여부를 판정할 수 없음 |
| Scope violation | MVP-B, Kafka·Spark, 외부 원문, 유료/다중 AI 자동 전환 | 승인되지 않은 범위·금지 기술 포함 |

[INFERENCE] 비차단 위험 후보는 안전한 fail-closed 동작이 이미 승인되고 불확실성이 외부 호출·data integrity·Secret·비용·P0-HG 의미를 바꾸지 않으며, exact owner·검증 시점·영향 범위·rollback이 있을 때만 등록합니다. 단순히 구현이 어렵거나 일정이 늦어진다는 이유로 blocking 항목을 비차단으로 낮추지 않습니다.

| Readiness evidence register field | 필수 내용 |
| --- | --- |
| Check ID/category | WBS-09.A~G와 세부 blocking/non-blocking 분류 |
| Requirement/Decision/WBS | 검증하는 상위 계약과 realization·verification owner |
| Required evidence | 통과에 필요한 exact artifact·experiment·review 결과 |
| Evidence location/fingerprint | Repository 경로, commit, dated external evidence 또는 비민감 환경/configuration fingerprint |
| Status | pass·fail·blocked·inconclusive·stale·not-run |
| Blocked scope | 완료하거나 시작할 수 없는 downstream WBS·operation |
| Owner·due/trigger | 결정을 닫을 책임과 재검토 계기; 임의 완료일 약속은 강제하지 않음 |
| Validity/revalidation | 계약·provider·account·configuration·image·runtime 변경과 VR-011 조건 |
| Risk/rollback | 잔존 영향, fail-closed 동작과 되돌림·중단 방법 |
| User approval | 판정·비차단 위험 수용·구현 진입 승인 reference |

[FACT] Evidence가 존재한다는 사실만으로 pass하지 않습니다. Artifact는 source version·환경·적용 configuration과 연결돼야 하고, 변경됐거나 유효성을 확인할 수 없으면 `stale` 또는 `inconclusive`로 판정합니다. 다른 provider·account·환경의 성공 evidence를 승인 대상에 재사용하지 않습니다.

[FACT] 2026-09-10 문서·산출물 확인 기준으로 실제 WBS-09 진입 조건은 `NOT_READY`입니다. SPK-01~06 실행, 외부 계약·provider 선택, PostgreSQL physical design·lease/fencing, K3s/backup/RPO/RTO와 quality review·report·digest 계약의 실제 완료 evidence가 없습니다. 계획 승인·감사 문서 수정은 해당 선행 작업의 완료를 뜻하지 않습니다. Git 확인을 수행하지 않았으므로 현재 commit/push 미완료를 차단 원인으로 단정하지 않습니다.

[FACT] `requirements.md`의 Workflow 8 승인 상태와 `architecture.md`의 NFR 참조 오류는 PLAN-CONSISTENCY-01의 PC-04·05에서 수정된 이력입니다. 현재 문서에는 2026-09-04 최종 승인과 실제 `NFR-OBS-001~002`, `NFR-SEC-001~002` 범위가 반영되어 있으므로 미수정 blocker로 중복 등록하지 않습니다. WBS-09.A의 실제 99개 coverage·source status 검증은 별도 실행해야 합니다.

| WBS-10 branch readiness field | 요구 내용 |
| --- | --- |
| Starting commit | Workflow 9/10 준비 변경이 반영된 검증된 `main` commit |
| Branch scope | Python 실행·테스트 기반만 포함하는 독립 기능/수정 단위 |
| Allowed files/output | Package skeleton, dependency lock, role entry-point skeleton, test harness와 필요한 최소 문서 |
| Prohibited scope | 실제 RSS/AI/Discord 호출, schema migration, K3s deployment, 다른 feature 구현 |
| Test entry | 외부 호출 없는 role import/startup·configuration failure와 기본 unit test 명령 |
| Rollback/review | Branch 폐기 또는 PR revert가 다른 사용자 변경을 되돌리지 않는 범위와 review 기준 |
| User approval | Branch name·scope·starting commit과 구현 시작의 명시적 승인 |

[FACT] WBS-10 branch는 실제 Feature Implementation 변경이므로 AGENTS.md의 branch/PR 규칙을 따릅니다. WBS-09 승인 전에 branch를 생성하거나 package·dependency·test 파일을 만들지 않습니다.

[INFERENCE] WBS-09 verification은 missing/stale evidence, 다른 환경 evidence, P0-HG accepted-risk 오분류, owner 없는 unknown, MVP-B 포함, 금지 기술 포함, branch scope 과다, Workflow 9 uncommitted 상태, 사용자 승인 누락 fixture마다 최종 `NOT_READY`를 기대하고, 모든 blocking pass와 명시적 비차단 위험 승인 fixture에서만 `READY`를 기대해야 합니다.

[INFERENCE] WBS-09 완료 기준은 모든 check가 evidence register에 있고 blocking status가 모두 pass이며, owner 없는 `[UNKNOWN]`·잘못된 Requirement/Decision ID·숨은 MVP-B·금지 기술·미검증 외부 계약·무승인 branch가 0건이고, 사용자가 비차단 위험과 WBS-10 진입을 명시적으로 승인하는 것입니다.

[UNKNOWN] 실제 readiness register 파일·format, 증거 유효기간, 비차단 위험 threshold, WBS-10 branch 이름·starting commit, 최종 test command와 reviewer는 WBS-09 실제 실행 때 확정합니다. 이 계획 승인은 readiness pass·branch 생성·코드·외부 검증·Git commit/push를 승인한 것이 아닙니다.
