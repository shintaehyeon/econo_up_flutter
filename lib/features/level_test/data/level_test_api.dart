import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../learning/data/learning_api.dart';

class LevelTestApi {
  LevelTestApi(this._client);

  final ApiClient _client;

  Future<LevelTestStart> create({int questionCount = 5}) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.createLevelTest,
      body: {'questionCount': questionCount},
    );
    return LevelTestStart.fromJson(data);
  }

  Future<LevelTestAnswerResult> submitAnswer({
    required int testId,
    required int questionId,
    required Map<String, dynamic> answer,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.submitLevelTestAnswer(testId),
      body: {
        'questionId': questionId,
        'answer': answer,
      },
    );
    return LevelTestAnswerResult.fromJson(data);
  }

  Future<LevelTestCompleteResult> complete(int testId) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.completeLevelTest(testId),
    );
    return LevelTestCompleteResult.fromJson(data);
  }

  Future<void> skip() async {
    await _client.post<Map<String, dynamic>>(ApiEndpoints.skipLevelTest);
  }
}

class LevelTestStart {
  const LevelTestStart({
    required this.testId,
    required this.estimatedMinutes,
    required this.questionCount,
    required this.firstQuestion,
  });

  final int testId;
  final int estimatedMinutes;
  final int questionCount;
  final LearningQuestion firstQuestion;

  factory LevelTestStart.fromJson(Map<String, dynamic> json) {
    return LevelTestStart(
      testId: _asInt(json['testId']),
      estimatedMinutes: _asInt(json['estimatedMinutes'], fallback: 3),
      questionCount: _asInt(json['questionCount'], fallback: 5),
      firstQuestion: LearningQuestion.fromJson(_asMap(json['firstQuestion'])),
    );
  }
}

class LevelTestAnswerResult {
  const LevelTestAnswerResult({
    required this.accepted,
    required this.progress,
    this.nextQuestion,
  });

  final bool accepted;
  final LearningProgress progress;
  final LearningQuestion? nextQuestion;

  factory LevelTestAnswerResult.fromJson(Map<String, dynamic> json) {
    final next = json['nextQuestion'];
    return LevelTestAnswerResult(
      accepted: json['accepted'] == true,
      progress: LearningProgress.fromJson(_asMap(json['progress'])),
      nextQuestion: next is Map && next.isNotEmpty ? LearningQuestion.fromJson(Map<String, dynamic>.from(next)) : null,
    );
  }
}

class LevelTestCompleteResult {
  const LevelTestCompleteResult({
    required this.correctCount,
    required this.totalCount,
    required this.resultType,
    required this.resultTitle,
    required this.recommendedCategoryCode,
    required this.recommendedUnitId,
    required this.recommendedStageId,
  });

  final int correctCount;
  final int totalCount;
  final String resultType;
  final String resultTitle;
  final String recommendedCategoryCode;
  final int recommendedUnitId;
  final int recommendedStageId;

  int get scorePercent {
    if (totalCount <= 0) return 0;
    return (correctCount * 100 / totalCount).round().clamp(0, 100);
  }

  factory LevelTestCompleteResult.fromJson(Map<String, dynamic> json) {
    return LevelTestCompleteResult(
      correctCount: _asInt(json['correctCount']),
      totalCount: _asInt(json['totalCount'], fallback: 1),
      resultType: '${json['resultType'] ?? ''}',
      resultTitle: '${json['resultTitle'] ?? ''}',
      recommendedCategoryCode: '${json['recommendedCategoryCode'] ?? ''}',
      recommendedUnitId: _asInt(json['recommendedUnitId']),
      recommendedStageId: _asInt(json['recommendedStageId']),
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
