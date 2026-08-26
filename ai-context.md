# AI Context

## Project Status

[FACT] 프로젝트는 전체 Workflow 1단계인 Problem Definition, 2단계인 Research / JTBD와 3단계인 Solution Discovery를 사용자 승인으로 완료했습니다.

[FACT] 전체 Workflow 4단계인 Feature Prioritization을 2026-08-25에 사용자 승인으로 완료했습니다.

[FACT] `docs/01-product/research.md`는 2026-08-25에 사용자 승인을 받았습니다.

[FACT] `docs/01-product/solution-discovery.md`는 2026-08-25에 사용자 승인을 받았습니다.

[FACT] Git 기본 branch는 `main`이며 GitHub의 `origin/main`과 동기화해 운영합니다.

[FACT] Solution Discovery 단계 종료 commit `d377f1e`가 local `main`과 `origin/main`에 반영됐습니다.

[FACT] Feature Prioritization 단계 종료 commit `bd4b359`가 local `main`과 `origin/main`에 반영됐습니다.

[FACT] MVP-A/MVP-B 범위와 fallback 방향 보완 commit `40d1dc8`이 local `main`과 `origin/main`에 반영됐습니다.

[FACT] 사용자가 2026-08-25의 비판적 제품 검토 후 MVP-A/MVP-B 범위 분리, 중요 기사 누락 우선, 모든 후보 자격 유지와 비무음 fallback 방향을 승인했습니다.

[FACT] 사용자가 후보 자격 유지, 실제 무료 AI 후보 검증, 검증 결과에 따른 fallback 명세 순서로 진행하고 장애 미발송을 신규 기사 0건과 구분하는 방향을 확인했습니다.

[FACT] 전체 Workflow 5단계인 Product Specification을 2026-08-26에 사용자 최종 승인으로 완료했습니다.

[FACT] 사용자가 2026-08-26에 중요도·관심 주제, 홍보성, 저정보 entry, 실패 가시성, Discord 복구, feedback과 MVP-A 합격선 정책을 승인하고 `docs/01-product/product-spec.md` 작성을 요청했습니다.

[FACT] `docs/01-product/product-spec.md`는 2026-08-26에 사용자 최종 승인을 받았습니다.

[FACT] Product Specification 단계 종료 commit `e9f02a0`이 local `main`과 `origin/main`에 반영됐습니다.

[FACT] 전체 Workflow 6단계인 Technical Requirements Draft를 작성하고 검토하는 중입니다.

[FACT] 사용자가 2026-08-26에 Technical Requirements의 P0-HG·P0·P1-V 우선순위와 FR·NFR·DR·EXT·VR Requirement ID 범주를 승인했습니다.

[FACT] 사용자가 Discord reaction 기반 batch 검토 완료, 세 부정 feedback, 암묵적 수용률, 구조화된 누락 기사 제출·사유 회신과 후보 recall·수집 범위 누락 분리 정책을 승인했습니다.

[FACT] Technical Requirements 순차 검토에서 FR-001~FR-024 Functional Requirements를 승인했으며 다음 재개 위치는 아직 미승인인 NFR-REL-001입니다.

[FACT] 이번 종료 시 Git 반영은 Technical Requirements 단계 완료가 아니라 다음 Task 재개를 위한 중간 checkpoint입니다.

[FACT] 구현, 데이터베이스 스키마, 테스트와 배포 구성은 시작하지 않았습니다.

[FACT] `docs/01-product/problem.md`는 사용자가 제공한 확정 정보와 아직 검증할 항목을 분리해 기록한 초기 Problem Definition입니다.

## Current Task

[FACT] `docs/02-technical/requirements.md` Technical Requirements Draft 순차 검토와 Product Specification·README·AI Context 동기화.

[FACT] 순차 검토 checkpoint는 FR-001~FR-024 승인 완료이며 NFR-REL-001부터 재개합니다.

## Completed

- [FACT] `C:\project`가 빈 새 프로젝트 위치임을 확인했습니다.
- [FACT] Git Repository를 처음 `master` 브랜치로 초기화한 뒤 기본 branch를 `main`으로 변경했습니다.
- [FACT] 최초 commit `ed74291`에 Problem Definition과 Research / JTBD 문서를 기록하고 GitHub의 `origin/main`에 push했습니다.
- [FACT] GitHub remote Repository를 `https://github.com/rleoprleop/news-data-pipeline.git`로 연결했습니다.
- [FACT] Problem Definition의 사용자, JTBD, MVP 범위, 출력, Retention, 비용, 용량과 지연 목표가 사용자 확정 요구사항과 충돌하지 않음을 검토했습니다.
- [FACT] 남은 검증·결정 항목을 Research / JTBD, Product Specification, Technical Requirements 및 Data / Interface Design 단계에서 다룰 항목으로 확인했습니다.
- [FACT] 사용자가 2026-08-25에 `docs/01-product/problem.md`를 명시적으로 승인했습니다.
- [FACT] 프로젝트 작업 규칙을 `AGENTS.md`에 기록했습니다.
- [FACT] 제품 개요와 현재 상태를 `README.md`에 기록했습니다.
- [FACT] 사용자, JTBD, MVP 범위, 출력, Retention, 용량, 비용 및 지연 목표를 `docs/01-product/problem.md`에 기록했습니다.
- [FACT] 검증이 필요한 RSS, AI, 분류 품질과 운영 항목을 문서에 분리했습니다.
- [FACT] 승인된 문제를 바탕으로 핵심 JTBD, 기능적 Job과 desired outcome을 구체화했습니다.
- [FACT] GeekNews의 공식 RSS URL, Atom 응답 형식, News·Ask·Show 전체 포함과 시간순 노출 특성을 확인했습니다.
- [FACT] GeekNews 이용약관에서 과도한 자동 접근 금지와 서비스 변경·중단 가능성을 확인했습니다.
- [FACT] 확인된 RSS 사실과 직접 원본 관찰이 필요한 항목을 `docs/01-product/research.md`에 분리했습니다.
- [FACT] 사용자가 2026-08-25에 제공한 RSS XML 표본을 정상적으로 파싱하고 feed-level metadata와 50개 entry 구조를 확인했습니다.
- [FACT] 표본의 모든 entry가 GeekNews topic link, 동일 값의 `id`, `published`, `updated`, `author`와 HTML `content`를 제공함을 확인했습니다.
- [FACT] 사용자가 외부 원문 직접 URL은 MVP 결과의 필수 조건이 아니며 RSS가 제공한 GeekNews topic link를 사용할 수 있다고 확인했습니다.
- [FACT] 사용자가 News, Ask와 Show를 모두 데이터 파이프라인의 일반 후보로 처리하고 source type만으로 조기 제외하지 않기로 결정했습니다.
- [FACT] RSS 표본 50개 전체를 title과 content만으로 검토한 결과, 48개는 보수적인 2문장 요약에 충분하고 1개는 제한적이며 1개는 불충분하다고 평가했습니다.
- [FACT] 사용자가 2026-08-25에 `docs/01-product/research.md`의 refined JTBD와 Research conclusion을 승인했습니다.
- [FACT] 사용자가 각 Workflow 단계 종료 시 commit 및 push 안내 절차를 수행하는 Git 운영 기준을 확정했습니다.
- [FACT] 문서 중심 단계는 `main`, 구현 이후 코드 변경은 기능 또는 수정 단위의 작업 branch와 Pull Request를 사용하기로 확정했습니다.
- [FACT] 규칙 중심, AI 중심과 근거 제한형 하이브리드의 세 가지 Solution Approach 및 각각의 Trade-off를 `docs/01-product/solution-discovery.md`에 비교했습니다.
- [FACT] 사용자가 2026-08-25에 근거 제한형 AI 판단과 결정적 하드 가드레일을 결합한 Approach C를 MVP Solution 방향으로 승인했습니다.
- [FACT] 사용자가 2026-08-25에 모든 News, Ask와 Show entry를 일반 후보로 유지하고 source type이나 단순 keyword만으로 AI 분석 전에 조기 제외하지 않는 원칙을 승인했습니다.
- [FACT] 사용자가 2026-08-25에 AI 의미 판단과 하드 가드레일을 결합하는 3B를 승인했습니다.
- [FACT] 사용자가 2026-08-25에 기사별 공통 결과를 재사용하고 월별 기준으로 별도 정규화·집계하는 4C를 승인했습니다.
- [FACT] 사용자가 기존 계획과 Repository 승인 기준이 충돌할 때 현재 승인 기준을 적용한다고 확인했습니다.
- [FACT] Solution Discovery 변경을 commit `d377f1e`로 기록하고 `origin/main`에 반영했습니다.
- [FACT] Required Start-of-Task Check에서 Repository 구조, 모든 문서, 코드·테스트 부재, Git 상태·최근 history와 TODO/FIXME 부재를 확인했습니다.
- [FACT] 승인된 이전 단계에서 기능 후보를 도출하고 사용자 가치, MVP 필수성, 의존성, 비용 압력, 운영 복잡도와 위험을 `docs/01-product/feature-prioritization.md`에 비교했습니다.
- [FACT] 사용자가 2026-08-25에 최초 P0·P1 MVP 포함, 후순위 기능, 기존 제외 범위와 주요 Trade-off 전체를 승인했고 이후 비판적 제품 검토에서 MVP-A/MVP-B로 범위를 개정했습니다.
- [FACT] `docs/01-product/feature-prioritization.md`와 `ai-context.md`를 Feature Prioritization 승인 상태로 동기화했습니다.
- [FACT] 프로젝트 전체 파일 정합성 검토에서 확인된 README 현재 상태·문서 링크와 Feature Prioritization의 승인 전 표현·L05 분류를 현재 승인 상태에 맞게 정리했습니다.
- [FACT] Feature Prioritization 변경을 commit `bd4b359`로 기록하고 `origin/main`에 반영했습니다.
- [FACT] 현재 Repository 파일과 Git history를 기준으로 승인된 제품 결정을 비판적으로 검토했습니다.
- [FACT] 사용자가 최초 MVP를 일일 P0와 최소 추적·feedback·측정의 MVP-A로 제한하고 월별 Insight, 장기 재사용·normalization과 자동 Retention lifecycle을 MVP-B로 이동하는 범위 개정을 승인했습니다.
- [FACT] 사용자가 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다루기로 승인했습니다.
- [FACT] 사용자가 모든 News·Ask·Show의 후보 자격을 유지하되 모든 항목에 동일한 수준의 AI 처리를 보장하지 않고, 처리하지 못한 후보를 조용히 제외하지 않는 추천 방향을 승인했습니다.
- [FACT] 사용자가 후보 처리 정책을 후보 자격 유지, 실제 무료 AI 후보 검증, 검증 결과에 따른 fallback 명세 순서로 진행하기로 확인했습니다.
- [FACT] 사용자가 장애나 한도 소진에 따른 미발송을 신규 기사 0건 미발송과 구분하고 실패 사실과 미처리 건수를 확인할 수 있어야 한다는 방향을 확인했습니다.
- [FACT] 위 보완 승인 내용을 `AGENTS.md`, `README.md`, `docs/01-product/problem.md`, `docs/01-product/research.md`, `docs/01-product/solution-discovery.md`, `docs/01-product/feature-prioritization.md`와 이 Context에 동기화했습니다.
- [FACT] 위 보완 결정 동기화를 commit `40d1dc8`로 기록하고 `origin/main`에 반영했습니다.
- [FACT] 2026-08-26 Product Specification 시작 전 `HEAD`, `main`과 `origin/main`이 `40d1dc8`로 일치하고 working tree가 깨끗함을 확인했습니다.
- [FACT] 사용자가 중요도와 관심 주제 적합성을 별도 판단하고 관심 주제 밖이어도 전체 IT 영향도가 높은 기사를 전달하기로 승인했습니다.
- [FACT] 사용자가 홍보성 False Positive를 더 심각하게 다루고 애매한 후보를 제외하지 않는 보수적 정책을 승인했습니다.
- [FACT] 사용자가 저정보 RSS entry를 후보로 유지하고 선정 시 `정보 제한` 결과로 표시하기로 승인했습니다.
- [FACT] 사용자가 AI 실패 상태·처리 건수·비무음 원칙은 확정하고 fallback 세부 우선순위는 무료 AI 후보 검증 후 결정하기로 승인했습니다.
- [FACT] 사용자가 각 batch의 논리적 발송 결과와 원래 수량 요약을 보존하고 Discord 복구 발송에서 이를 지연 기사로 재사용해 현재 기사와 구분하며 각각 최대 10개, 총 최대 20개를 허용하기로 승인했습니다.
- [FACT] 사용자가 혼합 feedback, 최소 평가 표본, 품질 목표와 Hard Gate를 승인했습니다.
- [FACT] 승인된 정책을 `docs/01-product/product-spec.md` Draft에 작성했습니다.
- [FACT] 사용자가 2026-08-26에 `docs/01-product/product-spec.md`를 최종 승인했습니다.
- [FACT] Product Specification 단계 종료 변경을 commit `e9f02a0`으로 기록하고 `origin/main`에 반영했습니다.
- [FACT] 2026-08-26 Technical Requirements 시작 전 `HEAD`, `main`과 `origin/main`이 `e9f02a0`으로 일치하고 working tree가 깨끗함을 확인했습니다.
- [FACT] 사용자가 P0-HG·P0·P1-V 우선순위와 FR·NFR·DR·EXT·VR Requirement ID 체계를 승인했습니다.
- [FACT] 사용자가 batch 대표 메시지의 ✅ reaction, 기사별 😕·🚫·📣 reaction과 검토 완료 batch의 암묵적 수용률 70% 정책을 승인했습니다.
- [FACT] 사용자가 구조화된 Discord slash command로 누락 link를 제출하면 이를 누락 검토 요청으로 기록하고, 별도의 이유 확인·이해 feedback 없이 실제 처리 이유에 추천해야 했다 reaction만 남기는 정책을 승인했습니다.
- [FACT] 사용자가 수집된 후보의 추천해야 했다는 recall 누락으로, 비교 기간을 포함하는 정상 Raw RSS 관찰 기록에서도 확인되지 않은 link만 수집원·수집 범위 누락으로 별도 집계하고 수집·처리 실패와 근거 부족은 구분하는 정책을 승인했습니다.
- [FACT] 사용자가 RSS 관찰 entry, 기존·중복 관찰, 후보 생성 불가능 입력 오류와 고유 신규 후보 수를 분리하고 단계별 수량을 대조하며, 입력 오류로 결과가 불완전하면 그 사실과 수를 표시하는 정책을 승인했습니다.
- [FACT] 사용자가 MVP-A 측정값을 batch별·Asia/Seoul 일자별로 산출하고 0건·측정 불가·원인 미확정을 구분하며, retry·reaction·복구 event와 논리적 결과 및 지연·현재 batch 수량을 중복 계산하지 않는 정책을 승인했습니다.
- [FACT] FR-001~FR-024의 순차 검토·승인을 완료하고 승인된 교차 수정안을 Product Specification, Technical Requirements와 Context에 동기화했습니다.
- [FACT] 사용자가 Product Specification과 Context에 위 feedback 정책을 동기화하도록 승인했습니다.
- [FACT] 승인된 Product Specification을 기준으로 Functional·Non-functional·Data·External Integration·Verification Requirements와 AC-01~AC-24 Traceability Matrix를 `docs/02-technical/requirements.md` Draft에 작성했습니다.
- [FACT] 승인된 feedback 정책을 `docs/01-product/product-spec.md`, `README.md`와 이 Context에 동기화했습니다.

## In Progress

- [FACT] `docs/02-technical/requirements.md`의 FR-001~FR-024 순차 검토·승인을 완료했습니다.
- [FACT] NFR-REL-001은 설명만 진행했으며 사용자 승인과 파일 수정은 하지 않았습니다.
- [FACT] FR 검토 중 승인된 결정을 동기화하면서 NFR-REL-002, DR-002, DR-008, DR-009, DR-011과 일부 Traceability 문구를 보강했지만 NFR·DR 범주 순차 검토 완료로 간주하지 않습니다.
- [FACT] 전체 91개 Requirement ID 중 Functional 24개를 순차 검토했고 NFR 17개, DR 14개, EXT 25개와 VR 11개의 범주 검토가 남아 있습니다.
- [UNKNOWN] Technical Requirements Draft 전체에 대한 사용자 최종 승인이 필요합니다.
- [UNKNOWN] NFR-SEC-001의 feedback 무료 AI 전달 가능 표현, 100건/일의 기준 단위, 13시간 지연의 RSS 노출·pipeline 구분, reaction 평가 snapshot과 홍보성 False Positive 검토 판정 데이터는 해당 Requirement 순서에서 검토해야 합니다.
- [UNKNOWN] 보류·재시도, 제한 결과와 미발송의 정확한 조건과 우선순위는 실제 무료 AI 후보 검증 후 결정해야 합니다.
- [UNKNOWN] 두 번 이상의 발송 시각 동안 Discord 장애가 계속될 때 backlog 상한과 분할 정책은 아직 결정되지 않았습니다.
- [UNKNOWN] 기사·batch·reaction의 정확한 Discord 표시와 mapping, slash command 이름·parameter와 누락 이유 응답 UI는 Interface Design에서 결정해야 합니다.
- [UNKNOWN] Discord Application의 Gateway·HTTP interaction·주기 조회 선택과 월 0원 실행 가능성은 Architecture 전에 검증해야 합니다.

## Next Task

[INFERENCE] 다음 Task 하나는 Required Start-of-Task Check 후 NFR-REL-001부터 Technical Requirements 순차 검토를 재개하는 것입니다.

[FACT] Product Specification 단계 종료 commit과 push는 완료됐습니다.

[FACT] 이번 종료 Git 반영은 재개용 중간 checkpoint이며 Technical Requirements 최종 승인과 관련 문서 동기화 후 별도의 단계 종료 Git commit/push 안내 절차를 진행합니다.

## Important Decisions

### Workflow Approval

- [FACT] `docs/01-product/problem.md`는 2026-08-25에 사용자 승인을 받았습니다.
- [FACT] `docs/01-product/research.md`는 2026-08-25에 사용자 승인을 받았습니다.
- [FACT] `docs/01-product/solution-discovery.md`는 2026-08-25에 사용자 승인을 받았습니다.
- [FACT] `docs/01-product/feature-prioritization.md`는 2026-08-25에 사용자 승인을 받았습니다.
- [FACT] `docs/01-product/product-spec.md`는 2026-08-26에 사용자 최종 승인을 받았습니다.
- [FACT] 승인된 문제, 목표와 MVP 범위를 변경하려면 사용자 승인이 필요합니다.
- [FACT] 승인된 Research / JTBD conclusion을 변경하려면 사용자 승인이 필요합니다.
- [FACT] 승인된 Solution Discovery 결정을 변경하려면 사용자 승인이 필요합니다.
- [FACT] 승인된 Product Specification 정책과 acceptance criteria를 변경하려면 사용자 승인이 필요합니다.

### Solution Discovery

- [FACT] 근거 제한형 AI 판단과 결정적 하드 가드레일을 결합한 Approach C를 MVP Solution 방향으로 채택합니다.
- [FACT] 모든 News, Ask와 Show entry를 일반 후보로 유지하고 source type이나 단순 keyword만으로 후보 자격과 최종 결과에서 조용히 제외하지 않습니다.
- [FACT] 후보 자격 유지는 모든 항목에 동일한 수준의 AI 처리를 보장한다는 뜻이 아닙니다.
- [FACT] 무료 한도나 처리 제약으로 전체 분석을 수행하지 못한 후보를 source type이나 단순 keyword 기준으로 조용히 제외하지 않고 Product Specification에서 정할 명시적 fallback을 적용합니다.
- [FACT] fallback은 실제 무료 AI 후보의 품질·한도·rate limit·재시도 가능성을 검증한 뒤 Product Specification에서 명세합니다.
- [FACT] 장애나 한도 소진으로 결과를 발송하지 못한 경우 신규 기사 0건과 구분하고 사용자가 실패 사실과 미처리 건수를 확인할 수 있어야 합니다.
- [FACT] AI가 포함 추천, 상대적 중요도와 홍보성 판단을 제안하고 후속 정책은 RSS 근거, 필수 형식, 최대 10개, 실패와 비용 제한 같은 하드 가드레일을 적용하는 3B를 채택합니다.
- [FACT] 기사별 요약, 근거, 주제·keyword 후보를 재사용하고 월별 단계에서 공통 taxonomy와 집계 기준으로 정규화해 월별 결과를 별도 보존하는 4C를 채택합니다.
- [FACT] 기존 계획과 Repository의 승인 기준이 충돌할 때 현재 승인된 Problem Definition, Research / JTBD와 Current Product Guardrails를 적용합니다.
- [FACT] Feature 우선순위, 합격선, 점수 공식, 임계값, AI 제공자, Architecture, 데이터 모델과 구현 방식은 이번 단계에서 결정하지 않습니다.

### Feature Prioritization

- [FACT] `docs/01-product/feature-prioritization.md`는 2026-08-25에 사용자 승인을 받았습니다.
- [FACT] MVP-A는 RSS 수집·입력 검증, 신규 구간·중복·재처리 상태, 근거 제한형 기사 분석, 하드 가드레일, 일일 선정·홍보성 제외, Discord 발송, 최소 판단 근거·결과 version, 사용자 feedback과 초기 사용량·지연·품질 측정을 포함합니다.
- [FACT] MVP-B는 MVP-A 검증 후 기사별 결과의 장기 보존·재사용, 월별 정규화·Insight와 자동 Retention lifecycle을 확장합니다.
- [FACT] MVP-B는 MVP-A 완료의 선행조건이 아닙니다.
- [FACT] 별도 검토·설정·검색·운영 UI, source type 표시, 월별 자동 전달과 실시간 알림은 후순위입니다.
- [FACT] 외부 원문·상세 페이지 수집, 추가 뉴스원, 다중 AI, 자동 유료 전환, 다중 사용자, Kafka와 Spark에 관한 기존 제외·조건부 범위는 변경하지 않았습니다.
- [FACT] 사용자는 모든 일반 후보의 자격을 유지하면서 동일한 수준의 AI 처리를 보장하지 않는 Trade-off, AI 판단의 비결정성, 최소 추적 정보 보존과 초기 전용 검토 UI 부재를 승인했습니다.
- [FACT] 중요도·홍보성, 저정보 entry, 실패 표시, Discord 복구, feedback과 MVP-A 합격선의 상세 제품 정책은 2026-08-26 Product Specification 결정으로 구체화됐습니다.

### Product Specification

- [FACT] 중요도와 관심 주제 적합성을 별도 축으로 판단합니다.
- [FACT] 관심 주제 밖이어도 전체 IT 생태계 영향도가 높으면 전달할 수 있습니다.
- [FACT] 홍보성 False Positive를 False Negative보다 더 심각하게 다루며 애매한 후보는 제외하지 않습니다.
- [FACT] 저정보 RSS entry는 후보 자격을 유지하고 선정 시 `정보 제한`, 근거가 허용하는 1문장 이하 설명과 GeekNews topic link를 제공합니다.
- [FACT] 정상 발송, 정상 0건, 부분 결과, 처리 실패 미발송과 Discord 전달 실패를 사용자 관점에서 구분합니다.
- [FACT] AI 부분 결과는 전체 Top 10으로 표현하지 않고 후보·정상 처리·미처리 건수를 표시합니다.
- [FACT] RSS 관찰 entry, 기존·중복 관찰, 후보 생성 불가능 입력 오류와 고유 신규 후보 수를 분리하며 입력 오류로 결과가 불완전하면 오류 수를 표시합니다.
- [FACT] 전체 AI 실패는 신규 0건과 구분하고 Discord가 사용 가능하면 실패 사실과 미처리 건수를 알립니다.
- [FACT] Discord 전달 실패 기사는 원래 batch의 선정 결과와 수량 요약을 재분석 없이 재사용해 다음 성공 정규 발송에서 지연 기사로 제공하며, 현재 기사와 각각 최대 10개, 총 최대 20개를 허용합니다.
- [FACT] Feedback은 기사별 😕 별로였음·🚫 불필요함·📣 홍보성 의심 reaction, batch별 ✅ 검토 완료, 누락 중요 기사 link·이유와 홍보성 제외 표본 검토를 결합합니다.
- [FACT] 검토 완료 batch에서 세 부정 reaction이 없는 기사는 암묵적 수용으로 기록하며 미검토 batch 기사는 암묵적 수용률 분모에서 제외합니다.
- [FACT] GeekNews topic link 클릭은 검토 완료로 간주하지 않습니다.
- [FACT] 누락 기사는 구조화된 Discord slash command로 제출해 누락 검토 요청으로 기록하고, 별도의 이유 확인·이해 feedback 없이 실제 처리 기록에 따른 이유에 추천해야 했다 reaction만 남깁니다.
- [FACT] 수집된 후보의 추천해야 했다는 중요 기사 recall 누락으로, 비교 기간을 포함하는 정상 Raw RSS 관찰 기록에서도 확인되지 않은 link만 수집원·수집 범위 누락으로 별도 집계하며 수집·처리 실패와 근거 부족은 구분합니다.
- [FACT] MVP-A 검증은 최소 2주·20개 batch·50개 후보 평가를 요구하고 표본이 부족하면 `판정 불충분`으로 기록합니다.
- [FACT] 중요 기사 recall 90%, 암묵적 수용률 70%, RSS 근거 충실도 95%, 홍보성 False Positive 5% 이하와 False Negative 10% 이하를 초기 품질 목표로 사용합니다.
- [FACT] 유료 AI 자동 전환, 조용한 미처리, 동일 기사 중복 발송, AI 실패의 신규 0건 오표시, Discord 미수신의 성공 기록과 중대한 근거 밖 사실은 각각 0건이어야 합니다.
- [UNKNOWN] AI fallback 세부 우선순위는 무료 AI 후보 검증 후 결정합니다.
- [UNKNOWN] 장기 Discord 장애 backlog와 feedback Interface·Discord Application 구현 방식은 이후 단계에서 결정합니다.

### Technical Requirements

- [FACT] P0-HG는 위반 0건이어야 하는 Hard Gate, P0는 일일 MVP-A 기능 필수, P1-V는 MVP-A 품질 판정 전 필요한 검증·학습 요구사항입니다.
- [FACT] P1-V는 선택 기능이나 MVP-B를 의미하지 않습니다.
- [FACT] Requirement ID는 FR, NFR, DR, EXT와 VR 범주로 구분합니다.
- [FACT] 각 요구사항은 ID, 우선순위, 내용, Product Specification 또는 Acceptance Criteria 근거, 검증 방법과 미결정 의존성을 포함합니다.
- [FACT] AC-01~AC-24는 Technical Requirement ID와 검증 증거에 연결돼야 합니다.
- [FACT] Technical Requirements는 AI 제공자·SDK, framework, DB schema, 상태 전이 구현, retry·polling, component 구조, identity 알고리즘, 점수·임계값, 인프라와 장기 Discord backlog 정책을 확정하지 않습니다.
- [UNKNOWN] `docs/02-technical/requirements.md` Draft 전체에 대한 사용자 최종 승인은 아직 완료되지 않았습니다.

### Git Workflow

- [FACT] 각 Workflow 단계는 사용자 승인과 관련 문서 동기화 후 commit 및 push 안내 절차로 마감합니다.
- [FACT] 단계 종료 시 변경 범위, 테스트 결과, 문서 동기화와 남은 위험을 먼저 보고합니다.
- [FACT] 사용자가 직접 Git 명령을 실행하면 Agent가 명령을 순서대로 안내하고 결과를 확인합니다.
- [FACT] Agent가 commit 또는 push를 실행하려면 사용자의 명시적 승인이 필요합니다.
- [FACT] Commit과 push가 완료되거나 사용자가 명시적으로 연기하기 전에는 다음 Workflow 단계로 넘어가지 않습니다.
- [FACT] 문서 중심의 Product 및 Design 단계는 승인된 변경을 단계별로 `main`에 commit하고 push합니다.
- [FACT] Feature Implementation 이후의 코드 변경은 기능 또는 수정 단위의 작업 branch에서 진행하고 Pull Request로 `main`에 병합합니다.
- [FACT] 작업 branch는 대화마다 만들지 않으며 독립적으로 검토하거나 되돌릴 변경 단위로 만듭니다.
- [FACT] 일반적인 단계 종료 절차에서는 force push를 사용하지 않습니다.

### User and Job

- [FACT] 사용자는 프로젝트 소유자 한 명입니다.
- [FACT] 사용자는 매일 10:00와 22:00 KST에 Discord 결과를 확인합니다.
- [FACT] 결과는 중요 기사 선별, 원문 확인과 기술 트렌드 파악에 사용합니다.
- [FACT] 뉴스 페이지 순회와 별도 정리 시간을 줄이고 광고성·홍보성 기사를 걸러내는 것이 목적입니다.

### MVP Scope

- [FACT] MVP는 한국어 IT 뉴스만 다룹니다.
- [FACT] 관심 주제는 데이터 엔지니어링, 클라우드, AI, 백엔드, 개발 도구와 데이터베이스입니다.
- [FACT] 첫 수집원은 GeekNews RSS 하나입니다.
- [FACT] GeekNews RSS의 News, Ask와 Show를 모두 수집·처리 후보에 포함합니다.
- [FACT] source type 또는 title prefix만으로 Ask와 Show를 조기 제외하지 않습니다.
- [FACT] 모든 후보에 동일한 수준의 AI 처리를 무조건 보장하지 않으며 처리하지 못한 후보를 조용히 제외하지 않습니다.
- [FACT] 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다룹니다.
- [INFERENCE] 최종 출력 포함 여부는 이후 관심 주제·중요도·홍보성 처리 결과로 판단합니다.
- [FACT] 시사·경제 뉴스와 네이버 RSS 후보는 현재 MVP 범위가 아닙니다.
- [FACT] RSS 제목, 설명, 링크와 관련 메타데이터만 저장·처리합니다.
- [FACT] 외부 원문 기사 본문은 수집하지 않습니다.
- [FACT] RSS만으로 요약 품질이 부족하다는 검증 결과가 있을 때만 GeekNews 상세 페이지 수집을 검토합니다.

### Delivery

- [FACT] Discord 발송 시각은 매일 10:00와 22:00 KST입니다.
- [FACT] 이전 발송 이후 수집된 기사 중 중요도순 최대 10개를 선택합니다.
- [FACT] 각 항목은 한국어 제목, 2~3문장 요약, 키워드와 링크를 포함합니다.
- [FACT] 원문 접근 가능 여부와 무관하게 기사 링크를 제공합니다.
- [FACT] 외부 원문 직접 URL은 필수가 아니며 RSS가 제공한 GeekNews topic link를 기사 링크로 사용할 수 있습니다.
- [FACT] 외부 자료 기반 항목과 GeekNews 직접 작성 항목이 혼재하므로 외부 원문 URL이 항상 존재한다고 가정하지 않습니다.
- [FACT] 홍보성 의심 기사는 주요 목록에서 제외하고 제외 건수만 표시합니다.
- [FACT] 신규 기사가 없으면 Discord 메시지를 발송하지 않습니다.
- [FACT] 장애나 처리 실패에 따른 미발송은 신규 기사 0건과 구분하며 실패 사실과 미처리 건수를 확인할 수 있어야 합니다.

### MVP-B Monthly Insight and Retention

- [FACT] 월별 Insight, 기사별 결과의 장기 재사용·normalization과 자동 Retention lifecycle은 MVP-A 검증 후 MVP-B에서 다룹니다.
- [FACT] 월별 Insight는 주제 비중, 전월 대비 주제 비중 증감, 새롭게 떠오르거나 급증한 키워드와 주요 주제별 대표 기사를 포함합니다.
- [FACT] 첫 달에는 전월 비교를 생략하고 두 번째 달부터 비교합니다.
- [FACT] Raw RSS 데이터는 3개월간 보존합니다.
- [FACT] 기사별 AI 요약, 키워드와 판정 결과는 12개월간 보존합니다.
- [FACT] 월별 Insight는 기간 제한 없이 보존합니다.
- [FACT] 보존 기간은 나중에 쉽게 변경할 수 있는 설정값으로 분리합니다.

### Capacity, Cost and Reliability

- [FACT] 초기 처리 용량 기준은 최대 100건/일입니다.
- [FACT] 실제 기사량과 API 사용량을 첫 2~4주 동안 측정한 뒤 기준을 조정합니다.
- [FACT] 추가 월 운영비 상한은 0원입니다.
- [FACT] 기사 전달 목표는 게시 후 최대 13시간 이내입니다.
- [FACT] 각 발송 배치는 30분 이내 완료하는 것이 목표입니다.
- [FACT] 13시간은 전달 지연 목표이며 누락 복구 범위가 아닙니다.
- [INFERENCE] 누락 복구의 출발 방향은 마지막 성공 수집 시점과 충분한 중첩 범위를 이용한 재수집, 그리고 `link UNIQUE + ON CONFLICT`를 이용한 중복 제거입니다.
- [UNKNOWN] 충분한 중첩 범위와 GeekNews 링크의 안정성·정규화 규칙은 설계 전에 검증해야 합니다.

### AI Provider

- [FACT] AI 제공자는 Gemini로 고정하지 않습니다.
- [FACT] MVP에서는 무료 제공자 하나만 연동합니다.
- [FACT] 이후 교체 가능한 경계를 마련하되 여러 제공자를 동시에 구현하지 않습니다.
- [FACT] 공개된 GeekNews RSS 제목과 설명이 무료 AI 제공자의 약관에 따라 서비스 개선 등에 이용될 가능성은 허용합니다.
- [FACT] Gemini 무료 API는 우선 검증 후보입니다.
- [FACT] ChatGPT Pro 사용량을 OpenAI API 무료 사용량으로 간주하지 않습니다.
- [FACT] OpenAI Platform의 별도 무료 API credit이 공식적으로 확인될 때만 월 0원 후보가 될 수 있습니다.
- [FACT] 무료 할당량이 소진돼도 유료 호출로 자동 전환하면 안 됩니다.

### GeekNews Research

- [FACT] 공식 RSS URL은 `https://news.hada.io/rss/news`입니다.
- [FACT] endpoint는 2026-08-25 기준 `application/atom+xml` 형식으로 응답합니다.
- [FACT] 공식 설명상 feed는 News뿐 아니라 Ask와 Show를 모두 포함하며, 첫 화면 순위가 아니라 시간순으로 노출합니다.
- [FACT] 사용자 제공 표본의 50개 entry는 모두 `title`, `link`, `id`, `updated`, `published`, `author`와 `content`를 제공합니다.
- [FACT] 모든 entry link는 GeekNews topic page를 가리키며 `id`는 같은 link 값입니다.
- [FACT] 표본에는 외부 원문 전용 link와 entry-level type/category가 없습니다.
- [FACT] 외부 원문 직접 URL은 MVP 필수 조건이 아니며 RSS의 GeekNews topic link를 결과 링크로 사용할 수 있습니다.
- [FACT] 모든 `content`는 한국어 HTML이고, tag 제거 후 53~208자이며 40개가 말줄임표로 끝납니다.
- [INFERENCE] 50개 전체의 입력 충분성 검토에서 48개는 보수적인 2문장 요약이 가능하고 1개는 제한적이며 1개는 불충분합니다.
- [INFERENCE] 표본 기준 RSS 정보는 MVP 요약 입력으로 대체로 충분하며 GeekNews 상세 페이지 수집을 추가할 근거는 없습니다.
- [FACT] 모든 entry의 `published`와 `updated`는 같고 `+09:00`이며 최신순입니다.
- [FACT] GeekNews 이용약관은 서비스에 과도한 부하를 주는 자동화 접근, crawling과 script 실행을 금지합니다.
- [UNKNOWN] 허용 polling 기준, ID의 장기 안정성, 시각의 업무 의미, 고정 항목 수, 갱신 및 과거 노출 범위는 확인하지 못했습니다.

## Do Not Change

- [FACT] 사용자 승인 없이 MVP에 외부 원문 기사 본문 수집을 추가하지 않습니다.
- [FACT] 사용자 승인 없이 시사·경제 뉴스 또는 네이버 RSS를 MVP에 추가하지 않습니다.
- [FACT] 사용자 승인 없이 다중 AI 제공자 구현, Kafka 또는 Spark를 추가하지 않습니다.
- [FACT] 검증 없이 특정 AI 제공자를 확정하지 않습니다.
- [FACT] 무료 한도 초과 시 유료 호출로 자동 전환하지 않습니다.
- [FACT] 13시간 지연 목표를 누락 복구 조회 범위로 사용하지 않습니다.
- [FACT] 월별 Insight 보존이 보장되기 전에 관련 원천 데이터를 삭제하는 설계를 승인하지 않습니다.
- [FACT] 사용자 승인 없이 배포하거나 Git commit 또는 Git push를 실행하지 않습니다.
- [FACT] News, Ask와 Show를 source type 또는 title prefix만으로 수집·처리 후보에서 조기 제외하지 않습니다.
- [FACT] 사용자 승인 없이 MVP-B 기능을 MVP-A 완료 조건으로 되돌리지 않습니다.
- [FACT] 무료 한도나 처리 제약으로 전체 AI 분석을 수행하지 못한 후보를 조용히 제외하지 않습니다.
- [FACT] 실제 무료 AI 후보 검증 전에 보류·재시도, 제한 결과와 미발송의 정확한 조건과 우선순위를 고정하지 않습니다.
- [FACT] 장애 미발송을 신규 기사 0건 미발송과 같은 정상 상태로 기록하지 않습니다.
- [FACT] 관심 주제 밖이라는 이유만으로 후보를 제외하지 않습니다.
- [FACT] 홍보성이 애매한 후보를 주요 목록에서 자동 제외하지 않습니다.
- [FACT] 저정보 entry에 근거 없는 내용을 추가해 2~3문장을 강제로 만들지 않습니다.
- [FACT] Discord가 메시지를 받지 못한 발송 구간을 성공 처리하거나 신규 기사 구간을 전진시키지 않습니다.

## Known Issues

- [FACT] 정보가 부족한 항목은 후보 자격을 유지하고 선정 시 `정보 제한`과 근거가 허용하는 1문장 이하 설명으로 표시합니다.
- [UNKNOWN] 실제 무료 AI 후보의 한국어 요약 품질은 검증하지 않았습니다.
- [UNKNOWN] 제공된 표본에 Ask가 없어 Ask 항목의 요약 충분성은 검증하지 못했습니다.
- [UNKNOWN] GeekNews topic link와 Atom `id`의 장기 안정성, 시각의 업무 의미, 갱신 특성과 과거 노출 범위를 확인하지 못했습니다.
- [UNKNOWN] source type을 추론해 metadata로 보존할지 결정되지 않았습니다.
- [UNKNOWN] GeekNews RSS의 허용 polling 빈도와 conditional request 지원 여부를 확인하지 못했습니다.
- [FACT] 중요도와 관심 주제 적합성은 별도 축이며 관심 주제 밖이어도 전체 IT 영향도가 높으면 전달할 수 있습니다.
- [FACT] 홍보성 False Positive를 더 심각하게 다루고 애매한 후보를 제외하지 않습니다.
- [UNKNOWN] 중요도 점수 공식, 홍보성 label과 정확한 제외 임계값은 결정되지 않았습니다.
- [UNKNOWN] 제외 판정의 사유와 점수를 보존할지 결정되지 않았습니다.
- [UNKNOWN] 무료 AI 후보별 현재 할당량, 데이터 조건, 유료 전환 차단 방식과 한국어 품질을 검증하지 않았습니다.
- [FACT] AI 실패는 정상 0건과 구분하고 부분 결과에는 후보·정상 처리·미처리 건수와 전체 Top 10이 아니라는 사실을 표시합니다.
- [UNKNOWN] 부분 발송, 전체 미발송, 제한 결과, 보류와 재처리의 정확한 조건과 우선순위는 결정되지 않았습니다.
- [FACT] Discord 전달 실패 기사는 저장된 원래 batch의 논리적 발송 결과와 수량 요약을 지연 기사 구간으로 재사용하고 현재 신규 결과와 별도 구간으로 발송합니다.
- [UNKNOWN] 두 번 이상의 발송 시각 동안 Discord 장애가 지속될 때 backlog 상한과 분할 정책은 결정되지 않았습니다.
- [FACT] MVP-A의 혼합 feedback 방식, 최소 검증 표본, 품질 목표와 Hard Gate가 결정됐습니다.
- [FACT] 기사별 세 부정 reaction, batch별 ✅ 검토 완료, 암묵적 수용률과 구조화된 slash command 기반 누락 feedback 수단이 결정됐습니다.
- [UNKNOWN] 기사·batch·reaction의 정확한 Discord 표시와 mapping은 Interface Design에서 결정해야 합니다.
- [UNKNOWN] slash command의 정확한 이름·parameter·표시 언어와 누락 이유 응답 UI는 Interface Design에서 결정해야 합니다.
- [UNKNOWN] Discord Application의 Gateway·HTTP interaction·주기 조회 선택과 월 0원 실행 가능성은 검증하지 않았습니다.
- [FACT] 수집된 후보의 추천해야 했다는 recall 누락으로, 정상 Raw RSS 관찰 범위에서도 확인되지 않은 link만 수집원·수집 범위 누락으로 분리하고 수집·처리 실패와 원인 미확정은 별도 분류합니다.
- [UNKNOWN] MVP-A 최소 추적 정보의 품질 검토 완료 이후 임시 보존·삭제 제품 정책은 결정되지 않았습니다.
- [UNKNOWN] 월별 Insight의 전달 채널과 실행 시각이 정해지지 않았습니다.
- [UNKNOWN] 월 경계, 발송 경계와 재수집 중첩 범위의 정확한 상태 관리 방식이 정해지지 않았습니다.
- [FACT] 애플리케이션 코드, 데이터베이스, 테스트와 배포 환경이 없습니다.

## Technical Debt

- [FACT] 구현이 시작되지 않아 코드 수준 Technical Debt는 없습니다.
- [INFERENCE] 단계 문서의 종료 시점 상태와 프로젝트의 현재 상태를 혼동하지 않도록 이후 문서에는 historical snapshot과 current status를 더 명시적으로 구분하는 편이 안전합니다.

## Current Risks

- [INFERENCE] 저정보 표시 정책을 구현하더라도 말줄임표 뒤의 내용을 추정하거나 제한 결과를 정상 2~3문장 결과처럼 보이게 하면 근거 없는 확장이 발생할 수 있습니다.
- [INFERENCE] 중요도 점수 공식과 홍보성 임계값이 검증되지 않은 상태에서 세밀한 수치를 고정하면 유용한 기사가 제외되거나 홍보성 기사가 포함될 수 있습니다.
- [INFERENCE] 무료 AI의 할당량·약관·모델 제공 조건 변경은 월 운영비 0원 목표를 위협합니다.
- [INFERENCE] 표본에서는 GeekNews topic link와 `id`가 같지만 장기 안정성이 확인되지 않아 이를 검증 없이 고유 식별자로 사용하면 중복 방지 또는 갱신 처리에서 오류가 발생할 수 있습니다.
- [INFERENCE] News, Ask와 Show를 모두 후보로 처리하므로 승인된 관심 주제·중요도·홍보성 원칙을 실제 AI 품질과 임계값으로 검증하지 않으면 최종 큐레이션의 품질이 낮아질 수 있습니다.
- [INFERENCE] 모든 후보의 자격을 유지하면서 동일한 수준의 AI 처리를 보장하지 않으므로 fallback과 미처리 상태를 명확히 하지 않으면 중요한 기사 누락이 보이지 않을 수 있습니다.
- [INFERENCE] Discord 장애 복구 발송이 최대 20개까지 늘어나면 한 번의 메시지에서 사용자의 검토 부담이 증가할 수 있습니다.
- [INFERENCE] Discord 장애가 여러 발송 시각 동안 지속되면 아직 정하지 않은 backlog 상한과 분할 정책 때문에 지연 기사가 누락되거나 과도하게 누적될 수 있습니다.
- [INFERENCE] 기사별 reaction과 batch별 검토 완료를 Discord 메시지에 명확히 연결하지 못하면 feedback이 잘못된 기사나 batch에 귀속될 수 있습니다.
- [INFERENCE] Discord Application의 실행·수신 방식이 별도 유료 runtime을 요구하면 추가 월 운영비 0원 목표와 충돌할 수 있습니다.
- [INFERENCE] batch를 실제로 검토하지 않고 ✅ reaction을 남기면 암묵적 수용률이 과대평가될 수 있으므로 검토 완료의 의미를 사용자 안내와 지표 정의에서 유지해야 합니다.
- [INFERENCE] 정상 Raw RSS 관찰 범위에서도 확인되지 않은 link를 후보 recall에 포함하거나 수집·처리 실패를 수집원 누락으로 합치면 수집 품질과 선정 품질을 혼동하므로 원인 범주를 계속 분리해야 합니다.
- [INFERENCE] 월별 Insight 생성과 Raw 삭제 순서를 잘못 설계하면 장기 데이터가 손실될 수 있습니다.
- [INFERENCE] 신규 기사 0건, 부분 실패와 재실행 시 발송 구간을 잘못 관리하면 누락 또는 중복 전달이 발생할 수 있습니다.

## Last Verified

[FACT] 2026-08-25 Asia/Seoul 기준 Repository 초기 상태와 사용자 제공 요구사항을 확인했습니다.

[FACT] 현재 Git branch는 `main`이며 GitHub remote는 `https://github.com/rleoprleop/news-data-pipeline.git`입니다.

[FACT] 최초 commit `ed74291`이 local `main`과 `origin/main`에 반영됐음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 `docs/01-product/problem.md`와 확정 요구사항 사이에 범위 또는 목표 충돌이 없음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 Problem Definition을 명시적으로 승인했음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 GeekNews 공식 RSS URL, Atom 응답 형식, 콘텐츠 범위, 정렬 특성과 이용약관을 공식 자료로 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자 제공 RSS XML 표본의 feed-level metadata와 50개 entry fields, link, ID, content 및 시각 구조를 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 외부 원문 직접 URL은 필수가 아니며 RSS의 GeekNews topic link를 결과 링크로 사용할 수 있다고 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 News, Ask와 Show를 모두 데이터 파이프라인 후보로 처리하기로 결정했음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 RSS 표본 50개의 요약 입력 충분성을 검토해 48개 Sufficient, 1개 Limited, 1개 Insufficient로 평가했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 `docs/01-product/research.md`의 Research / JTBD 결과를 승인했음을 확인했습니다.

[FACT] live HTTP header와 시간에 따른 update behavior는 확인하지 못했으며, AI 제공자의 변동 가능한 외부 정보도 아직 공식 자료로 검증하지 않았습니다. 구현 시점의 공식 정보를 다시 확인해야 합니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 Solution Discovery의 네 가지 결정을 승인했고, Approach C 설명이 선택된 3B·4C와 일치하며, 기존 계획과 충돌할 때 현재 승인된 Problem Definition, Research / JTBD와 Current Product Guardrails를 적용함을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 commit `d377f1e`가 local `main`과 `origin/main`의 현재 tip이며 Start-of-Task Check 당시 working tree가 깨끗했음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 Repository에는 문서 외 애플리케이션 코드와 테스트가 없고 TODO/FIXME도 없음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 Feature Prioritization 제안이 승인된 Problem Definition, Research / JTBD, Solution Discovery의 범위와 Guardrail을 변경하지 않고 기능 후보·평가·추천·Trade-off와 `[UNKNOWN]`을 구분하는지 검토했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 최초 Feature Prioritization의 P0·P1 MVP 포함, 후순위 기능, 기존 제외 범위와 주요 Trade-off 전체를 승인했고 이후 비판적 제품 검토에서 MVP-A/MVP-B로 범위를 개정했음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 README, Feature Prioritization과 AI Context의 현재 단계·승인 상태·다음 Task 표기가 서로 일치하도록 동기화했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 commit `bd4b359`가 local `main`과 `origin/main`의 현재 tip이며 비판적 제품 검토 시작 당시 working tree가 깨끗했음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 MVP-A/MVP-B 분리, 중요 기사 누락 우선, 모든 후보 자격 유지와 비무음 fallback 방향을 승인했음을 확인했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 사용자가 후보 자격 유지, 무료 AI 후보 검증, fallback 명세 순서와 장애 미발송 구분 원칙을 확인했음을 검증했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 위 보완 결정이 Repository 운영 규칙, 현재 상태와 네 단계 제품 문서에 일관되게 반영됐는지 검토했습니다.

[FACT] 2026-08-25 Asia/Seoul 기준 보완 결정 동기화 commit `40d1dc8`이 local `main`과 `origin/main`에 반영됐습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 Product Specification 시작 전 `HEAD`, `main`과 `origin/main`이 `40d1dc8`로 일치하고 working tree가 깨끗했음을 확인했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 사용자가 중요도·관심 주제, 홍보성, 저정보 entry, 실패 가시성, Discord 복구, feedback과 MVP-A 합격선 정책을 승인했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 승인된 정책을 `docs/01-product/product-spec.md` Draft에 작성하고 이전 단계의 오래된 commit/push 대기 표현을 현재 Git history에 맞게 정리했으며 문서 정합성을 검토했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 사용자가 `docs/01-product/product-spec.md`를 최종 승인했고 문서 상태와 Project Context를 Product Specification 완료 상태로 동기화했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 Technical Requirements 시작 전 `HEAD`, `main`과 `origin/main`이 `e9f02a0`으로 일치하고 working tree가 깨끗했으며 Repository에 애플리케이션 코드·테스트·TODO·FIXME가 없음을 확인했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 GeekNews RSS·이용약관, Gemini API rate limit·추가 약관, Discord webhook·rate limit·reaction·interaction 공식 문서를 확인하고 변동 가능한 조건과 미검증 live 동작은 `[UNKNOWN]`으로 분리했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 Technical Requirement 91개의 ID가 모두 고유하고 모든 요구사항 행에 제품 근거·검증 방법·`[UNKNOWN]` 미결정 의존성이 있음을 검사했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 Acceptance Criteria Traceability Matrix가 AC-01~AC-24를 누락·중복 없이 포함하고 변경 문서의 local link, trailing whitespace와 Git diff 형식 검사를 통과했음을 확인했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 README, Product Specification, Technical Requirements와 AI Context의 현재 Workflow 단계·feedback 정책·미결정 범위가 서로 충돌하지 않음을 검토했습니다.

[FACT] 2026-08-26 Asia/Seoul 기준 FR-001~FR-024 순차 검토를 완료하고 다음 재개 위치를 NFR-REL-001로 확정했으며, 전체 Draft는 최종 승인 전 상태로 유지했습니다.

## Last Updated

[FACT] 2026-08-26 Asia/Seoul
