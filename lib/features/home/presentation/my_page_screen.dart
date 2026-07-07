// lib/features/home/presentation/my_page_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../data/my_page_api.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({
    super.key,
    this.onBottomTabSelected,
    this.onOpenSettings,
    this.showBottomNavigation = true,
  });

  final ValueChanged<int>? onBottomTabSelected;
  final VoidCallback? onOpenSettings;
  final bool showBottomNavigation;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textButton = Color(0xFF4B5563);
  static const Color iconGrey = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color selectedBg = Color(0xFFF2FFFA);
  static const Color disabledBg = Color(0xFFF3F3F3);
  static const Color disabledText = Color(0xFFC0C0C0);
  static const Color heatmapEmpty = Color(0xFFE4E8F0);
  static const Color fireOrange = Color(0xFFFF6900);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late final ApiClient _client;
  late final MyPageApi _api;
  late Future<MyPageData> _summaryFuture;

  static const Color brandInk = MyPageScreen.brandInk;
  static const Color textDark = MyPageScreen.textDark;
  static const Color textMuted = MyPageScreen.textMuted;
  static const Color textButton = MyPageScreen.textButton;
  static const Color iconGrey = MyPageScreen.iconGrey;
  static const Color borderGrey = MyPageScreen.borderGrey;
  static const Color themeGreen = MyPageScreen.themeGreen;
  static const Color selectedBg = MyPageScreen.selectedBg;
  static const Color disabledBg = MyPageScreen.disabledBg;
  static const Color disabledText = MyPageScreen.disabledText;
  static const Color fireOrange = MyPageScreen.fireOrange;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = MyPageApi(_client);
    _summaryFuture = _api.summary();
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

    final content = FutureBuilder<MyPageData>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: data == null && snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator(color: themeGreen))
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20 * scale,
                            9 * scale,
                            20 * scale,
                            24 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (snapshot.hasError && data == null) ...[
                                SizedBox(height: 160 * scale),
                                Text(
                                  '마이페이지 정보를 불러오지 못했어요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: textMuted,
                                  ),
                                ),
                              ] else ...[
                                _buildProfileSection(scale, data),
                                SizedBox(height: 20 * scale),
                                _buildStatusCard(scale, data),
                                SizedBox(height: 20 * scale),
                                _buildCollectionSection(scale, data),
                                SizedBox(height: 20 * scale),
                                _buildLearningRecordSection(scale, data),
                              ],
                            ],
                          ),
                        ),
                ),
                if (widget.showBottomNavigation)
                  EconoBottomNavigationBar(
                    activeTab: EconoBottomTab.my,
                    onTabSelected: (tab) {
                      final index = _indexForBottomTab(tab);
                      if (widget.onBottomTabSelected != null) {
                        widget.onBottomTabSelected!(index);
                      } else {
                        EconoBottomNavigationBar.goToRootTab(context, tab);
                      }
                    },
                    scale: scale,
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!widget.showBottomNavigation) {
      return ColoredBox(color: Colors.white, child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: content),
    );
  }

  Widget _buildProfileSection(double scale, MyPageData? data) {
    final nickname = data?.nickname.isNotEmpty == true ? data!.nickname : '사용자';
    final equippedName = _characterName(data?.equippedCharacterId);
    final equippedCategory = _categoryLabel(_characterCategoryCode(data?.equippedCharacterId));
    return SizedBox(
      height: 143 * scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 28 * scale,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '마이페이지',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 19 / 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 4 * scale),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onOpenSettings?.call();
            },
            child: Container(
              height: 110 * scale,
              padding: EdgeInsets.fromLTRB(6 * scale, 16 * scale, 18 * scale, 6 * scale),
              color: Colors.white,
              child: Row(
                children: [
                  _AvatarBubble(
                    emoji: '🐷',
                    size: 86,
                    emojiSize: 35.4,
                    borderColor: themeGreen,
                    backgroundColor: Colors.white,
                    scale: scale,
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2 * scale),
                        Row(
                          children: [
                            Text(
                              nickname,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                                height: 19 / 16,
                              ),
                            ),
                            SizedBox(width: 13 * scale),
                            Text(
                              '$equippedCategory 캐릭터',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                                height: 14 / 10,
                              ),
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              equippedName,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w600,
                                color: themeGreen,
                                height: 14 / 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14 * scale),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _ProfileCategoryIcon(
                              emoji: '◉',
                              label: '경제',
                              scale: scale,
                            ),
                            SizedBox(width: 25 * scale),
                            _ProfileCategoryIcon(
                              emoji: '🐷',
                              label: '저축',
                              scale: scale,
                            ),
                            SizedBox(width: 25 * scale),
                            _ProfileCategoryIcon.locked(label: '주식', scale: scale),
                            SizedBox(width: 25 * scale),
                            _ProfileCategoryIcon.locked(label: '부동산', scale: scale),
                            SizedBox(width: 25 * scale),
                            _ProfileCategoryIcon.locked(label: '세금', scale: scale),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(double scale, MyPageData? data) {
    final streakDays = data?.streakDays ?? 0;
    final leagueText = _leagueText(data?.leagueTier, data?.crowns ?? 0);
    return Container(
      height: 49 * scale,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 17 * scale,
                color: fireOrange,
              ),
              SizedBox(width: 2 * scale),
              Text(
                '$streakDays일 연속',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: textButton,
                  height: 14 / 14,
                ),
              ),
            ],
          ),
          Container(
            width: 1 * scale,
            height: 17 * scale,
            margin: EdgeInsets.symmetric(horizontal: 62 * scale),
            color: borderGrey,
          ),
          Text(
            leagueText,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: textButton,
              height: 14 / 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSection(double scale, MyPageData? data) {
    final equippedName = _characterName(data?.equippedCharacterId);
    final equippedCategory = _categoryLabel(_characterCategoryCode(data?.equippedCharacterId));
    return SizedBox(
      height: 139 * scale,
      child: Column(
        children: [
          SizedBox(
            height: 20 * scale,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '내 캐릭터 컬렉션',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: brandInk,
                      height: 19 / 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24 * scale,
                  color: iconGrey,
                ),
              ],
            ),
          ),
          SizedBox(height: 14 * scale),
          Row(
            children: [
              Expanded(
                child: _CharacterCard(
                  badge: '장착',
                  emoji: '🐷',
                  title: equippedName,
                  subtitle: '$equippedCategory Lv.1',
                  backgroundColor: selectedBg,
                  badgeColor: textButton,
                  badgeTextColor: const Color(0xFFE8E8E8),
                  scale: scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _CharacterCard(
                  badge: '장착 중',
                  emoji: '🪙',
                  title: '동전 모으기',
                  subtitle: '저축 Lv.2',
                  backgroundColor: selectedBg,
                  borderColor: themeGreen,
                  badgeColor: themeGreen,
                  badgeTextColor: textButton,
                  scale: scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _CharacterCard(
                  badge: '예정',
                  emoji: '🔒',
                  title: '통장 쪼개기',
                  subtitle: '저축 Lv.3',
                  backgroundColor: disabledBg,
                  badgeColor: disabledText,
                  badgeTextColor: const Color(0xFFE8E8E8),
                  isDisabled: true,
                  scale: scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningRecordSection(double scale, MyPageData? data) {
    return SizedBox(
      height: 122 * scale,
      child: Column(
        children: [
          SizedBox(
            height: 18 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '학습 기록',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: brandInk,
                      height: 19 / 16,
                    ),
                  ),
                ),
                _MonthSelector(scale: scale),
              ],
            ),
          ),
          SizedBox(height: 14 * scale),
          Container(
            height: 90 * scale,
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey, width: 1 * scale),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: _LearningHeatmap(scale: scale, calendar: data?.calendar ?? const []),
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

  String _characterCategoryCode(String? id) {
    final value = id ?? '';
    if (!value.startsWith('char_')) return 'SAVING';
    final last = value.lastIndexOf('_');
    if (last <= 5) return 'SAVING';
    return value.substring(5, last).toUpperCase();
  }

  String _categoryLabel(String code) {
    return switch (code.toUpperCase()) {
      'ECONOMY' => '경제',
      'STOCK' => '주식',
      'REAL_ESTATE' => '부동산',
      'TAX' => '세금',
      _ => '저축',
    };
  }

  String _characterName(String? id) {
    return switch (id) {
      'char_economy_1' => '경제 기초왕',
      'char_saving_1' => '저금통 텅텅',
      'char_saving_2' => '동전 모으기',
      'char_stock_1' => '주식 새싹',
      _ => '장착 캐릭터',
    };
  }

  String _leagueText(String? tier, int crowns) {
    final tierText = switch ((tier ?? '').toUpperCase()) {
      'GOLD' => '골드 리그',
      'SILVER' => '실버 리그',
      'BRONZE' => '브론즈 리그',
      _ => '브론즈 리그',
    };
    return crowns > 0 ? '🥈 $tierText · $crowns관' : '🥈 $tierText';
  }
}

class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({
    required this.emoji,
    required this.size,
    required this.emojiSize,
    required this.backgroundColor,
    required this.scale,
    this.borderColor,
  });

  final String emoji;
  final double size;
  final double emojiSize;
  final Color backgroundColor;
  final double scale;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * scale,
      height: size * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 1 * scale),
      ),
      child: Text(
        emoji,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: emojiSize * scale,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ProfileCategoryIcon extends StatelessWidget {
  const _ProfileCategoryIcon({
    required this.emoji,
    required this.label,
    required this.scale,
  }) : locked = false;

  const _ProfileCategoryIcon.locked({
    required this.label,
    required this.scale,
  })  : emoji = '🔒',
        locked = true;

  final String emoji;
  final String label;
  final double scale;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final labelWidth = label == '부동산' ? 26.0 : 21.46;

    return SizedBox(
      width: labelWidth * scale,
      height: 38.46 * scale,
      child: Column(
        children: [
          SizedBox(
            height: 21.46 * scale,
            child: Center(
              child: locked
                  ? Container(
                      width: 21.46 * scale,
                      height: 21.46 * scale,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8E8E8),
                        shape: BoxShape.circle,
                      ),
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: 8.84 * scale,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      emoji,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        height: 13 / 12,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 5 * scale),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500,
              color: MyPageScreen.textMuted,
              height: 12 / 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.badge,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.scale,
    this.borderColor,
    this.isDisabled = false,
  });

  final String badge;
  final String emoji;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color? borderColor;
  final bool isDisabled;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105 * scale,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 11.5 * scale,
            child: Column(
              children: [
                _AvatarBubble(
                  emoji: emoji,
                  size: 52,
                  emojiSize: 21.4,
                  backgroundColor: isDisabled ? const Color(0xFFE8E8E8) : Colors.white,
                  scale: scale,
                ),
                SizedBox(height: 6 * scale),
                Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? MyPageScreen.disabledText : MyPageScreen.textDark,
                    height: 14 / 12,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  subtitle,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w500,
                    color: isDisabled ? const Color(0xFFD0D0D0) : MyPageScreen.textMuted,
                    height: 12 / 10,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 9 * scale,
            child: Container(
              width: 40.23 * scale,
              height: 15 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(45 * scale),
              ),
              child: Text(
                badge,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w500,
                  color: badgeTextColor,
                  height: 12 / 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 71 * scale,
      height: 25 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.chevron_left_rounded,
            size: 18 * scale,
            color: MyPageScreen.iconGrey,
          ),
          SizedBox(width: 4 * scale),
          Text(
            '6월',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: MyPageScreen.textMuted,
              height: 14 / 12,
            ),
          ),
          SizedBox(width: 4 * scale),
          Icon(
            Icons.chevron_right_rounded,
            size: 18 * scale,
            color: MyPageScreen.iconGrey,
          ),
        ],
      ),
    );
  }
}

class _LearningHeatmap extends StatelessWidget {
  const _LearningHeatmap({required this.scale, required this.calendar});

  final double scale;
  final List<Map<String, dynamic>> calendar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnGap = 9 * scale;
        final rowGap = 6 * scale;
        final cellWidth = (constraints.maxWidth - columnGap * 9) / 10;
        final rowHeights = [15 * scale, 14 * scale, 15 * scale];

        return Column(
          children: [
            for (var row = 0; row < 3; row++) ...[
              SizedBox(
                height: rowHeights[row],
                child: Row(
                  children: [
                    for (var column = 0; column < 10; column++) ...[
                      Container(
                        width: cellWidth,
                        height: rowHeights[row],
                        decoration: BoxDecoration(
                          color: _cellColor(row * 10 + column),
                          borderRadius: BorderRadius.circular(3 * scale),
                        ),
                      ),
                      if (column != 9) SizedBox(width: columnGap),
                    ],
                  ],
                ),
              ),
              if (row != 2) SizedBox(height: rowGap),
            ],
          ],
        );
      },
    );
  }

  Color _cellColor(int index) {
    if (index >= calendar.length) return MyPageScreen.heatmapEmpty;
    final value = calendar[index]['intensity'];
    final intensity = value is int ? value : int.tryParse('$value') ?? 0;
    if (intensity <= 0) return MyPageScreen.heatmapEmpty;
    return MyPageScreen.themeGreen.withValues(alpha: (0.35 + intensity * 0.16).clamp(0.35, 1.0));
  }
}
