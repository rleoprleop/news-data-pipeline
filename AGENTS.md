# AGENTS.md

## Purpose

[FACT] 이 파일은 여러 AI Agent가 대화 기억에 의존하지 않고 이 Repository를 이어서 작업하기 위한 공통 운영 규칙입니다.

[FACT] 모든 Agent는 작업을 시작하기 전에 이 파일과 `ai-context.md`를 읽어야 합니다.

## Source of Truth

[FACT] 정보가 충돌하면 다음 순서로 확인합니다.

1. 현재 실제 Code
2. Git History
3. Architecture 및 Technical Documents
4. Product Documents
5. `ai-context.md`
6. 이전 AI 대화

[FACT] Code와 문서가 다르다는 이유만으로 Code를 자동으로 정답으로 간주하지 않습니다.

[FACT] 불일치가 발견되면 변경 전에 다음을 보고합니다.

1. Code의 현재 동작
2. 문서에 정의된 의도
3. Git History에서 확인되는 변경 과정
4. 불일치의 영향
5. 추천 기준

## Required Start-of-Task Check

[FACT] 모든 작업 시작 시 다음을 확인합니다.

- Repository 구조
- `README.md`
- `AGENTS.md`
- `docs/`
- `ai-context.md`
- 현재 코드
- 현재 테스트
- `git status --short --branch`
- 최근 Git history
- TODO와 FIXME

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

[FACT] 다음 단계를 순서대로 진행하며 전체 프로젝트를 한 번에 구현하지 않습니다.

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

## Design Before Code

[FACT] 요구사항과 설계가 확정되기 전에는 구현하지 않습니다.

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

[FACT] 다음 작업은 사용자 승인 없이 실행하지 않습니다.

- Scope 변경
- Architecture의 핵심 결정 변경
- 기존 파일의 대규모 수정 또는 삭제
- 데이터 손실 가능성이 있는 작업
- 배포
- Git commit

[FACT] Kafka와 Spark는 실제 규모와 요구사항으로 필요성이 입증되기 전까지 도입하지 않습니다.

## Current Product Guardrails

- [FACT] MVP 수집원은 GeekNews RSS 하나입니다.
- [FACT] MVP는 한국어 IT 뉴스만 다룹니다.
- [FACT] 외부 원문 기사 본문은 수집하지 않습니다.
- [FACT] 무료 AI 제공자 하나만 연동하며 여러 제공자를 동시에 구현하지 않습니다.
- [FACT] AI 제공자는 아직 확정되지 않았습니다. Gemini 무료 API는 우선 검증 후보입니다.
- [FACT] 유료 API 호출로 자동 전환하면 안 됩니다.
- [FACT] 추가 월 운영비 상한은 0원입니다.
- [FACT] Raw RSS, 기사별 AI 결과와 월별 Insight의 Retention 정책을 구분합니다.

[FACT] 상세 범위와 검증 항목은 `docs/01-product/problem.md`를 기준으로 확인합니다.

## Testing

[FACT] 구현 완료를 선언하기 전에 관련 테스트를 실행합니다.

[FACT] 실행한 테스트와 결과를 구분해 보고합니다.

[FACT] 실행하지 않은 테스트를 통과했다고 표현하지 않습니다.

## Documentation and Context Sync

[FACT] 중요 결정과 구현 변경은 관련 Repository 문서에 반영합니다.

[FACT] 각 Task 종료 시 `ai-context.md`의 다음 항목을 최신 상태로 유지합니다.

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

[FACT] 작업 전후에 Git 변경사항을 확인합니다.

[FACT] Git commit은 사용자 승인 후에만 실행합니다.

[FACT] 파괴적인 Git 명령으로 사용자 변경을 되돌리지 않습니다.

[FACT] Commit 검토 시 변경 범위, 테스트 결과, 문서 동기화와 남은 위험을 먼저 보고합니다.

## End-of-Task Report

[FACT] 각 Task 종료 보고에는 최소한 다음을 포함합니다.

- 변경한 파일
- 결정한 내용
- 남은 `[UNKNOWN]`
- 실행한 테스트와 실제 결과
- 실행하지 않은 테스트
- Git 상태
- 추천하는 다음 Task 하나
