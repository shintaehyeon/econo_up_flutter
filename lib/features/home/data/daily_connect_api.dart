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
}

class DailyArticle {
  const DailyArticle({
    required this.id,
    required this.categoryCode,
    required this.title,
    required this.term,
    required this.subtitle,
    required this.thumbnailUrl,
    required this.youtubeUrl,
    required this.publishedAt,
    required this.bookmarked,
    required this.quizCompleted,
  });

  final String id;
  final String categoryCode;
  final String title;
  final String term;
  final String subtitle;
  final String thumbnailUrl;
  final String youtubeUrl;
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
      thumbnailUrl: '${json['thumbnailUrl'] ?? ''}',
      youtubeUrl: '${json['youtubeUrl'] ?? ''}',
      publishedAt: '${json['publishedAt'] ?? ''}',
      bookmarked: json['bookmarked'] == true,
      quizCompleted: json['quizCompleted'] == true,
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