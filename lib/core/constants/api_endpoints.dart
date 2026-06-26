// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  static const String defaultLocalBaseUrl = 'http://localhost:8080/api/v1';
  static const String baseUrl = String.fromEnvironment(
    'ECONOUP_API_BASE_URL',
    defaultValue: defaultLocalBaseUrl,
  );

  // Auth
  static const String devLogin = '/dev/auth/login';
  static const String googleLogin = '/auth/google/login';
  static const String socialLogin = '/auth/social/login';
  static const String tokenRefresh = '/auth/token/refresh';
  static const String logout = '/auth/logout';
  static const String withdraw = '/users/me';
  static const String me = '/users/me';

  // Onboarding
  static const String onboardingProfile = '/onboarding/profile';
  static const String checkNickname = '/users/nickname-availability';
  static const String onboardingInterests = '/onboarding/interests';
  static const String onboardingGoal = '/onboarding/goal';
  static const String onboardingStudyStyle = '/onboarding/study-style';
  static const String onboardingFailureReason = '/onboarding/failure-reason';
  static const String onboardingStatus = '/onboarding/status';

  // Level test
  static const String createLevelTest = '/level-tests';
  static String submitLevelTestAnswer(Object testId) => '/level-tests/$testId/answers';
  static String completeLevelTest(Object testId) => '/level-tests/$testId/complete';
  static const String skipLevelTest = '/level-tests/skip';

  // Home
  static const String home = '/home';
  static const String updateHomeInterests = '/users/me/home-interests';

  // Curriculum
  static const String categories = '/curriculum/categories';
  static String categoryRoadmap(String categoryCode) => '/curriculum/categories/$categoryCode/roadmap';
  static String stageMap(Object unitId, Object stageId) => '/curriculum/units/$unitId/stages/$stageId/map';

  // Learning
  static String startSession(Object sessionId) => '/learning/sessions/$sessionId/attempts';
  static String submitAnswer(Object attemptId) => '/learning/attempts/$attemptId/answers';
  static String exitAttempt(Object attemptId) => '/learning/attempts/$attemptId/exit';
  static String completeAttempt(Object attemptId) => '/learning/attempts/$attemptId/complete';
  static String stageCompletionSummary(Object stageId) => '/learning/stages/$stageId/completion-summary';

  // Review
  static const String todayReviews = '/reviews/today';
  static String submitReviewAnswer(Object reviewSetId) => '/reviews/$reviewSetId/answers';
  static String completeReview(Object reviewSetId) => '/reviews/$reviewSetId/complete';

  // Progress
  static const String streakDetail = '/progress/streak';
  static const String learningRecords = '/progress/learning-records';
  static const String competencyReport = '/progress/competency-report';

  // Simulation
  static const String simulations = '/simulations';
  static String startSimulation(Object simulationId) => '/simulations/$simulationId/attempts';
  static String simulationStep(Object attemptId, int stepNo) => '/simulation-attempts/$attemptId/steps/$stepNo';
  static String submitSimulationAnswer(Object attemptId, int stepNo) => '/simulation-attempts/$attemptId/steps/$stepNo/answers';
  static String completeSimulation(Object attemptId) => '/simulation-attempts/$attemptId/complete';

  // Daily Connect
  static const String dailyArticles = '/daily-connect/articles';
  static String articleDetail(String articleId) => '/daily-connect/articles/$articleId';
  static String termDetail(String termId) => '/terms/$termId';
  static String toggleBookmark(String articleId) => '/daily-connect/articles/$articleId/bookmark';
  static String submitDailyQuiz(String quizId) => '/daily-connect/quizzes/$quizId/answers';

  // My Page and characters
  static const String myPageSummary = '/my-page/summary';
  static String characterGrowth(String categoryCode) => '/characters/categories/$categoryCode';
  static String equipCharacter(String characterId) => '/characters/$characterId/equip';

  // Wallet and unlocks
  static const String wallet = '/wallet';
  static const String grantBills = '/wallet/bills/grant';
  static const String spendBills = '/wallet/bills/spend';
  static const String refillHearts = '/wallet/hearts/refill';
  static const String purchaseUnlimitedHearts = '/wallet/hearts/unlimited-pass';
  static const String purchaseStreakTicket = '/wallet/streak-revive-tickets/purchase';
  static const String useStreakTicket = '/wallet/streak/revive';
  static const String contentUnlocks = '/wallet/unlocks';
  static const String purchaseContentUnlock = '/wallet/unlocks/purchase';

  // Golden ticket
  static const String currentGoldenTicket = '/golden-tickets/current';
  static String activateGoldenTicket(Object ticketId) => '/golden-tickets/$ticketId/activate';

  // League, social, and battle
  static const String leagueMe = '/leagues/me';
  static String leagueRanking(Object leagueId) => '/leagues/$leagueId/ranking';
  static const String latestLeagueResult = '/leagues/results/latest';
  static const String friends = '/friends';
  static const String friendSearch = '/friends/search';
  static const String friendRequests = '/friend-requests';
  static String acceptFriendRequest(Object requestId) => '/friend-requests/$requestId/accept';
  static String rejectFriendRequest(Object requestId) => '/friend-requests/$requestId/reject';
  static String deleteFriend(Object friendId) => '/friends/$friendId';
  static const String socialFeed = '/social/feed';
  static String pokeFriend(Object friendId) => '/friends/$friendId/pokes';
  static const String battleSummary = '/battles/summary';
  static const String randomBattleMatch = '/battles/random-matches';
  static String startBattle(Object battleId) => '/battles/$battleId/attempts';
  static String submitBattleAnswer(Object attemptId) => '/battle-attempts/$attemptId/answers';
  static String completeBattle(Object attemptId) => '/battle-attempts/$attemptId/complete';
  static String battleResult(Object battleId) => '/battles/$battleId/result';
  static String battleReaction(Object battleId) => '/battles/$battleId/reactions';
  static const String battleFriendInvites = '/battles/friend-invites';
  static String acceptBattleInvite(Object inviteId) => '/battles/friend-invites/$inviteId/accept';
  static String rejectBattleInvite(Object inviteId) => '/battles/friend-invites/$inviteId/reject';
  static const String battleHistory = '/battles/history';

  // Settings and app info
  static const String notificationSettings = '/settings/notifications';
  static const String appInfo = '/app-info';
}

