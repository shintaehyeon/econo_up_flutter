// lib/features/home/presentation/account_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({
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
  static const Color danger = Color(0xFFFF455D);
  static const Color dangerBg = Color(0xFFFFF2F4);

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
                    _buildConnectedAccountCard(scale),
                    SizedBox(height: 12 * scale),
                    _buildActionCard(
                      scale: scale,
                      title: '로그아웃',
                      subtitle: '이 기기에서 로그아웃됩니다',
                      onTap: () => _showLogoutDialog(context),
                    ),
                    SizedBox(height: 12 * scale),
                    _buildActionCard(
                      scale: scale,
                      title: '회원 탈퇴',
                      subtitle: '탈퇴 시 모든 학습 데이터 삭제됩니다',
                      isDanger: true,
                    ),
                  ],
                ),
              ),
            ),
            if (showBottomNavigation)
              EconoBottomNavigationBar(
                activeTab: EconoBottomTab.my,
                onTabSelected: (tab) => onBottomTabSelected?.call(_indexForBottomTab(tab)),
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
              '계정 설정',
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

  Widget _buildConnectedAccountCard(double scale) {
    return Container(
      width: double.infinity,
      height: 73 * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연결된 계정',
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
          SizedBox(height: 3 * scale),
          Text(
            '카카오 junseo27@kakao.com',
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
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required double scale,
    required String title,
    required String subtitle,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    final titleColor = isDanger ? danger : textDark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: double.infinity,
        height: 73 * scale,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: isDanger ? dangerBg : Colors.white,
          border: Border.all(
            color: isDanger ? danger : borderGrey,
            width: 1 * scale,
          ),
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
                      color: titleColor,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final scale = (screenWidth / 447.0).clamp(0.0, 1.0).toDouble();

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: LogoutConfirmDialog(scale: scale),
        );
      },
    );
  }
}

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({
    super.key,
    required this.scale,
  });

  final double scale;

  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color buttonText = Color(0xFF4B5563);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color dialogBg = Color(0xFFF3F4F6);
  static const Color danger = Color(0xFFFF455D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 335 * scale,
      height: 222 * scale,
      padding: EdgeInsets.fromLTRB(34 * scale, 22 * scale, 34 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: dialogBg,
        border: Border.all(color: borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 266 * scale,
            height: 109 * scale,
            child: Column(
              children: [
                SizedBox(
                  width: 266 * scale,
                  height: 46 * scale,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 54 * scale,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 14 * scale),
                SizedBox(
                  width: 266 * scale,
                  height: 49 * scale,
                  child: Column(
                    children: [
                      Text(
                        '정말 로그아웃 하시겠습니까?',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 18 * scale,
                          height: 26 / 18,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        '로그인 데이터는 유지됩니다.',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 13 * scale,
                          height: 16 / 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 21 * scale),
          SizedBox(
            width: 266 * scale,
            height: 38 * scale,
            child: Row(
              children: [
                Expanded(
                  child: _LogoutDialogButton(
                    label: '취소',
                    backgroundColor: Colors.white,
                    textColor: buttonText,
                    fontWeight: FontWeight.w500,
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _LogoutDialogButton(
                    label: '로그아웃',
                    backgroundColor: danger,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w700,
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutDialogButton extends StatelessWidget {
  const _LogoutDialogButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.fontWeight,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38 * scale,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.fromHeight(38 * scale),
          backgroundColor: backgroundColor,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: fontWeight,
            fontSize: 10 * scale,
            height: 13 / 10,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
