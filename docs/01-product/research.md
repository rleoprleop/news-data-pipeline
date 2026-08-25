# Research / JTBD

## Document Status

[FACT] Workflow 단계: Research / JTBD

[FACT] 상태: Approved

[FACT] 승인일: 2026-08-25 Asia/Seoul

[FACT] 승인자: 프로젝트 사용자 및 소유자

[FACT] 조사 기준일: 2026-08-25 Asia/Seoul

[FACT] 이 문서는 승인된 [Problem Definition](problem.md)을 바탕으로 사용자의 Job to Be Done을 구체화하고, 첫 수집원인 GeekNews RSS의 공식 정보와 남은 검증 항목을 기록합니다.

[FACT] 이 문서는 Solution, 기능 우선순위, Architecture, 데이터 모델, AI 제공자 또는 구현 방식을 확정하지 않습니다.

[FACT] 사용자가 2026-08-25에 이 Research / JTBD 결과를 승인했습니다.

## Research Scope and Method

### In Scope

- [FACT] 승인된 사용자 문제와 원하는 결과를 JTBD 관점으로 재구성
- [FACT] GeekNews RSS의 공식 URL, 형식, 콘텐츠 범위와 정렬 특성 조사
- [FACT] 링크 의미, 제공 필드, 갱신 특성 및 이용 조건에 대해 확인된 내용과 미확인 내용 분리
- [FACT] 다음 설계 단계 전에 해소해야 할 검증 항목 식별

### Out of Scope

- [FACT] Solution Discovery와 Feature Prioritization
- [FACT] 중요도·홍보성 판정 기준 또는 합격선 결정
- [FACT] AI 제공자 비교와 선정
- [FACT] 수집 주기, 재수집 범위, URL 정규화 또는 데이터 모델 결정
- [FACT] 코드, 테스트, 배포 구성과 Git commit

### Evidence Rules

- [FACT] 사용자와 제품 요구에 관한 근거는 승인된 [Problem Definition](problem.md)을 사용했습니다.
- [FACT] GeekNews에 관한 근거는 GeekNews가 운영하는 공식 사이트, 공식 공지와 운영자 답변을 우선 사용했습니다.
- [FACT] Atom 표준의 역할은 IETF 문서를 사용했습니다.
- [FACT] 변동 가능한 외부 정보는 2026-08-25 Asia/Seoul 기준으로 확인했으며 구현 직전에 다시 검증해야 합니다.
- [FACT] 사용자가 2026-08-25에 제공한 45,955 byte RSS XML 표본을 파싱해 실제 feed와 entry 구조를 관찰했습니다.
- [FACT] 제공된 XML은 한 시점의 표본이며 live HTTP header와 서로 다른 시점의 feed 비교는 수행하지 않았습니다.
- [INFERENCE] 한 표본으로 확인할 수 없는 장기 안정성, 수정·삭제 반영과 HTTP 동작은 Atom 표준이나 과거 공지만으로 추정하지 않고 `[UNKNOWN]`으로 유지하는 것이 안전합니다.

## JTBD

### Evidence from the Approved Problem

- [FACT] 사용자는 프로젝트 소유자 한 명입니다.
- [FACT] 사용자는 매일 10:00와 22:00 KST에 IT 뉴스를 확인합니다.
- [FACT] 사용자는 여러 뉴스 페이지를 방문하고 기사를 선별한 뒤 내용을 따로 정리하는 데 시간과 노력을 사용합니다.
- [FACT] 사용자는 광고성·홍보성 기사를 구분하기 어렵습니다.
- [FACT] 사용자는 중요한 기술 변화와 읽을 원문을 제한된 시간 안에 찾고 싶어 합니다.
- [FACT] 사용자는 월별로 관심 기술 주제와 키워드의 변화를 확인하고 싶어 합니다.

### Core Job Statement

[INFERENCE] 사용자가 하루의 주요 뉴스 확인 시점에 최신 한국어 IT 뉴스를 살펴볼 때, 여러 페이지를 순회하거나 광고성 글을 일일이 가려내지 않고 중요한 기술 변화와 읽을 원문을 빠르게 판단하여 제한된 시간 안에 놓치면 안 되는 기사와 장기 추세를 신뢰할 수 있게 파악하고 싶습니다.

### Functional Jobs

1. [INFERENCE] 지금 확인할 가치가 높은 기사를 빠르게 구분합니다.
2. [INFERENCE] 원문을 열기 전에 판단에 필요한 최소한의 맥락을 파악합니다.
3. [INFERENCE] 관심 있는 기사의 GeekNews topic으로 이동하고, 외부 원문이 있는 경우 필요에 따라 원문으로 이동합니다.
4. [INFERENCE] 광고성·홍보성으로 의심되는 콘텐츠로 인한 검토 부담을 줄입니다.
5. [INFERENCE] 월별 주제와 키워드 변화를 통해 단일 기사보다 긴 기술 흐름을 파악합니다.

### Desired Outcomes

- [INFERENCE] 중요 기사를 찾는 데 필요한 검토 시간을 줄입니다.
- [INFERENCE] 중요 기사를 놓칠 가능성을 줄입니다.
- [INFERENCE] 홍보성 콘텐츠를 직접 판별해야 하는 횟수를 줄입니다.
- [INFERENCE] 요약에서 RSS가 제공한 GeekNews topic으로 이동할 수 있는 추적 가능성을 유지합니다.
- [INFERENCE] 새로운 기사가 없을 때 불필요한 알림으로 주의를 빼앗기지 않습니다.
- [INFERENCE] 월별 변화가 실제 기사와 연결되어 다시 확인할 수 있게 합니다.

### JTBD Validation Gaps

- [UNKNOWN] 현재 뉴스 확인과 정리에 실제로 드는 기준 시간과 목표 절감 시간
- [FACT] 2026-08-25의 후속 비판적 제품 검토에서 사용자가 중요 기사 누락을 비중요 기사 포함보다 더 심각한 오류로 다루기로 승인했습니다.
- [UNKNOWN] 관심 주제 안에서 중요도를 가르는 신호와 우선순위
- [UNKNOWN] 홍보성 판정의 False Positive와 False Negative 허용 수준
- [UNKNOWN] GeekNews topic 링크가 접근 불가할 때 제공된 요약만으로도 결과가 유용한지
- [UNKNOWN] 월별 Insight를 확인하는 상황, 전달 채널과 실행 시점

[INFERENCE] 위 항목은 Product Specification의 합격선을 미리 결정하기 위한 질문이 아니라, Research / JTBD 승인 시 사용자의 우선순위를 확인하기 위한 질문입니다.

## GeekNews RSS Research

### Verified Source Facts

1. [FACT] GeekNews 현재 사이트의 RSS 링크는 [https://news.hada.io/rss/news](https://news.hada.io/rss/news)입니다.
2. [FACT] RSS 링크는 GeekNews의 현재 About, 이용법과 이용약관 페이지 하단에서 공식적으로 제공됩니다.
3. [FACT] RSS endpoint는 현재 `application/atom+xml` 콘텐츠 형식으로 응답합니다.
4. [FACT] GeekNews의 [RSS 공개 공지](https://news.hada.io/blog/geeknews_feed)는 이 피드가 GeekNews에 등록되는 모든 News, Ask와 Show 글을 자동으로 노출한다고 설명합니다.
5. [FACT] 같은 공지는 피드가 시간순이고, 사용자 투표로 순위가 달라지는 GeekNews 첫 화면과 일치하지 않을 수 있다고 설명합니다.
6. [FACT] GeekNews의 [RSS 공개 토픽](https://news.hada.io/topic?id=5674)은 피드를 `Atom (RFC5023)` 형식이라고 설명합니다.
7. [FACT] IETF의 [RFC 5023](https://datatracker.ietf.org/doc/html/rfc5023)은 Atom 형식의 표현을 사용해 웹 리소스를 게시·편집하는 Atom Publishing Protocol을 정의합니다.
8. [FACT] IETF의 [RFC 4287](https://datatracker.ietf.org/doc/html/rfc4287)은 피드와 entry를 구성하는 Atom Syndication Format을 정의합니다.
9. [FACT] 사용자 제공 XML의 root는 Atom namespace `http://www.w3.org/2005/Atom`을 사용하는 `feed`입니다.
10. [INFERENCE] 따라서 GeekNews 공지의 표준 표기는 제공자의 설명으로 보존하되, 실제 feed parsing 기준은 관찰한 Atom namespace와 요소를 사용해야 합니다.
11. [FACT] GeekNews 운영자는 2023-12-19 답변에서 당시 GN+ 글을 `author`가 `neo`인 항목으로 필터링할 수 있다고 설명했습니다. 근거는 [공식 사이트의 운영자 답변](https://news.hada.io/topic?id=12418)입니다.
12. [UNKNOWN] 위 `author=neo` 규칙이 현재도 모든 GN+ 글에 적용되는지, 다른 콘텐츠 유형을 안정적으로 구분하는 데 사용할 수 있는지는 확인하지 못했습니다.

### User-provided XML Snapshot

#### Feed-level Structure

- [FACT] 표본의 feed-level 요소는 `title`, `subtitle`, `link` 2개, `id`, `updated`, `author`, `category`, `icon`, `logo`와 `entry` 50개입니다.
- [FACT] `id`는 `https://news.hada.io/rss/news`입니다.
- [FACT] `link rel="self"`는 `application/atom+xml` 형식의 `https://news.hada.io/rss/news`를 가리킵니다.
- [FACT] `link rel="alternate"`는 `text/html` 형식의 `https://news.hada.io`를 가리킵니다.
- [FACT] feed `author`는 `GeekNews`, category term은 `technology`입니다.
- [FACT] feed `updated`는 `2026-08-25T10:40:52+09:00`이며 표본의 가장 최신 entry 시각과 같습니다.

#### Entry Structure

- [FACT] 50개 entry는 모두 `title`, `link`, `id`, `updated`, `published`, `author`, `content`를 각각 하나씩 같은 순서로 제공합니다.
- [FACT] 각 `author`는 `name`과 `https://news.hada.io/user/{name}` 형식의 `uri`를 제공합니다.
- [FACT] 표본에는 entry-level `summary`, `category`, 별도 GUID 또는 외부 원문 전용 필드가 없습니다.
- [FACT] 50개 `id`와 50개 `link`는 표본 안에서 각각 모두 고유합니다.
- [FACT] 모든 entry에서 `id`와 `link href`가 같습니다.

#### Link and Content

- [FACT] 50개 entry의 유일한 `link`는 모두 `rel="alternate"`, `type="text/html"`이며 `https://news.hada.io/topic?id={number}` 형식의 GeekNews 상세 페이지를 가리킵니다.
- [FACT] 외부 원문 URL을 직접 제공하는 entry-level link relation은 표본에 없습니다.
- [FACT] `content`는 50개 모두 `type="html"`, `xml:lang="ko"`이고 CDATA 안에 HTML을 포함합니다.
- [FACT] HTML tag를 제거한 content 길이는 표본에서 최소 53자, 중앙값 156자, 최대 208자이며 빈 content는 없습니다.
- [FACT] 50개 content 중 40개는 plain text가 `...` 또는 `…`로 끝납니다.
- [FACT] 50개 content 중 anchor를 포함한 것은 1개이고, 나머지 49개에는 URL anchor가 없습니다.
- [INFERENCE] 표본의 `content`에서 외부 원문 URL을 일반적으로 추출할 수 있다고 가정하면 안 됩니다.

#### Time and Ordering

- [FACT] 50개 entry가 모두 `published`와 `updated`를 제공하며 각 entry에서 두 값은 같습니다.
- [FACT] 모든 entry 시각의 UTC offset은 `+09:00`입니다.
- [FACT] 표본의 시각 범위는 `2026-08-23T23:42:10+09:00`부터 `2026-08-25T10:40:52+09:00`까지입니다.
- [FACT] entry는 `published` 기준 최신순이며 역순 위반은 없습니다.
- [UNKNOWN] 한 표본에 50개가 있다는 사실만으로 feed가 항상 최근 50개를 제공한다고 확정할 수 없습니다.

#### Content Type Signals

- [FACT] 표본에는 `Show GN:`으로 시작하는 title이 5개 있고 `Ask GN:` 또는 `To GN:`으로 시작하는 title은 없습니다.
- [FACT] 표본의 entry-level 요소에는 콘텐츠 유형을 명시하는 category 또는 type 필드가 없습니다.
- [FACT] 표본에는 10명의 author가 있고 `neo`가 38개 entry의 author입니다.
- [INFERENCE] `Show GN:` title prefix는 이 표본의 Show 항목을 식별하지만, 모든 유형과 미래 title 형식에 적용되는 안정적인 계약으로 볼 수 없습니다.
- [FACT] 사용자는 2026-08-25에 News, Ask와 Show를 모두 데이터 파이프라인의 일반 후보로 처리하기로 결정했습니다.
- [FACT] source type 또는 title prefix만으로 Ask와 Show를 수집·처리 후보에서 조기 제외하지 않습니다.
- [INFERENCE] source type 식별은 후보 포함 조건이 아니며, 관심 주제·중요도·홍보성에 따른 최종 처리 판단을 대체하지 않습니다.
- [UNKNOWN] source type을 추론해 metadata로 보존할지는 Data / Interface Design에서 결정해야 합니다.

### Feed Scope versus MVP Scope

- [FACT] 승인된 MVP는 한국어 IT 뉴스를 대상으로 합니다.
- [FACT] GeekNews 공식 피드는 News뿐 아니라 Ask와 Show도 포함합니다.
- [FACT] GeekNews의 [About](https://news.hada.io/about)은 News, Ask와 Show를 서로 다른 섹션으로 설명합니다.
- [FACT] News, Ask와 Show는 모두 수집·처리 후보에 포함합니다.
- [INFERENCE] 후보 입력 범위와 최종 전달 대상을 분리하여, source type이 아니라 관심 주제·중요도·홍보성 처리 결과로 출력 포함 여부를 판단하는 방향입니다.
- [UNKNOWN] 최종 Discord 출력과 월별 Insight 집계에 포함할 정확한 기준은 Product Specification에서 결정해야 합니다.

### Title, Description and Content Meaning

- [FACT] GeekNews [이용법](https://news.hada.io/guidelines)은 등록자가 원 제목을 사용하거나 제목을 한국어로 번역할 수 있고, 원문을 더 잘 설명하도록 제목을 바꿀 수도 있다고 안내합니다.
- [FACT] 같은 이용법은 등록 내용에 원문 요약 또는 영문 원문의 한국어 번역 요약을 직접 작성할 수 있다고 안내합니다.
- [INFERENCE] GeekNews의 제목과 본문은 외부 원문의 원문 메타데이터와 동일하다고 가정할 수 없습니다.
- [FACT] 사용자 제공 표본에서 등록 내용은 entry의 `content type="html" xml:lang="ko"`에 매핑되며 `summary`는 제공되지 않습니다.
- [FACT] 표본의 50개 content는 모두 비어 있지 않고, HTML tag 제거 후 길이는 53~208자이며 중앙값은 156자입니다.
- [FACT] 표본의 40개 content가 말줄임표로 끝나므로 제공된 내용이 완결된 요약인지 추가 검증이 필요합니다.
- [INFERENCE] 말줄임표 뒤의 누락 내용을 추정하지 않고 title과 명시적으로 제공된 content만 요약 근거로 사용해야 합니다.

### RSS Summary Sufficiency Validation

#### Method

- [FACT] 검증 대상은 SHA-256 `679E3295C2B4024C15FB8EE9F9108AE54D54728D2B36CE094E492AED5928DBAD`인 사용자 제공 RSS XML 표본의 50개 entry 전체입니다.
- [FACT] 각 entry의 `title`과 HTML tag를 제거한 `content`만 검토했으며 GeekNews topic과 외부 원문은 사용하지 않았습니다.
- [FACT] 특정 AI 제공자나 모델을 호출하지 않았습니다.
- [INFERENCE] 주제, 핵심 주장·변화·기능과 최소 한 가지 근거·영향·사용 맥락을 확인할 수 있고 새로운 사실 없이 보수적인 2문장으로 재구성할 수 있으면 `Sufficient`로 판정했습니다.
- [INFERENCE] 핵심 주제는 알 수 있지만 두 문장을 만들 근거가 약하면 `Limited`, 반복이나 추론 없이 두 문장을 만들 수 없으면 `Insufficient`로 판정했습니다.

#### Results

- [INFERENCE] `Sufficient`: 48개, 표본의 96%입니다.
- [INFERENCE] `Limited`: 1개, 표본의 2%입니다.
- [INFERENCE] `Insufficient`: 1개, 표본의 2%입니다.
- [FACT] 48개 Sufficient 항목의 plain content는 모두 100자 이상입니다.
- [FACT] 5개 Show 항목의 content는 156~172자이며, 모두 문제·기능 또는 사용 맥락을 제공합니다.
- [INFERENCE] 5개 Show 항목은 모두 보수적인 2문장 요약에 충분했습니다.
- [FACT] 표본에는 Ask 항목이 없습니다.

#### Exceptions

- [INFERENCE] `SonicMoE로 보는 GPU 커널 최적화`는 content가 53자이고 SonicMoE를 예시로 효율적인 GPU kernel 설계를 설명한다는 소개만 있어 `Insufficient`로 판정했습니다.
- [INFERENCE] `AI가 인간의 실행력을 확장하려면 무엇이 필요한가`는 content가 85자이고 두 글의 공통 관점만 일부 제공해 `Limited`로 판정했습니다.

#### Interpretation

- [INFERENCE] 이 표본에서는 RSS title과 content만으로 대부분의 항목을 사실에 충실한 짧은 요약으로 재구성할 수 있으므로, 현재 근거만으로 GeekNews 상세 페이지 수집을 MVP에 추가할 필요는 없습니다.
- [INFERENCE] 2~3문장을 기계적으로 채우면 정보가 부족한 항목에서 반복이나 근거 없는 확장이 발생할 수 있습니다.
- [UNKNOWN] 정보가 부족한 항목을 1문장으로 허용할지, 요약 불충분으로 표시할지, 주요 후보에서 제외할지는 Product Specification에서 결정해야 합니다.
- [UNKNOWN] 실제 무료 AI 후보가 같은 입력으로 사실에 충실한 한국어 요약을 생성하는지는 AI Provider 검증에서 평가해야 합니다.
- [UNKNOWN] Ask 항목의 요약 충분성은 Ask가 포함된 추가 표본으로 검증해야 합니다.

### Link Meaning and Identity

- [FACT] GeekNews [About](https://news.hada.io/about)은 웹의 토픽 목록에서 제목을 누르면 원문 링크로 이동하고, GeekNews 요약과 댓글은 별도 경로로 확인한다고 설명합니다.
- [FACT] 사용자 제공 표본의 모든 Atom entry는 GeekNews topic URL을 가리키는 `alternate` link 하나만 제공합니다.
- [FACT] 모든 entry의 `id`는 같은 entry의 GeekNews topic link와 같고, 표본 안에서는 50개 모두 고유합니다.
- [FACT] 표본에는 외부 원문을 직접 가리키는 별도 link relation이 없습니다.
- [FACT] 사용자는 GeekNews에 외부 자료를 바탕으로 등록된 항목과 GeekNews에 직접 작성된 항목이 혼재한다고 확인했습니다.
- [FACT] 사용자는 2026-08-25에 외부 원문 직접 URL을 MVP 결과의 필수 조건으로 보지 않는다고 확인했습니다.
- [INFERENCE] 이 표본 기준으로 RSS만 사용하면 GeekNews 상세 페이지에는 연결할 수 있지만 외부 원문 직접 URL을 일반적으로 제공할 수 없습니다.
- [FACT] MVP 결과 링크로 RSS가 제공한 GeekNews topic link를 사용할 수 있습니다.
- [INFERENCE] 외부 원문 URL이 RSS에 명시적으로 제공되지 않으면 이를 별도로 추출하기 위해 GeekNews 상세 페이지나 외부 페이지를 수집하지 않습니다.
- [UNKNOWN] GeekNews topic URL과 Atom `id`가 항목 수명 동안 안정적인지는 여러 시점의 비교나 공식 계약으로 확인하지 못했습니다.
- [UNKNOWN] 동일 원문이 다른 URL로 다시 등록될 가능성, 추적 parameter와 URL 정규화 필요성을 확인하지 못했습니다.

### Time and Update Behavior

- [FACT] 공식 공지는 새로 등록되는 항목이 피드에 자동 노출되고 시간순으로 제공된다고 설명합니다.
- [FACT] 사용자 제공 표본의 모든 entry가 `published`와 `updated`를 제공하고, 각 entry에서 두 값은 같으며 UTC offset은 `+09:00`입니다.
- [FACT] 표본은 50개 entry를 `published` 최신순으로 제공합니다.
- [UNKNOWN] 제공 시각이 원문 게시 시각, GeekNews 등록 시각 또는 다른 기준 중 무엇을 의미하는지 공식적으로 확인하지 못했습니다.
- [UNKNOWN] feed가 항상 50개를 제공하는지, 과거 노출 범위, 생성 지연과 갱신 주기는 한 표본으로 확인할 수 없습니다.
- [UNKNOWN] 기존 항목의 제목·내용 수정, 삭제 또는 순서 변경이 피드에 어떻게 반영되는지 확인하지 못했습니다.
- [UNKNOWN] `ETag`, `Last-Modified`와 conditional request 지원 여부를 확인하지 못했습니다.

### Use Conditions

- [FACT] GeekNews는 현재 사이트 전역에서 RSS endpoint를 공개적으로 연결하고 구독 기능으로 제공합니다.
- [FACT] 2026-08-16에 최종 수정된 GeekNews [이용약관](https://news.hada.io/terms)은 서비스에 과도한 부하를 주는 자동화 접근, crawling과 script 실행을 금지합니다.
- [FACT] 같은 약관은 운영상 필요에 따라 서비스 일부 또는 전부가 변경되거나 중단될 수 있다고 설명합니다.
- [UNKNOWN] 허용되는 polling 빈도, rate limit, User-Agent 또는 연락처 표기 기준은 공식 문서에서 확인하지 못했습니다.
- [INFERENCE] 공개 feed를 저빈도로 구독하는 것과 금지된 과도한 자동 접근은 구분될 가능성이 높지만, 허용 범위를 문서만으로 확정할 수 없습니다.
- [INFERENCE] 실제 수집 주기는 이용 조건, conditional request 지원과 서비스 부하를 함께 검증한 뒤 Technical Requirements에서 결정해야 합니다.

## Research Conclusions

1. [FACT] 공식 feed URL과 Atom 응답 형식은 확인했습니다.
2. [FACT] feed가 News 전용이 아니라 News, Ask와 Show 전체의 시간순 feed라는 점을 확인했습니다.
3. [FACT] News, Ask와 Show를 모두 데이터 파이프라인의 일반 후보로 처리하며 source type만으로 조기 제외하지 않습니다.
4. [FACT] 사용자 제공 표본의 entry fields는 `title`, GeekNews topic `link`, 동일 값을 갖는 `id`, `updated`, `published`, `author`와 HTML `content`입니다.
5. [FACT] 표본에는 외부 원문 전용 link, `summary`와 entry-level type/category가 없습니다.
6. [FACT] 표본의 모든 `published`와 `updated`는 같고 `+09:00`이며, 50개 entry는 최신순입니다.
7. [INFERENCE] title과 content만으로 48개는 보수적인 2문장 요약이 가능하고 1개는 제한적이며 1개는 불충분합니다.
8. [INFERENCE] 표본 기준 RSS 정보는 MVP 요약 입력으로 대체로 충분하며 현재 근거만으로 GeekNews 상세 페이지 수집을 추가할 필요는 없습니다.
9. [FACT] 과도한 자동 접근 금지 조건은 확인했지만 구체적인 polling 허용 기준은 확인하지 못했습니다.
10. [UNKNOWN] ID의 장기 안정성, 시각의 업무 의미, 고정 항목 수, 과거 노출 범위, HTTP cache와 update behavior는 추가 관찰이나 공식 확인이 필요합니다.
11. [FACT] 외부 원문 직접 URL은 필수가 아니며 MVP 결과에는 RSS가 제공한 GeekNews topic link를 사용할 수 있습니다.
12. [INFERENCE] 현재 근거만으로 `link UNIQUE`, 재수집 중첩 범위, 수집 주기 또는 실제 AI 요약 품질을 설계 결정으로 확정하면 안 됩니다.

## Research / JTBD Exit Criteria

- [FACT] 승인된 문제에서 JTBD와 desired outcomes를 구체화했습니다.
- [FACT] GeekNews 공식 URL, 형식, 콘텐츠 범위, 정렬 특성과 이용 조건을 조사했습니다.
- [FACT] 사용자 제공 XML 표본에서 실제 feed와 entry 구조를 확인했습니다.
- [FACT] 직접 확인한 사실, inference와 추가 시점 관찰이 필요한 unknown을 분리했습니다.
- [FACT] 사용자가 외부 원문 직접 URL은 필수가 아니며 GeekNews topic link를 결과에 사용할 수 있음을 확인했습니다.
- [FACT] 사용자가 News, Ask와 Show를 모두 데이터 파이프라인 후보로 처리하기로 결정했습니다.
- [FACT] RSS 표본 50개 전체의 요약 입력 충분성을 검토하고 결과와 예외를 기록했습니다.
- [FACT] 사용자가 2026-08-25에 refined JTBD와 Research conclusion을 승인했습니다.
- [INFERENCE] HTTP header, ID 안정성과 시간에 따른 update behavior는 Technical Requirements와 Data / Interface Design의 검증 항목이며 Research / JTBD 승인 자체를 차단하지 않습니다.

[FACT] Research / JTBD 단계는 2026-08-25에 사용자 승인으로 완료됐습니다.

[FACT] 이번 승인 동기화 작업에서는 다음 단계인 Solution Discovery를 시작하지 않습니다.
