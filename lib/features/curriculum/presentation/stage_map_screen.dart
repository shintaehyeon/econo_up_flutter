import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/presentation/study_detail_screen.dart';

class StageMapScreen extends StatefulWidget {
  final String stageName;
  final String unitName;
  final String category; // '경제 상식' 또는 '저축'

  const StageMapScreen({
    super.key,
    required this.stageName,
    required this.unitName,
    required this.category,
  });

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color bgGrey = Color(0xFFF7F7F7);

  Color get themeColor => widget.category == '저축' ? const Color(0xFF00DAEE) : const Color(0xFF00EE94);
  Color get playColor => widget.category == '저축' ? const Color(0xFF00BECF) : const Color(0xFF1DDC83);
  Color get completedNodeShadowColor => widget.category == '저축' ? const Color(0x6600DAEE) : const Color(0x6600EE94);
  Color get activeCardShadowColor => widget.category == '저축' ? const Color(0x2E00DAEE) : const Color(0x2E00EE94);
  Color get topSummaryBorderColor => widget.category == '저축' ? const Color(0x4D00DAEE) : const Color(0x4D01EE94);
  Color get topSummaryShadowColor => widget.category == '저축' ? const Color(0x1400DAEE) : const Color(0x1400EE94);
  Color get questCardBgColor => widget.category == '저축' ? const Color(0x0D00DAEE) : const Color(0x0D00EE94);
  Color get questCardBorderColor => widget.category == '저축' ? const Color(0x6600DAEE) : const Color(0x6600EE94);

  late final List<SessionData> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = _getSessionDataForStage(widget.stageName);
  }

  List<SessionData> _getSessionDataForStage(String stageName) {
    // 1. Completed stages (all completed)
    if (stageName.contains('예적금의 기초')) {
      return [
        SessionData(id: 1, type: '이론', title: '예금과 적금의 차이', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '단리 vs 복리 계산', state: SessionState.completed),
        SessionData(id: 3, type: '연결', title: '적금 만기 시뮬레이션', state: SessionState.completed),
        SessionData(id: 4, type: '드릴', title: '과세 vs 비과세 혜택', state: SessionState.completed),
        SessionData(id: 5, type: '데이터', title: '우대 금리 조건 비교', state: SessionState.completed),
      ];
    } else if (stageName.contains('비상금 마련')) {
      return [
        SessionData(id: 1, type: '이론', title: '비상금의 규모 설정', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '비상금 통장 선택 기준', state: SessionState.completed),
        SessionData(id: 3, type: '연결', title: 'CMA vs 파킹통장 비교', state: SessionState.completed),
        SessionData(id: 4, type: '드릴', title: '월 생활비 기준 설정', state: SessionState.completed),
        SessionData(id: 5, type: '데이터', title: '금리 변동과 이자 분석', state: SessionState.completed),
      ];
    } else if (stageName.contains('통장 쪼개기')) {
      return [
        SessionData(id: 1, type: '이론', title: '4개의 통장 관리법', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '고정지출 vs 변동지출', state: SessionState.completed),
        SessionData(id: 3, type: '연결', title: '지출 예산 수립하기', state: SessionState.completed),
        SessionData(id: 4, type: '드릴', title: '비정기 지출 대비책', state: SessionState.completed),
        SessionData(id: 5, type: '데이터', title: '가계부 지출 비중 분석', state: SessionState.completed),
      ];
    } else if (stageName.contains('금리 비교하기')) {
      return [
        SessionData(id: 1, type: '이론', title: '공시 이자율의 이해', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '최고 금리 vs 기본 금리', state: SessionState.completed),
        SessionData(id: 3, type: '연결', title: '금융상품 한눈에 활용', state: SessionState.completed),
        SessionData(id: 4, type: '드릴', title: '실제 수령 이자 계산', state: SessionState.completed),
        SessionData(id: 5, type: '데이터', title: '은행별 예적금 금리 비교', state: SessionState.completed),
      ];
    } else if (stageName.contains('기준금리 기초')) {
      return [
        SessionData(id: 1, type: '이론', title: '기준금리란 무엇인가', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '한국은행의 역할', state: SessionState.completed),
        SessionData(id: 3, type: '연결', title: '금융통화위원회와 금리', state: SessionState.completed),
        SessionData(id: 4, type: '드릴', title: '기준금리 결정 요인', state: SessionState.completed),
        SessionData(id: 5, type: '데이터', title: '역대 기준금리 추이', state: SessionState.completed),
      ];
    } else if (stageName.contains('인플레이션')) {
      return [
        SessionData(id: 1, type: '이론', title: '인플레이션의 정의', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '화폐 가치 하락 체감', state: SessionState.completed),
        SessionData(id: 3, type: '연결', title: '물가 상승과 구매력', state: SessionState.completed),
        SessionData(id: 4, type: '드릴', title: '인플레이션 유형 구분', state: SessionState.completed),
        SessionData(id: 5, type: '데이터', title: '소비자물가지수 분석', state: SessionState.completed),
      ];
    }

    // 2. Active stages (Session 1 completed, Session 2 active, others locked)
    else if (stageName.contains('금리와 시장')) {
      return [
        SessionData(id: 1, type: '이론', title: '금리와 시장 개요', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '유리 vs 불리', state: SessionState.active),
        SessionData(id: 3, type: '연결', title: '금리 인상→소비 감소', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '금리↓ 시 오르는 자산', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '이자 계산하기', state: SessionState.locked),
      ];
    } else if (stageName.contains('주거래은행 혜택')) {
      return [
        SessionData(id: 1, type: '이론', title: '주거래은행 선정 기준', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '우대 혜택 요건 분석', state: SessionState.active),
        SessionData(id: 3, type: '연결', title: '급여 이체와 수수료 면제', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '환전 및 송금 우대율', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '신용 등급과 주거래 실적', state: SessionState.locked),
      ];
    } else if (stageName.contains('물가 관련 개념')) {
      return [
        SessionData(id: 1, type: '이론', title: '디플레이션 개요', state: SessionState.completed),
        SessionData(id: 2, type: '드릴', title: '물가 상승률 계산', state: SessionState.active),
        SessionData(id: 3, type: '연결', title: '원자재 가격과 물가', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '물가 안정 정책 효과', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '생산자물가지수 추이', state: SessionState.locked),
      ];
    }

    // 3. Locked stages (All locked)
    else if (stageName.contains('매파와 비둘기파')) {
      return [
        SessionData(id: 1, type: '이론', title: '매파와 비둘기파 유래', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '인물별 금리 성향 분류', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: 'FOMC 성명서 실전 분석', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '경제 지표로 성향 예측', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '성명서 키워드 빈도', state: SessionState.locked),
      ];
    } else if (stageName.contains('예금자보호제도')) {
      return [
        SessionData(id: 1, type: '이론', title: '예금자보호법 개요', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '보호 대상 금융회사', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '5천만원 한도 계산', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '이자 포함 보호 여부', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '금융기관 건전성 지표', state: SessionState.locked),
      ];
    } else if (stageName.contains('청년도약계좌')) {
      return [
        SessionData(id: 1, type: '이론', title: '청년도약계좌 가입 조건', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '정부 기여금 매칭 비율', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '5년 만기 예상 수령액', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '중도 해지 요건 분석', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '적금 상품 대비 이자비율', state: SessionState.locked),
      ];
    } else if (stageName.contains('청년주택드림')) {
      return [
        SessionData(id: 1, type: '이론', title: '청년주택드림 청약 개요', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '소득 및 무주택 요건', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '청약 당첨 시 대출 연계', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '납입 횟수와 가점 계산', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '지역별 분양가 대비 한도', state: SessionState.locked),
      ];
    } else if (stageName.contains('정부 지원 적금')) {
      return [
        SessionData(id: 1, type: '이론', title: '지자체 청년 적금 비교', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '희망두배 청년통장 요건', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '저축액 매칭 비율 분석', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '중도 탈락 방지 요건', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '정부 적금 누적 혜택 분석', state: SessionState.locked),
      ];
    } else if (stageName.contains('환율의 기초')) {
      return [
        SessionData(id: 1, type: '이론', title: '환율과 화폐 가치', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '원화 강세 vs 약세', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '여행 환전 타이밍', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '환전 수수료 우대 계산', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '일자별 환율 변동 추이', state: SessionState.locked),
      ];
    } else if (stageName.contains('환율과 무역')) {
      return [
        SessionData(id: 1, type: '이론', title: '수출입 기업과 환율', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '환율 상승 시 수혜 업종', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '해외 직구와 환율 관계', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '원자재 수입 비용 계산', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '무역 수지와 환율 통계', state: SessionState.locked),
      ];
    } else if (stageName.contains('기축통화와 안전자산')) {
      return [
        SessionData(id: 1, type: '이론', title: '달러의 패권과 기축통화', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '금과 달러의 상관관계', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '글로벌 위기 시 자산 배분', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '달러 인덱스 계산', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '주요 통화별 안전도 비교', state: SessionState.locked),
      ];
    } else if (stageName.contains('실생활 속 물가')) {
      return [
        SessionData(id: 1, type: '이론', title: '장바구니 물가와 체감 물가', state: SessionState.locked),
        SessionData(id: 2, type: '드릴', title: '생활물가지수 품목 구성', state: SessionState.locked),
        SessionData(id: 3, type: '연결', title: '외식비 변동과 소비 심리', state: SessionState.locked),
        SessionData(id: 4, type: '드릴', title: '슈링크플레이션 구별법', state: SessionState.locked),
        SessionData(id: 5, type: '데이터', title: '최근 1년 품목별 가격 변동', state: SessionState.locked),
      ];
    }

    // Default fallback
    return [
      SessionData(id: 1, type: '이론', title: '$stageName 개요', state: SessionState.completed),
      SessionData(id: 2, type: '드릴', title: '핵심 개념 훈련', state: SessionState.active),
      SessionData(id: 3, type: '연결', title: '실생활 연결 연습', state: SessionState.locked),
      SessionData(id: 4, type: '드릴', title: '적용 문제 풀이', state: SessionState.locked),
      SessionData(id: 5, type: '데이터', title: '데이터 종합 분석', state: SessionState.locked),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);
    final cardWidth = (contentWidth - 32).clamp(0.0, 416.0);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header
            _buildHeader(),
            // 2. Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: Container(
                    width: contentWidth,
                    color: bgGrey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Top Summary Card
                        _buildTopSummaryCard(cardWidth),
                        const SizedBox(height: 16),
                        // Session Path Container (Exactly 390px wide in Figma)
                        Container(
                          width: 390,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: _buildTimelineNodes(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Bottom Simulation Quest Card
                        _buildSimulationQuestCard(cardWidth),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 3. Bottom Tab Navigation
            _buildBottomNavigationBar(contentWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 41,
      color: bgGrey,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6A7282),
                size: 20,
              ),
            ),
          ),
          Text(
            widget.stageName,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: brandInk,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummaryCard(double width) {
    return Container(
      width: width,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: topSummaryBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: topSummaryShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.unitName,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.45,
              letterSpacing: 0.06,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.stageName,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 1.45,
              letterSpacing: -0.23,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineNodes() {
    final List<Widget> children = [];

    for (int i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      final bool isLeftNode = i % 2 == 0; // Alternates: Left Node, Right Node

      children.add(_buildSessionRow(session, isLeftNode));

      // Draw dotted connector if not the last session
      if (i < _sessions.length - 1) {
        final nextSession = _sessions[i + 1];
        final bool isGreenLine = session.state == SessionState.completed &&
            (nextSession.state == SessionState.completed || nextSession.state == SessionState.active);

        children.add(
          Container(
            width: 350,
            height: 38,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (idx) {
                  return Container(
                    width: 2,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isGreenLine ? themeColor : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(16777216),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      }
    }

    return children;
  }

  Widget _buildSessionRow(SessionData session, bool isLeftNode) {
    final double nodeSize = session.id == 1 ? 60 : 56;
    final double cardWidth = session.id == 1 ? 278 : 282;

    final nodeWidget = _buildNodeWidget(session, nodeSize);
    final cardWidget = _buildCardWidget(session, cardWidth);

    if (isLeftNode) {
      // Node on the Left, Card on the Right
      return SizedBox(
        width: 350,
        height: session.id == 1 ? 69 : 67,
        child: Row(
          children: [
            nodeWidget,
            const SizedBox(width: 12),
            Expanded(child: cardWidget),
          ],
        ),
      );
    } else {
      // Card on the Left, Node on the Right
      return SizedBox(
        width: 350,
        height: session.id == 1 ? 69 : 67,
        child: Row(
          children: [
            Expanded(child: cardWidget),
            const SizedBox(width: 12),
            nodeWidget,
          ],
        ),
      );
    }
  }

  Widget _buildNodeWidget(SessionData session, double size) {
    if (session.state == SessionState.completed) {
      // Completed node (theme color circle with star icon, checkmark badge)
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor,
              boxShadow: [
                BoxShadow(
                  color: completedNodeShadowColor,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          // Checkmark badge on top right
          Positioned(
            right: size == 60 ? -4 : -2,
            top: size == 60 ? -4 : -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '✓',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (session.state == SessionState.active) {
      // Active node (White circle with dashed theme border, play icon)
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _DashedCirclePainter(color: themeColor, strokeWidth: 2),
          child: Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: playColor,
              size: 24,
            ),
          ),
        ),
      );
    } else {
      // Locked node (Grey circle with lock icon)
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE5E7EB),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.lock_rounded,
          color: Color(0xFFCACACA),
          size: 18,
        ),
      );
    }
  }

  Widget _buildCardWidget(SessionData session, double width) {
    final bool isCompleted = session.state == SessionState.completed;
    final bool isActive = session.state == SessionState.active;

    Color badgeBg;
    Color badgeText;
    Color titleColor;
    Color descColor;
    Color cardBg;
    Border? cardBorder;
    List<BoxShadow>? cardShadow;

    if (isCompleted) {
      badgeBg = themeColor.withOpacity(0.15);
      badgeText = themeColor;
      titleColor = textMuted;
      descColor = brandInk;
      cardBg = Colors.white;
      cardBorder = Border.all(color: const Color(0xFFF0F0F0), width: 1);
      cardShadow = const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ];
    } else if (isActive) {
      badgeBg = themeColor.withOpacity(0.15);
      badgeText = themeColor;
      titleColor = textMuted;
      descColor = brandInk;
      cardBg = Colors.white;
      cardBorder = Border.all(color: const Color(0xFFF0F0F0), width: 1);
      cardShadow = const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ];
    } else {
      // Locked card
      badgeBg = const Color(0xFFF0F0F0);
      badgeText = const Color(0xFF9CA3AF);
      titleColor = const Color(0xFFC4C4C4);
      descColor = const Color(0xFF9CA3AF);
      cardBg = const Color(0xFFF3F4F6);
      cardBorder = null;
      cardShadow = null;
    }

    return GestureDetector(
      onTap: () => _handleSessionTap(session),
      child: Container(
        constraints: BoxConstraints(minHeight: session.id == 1 ? 69 : 67),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          border: cardBorder,
          boxShadow: cardShadow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                // Session Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(16777216),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    session.type,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Session Number
                Text(
                  'Session ${session.id}',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: titleColor,
                    height: 1.5,
                    letterSpacing: 0.11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              session.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: descColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSessionTap(SessionData session) {
    if (session.state == SessionState.locked) {
      return;
    }

    HapticFeedback.lightImpact();
    // Navigate to StudyDetailScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyDetailScreen(
          title: widget.category,
        ),
      ),
    );
  }

  Widget _buildSimulationQuestCard(double width) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 65),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: questCardBgColor,
        border: Border.all(color: questCardBorderColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            '🕹️ 시뮬레이션 퀘스트',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: brandInk,
              height: 1.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '스테이지 완료 후 해금',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.45,
              letterSpacing: 0.06,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(double width) {
    return Container(
      width: double.infinity,
      height: 77,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderLight, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 9, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem(idx: 0, icon: Icons.home_rounded, label: '홈', iconSize: 29),
          _buildTabItem(idx: 1, icon: Icons.menu_book_rounded, label: '학습', iconSize: 29),
          _buildTabItem(
            idx: 2,
            icon: Icons.assignment_rounded,
            label: '커넥트',
            width: 63.14,
            iconSize: 30,
          ),
          _buildTabItem(idx: 3, icon: Icons.show_chart_rounded, label: '배틀', iconSize: 31),
          _buildTabItem(idx: 4, icon: Icons.person_rounded, label: '마이', iconSize: 29),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int idx,
    required IconData icon,
    required String label,
    double width = 56,
    double iconSize = 29,
  }) {
    final bool isActive = idx == 1; // Stage Map is part of "학습" tab
    final Color itemColor = isActive ? const Color(0xFF626262) : const Color(0xFFBCBCBC);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (idx != 1) {
          // Pass idx back to CurriculmRoadmapScreen which will pop back to HomeScreen with the selected tab index
          Navigator.pop(context, idx);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: itemColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: itemColor,
                height: 16 / 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    const double dashWidth = 6.0;
    const double dashSpace = 4.0;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class SessionData {
  final int id;
  final String type; // '이론', '드릴', '연결', '데이터'
  final String title;
  final SessionState state;

  SessionData({
    required this.id,
    required this.type,
    required this.title,
    required this.state,
  });
}

enum SessionState {
  completed,
  active,
  locked,
}
