import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class MyPageApi {
  MyPageApi(this._client);

  final ApiClient _client;

  Future<MyPageData> summary() async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.myPageSummary);
    return MyPageData.fromJson(data);
  }
}

class MyPageData {
  const MyPageData({
    required this.nickname,
    required this.equippedCharacterId,
    required this.streakDays,
    required this.leagueTier,
    required this.crowns,
    required this.characters,
    required this.calendar,
  });

  final String nickname;
  final String equippedCharacterId;
  final int streakDays;
  final String leagueTier;
  final int crowns;
  final List<Map<String, dynamic>> characters;
  final List<Map<String, dynamic>> calendar;

  factory MyPageData.fromJson(Map<String, dynamic> json) {
    final profile = _asMap(json['profile']);
    final league = _asMap(json['leaguePreview']);
    return MyPageData(
      nickname: '${profile['nickname'] ?? ''}',
      equippedCharacterId: '${profile['equippedCharacterId'] ?? ''}',
      streakDays: _asInt(json['streakDays']),
      leagueTier: '${league['tier'] ?? ''}',
      crowns: _asInt(league['crowns']),
      characters: _asList(json['characters']).map((e) => _asMap(e)).toList(),
      calendar: _asList(json['learningCalendarPreview']).map((e) => _asMap(e)).toList(),
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

List<Object?> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}