# WBS-01 Traceability Baseline

## Status and Reading Guide

[FACT] 2026-09-10 작성. 승인된 Requirement 99개·AC 24개·AD 23개·DDI 10개·MIN 8개를 변경하지 않고 실행 추적표를 추가했습니다. 기준은 [요구사항 정본](../02-technical/requirements.md), [WBS 정의](implementation-plan.md#work-breakdown-structure), [추적성 계획](validation-traceability-plan.md#requirement-traceability-plan)입니다.

[FACT] 행별 책임·profile·decision 연결·negative case·증거 경로는 사용자의 `1. 승인` 답변으로 승인됐습니다. Primary는 통합 책임이며 기존 WBS의 범위·조건을 축소하지 않습니다. 실제 SPK·Coding Readiness·기능 검증 또는 activation 승인이 아닙니다.

[FACT] 전체 파일 정독 대신 대상 Requirement 행 → profile → 정본의 해당 ID 전체 행(조건·검증·미결정 포함) → 관련 WBS를 따라 읽습니다. DR 표는 다른 표와 열 구조가 다르며 정확성·보존/접근·제품 출처·검증/의존성을 함께 읽습니다.

- [Requirement Matrix](#requirement-matrix)
- [Owner Profiles](#owner-profiles)
- [WBS Reverse Index](#wbs-reverse-index)
- [AC Reverse Map](#ac-reverse-map)
- [Non-AC Product Sources](#non-ac-product-sources)
- [Decision Reverse Map](#decision-reverse-map)
- [Hard Gate Evidence Map](#hard-gate-evidence-map)
- [Evidence and Status Rules](#evidence-and-status-rules)
- [Blockers and Consistency Register](#blockers-and-consistency-register)
- [Static Coverage Check](#static-coverage-check)

## Requirement Matrix

[INFERENCE] 각 EV의 전체 검증 범위는 연결된 정본 ID 행의 검증 기준입니다. 아래 negative는 P0-HG의 필수 회귀 case 요약이며 전체 정상·경계·fault suite를 대체하지 않습니다. AC의 `-`는 orphan이 아니라 아래 별도 Product source로 이어지는 기술 요구사항입니다. 모든 location은 아직 생성하지 않은 계획 경로입니다.

| Requirement ID | Priority | Primary realization owner | Verification owner | Profile | Decision IDs | AC IDs | Planned evidence | Evidence location | Negative / fault case | Status | Blocker |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FR-001 | P0 | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | AC-01 | EV-FR-001: [정본 FR-001의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-002 | P0-HG | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | AC-02 | EV-FR-002: [정본 FR-002의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-002/<run-id>/manifest.json` | 혼합 entry·처리 제한에서 관찰 수량 보존; 조용한 제외 0건 | not_run | B-01, B-02, B-03 |
| FR-003 | P0-HG | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | AC-01, AC-02, AC-07 | EV-FR-003: [정본 FR-003의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-003/<run-id>/manifest.json` | News/Ask/Show·관심 밖·홍보 keyword 변경에도 후보 박탈 0건 | not_run | B-01, B-02, B-03 |
| FR-004 | P0-HG | WBS-13 | WBS-24 | P-13 | AD-02, AD-03, AD-08, AD-10, AD-19, DDI-05, DDI-09, MIN-05 | AC-04 | EV-FR-004: [정본 FR-004의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-24/EV-FR-004/<run-id>/manifest.json` | 동시 batch·응답 유실 replay에서 중복 admission/발송 0건 | not_run | B-01, B-02, B-03 |
| FR-005 | P0-HG | WBS-13 | WBS-24 | P-13 | AD-02, AD-03, AD-08, AD-10, AD-19, DDI-05, DDI-09, MIN-05 | AC-04, AC-13, AC-17 | EV-FR-005: [정본 FR-005의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-24/EV-FR-005/<run-id>/manifest.json` | 현재·처리 지연·복구 scope 혼합 및 과거 미선정 재편입 0건 | not_run | B-01, B-02, B-03 |
| FR-006 | P0-HG | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | AC-03, AC-05 | EV-FR-006: [정본 FR-006의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-006/<run-id>/manifest.json` | 외부 원문·식별자 주입과 근거 없는 주장 입력 차단 | not_run | B-01, B-02, B-03 |
| FR-007 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | AC-05, AC-10 | EV-FR-007: [정본 FR-007의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-007/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-008 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | AC-11 | EV-FR-008: [정본 FR-008의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-008/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-009 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | AC-06, AC-07 | EV-FR-009: [정본 FR-009의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-009/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-010 | P0 | WBS-16 | WBS-25 | P-16 | AD-08, AD-17, AD-18, AD-20, DDI-02, DDI-09, MIN-08 | AC-08, AC-12, AC-22 | EV-FR-010: [정본 FR-010의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-010/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-011 | P0 | WBS-16 | WBS-25 | P-16 | AD-08, AD-17, AD-18, AD-20, DDI-02, DDI-09, MIN-08 | AC-09 | EV-FR-011: [정본 FR-011의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-011/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-012 | P0 | WBS-17 | WBS-25 | P-17 | AD-07, AD-19, AD-20, DDI-03, MIN-08 | AC-10, AC-12, AC-13, AC-15 | EV-FR-012: [정본 FR-012의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-012/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-013 | P0-HG | WBS-16 | WBS-25 | P-16 | AD-08, AD-17, AD-18, AD-20, DDI-02, DDI-09, MIN-08 | AC-14, AC-15 | EV-FR-013: [정본 FR-013의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-013/<run-id>/manifest.json` | 유효 후보 1건 미완료에서 부분 기사 목록 발송 0건 | not_run | B-01, B-02, B-03 |
| FR-014 | P0-HG | WBS-16 | WBS-25 | P-16 | AD-08, AD-17, AD-18, AD-20, DDI-02, DDI-09, MIN-08 | AC-14, AC-16 | EV-FR-014: [정본 FR-014의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-014/<run-id>/manifest.json` | 전부 quota/timeout 실패에서 정상 0건 오기록·유료 fallback 0건 | not_run | B-01, B-02, B-03 |
| FR-015 | P0-HG | WBS-17 | WBS-25 | P-17 | AD-07, AD-19, AD-20, DDI-03, MIN-08 | AC-17 | EV-FR-015: [정본 FR-015의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-015/<run-id>/manifest.json` | 응답 유실·부분 수락에서 근거 없는 성공 0건 | not_run | B-01, B-02, B-03 |
| FR-016 | P0 | WBS-19 | WBS-24 | P-19 | AD-03, AD-07, AD-11, AD-12, AD-21, DDI-03, DDI-04, DDI-10, MIN-01 | AC-18, AC-19 | EV-FR-016: [정본 FR-016의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-24/EV-FR-016/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-017 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-20 | EV-FR-017: [정본 FR-017의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-017/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-018 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-20 | EV-FR-018: [정본 FR-018의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-018/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-019 | P1-V | WBS-22 | WBS-25 | P-22 | AD-23, DDI-08, MIN-02 | AC-20 | EV-FR-019: [정본 FR-019의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-019/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-020 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-21 | EV-FR-020: [정본 FR-020의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-020/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-021 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-21 | EV-FR-021: [정본 FR-021의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-021/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-022 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-21 | EV-FR-022: [정본 FR-022의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-23/EV-FR-022/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-023 | P1-V | WBS-22 | WBS-25 | P-22 | AD-23, DDI-08, MIN-02 | AC-21 | EV-FR-023: [정본 FR-023의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-023/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| FR-024 | P1-V | WBS-22 | WBS-25 | P-22 | AD-23, DDI-08, MIN-02 | AC-23, AC-24 | EV-FR-024: [정본 FR-024의 검증 기준](../02-technical/requirements.md#functional-requirements) | `evidence/WBS-25/EV-FR-024/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-REL-001 | P0-HG | WBS-19 | WBS-24 | P-19 | AD-03, AD-07, AD-11, AD-12, AD-21, DDI-03, DDI-04, DDI-10, MIN-01 | AC-04, AC-13, AC-14, AC-17, AC-18 | EV-NFR-REL-001: [정본 NFR-REL-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-24/EV-NFR-REL-001/<run-id>/manifest.json` | 동시 실행·불명확 응답·late receipt에서 무승인 중복 발송 0건 | not_run | B-01, B-02, B-03 |
| NFR-REL-002 | P0-HG | WBS-13 | WBS-24 | P-13 | AD-02, AD-03, AD-08, AD-10, AD-19, DDI-05, DDI-09, MIN-05 | AC-13, AC-14, AC-15, AC-17, AC-18, AC-24 | EV-NFR-REL-002: [정본 NFR-REL-002의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-24/EV-NFR-REL-002/<run-id>/manifest.json` | RSS/AI/Discord fault에서 단계·scope 수량 혼합과 정상 0건 오판 0건 | not_run | B-01, B-02, B-03 |
| NFR-PERF-001 | P0 | WBS-22 | WBS-25 | P-22 | AD-23, DDI-08, MIN-02 | AC-24 | EV-NFR-PERF-001: [정본 NFR-PERF-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-25/EV-NFR-PERF-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-LAT-001 | P0 | WBS-13 | WBS-24 | P-13 | AD-02, AD-03, AD-08, AD-10, AD-19, DDI-05, DDI-09, MIN-05 | AC-23, AC-24 | EV-NFR-LAT-001: [정본 NFR-LAT-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-24/EV-NFR-LAT-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-LAT-002 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | AC-09, AC-18, AC-24 | EV-NFR-LAT-002: [정본 NFR-LAT-002의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-23/EV-NFR-LAT-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-COST-001 | P0-HG | WBS-11 | WBS-30 | P-11 | AD-04, AD-10, AD-13, AD-15, AD-16, DDI-06, MIN-03 | AC-16, AC-24 | EV-NFR-COST-001: [정본 NFR-COST-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-30/EV-NFR-COST-001/<run-id>/manifest.json` | 비용 불명·quota 소진에서 호출 차단; 전 비용 범위 billing 누락이면 통과 금지 | not_run | B-01, B-02, B-03 |
| NFR-DQ-001 | P0-HG | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | AC-05, AC-11, AC-24 | EV-NFR-DQ-001: [정본 NFR-DQ-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-23/EV-NFR-DQ-001/<run-id>/manifest.json` | RSS에 없는 사실 주입·저정보 fixture에서 정상 분석 승인 0건 | not_run | B-01, B-02, B-03 |
| NFR-DQ-002 | P0-HG | WBS-16 | WBS-25 | P-16 | AD-08, AD-17, AD-18, AD-20, DDI-02, DDI-09, MIN-08 | AC-13, AC-14, AC-15, AC-16, AC-17, AC-18, AC-24 | EV-NFR-DQ-002: [정본 NFR-DQ-002의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-25/EV-NFR-DQ-002/<run-id>/manifest.json` | 후보 미처리·입력 오류·전달 불명확의 정상 미선정/성공 오분류 0건 | not_run | B-01, B-02, B-03 |
| NFR-OBS-001 | P0 | WBS-20 | WBS-26 | P-20 | AD-13, AD-15, AD-16, DDI-06, MIN-03 | AC-24 | EV-NFR-OBS-001: [정본 NFR-OBS-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-26/EV-NFR-OBS-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-OBS-002 | P0-HG | WBS-22 | WBS-30 | P-22 | AD-23, DDI-08, MIN-02 | AC-24 | EV-NFR-OBS-002: [정본 NFR-OBS-002의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-30/EV-NFR-OBS-002/<run-id>/manifest.json` | 각 Gate 위반·증거 누락을 독립 주입; 다른 Gate 또는 평균으로 pass 대체 0건 | not_run | B-01, B-02, B-03 |
| NFR-SEC-001 | P0 | WBS-11 | WBS-23 | P-11 | AD-04, AD-10, AD-13, AD-15, AD-16, DDI-06, MIN-03 | AC-03 | EV-NFR-SEC-001: [정본 NFR-SEC-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-23/EV-NFR-SEC-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-SEC-002 | P0 | WBS-11 | WBS-23 | P-11 | AD-04, AD-10, AD-13, AD-15, AD-16, DDI-06, MIN-03 | - | EV-NFR-SEC-002: [정본 NFR-SEC-002의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-23/EV-NFR-SEC-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-REC-001 | P0-HG | WBS-21 | WBS-24 | P-21 | AD-09, AD-10, AD-22, DDI-05, DDI-06, MIN-01 | - | EV-NFR-REC-001: [정본 NFR-REC-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-24/EV-NFR-REC-001/<run-id>/manifest.json` | commit 유실·restore·DB 불신에서 자동 외부 재호출/재개 0건 | not_run | B-01, B-02, B-03 |
| NFR-MNT-001 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-NFR-MNT-001: [정본 NFR-MNT-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-23/EV-NFR-MNT-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-MNT-002 | P0 | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | - | EV-NFR-MNT-002: [정본 NFR-MNT-002의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-23/EV-NFR-MNT-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-TIME-001 | P0 | WBS-13 | WBS-24 | P-13 | AD-02, AD-03, AD-08, AD-10, AD-19, DDI-05, DDI-09, MIN-05 | - | EV-NFR-TIME-001: [정본 NFR-TIME-001의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-24/EV-NFR-TIME-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| NFR-REL-003 | P0 | WBS-13 | WBS-24 | P-13 | AD-02, AD-03, AD-08, AD-10, AD-19, DDI-05, DDI-09, MIN-05 | - | EV-NFR-REL-003: [정본 NFR-REL-003의 검증 기준](../02-technical/requirements.md#non-functional-requirements) | `evidence/WBS-24/EV-NFR-REL-003/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-001 | P0 | WBS-12 | WBS-24 | P-12 | AD-02, DDI-01, MIN-08, DDI-07 | - | EV-DR-001: [정본 DR-001의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-002 | P0 | WBS-12 | WBS-24 | P-12 | AD-02, DDI-01, MIN-08 | - | EV-DR-002: [정본 DR-002의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-003 | P0-HG | WBS-12 | WBS-24 | P-12 | AD-02, DDI-01, MIN-08 | - | EV-DR-003: [정본 DR-003의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-003/<run-id>/manifest.json` | 같은 link 동시 생성·다른 link 유사 제목에서 중복/추정 병합 0건 | not_run | B-01, B-02, B-03 |
| DR-004 | P0-HG | WBS-12 | WBS-24 | P-12 | AD-02, DDI-02, DDI-09, MIN-08 | - | EV-DR-004: [정본 DR-004의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-004/<run-id>/manifest.json` | 재처리·상태 전이에서 실패/미처리 이력 덮어쓰기 0건 | not_run | B-01, B-02, B-03 |
| DR-005 | P0-HG | WBS-12 | WBS-24 | P-12 | AD-02, DDI-02, DDI-03, MIN-08 | - | EV-DR-005: [정본 DR-005의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-005/<run-id>/manifest.json` | 복구에 과거 미선정·수락 확인 기사 편입 및 AI 재호출 0건 | not_run | B-01, B-02, B-03 |
| DR-006 | P0 | WBS-12 | WBS-24 | P-12 | AD-02, DDI-02, MIN-04, MIN-06, MIN-08 | AC-05 | EV-DR-006: [정본 DR-006의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-006/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-007 | P0 | WBS-12 | WBS-24 | P-12 | AD-02, DDI-02, DDI-09, MIN-08 | - | EV-DR-007: [정본 DR-007의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-007/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-008 | P0 | WBS-12 | WBS-24 | P-12 | AD-02, DDI-02, DDI-03, MIN-08 | AC-22 | EV-DR-008: [정본 DR-008의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-008/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-009 | P0-HG | WBS-12 | WBS-24 | P-12 | AD-02, DDI-03, MIN-08 | - | EV-DR-009: [정본 DR-009의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-009/<run-id>/manifest.json` | physical message 부분 수락·응답 유실에서 타 message 성공 추정 0건 | not_run | B-01, B-02, B-03 |
| DR-010 | P1-V | WBS-12 | WBS-24 | P-12 | AD-02, DDI-04, MIN-07, MIN-08 | AC-20 | EV-DR-010: [정본 DR-010의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-010/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-011 | P1-V | WBS-12 | WBS-24 | P-12 | AD-02, DDI-10, MIN-08 | AC-21 | EV-DR-011: [정본 DR-011의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-011/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-012 | P1-V | WBS-12 | WBS-24 | P-12 | AD-02, DDI-08, DDI-10, MIN-08 | AC-21 | EV-DR-012: [정본 DR-012의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-012/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-013 | P1-V | WBS-12 | WBS-24 | P-12 | AD-02, DDI-08, MIN-02, MIN-08 | - | EV-DR-013: [정본 DR-013의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-013/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| DR-014 | P0 | WBS-12 | WBS-24 | P-12 | AD-02, DDI-06, MIN-03, MIN-08 | - | EV-DR-014: [정본 DR-014의 검증 기준](../02-technical/requirements.md#data-requirements) | `evidence/WBS-24/EV-DR-014/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-GN-001 | P0 | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | AC-01 | EV-EXT-GN-001: [정본 EXT-GN-001의 검증 기준](../02-technical/requirements.md#geeknews-rss) | `evidence/WBS-23/EV-EXT-GN-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-GN-002 | P0 | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | - | EV-EXT-GN-002: [정본 EXT-GN-002의 검증 기준](../02-technical/requirements.md#geeknews-rss) | `evidence/WBS-23/EV-EXT-GN-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-GN-003 | P0-HG | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | - | EV-EXT-GN-003: [정본 EXT-GN-003의 검증 기준](../02-technical/requirements.md#geeknews-rss) | `evidence/WBS-23/EV-EXT-GN-003/<run-id>/manifest.json` | Atom id·제목 기반 병합·link normalization·identity 소급 변경 0건 | not_run | B-01, B-02, B-03 |
| EXT-GN-004 | P0 | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | - | EV-EXT-GN-004: [정본 EXT-GN-004의 검증 기준](../02-technical/requirements.md#geeknews-rss) | `evidence/WBS-23/EV-EXT-GN-004/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-GN-005 | P0 | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | - | EV-EXT-GN-005: [정본 EXT-GN-005의 검증 기준](../02-technical/requirements.md#geeknews-rss) | `evidence/WBS-23/EV-EXT-GN-005/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-GN-006 | P0 | WBS-14 | WBS-23 | P-14 | AD-02, AD-10, DDI-01, DDI-02, MIN-08 | - | EV-EXT-GN-006: [정본 EXT-GN-006의 검증 기준](../02-technical/requirements.md#geeknews-rss) | `evidence/WBS-23/EV-EXT-GN-006/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-AI-001 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-001: [정본 EXT-AI-001의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-AI-002 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-002: [정본 EXT-AI-002의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-AI-003 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-003: [정본 EXT-AI-003의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-003/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-AI-004 | P0-HG | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-004: [정본 EXT-AI-004의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-004/<run-id>/manifest.json` | billing/tier 불명·설정 변경에서 호출·자동 유료 전환 0건 | not_run | B-01, B-02, B-03 |
| EXT-AI-005 | P0-HG | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-005: [정본 EXT-AI-005의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-005/<run-id>/manifest.json` | quota/형식 오류·거부·timeout의 저정보/정상 0건 오분류 0건 | not_run | B-01, B-02, B-03 |
| EXT-AI-006 | P1-V | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-006: [정본 EXT-AI-006의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-006/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-AI-007 | P0 | WBS-15 | WBS-23 | P-15 | AD-01, AD-04, AD-17, AD-18, DDI-02, DDI-09, MIN-04, MIN-06 | - | EV-EXT-AI-007: [정본 EXT-AI-007의 검증 기준](../02-technical/requirements.md#free-ai-provider) | `evidence/WBS-23/EV-EXT-AI-007/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-DC-001 | P0-HG | WBS-17 | WBS-25 | P-17 | AD-07, AD-19, AD-20, DDI-03, MIN-08 | AC-17 | EV-EXT-DC-001: [정본 EXT-DC-001의 검증 기준](../02-technical/requirements.md#discord-delivery) | `evidence/WBS-25/EV-EXT-DC-001/<run-id>/manifest.json` | message 식별자 누락·응답 유실·reaction만으로 서버 수락 추정 0건 | not_run | B-01, B-02, B-03 |
| EXT-DC-002 | P0 | WBS-17 | WBS-25 | P-17 | AD-07, AD-19, AD-20, DDI-03, MIN-08 | - | EV-EXT-DC-002: [정본 EXT-DC-002의 검증 기준](../02-technical/requirements.md#discord-delivery) | `evidence/WBS-25/EV-EXT-DC-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-DC-003 | P0-HG | WBS-19 | WBS-24 | P-19 | AD-03, AD-07, AD-11, AD-12, AD-21, DDI-03, DDI-04, DDI-10, MIN-01 | AC-18 | EV-EXT-DC-003: [정본 EXT-DC-003의 검증 기준](../02-technical/requirements.md#discord-delivery) | `evidence/WBS-24/EV-EXT-DC-003/<run-id>/manifest.json` | 1시간 전후·late proof·못 받음 재유실에서 자동 재발송 및 예외 2회 허용 0건 | not_run | B-01, B-02, B-03 |
| EXT-DC-004 | P0 | WBS-17 | WBS-25 | P-17 | AD-07, AD-19, AD-20, DDI-03, MIN-08 | AC-19 | EV-EXT-DC-004: [정본 EXT-DC-004의 검증 기준](../02-technical/requirements.md#discord-delivery) | `evidence/WBS-25/EV-EXT-DC-004/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-DC-005 | P0 | WBS-19 | WBS-24 | P-19 | AD-03, AD-07, AD-11, AD-12, AD-21, DDI-03, DDI-04, DDI-10, MIN-01 | AC-18 | EV-EXT-DC-005: [정본 EXT-DC-005의 검증 기준](../02-technical/requirements.md#discord-delivery) | `evidence/WBS-24/EV-EXT-DC-005/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-DC-006 | P0-HG | WBS-17 | WBS-25 | P-17 | AD-07, AD-19, AD-20, DDI-03, MIN-08 | - | EV-EXT-DC-006: [정본 EXT-DC-006의 검증 기준](../02-technical/requirements.md#discord-delivery) | `evidence/WBS-25/EV-EXT-DC-006/<run-id>/manifest.json` | 처리 실패 notice·receipt의 기사 성공/정상 0건 오판 0건 | not_run | B-01, B-02, B-03 |
| EXT-FB-001 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-20 | EV-EXT-FB-001: [정본 EXT-FB-001의 검증 기준](../02-technical/requirements.md#discord-feedback) | `evidence/WBS-23/EV-EXT-FB-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-FB-002 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-20 | EV-EXT-FB-002: [정본 EXT-FB-002의 검증 기준](../02-technical/requirements.md#discord-feedback) | `evidence/WBS-23/EV-EXT-FB-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-FB-003 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-21 | EV-EXT-FB-003: [정본 EXT-FB-003의 검증 기준](../02-technical/requirements.md#discord-feedback) | `evidence/WBS-23/EV-EXT-FB-003/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-FB-004 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-21 | EV-EXT-FB-004: [정본 EXT-FB-004의 검증 기준](../02-technical/requirements.md#discord-feedback) | `evidence/WBS-23/EV-EXT-FB-004/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-FB-005 | P1-V | WBS-18 | WBS-23 | P-18 | AD-05, AD-11, AD-12, DDI-04, DDI-10, MIN-07 | AC-21 | EV-EXT-FB-005: [정본 EXT-FB-005의 검증 기준](../02-technical/requirements.md#discord-feedback) | `evidence/WBS-23/EV-EXT-FB-005/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| EXT-FB-006 | P0 | WBS-11 | WBS-23 | P-11 | AD-04, AD-10, AD-13, AD-15, AD-16, DDI-06, MIN-03 | - | EV-EXT-FB-006: [정본 EXT-FB-006의 검증 기준](../02-technical/requirements.md#discord-feedback) | `evidence/WBS-23/EV-EXT-FB-006/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-001 | P0 | WBS-01 | WBS-23 | P-01 | AD-23, DDI-08, MIN-02 | AC-24 | EV-VR-001: [정본 VR-001의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-23/EV-VR-001/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-002 | P0 | WBS-23 | WBS-23 | P-23 | AD-01, DDI-01, MIN-08 | - | EV-VR-002: [정본 VR-002의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-23/EV-VR-002/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-003 | P0 | WBS-25 | WBS-25 | P-25 | AD-17, AD-18, AD-20, DDI-09, MIN-08 | - | EV-VR-003: [정본 VR-003의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-25/EV-VR-003/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-004 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05 | - | EV-VR-004: [정본 VR-004의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-004/<run-id>/manifest.json` | AI/Discord 원인별 fault에서 상태 은폐·partial release·유료 전환 0건 | not_run | B-01, B-02, B-03 |
| VR-005 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05 | AC-04 | EV-VR-005: [정본 VR-005의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-005/<run-id>/manifest.json` | 정확히 같은 link replay·불명확 전달에서 무승인 중복 발송 0건 | not_run | B-01, B-02, B-03 |
| VR-006 | P1-V | WBS-30 | WBS-30 | P-30 | AD-15, AD-23, DDI-06, DDI-08, MIN-02, MIN-03 | AC-23 | EV-VR-006: [정본 VR-006의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-30/EV-VR-006/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-007 | P1-V | WBS-22 | WBS-25 | P-22 | AD-23, DDI-08, MIN-02 | AC-08, AC-22, AC-24 | EV-VR-007: [정본 VR-007의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-25/EV-VR-007/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-008 | P0 | WBS-26 | WBS-26 | P-26 | AD-06, AD-19, AD-23, DDI-08, MIN-02 | AC-24 | EV-VR-008: [정본 VR-008의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-26/EV-VR-008/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-009 | P0-HG | WBS-30 | WBS-30 | P-30 | AD-15, AD-23, DDI-06, DDI-08, MIN-02, MIN-03 | AC-24 | EV-VR-009: [정본 VR-009의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-30/EV-VR-009/<run-id>/manifest.json` | 7-scope 중 하나 누락·유료 event 존재 시 비용 Gate pass 금지 | not_run | B-01, B-02, B-03 |
| VR-010 | P1-V | WBS-25 | WBS-25 | P-25 | AD-17, AD-18, AD-20, DDI-09, MIN-08 | AC-20, AC-21 | EV-VR-010: [정본 VR-010의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-25/EV-VR-010/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-011 | P0 | WBS-28 | WBS-28 | P-28 | AD-06, AD-09, AD-14, AD-15, AD-22, DDI-06, MIN-03 | - | EV-VR-011: [정본 VR-011의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-28/EV-VR-011/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-012 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05 | AC-17, AC-18, AC-19 | EV-VR-012: [정본 VR-012의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-012/<run-id>/manifest.json` | 부분 message receipt를 전체 segment 수락으로 확대 및 수신 item 재복구 0건 | not_run | B-01, B-02, B-03 |
| VR-013 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05 | AC-04, AC-17 | EV-VR-013: [정본 VR-013의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-013/<run-id>/manifest.json` | W1 lease 만료·W2 claim 뒤 W1 invocation/commit 0건 | not_run | B-01, B-02, B-03 |
| VR-014 | P0 | WBS-26 | WBS-26 | P-26 | AD-06, AD-19, AD-23, DDI-08, MIN-02 | AC-23, AC-24 | EV-VR-014: [정본 VR-014의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-26/EV-VR-014/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-015 | P0 | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05 | AC-04, AC-24 | EV-VR-015: [정본 VR-015의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-015/<run-id>/manifest.json` | - | not_run | B-01, B-02, B-03 |
| VR-016 | P0-HG | WBS-25 | WBS-25 | P-25 | AD-17, AD-18, AD-20, DDI-09, MIN-08 | AC-13, AC-14, AC-15, AC-16 | EV-VR-016: [정본 VR-016의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-25/EV-VR-016/<run-id>/manifest.json` | 정상 0건·오류·all-promo·recovery-only에서 immutable completion 재작성 0건 | not_run | B-01, B-02, B-03 |
| VR-017 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05 | AC-13, AC-14, AC-15, AC-16 | EV-VR-017: [정본 VR-017의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-017/<run-id>/manifest.json` | Prepare token 교체·commit 전후 중단에서 별도 finalization work/stale commit 0건 | not_run | B-01, B-02, B-03 |
| VR-018 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05, DDI-06, MIN-03 | AC-05, AC-09, AC-10, AC-14, AC-17 | EV-VR-018: [정본 VR-018의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-018/<run-id>/manifest.json` | C1 batch 도중 C2 변경에서 snapshot 재결합·version 중복 lineage 0건 | not_run | B-01, B-02, B-03 |
| VR-019 | P0-HG | WBS-24 | WBS-24 | P-24 | AD-02, AD-03, AD-10, DDI-05, MIN-05, DDI-02, MIN-04, MIN-06 | AC-05, AC-13, AC-14 | EV-VR-019: [정본 VR-019의 검증 기준](../02-technical/requirements.md#verification-requirements) | `evidence/WBS-24/EV-VR-019/<run-id>/manifest.json` | 검증 실패·late 응답에서 analysis 생성·finalization 소급 변경 0건 | not_run | B-01, B-02, B-03 |

## Owner Profiles

[INFERENCE] Profile은 반복되는 설계·협업·spike 탐색 경로입니다. Requirement에 직접 적용되는 세부 checkpoint만 사용하며, 연결 목록 자체가 선행 조건 충족이나 실행 승인은 아닙니다. Verification owner는 정본 기준 전체를 취합하고 WBS-23 단위/계약, WBS-24 동시성/fault, WBS-25 E2E, WBS-26 운영 전 용량/시간, WBS-29 smoke, WBS-30 실제 운영 evidence 중 적용 계층을 분리 인계합니다. 비용·외부 계약은 SPK와 WBS-28 검토도 필요합니다.

| Profile | Design WBS | Supporting realization WBS | External evidence dependency |
| --- | --- | --- | --- |
| P-01 | - | - | - |
| P-11 | WBS-03, WBS-04, WBS-05 | WBS-12, WBS-15, WBS-18, WBS-20, WBS-27, WBS-29 | SPK-06A, SPK-06B |
| P-12 | WBS-04, WBS-05 | WBS-14, WBS-15, WBS-16, WBS-17, WBS-18, WBS-19, WBS-20, WBS-22 | - |
| P-13 | WBS-03, WBS-04, WBS-05 | WBS-11, WBS-14, WBS-16, WBS-17, WBS-19 | SPK-04 |
| P-14 | WBS-04, WBS-05 | WBS-12, WBS-13 | SPK-01 |
| P-15 | WBS-03, WBS-04, WBS-05, WBS-06 | WBS-11, WBS-12, WBS-13, WBS-16 | SPK-02, SPK-06A, SPK-06B |
| P-16 | WBS-04, WBS-05, WBS-06 | WBS-12, WBS-13, WBS-15, WBS-17 | SPK-02 |
| P-17 | WBS-04, WBS-05, WBS-06, WBS-07 | WBS-11, WBS-12, WBS-13, WBS-16, WBS-19 | SPK-03 |
| P-18 | WBS-03, WBS-04, WBS-05, WBS-07 | WBS-11, WBS-12, WBS-17, WBS-19, WBS-22 | SPK-03 |
| P-19 | WBS-04, WBS-05, WBS-07 | WBS-13, WBS-17, WBS-18, WBS-21 | SPK-03, SPK-05 |
| P-20 | WBS-03, WBS-04, WBS-08 | WBS-11, WBS-13, WBS-21, WBS-22, WBS-27, WBS-29 | SPK-06A, SPK-06B |
| P-21 | WBS-03, WBS-04, WBS-05, WBS-08 | WBS-11, WBS-12, WBS-13, WBS-19, WBS-27, WBS-29 | SPK-04, SPK-05 |
| P-22 | WBS-04, WBS-07, WBS-08 | WBS-13, WBS-14, WBS-15, WBS-16, WBS-17, WBS-18, WBS-19, WBS-20 | - |
| P-23 | WBS-04, WBS-05, WBS-06, WBS-07, WBS-08 | WBS-10, WBS-14 | SPK-01 |
| P-24 | WBS-04, WBS-05, WBS-06, WBS-07 | WBS-12, WBS-13, WBS-15, WBS-16, WBS-17, WBS-19 | - |
| P-25 | WBS-04, WBS-05, WBS-06, WBS-07, WBS-08 | WBS-14, WBS-15, WBS-16, WBS-17, WBS-18, WBS-19, WBS-22 | - |
| P-26 | WBS-03, WBS-05, WBS-06, WBS-08 | WBS-13, WBS-15, WBS-20, WBS-22 | SPK-02, SPK-04, SPK-06A, SPK-06B |
| P-28 | WBS-03, WBS-08 | WBS-11, WBS-20, WBS-21, WBS-27, WBS-29 | SPK-01, SPK-02, SPK-03, SPK-04, SPK-05, SPK-06A, SPK-06B |
| P-30 | WBS-08 | WBS-20, WBS-22, WBS-28, WBS-29 | - |

[FACT] 모든 행의 승인 흐름은 WBS-01 기준선 검토 → WBS-02 관련 외부 계약 → WBS-03~08 관련 설계 → WBS-09 실제 READY → 해당 구현/검증 승인입니다. 배포 전 WBS-28, 별도 activation WBS-29, 실제 운영 판정 WBS-30, 결과 승인·MVP-B 진입 결정 WBS-31을 구분합니다. WBS-10은 공통 구현·테스트 기반, WBS-27은 배포 artifact 책임이며 임의 생략하지 않습니다.

## WBS Reverse Index

[INFERENCE] 행 번호 대신 Requirement ID와 profile로 역탐색합니다. Design/support 열은 해당 profile의 Requirement 행으로 이어집니다. 공통 gate 적용은 관련 선행 조건과 별도 사용자 승인을 생략하지 않습니다.

| WBS ID | Primary realization requirements | Verification requirements | Design / supporting profiles | Common responsibility |
| --- | --- | --- | --- | --- |
| WBS-01 | VR-001 | - | - | 전체 추적성 및 이번 baseline 검토 |
| WBS-02 | - | - | - | 관련 SPK 결과·외부 계약 승인 gate |
| WBS-03 | - | - | P-11, P-13, P-15, P-18, P-20, P-21, P-26, P-28 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-04 | - | - | P-11, P-12, P-13, P-14, P-15, P-16, P-17, P-18, P-19, P-20, P-21, P-22, P-23, P-24, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-05 | - | - | P-11, P-12, P-13, P-14, P-15, P-16, P-17, P-18, P-19, P-21, P-23, P-24, P-25, P-26 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-06 | - | - | P-15, P-16, P-17, P-23, P-24, P-25, P-26 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-07 | - | - | P-17, P-18, P-19, P-22, P-23, P-24, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-08 | - | - | P-20, P-21, P-22, P-23, P-25, P-26, P-28, P-30 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-09 | - | - | - | 전체 구현 진입 READY 검토 |
| WBS-10 | - | - | P-23 | 공통 실행·테스트 기반 |
| WBS-11 | NFR-COST-001, NFR-SEC-001, NFR-SEC-002, EXT-FB-006 | - | P-13, P-15, P-17, P-18, P-20, P-21, P-28 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-12 | DR-001, DR-002, DR-003, DR-004, DR-005, DR-006, DR-007, DR-008, DR-009, DR-010, DR-011, DR-012, DR-013, DR-014 | - | P-11, P-14, P-15, P-16, P-17, P-18, P-21, P-24 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-13 | FR-004, FR-005, NFR-REL-002, NFR-LAT-001, NFR-TIME-001, NFR-REL-003 | - | P-14, P-15, P-16, P-17, P-19, P-20, P-21, P-22, P-24, P-26 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-14 | FR-001, FR-002, FR-003, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006 | - | P-12, P-13, P-22, P-23, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-15 | FR-006, FR-007, FR-008, FR-009, NFR-LAT-002, NFR-DQ-001, NFR-MNT-001, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007 | - | P-11, P-12, P-16, P-22, P-24, P-25, P-26 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-16 | FR-010, FR-011, FR-013, FR-014, NFR-DQ-002 | - | P-12, P-13, P-15, P-17, P-22, P-24, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-17 | FR-012, FR-015, EXT-DC-001, EXT-DC-002, EXT-DC-004, EXT-DC-006 | - | P-12, P-13, P-16, P-18, P-19, P-22, P-24, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-18 | FR-017, FR-018, FR-020, FR-021, FR-022, NFR-MNT-002, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 | - | P-11, P-12, P-19, P-22, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-19 | FR-016, NFR-REL-001, EXT-DC-003, EXT-DC-005 | - | P-12, P-13, P-17, P-18, P-21, P-22, P-24, P-25 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-20 | NFR-OBS-001 | - | P-11, P-12, P-22, P-26, P-28, P-30 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-21 | NFR-REC-001 | - | P-19, P-20, P-28 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-22 | FR-019, FR-023, FR-024, NFR-PERF-001, NFR-OBS-002, VR-007 | - | P-12, P-18, P-20, P-25, P-26, P-30 | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-23 | VR-002 | FR-001, FR-002, FR-003, FR-006, FR-007, FR-008, FR-009, FR-017, FR-018, FR-020, FR-021, FR-022, NFR-LAT-002, NFR-DQ-001, NFR-SEC-001, NFR-SEC-002, NFR-MNT-001, NFR-MNT-002, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005, EXT-FB-006, VR-001, VR-002 | - | 전체 verification-layer inventory 및 관련 계약·단위 closure |
| WBS-24 | VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 | FR-004, FR-005, FR-016, NFR-REL-001, NFR-REL-002, NFR-LAT-001, NFR-REC-001, NFR-TIME-001, NFR-REL-003, DR-001, DR-002, DR-003, DR-004, DR-005, DR-006, DR-007, DR-008, DR-009, DR-010, DR-011, DR-012, DR-013, DR-014, EXT-DC-003, EXT-DC-005, VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 | - | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-25 | VR-003, VR-010, VR-016 | FR-010, FR-011, FR-012, FR-013, FR-014, FR-015, FR-019, FR-023, FR-024, NFR-PERF-001, NFR-DQ-002, EXT-DC-001, EXT-DC-002, EXT-DC-004, EXT-DC-006, VR-003, VR-007, VR-010, VR-016 | - | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-26 | VR-008, VR-014 | NFR-OBS-001, VR-008, VR-014 | - | 해당 WBS 정본의 조건·계약·검증 범위 |
| WBS-27 | - | - | P-11, P-20, P-21, P-28 | 공통 배포 artifact·정적 검증 |
| WBS-28 | VR-011 | VR-011 | P-30 | 전체 배포 readiness·운영 검증 handoff |
| WBS-29 | - | - | P-11, P-20, P-21, P-28, P-30 | 관련 smoke 및 별도 activation 승인 |
| WBS-30 | VR-006, VR-009 | NFR-COST-001, NFR-OBS-002, VR-006, VR-009 | - | 실제 운영 표본·6개 Gate 독립 판정 |
| WBS-31 | - | - | - | 전체 결과 회고·MVP-A/B disposition 분리 승인 |

## AC Reverse Map

[FACT] 연결 집합과 필요 증거 요약은 정본 AC matrix에서 가져왔습니다. 각 Requirement의 EV를 모아 `evidence/AC/AC-xx/<run-id>/manifest.json`에 연결할 계획입니다. AC evidence는 독립 복제 결과가 아니라 해당 실행 manifest 참조와 AC 전체 충족 검토를 포함합니다.

| AC ID | Requirement IDs | Required evidence | Status |
| --- | --- | --- | --- |
| AC-01 | FR-001, FR-003, EXT-GN-001 | News·Ask·Show fixture 후보 결과 | not_run |
| AC-02 | FR-002, FR-003 | prefix·keyword 변화에도 후보 유지 | not_run |
| AC-03 | FR-006, NFR-SEC-001 | AI payload와 외부 호출 감사 | not_run |
| AC-04 | FR-004, FR-005, NFR-REL-001, VR-005, VR-013, VR-015 | replay·중첩·후보 admission·응답 유실 중복 0건·lease fencing | not_run |
| AC-05 | FR-006, FR-007, NFR-DQ-001, DR-006, VR-018, VR-019 | 정상 분석 결과 계약 테스트 | not_run |
| AC-06 | FR-009 | 관심도 낮음·IT 영향도 높음 선정 표본 | not_run |
| AC-07 | FR-003, FR-009 | 관심 주제 밖 후보 유지 | not_run |
| AC-08 | FR-010, VR-007 | 경계 표본과 홍보성 FP 계산 | not_run |
| AC-09 | FR-011, NFR-LAT-002, VR-018 | 최신성 경계와 10·11·100건 순위·상한 테스트 | not_run |
| AC-10 | FR-007, FR-012, VR-018 | Discord 정상 item 검사 | not_run |
| AC-11 | FR-008, NFR-DQ-001 | 저정보 출력 fixture | not_run |
| AC-12 | FR-010, FR-012 | 제외 수량과 출력 대조 | not_run |
| AC-13 | FR-005, FR-012, NFR-REL-001, NFR-REL-002, NFR-DQ-002, VR-016, VR-017, VR-019 | 신규·실패·backlog와 source batch 정상 0건/recovery-only 조합 테스트 | not_run |
| AC-14 | FR-013, FR-014, NFR-REL-001, NFR-REL-002, NFR-DQ-002, VR-016, VR-017, VR-018, VR-019 | AI fault 상태 비교 | not_run |
| AC-15 | FR-012, FR-013, NFR-REL-002, NFR-DQ-002, VR-016, VR-017 | 입력 오류 수량·불완전 Top 10 경고와 AI 미완료 목록 미발송 검사 | not_run |
| AC-16 | FR-014, NFR-COST-001, NFR-DQ-002, VR-016, VR-017 | 전체 AI 실패 notice | not_run |
| AC-17 | FR-005, FR-015, NFR-REL-001, NFR-REL-002, NFR-DQ-002, EXT-DC-001, VR-012, VR-013, VR-018 | Discord 수락·미수락·partial message·lease fencing 시험 | not_run |
| AC-18 | FR-016, NFR-REL-001, NFR-REL-002, NFR-LAT-002, NFR-DQ-002, EXT-DC-003, EXT-DC-005, VR-012 | 다음 정규 발송·사용자 미수신 확인 기반 예외 복구·receipt scope End-to-End | not_run |
| AC-19 | FR-016, EXT-DC-004, VR-012 | 10+10 경계·physical message item subset 출력 | not_run |
| AC-20 | FR-017, FR-018, FR-019, DR-010, EXT-FB-001, EXT-FB-002, VR-010 | 기사·batch reaction과 암묵적 수용 계산 | not_run |
| AC-21 | FR-020, FR-021, FR-022, FR-023, DR-011, DR-012, EXT-FB-003, EXT-FB-004, EXT-FB-005, VR-010 | 누락 command·근거 회신·feedback·원인 분류 | not_run |
| AC-22 | FR-010, DR-008, VR-007 | 홍보성 제외 결과 표본과 FP 산출 | not_run |
| AC-23 | FR-024, NFR-LAT-001, VR-006, VR-014 | 기간·예정 batch·미실행·후보 최소 조건 검사 | not_run |
| AC-24 | FR-024, NFR-REL-002, NFR-PERF-001, NFR-LAT-001, NFR-LAT-002, NFR-COST-001, NFR-DQ-001, NFR-DQ-002, NFR-OBS-001, NFR-OBS-002, VR-001, VR-007, VR-008, VR-009, VR-014, VR-015 | Hard Gate·품질·서비스·미실행 예정 batch·후보 admission 결과 보고 | not_run |

## Non-AC Product Sources

[FACT] 정본 AC에 직접 연결되지 않은 Requirement의 제품 출처를 보존했습니다. AC를 새로 만들거나 기존 연결을 추정 확장하지 않습니다. 원문 조건은 각 Requirement 행에서 확인합니다.

| Requirement ID | Product source in requirements |
| --- | --- |
| NFR-SEC-002 | MVP-A Product Scope, Security and Secret Management, Cost Control, NFR-COST-001·NFR-SEC-001·NFR-OBS-001, 사용자 승인 |
| NFR-REC-001 | Recovery Scenarios 3·5·8, Product Batch States, AC-04, AC-14~AC-19, NFR-REL-001·NFR-REL-002·NFR-LAT-002·NFR-DQ-002·NFR-OBS-001·NFR-COST-001, 사용자 승인 |
| NFR-MNT-001 | Approved Solution 3B, MVP-A Scope, Evidence-bounded Analysis, Cost Control, AC-03·AC-05·AC-14·AC-16·AC-24, NFR-COST-001·NFR-SEC-001·NFR-SEC-002·NFR-REC-001, 사용자 승인 |
| NFR-MNT-002 | Feedback Policy, Scenario 9, AC-20~AC-21, FR-017~FR-023, DR-010~DR-011, EXT-FB-001~EXT-FB-005, 사용자 승인 |
| NFR-TIME-001 | 정규 발송·최신성·복구 정책, Scenario 1·5, AC-09·AC-18·AC-23~AC-24, FR-024, NFR-LAT-001·NFR-LAT-002, 사용자 승인 |
| NFR-REL-003 | Reliability, GeekNews 과도한 요청 금지, Failure Policy, AC-13~AC-17·AC-24, EXT-GN-001·EXT-GN-006, EXT-AI-002·EXT-AI-004~005, EXT-DC-002~003, VR-004, NFR-REL-001·NFR-COST-001, 사용자 승인 |
| DR-001 | Input Boundary, Scenario 1·5·9, AC-01~AC-05·AC-14~AC-15·AC-21·AC-24, FR-001~FR-006·FR-021~FR-024, NFR-DQ-001·NFR-OBS-001·NFR-REC-001, 사용자 승인 |
| DR-002 | Candidate Terms, Scenario 1·5·9, AC-01~AC-05·AC-09·AC-14~AC-15·AC-21·AC-24, FR-001~FR-006·FR-011~FR-012·FR-021~FR-024, NFR-REL-002·NFR-LAT-002·NFR-DQ-001·NFR-REC-001, 사용자 승인 |
| DR-003 | Duplicate Guardrail, Scenario 8·9, AC-04·AC-17~AC-18·AC-21·AC-24, FR-002·FR-004~FR-006·FR-020~FR-024, NFR-REL-001·NFR-REL-002·NFR-REC-001, 사용자 승인 |
| DR-004 | Candidate Terms·Batch States, Scenario 1~8, AC-13~AC-18·AC-24, FR-001~FR-016·FR-024, NFR-REL-001·NFR-REL-002·NFR-DQ-002·NFR-OBS-001·NFR-REC-001, 사용자 승인 |
| DR-005 | Candidate Terms·Scenario 2·5·8, AC-04·AC-17~AC-19·AC-24, FR-004~FR-005·FR-011~FR-012·FR-015~FR-016·FR-024, NFR-REL-001·NFR-REL-002·NFR-LAT-002·NFR-REC-001, 사용자 승인 |
| DR-007 | Candidate Terms·Batch States, Scenario 1~7, AC-08·AC-11~AC-18·AC-24, FR-002~FR-003·FR-007~FR-016·FR-024, NFR-DQ-001·NFR-DQ-002·NFR-REL-001·NFR-REL-002·NFR-REC-001, 사용자 승인 |
| DR-009 | Delivery Success·Recovery, Scenario 5·8·9, AC-04·AC-17~AC-21·AC-24, FR-004~FR-005·FR-012·FR-015~FR-018·FR-021·FR-024, NFR-REL-001·NFR-REL-002·NFR-OBS-001·NFR-REC-001·NFR-SEC-001, EXT-DC-001~EXT-DC-005, 사용자 승인 |
| DR-013 | Product Metrics·Quality Gate·Service Goals, AC-23~AC-24, FR-024, NFR-REL-002·NFR-PERF-001·NFR-LAT-001·NFR-LAT-002·NFR-COST-001·NFR-DQ-001·NFR-DQ-002·NFR-OBS-001~002, DR-001~DR-012·DR-014, 사용자 승인 |
| DR-014 | Cost Control·AI Provider·Security, AC-03·AC-05·AC-14·AC-16·AC-24, NFR-COST-001·NFR-SEC-001~002·NFR-MNT-001·NFR-OBS-001, EXT-AI-002~EXT-AI-005, 사용자 승인 |
| EXT-GN-002 | Collection and Recovery, AC-24 |
| EXT-GN-003 | Duplicate Guardrail, Scenario 8, AC-04 |
| EXT-GN-004 | Current Article Freshness, Reliability·Latency Metrics, AC-09·AC-18·AC-24 |
| EXT-GN-005 | Candidate Collection and Recovery, Scenario 1·8, AC-04·AC-24 |
| EXT-GN-006 | Failure Policy, Batch States, AC-13·AC-15·AC-24 |
| EXT-AI-001 | Evidence-bounded Analysis, Importance·Interest·Promotional Judgment, Low-information Article Item, AC-05~AC-11 |
| EXT-AI-002 | Capacity·Cost·Reliability, Service Goal Thresholds, AC-14·AC-16·AC-24 |
| EXT-AI-003 | Input Boundary, Security, AC-03·AC-24 |
| EXT-AI-004 | Cost Hard Gate, Free Quota Exhaustion, AC-14·AC-16·AC-24 |
| EXT-AI-005 | Failure Policy, Error Visibility, AC-14·AC-16·AC-24 |
| EXT-AI-006 | Success Metrics, Quality Metrics, Versioned Evaluation, AC-23·AC-24 |
| EXT-AI-007 | Failure Policy, Candidate Processing and Delivery, AC-14·AC-15·AC-16·AC-24 |
| EXT-DC-002 | Delivery Success, Failure Policy, Error Visibility, AC-17·AC-24 |
| EXT-DC-006 | Failure Policy, Batch States, Delivery Success, Error Visibility, AC-13~AC-18·AC-24 |
| EXT-FB-006 | Cost Control, Security, Feedback Policy, AC-03·AC-20·AC-21·AC-24 |
| VR-002 | AC-01~03, FR-001~003, EXT-GN-001·EXT-GN-006 |
| VR-003 | 전체 AC, Scenario 1~9, FR·NFR·DR·EXT, VR-004·VR-005·VR-010·VR-011 |
| VR-004 | AC-14~19, FR-013~016, NFR-REL-001~002, EXT-AI-004~007, EXT-DC-001~003·005 |
| VR-011 | 변동 가능한 외부 조건 |

## Decision Reverse Map

[INFERENCE] 아래는 Requirement Matrix의 역방향 연결입니다. 전체 설계 영향 목록이 아니라 누락 탐지와 읽기 시작점이며 실제 변경 시 공통 계약까지 확인합니다. AD 정본은 [Architecture register](../02-technical/architecture.md#key-architecture-decisions), DDI/MIN 정본은 [Data decision register](../02-technical/data-model.md#decision-review-register)입니다.

| Decision ID | Requirement IDs |
| --- | --- |
| AD-01 | FR-006, FR-007, FR-008, FR-009, NFR-LAT-002, NFR-DQ-001, NFR-MNT-001, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-002 |
| AD-02 | FR-001, FR-002, FR-003, FR-004, FR-005, NFR-REL-002, NFR-LAT-001, NFR-TIME-001, NFR-REL-003, DR-001, DR-002, DR-003, DR-004, DR-005, DR-006, DR-007, DR-008, DR-009, DR-010, DR-011, DR-012, DR-013, DR-014, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006, VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 |
| AD-03 | FR-004, FR-005, FR-016, NFR-REL-001, NFR-REL-002, NFR-LAT-001, NFR-TIME-001, NFR-REL-003, EXT-DC-003, EXT-DC-005, VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 |
| AD-04 | FR-006, FR-007, FR-008, FR-009, NFR-LAT-002, NFR-COST-001, NFR-DQ-001, NFR-SEC-001, NFR-SEC-002, NFR-MNT-001, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, EXT-FB-006 |
| AD-05 | FR-017, FR-018, FR-020, FR-021, FR-022, NFR-MNT-002, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 |
| AD-06 | VR-008, VR-011, VR-014 |
| AD-07 | FR-012, FR-015, FR-016, NFR-REL-001, EXT-DC-001, EXT-DC-002, EXT-DC-003, EXT-DC-004, EXT-DC-005, EXT-DC-006 |
| AD-08 | FR-004, FR-005, FR-010, FR-011, FR-013, FR-014, NFR-REL-002, NFR-LAT-001, NFR-DQ-002, NFR-TIME-001, NFR-REL-003 |
| AD-09 | NFR-REC-001, VR-011 |
| AD-10 | FR-001, FR-002, FR-003, FR-004, FR-005, NFR-REL-002, NFR-LAT-001, NFR-COST-001, NFR-SEC-001, NFR-SEC-002, NFR-REC-001, NFR-TIME-001, NFR-REL-003, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006, EXT-FB-006, VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 |
| AD-11 | FR-016, FR-017, FR-018, FR-020, FR-021, FR-022, NFR-REL-001, NFR-MNT-002, EXT-DC-003, EXT-DC-005, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 |
| AD-12 | FR-016, FR-017, FR-018, FR-020, FR-021, FR-022, NFR-REL-001, NFR-MNT-002, EXT-DC-003, EXT-DC-005, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 |
| AD-13 | NFR-COST-001, NFR-OBS-001, NFR-SEC-001, NFR-SEC-002, EXT-FB-006 |
| AD-14 | VR-011 |
| AD-15 | NFR-COST-001, NFR-OBS-001, NFR-SEC-001, NFR-SEC-002, EXT-FB-006, VR-006, VR-009, VR-011 |
| AD-16 | NFR-COST-001, NFR-OBS-001, NFR-SEC-001, NFR-SEC-002, EXT-FB-006 |
| AD-17 | FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-013, FR-014, NFR-LAT-002, NFR-DQ-001, NFR-DQ-002, NFR-MNT-001, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-003, VR-010, VR-016 |
| AD-18 | FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-013, FR-014, NFR-LAT-002, NFR-DQ-001, NFR-DQ-002, NFR-MNT-001, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-003, VR-010, VR-016 |
| AD-19 | FR-004, FR-005, FR-012, FR-015, NFR-REL-002, NFR-LAT-001, NFR-TIME-001, NFR-REL-003, EXT-DC-001, EXT-DC-002, EXT-DC-004, EXT-DC-006, VR-008, VR-014 |
| AD-20 | FR-010, FR-011, FR-012, FR-013, FR-014, FR-015, NFR-DQ-002, EXT-DC-001, EXT-DC-002, EXT-DC-004, EXT-DC-006, VR-003, VR-010, VR-016 |
| AD-21 | FR-016, NFR-REL-001, EXT-DC-003, EXT-DC-005 |
| AD-22 | NFR-REC-001, VR-011 |
| AD-23 | FR-019, FR-023, FR-024, NFR-PERF-001, NFR-OBS-002, VR-001, VR-006, VR-007, VR-008, VR-009, VR-014 |
| DDI-01 | FR-001, FR-002, FR-003, DR-001, DR-002, DR-003, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006, VR-002 |
| DDI-02 | FR-001, FR-002, FR-003, FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-013, FR-014, NFR-LAT-002, NFR-DQ-001, NFR-DQ-002, NFR-MNT-001, DR-004, DR-005, DR-006, DR-007, DR-008, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-019 |
| DDI-03 | FR-012, FR-015, FR-016, NFR-REL-001, DR-005, DR-008, DR-009, EXT-DC-001, EXT-DC-002, EXT-DC-003, EXT-DC-004, EXT-DC-005, EXT-DC-006 |
| DDI-04 | FR-016, FR-017, FR-018, FR-020, FR-021, FR-022, NFR-REL-001, NFR-MNT-002, DR-010, EXT-DC-003, EXT-DC-005, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 |
| DDI-05 | FR-004, FR-005, NFR-REL-002, NFR-LAT-001, NFR-REC-001, NFR-TIME-001, NFR-REL-003, VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 |
| DDI-06 | NFR-COST-001, NFR-OBS-001, NFR-SEC-001, NFR-SEC-002, NFR-REC-001, DR-014, EXT-FB-006, VR-006, VR-009, VR-011, VR-018 |
| DDI-07 | DR-001 |
| DDI-08 | FR-019, FR-023, FR-024, NFR-PERF-001, NFR-OBS-002, DR-012, DR-013, VR-001, VR-006, VR-007, VR-008, VR-009, VR-014 |
| DDI-09 | FR-004, FR-005, FR-006, FR-007, FR-008, FR-009, FR-010, FR-011, FR-013, FR-014, NFR-REL-002, NFR-LAT-001, NFR-LAT-002, NFR-DQ-001, NFR-DQ-002, NFR-MNT-001, NFR-TIME-001, NFR-REL-003, DR-004, DR-007, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-003, VR-010, VR-016 |
| DDI-10 | FR-016, FR-017, FR-018, FR-020, FR-021, FR-022, NFR-REL-001, NFR-MNT-002, DR-011, DR-012, EXT-DC-003, EXT-DC-005, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 |
| MIN-01 | FR-016, NFR-REL-001, NFR-REC-001, EXT-DC-003, EXT-DC-005 |
| MIN-02 | FR-019, FR-023, FR-024, NFR-PERF-001, NFR-OBS-002, DR-013, VR-001, VR-006, VR-007, VR-008, VR-009, VR-014 |
| MIN-03 | NFR-COST-001, NFR-OBS-001, NFR-SEC-001, NFR-SEC-002, DR-014, EXT-FB-006, VR-006, VR-009, VR-011, VR-018 |
| MIN-04 | FR-006, FR-007, FR-008, FR-009, NFR-LAT-002, NFR-DQ-001, NFR-MNT-001, DR-006, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-019 |
| MIN-05 | FR-004, FR-005, NFR-REL-002, NFR-LAT-001, NFR-TIME-001, NFR-REL-003, VR-004, VR-005, VR-012, VR-013, VR-015, VR-017, VR-018, VR-019 |
| MIN-06 | FR-006, FR-007, FR-008, FR-009, NFR-LAT-002, NFR-DQ-001, NFR-MNT-001, DR-006, EXT-AI-001, EXT-AI-002, EXT-AI-003, EXT-AI-004, EXT-AI-005, EXT-AI-006, EXT-AI-007, VR-019 |
| MIN-07 | FR-017, FR-018, FR-020, FR-021, FR-022, NFR-MNT-002, DR-010, EXT-FB-001, EXT-FB-002, EXT-FB-003, EXT-FB-004, EXT-FB-005 |
| MIN-08 | FR-001, FR-002, FR-003, FR-010, FR-011, FR-012, FR-013, FR-014, FR-015, NFR-DQ-002, DR-001, DR-002, DR-003, DR-004, DR-005, DR-006, DR-007, DR-008, DR-009, DR-010, DR-011, DR-012, DR-013, DR-014, EXT-GN-001, EXT-GN-002, EXT-GN-003, EXT-GN-004, EXT-GN-005, EXT-GN-006, EXT-DC-001, EXT-DC-002, EXT-DC-004, EXT-DC-006, VR-002, VR-003, VR-010, VR-016 |

## Hard Gate Evidence Map

[FACT] HG-01~06은 이 문서의 탐색용 별칭이며 새로운 제품 Requirement ID가 아닙니다. 여섯 Gate는 서로 독립 판정하고 evidence 부재를 pass 또는 비용 0원으로 간주하지 않습니다. 아래 Requirement는 직접 증거 연결의 시작점이며 다른 P0-HG 책임을 제외하지 않습니다.

| Gate ID | Gate | Requirement IDs | Realization lead | Verification chain | Mandatory negative / actual evidence | Planned location | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HG-01 | 추가 월 비용·유료 사용 0건 | NFR-COST-001, VR-009, EXT-AI-004 | WBS-11 | SPK-06A, SPK-06B, WBS-26, WBS-28, WBS-29, WBS-30 | 비용 불명 차단·kill switch·전 비용 범위 월 청구와 유료 event 대조; SPK-06B로 운영월 pass 대체 금지 | `evidence/HG/HG-01/<run-id>/manifest.json` | not_run |
| HG-02 | 미처리 후보 조용한 제외 0건 | FR-002, FR-003, FR-013, NFR-DQ-002, VR-015, VR-016, VR-019 | WBS-16 | WBS-23, WBS-24, WBS-25, WBS-30 | 혼합 entry·quota·101후보·late response에서 모든 후보 수량/이유 보존 및 부분 목록 0건 | `evidence/HG/HG-02/<run-id>/manifest.json` | not_run |
| HG-03 | 의도되지 않은 동일 기사 중복 발송 0건 | FR-004, NFR-REL-001, VR-005, VR-012, VR-013 | WBS-19 | WBS-24, WBS-25, WBS-30 | 동시 claim·응답 유실·receipt·1회 예외 재유실에서 scope별 중복 검사 | `evidence/HG/HG-03/<run-id>/manifest.json` | not_run |
| HG-04 | AI 실패의 신규 0건 오기록 0건 | FR-014, EXT-AI-005, VR-004, VR-016, VR-017 | WBS-16 | WBS-23, WBS-24, WBS-25, WBS-30 | 전체 quota/timeout/검증 실패를 빈 feed/정상 0건과 구분하고 실패 notice 확인 | `evidence/HG/HG-04/<run-id>/manifest.json` | not_run |
| HG-05 | Discord 미수락의 성공 기록 0건 | FR-015, DR-009, EXT-DC-001, EXT-DC-003, VR-012 | WBS-17 | SPK-03, WBS-24, WBS-25, WBS-30 | 부분 수락·응답 유실·사용자 receipt에서 서버 수락 긍정 근거 없는 성공 0건 | `evidence/HG/HG-05/<run-id>/manifest.json` | not_run |
| HG-06 | 중대한 근거 밖 사실 0건 | FR-006, NFR-DQ-001, EXT-AI-001, VR-019 | WBS-15 | SPK-02, WBS-23, WBS-25, WBS-30 | 저정보·근거 없는 주장 주입 검증과 실제 RSS 대조 품질 표본; mock만으로 실제 품질 pass 금지 | `evidence/HG/HG-06/<run-id>/manifest.json` | not_run |

## Evidence and Status Rules

[INFERENCE] 저장 root는 repository-relative `evidence/`로 계획하되 지금 빈 디렉터리나 가짜 manifest를 만들지 않습니다. 실제 저장·민감정보 보존 계약은 WBS-03/08에서 확정합니다. `<run-id>`는 실행 때 UTC 시각과 충돌 없는 식별자로 치환합니다. 재실행은 새 경로이며 과거 evidence를 덮어쓰지 않습니다.

[INFERENCE] 실제 manifest에는 ID(Requirement/AC/HG/Decision/WBS), 기준선 fingerprint, 실행 시각·환경·fixture/procedure version, expected/actual, redacted artifact 경로·hash, 실행 계층(synthetic/actual), 판정·한계·blocker·검토자를 기록합니다. credential·원 사용자 식별자·허용되지 않은 원문은 포함하지 않습니다. Git fingerprint가 필요해도 Agent는 현재 지시에 따라 Git을 조회하지 않으며 추후 사용자가 제공한 값과 확인 범위를 구분합니다.

[FACT] 현재 모든 행의 `not_run`은 증거 미수집 상태입니다. 문서 검사 결과는 로컬 정합성만 의미합니다. 향후 실제 실행 상태 체계는 해당 WBS 정본을 따르며, spike의 pass/fail/blocked/inconclusive, Hard Gate의 pass/fail/not_measurable, 표본·품질·서비스 판정을 하나의 boolean으로 합치지 않습니다. 자동 검사기는 이 미실행 기준선을 검사하므로 실제 evidence를 연결할 때 상태 검증 규칙도 명시적으로 확장해야 합니다.

[FACT] MVP-A Raw/AI 결과 보존과 MVP-B의 월별 Insight·normalization·자동 Retention lifecycle을 구분합니다. DDI-07 연결은 경계 보존 검증이며 MVP-B 구현을 승인하지 않습니다.

## Blockers and Consistency Register

| ID | State | Owner | Resolution / evidence |
| --- | --- | --- | --- |
| B-01 | resolved | WBS-01 | 2026-09-11 사용자 체크리스트 1번 승인. 각 행의 B-01은 해소 이력 reference이며 현재 blocker는 B-02·B-03 |
| B-02 | not_run | WBS-02, WBS-03, WBS-04, WBS-05, WBS-06, WBS-07, WBS-08, WBS-09 | 관련 spike·물리/인터페이스 계약·실제 READY 미확보. 각 행 profile과 원본 WBS 선행 조건 기준으로 해소 |
| B-03 | not_run | 각 행 Verification owner | 구현·실행 evidence 미확보. 실제 suite·SPK·smoke·운영 evidence를 분리 수집 |
| C-01 | no_contract_change | WBS-01 | Requirement/AC/AD/DDI/MIN 정본은 수정하지 않음. 현재 baseline의 ID/priority/역방향 연결 검사는 아래 자동 검사로 재현 |
| C-02 | reviewed | WBS-01 | 사용자 기준선 승인 반영. 이후 변경 시 의미 영향 검토는 재수행하며 집합 검사는 의미적 완전성을 보장하지 않음 |
| C-03 | historical_closed | 문서 정본 | 과거 F01~F08 정합성 수정 승인은 검토 이력에서 유지. 이번 작업은 과거 전체 감사를 재수행하거나 새로운 정정 승인을 추정하지 않음 |

## Static Coverage Check

[FACT] [로컬 검사기](../../scripts/check-traceability.ps1)는 파일만 읽고 Git·네트워크·DB·외부 API를 호출하지 않습니다. 저장소 root와 무관하게 script 위치 기준으로 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\project\scripts\check-traceability.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\project\scripts\check-traceability.ps1 -SelfTest
```

[INFERENCE] 검사는 Requirement 집합·우선순위·owner/profile·planned EV 경로·34개 P0-HG negative·AC 정본 일치/역방향·Non-AC 출처·41개 decision 역방향·6개 Gate·미실행 상태를 대조합니다. SelfTest는 메모리 내 변형으로 누락·중복·잘못된 owner·negative 누락·AC drift·decision orphan·허위 pass를 탐지하는지 확인하며 실제 문서를 변조하지 않습니다. 의미 검토·runtime 테스트·공식 외부 계약 검증을 대체하지 않습니다.
