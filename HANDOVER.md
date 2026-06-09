# 🚀 레벨 테스트 (듀오링고 스타일) 인수인계 및 To-Do List

안녕하세요! 백엔드 개발자님 & 다음 개발 작업을 이어나가실 팀원분들께,
지금까지 구현된 레벨 테스트(Onboarding Level Test) 모듈의 진행 상황과 앞으로 남은 작업(TODO)을 정리해 드립니다.

## 📌 1. 금일(최근) 작업 내역 요약
1. **듀오링고 스타일 프레임워크 구축**
   - 상단 진행률 바(Progress Bar) 및 문항 전환(상태 유지) 로직 완비
2. **4가지 커스텀 문항 UI 인터랙션 완벽 구현**
   - 객관식(MULTIPLE_CHOICE), 매칭형(MATCHING), 순서나열형(REORDER), 그래프 터치(GRAPH_INPUT)
   - 시각화용 피그마 화면에 맞춰 '그래프 터치 + 텍스트 동시 입력' 같은 복합 UI도 컴포넌트 화하여 구현 완료
3. **정답 피드백 풀스크린 뷰 (EC-2036)**
   - 정답/오답 제출 시 하단에서 부드럽게 올라오는 `LevelTestFeedbackScreen` 네비게이션 적용
4. **결과 리포트 화면 (EC-203X)**
   - 점수에 따른 등급 판별 및 커스텀 결과창(`LevelTestResultScreen`) 흐름 연동 완료
5. **목업 데이터(Mock Data) 분리**
   - 시각화 및 시연을 위해 작성한 더미 질문 5개를 `lib/features/level_test/data/level_test_mock_data.dart` 파일로 분리.
   - 백엔드 분들은 이 파일의 JSON 구조를 참고하여 API 명세서를 확정 지으시면 됩니다!

---

## 🛠 2. 백엔드 연동 및 다음 작업 (TODO List)

다음 작업 시 쾌적한 API 연동과 유지보수를 위해 아래의 순서대로 작업을 진행하시길 권장합니다. (브랜치는 목적에 맞게 세분화하여 작업 및 PR을 올려주세요!)

### [TODO 1] UI 코드 리팩토링 (위젯 분리)
> **Branch 제안**: `refactor/level-test-widgets`
- **현상**: 현재 `level_test_screen.dart` 하나에 객관식, 매칭형, 순서나열, 그래프 등 모든 UI 그리기 로직이 포함되어 파일 라인 수가 약 1000줄에 달합니다.
- **작업 내용**: 
  - `_buildMultipleChoice` -> `MultipleChoiceWidget` 클래스로 분리
  - `_buildReorderContent` -> `ReorderWidget` 클래스로 분리
  - `_buildGraphInput` -> `GraphInputWidget` 클래스로 분리
  - `_buildMatchingContent` -> `MatchingWidget` 클래스로 분리
- **효과**: 코드가 훨씬 가벼워지고, 백엔드 개발자가 API 응답 값을 각 위젯에 Prop으로 넘겨주기 훨씬 편해집니다.

### [TODO 2] 커리큘럼 API (스프레드시트) 연동
> **Branch 제안**: `feat/level-test-api-integration`
- **작업 내용**:
  - `level_test_mock_data.dart`에 정의된 5개의 Mock 데이터 배열을 지웁니다.
  - 실제 스프레드시트에 기입된 커리큘럼 데이터를 서버 API(`/api/v1/curriculum/...`)를 통해 불러오는 비동기 통신 코드를 작성합니다.
  - `FutureBuilder` 또는 Provider/Riverpod을 사용해 화면 진입 시 로딩 스피너를 띄우고 데이터 fetch 후 렌더링하도록 묶어줍니다.

### [TODO 3] 정답 제출 및 채점 로직 서버 이관
> **Branch 제안**: `feat/level-test-grading-api`
- **현상**: 현재는 클라이언트(앱) 측에서 정답(`currentQ['answer']`)을 들고 있고 직접 채점하고 있습니다.
- **작업 내용**:
  - 보안 및 데이터 수집을 위해 유저가 고른 답안을 백엔드로 `POST` 요청(제출)합니다.
  - 서버가 응답으로 준 `isCorrect`, `explanation`, `highlightText` 등을 `LevelTestFeedbackScreen`에 넘겨서 렌더링하도록 흐름을 변경합니다.

---

## 💬 3. PM / 디자인 팀 논의 사항 (참고용)
- **그래프 터치 + 텍스트 입력 문항(GRAPH_INPUT)**은 피그마 디자인을 있는 그대로 반영하여 개발해 두었으나, PM님의 답변("완전 목데이터로 생각하고 시각화를 위해 만든 페이지")에 따라 실제 스프레드시트 커리큘럼 내용이 들어오면 해당 UI는 백엔드가 주는 `type`에 따라 동적으로 갈아끼워집니다.
- 시연 시에는 현재 더미 데이터 5개가 모두 활성화되어 있으니 이를 보여주면서 "모든 인터랙션 준비 완료"를 어필하시면 됩니다.

감사합니다. 화이팅! 🚀
