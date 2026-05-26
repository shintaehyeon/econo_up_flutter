// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  static const String baseUrl = 'https://api.econo-up.com/api/v1'; // TODO: 백엔드 개발자와 호스트 주소 맞출 것

  // 1. 인증 및 계정
  static const String socialLogin = '/auth/social/login';
  static const String tokenRefresh = '/auth/token/refresh';
  static const String logout = '/auth/logout';
  static const String withdraw = '/users/me';

  // 2. 온보딩
  static const String onboardingProfile = '/onboarding/profile';
  static const String checkNickname = '/users/nickname-availability';
  static const String onboardingInterests = '/onboarding/interests';
  static const String onboardingGoal = '/onboarding/goal';
  static const String onboardingStudyStyle = '/onboarding/study-style';
  static const String onboardingFailureReason = '/onboarding/failure-reason';
  static const String onboardingStatus = '/onboarding/status';

  // 3. 레벨테스트
  static const String createLevelTest = '/level-tests';
  static String submitLevelTestAnswer(String testId) => '/level-tests/$testId/answers';
  static String completeLevelTest(String testId) => '/level-tests/$testId/complete';
  static const String skipLevelTest = '/level-tests/skip';

  // 4. 홈
  static const String home = '/home';
  static const String updateHomeInterests = '/users/me/home-interests';

  // 5. 커리큘럼
  static const String categories = '/curriculum/categories';
  static String categoryRoadmap(String categoryCode) => '/curriculum/categories/$categoryCode/roadmap';
  static String stageMap(String unitId, String stageId) => '/curriculum/units/$unitId/stages/$stageId/map';

  // 6. 학습 세션
  static String startSession(String sessionId) => '/learning/sessions/$sessionId/attempts';
  static String submitAnswer(String attemptId) => '/learning/attempts/$attemptId/answers';
  static String exitAttempt(String attemptId) => '/learning/attempts/$attemptId/exit';
  static String completeAttempt(String attemptId) => '/learning/attempts/$attemptId/complete';
  static String getAttemptResult(String attemptId) => '/learning/attempts/$attemptId/result';

  // 7. 복습
  static const String todayReviews = '/reviews/today';
  static String submitReviewAnswer(String reviewSetId) => '/reviews/$reviewSetId/answers';
  static String completeReview(String reviewSetId) => '/reviews/$reviewSetId/complete';

  // 8. 진행 및 스트릭
  static const String streakDetail = '/progress/streak';
  static const String learningRecords = '/progress/learning-records';
  static const String capabilityReport = '/progress/report';

  // 9. 시뮬레이션
  static const String simulations = '/simulations';
  static String startSimulation(String simulationId) => '/simulations/$simulationId/attempts';
  static String simulationStep(String attemptId, int stepNo) => '/simulation-attempts/$attemptId/steps/$stepNo';
  static String submitSimulationAnswer(String attemptId, int stepNo) => '/simulation-attempts/$attemptId/steps/$stepNo/answers';
  static String completeSimulation(String attemptId) => '/simulation-attempts/$attemptId/complete';

  // 10. 데일리 커넥트 (뉴스)
  static const String dailyArticles = '/daily-connect/articles';
  static String articleDetail(String articleId) => '/daily-connect/articles/$articleId';
  static String termDetail(String termId) => '/terms/$termId';
  static String toggleBookmark(String articleId) => '/daily-connect/bookmarks/$articleId';
  static const String submitDailyQuiz = '/daily-connect/quizzes/submit';

  // 11. 마이페이지 및 캐릭터
  static const String myProfile = '/users/me/profile';
  static const String myPageSummary = '/my-page/summary';
  static String characterGrowth(String categoryCode) => '/characters/categories/$categoryCode';
  static String equipCharacter(String characterId) => '/characters/$characterId/equip';

  // 12. 재화 및 BM
  static const String wallets = '/wallets';
  static const String shopProducts = '/shop/products';
  static const String verifyReceipt = '/shop/receipt/verify';
  static const String refillHearts = '/shop/hearts/refill';
  static const String purchaseUnlimitedHearts = '/shop/hearts/unlimited';
  static const String purchaseStreakTicket = '/shop/streaks/revive-ticket';
  static const String useStreakTicket = '/shop/streaks/revive';
  static const String shopContentPasses = '/shop/content-passes';
  static const String purchaseContentPass = '/shop/content-passes/purchase';

  // 13. 골든 티켓
  static const String currentGoldenTicket = '/golden-tickets/current';
  static const String startGoldenTicket = '/golden-tickets/activate';

  // 14. 설정
  static const String notificationSettings = '/settings/notifications';
  static const String appInfo = '/app-info';
}
