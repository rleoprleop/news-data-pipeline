# SPK-06A Cost Safety Preflight — Current Gemini Validation Plan

## Status and Boundary

[FACT] **문서 상태: SPK-06A `fail`, Gemini API 후보 `rejected` — 이용 목적 계약 불일치, provider 호출 0회.** 2026-09-14 사용자는 Gemini 무료 API 우선 검증 방향과 아래 SPK-02 제한 transport를 승인했고, 같은 날 Agent가 공식 Gemini API 문서만 조회해 비용·모델·약관 조건을 대조했습니다. 현재 Gemini API 추가 약관은 Google AI Studio와 Gemini API를 professional 또는 business purpose로 model을 구축하는 developer 용도로 한정하고 consumer use가 아니라고 명시합니다. Repository의 확정된 개인 소비자 목적과 직접 충돌하며 사용자는 확인 뒤 개인 소비자 목적 유지를 명시했습니다. Configured-state가 Free Tier여도 이번 SPK-06A는 pass가 될 수 없습니다.

[FACT] 2026-09-11 기록은 [중단된 SPK-06A archive](spk-06a-preflight.md)로 유지합니다. 해당 run은 `stopped/not_run`, provider 호출 0회이며 과거 모델·quota·budget·실행 승인을 이번 검증의 pass evidence 또는 실행 권한으로 재사용하지 않습니다. Archive의 과거 문구가 새 실행 승인을 대신하지 않으며 새 run은 별도 ID·evidence·판정을 가집니다.

[FACT] 이 preflight는 SPK-02의 비용 가능 호출보다 먼저 수행합니다. 현재 판정이 `fail`이므로 검증 코드 작성·복원, API key 접근과 실제 provider 호출을 시작하지 않습니다. 이 fail은 무료 quota·모델 capability 실패가 아니라 이용 목적 계약 불일치이며, 다른 provider·유료 Gemini·로컬 AI로 자동 전환하지 않습니다.

[FACT] 연결 Requirement는 NFR-COST-001, NFR-REL-003, EXT-AI-001~007, VR-009·011입니다. 연결 결정은 AD-04·13·15·16, DDI-02·05·06·09, MIN-03·04·05·06입니다. WBS-02가 독립 spike 판정과 사용자 승인을 취합하며 WBS-06.A·D가 provider/cost와 retry 상세 설계를 이어받습니다.

## Candidate and Current User-Observed State

[FACT] 공식 Models 문서에서 후보의 stable exact model ID는 `gemini-3.5-flash-lite`, input 한도는 1,048,576 token, output 한도는 65,536 token이며 structured output과 thinking을 지원한다고 2026-09-14 확인했습니다. 이는 capability 근거일 뿐 이용 목적 적합성·configured-state·SPK-06A pass 또는 운영 model 채택 근거가 아닙니다.

[FACT] 2026-09-14 사용자가 제공한 project quota 화면 텍스트에는 `Gemini 3.5 Flash Lite`가 현재 사용량/한도 형식으로 보이는 RPM `0 / 15`, TPM `0 / 250K`, RPD `0 / 500`으로 표시됐습니다. 공식 rate-limit 문서는 RPM·input TPM·RPD를 project 단위로 적용하고 RPD를 Pacific time 자정에 reset하며 AI Studio의 active limit가 tier/account 상태에 따라 바뀌고 명시된 수치를 보장하지 않는다고 설명합니다. 사용자 값은 현재 configured-state 후보 evidence이며 Agent가 화면·account·project 연결 또는 분자·분모 의미를 확인한 결과가 아닙니다.

| 확인 대상 | 현재 상태 | SPK-06A에 필요한 evidence | 미확인 시 처리 |
| --- | --- | --- | --- |
| 개인 소비자 이용 조건 | [FACT] 공식 약관과 Repository 목적이 충돌 | 2026-03-23 적용 Gemini API Additional Terms의 Use Restrictions와 2026-09-14 확인 시각 | `fail`, 호출 금지 |
| 무료 데이터 이용 조건 | [FACT] unpaid input/output은 제품 개선에 사용되고 사람 검토 가능 | Additional Terms의 Unpaid Services와 공개 RSS input allowlist 대조 | 목적 fail과 별개로 민감·기밀·개인정보 전송 금지 유지 |
| Exact provider/service/model | [FACT] Gemini API stable `gemini-3.5-flash-lite` | 공식 model·pricing 문서와 2026-09-14 확인 시각 | capability만 확인, 채택 금지 |
| Account/project/billing 경계 | 사용자 configured-state evidence 미제출 | 비밀값·개인 식별자를 제거한 project alias, tier, billing account 연결·paid route 상태와 확인 시각 | 현재 fail을 바꾸지 않으며 호출 금지 |
| Quota·rate limit·reset | [FACT] 적용 차원·project scope·Pacific reset 확인; 실제 수치는 사용자 관찰값 | 공식 rate-limit 문서와 실제 project 화면 대조 | 현재 fail을 바꾸지 않으며 호출 금지 |
| 자동 paid/model/credential routing | [UNKNOWN] | 자동 routing·fallback 부재 또는 차단 근거 | `fail` 또는 `inconclusive`, 호출 금지 |

[FACT] 공식 Free Tier 존재, 결제 수단 미등록, usage 0, 청구 내역 부재 또는 budget alert만으로 실제 project의 과금 불가능 상태를 증명하지 않습니다. Official contract, configured state, sandbox observation과 usage/billing evidence는 서로 대체하지 않습니다.

## Official Contract Review — 2026-09-14

| Official source | 확인 결과 | 적용 판정 |
| --- | --- | --- |
| [Gemini API Additional Terms](https://ai.google.dev/gemini-api/terms) | [FACT] 2026-03-23 적용. API 이용자는 18세 이상이어야 하고, Google AI Studio와 Gemini API는 professional/business purpose로 개발하는 developer 용도이며 consumer use가 아니라고 명시 | Repository의 개인 소비자 목적과 직접 불일치하므로 SPK-06A `fail` |
| [Available regions](https://ai.google.dev/gemini-api/docs/available-regions) | [FACT] South Korea가 사용 가능 지역 목록에 포함 | 지역 gate는 충족 가능하지만 목적 fail을 해소하지 않음 |
| [Gemini 3.5 Flash-Lite model](https://ai.google.dev/gemini-api/docs/models/gemini-3.5-flash-lite) | [FACT] stable ID `gemini-3.5-flash-lite`, text output, structured output 지원, input 1,048,576/output 65,536 token | model identity·capability 확인; 실제 품질·quota·채택은 미검증 |
| [Gemini Developer API pricing](https://ai.google.dev/gemini-api/docs/pricing) | [FACT] `gemini-3.5-flash-lite` Standard의 Free Tier input/output은 free of charge이며 free usage는 제품 개선에 사용됨. Grounding 기능은 현재 입력 경계에서 사용하지 않음 | 무료 가격 근거는 존재하지만 이용 목적 fail과 project configured-state를 대신하지 않음 |
| [Billing](https://ai.google.dev/gemini-api/docs/billing) | [FACT] Free에서 Paid로 가려면 billing account 연결과 billing setup이 필요하며 Projects 화면의 `Set up billing`은 project에 billing account가 연결되지 않았음을 의미 | 사용자가 직접 확인할 configured-state 기준; 현재 fail을 pass로 바꾸지 않음 |
| [Rate limits](https://ai.google.dev/gemini-api/docs/rate-limits) | [FACT] RPM·input TPM·RPD를 각각 대조하고 project 단위로 적용하며 RPD는 Pacific time 자정에 reset. 실제 active limit는 AI Studio에서 확인하고 지정 수치는 보장되지 않음 | 사용자 관찰 15 RPM·250K TPM·500 RPD의 project 연결·시각 evidence 필요; 현재 호출 금지 |

[FACT] 이번 검증의 5개 묶음은 한 번의 Standard interactive request payload 안에 최대 5개 RSS item을 넣는 application-level grouping입니다. Gemini Batch API로 전환하는 결정이 아니며 Batch·Flex·Priority·grounding·context caching을 사용하지 않습니다.

[INFERENCE] 사용자가 실제 사용 목적을 professional/business development로 바꾸었다고 단순 표기해 약관 불일치를 우회해서는 안 됩니다. 실제 목적 변경이 사실이라면 Product Guardrail·Requirement·Architecture 영향과 법적 적합성에 대한 별도 사용자 확인·change control·재검증이 필요합니다.

## Approved SPK-02 Validation Transport

[FACT] 다음 transport 결정은 2026-09-14 사용자가 승인한 **SPK-02 제한 검증 방식**입니다. Production Data/Interface 채택은 SPK-02 결과 뒤 별도 review와 사용자 승인을 받아야 하며, 현재 `ai_analysis_attempt`의 article·observation·candidate 단일 lineage나 logical work type을 변경하지 않습니다.

| 항목 | 승인된 제한 검증 규칙 |
| --- | --- |
| 묶음 크기 | 요청당 최대 5개 candidate |
| 묶음 구성 | 고정된 candidate 순서로 5개씩 구성 |
| 마지막 묶음 | 전체 candidate 수를 5로 나눈 나머지가 0이면 마지막 묶음도 5개이며, 나머지가 1~4일 때만 마지막 묶음은 해당 나머지 수로 구성 |
| 금지 구성 | 5개를 채우기 위한 기사 복제·과거 기사 재편입·다른 묶음과의 재조합 금지 |
| 결과 판정 | 한 항목이라도 validation 실패면 해당 provider response의 묶음 전체 실패; 부분 성공 수용 금지 |
| Retry | 명시적으로 retry 가능한 validation 실패에만 동일 묶음 전체를 최대 1회 새 request로 재요청 |
| Retry 불변성 | candidate 구성·순서·item reference·RSS observation·model·prompt·output contract·configuration과 입력 payload를 유지 |
| Retry 종료 | 두 번째 validation 실패면 묶음 전체를 명시적 미처리로 판정하고 추가 호출 금지 |
| 자동 전환 | 다른 provider·account·project·credential·model·유료 plan/API·로컬 AI 전환 금지 |

[FACT] 묶음 요청은 비민감 request-local `item_ref`로 입력과 출력을 대응시킵니다. RSS link·article ID·batch ID 등 외부 전송 금지 식별자를 item reference로 사용하지 않습니다.

[INFERENCE] 묶음 전체 성공에는 요청한 모든 item reference가 정확히 한 번씩 존재하고 예상 밖·누락·중복 item이 없으며, 각 item이 독립적으로 정상 또는 저정보 schema·RSS 근거 검증을 통과해야 합니다. 출력 순서만으로 입력을 대응시키지 않습니다. 정상적인 `low_information`은 validation 실패가 아닙니다.

[FACT] 첫 attempt와 response·usage·limit evidence는 retry 뒤에도 수정하거나 덮어쓰지 않습니다. Retry는 새 attempt로 기록하고 source group·이전 attempt·retry 사유를 연결합니다. 이 experiment evidence 구조를 production canonical data model로 자동 채택하지 않습니다.

## Retry Eligibility and Stop Rules

| 관찰 결과 | 자동 retry | 처리 |
| --- | --- | --- |
| 완전한 response의 JSON/schema 오류, item 누락·중복·예상 밖 item, item 간 내용 혼합, 필수 결과 또는 RSS 근거 validation 실패 | 동일 묶음 최대 1회 | 첫 attempt/evidence 보존 후 동일 입력으로 새 attempt |
| 정상 또는 유효한 저정보 결과 5개/잔여 item 전부 통과 | 없음 | 묶음 성공 evidence |
| 두 번째 validation 실패 | 금지 | 묶음 전체 미처리, 원인·영향 candidate 수 기록 |
| Timeout·응답 미수신·호출 시작 또는 외부 효과 불명확 | 금지 | `external_effect_uncertain`, 자동 재호출 금지 |
| Quota 소진 | 금지 | 공식 근거와 영향 수량 기록, reset/reopen 확인 전 중단 |
| Rate limit | 현재 금지 | 공식 retry 지시·적용 범위가 확인되지 않으면 중단 |
| 인증·권한·project/model 설정·provider 정책/안전 거부 | 금지 | 원인별 실패, 다른 경로 우회 금지 |
| 비용·billing·plan·paid route 상태 불명 또는 불일치 | 금지 | 비용 gate 차단 |
| 요청·token·시간·속도 budget 도달 또는 초과 가능 | 금지 | 신규 호출 중단 |
| Secret·금지 metadata·개인정보 노출 또는 payload 포함 | 금지 | 즉시 중단, 노출 범위 보존·확대 금지 |

[FACT] Process 종료만으로 invocation이 없었다고 추정하지 않습니다. 중단 전에 시작된 요청의 response·usage 불명확성을 보존하고 다른 credential·project·provider·model·유료 경로로 우회하지 않습니다.

## Input Boundary

[FACT] 각 item의 provider 입력은 저장된 해당 article의 공개 RSS `title`과 `content` 또는 `description`, 비밀정보 없는 최소 지시와 승인된 output contract로 제한합니다.

[FACT] RSS `link`·Atom `id`·author·시각과 기타 운영 metadata, 외부 원문·GeekNews 상세 페이지·댓글·검색 결과, Discord·사용자·message·batch 식별자, 다른 저장 데이터, credential·Secret·개인정보는 전송하지 않습니다.

[INFERENCE] 실제 호출 도구는 직렬화된 payload의 item 수·허용 field·item reference uniqueness·금지 field 부재를 외부 호출 전에 fail-closed로 검사해야 합니다. 이 검사는 아직 구현·복원·실행하지 않습니다.

## Bounded Workload for Later Approval

[FACT] 다음 숫자는 사용자가 승인한 SPK-02 제한 검증 계획이며 SPK-06A pass와 별도 실제 실행 승인이 있기 전에는 호출하지 않습니다.

| Budget | 승인 값 |
| --- | ---: |
| 공개 RSS article | 최대 10개 |
| 최초 request group | 최대 2개, 각 최대 5 article |
| group별 retry | validation 실패에 한해 최대 1회 |
| generation request | 최초 2회 + retry 최대 2회 = 최대 4회 |
| 선택적 `countTokens` request | 최초 group별 최대 1회 = 최대 2회; retry 때 같은 payload를 다시 계산하지 않음 |
| 전체 provider request | 최대 6회 |
| 요청 속도 | 분당 최대 5회, 동시 요청 없음 |
| 전체 실행 시간 | 최대 10분 |
| article별 RSS 입력 | 최대 2,000 token |
| group별 RSS 입력 subtotal | 최대 10,000 token |
| group별 출력 상한 후보 | 최대 10,240 token |
| generation 전체 RSS 입력 subtotal | retry 포함 최대 40,000 token |
| generation 전체 출력 상한 후보 | retry 포함 최대 40,960 token |

[UNKNOWN] 공통 instruction·output schema를 포함한 실제 serialized input token, thinking/output token 계산, `countTokens`의 request quota 포함 방식과 SDK의 `max_output_tokens` 적용 방식은 공식 계약과 offline payload 준비 뒤 확정해야 합니다. 이 값이 확정되지 않으면 SPK-06A는 pass가 아니며 실제 호출하지 않습니다.

[INFERENCE] 사용자 관찰 TPM 250K가 exact project/model에 적용된다는 공식·configured evidence가 확인되더라도 자체 pace는 분당 최대 5회로 유지합니다. Quota가 낮아지면 실행 중 group size나 pace를 자동 변경하지 않고 해당 run을 중단해 새 contract/configuration과 사용자 승인을 받습니다.

## User VS Code Procedure Boundary

1. [FACT] 공식 계약 대조에서 개인 소비자 목적 불일치가 확인돼 SPK-06A를 `fail`로 판정했습니다.
2. [FACT] 현재 run에서는 검증 코드 작성·복원, VS Code command 준비, API key 접근과 provider 호출로 진행하지 않습니다.
3. [FACT] 사용자가 아래 비민감 configured-state checklist를 확인할 수는 있지만 결과는 비용·quota 참고 evidence이며 현재 목적 계약 fail을 pass로 바꾸지 않습니다.
4. [FACT] 목적 변경 또는 다른 무료 provider 검토는 별도 change control과 사용자 승인 없이는 시작하지 않습니다.

[UNKNOWN] 정확한 SDK/version, command, key 주입 interface, offline validator와 redacted artifact 형식은 검증 코드 준비 승인 전 확정하지 않습니다.

## User Configured-State Checklist

[FACT] 다음 확인은 사용자가 Google AI Studio에서 직접 수행합니다. API key 값·일부 값, project ID, billing account ID, 이메일과 결제정보는 대화나 Repository에 제출하지 않습니다. `Set up billing`, `Upgrade`, `Prepay`, 결제 계정 연결 버튼은 누르지 않습니다.

1. [INFERENCE] AI Studio의 Projects 화면에서 대상 project 행을 찾고 비민감 별칭을 사용자 로컬 기록에 적습니다.
2. [INFERENCE] `Billing Tier` 또는 `Status`가 `Set up billing`인지 확인합니다. 공식 Billing 문서상 이 표시는 project에 billing account가 연결되지 않았음을 뜻합니다. `Set up Prepay`, `No credits`, Tier 1 이상 또는 paid 표시는 Free-only configured-state 근거로 사용하지 않습니다.
3. [INFERENCE] 같은 대상 project의 API Keys 화면에서 사용할 key가 그 project에 연결되는지만 확인합니다. Key 문자열·앞뒤 일부·fingerprint를 복사하거나 캡처하지 않습니다.
4. [INFERENCE] Rate Limits 화면에서 동일 project와 `Gemini 3.5 Flash Lite`를 선택하고 RPM·TPM·RPD의 현재 사용량/한도와 화면 확인 시각을 기록합니다. 2026-09-14 사용자 관찰값은 RPM 15, TPM 250K, RPD 500이지만 새 화면과 다르면 새 값을 우선하고 불일치로 기록합니다.
5. [INFERENCE] Dashboard > Usage에서 대상 project의 현재 Gemini API usage를 확인합니다. Usage 0은 보조 근거일 뿐 billing 미연결을 대신하지 않습니다.
6. [INFERENCE] 비민감 evidence가 필요하면 project/key/account 식별자와 개인정보를 제거한 뒤 `Free Tier` 또는 `Set up billing`, model 표시, quota 숫자, 확인 시각만 보존합니다.
7. [FACT] 확인 중 billing setup이 시작됐거나 paid project/key가 연결된 사실을 발견하면 설정을 추가 변경하지 말고 현재 상태와 영향만 보고합니다.

[FACT] 사용자가 추가로 사실 확인해야 할 비계정 항목은 만 18세 이상 여부, 실제 접속·운영 지역이 South Korea인지, 이 제품의 실제 목적이 Repository에 기록된 개인 소비자 목적과 같은지입니다. 이 중 실제 목적을 다르게 답하려면 사실에 근거한 scope 변경 검토가 먼저 필요합니다.

## Required Evidence

| Evidence class | 제출 항목 |
| --- | --- |
| Official contract | URL, 확인 시각, 적용 서비스·tier·model, 개인 이용·data-use·pricing·quota·reset·오류/retry·자동 routing 조건의 제한 요약 또는 fingerprint |
| Configured state | 비밀값 없는 project alias, Free Tier·billing/paid route·model quota 화면 reference와 확인 시각·확인자 |
| Approval | exact provider/service/model/project alias, 입력 범위, budget, retry/stop/no-fallback와 실행 단계별 사용자 승인 reference |
| Request plan | group membership 규칙, request-local item reference, allowlist, model/prompt/output contract version, expected schema |
| Preflight result | 실제 API 호출 0회, 확인·미확인·불일치, 판정·blocker·영향 WBS·재검증 trigger·검토자 |
| Later SPK-02 observation | 별도 승인 run의 redacted request/response validation, request/token/latency/error/retry/stop evidence; SPK-06A pass와 분리 |

[FACT] API key·일부 key 값·credential fingerprint·실제 account/project/billing 식별자·invoice 원문을 Repository, 일반 log, metric, trace, AI input 또는 대화 evidence에 포함하지 않습니다.

## Decision Criteria

| 판정 | 기준 | 후속 처리 |
| --- | --- | --- |
| `pass` | 현재 공식 계약, 개인 소비자·data-use 적합성, exact configured project/model의 무료·과금 불가 상태, quota, 자동 paid/model/credential routing 부재, input·budget·retry·stop·evidence와 사용자 승인이 모두 연결되고 SPK-06A API 호출이 0회 | 별도 사용자 승인 범위에서 검증 코드 준비와 SPK-02 실행 검토 가능 |
| `fail` | 공식 계약 또는 실제 설정이 0원·입력·단일 provider/model·no-paid-fallback 요구와 명백히 충돌 | 의존 WBS 차단; 다른 provider/model/유료/로컬 경로 자동 대체 금지 |
| `blocked` | account·권한·공식 자료·필수 설정 evidence 또는 승인 부재로 확인을 수행하지 못함 | 성공 추정 금지, blocker·owner 지정 |
| `inconclusive` | 확인은 수행했지만 과금 불가능성·적용 범위·model/quota/routing·data-use를 결론 낼 evidence가 부족하거나 상충 | 의존 WBS 차단, 보완 evidence 또는 별도 승인된 change control만 허용 |

[FACT] 공식 또는 configured evidence의 필수 확인이 하나라도 부족하면 `pass`로 판정하지 않습니다. SPK-06A 결과는 archive의 상태를 수정하지 않고 새 run evidence로만 기록합니다.

[FACT] **현재 실제 판정은 `fail`, Gemini API 후보 disposition은 `rejected`입니다.** 공식 약관의 consumer-use 제외와 Repository의 개인 소비자 목적이 충돌하고, 사용자는 2026-09-14 개인 소비자 목적 유지를 확인했습니다. 비용·model·지역 조건의 일부는 충족 가능하지만 이 필수 계약 불일치를 보완하지 못합니다. SPK-02, WBS-06 Gemini provider selection과 AI 의존 구현은 차단합니다.

## Record Separation and Handoff

[INFERENCE] 새 실행 evidence는 실제 확인 때 repository-relative `evidence/WBS-02/SPK-06A/<UTC-run-id>/manifest.json` 경로를 사용합니다. 현재 빈 directory나 가짜 manifest를 만들지 않습니다. 각 rerun은 새 run ID를 사용하고 이전 plan·evidence·판정을 덮어쓰지 않습니다.

[INFERENCE] Manifest는 plan reference, predecessor archive, baseline fingerprint, 확인 시각·환경, official/configured evidence reference, expected/actual, 실제 API call count, 판정·한계·blocker·reviewer와 영향 WBS를 포함합니다. 실제 물리 저장·redaction schema는 WBS-03/08 closure 전 확정하지 않습니다.

[FACT] 5개 묶음 production 채택은 SPK-02에서 구조 안정성·항목 누락/혼합·token/latency·retry 결과를 확인한 뒤 별도 사용자 승인을 받습니다. 채택 시 request-level invocation과 candidate-level item lineage, usage/evidence, group retry와 logical work를 DDI-02·05·09 및 WBS-04~06에서 다시 설계합니다. 이 preflight 승인은 해당 production Data/Interface 변경이 아닙니다.
