// lib/features/home/presentation/app_info_terms_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _AppInfoItem(
      title: '이용약관',
      subtitle: '서비스 이용약관 전문',
      action: _AppInfoAction.terms,
    ),
    _AppInfoItem(
      title: '개인정보처리방침',
      subtitle: '개인정보 수집·이용 안내',
      action: _AppInfoAction.privacy,
    ),
    _AppInfoItem(
      title: '문의하기',
      subtitle: '이메일·고객센터 연결',
      action: _AppInfoAction.contact,
    ),
  ];

  static const String _termsText = '''
서비스 이용약관

제1조 (목적)

본 약관은 '이코노업'(이하 "서비스")이 제공하는 경제·금융 학습 및 관련 제반 서비스의 이용과 관련하여 서비스와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (회원가입 및 이용계약 체결)

① 이용계약은 가입신청자가 카카오, 구글, 애플 등의 소셜 계정을 통해 약관에 동의하고 가입을 신청한 후, 서비스가 이를 승낙함으로써 체결됩니다.

② 본 서비스는 만 14세 이상인 이용자만 가입 및 이용이 가능합니다. 만 14세 미만의 아동이 타인의 명의를 도용하는 등 허위로 가입한 사실이 확인될 경우, 서비스 이용 제한 조치를 취할 수 있습니다.

제3조 (서비스의 내용 및 콘텐츠)

① 서비스는 회원에게 카테고리·유닛·세션 단위의 단계별 경제·금융 학습, 복습 퀴즈, 시뮬레이션 퀘스트, 데일리 커넥트 뉴스 학습 및 소셜 기능(퀴즈 대결, 리그, 찌르기)을 제공합니다.

② 회원은 서비스 내 캐릭터 성장, XP, 인앱 재화(지폐), 오각형 리포트 등 서비스가 제공하는 게이미피케이션 요소를 이용할 수 있으며, 시스템 오류나 부정한 방법으로 학습 진도·재화·랭킹 등을 조작해서는 안 됩니다.

제4조 (유료 서비스 및 인앱 결제)

① 서비스의 일부 카테고리(주식 등) 및 기능은 유료로 제공되며, 회원은 인앱 재화(지폐) 충전 또는 카테고리 패스 구매를 통해 이용할 수 있습니다.

② 구매한 인앱 재화 및 콘텐츠 이용권은 관련 법령 및 앱스토어 정책에서 정한 범위 내에서 환불이 가능합니다.

③ 회원 탈퇴 시 잔여 인앱 재화 및 구매한 콘텐츠 이용 권한은 소멸되며, 환불되지 않습니다.

제5조 (서비스의 변경 및 중지)

서비스는 MVP(최소 기능 제품) 단계의 테스트 운영 및 기술적 필요에 따라 제공하고 있는 기능의 일부 또는 전부를 사전 공지 후 변경하거나 중단할 수 있습니다.

Copyright 2026. 이코노업. All rights reserved.

본 서비스의 UI/UX 디자인, 프로그램 소스 코드 및 고유 콘텐츠(학습 세션, 시뮬레이션 퀘스트, 데일리 커넥트 등)의 저작권은 이코노업에 있습니다.

Open Source License

본 앱은 공공의 이익과 개발자 커뮤니티의 오픈소스 가이드라인을 준수하며, 상업적 이용이 가능한 무료 라이선스 폰트 및 에셋을 활용하여 제작되었습니다.
''';

  static const String _privacyText = '''
개인정보처리방침

이코노업(이하 "서비스")은 이용자의 개인정보를 소중히 여기며, 최소한의 정보만 수집합니다.

1. 수집하는 개인정보의 항목 및 수집 방법

가입 시 (소셜 연동)
카카오, 구글, 애플 계정 연동을 통해 제공받는 이메일 주소, 닉네임

서비스 이용 시 수집되는 데이터
학습 세션 진행 이력 및 진도 데이터, 복습 퀴즈 결과 및 정오답 기록, 티어 및 배틀 점수 데이터, 캐릭터 레벨 및 XP 상태 정보, 시뮬레이션 퀘스트 진행 기록, 인앱 재화(지폐) 및 아이템(하트·부활권) 보유 및 사용 이력, 소셜 기능(찌르기, 퀴즈 대결, 리그 순위) 이용 기록, 레벨 테스트 결과 및 콘텐츠 추천 데이터

자동 수집 항목
접속 로그, 기기 정보, IP 주소, 앱 이용 시간대 및 세션 체류 시간

2. 개인정보의 수집 및 이용 목적

회원 관리 및 서비스 제공
카카오, 구글, 애플 계정을 통한 본인 식별, 만 14세 미만 아동의 가입 제한 확인, 불량 이용자의 부정 이용 방지

핵심 기능 구현
레벨 테스트 기반 개인 맞춤 콘텐츠 추천, 카테고리·유닛·세션 단위 학습 진도 및 해금 상태 저장, 복습 퀴즈 스케줄 산정 및 연속 학습일 카운트, 오각형 리포트 실시간 반영 및 카테고리별 상위 % 표시, 시뮬레이션 퀘스트 진행 상태 저장, 소셜 기능(리그 랭킹·퀴즈 대결·찌르기) 운영, 인앱 재화 및 아이템 결제·사용 내역 관리, 데일리 커넥트 뉴스 학습 이력 연동, 골든 티켓 발송 및 수강 이력 관리

서비스 개선
MVP 운영 기간 중 오류 수정 및 사용자 편의성 향상을 위한 통계 분석, 핵심 사용 시간대(출근·퇴근·취침 전) 학습 패턴 분석을 통한 알림 최적화

3. 개인정보의 보유 및 이용 기간

원칙적으로 회원 탈퇴 시 또는 개인정보 수집 및 이용 목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다.

단, 부정이용 및 어뷰징 방지를 위해 탈퇴 후에도 6개월간 최소한의 식별 정보(탈퇴 기록)를 보관할 수 있습니다.

학습 진도, 퀴즈 결과, 오각형 리포트, 캐릭터 상태, 시뮬레이션 기록, 인앱 재화 잔액 등 서비스 이용 데이터는 회원 탈퇴 즉시 완전히 삭제되며, 재가입하더라도 복구되지 않습니다.

4. 개인정보의 파기 절차 및 방법

전자적 파일 형태로 저장된 개인정보 및 학습 데이터는 기록을 재생하거나 복원할 수 없는 기술적 방법을 사용하여 완전히 삭제합니다.

5. 이용자의 권리와 행사 방법

이용자는 언제든지 서비스 내 설정 메뉴 또는 개인정보 보호책임자에게 이메일을 통해 본인의 개인정보(학습 데이터 포함) 조회, 수정, 삭제(회원 탈퇴)를 요청할 수 있습니다.

6. 개인정보 보호책임자 및 문의처

서비스는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 이용자의 개인정보 관련 문의 및 불만 처리를 위해 아래와 같이 소통 창구를 두고 있습니다.

담당자: 김동신
이메일: kdshin@freshmilk.kr
''';

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
                      _AppInfoCard(
                        item: _items[i],
                        scale: scale,
                        onTap: () => _handleItemTap(context, _items[i]),
                      ),
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

  void _handleItemTap(BuildContext context, _AppInfoItem item) {
    HapticFeedback.lightImpact();
    switch (item.action) {
      case _AppInfoAction.terms:
        _openLegalText(context, title: '이용약관', body: _termsText);
        return;
      case _AppInfoAction.privacy:
        _openLegalText(context, title: '개인정보처리방침', body: _privacyText);
        return;
      case _AppInfoAction.contact:
        _openSupportEmail(context);
        return;
    }
  }

  void _openLegalText(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LegalTextScreen(title: title, body: body),
      ),
    );
  }

  Future<void> _openSupportEmail(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: 'kdshin@freshmilk.kr');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _showContactFallback(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showContactFallback(context);
      }
    }
  }

  void _showContactFallback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('문의 이메일: kdshin@freshmilk.kr')),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard({
    required this.item,
    required this.scale,
    required this.onTap,
  });

  final _AppInfoItem item;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 73 * scale,
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppInfoTermsScreen.borderGrey,
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

class _LegalTextScreen extends StatelessWidget {
  const _LegalTextScreen({required this.title, required this.body});

  final String title;
  final String body;

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
                SizedBox(
                  height: 53 * scale,
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
                              Navigator.of(context).pop();
                            },
                            child: SizedBox(
                              width: 32 * scale,
                              height: 32 * scale,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 26 * scale,
                                color: AppInfoTermsScreen.iconGrey,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppInfoTermsScreen.brandInk,
                            height: 16 / 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      18 * scale,
                      24 * scale,
                      32 * scale,
                    ),
                    child: Text(
                      body.trim(),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w400,
                        color: AppInfoTermsScreen.textDark,
                        height: 1.65,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _AppInfoAction { terms, privacy, contact }

class _AppInfoItem {
  const _AppInfoItem({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final _AppInfoAction action;
}
