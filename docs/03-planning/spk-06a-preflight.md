# SPK-06A Cost Safety Preflight — Archived Gemini Experiment

## Status and Boundary

[FACT] **현재 상태: `stopped/not_run` — Gemini 실험 중단·보관 기록.** 2026-09-11 사용자가 개인 소비자 용도를 확인하고 테스트 중단·실험 코드 삭제를 지시했습니다. 기존 실행 승인은 더 이상 사용하지 않으며 API 호출은 총 0회입니다. 실험용 Python 도구·테스트·사용 안내 3개를 삭제했습니다. 프로젝트 밖 키 파일·계정·프로젝트는 변경하지 않았습니다.

[FACT] 이 문서의 아래 준비 내용·승인 한도·미확인 항목은 중단 전 기록으로 보존하며 현재 실행 계획이나 재승인 요청이 아닙니다. SPK-06A pass·SPK-02 품질 검증·운영 채택은 없었습니다. 로컬 AI 또는 다른 제공자 검토·도입은 승인되지 않았습니다.

[FACT] 2026-09-14 사용자는 Gemini 무료 API의 우선 검증·사용 방향을 유지한다고 확인했습니다. 이 결정은 중단된 이 run을 재개·pass 처리하거나 기존 실행 승인을 되살리지 않으며, 새 실제 검증에는 갱신된 비용·계약 확인과 별도 사용자 승인이 필요합니다.

[FACT] WBS-01 승인과 현재 PC 개발 방침을 유지합니다. 사용자가 Gemini 프로젝트 생성·Free Tier·결제 수단 미등록을 확인했고 `gemini-3.5-flash-lite` 검증을 선택했습니다. 실제 계정 설정을 직접 조회하거나 API를 호출하지 않았으며 SPK-06A pass가 아닙니다.

[FACT] 기준은 [외부 검증 순서](validation-traceability-plan.md#external-validation--spike-plan), [WBS-06.A](design-readiness-plan.md#wbs-06-internal-review-checkpoints), [WBS-08 비용 계약](design-readiness-plan.md#wbs-08-detailed-review-checkpoints), [비용·보안 interface](../02-technical/interface-spec.md#security-cost-and-operational-gate-contract)입니다. 이 문서는 기존 계약을 바꾸지 않는 실행 준비표입니다.

[FACT] 사용자는 공개 RSS 로컬 개발 검증의 최대 10기사·생성 10회·필요 시 token 계산 10회·총 10분·자동 retry 없음의 실행 범위를 승인했습니다. 아래 미승인 표시는 이 기록으로 대체합니다.

[FACT] 2026-09-11 사용자가 `C:\secret\gemini.txt`의 키를 앞서 Free Tier로 확인한 프로젝트에서 발급했다고 확인했습니다. 이는 사용자 제공 configured-state 근거이며 Agent의 계정 조회·인증 성공 evidence가 아닙니다.

[FACT] 실제 SPK-06A는 실행하지 않고 `stopped/not_run`으로 종료했습니다. 아래 미확인 조건은 중단 전 선행 조건의 역사 기록이며, 새 Gemini 검증·다른 제공자·새 검증 범위에 자동 적용하거나 기존 프로젝트·등급·한도·키 연결·실험 승인을 다시 요구하지 않습니다.

## Required Inputs

### Selected Validation Candidate

[FACT] 사용자의 `3.5 라이트로 진행해보자` 지시에 따라 검증 대상은 `gemini-3.5-flash-lite` 하나로 정했습니다. 3.6/3.7 후보 검토를 대체하며 운영 모델 최종 채택·동시 다중 모델·자동 fallback 승인은 아닙니다.

[FACT] 사용자 보고: 테스트 프로젝트 생성 완료, Free Tier 확인, 결제 수단 미등록, 해당 프로젝트에서 지정 파일의 키 발급. 사용자가 붙여 넣은 모델별 한도는 RPM 15·TPM 250,000·RPD 500이며 표 제목상 앞의 0은 지난 90일 최대 사용량 표시입니다. 현재 잔여량을 실시간 조회한 결과로 보지 않습니다.

[FACT] [모델 문서](https://ai.google.dev/gemini-api/docs/models/gemini-3.5-flash-lite)는 정확한 model ID·텍스트/구조화 출력 지원을 명시합니다. [가격표](https://ai.google.dev/gemini-api/docs/pricing)의 Standard 입력·출력 무료 구간을 검토 근거로 사용하며, 이번 후보는 Standard만 검증합니다. 이전 3.6/3.7의 Batch/Flex 조건을 다른 모델에 일반화하지 않습니다.

[FACT] 2026-09-11 [Gemini 추가 약관](https://ai.google.dev/gemini-api/terms)의 무료 서비스 조건은 입력·출력의 제품 개선 사용과 사람 검토 가능성을 명시합니다. 민감·비밀·개인정보는 보내지 않습니다. 약관은 개발자의 professional/business 목적과 연령·지역 조건도 두므로 개발 검증 및 최종 개인 큐레이션 용도의 적합성은 별도로 확인하며 이 문서에서 법적 적합 판정을 내리지 않습니다.

[FACT] 승인된 최초 실험 범위는 기사별 1회 생성, 최대 10기사·생성 요청 10회·전체 10분입니다. 입력은 최소 지시와 검토된 공개 RSS title/content 또는 description만 포함합니다. 요청당 입력 상한 2,000 token·출력 상한 2,048 token을 검증하고, 필요 시 countTokens 요청도 최대 10회로 제한합니다. 전체 provider 요청 최대 20회이며 추가 retry는 하지 않습니다. [INFERENCE] countTokens를 포함한 전체 요청을 분당 최대 5회로 보수적으로 제한합니다. Token 계산·thinking/output cap 적용 방식과 실제 시간 제한은 live transport 준비 시 공식 계약과 대조하고 검증합니다.

[INFERENCE] 정상·저정보·홍보성 경계·중요하지만 관심 주제 밖인 기사 표본에서 JSON 유효성·RSS 근거·중요 기사 누락·처리 시간·usage를 대조합니다. 10기사 결과로 100기사/일 처리나 운영 품질 pass를 선언하지 않습니다. 적합한 저장 RSS fixture·키 주입·로컬 추가 비용 범위·약관 적합성·호출 한도 승인이 준비되기 전 실제 호출하지 않습니다.

[FACT] 현재 provider 호출 0회이며 SPK-06A는 아직 pass가 아닙니다. 사용자가 환경변수 대신 프로젝트 밖 `C:\secret\gemini.txt`를 직접 지정했습니다. 파일 형식은 `GEMINI_API_KEY=...` 한 줄이며 2026-09-11 로컬 읽기·형식 검사는 통과했습니다. 값·부분 값·fingerprint는 출력·복제하지 않았고 인증 유효성·프로젝트 연결·ACL 적합성은 이 검사로 검증하지 않았습니다.

[FACT] 실행 도구는 명시적 절대 경로에서 필요한 때만 키를 읽고 환경변수·다른 파일·다른 account로 자동 대체하지 않습니다. 파일 없음·읽기 실패·빈 값·중복 assignment·예상 밖 형식이면 외부 호출 전에 차단합니다. 다른 PC에는 별도 키 파일과 경로를 준비하며 동일 프로젝트이면 한도를 공유합니다. 이 경로 확정은 로컬 검증 도구의 입력 선택이지 production Secret 설계 변경이 아닙니다.

[FACT] 2026-09-11 [공식 API key 안내](https://ai.google.dev/gemini-api/docs/api-key)는 신규 사용자의 약관 동의 뒤 기본 project/key 생성과 Dashboard Projects/API Keys 관리를 설명합니다. [Billing 안내](https://ai.google.dev/gemini-api/docs/billing)는 Free Tier와 청구 연결을 구분하며 `Set up billing`은 청구 계정 미연결 표시로 설명합니다. 실제 사용자 화면은 아직 보지 않았습니다.

[FACT] 같은 날 [가격표](https://ai.google.dev/gemini-api/docs/pricing)의 `gemini-3.6-flash`·`gemini-3.7-flash` Standard 입력·출력에 무료 구간을 확인했습니다. 무료 구간은 제품 개선에 데이터 사용 가능으로 표시되며 실제 quota·project 적용·data-use 적합성은 별도 확인합니다. Batch/Flex는 무료 API 경로로 취급하지 않습니다. 프로젝트의 예정 batch 실행과 제공자의 Batch API는 별개입니다.

[INFERENCE] 프로젝트 생성 안내는 완료됐습니다. 다음은 선택한 무료 프로젝트 키의 로컬 주입과 제한 실험 준비이며 billing 연결·upgrade·credit 구매는 하지 않습니다.

| 입력 | 현재 확인 상태 | 필요한 비민감 정보 | 담당 |
| --- | --- | --- | --- |
| WBS-01 기준선 | 사용자 승인 완료 | `1. 승인` 답변 | 사용자 |
| 검증 AI 후보 | `gemini-3.5-flash-lite` 검증 선택, 프로젝트 생성 사용자 확인 | 실험 결과 전 운영 채택 미확정 | 사용자 선택 후 Agent 검증 준비 |
| Billing / paid route | 사용자 확인: Free Tier·결제 수단 미등록·키의 해당 프로젝트 소속 | 사용자 설정 근거와 공식 Billing 조건 대조; 계정 직접 조회·결제 설정 변경 없음 | 사용자 확인 완료, Agent 계약 대조 |
| 실행 환경 | 현재 PC 개발, 다른 PC 개발 재개 필요 | 로컬 실험 추가 비용·한도 확인; 지금 클라우드 가입 불필요 | 사용자 |
| 실험 한도 | 사용자 승인 완료, 비용 gate 충족 전 호출 보류 | 최대 생성 10회·token 계산 10회·10분·자동 retry 없음; 중단은 Agent 또는 사용자 요청/Ctrl+C | Agent 실행 제어 |
| Discord / storage / registry 등 | 미확정 | 아래 비용 범위별 사용 예정 대상 또는 이번 run 미사용 사유 | 사용자 범위 확인 → Agent 대조 |

[FACT] Project는 비민감 별칭으로 설명하고 실제 대상과의 대응은 사용자가 보관합니다. API key·token·webhook URL·billing account 식별자·청구서 원문을 이 문서나 대화에 제공할 필요가 없습니다. 설정 화면 근거가 필요하면 비밀값과 개인 식별자를 제거한 범위만 사용합니다.

## Seven-Scope Coverage

[INFERENCE] 각 scope를 이번 제한 실험에 사용/미사용으로 먼저 분류합니다. 미사용에는 호출·생성·저장·전송이 없다는 범위 근거가 필요하며 무료 판정이나 이후 운영 승인으로 재사용하지 않습니다. 현재는 실험 범위 자체가 미확정이므로 모든 scope를 미확인으로 유지합니다.

| Scope | 사전에 필요한 근거 | 현재 상태 | 미확인 시 금지 범위 |
| --- | --- | --- | --- |
| AI provider | 공식 무료 조건·data-use·quota와 실제 project/model의 과금 불가 설정, 자동 paid routing/fallback 부재 | 미확인 | AI invocation |
| Discord | 승인 sandbox·Application/연동 범위의 추가 비용 경로와 실행 host 비용 | 미확인 | 영향 Discord operation |
| K3s runtime/host | 기존 host 사용의 추가 월 비용, 신규 자원·네트워크 범위 | 미확인 | 해당 workload 실행·자원 생성 |
| PostgreSQL/PV | DB·volume 제공 방식, 용량·I/O·추가 비용 여부 | 미확인 | 해당 DB·volume 생성 및 활성화 |
| Backup storage/transfer | 저장·보관·전송·restore 실험 비용, 기존 저장소 범위 | 미확인 | backup/restore 실험 |
| Image registry | 저장·pull·traffic의 공식 조건과 실제 대상 설정 | 미확인 | registry 게시·전송 |
| Scheduler/monitoring | Cron·listener·log/metric/alert의 실행·저장 비용 | 미확인 | 해당 서비스 활성화 |

## Evidence and Decision Procedure

1. [INFERENCE] 사용자에게서 WBS-01 검토 승인과 비민감 대상·실험 범위를 확인합니다. 현재 선택되지 않은 제공자·host·model을 임의로 확정하지 않습니다.
2. [INFERENCE] 선택 대상의 공식 조건을 실행 직전에 확인해 URL·확인 시각·관련 조건·적용 범위를 기록합니다. 현재 문서는 가격·무료 tier·quota를 최신 사실로 주장하지 않습니다.
3. [FACT] 실제 설정 근거와 공식 조건을 따로 대조합니다. 공식 free tier 존재, usage 0, 청구 내역 부재 또는 예산 알림만으로 과금 불가를 증명하지 않습니다. 제공자/project의 강제 차단 또는 동등한 비과금 근거가 필요합니다.
4. [INFERENCE] 모든 적용 비용 scope의 누락을 확인한 뒤 call·token·시간 한도, 중단 책임·방법, 재시도·fallback 금지와 사용할 공개 RSS 입력 범위를 사용자 승인 항목으로 묶습니다. 아직 실제 숫자나 K3s 중지 명령을 정하지 않습니다.
5. [FACT] Evidence 부족은 blocked/inconclusive, 승인 요구와의 실제 불일치는 fail로 구분합니다. 필수 근거와 사용자 승인 범위가 충족됐을 때에만 해당 범위의 SPK-06A pass를 기록할 수 있습니다. 자동 호출을 시작하지 않습니다.
6. [FACT] 이후 승인된 SPK 실험과 SPK-06B의 실제 사용량·전체 비용 대조를 분리합니다. SPK-06A/B는 실제 운영월 WBS-30 비용 Hard Gate pass 또는 provider 최종 선택·배포·activation 승인을 대체하지 않습니다.

[INFERENCE] 실제 record에는 SPK ID·확인 시각·검토자·비민감 대상/configuration fingerprint·적용 scope·공식 조건 reference·설정 확인 reference·승인 한도·판정·blocker·영향 WBS·재검증 trigger가 필요합니다. 현재는 실행 evidence나 빈 manifest를 생성하지 않습니다.

## Stop and Revalidation Rules

- [FACT] 비용 가능성·설정 불일치·공식 quota 상태가 불명확하면 영향 신규 호출을 중단합니다. 다른 account/credential/provider/model·유료 경로로 우회하지 않습니다.
- [FACT] Quota 소진·rate limit은 실제 청구 위반과 분리합니다. 실제 비용 위반은 별도 보존하며 이후 정상화로 과거 실패를 지우지 않습니다.
- [FACT] 중지 전에 시작된 호출의 응답·usage 불명확성을 보존합니다. 프로세스 종료만으로 호출 미발생을 추정하지 않습니다. DB/PVC/backup을 삭제하지 않습니다.
- [FACT] 대상·설정·billing·model·공식 조건·runtime 변경 또는 관찰 불일치에는 VR-011 재검증과 필요한 사용자 승인을 적용합니다. 자동 재개하지 않습니다.

## Handoff

[FACT] 연결 Requirement: NFR-COST-001, EXT-AI-004, VR-009, VR-011. 연결 결정: AD-04·13·15·16, DDI-06, MIN-03. Evidence 연결 시작점은 [WBS-01 기준선](traceability-baseline.md#hard-gate-evidence-map)입니다.

[FACT] 중단 전 오프라인 준비 도구에서 합성 fixture 테스트 13개와 실제 키 파일 형식 검사를 통과했습니다. 사용자 중단 지시 후 도구·테스트·사용 안내를 삭제했으므로 이는 과거 실행 기록입니다. provider 호출 0회·실제 RSS 표본 0개이며 live 제한 구현·검증 evidence는 없습니다.

[FACT] 2026-09-11 공식 모델·가격·Billing·약관을 재확인했습니다. 선택 모델 Standard 입력·출력 무료 조건과 유료 전환 시 Billing 연결 조건은 위 사용자 확인과 일치합니다. 인증·실제 사용량·청구 결과까지 확인한 것은 아닙니다.

[FACT] 사용자는 개인 소비자 용도를 확인했고 Gemini 테스트를 중단했습니다. 사용 목적·키 연결·실험 승인을 다시 요구하지 않습니다. AI 의존 작업은 미검증 상태로 남깁니다.

[INFERENCE] 다음 독립 작업 후보는 SPK-01 GeekNews RSS 검증 준비입니다. RSS 전용 실행 범위·비용·허용 접근 조건을 먼저 확인한 뒤 제한 수집으로 입력 필드·갱신·실패 구분을 검증합니다. Gemini 중단을 전체 외부 검증 통과나 RSS 호출 승인으로 해석하지 않습니다.
