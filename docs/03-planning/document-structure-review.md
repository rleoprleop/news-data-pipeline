# Documentation Structure Review

## Status and Scope

[FACT] 검토 ID: `DOC-STRUCTURE-SCOPE-01`, 실행 ID: `DOC-STRUCTURE-SPLIT-01`. 사용자가 2026-09-10 B안의 실제 분리를 승인하여 반영했고 2026-09-14 사후 검토 완료를 확인했습니다. 아래 관찰·대안·제안은 분리 전 검토 기록이며, 실행 결과는 마지막 절을 참조합니다.

[FACT] F01~F08 승인 내용, Product·Requirement·AD·DDI·MIN 및 WBS의 조건·의존성·완료 기준은 이번 검토에서 변경하지 않았습니다. 코드·테스트·실행 설정은 없으며 Git 상태·history는 사용자 지시에 따라 확인하지 않았습니다. 과거 변경 과정은 문서에 기록된 승인 이력만 참고했습니다.

## Observations

- [FACT] 검토 시작 시 Repository에는 Markdown 13개가 있습니다. 구현 계획은 5,306줄, AI Context는 583줄, README는 119줄입니다.
- [FACT] [구현 계획](implementation-plan.md)은 WBS 요약표, WBS-03~31 상세 checkpoint, spike·traceability·milestone·risk 및 과거 승인 이력을 함께 포함합니다. 상세 checkpoint 구간은 당시 105~5,034행으로 4,930줄입니다.
- [FACT] WBS-01·02는 전체 WBS 요약표에 있으며 WBS-03처럼 별도 상세 checkpoint 절이 없습니다. 구조 개선을 이유로 새 상세 설계를 작성할 근거는 없습니다.
- [FACT] [README](../../README.md)와 [AI Context](../../ai-context.md)는 현재 상태 외에도 단계별 승인·과거 commit 기록을 포함합니다. 구현 계획의 Sequential Review State에도 날짜별 승인 기록이 있습니다.
- [FACT] WBS-18·19·26은 Data·Interface 정본을 명시적으로 연결합니다. [Data Model](../02-technical/data-model.md)의 Decision Review Register가 DDI/MIN 승인 정본이며 [Interface Specification](../02-technical/interface-spec.md)은 역할별 계약을 정의합니다.
- [INFERENCE] 탐색 부담과 상태 갱신 지점의 분산은 확인되지만, 문구 반복 전체를 불필요한 중복으로 간주할 수는 없습니다. 설계 조건과 그 조건을 구현·검증할 책임은 서로 다른 정보입니다.
- [INFERENCE] 파일 분리와 의미 축약을 동시에 하면 F01~F08의 예외·금지 조건이나 검증 책임이 유실됐는지 구분하기 어렵습니다. 먼저 위치만 바꾸고 의미 중복 제거는 별도 검토하는 편이 안전합니다.

## Alternatives

| 안 | 변경 범위 | 장점 | 비용·한계 |
| --- | --- | --- | --- |
| A — 단일 파일 유지 | 목차·WBS 바로가기와 상태 안내만 보강 | 이동·참조 파손 위험이 가장 작음 | 5천 줄 이상의 본문과 승인 이력이 계속 한 파일에 남음 |
| B — 역할별 분리 | 기존 계획을 진입점으로 유지하고 상세 계획·검증·이력을 별도 파일로 이동 | 작업 단계별로 읽을 범위와 유지보수 책임이 명확해짐 | 링크 이전·본문 보존 검증 필요; 설계 상세 파일은 여전히 큼 |
| C — 전면 정본화 | B에 더해 상위 설계와 반복되는 조건을 축약하고 README·Context 이력도 재배치 | 장기적으로 반복과 상태 갱신 부담 감소 가능 | 의미 판단·승인 이력 재분류가 필요하며 감사 수정 회귀 위험이 가장 큼 |

[INFERENCE] 추천은 **B**입니다. C는 이번 분리와 묶지 않습니다. 목표는 줄 수를 임의로 줄이는 것이 아니라 승인된 내용을 작업 역할별로 찾아 읽을 수 있게 하는 것입니다.

## Proposed B Layout

[FACT] 아래 경로·경계의 B안을 2026-09-10 승인받아 적용했습니다. 기존 진입점과 신규 여섯 파일을 합해 일곱 계획·이력 파일이며, 이 검토 문서는 일곱 개에 포함하지 않습니다. 표의 신규 제안 표기는 당시 제안 기록입니다.

| 대상 파일 | 기존 내용의 배치 | 정본 책임 |
| --- | --- | --- |
| `implementation-plan.md` (유지) | Status·Context·Assumptions/Unknowns·Strategy, WBS-01~31 요약표, Milestones, Risks, 다음 작업 안내 | 계획 진입점·전체 순서·요약·승인 gate; 각 WBS 상세 위치 연결 |
| `design-readiness-plan.md` (신규 제안) | WBS-03~09 상세 checkpoint 전체 | 미래 상세 설계와 Coding Readiness의 작업·검증 계획; 실제 물리 설계 결과 아님 |
| `feature-implementation-plan.md` (신규 제안) | WBS-10~22 상세 checkpoint 전체 | 기능 구현 작업과 각 작업 내부 테스트·완료 기준 |
| `integrated-verification-plan.md` (신규 제안) | WBS-23~26 상세 checkpoint 전체 | 통합 계약·동시성·fault·E2E·운영 전 검증 계획; 실행 결과 아님 |
| `release-operations-plan.md` (신규 제안) | WBS-27~31 상세 checkpoint 전체 | artifact·배포 readiness·실제 배포·monitoring·회고의 구분된 승인 경계 |
| `validation-traceability-plan.md` (신규 제안) | External Validation / Spike Plan, Requirement Traceability Plan 전체 | SPK-01~06·Hard Gate·계획상 owner 연결; 실제 99행 evidence matrix를 만들거나 완료 처리하지 않음 |
| `implementation-review-history.md` (신규 제안) | Proposed Documentation Changes, Sequential Review State의 날짜별 승인·감사 기록 | 당시 승인 경위와 F01~F08 기록; 현재 Task의 정본이 아님 |

[INFERENCE] 기존 상세 heading과 WBS 하위 ID는 유지합니다. 각 신규 파일은 목적·계획 승인 상태·미실행 경계와 상위 진입점 링크만 추가합니다. WBS 요약표의 기존 조건은 유지하고 ID에 상세 위치 링크를 연결하며, WBS-01·02는 기존 요약 및 spike·traceability 계획으로 연결합니다.

[INFERENCE] 현재 Task·활성 blocker·다음 작업의 정본은 AI Context로 유지합니다. 구현 계획의 현재 검토 포인터와 Recommended Next Action은 AI Context를 참조하게 하고 과거 승인 완료 Task를 현재 Task로 복제하지 않습니다. README는 계획 진입점을 유지하며 필요시 설명만 조정합니다.

[INFERENCE] B에서도 설계 상세 구간은 약 2,353줄, 구현 상세 구간은 약 1,407줄로 남습니다. 처음부터 WBS마다 파일을 만드는 과도한 분할은 피하고, 후속 사용에서 탐색 부담이 남으면 별도로 재검토합니다.

## Change Boundary and Preservation

- [INFERENCE] 실행 승인 요청 범위는 기존 구현 계획의 기계적 분리, 신규 여섯 파일, README·AI Context의 탐색·상태 동기화, 이 검토 문서의 승인 기록입니다. 기존 Product·Technical 문서와 AGENTS는 수정 대상에서 제외합니다.
- [INFERENCE] Requirement 99개, AC 24개, AD 23개, DDI 10개, MIN 8개, WBS 31개, SPK 6개의 식별자와 기존 참조 의미를 유지합니다. 현재 없는 WBS-01 실행 산출물·코드·fixture·runbook을 생성하지 않습니다.
- [INFERENCE] 반복 조건·금지 사항·negative test·owner·승인 경계를 삭제하거나 요약하지 않습니다. 제목·링크·파일 안내 외 본문 의미 변경이 필요해지면 해당 부분은 이동을 멈추고 별도 문제로 보고합니다.
- [INFERENCE] Markdown 링크뿐 아니라 `WBS-19.B3`, `이 문서`, `위/아래`, 절 이름 같은 텍스트 참조도 검사합니다. 상대 링크는 같은 디렉터리 기준을 유지하고 이동된 절은 정확한 대상 파일·anchor로 연결합니다.
- [INFERENCE] 기존 계획의 이동된 최상위 WBS heading 및 주요 절 anchor에는 짧은 이동 안내를 남겨 기존 deep link를 최대한 유지합니다. Repository 내 다른 하위 heading 참조도 검색해 갱신합니다. 호환 안내에는 본문을 복제하지 않습니다.
- [UNKNOWN] Repository 밖에서 사용 중인 모든 deep link는 확인할 수 없습니다. 외부 링크를 전부 보존했다고 주장하지 않으며, 알려진 링크가 추가로 제공되면 해당 anchor를 검증합니다.
- [INFERENCE] README·AI Context의 과거 이력 대량 삭제·별도 archive 이동은 C에 해당하므로 이번 B에서 수행하지 않습니다. 미래 상세 설계 정본을 현재 논리 설계 대신 새 계획 파일로 바꾸지도 않습니다.

## Execution and Acceptance Plan

1. [INFERENCE] B 범위 승인 후 원본 파일·섹션·heading·ID·링크 목록과 SHA256을 읽기 전용으로 기록합니다. Git 명령은 사용하지 않습니다.
2. [INFERENCE] WBS와 주요 절 단위 이동표를 확정하고 본문을 그대로 옮깁니다. 각 원본 블록은 정확히 하나의 대상 본문에 대응해야 합니다. 기존 WBS 요약표와 상세 본문의 서로 다른 역할은 유지합니다.
3. [INFERENCE] 진입점·호환 anchor·교차 링크·현재/역사 상태 안내를 연결합니다. 본문 비교에서 허용하는 차이는 별도로 열거한 제목·링크·안내 변경뿐입니다.
4. [INFERENCE] 원본 대비 블록 누락·중복 이동 0건, WBS-03~31 상세 root 각 1개, 요약표 WBS 31행, SPK 6행과 모든 참조 ID의 유효성을 검사합니다. 호환 anchor는 상세 본문으로 계산하지 않습니다.
5. [INFERENCE] F01~F08 조건 보존, 표 열 수·fence·상대 링크·anchor 유효성, 문맥 의존 참조와 날짜별 승인 상태를 검사합니다. 상위 설계 문서의 SHA256 불변도 확인합니다.
6. [INFERENCE] 문서 검증 결과와 남은 위험을 보고하고 변경 후 사용자 검토를 받습니다. 구조 개선 완료를 Coding Readiness·구현 완료로 기록하지 않습니다.

## Decision Needed

[FACT] 2026-09-10 사용자의 `분리 진행` 요청으로 B의 파일 경계와 내용 보존 방식에 따른 실제 분리 범위가 승인됐습니다. 의미 축약·상위 설계 변경은 승인 범위가 아닙니다.

[FACT] 분리 후 탐색성 점검과 목차 보완을 진행했습니다. 2026-09-10 사용자 지시에 따라 중간 commit 안내를 생략하며 Git은 사용자가 전체 작업 완료 후 직접 관리합니다.

## Split Execution Record

[FACT] 2026-09-10 승인된 B안에 따라 여섯 파일을 추가하고 기존 진입점·README·AI Context를 갱신했습니다. 원본 전체 파일의 SHA256은 `B3053AA14CAE50166C96E37FDB2416BB69A45BB9622E6E17FEDA054F4C6AECFF`입니다. 이 값은 Git이 아닌 분리 직전 파일 기준입니다.

| 이동 대상 | 원본 행 (분리 직전) | 이동 본문 줄 수 |
| --- | --- | --- |
| [design-readiness-plan.md](design-readiness-plan.md) | 105~2457 | 2353 |
| [feature-implementation-plan.md](feature-implementation-plan.md) | 2458~3864 | 1407 |
| [integrated-verification-plan.md](integrated-verification-plan.md) | 3865~4433 | 569 |
| [release-operations-plan.md](release-operations-plan.md) | 4434~5034 | 601 |
| [validation-traceability-plan.md](validation-traceability-plan.md) | 5035~5106 | 72 |
| [implementation-review-history.md](implementation-review-history.md) | 5145~5303 | 159 |

[FACT] 허용한 차이는 신규 파일 안내·상태, 기존 진입점의 WBS ID 링크·이동 heading·다음 작업 안내와 README·Context 상태 동기화입니다. 이동 본문 자체는 축약·조건 변경 없이 보존했습니다. WBS-01·02 상세 설계나 실제 99행 evidence matrix를 추가하지 않았습니다.

[FACT] 기존 WBS-03~31 root heading 29개와 spike·traceability·Hard Gate·과거 정정·검토 이력 절에 호환 안내를 남겼습니다. 다른 파일로 향하는 WBS 텍스트 참조는 각 문서 상단의 전체 WBS 안내로 찾을 수 있습니다. 같은 WBS 내부의 위/아래 checkpoint 순서는 유지합니다.

[UNKNOWN] Repository 밖의 모든 하위 절 deep link 호환은 보장하지 않습니다. 계획 분리의 완료는 실제 설계·구현·runtime 검증·배포 완료를 뜻하지 않습니다.

### Verification Results

- [FACT] 여섯 이동 본문의 총 5,161줄은 분리 직전 원본과 줄바꿈 정규화 후 정확히 일치합니다. 신규 안내를 포함한 각 파일과 기존 진입점도 계획된 변환 결과와 일치합니다. 따라서 이동 본문에 포함된 F01~F08 조건·검증 계획·승인 기록은 그대로 보존됐습니다.
- [FACT] WBS 요약 31행, 이동된 상세 root 29개(WBS-03~31, 각 1개), SPK 6행을 확인했습니다. 상위 Requirement·AC·AD·DDI·MIN 정본을 포함한 기존 비대상 10개 파일의 SHA256은 모두 분리 전과 같습니다.
- [FACT] 전체 Markdown 20개의 표 292개, 로컬 링크 169개(그중 heading anchor 링크 78개), fence·trailing whitespace 검사를 통과했습니다. Anchor는 Markdown heading 기반 정적 검사이며 외부 문서의 링크 사용이나 모든 렌더러의 동작을 검증한 것은 아닙니다.
- [FACT] 구현 계획 진입점은 5,306줄에서 292줄로 바뀌었습니다. 본문은 삭제하지 않고 역할별 문서로 이동했으며 전체 문서량 축약은 수행하지 않았습니다.
- [FACT] 코드·runtime·동시성 테스트·외부 spike·배포와 Git 명령은 실행하지 않았습니다. 변경 후 사용자 검토는 대기입니다.

### Navigation Follow-up

[FACT] 2026-09-10 여섯 분리 문서 상단에 WBS·주요 절 목차 링크 34개를 추가하고 README의 역할·WBS 범위를 한국어로 안내했습니다. 목차는 기존 heading을 연결하며 본문 조건·식별자·승인 이력은 변경하지 않았습니다.
