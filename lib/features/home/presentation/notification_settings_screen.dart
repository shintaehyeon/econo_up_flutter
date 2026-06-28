// lib/features/home/presentation/notification_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
    this.onBack,
    this.onBottomTabSelected,
    this.showBottomNavigation = true,
  });

  final VoidCallback? onBack;
  final ValueChanged<int>? onBottomTabSelected;
  final bool showBottomNavigation;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color iconGrey = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color inactiveSwitch = Color(0xFFD0D5E0);
  static const Color chipGrey = Color(0xFFF3F4F6);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late final ApiClient _client;

  bool _reviewQuizEnabled = true;
  bool _goldenTicketEnabled = true;
  bool _pokeEnabled = true;
  bool _leagueEnabled = true;
  bool _studyReminderEnabled = false;
  String _reviewReminderTime = '07:30';
  String _studyReminderTime = '21:00';
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const Color brandInk = NotificationSettingsScreen.brandInk;
  static const Color textDark = NotificationSettingsScreen.textDark;
  static const Color textMuted = NotificationSettingsScreen.textMuted;
  static const Color iconGrey = NotificationSettingsScreen.iconGrey;
  static const Color borderGrey = NotificationSettingsScreen.borderGrey;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    final content = Center(
      child: SizedBox(
        width: contentWidth,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  29 * scale,
                  24 * scale,
                  24 * scale,
                ),
                child: _buildSettingsContent(scale),
              ),
            ),
            if (widget.showBottomNavigation)
              EconoBottomNavigationBar(
                activeTab: EconoBottomTab.my,
                onTabSelected: (tab) => widget.onBottomTabSelected?.call(_indexForBottomTab(tab)),
                scale: scale,
              ),
          ],
        ),
      ),
    );

    if (!widget.showBottomNavigation) {
      return ColoredBox(color: Colors.white, child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: content),
    );
  }

  Widget _buildSettingsContent(double scale) {
    if (_isLoading) {
      return SizedBox(
        height: 360 * scale,
        child: const Center(
          child: CircularProgressIndicator(color: NotificationSettingsScreen.themeGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 360 * scale,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
              SizedBox(height: 12 * scale),
              TextButton(
                onPressed: _loadNotificationSettings,
                child: const Text('다시 불러오기'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_isSaving)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * scale),
            child: const LinearProgressIndicator(
              minHeight: 2,
              color: NotificationSettingsScreen.themeGreen,
              backgroundColor: Color(0xFFE4E8F0),
            ),
          ),
        _buildNotificationCard(
          scale: scale,
          title: '복습 퀴즈 알림',
          subtitle: '매일 아침 복습 알림',
          time: _reviewReminderTime,
          enabled: _reviewQuizEnabled,
          onChanged: (value) => _updateSetting(reviewQuiz: value),
        ),
        SizedBox(height: 12 * scale),
        _buildNotificationCard(
          scale: scale,
          title: '골든 티켓 알림',
          subtitle: '티켓 발급 시 즉시',
          enabled: _goldenTicketEnabled,
          onChanged: (value) => _updateSetting(goldenTicket: value),
        ),
        SizedBox(height: 12 * scale),
        _buildNotificationCard(
          scale: scale,
          title: '찌르기 알림',
          subtitle: '친구가 찌를 때',
          enabled: _pokeEnabled,
          onChanged: (value) => _updateSetting(poke: value),
        ),
        SizedBox(height: 12 * scale),
        _buildNotificationCard(
          scale: scale,
          title: '리그 알림',
          subtitle: '순위 변동·리그 종료',
          enabled: _leagueEnabled,
          onChanged: (value) => _updateSetting(league: value),
        ),
        SizedBox(height: 12 * scale),
        _buildNotificationCard(
          scale: scale,
          title: '학습 리마인더',
          subtitle: '미접속 시 리마인더',
          time: _studyReminderTime,
          enabled: _studyReminderEnabled,
          onChanged: (value) => _updateSetting(studyReminder: value),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return SizedBox(
      height: 41 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (widget.onBack != null) {
                    widget.onBack!();
                    return;
                  }
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: SizedBox(
                  width: 32 * scale,
                  height: 32 * scale,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 26 * scale,
                    color: iconGrey,
                  ),
                ),
              ),
            ),
            Text(
              '알림 설정',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: brandInk,
                height: 16 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required double scale,
    required String title,
    required String subtitle,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    String? time,
  }) {
    return Container(
      height: 73 * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    height: 20 / 16,
                  ),
                ),
                SizedBox(height: 3 * scale),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    height: 14 / 12,
                  ),
                ),
              ],
            ),
          ),
          if (time != null) ...[
            SizedBox(width: 12 * scale),
            _TimeChip(time: time, scale: scale),
          ],
          SizedBox(width: 12 * scale),
          _NotificationSwitch(
            enabled: enabled,
            scale: scale,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  int _indexForBottomTab(EconoBottomTab tab) {
    switch (tab) {
      case EconoBottomTab.home:
        return 0;
      case EconoBottomTab.learning:
        return 1;
      case EconoBottomTab.connect:
        return 2;
      case EconoBottomTab.battle:
        return 3;
      case EconoBottomTab.my:
        return 4;
    }
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.notificationSettings);
      if (!mounted) return;
      _applyNotificationPayload(data);
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '알림 설정을 불러오지 못했어요.';
      });
    }
  }

  Future<void> _updateSetting({
    bool? reviewQuiz,
    bool? goldenTicket,
    bool? poke,
    bool? league,
    bool? studyReminder,
  }) async {
    if (_isSaving) return;

    final previous = (
      reviewQuiz: _reviewQuizEnabled,
      goldenTicket: _goldenTicketEnabled,
      poke: _pokeEnabled,
      league: _leagueEnabled,
      studyReminder: _studyReminderEnabled,
    );

    setState(() {
      if (reviewQuiz != null) _reviewQuizEnabled = reviewQuiz;
      if (goldenTicket != null) _goldenTicketEnabled = goldenTicket;
      if (poke != null) _pokeEnabled = poke;
      if (league != null) _leagueEnabled = league;
      if (studyReminder != null) _studyReminderEnabled = studyReminder;
      _isSaving = true;
    });

    try {
      final data = await _client.put<Map<String, dynamic>>(
        ApiEndpoints.notificationSettings,
        body: {
          'reviewReminder': {
            'enabled': _reviewQuizEnabled,
            'time': _reviewReminderTime,
          },
          'goldenTicket': {'enabled': _goldenTicketEnabled},
          'poke': {'enabled': _pokeEnabled},
          'league': {'enabled': _leagueEnabled},
          'studyReminder': {
            'enabled': _studyReminderEnabled,
            'time': _studyReminderTime,
          },
        },
      );
      if (!mounted) return;
      _applyNotificationPayload(data);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reviewQuizEnabled = previous.reviewQuiz;
        _goldenTicketEnabled = previous.goldenTicket;
        _pokeEnabled = previous.poke;
        _leagueEnabled = previous.league;
        _studyReminderEnabled = previous.studyReminder;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정 저장에 실패했어요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _applyNotificationPayload(Map<String, dynamic> data) {
    final review = _asMap(data['reviewReminder']);
    final golden = _asMap(data['goldenTicket']);
    final poke = _asMap(data['poke']);
    final league = _asMap(data['league']);
    final study = _asMap(data['studyReminder']);

    setState(() {
      _reviewQuizEnabled = review['enabled'] == true;
      _reviewReminderTime = _asString(review['time'], fallback: '07:30');
      _goldenTicketEnabled = golden['enabled'] == true;
      _pokeEnabled = poke['enabled'] == true;
      _leagueEnabled = league['enabled'] == true;
      _studyReminderEnabled = study['enabled'] == true;
      _studyReminderTime = _asString(study['time'], fallback: '21:00');
    });
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
}

String _asString(Object? value, {required String fallback}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.scale,
  });

  final String time;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56 * scale,
      height: 20 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NotificationSettingsScreen.chipGrey,
        borderRadius: BorderRadius.circular(40 * scale),
      ),
      child: Text(
        time,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
          color: NotificationSettingsScreen.iconGrey,
          height: 14 / 12,
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  const _NotificationSwitch({
    required this.enabled,
    required this.scale,
    required this.onChanged,
  });

  final bool enabled;
  final double scale;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!enabled);
      },
      child: SizedBox(
        width: 36 * scale,
        height: 24 * scale,
        child: Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 36 * scale,
            height: 20 * scale,
            padding: EdgeInsets.all(2 * scale),
            decoration: BoxDecoration(
              color: enabled
                  ? NotificationSettingsScreen.themeGreen
                  : NotificationSettingsScreen.inactiveSwitch,
              borderRadius: BorderRadius.circular(40 * scale),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16 * scale,
                height: 16 * scale,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
