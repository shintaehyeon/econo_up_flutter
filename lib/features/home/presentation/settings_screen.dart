// lib/features/home/presentation/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'account_settings_screen.dart';
import 'app_info_terms_screen.dart';
import 'friend_management_screen.dart';
import 'interest_area_settings_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
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
                child: Column(
                  children: [
                    _buildSettingCard(
                      scale: scale,
                      icon: '🔔',
                      title: '알림 설정',
                      subtitle: '복습·골든 티켓 알림',
                      onTap: () => _openNotificationSettings(context),
                    ),
                    SizedBox(height: 12 * scale),
                    _buildSettingCard(
                      scale: scale,
                      icon: '📊',
                      title: '관심 분야 수정',
                      subtitle: '홈 피드 카테고리 변경',
                      onTap: () => _openInterestAreaSettings(context),
                    ),
                    SizedBox(height: 12 * scale),
                    _buildSettingCard(
                      scale: scale,
                      icon: '👥',
                      title: '친구 관리',
                      subtitle: '추가·차단·목록',
                      onTap: () => _openFriendManagement(context),
                    ),
                    SizedBox(height: 12 * scale),
                    _buildSettingCard(
                      scale: scale,
                      icon: '🔒',
                      title: '계정 설정',
                      subtitle: '로그아웃·회원 탈퇴',
                      onTap: () => _openAccountSettings(context),
                    ),
                    SizedBox(height: 12 * scale),
                    _buildSettingCard(
                      scale: scale,
                      icon: '📄',
                      title: '앱 정보 / 약관',
                      subtitle: '버전 v1.0 · 이용약관',
                      onTap: () => _openAppInfoTerms(context),
                    ),
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
              '설정',
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

  Widget _buildSettingCard({
    required double scale,
    required String icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
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
                  Row(
                    children: [
                      Text(
                        icon,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          height: 20 / 14,
                        ),
                      ),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
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
                      ),
                    ],
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
            SizedBox(width: 12 * scale),
            Icon(
              Icons.chevron_right_rounded,
              size: 24 * scale,
              color: iconGrey,
            ),
          ],
        ),
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

  void _openNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationSettingsScreen(
          onBottomTabSelected: (index) {
            Navigator.of(context).pop();
            _goToBottomTab(context, index);
          },
        ),
      ),
    );
  }

  void _openInterestAreaSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterestAreaSettingsScreen(
          onBottomTabSelected: (index) {
            Navigator.of(context).pop();
            _goToBottomTab(context, index);
          },
        ),
      ),
    );
  }

  void _openAccountSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountSettingsScreen(
          onBottomTabSelected: (index) {
            Navigator.of(context).pop();
            _goToBottomTab(context, index);
          },
        ),
      ),
    );
  }

  void _openFriendManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FriendManagementScreen(
          onBottomTabSelected: (index) {
            Navigator.of(context).pop();
            _goToBottomTab(context, index);
          },
        ),
      ),
    );
  }

  void _openAppInfoTerms(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppInfoTermsScreen(
          onBottomTabSelected: (index) {
            Navigator.of(context).pop();
            _goToBottomTab(context, index);
          },
        ),
      ),
    );
  }

  void _goToBottomTab(BuildContext context, int index) {
    if (onBottomTabSelected != null) {
      onBottomTabSelected!(index);
      return;
    }
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: index,
    );
  }
}
