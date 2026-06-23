// lib/features/home/presentation/simulation_contract_review_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'simulation_payment_screen.dart';

class SimulationContractReviewScreen extends StatelessWidget {
  const SimulationContractReviewScreen({
    super.key,
    this.onBottomTabSelected,
  });

  final ValueChanged<int>? onBottomTabSelected;

  static const Color textDark = Color(0xFF111827);
  static const Color textButton = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color inactiveProgress = Color(0xFFE4E8F0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color selectedBg = Color(0xFFF2FFFA);
  static const Color warningBg = Color(0xFFFFF6F2);
  static const Color warningOrange = Color(0xFFFF7C1F);
  static const Color contractTabBg = Color(0xFFF3F4F6);

  static const List<_ContractClause> _clauses = [
    _ContractClause(
      article: '제3조 계약금',
      content: '분양가의 10%를 계약 당일 납부',
      state: _ContractClauseState.normal,
    ),
    _ContractClause(
      article: '제5조 중도금',
      content: '6회 분할, 집단 대출 가능',
      state: _ContractClauseState.normal,
    ),
    _ContractClause(
      article: '제7조 입주일',
      content: '2028년 3월 예정 (변경 가능)',
      state: _ContractClauseState.warning,
      status: '⚠ 확인 필요',
    ),
    _ContractClause(
      article: '제9조 위약금',
      content: '계약 해제 시 계약금 전액 몰수',
      state: _ContractClauseState.warning,
      status: '⚠ 확인 필요',
    ),
    _ContractClause(
      article: '제11조 옵션',
      content: '발코니 확장 포함 (추가금 없음)',
      state: _ContractClauseState.safe,
      status: '정상',
    ),
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
                _buildProgressHeader(scale),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20 * scale),
                        _SituationCard(scale: scale),
                        SizedBox(height: 24 * scale),
                        _ContractQuestion(scale: scale),
                        SizedBox(height: 24 * scale),
                        _HintCard(scale: scale),
                        const Spacer(),
                        _PrimaryActionButton(
                          label: '위험 조항 확인 완료! →',
                          scale: scale,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SimulationPaymentScreen(),
                              ),
                            );
                            if (result is int && context.mounted) {
                              Navigator.of(context).pop(result);
                            }
                          },
                        ),
                        SizedBox(height: 28 * scale),
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

  Widget _buildProgressHeader(double scale) {
    return SizedBox(
      height: 53 * scale,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24 * scale,
          12 * scale,
          24 * scale,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 16 * scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '2 / 5단계',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: textLight,
                      height: 16 / 12,
                    ),
                  ),
                  Text(
                    '계약서 확인',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: textLight,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * scale),
            Row(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  Expanded(
                    child: Container(
                      height: 4 * scale,
                      decoration: BoxDecoration(
                        color: i < 2 ? themeGreen : inactiveProgress,
                        borderRadius: BorderRadius.circular(999 * scale),
                      ),
                    ),
                  ),
                  if (i != 4) SizedBox(width: 8 * scale),
                ],
              ],
            ),
          ],
        ),
      ),
    );
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

class _SituationCard extends StatelessWidget {
  const _SituationCard({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 99 * scale,
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        18 * scale,
        12 * scale,
        16 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF01EE94),
          width: 1 * scale,
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: SimulationContractReviewScreen.themeGreen.withValues(alpha: 0.12),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '상황 D+8 계약 당일',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: SimulationContractReviewScreen.themeGreen,
              height: 14 / 12,
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            '계약서를 받았습니다.\n서명 전 반드시 꼼꼼히 읽어야 합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationContractReviewScreen.textDark,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractQuestion extends StatelessWidget {
  const _ContractQuestion({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 18 * scale,
          child: Center(
            child: Text(
              '🎯 아래 계약서에서 이상한 조항을 찾아 탭 하세요',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: SimulationContractReviewScreen.themeGreen,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        Container(
          height: 23 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SimulationContractReviewScreen.contractTabBg,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Text(
            '분양 계약서 (요약본)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10 * scale,
              fontWeight: FontWeight.w600,
              color: SimulationContractReviewScreen.textButton,
              height: 15 / 10,
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        for (var i = 0; i < SimulationContractReviewScreen._clauses.length; i++) ...[
          _ContractClauseCard(
            clause: SimulationContractReviewScreen._clauses[i],
            scale: scale,
          ),
          if (i != SimulationContractReviewScreen._clauses.length - 1) SizedBox(height: 10 * scale),
        ],
      ],
    );
  }
}

class _ContractClause {
  const _ContractClause({
    required this.article,
    required this.content,
    required this.state,
    this.status,
  });

  final String article;
  final String content;
  final _ContractClauseState state;
  final String? status;
}

enum _ContractClauseState {
  normal,
  warning,
  safe,
}

class _ContractClauseCard extends StatelessWidget {
  const _ContractClauseCard({
    required this.clause,
    required this.scale,
  });

  final _ContractClause clause;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isWarning = clause.state == _ContractClauseState.warning;
    final isSafe = clause.state == _ContractClauseState.safe;
    final borderColor = isWarning
        ? SimulationContractReviewScreen.warningOrange
        : isSafe
            ? SimulationContractReviewScreen.themeGreen
            : SimulationContractReviewScreen.borderGrey;
    final backgroundColor = isWarning
        ? SimulationContractReviewScreen.warningBg
        : isSafe
            ? SimulationContractReviewScreen.selectedBg
            : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 53 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 9 * scale,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: (isWarning || isSafe) ? 2 * scale : 1 * scale,
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
                  SizedBox(
                    width: double.infinity,
                    height: 12 * scale,
                    child: Text(
                      clause.article,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w600,
                        color: SimulationContractReviewScreen.textLight,
                        height: 12 / 10,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 18 * scale,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        clause.content,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: SimulationContractReviewScreen.textButton,
                          height: 18 / 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (clause.status != null) ...[
              SizedBox(width: 10 * scale),
              Text(
                clause.status!,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: isWarning
                      ? SimulationContractReviewScreen.warningOrange
                      : SimulationContractReviewScreen.themeGreen,
                  height: 14 / 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58 * scale,
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      decoration: BoxDecoration(
        color: SimulationContractReviewScreen.selectedBg,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '💡 제7조 입주 예정일',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: SimulationContractReviewScreen.themeGreen,
              height: 18 / 12,
            ),
          ),
          SizedBox(height: 2 * scale),
          SizedBox(
            width: double.infinity,
            height: 17 * scale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "'예정'이란 단어가 있으면 지연 시 보상 조건을 꼭 확인하세요.",
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w400,
                  color: SimulationContractReviewScreen.textMuted,
                  height: 16 / 11,
                ),
              ),
            ),
          ),
        ],
      ),
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
          color: SimulationContractReviewScreen.themeGreen,
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
