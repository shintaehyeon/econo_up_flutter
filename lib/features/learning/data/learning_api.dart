import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class LearningApi {
  LearningApi(this._client);

  final ApiClient _client;

  Future<LearningAttemptStart> startAttempt(int sessionId, {bool resume = true}) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.startSession(sessionId),
      body: {'resume': resume},
    );
    return LearningAttemptStart.fromJson(data);
  }

  Future<LearningAnswerResult> submitAnswer({
    required int attemptId,
    required int questionId,
    required Map<String, dynamic> answer,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.submitAnswer(attemptId),
      body: {
        'questionId': questionId,
        'answer': answer,
        'clientAnsweredAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
    return LearningAnswerResult.fromJson(data);
  }

  Future<LearningCompleteResult> completeAttempt(int attemptId) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.completeAttempt(attemptId),
    );
    return LearningCompleteResult.fromJson(data);
  }

  Future<void> exitAttempt(int attemptId) async {
    await _client.post<Map<String, dynamic>>(ApiEndpoints.exitAttempt(attemptId));
  }
}

class LearningAttemptStart {
  const LearningAttemptStart({
    required this.attemptId,
    required this.session,
    required this.progress,
    required this.question,
  });

  final int attemptId;
  final Map<String, dynamic> session;
  final LearningProgress progress;
  final LearningQuestion question;

  factory LearningAttemptStart.fromJson(Map<String, dynamic> json) {
    return LearningAttemptStart(
      attemptId: _asInt(json['attemptId']),
      session: _asMap(json['session']),
      progress: LearningProgress.fromJson(_asMap(json['progress'])),
      question: LearningQuestion.fromJson(_asMap(json['question'])),
    );
  }
}

class LearningAnswerResult {
  const LearningAnswerResult({
    required this.feedback,
    required this.progress,
    this.nextQuestion,
  });

  final LearningFeedback feedback;
  final LearningProgress progress;
  final LearningQuestion? nextQuestion;

  factory LearningAnswerResult.fromJson(Map<String, dynamic> json) {
    final next = json['nextQuestion'];
    return LearningAnswerResult(
      feedback: LearningFeedback.fromJson(_asMap(json['feedback'])),
      progress: LearningProgress.fromJson(_asMap(json['progress'])),
      nextQuestion: next is Map<String, dynamic> && next.isNotEmpty ? LearningQuestion.fromJson(next) : null,
    );
  }
}

class LearningCompleteResult {
  const LearningCompleteResult({
    required this.sessionCompleted,
    required this.stageCompleted,
    required this.xpGained,
    required this.growth,
    required this.next,
  });

  final bool sessionCompleted;
  final bool stageCompleted;
  final int xpGained;
  final Map<String, dynamic> growth;
  final Map<String, dynamic> next;

  int? get nextSessionId {
    final value = next['nextSessionId'];
    if (value == null) return null;
    final parsed = _asInt(value);
    return parsed <= 0 ? null : parsed;
  }

  factory LearningCompleteResult.fromJson(Map<String, dynamic> json) {
    return LearningCompleteResult(
      sessionCompleted: json['sessionCompleted'] == true,
      stageCompleted: json['stageCompleted'] == true,
      xpGained: _asInt(json['xpGained']),
      growth: _asMap(json['growth']),
      next: _asMap(json['next']),
    );
  }
}

class LearningFeedback {
  const LearningFeedback({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.highlightText,
    required this.reward,
    required this.heart,
  });

  final bool isCorrect;
  final Map<String, dynamic> correctAnswer;
  final String explanation;
  final String highlightText;
  final Map<String, dynamic> reward;
  final Map<String, dynamic> heart;

  int get xpGained => _asInt(reward['xpGained']);
  int get heartConsumed => _asInt(reward['heartConsumed']);

  factory LearningFeedback.fromJson(Map<String, dynamic> json) {
    return LearningFeedback(
      isCorrect: json['correct'] == true || json['isCorrect'] == true,
      correctAnswer: _asMap(json['correctAnswer']),
      explanation: '${json['explanation'] ?? ''}',
      highlightText: '${json['highlightText'] ?? ''}',
      reward: _asMap(json['reward']),
      heart: _asMap(json['heart']),
    );
  }
}

class LearningProgress {
  const LearningProgress({
    required this.current,
    required this.total,
    required this.answered,
  });

  final int current;
  final int total;
  final int answered;

  int get progressPercent {
    if (total <= 0) return 0;
    final value = (answered > 0 ? answered : current - 1) * 100 / total;
    return value.clamp(0, 100).round();
  }

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      current: _asInt(json['current'], fallback: 1),
      total: _asInt(json['total'], fallback: 1),
      answered: _asInt(json['answered']),
    );
  }
}

class LearningQuestion {
  const LearningQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.choices,
    required this.payload,
    required this.resource,
  });

  final int id;
  final String type;
  final String prompt;
  final List<LearningChoice> choices;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> resource;

  bool get isTheoryCard => type == 'THEORY_CARD';
  bool get isChoice => choices.isNotEmpty;
  bool get allowsMultipleChoice {
    final normalized = type.toUpperCase();
    return normalized == 'MULTIPLE_CHOICE' ||
        normalized == 'MULTI_SELECT' ||
        normalized == 'MATCHING' ||
        normalized == 'CLASSIFICATION';
  }

  bool get isOrdering => type == 'ORDERING';
  bool get isNumberInput => type == 'NUMBER_INPUT';
  bool get isTextInput => type == 'TEXT_INPUT' || (!isChoice && !isOrdering && !isNumberInput && !isTheoryCard);

  factory LearningQuestion.fromJson(Map<String, dynamic> json) {
    final context = _asMap(json['context']);
    final resource = _asMap(json['resource'] ?? json['source']);
    return LearningQuestion(
      id: _asInt(json['id']),
      type: '${json['type'] ?? 'SINGLE_CHOICE'}',
      prompt: '${json['prompt'] ?? ''}',
      choices: _asList(json['choices']).map(LearningChoice.fromJson).toList(),
      payload: _asMap(json['payload']),
      resource: {...context, ...resource},
    );
  }
}

class LearningChoice {
  const LearningChoice({required this.id, required this.text, this.subtitle});

  final String id;
  final String text;
  final String? subtitle;

  factory LearningChoice.fromJson(Object? value) {
    final map = value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    return LearningChoice(
      id: '${map['id'] ?? ''}',
      text: '${map['text'] ?? map['label'] ?? ''}',
      subtitle: map['subtitle'] == null ? null : '${map['subtitle']}',
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

List<Object?> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}
