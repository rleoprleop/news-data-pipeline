# IT 뉴스 데이터 파이프라인

[FACT] 이 Repository는 한국어 IT 뉴스를 수집·검증·처리하고 개인용 Discord 큐레이션 결과와 월별 Insight를 만드는 배치 데이터 파이프라인 프로젝트입니다.

## Project Status

[FACT] 전체 개발 Workflow의 첫 단계인 **Problem Definition**은 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] **Research / JTBD**는 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] **Solution Discovery**는 2026-08-25에 사용자 승인을 받아 완료됐습니다.

[FACT] 단계 종료 commit/push는 아직 실행하지 않았으며 **Feature Prioritization**은 시작하지 않았습니다.

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
- [FACT] 초기 처리 기준은 최대 100건/일입니다.
- [FACT] 추가 월 운영비 상한은 0원입니다.

상세한 Problem Definition과 범위는 [docs/01-product/problem.md](docs/01-product/problem.md)를 확인합니다.

## Documents

- [AGENTS.md](AGENTS.md): 모든 AI Agent와 기여자가 따라야 할 작업 규칙
- [ai-context.md](ai-context.md): 현재 프로젝트 상태, 결정, 위험과 다음 작업
- [docs/01-product/problem.md](docs/01-product/problem.md): 사용자 문제, MVP 범위, 성공 기준과 검증 항목
- [docs/01-product/research.md](docs/01-product/research.md): JTBD 구체화, GeekNews RSS 조사 결과와 남은 검증 항목
- [docs/01-product/solution-discovery.md](docs/01-product/solution-discovery.md): Solution Approach 비교, 승인된 Solution 결정과 남은 미결정 사항

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

[FACT] GitHub remote Repository는 `https://github.com/rleoprleop/news-data-pipeline.git`입니다.
