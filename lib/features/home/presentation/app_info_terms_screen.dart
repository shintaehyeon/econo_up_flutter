// lib/features/home/presentation/app_info_terms_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class AppInfoTermsScreen extends StatelessWidget {
  const AppInfoTermsScreen({
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

  static const List<_AppInfoItem> _items = [
    _AppInfoItem(title: '이용약관', subtitle: '서비스 이용약관 전문'),
    _AppInfoItem(title: '개인정보처리방침', subtitle: '개인정보 수집·이용 안내'),
    _AppInfoItem(title: '공지사항', subtitle: '서비스 업데이트·공지'),
    _AppInfoItem(title: '문의하기', subtitle: '이메일·고객센터 연결'),
    _AppInfoItem(title: '문의하기', subtitle: '이메일·고객센터 연결'),
  ];

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
            _buildVersionInfo(scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  29 * scale,
                  24 * scale,
                  24 * scale,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _items.length; i++) ...[
                      _AppInfoCard(item: _items[i], scale: scale),
                      if (i != _items.length - 1) SizedBox(height: 12 * scale),
                    ],
                  ],
                ),
              ),
            ),
            if (showBottomNavigation)
              EconoBottomNavigationBar(
                activeTab: EconoBottomTab.my,
                onTabSelected: (tab) {
                  final index = _indexForBottomTab(tab);
                  if (onBottomTabSelected != null) {
                    onBottomTabSelected!(index);
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

    if (!showBottomNavigation) {
      return ColoredBox(color: Colors.white, child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: content),
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
                  if (onBack != null) {
                    onBack!();
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
              '앱 정보 / 약관',
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

  Widget _buildVersionInfo(double scale) {
    return SizedBox(
      height: 99 * scale,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 17 * scale,
            child: Text(
              'Econo-up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 30 * scale,
                fontWeight: FontWeight.w700,
                color: themeGreen,
                height: 36 / 30,
              ),
            ),
          ),
          Positioned(
            top: 56 * scale,
            child: Text(
              '버전 v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: textMuted,
                height: 16 / 12,
              ),
            ),
          ),
          Positioned(
            top: 83 * scale,
            child: Text(
              '최신 버전입니다 ✓',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                color: textDark,
                height: 16 / 14,
              ),
            ),
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
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard({
    required this.item,
    required this.scale,
  });

  final _AppInfoItem item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 73 * scale,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppInfoTermsScreen.borderGrey, width: 1 * scale),
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
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppInfoTermsScreen.textDark,
                      height: 20 / 16,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppInfoTermsScreen.textMuted,
                      height: 14 / 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            Icon(
              Icons.chevron_right_rounded,
              size: 24 * scale,
              color: AppInfoTermsScreen.iconGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppInfoItem {
  const _AppInfoItem({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}
