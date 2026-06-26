import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../learning/data/learning_api.dart';

class ReviewApi {
  ReviewApi(this._client);

  final ApiClient _client;

  Future<ReviewToday> today() async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.todayReviews);
    return ReviewToday.fromJson(data);
  }

  Future<LearningAnswerResult> submitAnswer({
    required int reviewSetId,
    required int questionId,
    required Map<String, dynamic> answer,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.submitReviewAnswer(reviewSetId),
      body: {
        'questionId': questionId,
        'answer': answer,
        'clientAnsweredAt': DateTime.now().toUtc().toIso8601String(),
      },
    );
    return LearningAnswerResult.fromJson(data);
  }

  Future<Map<String, dynamic>> complete(int reviewSetId) async {
    return _client.post<Map<String, dynamic>>(ApiEndpoints.completeReview(reviewSetId));
  }
}

class ReviewToday {
  const ReviewToday({required this.reviewSetId, required this.status, required this.progress, this.question});

  final int reviewSetId;
  final String status;
  final LearningProgress progress;
  final LearningQuestion? question;

  factory ReviewToday.fromJson(Map<String, dynamic> json) {
    final q = json['question'];
    return ReviewToday(
      reviewSetId: _asInt(json['reviewSetId']),
      status: '${json['status'] ?? ''}',
      progress: LearningProgress.fromJson(_asMap(json['progress'])),
      question: q is Map && q.isNotEmpty ? LearningQuestion.fromJson(Map<String, dynamic>.from(q)) : null,
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}