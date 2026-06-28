// lib/features/home/presentation/simulation_loan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../data/simulation_api.dart';
import 'simulation_settlement_screen.dart';

class SimulationLoanScreen extends StatelessWidget {
  const SimulationLoanScreen({
    super.key,
    required this.attemptId,
    this.onBottomTabSelected,
  });

  final int attemptId;
  final ValueChanged<int>? onBottomTabSelected;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textButton = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color inactiveProgress = Color(0xFFE4E8F0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color selectedBg = Color(0xFFF2FFFA);
  static const Color middlePaymentBlue = Color(0xFF00DAEE);
  static const Color balancePurple = Color(0xFF8F3EFF);

  static const List<_LoanComparisonRow> _comparisonRows = [
    _LoanComparisonRow(
      label: '금리',
      groupLoan: '시중 최저금리\n(은행 협약)',
      personalLoan: '개인 신용도 반영\n(더 높을 수 있음)',
    ),
    _LoanComparisonRow(
      label: '한도',
      groupLoan: '중도금 전액',
      personalLoan: '소득·자산 심사',
    ),
    _LoanComparisonRow(
      label: '편의성',
      groupLoan: '분양사가 은행 연계\n→ 서류 간편',
      personalLoan: '직접 은행 방문\n심사 필요',
    ),
    _LoanComparisonRow(
      label: '추천',
      groupLoan: '⭐️ 대부분 선택',
      personalLoan: '특수한 경우만',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;
    final bottomButtonGap = screenHeight < 870 ? 24.0 : 56.0;

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
                _ProgressHeader(scale: scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      31 * scale,
                      24 * scale,
                      14 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SituationCard(scale: scale),
                        SizedBox(height: 20 * scale),
                        _PaymentStructureSection(scale: scale),
                        SizedBox(height: 20 * scale),
                        _LoanComparisonSection(scale: scale),
                        SizedBox(height: 20 * scale),
                        _HintCard(scale: scale),
                        SizedBox(height: bottomButtonGap * scale),
                        _PrimaryActionButton(
                          label: '대출 신청 완료! 다음 단계로 →',
                          scale: scale,
                          onTap: () => _submitAndContinue(context),
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

  Future<void> _submitAndContinue(BuildContext context) async {
    HapticFeedback.lightImpact();
    final client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    final api = SimulationApi(client);
    try {
      await api.submitAnswer(
        attemptId: attemptId,
        stepNo: 4,
        answer: const {'choiceIds': ['A']},
      );
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SimulationSettlementScreen(attemptId: attemptId),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시뮬레이션 답안 저장에 실패했어요.')),
      );
    } finally {
      client.close();
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
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
                    '4 / 5단계',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: SimulationLoanScreen.textLight,
                      height: 16 / 12,
                    ),
                  ),
                  Text(
                    '중도금 대출',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: SimulationLoanScreen.textLight,
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
                        color: i < 4 ? SimulationLoanScreen.themeGreen : SimulationLoanScreen.inactiveProgress,
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
            color: SimulationLoanScreen.themeGreen.withValues(alpha: 0.12),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '상황 D+60 두 달 뒤',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: SimulationLoanScreen.themeGreen,
              height: 14 / 12,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            '이제 중도금(분양가의 60%)을 6회 분할로\n납부해야 합니다. 대출을 알아볼 시간.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationLoanScreen.textDark,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStructureSection extends StatelessWidget {
  const _PaymentStructureSection({
    required this.scale,
  });

  final double scale;

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
              '중도금 구조 한눈에 보기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: SimulationLoanScreen.brandInk,
                height: 19 / 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        Container(
          height: 46 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: SimulationLoanScreen.borderGrey,
              width: 1 * scale,
            ),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 50,
                child: _PaymentStructureSegment(
                  label: '계약금',
                  color: SimulationLoanScreen.themeGreen,
                  scale: scale,
                ),
              ),
              Expanded(
                flex: 210,
                child: _PaymentStructureSegment(
                  label: '중도금',
                  color: SimulationLoanScreen.middlePaymentBlue,
                  scale: scale,
                ),
              ),
              Expanded(
                flex: 106,
                child: _PaymentStructureSegment(
                  label: '잔금',
                  color: SimulationLoanScreen.balancePurple,
                  scale: scale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentStructureSegment extends StatelessWidget {
  const _PaymentStructureSegment({
    required this.label,
    required this.color,
    required this.scale,
  });

  final String label;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 10 * scale,
            fontWeight: FontWeight.w500,
            color: SimulationLoanScreen.textLight,
            height: 12 / 10,
          ),
        ),
        SizedBox(height: 6 * scale),
        Container(
          height: 6 * scale,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999 * scale),
          ),
        ),
      ],
    );
  }
}

class _LoanComparisonSection extends StatelessWidget {
  const _LoanComparisonSection({
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
              '🎯 두 가지 대출 방식의 차이를 비교해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: SimulationLoanScreen.themeGreen,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        SizedBox(
          height: 209 * scale,
          child: Table(
            border: TableBorder.all(
              color: SimulationLoanScreen.borderGrey,
              width: 1 * scale,
            ),
            columnWidths: const {
              0: FlexColumnWidth(134),
              1: FlexColumnWidth(134),
              2: FlexColumnWidth(133),
            },
            children: [
              _buildTableRow(
                scale: scale,
                height: 33 * scale,
                label: '항목',
                groupLoan: '집단 대출',
                personalLoan: '개별 대출',
                isHeader: true,
              ),
              for (final row in SimulationLoanScreen._comparisonRows)
                _buildTableRow(
                  scale: scale,
                  height: 44 * scale,
                  label: row.label,
                  groupLoan: row.groupLoan,
                  personalLoan: row.personalLoan,
                ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow({
    required double scale,
    required double height,
    required String label,
    required String groupLoan,
    required String personalLoan,
    bool isHeader = false,
  }) {
    return TableRow(
      children: [
        _LoanTableCell(
          text: label,
          height: height,
          scale: scale,
          isHeader: isHeader,
        ),
        _LoanTableCell(
          text: groupLoan,
          height: height,
          scale: scale,
          isHeader: isHeader,
          isSelectedColumn: !isHeader,
          textColor: isHeader ? SimulationLoanScreen.textButton : SimulationLoanScreen.themeGreen,
        ),
        _LoanTableCell(
          text: personalLoan,
          height: height,
          scale: scale,
          isHeader: isHeader,
        ),
      ],
    );
  }
}

class _LoanTableCell extends StatelessWidget {
  const _LoanTableCell({
    required this.text,
    required this.height,
    required this.scale,
    this.isHeader = false,
    this.isSelectedColumn = false,
    this.textColor,
  });

  final String text;
  final double height;
  final double scale;
  final bool isHeader;
  final bool isSelectedColumn;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      color: isSelectedColumn ? SimulationLoanScreen.selectedBg : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: (isHeader ? 12 : 11) * scale,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
          color: textColor ?? SimulationLoanScreen.textButton,
          height: isHeader ? 18 / 12 : 14 / 11,
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
        color: SimulationLoanScreen.selectedBg,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '✅ 집단 대출 신청!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: SimulationLoanScreen.themeGreen,
              height: 18 / 12,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            '분양사를 통해 은행과 일괄 계약 → 6회 자동 납부 설정 완료',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11 * scale,
              fontWeight: FontWeight.w400,
              color: SimulationLoanScreen.textMuted,
              height: 16 / 11,
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
          color: SimulationLoanScreen.themeGreen,
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

class _LoanComparisonRow {
  const _LoanComparisonRow({
    required this.label,
    required this.groupLoan,
    required this.personalLoan,
  });

  final String label;
  final String groupLoan;
  final String personalLoan;
}
