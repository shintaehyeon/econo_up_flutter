// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'study_detail_screen.dart';
import 'streak_detail_screen.dart';
import 'heart_recharge_screen.dart';
import 'bill_purchase_center_screen.dart';
import 'news_feed_screen.dart';
import 'settings_screen.dart';
import 'my_page_screen.dart';
import 'interest_area_settings_screen.dart';
import 'simulation_quest_list_screen.dart';
import '../../curriculum/presentation/curriculum_roadmap_screen.dart';
import '../../social/presentation/battle_main_screen.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  final String nickname;

  const HomeScreen({super.key, this.nickname = '경제왕'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIdx = 0; // 0: 홈, 1: 학습, 2: 커넥트, 3: 배틀, 4: 마이
  bool _showBillPurchaseCenter = false;
  bool _showHeartRecharge = false;
  bool _showInterestAreaSettings = false;

  // 테마 색상 정의
  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color textMuted = Color(0xFF6A7282);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _buildCurrentTabBody()),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabBody() {
    if (_currentTabIdx == 1) {
      return _buildLearningTab();
    }

    if (_currentTabIdx == 2) {
      return NewsFeedScreen(
        onBottomTabSelected: (index) {
          setState(() {
            _currentTabIdx = index;
            if (index != 4) {
              _showBillPurchaseCenter = false;
            }
          });
        },
      );
    }

    if (_currentTabIdx == 4) {
      if (_showBillPurchaseCenter) {
        return BillPurchaseCenterScreen(
          onClose: () {
            setState(() {
              _showBillPurchaseCenter = false;
              _showHeartRecharge = true;
            });
          },
        );
      }

      if (_showHeartRecharge) {
        return HeartRechargeScreen(
          onClose: () {
            setState(() {
              _currentTabIdx = 0;
              _showBillPurchaseCenter = false;
              _showHeartRecharge = false;
            });
          },
          onOpenBillPurchaseCenter: () {
            setState(() {
              _showBillPurchaseCenter = true;
            });
          },
        );
      }

      if (_showInterestAreaSettings) {
        return InterestAreaSettingsScreen(
          showBottomNavigation: false,
          onBack: () {
            setState(() {
              _currentTabIdx = 0;
              _showInterestAreaSettings = false;
            });
          },
        );
      }

      return MyPageScreen(
        showBottomNavigation: false,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingsScreen(
                onBottomTabSelected: (index) {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentTabIdx = index;
                    _showBillPurchaseCenter = false;
                    _showHeartRecharge = false;
                  });
                },
              ),
            ),
          );
        },
        onBottomTabSelected: (index) {
          setState(() {
            _currentTabIdx = index;
            _showBillPurchaseCenter = false;
            _showHeartRecharge = false;
          });
        },
      );
    }

    if (_currentTabIdx == 3) {
      return BattleMainScreen(
        onBottomTabSelected: (index) {
          setState(() {
            _currentTabIdx = index;
          });
        },
      );
    }

    if (_currentTabIdx != 0) {
      return _buildPlaceholderTab();
    }

    return _buildHomeTab();
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildCustomTopHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStreakCard(),
                const SizedBox(height: 14),
                _buildGoldenTicketCard(),
                const SizedBox(height: 24),
                _buildLearningSection(),
                const SizedBox(height: 24),
                _buildBattleLeagueSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Figma-aligned Top Welcome Header Area
  Widget _buildCustomTopHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Econo-up" Title
              const Text(
                'Econo-up',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                  height: 32 / 24,
                ),
              ),
              // Asset Pills (Heart & Cash)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAssetPill(
                    iconPath: 'assets/heart_vector',
                    iconColor: const Color(0xFFFF7C7C),
                    value: '3',
                    onTap: () {
                      setState(() {
                        _currentTabIdx = 4;
                        _showHeartRecharge = true;
                        _showBillPurchaseCenter = false;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildAssetPill(
                    iconPath: 'assets/cash_vector',
                    iconColor: const Color(0xFFA1E669),
                    value: '5',
                    onTap: () {
                      setState(() {
                        _currentTabIdx = 4;
                        _showBillPurchaseCenter = true;
                        _showHeartRecharge = false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Heading 2: Welcome dynamic nickname message
          Text(
            '${widget.nickname} 님, 환영해요!',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 32 / 22,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '오늘부터 경제 공부를 시작해볼까요?',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A7282),
              height: 16 / 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper asset pill
  Widget _buildAssetPill({
    required String iconPath,
    required Color iconColor,
    required String value,
    VoidCallback? onTap,
  }) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconColor == const Color(0xFFFF7C7C)
                ? Icons.favorite_rounded
                : Icons.payments_rounded,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB2B2B2),
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return pill;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: pill,
    );
  }

  // Card 1: 1일 연속 학습 중 Card
  Widget _buildStreakCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StreakDetailScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF4ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF6900),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '1일 연속 학습 중',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: brandInk,
                      height: 20 / 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '오늘 첫 학습을 시작했어요! 내일도 와요 💪',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 2: Golden Ticket Card (inactive state)
  Widget _buildGoldenTicketCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0x66FEFCE8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_num_rounded,
              color: Color(0x66FCD31F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '골든 티켓',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC0C0C0),
                    height: 20 / 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '아직 골든 티켓이 도착하지 않았어요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD0D0D0),
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Text(
              '매일 오전 도착',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6A7282),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Learning Section
  Widget _buildLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '학습하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: brandInk,
                letterSpacing: -0.44,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentTabIdx = 4;
                  _showInterestAreaSettings = true;
                  _showBillPurchaseCenter = false;
                  _showHeartRecharge = false;
                });
              },
              child: const Icon(
                Icons.settings_rounded,
                color: Color(0xFFB2B2B2),
                size: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF2FFFA),
            border: Border.all(color: themeGreen, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '아직 학습 내역이 없어요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: brandInk,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '추천 콘텐츠로 첫 학습을 시작해보세요!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _currentTabIdx = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '추천 콘텐츠 학습하러 가기 →',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card 4: Battle League Section
  Widget _buildBattleLeagueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '배틀 리그',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: brandInk,
            letterSpacing: -0.44,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.emoji_events_rounded,
                          color: themeGreen,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '브론즈 리그',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: brandInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '퀴즈 배틀을 통해 리그를 점령하세요!',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _currentTabIdx = 3;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '퀴즈 배틀 바로가기 →',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLearningTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: const Color(0xFFF7F7F7),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: const Text(
            '학습',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 32 / 24,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '카테고리를 선택해 학습을 시작하세요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                      height: 18 / 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const designWidth = 408.0;
                    const designHeight = 655.75;
                    final scale = (constraints.maxWidth / designWidth).clamp(0.0, 1.0).toDouble();

                    return SizedBox(
                      height: designHeight * scale,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            width: 196 * scale,
                            height: 221 * scale,
                            child: _buildLearningCategoryCard(
                              scale: scale,
                              emoji: '📚',
                              title: '경제 상식',
                              subtitle: '금리·물가·환율',
                              progress: 0.6,
                              buttonLabel: '학습하기',
                              buttonColor: const Color(0x2600EE94),
                              buttonTextColor: const Color(0xFF00C97D),
                            ),
                          ),
                          Positioned(
                            left: 212 * scale,
                            top: 0,
                            width: 196 * scale,
                            height: 221 * scale,
                            child: _buildLearningCategoryCard(
                              scale: scale,
                              emoji: '💰',
                              title: '저축',
                              subtitle: '현금관리·은행·청년',
                              progress: 0.3,
                              buttonLabel: '학습하기',
                              buttonColor: const Color(0x2600EE94),
                              buttonTextColor: const Color(0xFF00C97D),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 235 * scale,
                            width: 196 * scale,
                            height: 203 * scale,
                            child: _buildLearningLockedCard(
                              scale: scale,
                              title: '주식',
                              subtitle: '주식·ETF·투자심리',
                            ),
                          ),
                          Positioned(
                            left: 212 * scale,
                            top: 235 * scale,
                            width: 196 * scale,
                            height: 203 * scale,
                            child: _buildLearningLockedCard(
                              scale: scale,
                              title: '부동산',
                              subtitle: '전월세·청약·매매',
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 452 * scale,
                            width: 196 * scale,
                            height: 204 * scale,
                            child: _buildLearningLockedCard(
                              scale: scale,
                              title: '세금',
                              subtitle: '소득세·연말정산',
                            ),
                          ),
                          Positioned(
                            left: 212 * scale,
                            top: 452 * scale,
                            width: 196 * scale,
                            height: 205 * scale,
                            child: _buildLearningCategoryCard(
                              scale: scale,
                              customIcon: JoystickIcon(
                                size: 46 * scale,
                                color: const Color(0xFFA1E669),
                              ),
                              title: '시뮬레이션 도전',
                              subtitle: '오늘 배운 내용으로 실전 체험!',
                              buttonLabel: '도전하기',
                              buttonColor: const Color(0xFFEEFFD1),
                              buttonTextColor: const Color(0xFF7BD134),
                              showProgress: false,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SimulationQuestListScreen(),
                                  ),
                                );
                                if (result is int && mounted) {
                                  setState(() {
                                    _currentTabIdx = result;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningCategoryCard({
    required double scale,
    String? emoji,
    IconData? icon,
    Widget? customIcon,
    Color iconColor = brandInk,
    required String title,
    required String subtitle,
    double progress = 0,
    required String buttonLabel,
    required Color buttonColor,
    required Color buttonTextColor,
    bool showProgress = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap();
          return;
        }
        if (title == '경제 상식' || title == '저축') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CurriculumRoadmapScreen(
                title: title,
              ),
            ),
          );
          if (result is int) {
            setState(() {
              _currentTabIdx = result;
            });
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudyDetailScreen(
                title: title,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(12 * scale, 24 * scale, 12 * scale, 16 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0x12000000),
              blurRadius: 12 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 64 * scale,
              height: 64 * scale,
              child: Center(
                child: customIcon ??
                    (emoji != null
                        ? Text(
                            emoji,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 46 * scale,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          )
                        : Icon(icon, color: iconColor, size: 46 * scale)),
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15 * scale,
                fontWeight: FontWeight.w700,
                color: brandInk,
                height: 19 / 15,
                letterSpacing: -0.23 * scale,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
                height: 15 / 10,
                letterSpacing: 0.12 * scale,
              ),
            ),
            if (showProgress) ...[
              SizedBox(height: 14 * scale),
              _buildLearningProgressBar(progress, scale),
              SizedBox(height: 11 * scale),
            ] else
              const Spacer(),
            _buildLearningPillButton(
              scale: scale,
              label: buttonLabel,
              backgroundColor: buttonColor,
              textColor: buttonTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningLockedCard({
    required double scale,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        if (title == '주식' || title == '부동산' || title == '세금') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CurriculumRoadmapScreen(
                title: title,
              ),
            ),
          );
          if (result is int) {
            setState(() {
              _currentTabIdx = result;
            });
          }
        }
      },
      child: Opacity(
        opacity: 0.65,
        child: Container(
          padding: EdgeInsets.fromLTRB(12 * scale, 24 * scale, 12 * scale, 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0x12000000),
                blurRadius: 12 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64 * scale,
                height: 64 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: const Color(0xFFB0B0B0),
                  size: 26 * scale,
                ),
              ),
              SizedBox(height: 12 * scale),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC0C0C0),
                  height: 19 / 15,
                  letterSpacing: -0.23 * scale,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD0D0D0),
                  height: 15 / 10,
                  letterSpacing: 0.12 * scale,
                ),
              ),
              const Spacer(),
              _buildLearningPillButton(
                scale: scale,
                label: '잠금',
                backgroundColor: const Color(0xFFF0F0F0),
                textColor: const Color(0xFFC0C0C0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningProgressBar(double progress, double scale) {
    return SizedBox(
      width: 148 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4 * scale),
        child: Container(
          width: 140 * scale,
          height: 6 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16777216),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 6 * scale,
              decoration: BoxDecoration(
                color: themeGreen,
                borderRadius: BorderRadius.circular(16777216),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearningPillButton({
    required double scale,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: 148 * scale,
      height: 35 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13 * scale,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 20 / 13,
          letterSpacing: -0.08 * scale,
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab() {
    final labels = ['홈', '학습', '커넥트', '배틀', '마이'];
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Text(
        labels[_currentTabIdx],
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: brandInk,
          height: 32 / 24,
        ),
      ),
    );
  }

  // Pinned Bottom Navigation Tab Bar
  Widget _buildBottomNavigationBar() {
    return EconoBottomNavigationBar(
      activeTab: _bottomTabForIndex(_currentTabIdx),
      onTabSelected: (tab) {
        setState(() {
          _currentTabIdx = _indexForBottomTab(tab);
          _showBillPurchaseCenter = false;
          _showHeartRecharge = false;
        });
      },
    );
  }

  EconoBottomTab _bottomTabForIndex(int index) {
    switch (index) {
      case 1:
        return EconoBottomTab.learning;
      case 2:
        return EconoBottomTab.connect;
      case 3:
        return EconoBottomTab.battle;
      case 4:
        return EconoBottomTab.my;
      default:
        return EconoBottomTab.home;
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

class JoystickIcon extends StatelessWidget {
  final double size;
  final Color color;

  const JoystickIcon({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: JoystickIconPainter(color: color),
    );
  }
}

class JoystickIconPainter extends CustomPainter {
  final Color color;

  JoystickIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final factor = size.width / 46.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (3.5 * factor).clamp(2.2, 3.5)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = 23.0 * factor;

    // 1. Circle at the top
    final circleCenter = Offset(cx, 11.0 * factor);
    final circleRadius = 5.7 * factor;
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // 2. Base plate (top diamond)
    final topD = Offset(cx, 20.0 * factor);
    final leftD = Offset(9.0 * factor, 27.0 * factor);
    final bottomD = Offset(cx, 34.0 * factor);
    final rightD = Offset(37.0 * factor, 27.0 * factor);

    final pathTop = Path()
      ..moveTo(topD.dx, topD.dy)
      ..lineTo(leftD.dx, leftD.dy)
      ..lineTo(bottomD.dx, bottomD.dy)
      ..lineTo(rightD.dx, rightD.dy)
      ..close();
    canvas.drawPath(pathTop, paint);

    // 3. Base plate (3D depth below)
    final depth = 7.0 * factor;
    final pathDepth = Path()
      ..moveTo(leftD.dx, leftD.dy)
      ..lineTo(leftD.dx, leftD.dy + depth)
      ..lineTo(bottomD.dx, bottomD.dy + depth)
      ..lineTo(rightD.dx, rightD.dy + depth)
      ..lineTo(rightD.dx, rightD.dy);
    canvas.drawPath(pathDepth, paint);

    // Draw the vertical corner line in the middle-bottom
    canvas.drawLine(bottomD, Offset(bottomD.dx, bottomD.dy + depth), paint);

    // 4. Joystick Stem/Stick
    final stemTop = Offset(cx, 16.7 * factor); // Bottom of circle (11.0 + 5.7 = 16.7)
    final stemBottom = Offset(cx, 27.0 * factor); // Center of top diamond
    canvas.drawLine(stemTop, stemBottom, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
