// lib/features/home/presentation/simulation_document_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import 'simulation_contract_review_screen.dart';

class SimulationDocumentSelectionScreen extends StatelessWidget {
  const SimulationDocumentSelectionScreen({
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
  static const Color wrongBg = Color(0xFFFFF6F2);
  static const Color wrongOrange = Color(0xFFFF7C1F);

  static const List<_DocumentChoice> _choices = [
    _DocumentChoice(
      title: '주민등록등본',
      subtitle: '세대원 전체 포함',
      state: _DocumentChoiceState.selected,
    ),
    _DocumentChoice(
      title: '가족관계증명서',
      subtitle: '청약 자격 확인용',
      state: _DocumentChoiceState.selected,
    ),
    _DocumentChoice(
      title: '근로소득 원천징수영수증',
      subtitle: '소득 증빙',
      state: _DocumentChoiceState.selected,
    ),
    _DocumentChoice(
      title: '여권 사본',
      subtitle: '❌ 계약 서류에 불필요',
      state: _DocumentChoiceState.wrong,
    ),
    _DocumentChoice(
      title: '건강보험료 납부확인서',
      subtitle: '소득 증빙 보조',
      state: _DocumentChoiceState.normal,
    ),
    _DocumentChoice(
      title: '인감증명서',
      subtitle: '계약서 서명용',
      state: _DocumentChoiceState.normal,
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
                        _DocumentQuestion(scale: scale),
                        SizedBox(height: 24 * scale),
                        _HintCard(scale: scale),
                        const Spacer(),
                        _PrimaryActionButton(
                          label: '확인! 다음 단계로 →',
                          scale: scale,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SimulationContractReviewScreen(),
                              ),
                            );
                            if (result is int && context.mounted) {
                              Navigator.of(context).pop(result);
                            }
                          },
                        ),
                        SizedBox(height: 31 * scale),
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
                    '1 / 5단계',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: textLight,
                      height: 16 / 12,
                    ),
                  ),
                  Text(
                    '서류 준비',
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
                        color: i == 0 ? themeGreen : inactiveProgress,
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
            color: SimulationDocumentSelectionScreen.themeGreen.withValues(alpha: 0.12),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '상황 D+1',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: SimulationDocumentSelectionScreen.themeGreen,
              height: 14 / 12,
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            '청약 당첨 후 7일 이내, 계약에 필요한\n서류를 준비해야 합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationDocumentSelectionScreen.textDark,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentQuestion extends StatelessWidget {
  const _DocumentQuestion({
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
              '🎯 아래 서류 목록에서 필요한 것을 모두 골라보세요',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: SimulationDocumentSelectionScreen.themeGreen,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        for (var row = 0; row < 3; row++) ...[
          Row(
            children: [
              Expanded(
                child: _DocumentChoiceButton(
                  choice: SimulationDocumentSelectionScreen._choices[row * 2],
                  scale: scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _DocumentChoiceButton(
                  choice: SimulationDocumentSelectionScreen._choices[row * 2 + 1],
                  scale: scale,
                ),
              ),
            ],
          ),
          if (row != 2) SizedBox(height: 12 * scale),
        ],
      ],
    );
  }
}

class _DocumentChoice {
  const _DocumentChoice({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final _DocumentChoiceState state;
}

enum _DocumentChoiceState {
  selected,
  wrong,
  normal,
}

class _DocumentChoiceButton extends StatelessWidget {
  const _DocumentChoiceButton({
    required this.choice,
    required this.scale,
  });

  final _DocumentChoice choice;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isSelected = choice.state == _DocumentChoiceState.selected;
    final isWrong = choice.state == _DocumentChoiceState.wrong;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 68 * scale,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
        decoration: BoxDecoration(
          color: isSelected
              ? SimulationDocumentSelectionScreen.selectedBg
              : isWrong
                  ? SimulationDocumentSelectionScreen.wrongBg
                  : Colors.white,
          border: Border.all(
            color: isSelected
                ? SimulationDocumentSelectionScreen.themeGreen
                : isWrong
                    ? SimulationDocumentSelectionScreen.wrongOrange
                    : SimulationDocumentSelectionScreen.borderGrey,
            width: (isSelected || isWrong) ? 2 * scale : 1 * scale,
          ),
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150 * scale,
              height: 21 * scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  choice.title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: SimulationDocumentSelectionScreen.textButton,
                    height: 21 / 14,
                  ),
                ),
              ),
            ),
            Text(
              choice.subtitle,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w400,
                color: SimulationDocumentSelectionScreen.textLight,
                height: 12 / 10,
              ),
            ),
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
        color: SimulationDocumentSelectionScreen.selectedBg,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '💡 잠깐!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: SimulationDocumentSelectionScreen.themeGreen,
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
                "'여권 사본'은 필요 없어요. 계약서엔 신분증 원본을 지참해야 합니다.",
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w400,
                  color: SimulationDocumentSelectionScreen.textMuted,
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
          color: SimulationDocumentSelectionScreen.themeGreen,
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
