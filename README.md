# IT 뉴스 데이터 파이프라인

[FACT] 이 Repository는 한국어 IT 뉴스를 수집·검증·처리하고 개인용 Discord 큐레이션 결과와 월별 Insight를 만드는 배치 데이터 파이프라인 프로젝트입니다.

## Project Status

[FACT] Workflow 1~9와 WBS-01 추적성 기준선은 승인됐습니다. Workflow 10 Coding Readiness와 Workflow 11 기능 구현에는 진입하지 않았으며 애플리케이션 코드·DB schema·배포 구성·runtime 테스트는 없습니다.

[FACT] Gemini 무료 API를 우선 검증·사용 방향으로 유지하지만 AI 제공자의 최종 채택·activation은 미완료입니다. 2026-09-11 제한 실험은 사용자 지시로 중단됐고 실제 외부 호출은 0회이며, 새 실제 검증은 별도 승인 전 실행하지 않습니다.

[FACT] 현재 Task·승인 경계·다음 작업의 정본은 [Active Context](ai-context.md#active-context)입니다. 단계별 승인·commit 기록은 아래 `Repository State`의 역사 snapshot과 각 문서의 Status를 참조합니다.

## Product Goal

[FACT] 사용자는 프로젝트 소유자 한 명입니다.

[FACT] 사용자는 매일 10:00와 22:00 KST에 중요 IT 기사를 확인하고, 관심 있는 원문을 읽으며 기술 트렌드를 파악합니다.

[INFERENCE] 제품이 해결하려는 핵심 문제는 여러 뉴스 페이지를 직접 순회하고 기사 내용을 따로 정리하는 시간, 그리고 광고성·홍보성 기사를 구분하는 부담입니다.

## MVP Summary

- [FACT] 한국어 IT 뉴스만 처리합니다.
- [FACT] 첫 수집원은 GeekNews RSS 하나입니다.
- [FACT] RSS 제목, 설명, 링크와 관련 메타데이터만 저장·처리합니다.
- [FACT] 외부 원문 기사 본문은 수집하지 않습니다.
- [FACT] Discord에는 이전 발송 이후 수집된 기사 중 중요도순 최대 10개를 한국어로 제공합니다.
- [FACT] MVP-A는 일일 큐레이션 P0와 최소 판단 근거·결과 version, 사용자 feedback 및 초기 사용량·지연·품질 측정을 포함합니다.
- [FACT] Feedback은 batch별 검토 완료, 기사별 세 부정 reaction, 암묵적 수용, 구조화된 누락 기사 제출·사유 회신과 후보 recall·수집 범위 누락 분리를 포함합니다.
- [FACT] 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다룹니다.
- [FACT] News, Ask와 Show는 모두 후보 자격을 유지하되 모든 항목에 동일한 수준의 AI 처리를 보장하지 않으며 처리하지 못한 후보를 조용히 제외하지 않습니다.
- [FACT] 유효 후보의 AI 처리가 미완료이면 기사 목록을 발송하지 않고, 전체 선정 완료 뒤 원래 batch의 최대 10개 처리 지연 full result를 발송하며, 전체 선정 불가능이면 원인별 처리 실패 notice를 보냅니다.
- [FACT] Discord 미수락 backlog는 처리 지연 full result와 구분하며, 다음 성공 정규 발송에서 가장 오래된 원래 batch 최대 10개와 현재 기사 최대 10개를 별도 구역으로 제공합니다.
- [FACT] 장애나 한도 소진에 따른 미발송은 신규 기사 0건 미발송과 구분해 실패 사실과 미처리 건수를 확인할 수 있어야 합니다.
- [FACT] 월별 Insight, 장기 결과 재사용·normalization과 자동 Retention lifecycle은 MVP-A 검증 후 MVP-B에서 다룹니다.
- [FACT] 초기 처리 기준 `100건/일`은 Asia/Seoul 일자별 고유 신규 후보 수이며 실제 AI 요청 수와 구분합니다.
- [FACT] 추가 월 운영비 상한은 0원입니다.

상세한 Problem Definition과 범위는 [docs/01-product/problem.md](docs/01-product/problem.md)를 확인합니다.

## Documents

- [작업별 읽기 경로](docs/task-navigation.md): 필요한 기능의 WBS·계약 절만 선택하는 탐색표
- [현재 Context](ai-context.md#active-context): 작업 시작 시 우선 읽는 상태·제약·다음 작업 요약; 과거 기록은 필요할 때만 참조

- [AGENTS.md](AGENTS.md): 모든 AI Agent와 기여자가 따라야 할 작업 규칙
- [docs/01-product/problem.md](docs/01-product/problem.md): 사용자 문제, MVP 범위, 성공 기준과 검증 항목
- [docs/01-product/research.md](docs/01-product/research.md): JTBD 구체화, GeekNews RSS 조사 결과와 남은 검증 항목
- [docs/01-product/solution-discovery.md](docs/01-product/solution-discovery.md): Solution Approach 비교, 승인된 Solution 결정과 남은 미결정 사항
- [docs/01-product/feature-prioritization.md](docs/01-product/feature-prioritization.md): 승인된 MVP 기능 우선순위, 후순위·제외 범위와 남은 미결정 사항
- [docs/01-product/product-spec.md](docs/01-product/product-spec.md): 승인된 MVP-A 제품 정책, 사용자 시나리오, acceptance criteria, 지표와 기술 단계로 넘길 미결정 사항
- [docs/02-technical/requirements.md](docs/02-technical/requirements.md): MVP-A Functional·Non-functional·Data·External Integration·Verification Requirements와 Acceptance Criteria Traceability Matrix
- [docs/02-technical/architecture.md](docs/02-technical/architecture.md): 승인된 MVP-A Architecture 결정과 후속 설계·검증 경계
- [docs/02-technical/data-model.md](docs/02-technical/data-model.md): 최종 승인된 MVP-A PostgreSQL 논리 데이터 모델과 상태·일관성·보존 경계
- [docs/02-technical/interface-spec.md](docs/02-technical/interface-spec.md): 최종 승인된 MVP-A 외부·운영·역할 간 논리 interface 계약
- [docs/03-planning/implementation-plan.md](docs/03-planning/implementation-plan.md): 승인된 전체 구현 순서·WBS 요약·승인 gate와 역할별 계획의 진입점
- [design-readiness-plan.md](docs/03-planning/design-readiness-plan.md): 설계·Coding Readiness 계획 (WBS-03~09)
- [feature-implementation-plan.md](docs/03-planning/feature-implementation-plan.md): 기능 구현 계획 (WBS-10~22)
- [integrated-verification-plan.md](docs/03-planning/integrated-verification-plan.md): 통합 검증 계획 (WBS-23~26)
- [release-operations-plan.md](docs/03-planning/release-operations-plan.md): 배포·운영 계획 (WBS-27~31)
- [validation-traceability-plan.md](docs/03-planning/validation-traceability-plan.md): 외부 검증·요구사항 추적성 계획
- [traceability-baseline.md](docs/03-planning/traceability-baseline.md): WBS-01 요구사항·AC·설계 결정·Hard Gate 추적성 기준선과 검사 방법
- [implementation-review-history.md](docs/03-planning/implementation-review-history.md): 계획 승인·감사 이력

## Working Principles

- [FACT] 작업 규칙의 정본은 [AGENTS.md](AGENTS.md)입니다. README의 요약과 충돌하면 AGENTS 및 승인된 정본 문서를 따릅니다.
- [FACT] Design Before Code, 현재 Task의 최소 변경, 사용자 승인 경계와 제품 Guardrail을 유지합니다.
- [FACT] 현재 사용자 지시에 따라 Agent는 Git을 조회·실행하지 않으며, scope·핵심 설계·데이터 손실 가능 작업·배포를 승인 없이 진행하지 않습니다.

## Repository State

[FACT] 이 절은 문서에 기록된 **역사 snapshot**이며 현재 Git 상태의 정본이 아닙니다. 이번 정리에서도 Git을 조회하지 않았습니다.

[FACT] 2026-08-25에 `C:\project`에서 새 Git Repository를 `master` 브랜치로 초기화한 뒤 기본 branch를 `main`으로 변경했으며, 기록된 remote는 `https://github.com/rleoprleop/news-data-pipeline.git`입니다.

| 단계·기록 | 승인·기록일 | 문서에 기록된 commit |
| --- | --- | --- |
| Problem Definition·Research / JTBD | 2026-08-25 | `ed74291` |
| Solution Discovery | 2026-08-25 | `d377f1e` |
| Feature Prioritization | 2026-08-25 | `bd4b359` |
| MVP-A/MVP-B 범위·fallback 보완 | 2026-08-25 | `40d1dc8` |
| Product Specification | 2026-08-26 | `e9f02a0` |
| Technical Requirements FR 검토 checkpoint | 2026-08-26~28 | `52ac9ee` |
| Technical Requirements 91개 순차 승인 checkpoint | 2026-08-26~29 | `d343ac5` |
| Technical Requirements 최종 승인 | 2026-08-29 | `0e8214c` |
| Architecture | 2026-09-01 | `c993ed9` |
| Data / Interface Design | 2026-09-04 | `8edc1a1` |
| Implementation Plan·WBS-01~31 | 2026-09-09~10 | 현재 Git 반영 상태 미확인 |
