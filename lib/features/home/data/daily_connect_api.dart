import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class DailyConnectApi {
  DailyConnectApi(this._client);

  final ApiClient _client;

  Future<List<DailyArticle>> articles({bool bookmarkedOnly = false}) async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.dailyArticles,
      query: bookmarkedOnly ? {'bookmarkedOnly': 'true'} : null,
    );
    return _asList(data['articles']).map(DailyArticle.fromJson).toList();
  }

  Future<DailyArticleDetail> article(String articleId) async {
    final data = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.articleDetail(articleId),
    );
    return DailyArticleDetail.fromJson(data);
  }
}

class DailyArticle {
  const DailyArticle({
    required this.id,
    required this.categoryCode,
    required this.title,
    required this.term,
    required this.subtitle,
    required this.summary,
    required this.thumbnailUrl,
    required this.youtubeUrl,
    required this.youtubeVideoId,
    required this.sourceName,
    required this.publishedAt,
    required this.bookmarked,
    required this.quizCompleted,
  });

  final String id;
  final String categoryCode;
  final String title;
  final String term;
  final String subtitle;
  final List<String> summary;
  final String thumbnailUrl;
  final String youtubeUrl;
  final String youtubeVideoId;
  final String sourceName;
  final String publishedAt;
  final bool bookmarked;
  final bool quizCompleted;

  factory DailyArticle.fromJson(Object? value) {
    final json = _asMap(value);
    return DailyArticle(
      id: '${json['id'] ?? ''}',
      categoryCode: '${json['categoryCode'] ?? ''}',
      title: '${json['title'] ?? ''}',
      term: '${json['term'] ?? json['title'] ?? ''}',
      subtitle: '${json['subtitle'] ?? ''}',
      summary: _asStringList(json['summary']),
      thumbnailUrl: '${json['thumbnailUrl'] ?? ''}',
      youtubeUrl: '${json['youtubeUrl'] ?? json['sourceUrl'] ?? ''}',
      youtubeVideoId: '${json['youtubeVideoId'] ?? ''}',
      sourceName: '${json['sourceName'] ?? ''}',
      publishedAt: '${json['publishedAt'] ?? ''}',
      bookmarked: json['bookmarked'] == true,
      quizCompleted: json['quizCompleted'] == true,
    );
  }
}

class DailyArticleDetail {
  const DailyArticleDetail({
    required this.article,
    required this.body,
    required this.sourceUrl,
    required this.terms,
    required this.relatedStageId,
    required this.quiz,
  });

  final DailyArticle article;
  final String body;
  final String sourceUrl;
  final List<DailyTerm> terms;
  final int relatedStageId;
  final DailyQuiz? quiz;

  factory DailyArticleDetail.fromJson(Map<String, dynamic> json) {
    final relatedLearning = _asMap(json['relatedLearning']);
    final quiz = _asMap(json['quiz']);
    return DailyArticleDetail(
      article: DailyArticle.fromJson(json),
      body: '${json['body'] ?? ''}',
      sourceUrl: '${json['sourceUrl'] ?? json['youtubeUrl'] ?? ''}',
      terms: _asList(json['terms']).map(DailyTerm.fromJson).toList(),
      relatedStageId: _asInt(relatedLearning['stageId']),
      quiz: quiz.isEmpty ? null : DailyQuiz.fromJson(quiz),
    );
  }
}

class DailyTerm {
  const DailyTerm({
    required this.id,
    required this.name,
    required this.definition,
    required this.relatedStageId,
  });

  final String id;
  final String name;
  final String definition;
  final int relatedStageId;

  factory DailyTerm.fromJson(Object? value) {
    final json = _asMap(value);
    return DailyTerm(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      definition: '${json['definition'] ?? ''}',
      relatedStageId: _asInt(json['relatedStageId']),
    );
  }
}

class DailyQuiz {
  const DailyQuiz({
    required this.quizId,
    required this.prompt,
    required this.choices,
    required this.completed,
  });

  final String quizId;
  final String prompt;
  final List<Map<String, dynamic>> choices;
  final bool completed;

  factory DailyQuiz.fromJson(Map<String, dynamic> json) {
    return DailyQuiz(
      quizId: '${json['quizId'] ?? ''}',
      prompt: '${json['prompt'] ?? ''}',
      choices: _asList(json['choices']).map(_asMap).toList(),
      completed: json['completed'] == true,
    );
  }
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

List<String> _asStringList(Object? value) {
  if (value is List) {
    return value.map((item) => '$item').where((item) => item.trim().isNotEmpty).toList();
  }
  return const [];
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
