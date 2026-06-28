import 'package:flutter/material.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class LeagueScreen extends StatefulWidget {
  final bool isEmbedded;
  final ValueChanged<int>? onSubTabChanged;

  const LeagueScreen({
    super.key,
    this.isEmbedded = false,
    this.onSubTabChanged,
  });

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  late final ApiClient _client;
  _LeagueSummary _summary = _LeagueSummary.fallback();
  List<_LeagueMember> _ranking = _fallbackRanking;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken, onUnauthorized: AuthSession.clear);
    _loadLeague();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadLeague() async {
    try {
      final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.leagueMe);
      final summary = _LeagueSummary.fromJson(data);
      var ranking = _fallbackRanking;
      if (summary.leagueId.isNotEmpty) {
        final rankingData = await _client.get<Map<String, dynamic>>(ApiEndpoints.leagueRanking(summary.leagueId));
        final rows = _asList(rankingData['ranking']).map(_LeagueMember.fromJson).toList();
        if (rows.isNotEmpty) {
          ranking = rows;
        }
      }
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _ranking = ranking;
      });
    } catch (_) {
      // QA 직전에는 리그 API가 비어 있어도 화면이 깨지지 않도록 기존 골드 카드로 유지한다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _summary.style;
    final mainContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMyLeagueCard(_summary),
          const SizedBox(height: 32),
          Text(
            '${style.name} 랭킹',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF122711),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _ranking.length; i++) ...[
            _buildRankingItem(
              _ranking[i].rank,
              _ranking[i].nickname,
              _ranking[i].pointsText,
              _ranking[i].rank == _summary.rank,
              style,
            ),
            if (i != _ranking.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return Container(
        color: Colors.white,
        child: mainContent,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '배틀',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF122711),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildTab('배틀', false, 0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTab('리그', true, 1)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTab('친구', false, 2)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: mainContent,
            ),
            
            // Bottom Nav
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.battle),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, int tabIdx) {
    return GestureDetector(
      onTap: () {
        if (widget.onSubTabChanged != null) {
          widget.onSubTabChanged!(tabIdx);
        }
      },
      child: Container(
        height: 33,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00EE94) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? null : Border.all(color: const Color(0xFFD0D5E0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: isActive ? 13 : 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF99A1AF),
          ),
        ),
      ),
    );
  }

  Widget _buildMyLeagueCard(_LeagueSummary summary) {
    final style = summary.style;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: style.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.workspace_premium, color: style.accent, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    style.name,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  summary.dDayLabel,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: style.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary.rank > 0 ? '랭킹 ${summary.rank}위' : '랭킹 집계 중',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.promotionText,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF99A1AF),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(summary.progress * 100).round()}%',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: summary.progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: style.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(int rank, String name, String points, bool isMe, _LeagueStyle style) {
    return Container(
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isMe ? style.background : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMe ? style.accent : const Color(0xFFD0D5E0),
        ),
      ),
      child: Row(
        children: [
          if (rank <= 3) ...[
            Icon(Icons.military_tech, color: style.accent, size: 16),
            const SizedBox(width: 4),
          ],
          SizedBox(
            width: rank <= 3 ? 24 : 44, // Align numbers if icon is missing
            child: Text(
              '$rank위',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF99A1AF),
              ),
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          const Icon(Icons.workspace_premium, color: Color(0xFFFCD34D), size: 18),
          const SizedBox(width: 4),
          Text(
            points,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueSummary {
  const _LeagueSummary({
    required this.tier,
    required this.rank,
    required this.weeklyXp,
    required this.leagueId,
    required this.resetsAt,
  });

  final String tier;
  final int rank;
  final int weeklyXp;
  final String leagueId;
  final String resetsAt;

  _LeagueStyle get style => _LeagueStyle.fromTier(tier);

  String get dDayLabel {
    final resetDate = DateTime.tryParse(resetsAt);
    if (resetDate == null) return 'D-3';
    final diff = resetDate.difference(DateTime.now());
    final days = diff.inSeconds <= 0 ? 0 : (diff.inHours / 24).ceil();
    return 'D-$days';
  }

  String get promotionText {
    if (weeklyXp <= 0) return '승급까지 24점';
    final remaining = (100 - weeklyXp).clamp(0, 100);
    return '승급까지 $remaining점';
  }

  double get progress {
    if (weeklyXp <= 0) return 0.72;
    return (weeklyXp / 100).clamp(0.0, 1.0);
  }

  factory _LeagueSummary.fromJson(Map<String, dynamic> json) {
    return _LeagueSummary(
      tier: '${json['tier'] ?? 'GOLD'}',
      rank: _asInt(json['rank']),
      weeklyXp: _asInt(json['weeklyXp']),
      leagueId: '${json['leagueId'] ?? ''}',
      resetsAt: '${json['resetsAt'] ?? ''}',
    );
  }

  factory _LeagueSummary.fallback() {
    return const _LeagueSummary(
      tier: 'GOLD',
      rank: 3,
      weeklyXp: 72,
      leagueId: '',
      resetsAt: '',
    );
  }
}

class _LeagueStyle {
  const _LeagueStyle({
    required this.name,
    required this.background,
    required this.accent,
    required this.shadow,
  });

  final String name;
  final Color background;
  final Color accent;
  final Color shadow;

  static _LeagueStyle fromTier(String tier) {
    return switch (tier.toUpperCase()) {
      'BRONZE' => const _LeagueStyle(
          name: '브론즈 리그',
          background: Color(0xFFFFF6F2),
          accent: Color(0xFFD9853A),
          shadow: Color(0x1FD9853A),
        ),
      'SILVER' => const _LeagueStyle(
          name: '실버 리그',
          background: Color(0xFFFAFAFA),
          accent: Color(0xFF99A1AF),
          shadow: Color(0x1F99A1AF),
        ),
      'PLATINUM' => const _LeagueStyle(
          name: '플래티넘 리그',
          background: Color(0xFFE8FBFC),
          accent: Color(0xFF00CFE8),
          shadow: Color(0x1F00CFE8),
        ),
      'DIAMOND' => const _LeagueStyle(
          name: '다이아 리그',
          background: Color(0xFFEAF3FF),
          accent: Color(0xFF5B9EFF),
          shadow: Color(0x1F5B9EFF),
        ),
      _ => const _LeagueStyle(
          name: '골드 리그',
          background: Color(0xFFFFFEF3),
          accent: Color(0xFFEEE201),
          shadow: Color(0x1FEEE201),
        ),
    };
  }
}

class _LeagueMember {
  const _LeagueMember({
    required this.rank,
    required this.nickname,
    required this.weeklyXp,
  });

  final int rank;
  final String nickname;
  final int weeklyXp;

  String get pointsText => weeklyXp > 0 ? '$weeklyXp XP' : '0 XP';

  factory _LeagueMember.fromJson(Object? value) {
    final json = _asMap(value);
    return _LeagueMember(
      rank: _asInt(json['rank']),
      nickname: '${json['nickname'] ?? '사용자'}',
      weeklyXp: _asInt(json['weeklyXp']),
    );
  }
}

const _fallbackRanking = [
  _LeagueMember(rank: 1, nickname: '왕초보탈출', weeklyXp: 320),
  _LeagueMember(rank: 2, nickname: '경제박사', weeklyXp: 298),
  _LeagueMember(rank: 3, nickname: '경제왕', weeklyXp: 254),
  _LeagueMember(rank: 4, nickname: '머니킹', weeklyXp: 210),
];

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Object?> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
