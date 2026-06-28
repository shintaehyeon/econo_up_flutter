# econo_up_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## 🐛 Trouble Shooting Log

### 1. 레벨 테스트 순서 나열형(REORDER) 뷰 렌더링 시 Null 타입 에러
- **이슈 내용**: `type 'Null' is not a subtype of type 'List<String>' in type cast` 에러와 함께 빨간색 스크린(Red Screen of Death) 발생.
- **원인 파악**: `level_test_screen.dart`의 메인 `build` 함수 내부에서, 새로 추가된 `REORDER` 및 `GRAPH_INPUT` 타입의 화면 분기 처리가 누락되어 있었습니다. 이로 인해 4번째 문제(REORDER)로 넘어갈 때 기본 Fallback으로 `_buildMatchingContent`가 호출되었고, 해당 함수 내에서 `currentQ['draggableItems']`를 `List<String>`으로 강제 캐스팅(as)하려 했으나 해당 값이 존재하지 않아(Null) 에러가 발생했습니다.
- **해결 방법**: 삼항 연산자(Ternary Operator)로 작성되어 있던 `build` 분기문을 `Builder`를 활용한 다중 `if-else`문으로 리팩토링하여, `MULTIPLE_CHOICE`, `MATCHING`, `REORDER`, `GRAPH_INPUT` 4가지 타입이 각각 알맞은 위젯 렌더링 함수를 호출하도록 수정했습니다.

### ⚠️ 개발 원칙 (사전 약속)
- **API 연동 규칙**: 프론트엔드 작업 시, **백엔드 개발자가 전달해 준 API 명세서를 절대적으로 준수**합니다. 임의로 API 요청/응답 형태를 변경하거나 명세와 어긋나는 방향으로 개발을 진행하지 않기로 사전에 약속되었습니다.

---

## 최종 QA 공유 메모

최종 QA 및 앱 심사 전 확인 과정에서 프론트에 남아 있던 테스트/대체 데이터 성격의 코드를 정리했습니다.

정리 이유는 실제 사용자 기준에서는 화면이 백엔드 DB/API 응답 기준으로만 보여야 하며, API 실패나 데이터 누락 상황에서 임의의 mock 데이터가 노출되면 QA와 심사에서 실제 연동 상태를 오해할 수 있기 때문입니다.

### 정리 내용

1. **리그 화면**
   - API 실패 시 임의의 골드 리그/가짜 랭킹 데이터가 보이던 fallback을 제거했습니다.
   - 리그 정보는 백엔드 `/leagues/me`, `/leagues/{leagueId}/ranking` 응답 기준으로만 표시합니다.

2. **관심 분야 설정**
   - 기본 선택값으로 경제/저축이 박혀 있던 부분을 제거했습니다.
   - 홈 API에서 내려오는 실제 사용자 관심 카테고리 기준으로 초기화합니다.

3. **뉴스 이미지**
   - 기사 이미지가 없을 때 특정 임시 이미지가 대신 보이던 fallback을 제거했습니다.
   - 실제 이미지가 없으면 중립 placeholder만 표시합니다.

4. **시뮬레이션 답안**
   - 프론트에 `choiceIds`를 직접 하드코딩해서 제출하던 부분을 제거했습니다.
   - 백엔드 simulation step API에서 내려주는 choice id 기준으로 답안을 구성하도록 수정했습니다.

5. **Admin Test Login**
   - 현재 로컬 QA 편의를 위한 테스트 로그인 진입점입니다.
   - 심사용/출시용 빌드에서는 `ECONOUP_SHOW_DEV_LOGIN=true` 옵션을 넣지 않으면 화면에 노출되지 않습니다.
   - 다만 최종 심사 안정성을 위해 완전 제거 여부는 로그인 최종 구현 담당자와 확인이 필요합니다.

현재 프론트 `main`에는 mock/fallback 성격의 화면 데이터 제거 작업까지 반영되어 있습니다.
