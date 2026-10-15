# AGENTS.md

## Purpose

[FACT] 이 파일은 여러 AI Agent가 대화 기억에 의존하지 않고 이 Repository를 이어서 작업하기 위한 공통 운영 규칙입니다.

[FACT] 모든 Agent는 작업 시작 시 이 파일 전체와 `ai-context.md`의 `Active Context` 절을 읽습니다. AI Context의 `Reference Context` 이하와 나머지 문서는 작업에 필요한 절만 읽으며 전체 파일 정독을 기본값으로 삼지 않습니다.

## Source of Truth

[FACT] 정보가 충돌하면 다음 순서로 확인합니다.

1. 현재 실제 Code
2. Git History
3. Architecture 및 Technical Documents
4. Product Documents
5. `ai-context.md`
6. 이전 AI 대화

[FACT] 이 순서는 자료가 충돌할 때의 대조 기준이지 모든 자료를 매번 읽으라는 뜻이 아닙니다. 사용자 지시에 따라 현재 Git 확인은 금지되어 있으므로 이력 대조가 필요한 경우 Git은 조회하지 않고 미확인으로 표시합니다.

[FACT] Code와 문서가 다르다는 이유만으로 Code를 자동으로 정답으로 간주하지 않습니다.

[FACT] 불일치가 발견되면 변경 전에 다음을 보고합니다.

1. Code의 현재 동작
2. 문서에 정의된 의도
3. Git History에서 확인되는 변경 과정
4. 불일치의 영향
5. 추천 기준

## Required Start-of-Task Check

[FACT] 모든 작업 시작 시 다음 순서로 필요한 범위만 확인합니다.

1. 이 파일 전체와 [현재 Context](ai-context.md#active-context)를 읽어 최신 사용자 지시·승인 경계·현재 Task를 확인합니다.
2. [작업별 탐색표](docs/task-navigation.md)에서 현재 작업에 맞는 행을 선택합니다. 문서 경로·구조가 불명확하면 `rg --files` 또는 README의 Documents 절로 위치만 확인합니다.
3. 대상 WBS와 직접 관련된 Requirement·Data·Interface·Architecture 절, 해당 코드·테스트 및 적용되는 하위 AGENTS를 확인합니다. WBS를 실행하지 않는 문서·상태 작업에는 무관한 기능 계약을 읽지 않습니다.
4. TODO/FIXME는 대상 파일·관련 모듈에서 검색합니다. 코드·테스트가 없는 문서 작업은 부재를 확인하고 실행 테스트를 꾸며내지 않습니다.
5. 관련 선행 조건·공통 불변식·호출자/소비자·승인 근거를 확인한 뒤 작업합니다. Git 명령은 실행하지 않습니다.

[FACT] 탐색표는 읽기 시작점이지 완결된 의존성 목록이나 실행 승인서가 아닙니다. 선택한 절의 조건·예외·표·검증 기준을 끝까지 읽고, 상위 절의 공통 규칙과 직접 참조한 계약 중 변경에 영향을 주는 부분까지 확장합니다. 검색 결과 한 줄이나 목차만으로 코드를 변경하지 않습니다.

[FACT] 영향 범위·정본이 불명확하거나 문서 간 충돌·공통 인터페이스 변경·전체 감사 요청이 있으면 이유를 밝히고 읽기 범위를 넓힙니다. 전체 정독은 해당 파일 전체가 실제로 필요할 때 수행하며, 읽지 않은 부분까지 검토했다고 보고하지 않습니다. 선택한 skill 지침 등 상위 지시에서 전체 읽기를 요구하는 경우에는 그 지시를 따릅니다.

[FACT] 동일 Task에서 이미 읽은 내용은 변경 여부나 새 의존성 확인이 필요할 때만 다시 읽습니다. 큰 파일은 heading 위치를 검색한 뒤 해당 절을 추출하고, 도구의 파일 해시·링크 정적 검사를 위한 기계적 스캔과 Agent의 본문 정독을 구분합니다.

[FACT] 파일이나 이력이 없다면 없다고 보고하며 기존 내용을 추정하지 않습니다.

[FACT] 사용자 작업을 덮어쓰거나 되돌리지 않습니다.

## Fact and Assumption Tags

[FACT] 분석, 설계와 상태 보고에는 다음 태그를 사용합니다.

- `[FACT]`: Repository, 공식 자료 또는 사용자가 확정한 내용
- `[ASSUMPTION]`: 진행을 위해 임시로 둔 가정
- `[INFERENCE]`: 사실과 가정에서 도출한 판단 또는 추천
- `[UNKNOWN]`: 추가 확인이나 결정이 필요한 내용

[FACT] 사용자가 `[CONFIRMED]`로 제공한 내용은 Repository 문서에서 `[FACT]`로 기록할 수 있습니다.

## Development Workflow

[FACT] 경량 SDD + 점진적 개발 + 위험 기반 테스트를 적용합니다. 아래 단계는 프로젝트 생명주기이며 이미 승인된 단계를 매 작업마다 다시 수행하지 않습니다. 전체 프로젝트를 한 번에 구현하지 않습니다.

1. Problem Definition
2. Research / JTBD
3. Solution Discovery
4. Feature Prioritization
5. Product Specification
6. Technical Requirements
7. Architecture
8. Data / Interface Design
9. Implementation Plan
10. Coding Readiness Check
11. Feature Implementation
12. Testing
13. Code Review
14. Context / Documentation Sync
15. Git Commit Review
16. Deployment
17. Monitoring
18. Retrospective

[FACT] 현재 단계와 승인 상태는 `ai-context.md`에서 확인합니다.

[FACT] 개발 작업은 `현재 WBS 선택 → 관련 기존 명세·설계 확인 → 네 가지 구현 준비 조건 확인 → 필수 미결정 사항만 해결 → 현재 범위 구현 → 위험에 맞는 테스트 → 코드 리뷰·필요한 수정 → 완료 조건 검증 → WBS·Active Context 동기화` 순서로 진행합니다. Workflow 10~14는 이 작업별 반복 흐름으로 적용하며, Workflow 15의 Agent Git 절차는 현행 Git Rules에 따라 비활성입니다. 배포·운영·MVP-B 진입 경계는 유지합니다.

[FACT] WBS를 더 나누는 것은 독립적인 구현·검증에 실질적으로 필요한 경우로 한정합니다. 해당 단위의 필수 검증과 완료 확인 후 다음 단위로 이동합니다.

## Design Before Code

[FACT] 현재 구현 범위의 요구사항·필수 계약과 제약이 확정되기 전에는 구현하지 않습니다. 기존 승인 명세를 참조하고 명확한 결함·계약 변경 근거가 없는 기술 선택은 재검토하지 않습니다. 후속 기능의 상세 결정을 현재 작업의 선행 조건으로 삼지 않습니다.

[FACT] 구현 준비는 ① 목표가 명확한가 ② 필수 계약·제약이 정해졌는가 ③ 현재 구현을 막는 미결정 사항이 없는가 ④ 완료를 검증할 수 있는가로 확인합니다. 대상 실행 승인이 있고 네 조건을 충족하면 추가 설계 검토 없이 구현합니다. 적용되는 안전·외부 계약·무결성 검증은 생략하지 않습니다.

[FACT] 작업별 정보는 목적, 입력·출력/주요 계약, 범위·제외 범위, 완료 조건, 핵심 검증 방법으로 제한합니다. 기존 문서에 있으면 경로·절·ID를 참조하며 새 명세나 중복 관리 파일을 만들지 않습니다. 필수 결정이 부족할 때만 해당 기존 절에 보완합니다.

[FACT] 구현 중 기존 설계와 충돌하는 문제가 발견되면 코드를 먼저 변경하지 않고 다음을 보고합니다.

1. 기존 설계
2. 발견된 문제
3. 가능한 해결책
4. Trade-off
5. 추천안
6. 영향받는 문서와 코드

## Scope and Change Control

[FACT] 하나의 Task에서는 해당 Task에 필요한 최소 범위만 변경합니다.

[FACT] 관련 없는 리팩터링, 구조 변경과 기술 추가를 수행하지 않습니다.

[FACT] YAGNI·KISS에 따라 현재 요구를 만족하는 단순한 구현과 기존 아키텍처·공통 모듈을 우선합니다. 미래 확장만을 위한 추상화·계층·라이브러리를 추가하지 않습니다.

[FACT] 발견 사항은 `BLOCKER`(현재 진행에 반드시 해결 필요), `REQUIRED`(필수 요구·안전·정합성 문제), `DEFERRED`(현재 범위 밖의 선택적 개선·후속 결정)로 분류합니다. 현재 범위에 적용되는 BLOCKER·REQUIRED는 완료 전 해결합니다. 범위 밖의 필수 요구는 원래 owner·진입 조건을 유지하며 기존 우선순위·필수 요구를 DEFERRED로 낮추지 않습니다. DEFERRED는 현재 완료를 차단하지 않습니다.

[FACT] 이미 승인된 범위의 구현·검증·범위 내 결함 수정·문서 동기화에 동일 승인을 반복 요구하지 않습니다. 범위 내 수정은 관련 WBS와 실제 변경·재검증 결과를 연결합니다. 실질적 scope·핵심 설계·비용/권한 변경, 데이터 손실 가능 작업·외부 검증·배포는 기존 별도 승인 경계를 따릅니다.

[FACT] 다음 작업은 사용자 승인 없이 실행하지 않습니다.

- Scope 변경
- Architecture의 핵심 결정 변경
- 기존 파일의 대규모 수정 또는 삭제
- 데이터 손실 가능성이 있는 작업
- 배포
- Git commit
- Git push

[FACT] Kafka와 Spark는 실제 규모와 요구사항으로 필요성이 입증되기 전까지 도입하지 않습니다.

## Current Product Guardrails

- [FACT] MVP 수집원은 GeekNews RSS 하나입니다.
- [FACT] MVP는 한국어 IT 뉴스만 다룹니다.
- [FACT] MVP-A는 일일 P0와 최소 판단 근거·결과 version, 사용자 feedback 및 초기 사용량·지연·품질 측정을 포함합니다.
- [FACT] 월별 Insight, 장기 결과 재사용·normalization과 자동 Retention lifecycle은 MVP-A 검증 후 MVP-B에서 다룹니다.
- [FACT] 외부 원문 기사 본문은 수집하지 않습니다.
- [FACT] 무료 AI 제공자 하나만 연동하며 여러 제공자를 동시에 구현하지 않습니다.
- [FACT] AI 제공자는 아직 최종 확정되지 않았습니다. Gemini 무료 API를 우선 검증하던 방향은 유지했지만, 2026-09-14 공식 추가 약관의 consumer-use 제외와 확정된 개인 소비자 목적이 충돌했고 사용자가 개인 소비자 목적 유지를 확인해 새 SPK-06A를 provider 호출 0회 `fail`, Gemini API 후보를 `rejected`로 판정했습니다. Gemini 실제 검증과 provider 채택은 차단하며, 다른 제공자·로컬 AI로 자동 전환하지 않습니다. Provider 후보·검증 범위 변경은 별도 사용자 승인과 change control이 필요합니다.
- [FACT] 유료 API 호출로 자동 전환하면 안 됩니다.
- [FACT] 추가 월 운영비 상한은 0원입니다.
- [FACT] 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다룹니다.
- [FACT] News, Ask와 Show는 모두 후보 자격을 유지하되 모든 항목에 동일한 수준의 AI 처리를 보장하지 않으며 처리하지 못한 후보를 조용히 제외하지 않습니다.
- [FACT] 유효 후보의 필요한 AI 처리가 미완료인 동안에는 기사 목록을 발송하지 않습니다. 전체 선정이 완료되면 원래 batch의 최대 10개 처리 지연 full result를 발송하고, 전체 선정이 불가능하면 원인별 처리 실패 notice를 발송합니다.
- [FACT] 처리 지연 full result와 Discord 미수락 복구 backlog는 별도 논리 구간이며 서로 섞지 않습니다.
- [FACT] 장애나 한도 소진에 따른 미발송은 신규 기사 0건 미발송과 구분하고 실패 사실과 미처리 건수를 확인할 수 있어야 합니다.
- [FACT] Raw RSS, 기사별 AI 결과와 월별 Insight의 Retention 정책을 구분합니다.

[FACT] 상세 범위와 검증 항목은 `docs/01-product/problem.md`를 기준으로 확인합니다.

## Testing

[FACT] 구현 완료를 선언하기 전에 관련 테스트를 실행합니다.

[FACT] 실행한 테스트와 결과를 구분해 보고합니다.

[FACT] 실행하지 않은 테스트를 통과했다고 표현하지 않습니다.

[FACT] 모든 작업에 TDD를 의무화하지 않습니다. 데이터 무결성·상태 전이·중복·실패/재시도/복구·외부 계약·보안/권한·핵심 업무 규칙은 테스트 우선을 적극 고려하고, 기반 설정·단순 구현은 구현 후 자동화 테스트를 허용합니다. 정상 경로·주요 실패·중요 경계를 우선하며 테스트 개수 자체를 목표로 하지 않습니다.

[FACT] 리뷰는 현재 범위의 계약 위반·안전·정합성·검증 누락·회귀에 집중합니다. 수정 뒤 영향받는 검증을 실행하고 새 변경·실패·미해결 우려가 없으면 전체 검토를 반복하지 않습니다. 테스트 실패는 원인을 분석해 현재 작업과 직접 관련된 문제만 수정하며, 동일 원인이 반복되거나 설계 변경이 필요하면 원인·대안을 보고하고 무한 반복하지 않습니다.

[FACT] 현재 작업의 완료 조건과 필수 테스트를 충족하고, 적용 범위의 중대한 오류·미해결 위험 및 확인된 회귀가 없으며 문서·WBS가 실제 구현/검증 상태와 일치하면 완료합니다. 선택적 개선 때문에 작업을 연장하지 않습니다. 작업 완료를 미실행 통합·운영 검증이나 후속 WBS의 완료로 확대하지 않습니다.

## Documentation and Context Sync

[FACT] 중요 결정과 구현 변경은 관련 Repository 문서에 반영합니다.

[FACT] 각 Task 종료 시 `ai-context.md`의 `Active Context`에 있는 다음 항목을 최신 상태로 유지합니다. 이 절이 현재 상태의 정본이며 `Reference Context` 이하는 필요할 때 참조하는 기존 상세 기록입니다. 과거 기록을 현재 상태처럼 계속 갱신하거나 매번 전체 정독하지 않습니다.

- Project Status
- Current Task
- Completed
- In Progress
- Next Task
- Important Decisions
- Do Not Change
- Known Issues
- Technical Debt
- Current Risks
- Last Verified
- Last Updated

[FACT] 빈 문서를 한 번에 생성하지 않습니다. 각 단계에서 내용이 확정될 때 필요한 문서만 추가합니다.

## Git Rules

[FACT] 현재 사용자 지시: Agent는 Git 상태·history·diff 등 모든 Git 확인과 commit·push를 실행하지 않습니다. 사용자가 전체 작업 완료 후 직접 한 번에 commit·push하며 중간 commit 메시지·안내와 결과 재확인을 생략합니다. 이는 보관된 기존 단계별 Git 절차보다 우선하며 별도 설계·구현·배포 승인을 생략하지 않습니다.

[FACT] 파괴적인 Git 명령으로 사용자 변경을 되돌리지 않습니다.

[FACT] 현재 지시로 비활성화된 기존 단계별 Git 절차는 [Git Workflow Policy History](docs/agent-git-policy-history.md)에 보관합니다. 이 링크는 해당 절차를 다시 활성화하거나 Git 작업을 승인하지 않습니다.

## End-of-Task Report

[FACT] 현재 사용자 지시에 따라 중간 사용자 보고는 변경점 중심으로 짧게 작성하고 commit 메시지를 제공하지 않습니다. 실제 검증 결과·미실행 테스트·미확인 사항·다음 작업은 Active Context에 기록하며 중요한 실패·위험·새 승인 필요 사항은 사용자에게도 알립니다. 아래 항목은 최종 종합 보고 또는 별도 요청 시 사용합니다.

- 변경한 파일
- 결정한 내용
- 남은 `[UNKNOWN]`
- 실행한 테스트와 실제 결과
- 실행하지 않은 테스트
- Git 상태
- 추천하는 다음 Task 하나
