# Git Workflow Policy History

## Status and Boundary

[FACT] 이 문서는 2026-09-14 필수 Context 축소 작업에서 `AGENTS.md`로부터 이동한 기존 단계별 Git 절차를 보존합니다.

[FACT] 아래 절차는 현재 비활성입니다. 현재 Git 작업 경계는 [AGENTS의 Git Rules](../AGENTS.md#git-rules)를 따르며, 이 역사 문서는 Git 조회·commit·push 또는 단계 전환을 승인하지 않습니다.

## Archived Procedure

[FACT] Git commit은 사용자 승인 후에만 실행합니다.

[FACT] Git push는 사용자 승인 후에만 실행합니다.

[FACT] 파괴적인 Git 명령으로 사용자 변경을 되돌리지 않습니다.

[FACT] Commit 검토 시 변경 범위, 테스트 결과, 문서 동기화와 남은 위험을 먼저 보고합니다.

[FACT] `Development Workflow`의 각 단계가 사용자 승인과 관련 문서 동기화를 거쳐 완료되면, 다음 단계로 넘어가기 전에 Git commit 및 push 안내 절차를 실행합니다.

[FACT] 단계 종료 Git 안내 절차는 다음 순서를 따릅니다.

1. `git status --short --branch`로 변경 파일과 현재 branch를 확인합니다.
2. 단계별 변경 범위, 테스트 결과, 문서 동기화와 남은 위험을 보고합니다.
3. commit 대상과 commit message를 제안합니다.
4. 사용자에게 commit 및 push 실행 여부를 확인합니다.
5. 사용자가 직접 실행하는 경우 정확한 명령을 순서대로 안내하고 결과를 확인합니다.
6. Agent가 실행하는 경우 사용자의 명시적 승인 후 commit하고 push합니다.
7. local branch와 remote branch의 반영 상태를 확인합니다.

[FACT] Commit 및 push가 완료되거나 사용자가 명시적으로 연기하기 전에는 다음 Workflow 단계로 넘어가지 않습니다.

[FACT] 서로 다른 Workflow 단계의 변경사항을 하나의 commit에 함께 포함하지 않습니다.

[FACT] 문서 중심의 Product 및 Design 단계는 승인된 변경을 단계별로 `main`에 commit하고 push합니다.

[FACT] Feature Implementation 이후의 코드 변경은 기능 또는 수정 단위의 작업 branch에서 진행하고 Pull Request를 통해 `main`에 병합합니다.

[FACT] 작업 branch는 대화나 세부 작업마다 만들지 않으며, 독립적으로 검토하거나 되돌릴 필요가 있는 기능 또는 수정 단위로 만듭니다.

[FACT] Force push는 일반적인 단계 종료 절차에서 사용하지 않습니다.
