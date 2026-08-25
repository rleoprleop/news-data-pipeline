# Problem Definition

## Document Status

[FACT] 상태: Approved

[FACT] 승인일: 2026-08-25 Asia/Seoul

[FACT] 승인자: 프로젝트 사용자 및 소유자

[FACT] 작성 기준일: 2026-08-25 Asia/Seoul

[FACT] 이 문서는 제품이 해결할 문제, MVP 범위, 성공 목표와 검증해야 할 항목을 정의합니다.

[FACT] 이 문서는 Architecture, 데이터 모델 또는 구현 방식을 확정하지 않습니다.

[FACT] 승인된 문제, 목표 또는 MVP 범위를 변경하려면 사용자 승인이 필요합니다.

## Problem Statement

[FACT] 사용자는 여러 IT 뉴스 페이지를 직접 방문하고 중요한 기사를 선별한 뒤 내용을 별도로 정리하는 데 시간과 노력을 사용하고 있습니다.

[FACT] 사용자는 광고성·홍보성 기사를 구분하기 어렵고, 중요한 기술 변화와 읽어야 할 원문을 효율적으로 찾고 싶어 합니다.

[INFERENCE] 해결할 핵심 문제는 다음과 같습니다.

> 한 명의 사용자가 한국어 IT 뉴스에서 중요한 기사와 기술 트렌드를 하루 두 번 빠르게 파악하고 관심 있는 원문으로 이동할 수 있도록, 제한된 정보와 0원의 추가 월 운영비 안에서 신뢰할 수 있는 큐레이션 결과를 지속적으로 제공해야 한다.

## Target User

- [FACT] 사용자는 프로젝트 소유자 한 명입니다.
- [FACT] 팀용 정보 시스템이나 다중 사용자 서비스는 MVP의 대상이 아닙니다.
- [INFERENCE] 이 제품은 범용 뉴스 플랫폼보다 개인용 IT 뉴스 큐레이션 도구에 가깝습니다.

## User Job and Current Pain

### Job to Be Done

[INFERENCE] 사용자가 하루의 주요 확인 시점에 최신 IT 뉴스를 살펴볼 때, 여러 페이지를 순회하지 않고 중요한 기사와 기술 트렌드를 파악하여 읽을 원문을 빠르게 선택하고 싶습니다.

### Current Pain

- [FACT] 여러 뉴스 페이지를 직접 방문해야 합니다.
- [FACT] 기사 내용을 직접 선별하고 따로 정리해야 합니다.
- [FACT] 광고성·홍보성 기사를 걸러내기 어렵습니다.
- [FACT] 중요한 기사와 기술 트렌드를 제한된 시간 안에 파악하고 싶습니다.

### Desired Outcome

- [FACT] 매일 정해진 두 시점에 중요한 기사 목록을 확인할 수 있어야 합니다.
- [FACT] 각 기사에서 핵심 내용을 빠르게 이해하고 원문 링크로 이동할 수 있어야 합니다.
- [FACT] 홍보성으로 의심되는 기사는 주요 결과에서 제외되어야 합니다.
- [FACT] 월별로 관심 기술 주제와 키워드의 변화를 확인할 수 있어야 합니다.

## MVP Scope

### Included

- [FACT] 언어: 한국어
- [FACT] 수집원: GeekNews RSS 하나
- [FACT] 관심 주제: 데이터 엔지니어링, 클라우드, AI, 백엔드, 개발 도구, 데이터베이스
- [FACT] 처리 데이터: RSS 제목, 설명, 링크와 관련 메타데이터
- [FACT] 결과 채널: Discord
- [FACT] 일일 큐레이션: 이전 발송 이후 수집된 기사 중 중요도순 최대 10개
- [FACT] 월별 Insight: 주제 비중, 전월 대비 주제 비중 증감, 신규·급증 키워드, 주요 주제별 대표 기사
- [FACT] Retention: Raw RSS 3개월, 기사별 AI 결과 12개월, 월별 Insight 무기한

### Explicitly Excluded

- [FACT] 외부 원문 기사 본문 수집
- [FACT] 다중 뉴스 수집원
- [FACT] 시사·경제 뉴스
- [FACT] 네이버 RSS
- [FACT] 여러 AI 제공자의 동시 구현
- [FACT] 추가 월 운영비가 발생하는 자동 유료 호출
- [FACT] 팀·다중 사용자 기능
- [FACT] Kafka와 Spark

### Conditional Follow-up

[FACT] RSS 제목과 설명만으로 요약 품질이 부족하다는 검증 결과가 나온 경우에만 GeekNews 상세 페이지 수집을 검토합니다.

[FACT] 상세 페이지 수집은 현재 MVP 범위가 아니며 사용자 승인 없이 추가하지 않습니다.

## Daily Discord Output

### Schedule and Selection

- [FACT] 발송 시각은 매일 10:00와 22:00 KST입니다.
- [FACT] 이전 발송 이후 수집된 기사 중 중요도순으로 최대 10개를 선택합니다.
- [FACT] 신규 기사가 없으면 Discord 메시지를 발송하지 않습니다.
- [FACT] 기사 전달 목표는 게시 후 최대 13시간 이내입니다.
- [FACT] 각 발송 배치는 30분 이내 완료해야 합니다.

### Article Format

[FACT] 각 기사는 한국어로 다음 정보를 표시합니다.

1. 제목
2. 2~3문장 요약
3. 키워드
4. 링크

[FACT] 원문 접근이 가능하지 않더라도 RSS가 제공한 기사 링크는 결과에 포함합니다.

### Promotional Content

- [FACT] 홍보성으로 의심되는 기사는 주요 기사 목록에서 제외합니다.
- [FACT] 제외된 기사가 있으면 `홍보성 의심 제외 N건` 형식으로 개수만 표시합니다.
- [UNKNOWN] 중요도 산정 기준은 아직 정의되지 않았습니다.
- [UNKNOWN] 홍보성 의심 판정 기준과 제외 임계값은 아직 정의되지 않았습니다.
- [UNKNOWN] 오판 검토를 위해 판정 사유, 점수와 모델 정보를 보존할지 결정되지 않았습니다.
- [INFERENCE] 포트폴리오의 추적 가능성과 품질 검증을 위해 판정 근거를 재검토할 수 있는 정보가 필요할 가능성이 높습니다.

## Monthly Insight

### Required Content

- [FACT] 해당 월의 주제별 기사 비중
- [FACT] 전월 대비 주제별 비중 증감
- [FACT] 새롭게 떠오른 키워드
- [FACT] 전월 대비 급증한 키워드
- [FACT] 주요 주제별 대표 기사

### Comparison Rule

- [FACT] 첫 달에는 전월 비교를 생략합니다.
- [FACT] 두 번째 달부터 전월 대비 비교를 제공합니다.

### Preservation

- [FACT] 월별 Insight는 기간 제한 없이 보존합니다.
- [UNKNOWN] 월별 Insight를 Discord에도 발송할지, 저장만 할지 결정되지 않았습니다.
- [UNKNOWN] 월별 집계 실행일과 시각은 결정되지 않았습니다.
- [UNKNOWN] 주제 비중의 분모, 다중 주제 기사의 집계 방식과 대표 기사 선정 기준은 결정되지 않았습니다.
- [UNKNOWN] 신규·급증 키워드를 판단할 최소 빈도와 비교 공식은 결정되지 않았습니다.

## Data Retention

- [FACT] Raw RSS 데이터 보존 기간은 3개월입니다.
- [FACT] 기사별 AI 요약, 키워드와 판정 결과의 보존 기간은 12개월입니다.
- [FACT] 월별 Insight는 무기한 보존합니다.
- [FACT] 각 보존 기간은 코드에 고정하지 않고 나중에 쉽게 변경할 수 있는 설정값으로 분리합니다.
- [INFERENCE] 데이터 삭제는 월별 Insight 생성과 필요한 검증이 성공했음을 확인한 이후에만 수행하는 방향이 안전합니다.
- [UNKNOWN] 삭제 대상 판정 기준 시각, 실패 시 동작, Audit 기록과 복구 정책은 Technical Requirements 단계에서 결정해야 합니다.

## Capacity, Cost and Service Goals

### Capacity

- [FACT] 초기 처리 기준은 최대 100건/일입니다.
- [FACT] 실제 기사량과 API 사용량을 첫 2~4주 동안 측정합니다.
- [FACT] 측정 결과를 바탕으로 용량 기준과 처리 정책을 재검토합니다.

### Cost

- [FACT] 프로젝트의 추가 월 운영비 상한은 0원입니다.
- [FACT] 무료 할당량 소진 후 유료 호출로 자동 전환하면 안 됩니다.
- [FACT] ChatGPT Pro 사용량은 OpenAI API 무료 사용량이 아닙니다.
- [FACT] OpenAI Platform에 별도 무료 API credit이 공식적으로 확인될 때만 OpenAI 모델을 무료 후보로 평가할 수 있습니다.

### Delivery Goals

- [FACT] 기사 게시 후 Discord 전달까지 최대 13시간을 목표로 합니다.
- [FACT] 각 발송 배치는 30분 이내 완료를 목표로 합니다.
- [FACT] 13시간은 전달 지연 목표일 뿐 누락 복구 조회 범위가 아닙니다.
- [UNKNOWN] GeekNews RSS의 게시 시각·수집 시각 필드와 갱신 특성을 확인한 뒤 지연 측정의 시작점을 확정해야 합니다.

## Collection and Recovery Direction

[FACT] 누락 복구 범위를 단순히 최근 13시간으로 제한하지 않습니다.

[INFERENCE] 현재 권장된 출발 방향은 마지막 성공 수집 시점부터 충분한 중첩 범위를 두고 다시 수집하는 것입니다.

[INFERENCE] 중복 제거의 출발 방향은 데이터베이스의 `link UNIQUE`와 `ON CONFLICT` 사용입니다.

[UNKNOWN] 다음 항목을 Data / Interface Design 전에 검증해야 합니다.

- GeekNews RSS 링크가 항목의 수명 동안 안정적인지
- 동일 기사가 다른 링크로 제공될 가능성
- 추적 파라미터 또는 URL 정규화 필요성
- RSS 항목 수정 시 같은 링크의 제목·설명을 갱신할지
- 마지막 성공 시점의 정의와 부분 성공 시 처리
- 충분한 중첩 범위의 길이
- 발송 기준점과 수집 기준점을 분리할지 여부

## AI Processing Direction

- [FACT] AI 제공자를 Gemini로 고정하지 않습니다.
- [FACT] MVP에서는 무료 제공자 하나만 선택해 연동합니다.
- [FACT] 이후 제공자를 교체할 수 있는 경계를 마련합니다.
- [FACT] 여러 제공자를 동시에 구현하지 않습니다.
- [FACT] 공개된 GeekNews RSS 제목과 설명이 무료 AI 제공자의 약관에 따라 서비스 개선 등에 이용될 가능성은 허용합니다.
- [FACT] Gemini 무료 API를 우선 검증 후보로 사용할 수 있습니다.
- [FACT] 무료 할당량 소진 시 유료 호출로 자동 전환하지 않습니다.
- [UNKNOWN] 제공자 선정 기준과 실패 시 AI 처리를 보류하는 동작은 Technical Requirements 단계에서 결정해야 합니다.

## Validation Required Before Implementation

### GeekNews RSS

- [UNKNOWN] 실제 공식 RSS URL
- [UNKNOWN] 제공 필드와 필드별 의미
- [UNKNOWN] 게시 시각, 수정 시각, ID 또는 GUID 제공 여부
- [UNKNOWN] 설명 길이와 정보량
- [UNKNOWN] 링크 대상과 링크 안정성
- [UNKNOWN] 갱신 주기와 과거 항목 노출 범위
- [UNKNOWN] 이용 조건과 자동 수집 허용 범위

### AI Provider

- [UNKNOWN] 후보별 현재 무료 할당량과 Rate limit
- [UNKNOWN] 무료 할당량 초과 시 과금 차단 방법
- [UNKNOWN] 입력 데이터의 저장·서비스 개선 이용 조건
- [UNKNOWN] 모델 제공 안정성과 무료 정책 변경 가능성
- [UNKNOWN] 제목·설명만 입력했을 때의 한국어 2~3문장 요약 품질
- [UNKNOWN] 키워드, 주제, 중요도와 홍보성 판정 품질
- [UNKNOWN] 100건/일과 하루 두 번 처리에 필요한 실제 요청·Token 사용량

### Product Quality

- [UNKNOWN] 사용자가 유용하다고 판단하는 기사 선택 정확도
- [UNKNOWN] 중요 기사를 놓치는 허용 수준
- [UNKNOWN] 홍보성 기사의 False Positive와 False Negative 허용 수준
- [UNKNOWN] 요약이 RSS 설명에 없는 내용을 추론하는 문제의 허용 기준
- [UNKNOWN] 링크가 접근 불가한 경우 사용자 경험

[FACT] 위 외부 정보는 구현 시점의 공식 자료를 기준으로 확인합니다.

## Initial Success Criteria

[INFERENCE] 다음 기준은 Product Specification 단계에서 측정 방법과 합격선을 구체화해야 하는 초기 성공 기준입니다.

- [FACT] 사용자가 하루 두 번 결과로 중요한 기사를 선별하고 원문으로 이동할 수 있습니다.
- [FACT] 신규 기사가 없을 때 불필요한 Discord 메시지를 받지 않습니다.
- [FACT] 홍보성 의심 기사가 주요 목록에서 제외되고 제외 건수를 확인할 수 있습니다.
- [FACT] 기사 게시 후 최대 13시간 이내 전달과 발송 배치 30분 이내 완료를 목표로 합니다.
- [FACT] 최대 100건/일의 초기 처리 기준을 검증할 수 있습니다.
- [FACT] 추가 월 운영비가 0원을 초과하지 않으며 무료 한도 소진 시 유료 호출이 차단됩니다.
- [FACT] 월별 Insight가 생성되고 설정된 Retention 이후에도 기간 제한 없이 남습니다.
- [INFERENCE] 재실행과 외부 API 부분 실패에도 기사 누락·중복 저장·중복 전달을 식별하고 복구할 수 있어야 합니다.

## Problem Definition Exit Criteria

[INFERENCE] 다음 항목이 충족되면 사용자 승인 후 Research / JTBD 단계로 이동할 수 있습니다.

- [FACT] 사용자와 JTBD가 문서에 올바르게 반영됐는지 확인
- [FACT] MVP 포함·제외 범위 확인
- [FACT] 일일 Discord 결과와 월별 Insight 요구 확인
- [FACT] Retention, 용량, 비용과 지연 목표 확인
- [FACT] `[UNKNOWN]` 항목 중 다음 단계에서 조사할 항목과 설계 단계에서 결정할 항목 구분
- [FACT] 사용자의 명시적 Problem Definition 승인 — 2026-08-25 완료
