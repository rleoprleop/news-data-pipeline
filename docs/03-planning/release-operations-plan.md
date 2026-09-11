# Release and Operations Plan

## Document Guide

[FACT] 2026-09-10 승인된 B안에 따라 [구현 계획](implementation-plan.md)의 해당 본문을 이동했습니다. Workflow 9 계획과 F01~F08 승인 범위는 유지하며 실제 설계 결과·구현·검증·배포 완료를 뜻하지 않습니다. 현재 Task·blocker·다음 작업은 [AI Context](../../ai-context.md)를 참조합니다.

[FACT] WBS 간 참조는 [전체 WBS 안내](implementation-plan.md#work-breakdown-structure), 계획 승인 경위는 [검토 이력](implementation-review-history.md#sequential-review-state)을 참조합니다. Product·Requirement·AD·DDI·MIN의 기존 정본은 변경하지 않습니다.

## Quick Navigation

- [WBS-27 Image·K3s 배포 artifact 준비 상세](#wbs-27-imagek3s-배포-artifact-준비-상세)
- [WBS-28 Deployment Readiness Review 상세](#wbs-28-deployment-readiness-review-상세)
- [WBS-29 단계별 실제 Deployment 상세](#wbs-29-단계별-실제-deployment-상세)
- [WBS-30 Baseline 고정 2~4주 Monitoring·Evaluation 상세](#wbs-30-baseline-고정-24주-monitoringevaluation-상세)
- [WBS-31 Retrospective·MVP-A disposition·MVP-B incremental-entry decision 상세](#wbs-31-retrospectivemvp-a-dispositionmvp-b-incremental-entry-decision-상세)

## Detailed Checkpoints

### WBS-27 Image·K3s 배포 artifact 준비 상세

[FACT] 관련 Requirement는 `FR-024`, `NFR-REL-001~003`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-REC-001`, `NFR-MNT-001`, `NFR-TIME-001`, `VR-001·009·011·013~014·018`이고 Architecture Decision은 `AD-01`, `AD-03`, `AD-06`, `AD-08~10`, `AD-13~16`, `AD-19`, `AD-21~23`, Data / Interface Design Decision은 `DDI-05~06`, `DDI-08~10`, `MIN-02~03`, `MIN-05~07`입니다. 외부 검증은 `SPK-04~06`, 선행 계획·구현·검증은 `WBS-03`, `WBS-08.C~D`, `WBS-10~26`, 후속 readiness·배포는 `WBS-28~29`입니다.

[FACT] WBS-27은 미래 배포 artifact 준비 Task의 작업 경계를 정의합니다. 현재 승인으로 image/build file, Kubernetes manifest, Secret/RBAC/storage, registry artifact, K3s resource를 생성·수정·push·apply하지 않으며 cluster smoke나 운영 활성화를 실행하지 않습니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-27.A | Deploy-input freeze | Source/dependency/schema/config/contract/SPK/evidence 버전·blocker register | WBS-09 actual `READY`와 WBS-10~26 closure·SPK-04~06·승인 입력의 유효성 review |
| WBS-27.B | Reproducible image build boundary | Base/runtime/dependency/build input·command·artifact identity | 동일 승인 입력의 재build 비교·Secret/ambient credential 0건 check |
| WBS-27.C | Digest·SBOM·registry handoff | Immutable digest, SBOM, provenance·registry condition record | Mutable tag 의존·Secret 포함·무승인 signing/push 0건 review |
| WBS-27.D | Runtime-role command mapping | Prepare/Delivery-gate/Recovery/Gateway/manual Evaluation command matrix | 역할 책임 침범·자동 evaluation·미승인 outbound 0건 정적 검사 |
| WBS-27.E | Configuration·Secret·RBAC | 역할별 config/Secret handle·ServiceAccount·permission matrix | Render/image/log의 Secret 0건, cluster-wide/과도 권한 0건 check |
| WBS-27.F | Schedule·concurrency·time | Cron/timezone/overlap/missed-run·DB-idempotency mapping | SPK-04-supported time 표현, 조기 delivery·Kubernetes-only dedupe 가정 0건 review |
| WBS-27.G | PostgreSQL·PV·backup boundary | StatefulSet/PV/storage/reclaim/failure-domain decision register | 싱글 replica 경계, 미승인 default·PVC 삭제 rollback·backup 공통 failure domain 0건 |
| WBS-27.H | Network·resource·security | Role egress, probes, resource/security-context candidate와 environment unknown | 클러스터 미검증 설정의 pass 오판·paid/forbidden egress 0건 review |
| WBS-27.I | Static validation·stop·rollback | Render/schema/dry-run 결과, suspend/stop/rollback package | 정적 검증 범위 표시, DB/PVC 삭제·auto resume·image-only DB rollback 가정 0건 |
| WBS-27.J | WBS-28/29 handoff | Artifact inventory/digest, pending cluster check, external-change approval matrix | Registry push·Secret 등록·cluster apply·smoke·activation의 소유자와 별도 승인점 연결 |

#### WBS-27.A Deploy-input freeze

[FACT] Packaging 입력은 승인 source revision, dependency lock, migration/configuration/contract version, WBS-23~26 test·capacity evidence와 SPK-04~06 결과를 exact reference로 고정합니다. `WBS-09` actual `READY`가 아니거나 선행 evidence가 변경·만료되면 build 후 정상화하지 않고 readiness로 반환합니다.

[INFERENCE] Input register는 source/dependency/runtime/schema/config/contract/SPK/test 버전, target architecture, 생성 도구와 실행 환경, 미확정 항목·owner·expiry를 기록합니다. Build 후 source나 dependency가 바뀌면 기존 digest를 그대로 승인 후보로 유지하지 않습니다.

#### WBS-27.B Reproducible image build boundary

[FACT] 승인 architecture의 하나의 Python codebase/image를 사용하고 실행 역할은 command와 configuration으로 분리합니다. Runtime/base image patch version, dependency locking/build context와 artifact naming은 실제 WBS-27 실행 전 확정합니다.

[INFERENCE] Build context에 VCS metadata, local credential, `.env`, test production data, cache와 불필요한 tool이 포함되지 않는지 검사합니다. Non-root·read-only filesystem 등 security hardening은 dependency/runtime 적합성을 검증한 후 적용하며 실행 전에 통과한 것으로 가정하지 않습니다.

[UNKNOWN] 최종 base image, Python patch, native dependency, multi-architecture 필요성, deterministic rebuild 비교 방식과 builder environment는 WBS-27 실행 승인 전 닫아야 합니다.

#### WBS-27.C Digest·SBOM·registry handoff

[FACT] Deployment identity는 mutable tag가 아닌 immutable image digest입니다. Tag가 있더라도 manifest·evidence·rollback의 정본 식별자로 사용하지 않습니다.

[INFERENCE] Digest에 source/build/dependency input, SBOM, 검증 결과와 생성 시각을 연결합니다. Signing은 승인된 requirement가 아니므로 도구·key·운영비 결정 없이 새로 도입하지 않습니다.

[FACT] Public/private registry 선택, retention, image storage/pull/traffic 비용, visibility, credential, digest preservation이 `NFR-COST-001`·`NFR-SEC-001~002`를 충족한다는 증거와 사용자 승인 없이 push하지 않습니다.

#### WBS-27.D Runtime-role command mapping

| Runtime role | Kubernetes candidate | 허용 책임 | 금지 침범 |
| --- | --- | --- | --- |
| Prepare | CronJob | 09:30/21:30 scheduled batch claim과 commit-driven pipeline 진행 | Delivery target 전 조기 발송, Recovery scope 혼합 |
| Delivery-gate | CronJob | 10:00/22:00에 이미 prepared된 result만 release | RSS/AI/selection 시작·재실행 |
| Recovery/Reconciliation | CronJob | Expired internal work, prepared-no-attempt, confirmation due, explicit REST request 수렴 | External effect uncertain 건 auto recall/resend, current/delayed 혼합 |
| Gateway listener | Deployment | 승인 Gateway event·interaction의 장기 수신 | Scheduler/recovery 소유, 직접 무제한 REST polling |
| Evaluation | Manual Job/command | 사용자 명시 request를 승인 scope로 실행 | 자동 Cron evaluation, source/outbound mutation |

[FACT] 다섯 command는 동일 image digest를 사용하되 ServiceAccount, configuration, network/outbound permission을 역할별로 분리합니다. Gateway replica 수와 session/ordering behavior는 실제 contract·SPK 근거 없이 임의로 확정하지 않습니다.

#### WBS-27.E Configuration·Secret·RBAC

[FACT] Non-secret configuration과 Secret reference/handle를 분리하고 Secret 원문을 image, manifest, ConfigMap, build argument, command line, repository, log, render/dry-run evidence에 기록하지 않습니다. Ambient credential 자동 발견으로 실행을 성공시키지 않습니다.

[INFERENCE] ServiceAccount·Role·RoleBinding은 role/operation/resource/verb/namespace 단위 permission matrix에서 파생하고 cluster-admin, wildcard와 불필요한 Secret list/read를 금지합니다. Application DB credential과 migration/backup/restore/operator credential도 서로 대체하지 않습니다.

[UNKNOWN] K3s Secret encryption-at-rest은 manifest 정적 검사로 증명할 수 없으며 target cluster 설정 evidence를 WBS-28~29에서 확인해야 합니다.

#### WBS-27.F Schedule·concurrency·time

[FACT] Logical schedule은 Asia/Seoul 기준 Prepare `09:30/21:30`, Delivery-gate `10:00/22:00`이며 Delivery-gate는 prepared result만 발송합니다. Cron expression/timezone field는 target K3s version의 `SPK-04` evidence 없이 고정하지 않습니다.

[FACT] Cron overlap/missed start/controller restart의 최종 중복 방지는 Kubernetes scheduling option이 아니라 WBS-13의 canonical batch identity, PostgreSQL claim/lease/fence/idempotency가 담당합니다. Kubernetes policy는 load 억제와 운영 보조수단이며 exactly-once 증거가 아닙니다.

[UNKNOWN] `concurrencyPolicy`, `startingDeadlineSeconds`, Job backoff/deadline/history/TTL·suspend의 실제 값은 failure/recovery 계약, SPK-04 실측과 운영 필요를 검토해 WBS-27 실행 전 승인합니다.

#### WBS-27.G PostgreSQL·PV·backup boundary

[FACT] PostgreSQL은 승인 architecture에 따라 single-replica StatefulSet/PV 경계를 유지합니다. Application 역할·evaluation·backup/restore를 해당 Pod의 임의 side effect로 혼합하지 않습니다.

[UNKNOWN] StorageClass, capacity, access mode, reclaim/retention, node/failure domain, volume permission은 `SPK-04~05`의 실제 환경 evidence와 사용자 승인 전에 default로 확정하지 않습니다. Backup은 primary PV와 별도 failure domain에 있다는 evidence가 필요합니다.

[FACT] Rollback/kill switch는 StatefulSet/PVC 삭제를 포함하지 않으며 image 되돌림으로 migration/data를 자동 되돌릴 수 있다고 가정하지 않습니다. DB 복구와 resume는 WBS-21의 별도 승인 gate를 따릅니다.

#### WBS-27.H Network·resource·security

[INFERENCE] Role별 egress는 PostgreSQL, GeekNews RSS, 승인된 단일 free AI, Discord의 승인 operation에 필요한 범위로 제한하고 paid/alternate provider, 외부 원문 기사, 불필요한 cluster resource로 확장하지 않습니다.

[UNKNOWN] K3s CNI의 NetworkPolicy 지원, DNS/egress 제어, CPU/memory request/limit, probe, securityContext, disruption behavior와 단일 node 제약은 target environment에서 검증해야 합니다. 미확인 값을 보안·용량 pass로 추정하지 않습니다.

#### WBS-27.I Static validation·stop·rollback

[INFERENCE] Static validation은 artifact render, schema/client-side validation, role-command/image digest/config/reference/RBAC/storage/schedule consistency, Secret scan과 prohibited technology/source check를 포함합니다. Actual API server admission·scheduler·CNI·Secret encryption·PV attach·restart·cold start를 검증했다고 표현하지 않습니다.

[FACT] Stop package는 Prepare/Delivery-gate/Recovery CronJob suspend와 Gateway listener 중지 경계를 담고 PostgreSQL/PVC와 evidence를 보존합니다. Pause 이후 in-flight/external-effect uncertainty를 자동 재시도하지 않고 resume는 별도 사용자 승인을 요구합니다.

[INFERENCE] Rollback package는 prior approved digest·manifest/config version, 전제 조건, DB compatibility, 보존 resource와 rollback 후 검증을 명시합니다. Migration incompatibility나 data loss 가능성이 있으면 image rollback을 자동 실행하지 않고 WBS-21/28 판단으로 보냅니다.

#### WBS-27.J Registry·deployment handoff

[FACT] WBS-27 completion은 local/approved build evidence와 deployable candidate package의 완결성이지 registry push, Kubernetes apply, nonproduction/production deployment 성공이 아닙니다. Registry credential 사용·push와 cluster/namespace Secret·RBAC·storage·network·workload 변경은 WBS-28 `READY` 후 WBS-29에서 exact target·scope별 사용자 승인을 받아야 합니다.

[INFERENCE] Handoff matrix는 artifact/digest/version, static result, known unknown, target environment prerequisite, push/apply order, Secret/storage/network/schedule check, nonproduction smoke, activation, stop/rollback owner와 승인점을 연결합니다.

[FACT] SPK-04의 실환경 evidence를 재사용할 때는 target K3s/version/CNI/storage/configuration이 유효한지 확인합니다. Static check나 과거 spike pass를 WBS-29의 실제 cluster smoke 결과로 대체하지 않습니다.

[INFERENCE] WBS-27 완료 기준은 하나의 immutable digest와 role command·config·permission·schedule/storage/stop mapping이 모두 추적되고 mutable tag, Secret 포함, 과도한 RBAC, 자동 evaluation, Delivery-gate pipeline 시작, uncertain recovery 자동 재시도, PVC 삭제 rollback, 무승인 registry push/cluster apply가 각각 0건이며 cluster-dependent check가 WBS-28~29 pending으로 명시되는 것입니다.

[UNKNOWN] Base/runtime/dependency/build tool, target architecture, registry/retention/credential/cost, K3s version/timezone/CNI, namespace, Gateway replica/session, Cron option 값, resource/probe/security context, StorageClass/capacity/reclaim/failure domain, backup schedule/location, image hardening·rebuild 비교, actual manifest 포맷·validation tool은 WBS-09·27~29에서 evidence와 사용자 승인으로 닫아야 합니다. 이 계획 승인은 image/build/push, manifest/Secret/RBAC/storage 생성·적용, cluster smoke, 배포·활성화 또는 비용 발생을 승인한 것이 아닙니다.

### WBS-28 Deployment Readiness Review 상세

[FACT] 관련 범위는 전체 99개 Requirement와 특히 전체 `P0-HG`, `FR-024`, `NFR-REL-001~003`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-DQ-001~002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-REC-001`, `NFR-TIME-001`, `VR-001·009·011·013~019`, Architecture Decision `AD-01~23`, Data / Interface Design Decision `DDI-01~10`, `MIN-01~08`입니다. 선행 evidence owner는 `SPK-01~06`, `WBS-01~27`이고 후속 실환경·운영 검증 owner는 `WBS-29~30`입니다.

[FACT] WBS-28은 미래 Deployment Readiness Review의 실행·판정 계약을 정의합니다. 현재 계획 승인은 WBS-01~27의 실제 완료, `READY`, registry/image/manifest/Secret/storage 생성·push·apply, cluster smoke, Discord/AI 활성화 또는 실제 배포 승인이 아닙니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-28.A | Review baseline·cutoff | Source/digest/schema/manifest/environment/external-contract fingerprint와 review cutoff | 서로 다른 revision/environment evidence 혼합 0건 |
| WBS-28.B | 99개 phase/evidence classification | Requirement별 predeploy/WBS-29 smoke/WBS-30 observation owner·status | 99행 orphan·circular pass·deferred-as-pass 0건 |
| WBS-28.C | Evidence validity·expiry | Evidence date/environment/fingerprint/expiry/revalidation trigger register | Missing/stale/not-run evidence의 pass 0건 |
| WBS-28.D | Artifact·release integrity | Source→dependency→migration/config→image digest/SBOM→manifest chain | Mutable/unapproved/mismatched artifact 0건 |
| WBS-28.E | Target·security·storage readiness | Exact cluster/namespace/registry/Secret/RBAC/network/PV target inventory | Unknown target·Secret exposure·overprivilege·unverified storage pass 0건 |
| WBS-28.F | External contract·cost readiness | RSS/AI/Discord contract fingerprint, free-only gate, cost coverage·user billing plan | Contract drift·paid fallback·cost-scope gap의 `READY` 0건 |
| WBS-28.G | Backup·recovery readiness | Backup/restore/RPO/RTO/loss-window, application/manifest/DB rollback matrix | Restore 미검증·PVC 삭제·image-only DB rollback 가정 0건 |
| WBS-28.H | Observability·runbook·owner | Alert/diagnostic, operator, stop/rollback/manual-resume·response-unavailable plan | Owner 없는 blocker·auto resume·alert-as-domain-evidence 0건 |
| WBS-28.I | Staged deployment·activation plan | Publish→suspended apply→internal/sandbox smoke→activation→observe/stop steps | Apply와 outbound activation 혼합·단계별 승인 누락 0건 |
| WBS-28.J | Risk·final decision | Blocker/accepted-risk/deferred-validation register와 immutable `READY`/`NOT_READY` record | 모든 blocker pass, 비차단 risk 사용자 수용, 별도 WBS-29 실행 승인 경계 |

#### WBS-28.A Review baseline·cutoff

[FACT] Readiness review는 exact source commit, dependency lock, migration/schema/configuration/contract version, image digest/SBOM, manifest package, target-environment fingerprint와 evidence cutoff를 하나의 baseline으로 고정합니다. Draft, local-only 미승인 수정, 다른 digest/cluster/provider의 evidence를 섞지 않습니다.

[INFERENCE] Review record는 reviewer, 일시/timezone, baseline identifiers, input inventory, excluded/stale input, 판정 버전과 후속 owner를 남깁니다. Baseline 이후 영향 있는 변경이 생기면 기존 `READY`를 자동 유지하지 않고 영향 evidence를 재판정합니다.

#### WBS-28.B 99개 phase/evidence classification

[FACT] 99개 Requirement 각 행은 primary realization owner, predeployment verification, WBS-29 smoke, WBS-30 validation-period/operation evidence, decision IDs, status, blocker와 evidence reference를 가집니다. Requirement 본문을 복사하지 않고 ID를 정본으로 연결합니다.

[FACT] Predeploy에서 증명 가능한 보안·비용 안전·contract·data integrity·recovery·artifact 항목과 실제 cluster에서만 확인할 smoke 항목, `2주·20 batch·50 candidate`·actual service/quality·monthly billing처럼 WBS-30에서만 판정 가능한 항목을 분리합니다.

[INFERENCE] WBS-30 owner로 deferred된 Requirement는 WBS-28에서 `pass`가 아니라 planned/not-yet-measurable이며, 측정 방법·source·owner·stop condition이 준비되어야 제한된 validation deployment에 진입할 수 있습니다. Deferred evidence를 WBS-28 통과로 만들지 않습니다.

#### WBS-28.C Evidence validity·expiry

| Evidence state | Readiness 처리 |
| --- | --- |
| `pass` | Exact baseline/environment·required scope와 유효기간을 충족할 때만 사용 |
| `fail` | 해당 blocker의 owner WBS로 반환, `NOT_READY` |
| `blocked` | 계정/권한/환경/결정 owner를 지정하고 `NOT_READY` |
| `inconclusive`/`not_measurable` | 필수 predeploy check이면 `NOT_READY`; 운영 후 항목은 deferred owner를 유지 |
| `stale`/`not-run`/missing | Pass로 추정하지 않고 영향 check 재실행 |

[FACT] Source/image/dependency, migration/schema, manifest/configuration, provider/model/quota/price, Discord application/permission/target, K3s/CNI/StorageClass, registry/backup storage, schedule/timezone, cost condition, runbook/kill switch가 변경하면 관련 evidence의 유효성을 재판정합니다.

[INFERENCE] 실행 일자만으로 evidence 유효성을 판정하지 않고 fingerprint, 환경 동등성, contract revision, coverage와 시간적 변경 가능성을 함께 보고 재검증 trigger와 owner를 남깁니다.

#### WBS-28.D Artifact·release integrity

[FACT] Approved source→dependency lock→migration/configuration/contract→build input→image digest/SBOM→role command→manifest reference의 연속성을 검증합니다. Tag 이름, file name, CI label만으로 동일 artifact라고 판정하지 않습니다.

[FACT] Mutable tag, digest mismatch, 미승인 dependency, 미검증 architecture, Secret/build credential 포함, SBOM 누락, WBS-23~26에서 검증한 artifact와 다른 후보가 하나라도 있으면 해당 artifact를 배포 후보로 승인하지 않습니다.

#### WBS-28.E Target·security·storage readiness

[INFERENCE] Target inventory는 host/cluster identity, K3s/version, namespace, registry/repository, image digest, ServiceAccount/RBAC, Secret handle/source, CNI/network policy, StorageClass/PV/reclaim/failure domain, resource/quota, timezone/scheduler, Discord target·AI project의 exact non-secret identifier를 가집니다.

[FACT] 정확한 target과 사용 권한이 확인되지 않으면 관행적 default, current context, ambient credential, 동일해 보이는 namespace로 추정하지 않고 `NOT_READY`로 판정합니다.

[FACT] Secret 원문은 readiness report에 기록하지 않으며 encryption-at-rest, least privilege, namespace isolation, registry visibility와 PV data protection은 실제 target evidence로 검증해야 합니다. Manifest 정적 pass로 target cluster의 보안을 대체하지 않습니다.

#### WBS-28.F External contract·cost readiness

[FACT] GeekNews RSS, 승인된 단일 free-only AI provider/model/configuration, Discord Gateway/REST/application/permission/target을 SPK-01~03의 유효한 contract fingerprint와 대조합니다. 변경·불일치·미승인 target은 auto fallback이 아니라 blocker입니다.

[FACT] AI, Discord, K3s host/runtime, PostgreSQL/PV, backup storage/transfer, image registry, scheduler/monitoring의 일곱 cost scope와 WBS-11 invocation gate, WBS-20 evidence, SPK-06A/06B, WBS-26 stop result를 대조합니다. Scope가 비어 있거나 paid possibility가 불명하면 0원으로 추정하지 않습니다.

[FACT] 운영월 actual billing/invoice/usage 최종 확인은 사용자가 수행합니다. WBS-28은 확인할 account/project, 기간, scope, 예정 시점, redacted evidence reference와 누락 시 stop owner를 정하며 예정된 확인을 `NFR-COST-001` 최종 pass로 기록하지 않습니다.

#### WBS-28.G Backup·recovery readiness

[FACT] WBS-21/SPK-05의 consistent backup artifact, 별도 failure domain, isolated restore·schema/data/ledger/integrity evidence, 측정 RPO/RTO, loss-window/no-backfill, production restore/restricted reconciliation/manual resume runbook을 exact target와 대조합니다.

[FACT] Application/image rollback, manifest/config rollback, data-preserving forward-fix, PostgreSQL restore를 별도 조건·권한·증거·승인으로 관리합니다. PVC 삭제, destructive down migration, unverified backup overwrite, external effect 재실행을 일반 rollback에 포함하지 않습니다.

[INFERENCE] Production restore를 사전 실행하지 못한다는 이유로 검증을 생략하지 않고 isolated rehearsal, exact tool/version/permission, trigger, expected loss, post-restore validation와 단계별 사용자 승인 경계를 readiness evidence로 사용합니다.

#### WBS-28.H Observability·runbook·owner

[INFERENCE] Runbook set은 deploy verification, schedule/listener status, batch·work·attempt·external evidence diagnostic, cost/quota, Secret/security event, backup gap, failure notice, suspend/stop, rollback, restore/reconciliation, manual resume의 trigger·owner·procedure·expected evidence를 가집니다.

[FACT] Alert/metric은 PostgreSQL domain/evidence의 대체 정본이 아니며 warning 발생만으로 delivery/receipt/feedback/Hard Gate를 판정하지 않습니다. 반대로 alert 미수신을 정상 배치 증거로 사용하지 않습니다.

[FACT] 1인 운영이라도 alert 확인·billing 확인·kill switch·rollback·resume 결정 owner와 확인 주기를 명시합니다. Owner가 대응할 수 없는 기간의 fail-closed/suspend 조건이 없으면 `NOT_READY`로 판정합니다.

#### WBS-28.I Staged deployment·activation plan

| Stage | 허용 변경 | 다음 단계 gate |
| --- | --- | --- |
| 1. Registry publish | 승인 repository에 exact immutable digest push | Digest/SBOM/visibility/cost·pull verification |
| 2. Foundation apply | Exact namespace의 Secret handle/RBAC/network/storage/DB와 suspended workloads | Target/resource/permission/PV·outbound-disabled 확인 |
| 3. Internal smoke | DB/schema, role command, clock/schedule render, listener/internal readiness | 미승인 external invocation 0건·evidence 통과 |
| 4. Bounded sandbox smoke | 사용자가 승인한 RSS/AI/Discord sandbox operation/budget만 | Acceptance/error/cost/stop·no-production-target evidence |
| 5. Activation approval | Exact CronJobs/listener, start time·scope·monitoring owner 승인 | 명시적 사용자 승인 |
| 6. Activation·observe | 승인 workload만 unsuspend/start | Immediate diagnostic·stop/rollback check와 WBS-30 handoff |

[FACT] WBS-28 `READY`는 위 모든 단계를 미리 승인하지 않습니다. Registry push, target resource apply, sandbox external call, production-target activation은 WBS-29에서 exact scope·target·rollback을 제시하고 별도 사용자 승인을 받습니다.

#### WBS-28.J Risk·final decision

| Risk class | 판정 원칙 |
| --- | --- |
| Blocking | 필수 predeploy check fail/blocked/inconclusive/stale/not-run, P0-HG safety violation, 비용·Secret·data-loss·external-effect 불분명, owner 없는 unknown이며 수용으로 우회 불가 |
| Non-blocking accepted risk | 영향·trigger·owner·detection·stop/rollback·expiry가 명확하고 Requirement/Hard Gate를 완화하지 않을 때만 사용자 수용 가능 |
| Deferred validation | WBS-29/30에서만 측정 가능하며 method·owner·sample/cutoff·failure stop·evidence destination이 준비된 항목 |

[FACT] Final status는 `READY` 또는 `NOT_READY`만 사용합니다. `READY_WITH_ACCEPTED_RISK`, partial ready, conditional pass 같은 blocker 우회 상태를 새로 만들지 않습니다.

[FACT] `READY`는 모든 predeploy blocker의 dated evidence pass, baseline/target 일치, 99개 Requirement phase owner·evidence coverage, owner 없는 unknown 0건, 비차단 risk의 사용자 수용을 모두 요구합니다. `READY`는 WBS-29 실행을 자동 시작하지 않고 별도 배포 승인 요청을 열어 줍니다.

[FACT] WBS-28 통과는 MVP-A product validation, 2주·20 batch·50 candidate, 95% service objective, quality target, 운영월 0원 Hard Gate 통과가 아닙니다. 이 결과들은 WBS-29~30에서 실제 evidence로 별도 판정합니다.

[INFERENCE] WBS-28 completion은 99개 Requirement의 phase/evidence orphan, stale/mismatched evidence pass, blocking risk acceptance, deferred-as-pass, mutable artifact/target ambiguity, cost scope gap, restore/owner/runbook gap, apply/activation 혼합, `READY`의 auto-deploy/MVP-A pass 오해가 각각 0건이고 final decision·제한·WBS-29 별도 승인점이 재현 가능하게 기록되는 것입니다.

[UNKNOWN] Actual source/digest/schema/manifest baseline, evidence expiry, target cluster/namespace/registry, Secret/RBAC/CNI/storage, provider/model·Discord target, runtime resource/schedule, backup/RPO/RTO, operator/response window, sandbox budget, deployment/activation window, accepted risk와 WBS-30 measurement plan은 WBS-01~30의 실제 실행 evidence와 사용자 승인으로 닫아야 합니다. 이 계획 승인은 actual `READY`, risk acceptance, artifact/target 선택, external change, 배포·활성화 또는 운영 Hard Gate pass를 승인한 것이 아닙니다.

### WBS-29 단계별 실제 Deployment 상세

[FACT] 관련 Requirement는 `FR-024`, `NFR-REL-001~003`, `NFR-PERF-001`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-DQ-002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-REC-001`, `NFR-MNT-001`, `NFR-TIME-001`, `VR-001·009·011·013~019`이고 Architecture Decision은 `AD-01`, `AD-03`, `AD-06`, `AD-08~10`, `AD-13~16`, `AD-19`, `AD-21~23`, Data / Interface Design Decision은 `DDI-05~06`, `DDI-08~10`, `MIN-02~03`, `MIN-05~07`입니다. 선행 evidence owner는 `SPK-01~06`, `WBS-21`, `WBS-27`, 실제 승인 gate는 `WBS-28`, 후속 운영 검증 owner는 `WBS-30`입니다.

[FACT] WBS-29는 미래 Workflow 16의 실제 외부 변경 절차를 정의합니다. 현재 계획 승인은 registry/image/manifest/Secret/RBAC/network/storage/PostgreSQL/K3s resource를 생성·수정·push·apply하거나 RSS/AI/Discord를 호출·활성화하는 승인이 아닙니다. 실제 실행 시 각 단계의 exact target, 명령 또는 변경 artifact, 영향, rollback과 검증을 다시 제시하고 사용자 승인을 받아야 합니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-29.A | Execution baseline·target freeze | Source/digest/manifest/cluster/namespace/contract/cutoff와 승인 matrix | WBS-28 `READY` baseline 일치·default/current-context 추정 0건 |
| WBS-29.B | Preflight·stop readiness | 비용 7개 scope, credential, backup, operator, suspend/rollback preflight | Paid/ambient credential·복구/owner/stop 공백 0건 |
| WBS-29.C | Immutable registry publish | 승인 digest push와 remote digest/visibility/retention/cost evidence | Local-approved-remote digest 불일치·mutable-only reference 0건 |
| WBS-29.D | Foundation apply | Exact namespace의 Secret handle/RBAC/network/storage/PostgreSQL foundation | Secret 원문 evidence·과도 권한·오대상·PVC destructive action 0건 |
| WBS-29.E | Database·migration | Empty/N-1 경로, backup, operator migration, schema/data validation | Application auto-migrate·부분 성공 은폐·image-only DB rollback 0건 |
| WBS-29.F | Inactive workload apply | 동일 digest의 역할별 resource를 suspend/outbound-disabled로 적용 | Cron/worker/listener의 미승인 외부 invocation·과거 slot 실행 0건 |
| WBS-29.G | Internal·sandbox smoke | 내부 K3s/DB/storage/time smoke와 별도 bounded external sandbox smoke | Target·budget·acceptance/error evidence 분리, production effect 0건 |
| WBS-29.H | Activation approval·execution | 첫 허용 slot/cutoff, exact roles/schedule/target/owner와 activation record | 명시적 승인 전 unsuspend/outbound 0건·historical backfill 0건 |
| WBS-29.I | State·stop·rollback | 부분 적용/불확실 상태, stop, rollback, reconciliation handoff evidence | Uncertain auto-retry·PVC 삭제·무승인 restore/resume 0건 |
| WBS-29.J | Immediate observation·WBS-30 handoff | Immutable activation baseline, pending Gate, cost/owner/stop/measurement handoff | Pod-running-only 성공 오판·관측 시작점/분모/owner 공백 0건 |

#### WBS-29.A Execution baseline·target freeze

[FACT] 실행 baseline은 WBS-28에서 `READY`로 승인된 source commit, dependency/migration/configuration/contract version, image digest/SBOM, manifest package와 evidence cutoff입니다. 실행 직전 이 중 하나라도 달라졌으면 영향 readiness를 다시 판정하며 배포 중 차이를 정상화하지 않습니다.

[INFERENCE] Exact target은 host/cluster identity, Kubernetes context, namespace, registry/repository, image digest, PostgreSQL/PV/StorageClass, Secret handle, ServiceAccount/RBAC, network, provider project/model, Discord application/guild/channel과 schedule timezone을 non-secret identifier로 기록합니다.

[FACT] 현재 context, default namespace, latest tag, ambient credential 또는 유사한 이름의 resource를 목표로 추정하지 않습니다. 각 단계의 변경 대상과 비대상 resource를 함께 확인하고 승인 범위를 벗어난 drift를 발견하면 실행을 중단합니다.

#### WBS-29.B Preflight·stop readiness

[FACT] Registry publish 또는 cluster mutation 전에 AI, Discord, K3s host/runtime, PostgreSQL/PV, backup storage/transfer, image registry, scheduler/monitoring의 일곱 cost scope와 free-only/no-paid-fallback 조건을 다시 확인합니다. 비용 가능성·요금제·quota가 불명확하면 다른 account/provider로 우회하지 않고 차단합니다.

[FACT] Secret 값은 출력·evidence·명령 이력에 보존하지 않으며 승인된 principal이 필요한 exact resource에만 주입합니다. Credential 존재만 확인하지 않고 target/account/scope/expiry/권한과 ambient fallback 차단을 검증합니다.

[INFERENCE] Preflight는 최신 consistent backup과 restore compatibility, operator availability, 단계별 stop/rollback, monitoring/diagnostic 접근, 배포 window, failure communication과 WBS-30 billing 확인 계획을 포함합니다. 하나라도 필수인데 준비되지 않았으면 `blocked` 또는 `not_started`로 남깁니다.

#### WBS-29.C Immutable registry publish

[FACT] Registry에는 WBS-28에서 승인한 exact image만 게시하고 mutable tag를 deployment identity로 사용하지 않습니다. Push 뒤 registry가 반환하거나 조회한 remote digest를 local build·승인 digest와 대조합니다.

[FACT] Repository visibility, retention, credential 노출, image storage/pull/traffic 비용과 SBOM/provenance reference를 검증합니다. Public registry 사용 조건이나 0원 조건이 깨지면 push 또는 후속 pull을 성공으로 간주하지 않습니다.

[INFERENCE] 이미 동일 digest가 존재하면 새 image로 덮어썼다고 표현하지 않고 idempotent publish 확인으로 기록합니다. 다른 digest가 같은 tag에 연결돼 있어도 승인 artifact로 대체하지 않으며 manifest는 digest를 고정합니다.

#### WBS-29.D Foundation apply

[FACT] Foundation 변경은 exact namespace, role별 ServiceAccount/RBAC, Secret reference, configuration, network boundary, PostgreSQL StatefulSet/PV와 필요한 service를 workload activation과 분리해 적용합니다. Cluster-wide wildcard 권한이나 다른 namespace mutation은 승인 범위에 포함하지 않습니다.

[FACT] Secret 원문은 manifest, diff, log와 evidence에 나타나지 않아야 하며 Secret encryption-at-rest와 접근 권한은 실제 target 설정으로 확인합니다. Redacted fingerprint와 resource/key 존재 증거는 값 자체를 대신합니다.

[FACT] StorageClass, capacity, access/reclaim/retention, node/failure domain과 volume permission을 적용 전 승인값과 대조합니다. PVC 삭제·재생성·reclaim 변경처럼 데이터 손실 가능성이 있는 작업은 일반 apply/rollback에 포함하지 않습니다.

#### WBS-29.E Database·migration

[FACT] 대상 DB가 empty baseline인지 기존 N-1 upgrade인지 확인하고 두 경로를 혼합하지 않습니다. Existing DB는 consistent backup과 현재 migration fingerprint를 확인한 뒤 별도 operator 권한과 승인된 migration command로만 변경합니다.

[FACT] Application startup이나 CronJob이 자동 migration하지 않습니다. Migration 전후 version/checksum, lock·duration, row/invariant/data preservation, application compatibility를 검증하고 부분 실패·commit unknown이면 재실행 전에 DB 정본을 조회합니다.

[FACT] Migration 실패 시 image rollback으로 DB가 복원된다고 가정하지 않습니다. Data-preserving forward-fix를 기본으로 하되 production restore 또는 destructive action은 WBS-21 절차와 별도 사용자 승인을 요구합니다.

#### WBS-29.F Inactive workload apply

[FACT] Prepare, Delivery-gate, Recovery CronJob은 suspend 상태로 최초 적용하고 Gateway listener와 외부 outbound도 승인된 비활성 메커니즘으로 차단합니다. Evaluation은 자동 CronJob으로 생성하지 않습니다.

[FACT] 모든 application role은 승인된 동일 immutable image digest를 사용하며 role command, configuration, ServiceAccount와 egress가 WBS-27 mapping과 일치해야 합니다. Delivery-gate가 RSS/AI/selection을 시작하거나 Recovery가 uncertain external effect를 자동 재시도하는 설정은 실패입니다.

[INFERENCE] Resource 생성 직후 Job history, Pod, event, application ledger와 outbound invocation evidence를 대조해 미승인 실행 0건을 확인합니다. Scheduler option만 믿지 않고 PostgreSQL canonical slot/idempotency도 함께 확인합니다.

#### WBS-29.G Internal·sandbox smoke

| Smoke 구간 | 허용 범위 | 금지 오판 |
| --- | --- | --- |
| Internal | Image pull-by-digest, command dispatch, DB/schema, config reference, RBAC, time, PV attach/restart, suspend/outbound gate | Pod Running을 pipeline/외부 계약 성공으로 확장 |
| Bounded RSS/AI | 승인 endpoint/account/model과 call/token/time budget의 최소 operation | 소량 성공을 100건 capacity·운영 quota·0원 최종 pass로 외삽 |
| Discord sandbox | 승인 application/permission/sandbox target의 mapping·acceptance/error operation | Sandbox 2XX를 production target 수락·recipient receipt로 전환 |

[FACT] Internal smoke와 external sandbox smoke는 invocation ledger와 evidence를 분리합니다. Sandbox 전에 exact target, operation, request/token/time budget, stop condition, 예상 외부 effect와 cleanup을 제시하고 별도 승인을 받습니다.

[FACT] Sandbox 실패 시 production target, 다른 provider/account, 유료 호출로 전환하지 않습니다. Failure/timeout/response loss를 정상 0건이나 성공으로 바꾸지 않고 partial/uncertain evidence를 보존합니다.

#### WBS-29.H Activation approval·execution

[INFERENCE] Activation request는 exact digest/configuration, cluster/namespace, 활성화할 role, Cron/timezone, Gateway target, 첫 허용 scheduled slot, activation cutoff, operator/monitoring window, expected outbound와 stop/rollback 조건을 포함합니다.

[FACT] 명시적 사용자 승인 전에는 CronJob을 unsuspend하거나 Gateway/outbound를 활성화하지 않습니다. Foundation apply 또는 smoke 승인으로 activation 승인을 대체하지 않습니다.

[FACT] Activation 이전의 scheduled slot을 RSS/AI/selection/Discord pipeline으로 소급 실행하지 않습니다. 첫 허용 slot 전 과거 기록은 historical-ledger-only 원칙을 유지하고, `startingDeadlineSeconds`나 manual Job으로 backfill하지 않습니다.

[INFERENCE] 역할별 activation과 확인을 가능한 작은 단계로 수행하며 한 단계가 실패·불명확하면 나머지 activation을 자동 계속하지 않습니다. 이미 발생한 외부 effect가 불명확한 상태에서는 rollback 뒤 자동 재호출하지 않습니다.

#### WBS-29.I State·stop·rollback

| Deployment state | 의미·후속 |
| --- | --- |
| `not_started` | 외부 변경 전, 선행 승인 또는 preflight 대기 |
| `blocked` | Target/비용/credential/backup/owner 조건 부족, 변경 금지 |
| `partially_applied` | 일부 resource만 변경됨; exact inventory와 외부 effect를 대조 |
| `deployed_inactive` | Foundation/workload가 적용됐으나 outbound는 중지됨 |
| `smoke_failed` | 실패 evidence 보존 후 관련 owner WBS로 반환 |
| `ready_for_activation` | 필수 smoke 통과, 아직 외부 효과 활성화 승인 전 |
| `activated_monitoring` | 별도 승인 activation 완료, WBS-30 baseline 관측 시작 |
| `stopped` | 신규 work/outbound 중지, DB/PV/evidence 보존 |
| `rollback_required` | 승인 rollback 계획과 별도 위험 검토 필요 |
| `external_effect_uncertain` | 호출 수락/commit 결과 불명확, 자동 재시도·재발송 금지 |

[FACT] Stop은 신규 scheduling/claim/outbound를 차단하되 이미 발생했거나 불명확한 외부 effect를 삭제하지 않습니다. Cron suspend, listener/outbound 중지와 in-flight reconciliation을 분리하고 자동 resume하지 않습니다.

[FACT] Rollback은 application/image, manifest/configuration, migration/DB restore를 분리합니다. PostgreSQL StatefulSet/PVC 삭제, destructive down migration, unverified restore, Discord 자동 재발송은 일반 rollback 경로가 아닙니다.

#### WBS-29.J Immediate observation·WBS-30 handoff

[INFERENCE] Handoff는 activation time/timezone, 첫 허용 slot, source/digest/schema/config/contract/target fingerprint, deployment state, applied resource inventory, smoke/activation evidence, open defect/risk, cost scopes와 사용자 billing 기간, operator, stop/rollback과 pending WBS-30 Requirement/Gate owner를 포함합니다.

[FACT] Pod/Job의 Running·Completed 상태만으로 WBS-29를 완료하지 않습니다. 승인된 activation 뒤 expected role/schedule, PostgreSQL ledger/evidence, outbound gate와 즉시 diagnostic을 확인하고 실패·중단·uncertain 구간을 WBS-30 관측 분모에 숨기지 않습니다.

[FACT] WBS-30 측정 시작점은 manifest apply나 image push 시각이 아니라 immutable `activated_monitoring` baseline입니다. Baseline 변경, stop/rollback, configuration/provider/target 변경이 발생하면 관측 구간을 분리하고 기존 기간에 합산하지 않습니다.

[INFERENCE] WBS-29 완료 기준은 WBS-28 baseline/target drift, default context, mutable image, Secret 노출, 무승인/과도 RBAC·destructive storage, application auto-migration, 최초 apply outbound, 과거 slot 소급, sandbox→production/paid fallback, partial/uncertain 자동 성공·재시도, 무승인 activation/restore/resume가 각각 0건이고 실제 상태·변경·rollback·WBS-30 baseline이 완전히 기록되는 것입니다.

[UNKNOWN] Actual registry/cluster/context/namespace/digest, Secret provision method, CNI/RBAC/storage/PostgreSQL/migration 상태, apply tool/options, inactive mechanism, internal/sandbox smoke command와 budget, production Discord/AI target, first slot/activation window, operator, rollback threshold와 WBS-30 start는 WBS-28~30의 실제 evidence와 단계별 사용자 승인으로 닫아야 합니다. 이 계획 승인은 registry push, Kubernetes/DB/Secret mutation, external request, deployment/activation/rollback/restore 또는 비용 발생을 승인한 것이 아닙니다.

### WBS-30 Baseline 고정 2~4주 Monitoring·Evaluation 상세

[FACT] 관련 Requirement는 `FR-017~024`, `NFR-REL-001~003`, `NFR-PERF-001`, `NFR-LAT-001~002`, `NFR-COST-001`, `NFR-DQ-001~002`, `NFR-OBS-001~002`, `NFR-SEC-001~002`, `NFR-TIME-001`, `VR-001·006~010·014~019`이고 Architecture Decision은 `AD-02`, `AD-05`, `AD-08`, `AD-10~12`, `AD-15~16`, `AD-19~23`, Data / Interface Design Decision은 `DDI-04~06`, `DDI-08~10`, `MIN-02~03`, `MIN-05`, `MIN-08`입니다. 상위 설계·구현 owner는 `WBS-08.E~G`, `WBS-20`, `WBS-22`, 검증 owner는 `WBS-25~26`, activation baseline owner는 `WBS-29`, 후속 결정 owner는 `WBS-31`입니다.

[FACT] WBS-30은 미래의 실제 Monitoring·Evaluation Task 경계를 정의합니다. 현재 계획 승인은 운영 관측 기간 시작, evaluation request/실행, Discord REST reconciliation, 사용자 billing 확인, 결과 판정, deployment/configuration 변경 또는 MVP-B 진입을 승인한 것이 아닙니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-30.A | Activation baseline·window | `activated_monitoring` fingerprint, KST start/cutoff, scheduled-slot inventory | Pre-activation/smoke/과거 slot의 운영 표본 포함 0건 |
| WBS-30.B | Evidence completeness | Slot/candidate/attempt/result/delivery/feedback/cost census와 gap register | Failure/not-run/incomplete/unknown의 정상 0·pass 변환 0건 |
| WBS-30.C | Sample adequacy | 2주 AND 20 scheduled batch AND 50 candidate, 최대 4주 판정 | 조기 종료·무한 자동 연장·조건 OR 처리 0건 |
| WBS-30.D | Service·time metrics | 30분 준비, 1분 Discord 수락, 13시간 freshness, pipeline/recovery latency | Source time/분모와 acceptance/receipt/recovery 혼합 0건 |
| WBS-30.E | Six Hard Gates | Gate별 source/coverage와 `pass/fail/not_measurable` typed result | Confirmed violation 은폐·coverage gap의 false pass 0건 |
| WBS-30.F | Quality·feedback·missing | 승인 metric/rubric, feedback cutoff, missing/recommendation lineage와 quality/service 결과 | Gate 상쇄·mutable projection·미검토 0값 처리 0건 |
| WBS-30.G | Cost·user billing | 일곱 scope usage/paid-event/plan evidence와 사용자 monthly billing coverage | 평가 기간 미포괄 billing·미확인 0원의 cost pass 0건 |
| WBS-30.H | Drift·incident·stop | Baseline segment, incident/중단 영향, 재시작/추가 관측 decision | 변경 전후 자동 합산·문제 구간 cherry-pick 제외 0건 |
| WBS-30.I | Explicit evaluation·report | 사용자 request, cutoff/high-watermark/manifest/digest, immutable result/report | 자동 evaluation·late evidence 소급·report 재계산 0건 |
| WBS-30.J | Final interpretation·WBS-31 handoff | Adequacy/Gate/quality/service/cost 독립 결과와 blocker/risk/decision package | 자동 MVP-B/확대/종료 0건·사용자 결과 승인 경계 |

#### WBS-30.A Activation baseline·window

[FACT] 관측 시작점은 registry push, manifest apply, smoke 시작이 아니라 WBS-29가 기록한 immutable `activated_monitoring` 시각입니다. Baseline은 source/image digest, schema/configuration/contract, provider/model/account, Discord target, cluster/namespace, schedule/timezone, cost scope와 operator를 포함합니다.

[INFERENCE] KST 관측 register는 activation instant, 첫 허용 scheduled slot, 최소 2주 cutoff, 최대 4주 cutoff와 그 사이의 09:30·21:30 예정 slot을 사전에 열거합니다. Activation 이전 slot, smoke/test batch와 historical-ledger-only 기록은 운영 표본에서 제외합니다.

[FACT] 관측기간을 유리한 첫 성공 batch부터 다시 시작하거나 실패 직전 기간을 버리지 않습니다. Stop/rollback이나 baseline drift가 있으면 기존 기간을 삭제하지 않고 별도 segment와 사유로 보존합니다.

#### WBS-30.B Evidence completeness

[INFERENCE] 각 예정 slot은 scheduled batch, configuration binding, trigger/start, RSS fetch/raw/parsing, candidate admission·처리 terminal, selection/final result, delivery mapping/attempt/acceptance, feedback/recovery와 operational event를 source identity로 대조합니다.

[FACT] Candidate census는 feed entry, unique new candidate, duplicate/existing observation, candidate-impossible input error와 normal/low-information/unprocessed/terminal outcome을 구분합니다. AI request/retry, Discord physical message/attempt와 logical candidate/result 수를 합산하지 않습니다.

[FACT] 미실행 scheduled batch, source/AI/DB/scheduler failure, evidence gap, partial/incomplete와 cause unknown을 정상 신규 0건으로 기록하지 않습니다. Source completeness가 부족하면 metric을 0이나 pass로 채우지 않고 영향 scope를 `not_measurable` 또는 판정 불충분으로 남깁니다.

#### WBS-30.C Sample adequacy

[FACT] 최소 표본은 활성 baseline 아래에서 `최소 2주 AND 최소 20개 예정 batch AND 최소 50개 candidate`를 모두 충족해야 합니다. 어느 한 조건만 충족해도 평가 적정성을 선언하지 않습니다.

[FACT] 2주 cutoff에 scheduled batch 또는 candidate가 부족하면 같은 baseline에서 최대 4주 cutoff까지만 관측할 수 있습니다. 연장은 표본 부족 보완 목적이며 실패·미달 결과를 희석하기 위한 window 선택으로 사용하지 않습니다.

[FACT] 최대 4주에도 하나 이상의 최소 조건이 부족하면 adequacy는 `판정 불충분`입니다. 자동 무기한 연장, candidate 생성, 추가 source, 과거 batch 소급 처리 또는 MVP-B data로 보완하지 않습니다.

[INFERENCE] 2주/4주 경계, 정확히 20 batch, 정확히 50 candidate, 19/49와 activation mid-day fixture로 기간·slot·candidate 계산을 독립 재현합니다.

#### WBS-30.D Service·time metrics

| Metric | Source boundary | 판정 경계 |
| --- | --- | --- |
| Batch preparation | Scheduled 09:30/21:30→verifiable logical result ready | 30분 이내 비율을 최소 20 scheduled batch에서 별도 대조 |
| Discord timely acceptance | Target 10:00/22:00→required physical mapping의 `discord_2xx`+message ID | `[target,target+1분)` 내 수락 비율 95% 이상 |
| Current freshness | Scheduled delivery target−RSS `published` comparable instant | 모든 current selected candidate가 13시간 이하, 정확히 13시간 포함 |
| Pipeline latency | Source scheduled start→original final result 최초 confirmed Discord acceptance | Delayed full result 포함, recovery/receipt confirmation 제외 |
| Recovery latency | Original scheduled target→confirmed recovery acceptance | Current timing/freshness와 별도 |

[FACT] Preparation 분모에서 정상 신규 0건, 늦은 시작, 미실행 예정 batch를 조용히 제외하지 않습니다. Message가 필요한 예정 batch만 Discord timely-acceptance 분모에 포함하되 required message 누락·미수락·불명확·조기·1분 이후 수락을 정시 성공으로 만들지 않습니다.

[FACT] Reaction, batch ✅, recipient `받음`, confirmation과 recovery는 Discord 서버의 original `discord_2xx` 수락 시각을 생성하거나 대체하지 않습니다. Processing-delayed full result는 original pipeline latency에는 포함하지만 정시 acceptance에는 포함하지 않습니다.

#### WBS-30.E Six Hard Gates

| Hard Gate | WBS-30 필수 evidence 경계 |
| --- | --- |
| 추가 월 비용·유료 호출·유료 자원 사용 0건 | 일곱 비용 scope의 설정·usage·paid event·공식 근거와 사용자 monthly billing |
| 미처리 후보 조용한 제외 0건 | Candidate census, typed unprocessed/terminal 결과, batch summary/notice와 수량 reconciliation |
| 의도되지 않은 동일 기사 중복 발송 0건 | Raw RSS exact-link identity, immutable result/item, delivery/recovery attempt와 승인 1회 resend 예외 |
| AI 실패의 신규 0건 오기록 0건 | AI attempt/error/quota/uncertain, candidate/batch 상태와 user-visible failure notice |
| Discord 미수락의 성공 기록 0건 | Physical mapping별 response+message ID, non-acceptance/timeout/uncertainty와 recipient evidence 분리 |
| 중대한 근거 밖 사실 0건 | RSS-bounded input, AI output/claim, article별 승인 review 표본과 source lineage |

[FACT] 각 Gate는 독립 `pass/fail/not_measurable` 결과를 가집니다. Confirmed violation이 한 건이라도 있으면 sample adequacy와 무관하게 해당 Gate는 `fail`입니다.

[FACT] 위반을 관측하지 못했더라도 필수 source·기간·scope·review coverage가 부족하면 0건 또는 `pass`로 기록하지 않습니다. 다른 Gate, 품질 목표, 사용자 feedback이나 서비스 목표의 성공이 실패 Gate를 상쇄하지 않습니다.

#### WBS-30.F Quality·feedback·missing

[FACT] Quality/service metric은 승인된 WBS-08.E~G와 WBS-22 version을 그대로 사용하며 관측 결과에 맞춰 threshold·분모·rubric을 바꾸지 않습니다. 홍보성 False Positive, 근거 충실도와 중요 기사 관련 평가는 승인된 대상·review evidence가 있는 범위에서만 계산합니다.

[FACT] Feedback는 original Gateway event, bounded REST snapshot과 reconciliation evidence를 evaluation cutoff 아래에서 재구성합니다. Current mutable projection, cutoff 뒤 reaction add/remove·late event·late REST 결과를 기존 immutable snapshot에 소급 적용하지 않습니다.

[FACT] Discord server acceptance, recipient-observed receipt, article negative reaction, batch representative ✅, exact `받음`·`못 받음`은 각 의미와 scope를 유지합니다. 미검토, mapping/user 불명, acceptance/receipt 모두 불명확한 item과 feedback 상태 불명을 암묵적 수용 또는 부정 0건으로 계산하지 않습니다.

[FACT] Missing request와 `추천해야 했다`는 exact stored GeekNews RSS link와 실제 이력에 연결된 범위에서만 missing/recommendation evidence로 사용합니다. 제출 자체나 not-collected를 source recall failure·중요 기사·추천 오류로 확정하지 않습니다.

#### WBS-30.G Cost·user billing

[FACT] AI provider, Discord, K3s runtime/host, PostgreSQL/PV, backup storage/transfer, image registry, scheduler/monitoring의 일곱 scope에 대해 account/project/plan, free-only/paid-disabled configuration, usage/quota, paid event, 기간과 stop evidence를 대조합니다.

[FACT] 실제 account의 billing/invoice/usage 최종 확인은 사용자가 직접 수행하며 애플리케이션이 billing API나 invoice scraping으로 자동 판정하지 않습니다. Report에는 Secret이나 전체 invoice를 복제하지 않고 기간·scope·판정과 redacted evidence reference만 연결합니다.

[FACT] 사용자 billing evidence가 evaluation과 필요한 청구 확정 기간, 모든 비용 scope를 완전히 덮기 전에는 비용 Hard Gate를 `pass`로 만들지 않습니다. Statement 지연·scope 누락·금액 또는 paid event 불명은 `판정 불충분`으로 유지합니다.

[FACT] 비용 또는 무료 상태가 불명확하거나 유료 사용 event가 발견되면 신규 비용 가능 operation을 중단하고 자동 유료 전환, 다른 account/provider/runtime 우회 또는 자동 resume를 금지합니다.

#### WBS-30.H Drift·incident·stop

[FACT] Image/source, schema/configuration, provider/model/account/plan, Discord target/permission, cluster/storage, schedule/timezone 또는 metric contract가 바뀌면 기존 activation baseline과 새 baseline을 같은 검증 표본으로 자동 합산하지 않습니다.

[INFERENCE] Drift/incident register는 발생 시각, 영향 slot/candidate/operation/evidence, stop 여부, 외부 effect uncertainty, 변경 전후 fingerprint, root-cause status와 관련 WBS owner를 포함합니다. 실패·중단 구간을 service denominator나 Gate coverage에서 삭제하지 않습니다.

[FACT] Fix·rollback 후 기존 표본을 계속 사용할지, 새 baseline으로 2~4주를 다시 시작할지 또는 결과를 판정 불충분으로 종료할지는 영향과 Requirement를 대조해 사용자가 결정합니다. Agent나 runtime이 유리한 구간을 선택해 자동 재시작하지 않습니다.

#### WBS-30.I Explicit evaluation·report

[FACT] Operational monitoring과 evaluation execution을 구분합니다. Monitoring evidence는 지속적으로 축적할 수 있지만 WBS-22 evaluation runner는 사용자 명시 request와 승인 scope/cutoff가 있어야 실행합니다.

[INFERENCE] Evaluation request 전에 현재 adequacy, evidence gap, 가능한 cutoff, feedback reconciliation 필요 여부와 예상 비용·외부 effect를 제시합니다. Reconciliation이 필요하면 WBS-07/19/22가 승인한 exact trigger와 bounded scope만 사용하고 broad polling을 추가하지 않습니다.

[FACT] Successful evaluation은 cutoff/source high-watermark, compact manifest/count/digest, metric/result version, 여섯 typed Gate result, quality/service/adequacy/cost 결과를 하나의 immutable snapshot/result로 원자적으로 고정합니다. 실패한 실행은 partial final result를 만들지 않습니다.

[FACT] Report는 canonical result를 read-only projection하며 지표를 다시 계산하거나 late evidence를 기존 결과에 삽입하지 않습니다. 같은 request replay는 기존 결과를 재사용하고 새 evidence 반영은 사용자가 승인한 새 evaluation request로만 수행합니다.

#### WBS-30.J Final interpretation·WBS-31 handoff

| Result axis | 허용 결과 |
| --- | --- |
| Sample adequacy | `sufficient` / `insufficient_at_2_weeks` / `insufficient_at_4_weeks` / `not_measurable` |
| 각 Hard Gate | `pass` / `fail` / `not_measurable` |
| 각 quality/service metric | `met` / `missed` / `not_measurable` |
| Cost coverage | `complete` / `incomplete` / `failed` |
| Overall interpretation | `MVP-A pass candidate` / `not met` / `inconclusive` |

[FACT] Overall `MVP-A pass candidate`는 sample adequacy, 여섯 Gate, 품질·서비스와 비용 evidence를 승인 contract로 대조한 사용자 검토 후보이지 자동 최종 승인 상태가 아닙니다. 한 축의 결과로 다른 축을 덮거나 종합 점수 하나로 실패를 숨기지 않습니다.

[INFERENCE] WBS-31 handoff는 baseline/window/sample, Gate별 결과, metric별 결과, billing coverage, incident/drift, feedback/review limitations, open blocker/risk, defect owner, 재검증 선택지와 source result/digest를 포함합니다.

[FACT] WBS-30은 Retrospective, MVP-B scope, monthly insight, 장기 normalization/reuse, 자동 retention lifecycle, 배포 확대 또는 프로젝트 종료를 자동 시작하지 않습니다. WBS-31에서 사용자가 결과를 승인하고 후속 범위를 별도로 결정합니다.

[INFERENCE] WBS-30 완료 기준은 2주·20 batch·50 candidate 조건의 OR/조기 종료, 4주 초과 자동 연장, 미실행/실패 분모 제외, 시간·acceptance·receipt·recovery 혼합, Gate 상쇄/coverage false pass, feedback/missing 의미 오염, billing 미포괄 cost pass, baseline drift 합산, 자동 evaluation·late evidence 소급, 자동 MVP-B 진입이 각각 0건이고 모든 결과 축과 WBS-31 handoff가 immutable evidence로 재현되는 것입니다.

[UNKNOWN] Actual activation date/baseline, scheduled-slot count, candidate volume, quality review sample/rubric execution, metric version, feedback reconciliation 필요성, billing statement availability, incident/drift, 2주 후 연장 여부, evaluation cutoff/request와 final interpretation은 WBS-29~31의 실제 운영 evidence와 사용자 승인으로 닫아야 합니다. 이 계획 승인은 monitoring/evaluation/REST/billing 확인 실행, metric·Gate 결과, 운영 변경, retrospective 또는 MVP-B 진입을 승인한 것이 아닙니다.

### WBS-31 Retrospective·MVP-A disposition·MVP-B incremental-entry decision 상세

[FACT] 관련 범위는 전체 99개 Requirement와 전체 `P0-HG`, Architecture Decision `AD-01~23`, Data / Interface Design Decision `DDI-01~10`, `MIN-01~08` 및 승인된 MVP-A/MVP-B Product Guardrail입니다. 선행 입력은 WBS-30 final result/report digest와 사용자 결과 승인이고 후속 작업은 사용자가 별도로 승인한 MVP-A 개선·재검증 또는 MVP-A baseline 기반 MVP-B incremental discovery입니다.

[FACT] WBS-31은 미래 retrospective와 후속 범위 결정 Task를 정의합니다. 현재 계획 승인은 WBS-30 결과 승인, MVP-A 운영 변경, code/schema/configuration 수정, 재배포·evaluation 재실행, 새 branch 또는 MVP-B discovery/구현 시작을 승인한 것이 아닙니다.

| Checkpoint | 작업 경계 | 최소 산출물 | 완료 증거 |
| --- | --- | --- | --- |
| WBS-31.A | Retrospective input baseline | WBS-30 result/report digest, activation baseline, limitation/billing/incident inventory | 다른 evaluation/baseline 혼합·immutable 결과 수정 0건 |
| WBS-31.B | Evidence-based learning | Outcome/Gate/quality/service/cost/incident/process fact·inference·unknown register | 근거 없는 root cause 확정·성공/실패 재분류 0건 |
| WBS-31.C | Three decision axes | MVP-A validation, MVP-A operation, MVP-B evolution의 독립 decision record | 한 축이 다른 축을 자동 결정하는 전이 0건 |
| WBS-31.D | Failure·inconclusive disposition | Gate fail/not_measurable, 표본·billing 부족, security/data/cost 영향별 pause/remediation owner | Hard Gate accepted-risk 우회·inconclusive의 pass/MVP-B 전환 0건 |
| WBS-31.E | MVP-A remediation·revalidation | 영향 WBS, 최소 fix scope, 재실행 evidence와 새 baseline 결정 | Retrospective 안 production fix·미검증 운영 재개 0건 |
| WBS-31.F | Scope-classified backlog | Defect/operation/evidence gap/risk/debt/MVP-B/out-of-scope와 owner·priority | MVP-A defect의 MVP-B 은닉·backlog-as-execution-approval 0건 |
| WBS-31.G | Change control | Product/Requirement/Architecture/Data/Interface 변경의 원 Workflow와 승인 owner | 승인 문서 조용한 overwrite·회고 기반 소급 변경 0건 |
| WBS-31.H | MVP-B eligibility | MVP-A accepted baseline, 충분한 표본, Gate·quality/service/cost와 사용자 승인 checklist | `not_met`/`inconclusive`의 MVP-B entry 0건 |
| WBS-31.I | Incremental evolution discovery | MVP-A baseline과 B delta의 reuse/extend/migrate/replace/deprecate/defer matrix | Greenfield 재생성·A 기간 B 선구현·destructive data reset 0건 |
| WBS-31.J | Final disposition·handoff | 운영 유지/pause/stop/revalidate, B authorization, context·evidence·next-workflow record | 자동 운영 변경·MVP-B 구현·결정 없는 종료 0건 |

#### WBS-31.A Retrospective input baseline

[FACT] 회고 입력은 사용자가 승인한 WBS-30 final result/report digest, evaluation cutoff/high-watermark/manifest, WBS-29 activation baseline, 관측 window·sample, billing coverage, incident/drift와 알려진 limitation을 exact reference로 동결합니다.

[FACT] 회고에서 과거 immutable evaluation result의 metric, Gate status, source manifest나 evidence를 직접 수정하지 않습니다. 계산·source 오류가 발견되면 원 결과를 보존하고 correction record, defect와 새 evaluation 필요성을 별도로 기록합니다.

[INFERENCE] 서로 다른 baseline, 평가 요청, cutoff 또는 변경 전후 운영 구간을 하나의 retrospective result로 합쳐 더 유리한 결론을 만들지 않습니다. 제외한 evidence와 제외 이유도 기록합니다.

#### WBS-31.B Evidence-based learning

[INFERENCE] 회고는 목표/실제 결과, 여섯 Gate, quality/service/cost, candidate·delivery·feedback/recovery, incident/drift, operator/runbook, 구현·검증·배포 프로세스별로 `[FACT]`, `[INFERENCE]`, `[UNKNOWN]`을 구분합니다.

[FACT] Correlation, 단일 incident 사례, 사용자 반응 또는 telemetry만으로 root cause를 확정하지 않습니다. Source ledger/evidence, 재현 test와 관련 Requirement/Decision이 부족하면 원인 후보와 추가 검증 owner로 남깁니다.

[FACT] 회고의 설명이 WBS-30의 `fail`, `not_measurable` 또는 `inconclusive`를 `pass`로 변경하지 않습니다. 최종 결과 변경이 필요하면 승인된 evaluation 계약으로 새 request/result를 생성해야 합니다.

#### WBS-31.C Three decision axes

| 결정 축 | 허용 결과 | 의미 |
| --- | --- | --- |
| MVP-A validation | `accepted_pass` / `not_met` / `inconclusive` | WBS-30 evidence와 limitation에 대한 사용자 최종 수용 |
| MVP-A operation | `continue` / `continue_with_monitoring` / `pause` / `stop` / `remediate_then_revalidate` | 현재 deployment의 별도 운영 disposition |
| MVP-B evolution | `not_authorized` / `increment_discovery_authorized` | MVP-A baseline 기반 B delta discovery 시작 권한 |

[FACT] 한 결정 축이 다른 축을 자동 결정하지 않습니다. `accepted_pass`라도 운영 지속이나 MVP-B 진입은 별도 사용자 결정이고 `pause`가 과거 validation result를 실패로 바꾸지 않습니다.

[FACT] 운영 disposition은 실제 CronJob/listener/provider/cluster 변경 승인이 아닙니다. Pause/stop/continue 또는 remediation 실행 전에는 exact 변경 범위, 외부 효과, evidence와 rollback을 별도로 제시합니다.

#### WBS-31.D Failure·inconclusive disposition

[FACT] Confirmed Hard Gate fail을 accepted risk, 품질/서비스 성공, 사용자 만족 또는 향후 MVP-B 개선으로 상쇄하지 않습니다. 영향 operation은 승인된 fail-closed/stop 경계와 관련 WBS owner에 연결합니다.

[FACT] 표본 부족, billing coverage 미완료, source/review gap 또는 required metric `not_measurable`은 `inconclusive`이며 validation complete나 비용 0원으로 기록하지 않습니다. 필요한 evidence가 최대 4주 뒤에도 없으면 자동 연장하지 않고 종료/재검증 결정을 요청합니다.

[INFERENCE] Security/Secret/data-loss/paid-event와 external-effect uncertainty는 영향이 닫힐 때까지 관련 operation을 계속하는 비차단 위험으로 분류하지 않습니다. Requirement를 완화해야 한다는 제안은 원 Workflow change control로 반환합니다.

#### WBS-31.E MVP-A remediation·revalidation

[INFERENCE] 각 remediation은 source finding, 영향 Requirement/Decision/WBS, 재현 evidence, 최소 변경 범위, 예상 데이터·외부 효과, test/revalidation owner, rollback과 사용자 승인점을 가집니다.

[FACT] Retrospective 안에 production code/schema/configuration fix나 긴급 배포를 숨기지 않습니다. 결함은 WBS-10~29의 원 owner로 반환해 change approval, 구현, 영향 test와 Deployment Readiness를 다시 수행합니다.

[FACT] Fix 뒤 기존 WBS-30 표본을 계속 사용할지 새 activation baseline으로 2~4주 validation을 다시 시작할지는 변경 영향과 사용자가 결정합니다. 실패 구간을 삭제한 뒤 기존 성공 구간만 재사용하지 않습니다.

#### WBS-31.F Scope-classified backlog

| Backlog class | 경계 |
| --- | --- |
| MVP-A defect | 승인 Requirement/Decision 불충족이며 MVP-B로 미루어 숨길 수 없음 |
| Operation/runbook | 배포·관측·대응 절차의 개선, 실제 변경은 별도 승인 |
| Evidence/test gap | 결론 부족을 보완할 검증이며 pass로 간주하지 않음 |
| Non-blocking risk | 영향·owner·detection·stop/rollback·expiry가 있는 잔존 위험 |
| Technical debt | 현재 동작을 바꾸지 않는 유지보수 부담, Requirement 위반 은닉 금지 |
| MVP-B delta | MVP-A baseline에 추가·변경할 승인 후보 기능 |
| Out-of-scope idea | 현재 A/B 어느 범위에도 승인되지 않은 아이디어 |

[INFERENCE] Backlog item은 ID, class, source evidence/result, affected scope, impact/priority, owner, dependency, 예상 artifact, verification, rollback, approval gate와 MVP-A/B label을 포함합니다.

[FACT] Backlog 등록이나 우선순위 합의는 branch/code/schema/deployment 실행 승인이 아닙니다. 구현 전 해당 Workflow와 Coding Readiness를 다시 통과합니다.

#### WBS-31.G Change control

[FACT] Product Specification, Technical Requirement, Architecture, Logical Data Model 또는 Logical Interface Specification을 회고 결론으로 조용히 덮어쓰지 않습니다. 변경 필요성은 현재 동작, 승인 의도, evidence, trade-off, 영향과 추천안을 제시해 해당 Workflow의 별도 Proposed Changes와 사용자 승인을 받습니다.

[FACT] 과거 승인 문서와 immutable result를 history rewrite하지 않습니다. 승인된 변화는 version/delta와 적용 시점, migration·compatibility, regression 영향과 supersession 관계를 보존합니다.

[INFERENCE] MVP-A requirement를 제거하거나 완화해야만 B가 가능하다면 단순 B delta가 아니라 product/technical change이며 MVP-B entry approval 전에 닫아야 합니다.

#### WBS-31.H MVP-B eligibility

[INFERENCE] `increment_discovery_authorized` 후보 조건은 최소한 WBS-30 sample adequacy sufficient, 여섯 Hard Gate pass, required quality/service 목표 충족, complete cost/billing coverage, 사용자 `accepted_pass`와 exact MVP-A baseline 승인입니다.

[FACT] `not_met`, `inconclusive`, confirmed Gate fail, 비용 evidence 미완료 또는 owner 없는 blocking defect가 있으면 MVP-B incremental discovery를 자동 시작하지 않습니다. 먼저 MVP-A remediation/revalidation 또는 product change 여부를 사용자가 결정합니다.

[FACT] Eligibility 충족도 진입 권한을 자동 생성하지 않습니다. 사용자가 MVP-A validation disposition과 별도로 `increment_discovery_authorized`를 명시적으로 승인해야 합니다.

#### WBS-31.I Incremental evolution discovery

[FACT] MVP-B는 MVP-A Repository, codebase, PostgreSQL data/schema, durable ledger, interfaces, deployment/observability/backup 기반과 검증 evidence를 출발 baseline으로 하는 versioned incremental update입니다. 새 Repository나 시스템을 처음부터 재생성하는 것을 기본 전략으로 삼지 않습니다.

| Delta disposition | 의미 |
| --- | --- |
| `reuse` | MVP-A component/contract/data를 변경 없이 사용 |
| `extend` | 기존 경계를 호환 가능하게 확장 |
| `migrate` | Data/config/interface를 versioned forward migration |
| `replace` | 기존 component를 근거·compatibility·rollback 승인 아래 교체 |
| `deprecate` | 사용 중단 시점과 data/interface consumer 보호 계획 아래 단계적 폐기 |
| `defer` | MVP-B에서도 구현하지 않고 근거·owner와 함께 보류 |

[INFERENCE] MVP-B delta-impact matrix는 delta Requirement, MVP-A baseline component, disposition, Product/Architecture/Data/Interface 영향, data migration/backfill, external contract/cost, regression, deployment/rollback과 approval owner를 연결합니다.

[FACT] PostgreSQL은 data-preserving forward migration을 기본으로 하며 reset/reseed/rebuild로 MVP-A 운영 data와 evidence를 지우지 않습니다. 전체 재구축, destructive migration, 장기 backfill 또는 incompatible replacement가 필요하면 별도 고위험 변경 승인과 backup/restore rehearsal을 요구합니다.

[FACT] MVP-B에서도 적용 가능한 MVP-A 99개 Requirement와 Hard Gate는 regression baseline으로 유지합니다. Requirement가 변경·폐기되는 경우 formal change control 없이 test/traceability에서 삭제하지 않습니다.

[FACT] MVP-B entry 승인 전에는 monthly insight, 장기 결과 reuse/normalization, automatic retention lifecycle 또는 다른 B 기능을 MVP-A code/schema/configuration에 선구현하지 않습니다. Entry 승인 뒤에도 먼저 delta discovery·requirements/design·Coding Readiness를 수행하며 구현은 별도 승인입니다.

[INFERENCE] 실제 MVP-B 구현은 승인된 MVP-A baseline commit에서 시작하는 기존 Repository의 독립적으로 검토 가능한 change branch/PR 단위로 수행합니다. 이 계획 단계에서 branch를 만들거나 commit/push하지 않습니다.

#### WBS-31.J Final disposition·handoff

[INFERENCE] Final record는 세 decision axis, source result/baseline digest, Gate/quality/service/cost limitation, 운영 disposition, remediation/revalidation backlog, accepted risk/debt, MVP-B eligibility와 authorization, incremental delta 원칙, 다음 Workflow·owner·승인점을 포함합니다.

[FACT] `continue`, `pause`, `stop`, `remediate_then_revalidate` 결정만으로 실제 runtime을 변경하지 않습니다. 별도 실행 Task에서 exact target과 effect를 확인하고 change-control 승인을 받습니다.

[FACT] `increment_discovery_authorized`는 MVP-B의 요구사항·영향 탐색 시작 권한이며 code/schema/migration/deployment 구현 승인이나 MVP-A baseline 폐기 승인이 아닙니다.

[INFERENCE] WBS-31 완료 기준은 WBS-30 result mutation, 근거 없는 root cause, Gate accepted-risk 우회, decision-axis 자동 전이, MVP-A defect의 B 은닉, backlog-as-implementation, 승인 문서 silent overwrite, `not_met`/`inconclusive`의 B 진입, greenfield 재생성, destructive data reset, A 기간 B 선구현과 자동 운영 변경이 각각 0건이고 사용자가 세 축과 다음 Workflow를 명시적으로 결정하는 것입니다.

[UNKNOWN] Actual WBS-30 result, MVP-A operational disposition, remediation/revalidation scope, accepted risk/debt, exact accepted baseline, MVP-B eligibility, delta Requirement와 각 disposition, migration/regression/branch 전략 및 다음 Workflow는 WBS-30~31의 실제 evidence와 사용자 승인으로 닫아야 합니다. 이 계획 승인은 retrospective 실행, 운영 변경, fix/revalidation, MVP-B entry/discovery/implementation, branch/commit/push 또는 승인 문서 변경을 승인한 것이 아닙니다.
