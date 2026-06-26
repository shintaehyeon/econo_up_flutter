import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class HomeApi {
  HomeApi(this._client);

  final ApiClient _client;

  Future<HomeData> home() async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.home);
    return HomeData.fromJson(data);
  }
}

class HomeData {
  const HomeData({
    required this.nickname,
    required this.streakDays,
    required this.heartCurrent,
    required this.heartMax,
    required this.billBalance,
    required this.categories,
    this.review,
    this.dailyConnect,
  });

  final String nickname;
  final int streakDays;
  final int heartCurrent;
  final int heartMax;
  final int billBalance;
  final List<HomeCategoryProgress> categories;
  final Map<String, dynamic>? review;
  final Map<String, dynamic>? dailyConnect;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final summary = _asMap(json['summary']);
    final continueLearning = _asMap(json['continueLearning']);
    final today = _asMap(json['today']);
    return HomeData(
      nickname: '${user['nickname'] ?? ''}',
      streakDays: _asInt(summary['streakDays']),
      heartCurrent: _asInt(summary['heartCurrent']),
      heartMax: _asInt(summary['heartMax'], fallback: 3),
      billBalance: _asInt(summary['billBalance']),
      categories: _asList(continueLearning['categories']).map(HomeCategoryProgress.fromJson).toList(),
      review: _asMapOrNull(today['review']),
      dailyConnect: _asMapOrNull(today['dailyConnect']),
    );
  }
}

class HomeCategoryProgress {
  const HomeCategoryProgress({
    required this.categoryCode,
    required this.categoryName,
    required this.completedSessionCount,
    required this.totalSessionCount,
    required this.progressPercent,
    this.nextSession,
  });

  final String categoryCode;
  final String categoryName;
  final int completedSessionCount;
  final int totalSessionCount;
  final int progressPercent;
  final Map<String, dynamic>? nextSession;

  bool get isAvailable => totalSessionCount > 0;

  factory HomeCategoryProgress.fromJson(Object? value) {
    final json = _asMap(value);
    return HomeCategoryProgress(
      categoryCode: '${json['categoryCode'] ?? ''}',
      categoryName: '${json['categoryName'] ?? ''}',
      completedSessionCount: _asInt(json['completedSessionCount']),
      totalSessionCount: _asInt(json['totalSessionCount']),
      progressPercent: _asInt(json['progressPercent']),
      nextSession: _asMapOrNull(json['nextSession']),
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

Map<String, dynamic>? _asMapOrNull(Object? value) {
  final map = _asMap(value);
  return map.isEmpty ? null : map;
}

List<Object?> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}