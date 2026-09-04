# IT 뉴스 데이터 파이프라인

[FACT] 이 Repository는 한국어 IT 뉴스를 수집·검증·처리하고 개인용 Discord 큐레이션 결과와 월별 Insight를 만드는 배치 데이터 파이프라인 프로젝트입니다.

## Project Status

[FACT] 전체 개발 Workflow의 첫 단계인 **Problem Definition**은 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] **Research / JTBD**는 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] **Solution Discovery**는 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] **Feature Prioritization**은 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] Feature Prioritization 단계 종료 commit `bd4b359`가 local `main`과 `origin/main`에 반영됐습니다.

[FACT] 사용자가 2026-08-25의 비판적 제품 검토 후 MVP-A/MVP-B 범위 분리, 중요 기사 누락 우선, 모든 후보 자격 유지와 비무음 fallback 방향을 승인했습니다.

[FACT] 위 보완 결정의 문서·Context 동기화는 commit `40d1dc8`로 local `main`과 `origin/main`에 반영됐습니다.

[FACT] 전체 Workflow 5단계인 **Product Specification**은 2026-08-26에 사용자 최종 승인을 받아 완료됐습니다.

[FACT] 사용자가 2026-08-26에 중요도·관심 주제, 홍보성, 저정보 entry, 실패 가시성, Discord 복구, feedback과 MVP-A 합격선 정책을 승인했고 `docs/01-product/product-spec.md` 작성을 요청했습니다.

[FACT] Product Specification 단계 종료 commit `e9f02a0`이 local `main`과 `origin/main`에 반영됐습니다.

[FACT] 전체 Workflow 6단계인 **Technical Requirements**의 Final Review와 사용자 최종 승인을 2026-08-29에 완료했습니다.

[FACT] 사용자가 2026-08-26에 Technical Requirements 우선순위·ID 체계와 Discord reaction 기반 batch 검토 완료, 부정 feedback, 암묵적 수용률, 구조화된 누락 기사 feedback 및 recall 분류 정책을 승인했습니다.


[FACT] Workflow 6 Technical Requirements 승인 기준선은 FR-001~FR-024, NFR 17개, DR-001~DR-014, EXT 25개와 VR-001~VR-011의 총 91개입니다.

[FACT] 2026-08-28에 Technical Requirements Draft 전체의 최종 정합성 점검을 완료했고 사용자가 2026-08-29에 전체 Draft를 최종 승인했습니다. 승인 반영 변경은 단계 종료 commit `0e8214c`로 기록되어 local `main`과 `origin/main`에 반영됐습니다.

[FACT] Workflow 7 **Architecture**의 AD-01~AD-23과 전체 문서를 2026-09-01에 사용자 최종 승인으로 완료했으며, 단계 종료 commit `c993ed9`가 local `main`과 `origin/main`에 반영됐습니다. 이 승인은 구현 승인을 뜻하지 않습니다.

[FACT] 사용자가 2026-09-01에 AD-01~AD-23의 하나의 Python image·K3s 역할 분리·PostgreSQL durable work ledger·Gateway-first feedback·정시 및 처리 지연 전달·복구·backup·평가 실행 경계를 승인했습니다.

[FACT] Workflow 8 **Data / Interface Design**에서 DDI-01~DDI-10, MIN-01~MIN-08, 세부 정합성 검토와 `VR-012`~`VR-019`를 항목별 승인했고, 사용자는 2026-09-04에 두 논리 설계 문서 전체를 최종 승인했습니다. 단계 종료 commit `8edc1a1`이 local `main`과 `origin/main`에 반영됐으며 현재 Technical Requirements는 총 99개입니다.

[FACT] 아직 애플리케이션 코드, 데이터베이스 스키마, 배포 구성과 테스트는 없습니다.

[FACT] 요구사항과 검증 항목이 승인되기 전에는 구현하지 않습니다.

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

- [AGENTS.md](AGENTS.md): 모든 AI Agent와 기여자가 따라야 할 작업 규칙
- [ai-context.md](ai-context.md): 현재 프로젝트 상태, 결정, 위험과 다음 작업
- [docs/01-product/problem.md](docs/01-product/problem.md): 사용자 문제, MVP 범위, 성공 기준과 검증 항목
- [docs/01-product/research.md](docs/01-product/research.md): JTBD 구체화, GeekNews RSS 조사 결과와 남은 검증 항목
- [docs/01-product/solution-discovery.md](docs/01-product/solution-discovery.md): Solution Approach 비교, 승인된 Solution 결정과 남은 미결정 사항
- [docs/01-product/feature-prioritization.md](docs/01-product/feature-prioritization.md): 승인된 MVP 기능 우선순위, 후순위·제외 범위와 남은 미결정 사항
- [docs/01-product/product-spec.md](docs/01-product/product-spec.md): 승인된 MVP-A 제품 정책, 사용자 시나리오, acceptance criteria, 지표와 기술 단계로 넘길 미결정 사항
- [docs/02-technical/requirements.md](docs/02-technical/requirements.md): MVP-A Functional·Non-functional·Data·External Integration·Verification Requirements와 Acceptance Criteria Traceability Matrix
- [docs/02-technical/architecture.md](docs/02-technical/architecture.md): 승인된 MVP-A Architecture 결정과 후속 설계·검증 경계
- [docs/02-technical/data-model.md](docs/02-technical/data-model.md): 최종 승인된 MVP-A PostgreSQL 논리 데이터 모델과 상태·일관성·보존 경계
- [docs/02-technical/interface-spec.md](docs/02-technical/interface-spec.md): 최종 승인된 MVP-A 외부·운영·역할 간 논리 interface 계약

## Working Principles

- [FACT] Design Before Code: 요구사항과 설계 승인 전에는 구현하지 않습니다.
- [FACT] Small Changes: 현재 Task와 관련된 최소 범위만 변경합니다.
- [FACT] Human in the Loop: Scope, 핵심 Architecture, 데이터 손실 가능 작업, 배포, Git commit과 Git push는 사용자 승인 없이 수행하지 않습니다.
- [FACT] Documentation and Context Sync: 중요 결정과 구현 변경을 관련 문서와 `ai-context.md`에 반영합니다.
- [FACT] Stage Closure: 각 Workflow 단계는 사용자 승인과 문서 동기화 후 commit 및 push 절차로 마감합니다.
- [FACT] Branch Strategy: 문서 중심 단계는 `main`을 사용하고, 구현 이후 코드 변경은 기능 또는 수정 단위의 작업 branch와 Pull Request를 사용합니다.
- [FACT] Kafka와 Spark는 실제 데이터 규모와 요구사항으로 필요성이 입증되기 전까지 도입하지 않습니다.

## Repository State

[FACT] 2026-08-25에 `C:\project`에서 새 Git Repository를 `master` 브랜치로 초기화한 뒤 기본 branch를 `main`으로 변경했습니다.

[FACT] Problem Definition과 Research / JTBD 문서를 최초 commit `ed74291`로 기록하고 `origin/main`에 push했습니다.

[FACT] Solution Discovery commit `d377f1e`와 Feature Prioritization commit `bd4b359`를 `origin/main`에 반영했습니다.

[FACT] MVP-A/MVP-B 범위와 fallback 방향 보완 commit `40d1dc8`을 `origin/main`에 반영했습니다.

[FACT] Product Specification 완료 commit `e9f02a0`을 `origin/main`에 반영했습니다.

[FACT] Technical Requirements FR 검토 완료 checkpoint commit `52ac9ee`를 local `main`과 `origin/main`에 반영했습니다.

[FACT] Technical Requirements 91개 Requirement의 순차 승인 checkpoint commit `d343ac5`를 local `main`과 `origin/main`에 반영했습니다.

[FACT] Architecture 완료 commit `c993ed9`를 local `main`과 `origin/main`에 반영했습니다.

[FACT] GitHub remote Repository는 `https://github.com/rleoprleop/news-data-pipeline.git`입니다.
