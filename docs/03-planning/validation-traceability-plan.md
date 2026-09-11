# External Validation and Traceability Plan

## Document Guide

[FACT] 2026-09-10 승인된 B안에 따라 [구현 계획](implementation-plan.md)의 해당 본문을 이동했습니다. Workflow 9 계획과 F01~F08 승인 범위는 유지하며 실제 설계 결과·구현·검증·배포 완료를 뜻하지 않습니다. 현재 Task·blocker·다음 작업은 [AI Context](../../ai-context.md)를 참조합니다.

[FACT] WBS 간 참조는 [전체 WBS 안내](implementation-plan.md#work-breakdown-structure), 계획 승인 경위는 [검토 이력](implementation-review-history.md#sequential-review-state)을 참조합니다. Product·Requirement·AD·DDI·MIN의 기존 정본은 변경하지 않습니다.

## Quick Navigation

- [External Validation / Spike Plan](#external-validation--spike-plan)
- [Requirement Traceability Plan](#requirement-traceability-plan)
- [Hard Gate Traceability](#hard-gate-traceability)

## External Validation / Spike Plan

[FACT] SPK-06A의 [사전 비용 확인 준비표](spk-06a-preflight.md)에 대상 입력·7개 비용 scope·판정 및 중단 조건을 정리했습니다. 실제 실행은 대상·설정 근거 확인 전 blocked이며 pass evidence가 아닙니다.

[FACT] SPK-01~06은 각각 독립적으로 실행·검토·판정하는 validation task이고, WBS-02는 그 결과를 취합하는 승인 gate입니다.

[INFERENCE] 각 spike evidence는 최소한 spike ID·목적, 실행 일시·환경, 비밀값을 제외한 account/project/configuration fingerprint, 확인한 공식 계약 version 또는 fingerprint, 입력 fixture·절차, redacted response/error/usage/latency, 비용 안전 근거, 판정, 알려진 한계·재검증 조건, 관련 Requirement·Decision·WBS와 후속 owner를 포함합니다.

| 판정 | 의미 | 후속 처리 |
| --- | --- | --- |
| pass | 정의한 성공 기준과 필수 evidence를 충족 | 관련 상세 설계의 승인 근거로 사용 가능 |
| fail | 계약 또는 관찰 결과가 승인 요구를 충족하지 못함 | 의존 WBS 차단, 대안 검토는 사용자 승인 필요 |
| blocked | account·권한·환경 부재 등으로 실험을 실행하지 못함 | 성공으로 추정하지 않고 blocker와 owner 지정 |
| inconclusive | 실험은 수행했지만 충분한 결론을 낼 evidence가 부족함 | 의존 WBS를 차단하고 보완 evidence, 승인된 대안 또는 formal change control로만 해소; 외부 계약·비용·보안 blocker는 accepted-risk로 우회 불가 |

[INFERENCE] 실행 순서는 WBS-01 뒤 SPK-06A 사전 비용 안전 확인을 먼저 수행하고, 허용된 범위에서 SPK-01~04를 독립적으로 진행합니다. SPK-05는 SPK-04에서 storage·backup 대상 후보가 확인된 뒤 수행하며, SPK-01~05 결과 뒤 SPK-06B가 실제 spike 사용량과 전체 환경 비용 coverage를 대조합니다.

[FACT] SPK-06B는 배포 전 비용 안전 근거이며 운영월의 최종 비용 Hard Gate `pass`가 아닙니다. 실제 월별 billing·usage와 유료 event 0건의 최종 판정은 WBS-30에서 수행합니다.

| ID | 검증 대상 | 검증 질문 | 최소 실험 | 성공/실패 판단 | 후속 영향 |
| -- | ----- | ----- | ----- | -------- | ----- |
| SPK-01 | GeekNews RSS | conditional request·항목 수·시간·update·link·허용 polling을 신뢰할 수 있는가 | 공식 조건 재확인 후 저빈도 live fetch를 여러 시점에 수행해 header·304·entry 변화·오류 비교 | 필수 입력·실패 분류와 허용 조건이 재현되면 성공; 불명확하면 관련 기능 차단 | WBS-14 HTTP·validation·retry 계약 |
| SPK-02 | 단일 무료 AI 후보 | 품질·quota·latency·structured output·유료 차단이 적합한가 | Gemini 무료 후보를 우선 검증하고 실패 시 자동 대체 없이 사용자 결정 | 품질·근거·구조·처리량·유료 불가가 모두 증거화돼야 채택 | WBS-06·15·16 |
| SPK-03 | Discord sandbox | 수락·분할·Gateway/REST·reaction·interaction·resume을 구현할 수 있는가 | sandbox에서 분할·대표 mapping·reaction·command·resume·fault 실험 | exact mapping과 긍정적 수락 근거, 불명확 상태 구분 가능 | WBS-07·17~19 |
| SPK-04 | K3s scheduling·storage | Cron·listener·PV·digest·Secret/RBAC가 목표를 충족하는가 | 비production namespace에서 cold start·clock·restart·PV·권한 검증 | 시간 오차·재시작 동작이 측정되고 fail-closed 가능 | WBS-03·05·08·27 |
| SPK-05 | PostgreSQL backup/restore | SPK-04에서 확인한 storage 후보에 대해 별도 실패 영역 backup과 검증 restore가 가능한가 | SPK-04 결과 뒤 synthetic ledger backup·격리 restore·integrity·ledger/Discord 대조 및 outbound 차단 확인 | 측정 RPO/RTO·손실 범위·수동 재개 증거 확보 | WBS-08·21·28 |
| SPK-06 | 추가 월 비용 0원 | 외부 호출 전과 전체 환경 선택 뒤 각각 비용 안전 조건을 충족하는가 | SPK-06A에서 billing·free-only·quota·유료 fallback 부재와 비용 가능 자원을 사전 확인하고, SPK-06B에서 실제 spike usage·유료 event·K3s·storage·registry·backup·monitoring coverage와 kill switch를 대조 | 06A 통과 전 비용 가능 호출 금지; 06B에서 모든 배포 전 범위가 0원·유료 사용 0건이면 WBS-28 비용 readiness 입력으로 사용 가능하며, activation은 WBS-28 `READY`와 WBS-29 별도 사용자 승인이 모두 필요; 운영월 최종 판정은 WBS-30 | WBS-03·11·20·26·28~30 |

## Requirement Traceability Plan

[FACT] WBS-01 [기준선](traceability-baseline.md)은 작성·정적 검사 후 사용자 승인을 받았습니다. 실제 외부·runtime evidence는 미실행이며 [검사 방법](traceability-baseline.md#static-coverage-check)을 유지합니다.

[INFERENCE] Requirement 본문을 복사하지 않고 `Requirement ID | Priority | Primary realization owner | Verification owner | Decision IDs | Planned evidence | Evidence location | Status | Blocker`의 99행 matrix를 유지합니다.

[FACT] 문서 불일치 register는 잘못된 ID, 승인 상태 drift와 아직 승인되지 않은 정정안을 구분합니다. 정합성 검토에서 해소된 항목은 근거와 함께 닫고, 이후 문서 변경에 따른 재발은 Coding Readiness와 Deployment Readiness의 자동 coverage 검사로 탐지합니다.

| Requirement 범위 | Primary implementation owner | Primary verification owner |
| --- | --- | --- |
| FR-001~005 | WBS-13~14 | WBS-23~25 |
| FR-006~010 | WBS-15~16 | WBS-23·25 |
| FR-011~016 | WBS-16~19 | WBS-24~25 |
| FR-017~023 | WBS-18~19·22 | WBS-23·25 |
| FR-024 | WBS-20·22 | WBS-25~26·30 |
| NFR-REL-001~003 | WBS-13·17·19 | WBS-24~25·29~30 |
| NFR-PERF-001 | WBS-14~16·20·22 | WBS-26·30 |
| NFR-LAT-001~002 | WBS-13~17·20·22 | WBS-25~26·30 |
| NFR-COST-001 | WBS-11·20~22·27·29 | SPK-06, WBS-26·28~30 |
| NFR-DQ-001~002 | WBS-14~16·20·22 | WBS-23~25·30 |
| NFR-OBS-001~002 | WBS-13·20·22·29 | WBS-25~26·29~30 |
| NFR-SEC-001~002 | WBS-03·11·20·27·29 | WBS-23·28~29 |
| NFR-REC-001 | WBS-13·19·21·29 | SPK-05, WBS-21·24·28~29 |
| NFR-MNT-001~002 | WBS-10·15·18 | WBS-23·25 |
| NFR-TIME-001 | WBS-13·20·22 | WBS-25~26·30 |
| DR-001~005 | WBS-12·14 | WBS-23~25 |
| DR-006~009 | WBS-12·15~17 | WBS-23~25 |
| DR-010~012 | WBS-12·18~19 | WBS-23·25 |
| DR-013~014 | WBS-11~12·20~22·29 | WBS-25~26·29~30 |
| EXT-GN-001~006 | WBS-14 | SPK-01, WBS-23·25 |
| EXT-AI-001~007 | WBS-15 | SPK-02, WBS-23~26 |
| EXT-DC-001~006 | WBS-17·19 | SPK-03, WBS-23~25 |
| EXT-FB-001~006 | WBS-11·18~19 | SPK-03, WBS-23·25 |
| VR-001~019 | WBS-01·22~26·28~30 | 각 VR evidence artifact와 phase별 WBS-23~30 검증 record |

### Hard Gate Traceability

| Hard Gate | 구현 경계 | 필수 검증 |
| --- | --- | --- |
| 추가 월 비용·유료 호출·유료 자원 사용 0건 | WBS-11·20~22·27·29 | SPK-06, WBS-26·28~30 |
| 미처리 후보 조용한 제외 0건 | WBS-14~16·20·22 | WBS-23~25·30 |
| 의도되지 않은 동일 기사 중복 발송 0건 | WBS-13·17·19·22 | WBS-24~25·30 |
| AI 실패의 신규 0건 오기록 0건 | WBS-15~16·20·22 | WBS-23~25·30 |
| Discord 미수락의 성공 기록 0건 | WBS-17·19·22 | SPK-03, WBS-24~25·30 |
| 중대한 근거 밖 사실 0건 | WBS-15·22 | SPK-02, WBS-23·25·30 |

[INFERENCE] 자동 정합성 검사는 99개 유효 ID, 구현·검증 owner, 모든 P0-HG의 negative test, AC-01~24 evidence, AD/DDI/MIN orphan 0건 및 MVP-A/B 경계를 확인합니다.
