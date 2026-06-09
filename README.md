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
