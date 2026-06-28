// lib/features/home/presentation/simulation_complete_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class SimulationCompleteScreen extends StatelessWidget {
  const SimulationCompleteScreen({
    super.key,
    this.onBottomTabSelected,
    this.xpGained = 200,
    this.badge = '내 집 마련 완료',
  });

  final ValueChanged<int>? onBottomTabSelected;
  final int xpGained;
  final String badge;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6F7782);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color xpGreen = Color(0xFF0DE593);
  static const Color selectedBg = Color(0xFFF2FFFA);

  static const List<_JourneyItem> _journeyItems = [
    _JourneyItem(icon: '🎊', day: 'D+0', title: '당첨 확인'),
    _JourneyItem(icon: '📄', day: 'D+7', title: '서류 준비'),
    _JourneyItem(icon: '📝', day: 'D+8', title: '계약 & 계약금'),
    _JourneyItem(icon: '🏦', day: 'D+60', title: '중도금 대출'),
    _JourneyItem(icon: '🔑', day: 'D+545', title: '잔금 & 등기'),
  ];

  static const List<String> _concepts = [
    '계약금 = 분양가 × 10% | 위약금 주의',
    '중도금 대출 = 집단 대출이 유리',
    '취득세 = 1주택 기준 1~3% 납부',
    '등기 전 법무사 선임 필수',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TitleHeader(scale: scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      0,
                      24 * scale,
                      14 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CompletionSummary(
                          scale: scale,
                          xpGained: xpGained,
                          badge: badge,
                        ),
                        SizedBox(height: 10 * scale),
                        _JourneySection(scale: scale),
                        SizedBox(height: 10 * scale),
                        _ConceptSection(scale: scale),
                        SizedBox(height: 22 * scale),
                        _PrimaryActionButton(
                          label: '학습으로 돌아가기',
                          scale: scale,
                          onTap: () => _returnToLearning(context),
                        ),
                      ],
                    ),
                  ),
                ),
                EconoBottomNavigationBar(
                  activeTab: EconoBottomTab.learning,
                  onTabSelected: (tab) => _handleBottomTab(context, tab),
                  scale: scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _returnToLearning(BuildContext context) {
    HapticFeedback.lightImpact();
    onBottomTabSelected?.call(1);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleBottomTab(BuildContext context, EconoBottomTab tab) {
    if (tab == EconoBottomTab.learning) {
      return;
    }

    final tabIndex = _indexForBottomTab(tab);
    if (onBottomTabSelected != null) {
      onBottomTabSelected!(tabIndex);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(tabIndex);
    }
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
}

class _TitleHeader extends StatelessWidget {
  const _TitleHeader({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 41 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        child: Center(
          child: Text(
            '시뮬레이션 완료!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: SimulationCompleteScreen.brandInk,
              height: 16 / 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionSummary extends StatelessWidget {
  const _CompletionSummary({
    required this.scale,
    required this.xpGained,
    required this.badge,
  });

  final double scale;
  final int xpGained;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155 * scale,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12 * scale,
          12 * scale,
          12 * scale,
          6 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48 * scale,
              child: Text(
                '🏠',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 40 * scale,
                  fontWeight: FontWeight.w400,
                  height: 48 / 40,
                ),
              ),
            ),
            SizedBox(height: 11 * scale),
            Text(
              badge,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: SimulationCompleteScreen.themeGreen,
                height: 28 / 18,
              ),
            ),
            SizedBox(height: 2 * scale),
            Text(
              '청약부터 등기까지 전 과정을 경험했어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationCompleteScreen.textDark,
                height: 16 / 12,
              ),
            ),
            SizedBox(height: 8 * scale),
            Center(
              child: Container(
                width: 103 * scale,
                height: 22 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SimulationCompleteScreen.selectedBg,
                  borderRadius: BorderRadius.circular(30 * scale),
                ),
                child: Text(
                  '+$xpGained XP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                    color: SimulationCompleteScreen.xpGreen,
                    height: 14 / 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneySection extends StatelessWidget {
  const _JourneySection({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TitledSection(
      title: '60일간의 여정',
      scale: scale,
      child: Container(
        height: 205 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: SimulationCompleteScreen.borderGrey,
            width: 1 * scale,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          children: [
            for (var i = 0; i < SimulationCompleteScreen._journeyItems.length; i++)
              _JourneyRow(
                item: SimulationCompleteScreen._journeyItems[i],
                scale: scale,
                showConnector: i != SimulationCompleteScreen._journeyItems.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({
    required this.item,
    required this.scale,
    required this.showConnector,
  });

  final _JourneyItem item;
  final double scale;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showConnector ? 37 * scale : 27 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 27 * scale,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 27 * scale,
                  height: 27 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SimulationCompleteScreen.themeGreen,
                    borderRadius: BorderRadius.circular(999 * scale),
                  ),
                  child: Text(
                    item.icon,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      height: 17 / 14,
                    ),
                  ),
                ),
                if (showConnector)
                  Positioned(
                    top: 27 * scale,
                    bottom: -10 * scale,
                    child: Container(
                      width: 2 * scale,
                      color: SimulationCompleteScreen.themeGreen,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          SizedBox(
            width: 44 * scale,
            height: 27 * scale,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.day,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: SimulationCompleteScreen.themeGreen,
                  height: 14 / 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 13 * scale),
          Expanded(
            child: SizedBox(
              height: 27 * scale,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: SimulationCompleteScreen.textDark,
                    height: 17 / 14,
                  ),
                ),
              ),
            ),
          ),
          _ReviewPill(scale: scale),
        ],
      ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        width: 43 * scale,
        height: 19 * scale,
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 4 * scale),
        decoration: BoxDecoration(
          color: SimulationCompleteScreen.selectedBg,
          borderRadius: BorderRadius.circular(30 * scale),
        ),
        child: Text(
          '복습',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            color: SimulationCompleteScreen.themeGreen,
            height: 12 / 10,
          ),
        ),
      ),
    );
  }
}

class _ConceptSection extends StatelessWidget {
  const _ConceptSection({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TitledSection(
      title: '이번 시뮬레이션 핵심 개념',
      scale: scale,
      child: Container(
        height: 91 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: SimulationCompleteScreen.borderGrey,
            width: 1 * scale,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < SimulationCompleteScreen._concepts.length; i++) ...[
              _ConceptRow(
                text: SimulationCompleteScreen._concepts[i],
                scale: scale,
              ),
              if (i != SimulationCompleteScreen._concepts.length - 1) SizedBox(height: 1 * scale),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConceptRow extends StatelessWidget {
  const _ConceptRow({
    required this.text,
    required this.scale,
  });

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15 * scale,
      child: Row(
        children: [
          SizedBox(
            width: 13 * scale,
            child: Text(
              '✓',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w400,
                color: SimulationCompleteScreen.themeGreen,
                height: 15 / 10,
                letterSpacing: 0.117188,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationCompleteScreen.textMuted,
                height: 15 / 10,
                letterSpacing: 0.117188,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitledSection extends StatelessWidget {
  const _TitledSection({
    required this.title,
    required this.scale,
    required this.child,
  });

  final String title;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 28 * scale,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: SimulationCompleteScreen.brandInk,
                height: 19 / 16,
                letterSpacing: -0.439453,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        child,
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SimulationCompleteScreen.themeGreen,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}

class _JourneyItem {
  const _JourneyItem({
    required this.icon,
    required this.day,
    required this.title,
  });

  final String icon;
  final String day;
  final String title;
}
