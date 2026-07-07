// lib/features/home/presentation/simulation_progress_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../data/simulation_api.dart';
import 'simulation_document_selection_screen.dart';

class SimulationProgressScreen extends StatelessWidget {
  const SimulationProgressScreen({
    super.key,
    required this.attemptId,
    required this.simulation,
    this.onBack,
    this.onBottomTabSelected,
  });

  final int attemptId;
  final SimulationSummary simulation;
  final VoidCallback? onBack;
  final ValueChanged<int>? onBottomTabSelected;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color iconGrey = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color tagGreen = Color(0xFF0DE593);
  static const Color tagBg = Color(0xFFF2FFFA);
  static const Color deadlineRed = Color(0xFFFF8897);

  static const List<_SimulationStep> _steps = [
    _SimulationStep(emoji: '📄', title: '서류 준비', period: 'D+1~7', number: '1'),
    _SimulationStep(emoji: '📝', title: '계약서 확인', period: 'D+8', number: '2'),
    _SimulationStep(emoji: '💰', title: '계약금 납부', period: 'D+8~14', number: '3'),
    _SimulationStep(emoji: '🏦', title: '중도금 대출', period: 'D+30~', number: '4'),
    _SimulationStep(emoji: '🔑', title: '잔금 & 등기', period: '입주일', number: '5'),
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
                _buildHeader(context, scale),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHero(scale),
                                SizedBox(height: 10 * scale),
                                _buildSituationSection(scale),
                                SizedBox(height: 10 * scale),
                                _buildStepsSection(scale),
                              ],
                            ),
                          ),
                        ),
                        _PrimaryActionButton(
                          label: '1단계 시작하기 →',
                          scale: scale,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SimulationDocumentSelectionScreen(attemptId: attemptId),
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
              '시뮬레이션 퀘스트',
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

  Widget _buildHero(double scale) {
    return Container(
      height: 179 * scale,
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        24 * scale,
        12 * scale,
        16 * scale,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            simulation.icon,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 40 * scale,
              fontWeight: FontWeight.w400,
              height: 48 / 40,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            simulation.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: themeGreen,
              height: 28 / 18,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            simulation.description.isEmpty ? '단계별로 직접 경험해보세요' : simulation.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: textDark,
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
                color: tagBg,
                borderRadius: BorderRadius.circular(30 * scale),
              ),
              child: Text(
                '부동산 · 심화',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: tagGreen,
                  height: 14 / 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSituationSection(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(label: '나의 상황', scale: scale),
        SizedBox(height: 10 * scale),
        Container(
          height: 117 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 14 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderGrey, width: 1 * scale),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SituationRow(label: '아파트', value: '경기도 하남시 감일 푸르지오 59m²', scale: scale),
              SizedBox(height: 9 * scale),
              _SituationRow(label: '분양가', value: '4억 2,000만원', scale: scale),
              SizedBox(height: 9 * scale),
              _SituationRow(label: '당첨일', value: '2026년 04월 20일', scale: scale),
              SizedBox(height: 9 * scale),
              _SituationRow(
                label: '계약 기한',
                value: '2026년 04월 28일 (D-0)',
                valueColor: deadlineRed,
                valueWeight: FontWeight.w600,
                scale: scale,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(label: '앞으로 경험할 5단계', scale: scale),
        SizedBox(height: 10 * scale),
        LayoutBuilder(
          builder: (context, constraints) {
            final rowScale = (constraints.maxWidth / 399).clamp(0.0, scale).toDouble();

            return Row(
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
                  _SimulationStepCard(step: _steps[i], scale: rowScale),
                  if (i != _steps.length - 1) ...[
                    SizedBox(width: 7 * rowScale),
                    _StepConnector(scale: rowScale),
                    SizedBox(width: 7 * rowScale),
                  ],
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _handleBottomTab(BuildContext context, EconoBottomTab tab) {
    final tabIndex = _indexForBottomTab(tab);
    if (onBottomTabSelected != null) {
      onBottomTabSelected!(tabIndex);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(tabIndex);
    } else {
      EconoBottomNavigationBar.goToRootTab(context, tab);
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.scale,
  });

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28 * scale,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: SimulationProgressScreen.brandInk,
            height: 19 / 16,
          ),
        ),
      ),
    );
  }
}

class _SituationRow extends StatelessWidget {
  const _SituationRow({
    required this.label,
    required this.value,
    required this.scale,
    this.valueColor = SimulationProgressScreen.textDark,
    this.valueWeight = FontWeight.w500,
  });

  final String label;
  final String value;
  final double scale;
  final Color valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 63 * scale,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationProgressScreen.textMuted,
              height: 14 / 12,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: valueWeight,
              color: valueColor,
              height: 14 / 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimulationStep {
  const _SimulationStep({
    required this.emoji,
    required this.title,
    required this.period,
    required this.number,
  });

  final String emoji;
  final String title;
  final String period;
  final String number;
}

class _SimulationStepCard extends StatelessWidget {
  const _SimulationStepCard({
    required this.step,
    required this.scale,
  });

  final _SimulationStep step;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        width: 66 * scale,
        height: 92 * scale,
        padding: EdgeInsets.fromLTRB(
          6 * scale,
          11 * scale,
          6 * scale,
          9 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: SimulationProgressScreen.borderGrey,
            width: 1 * scale,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 54 * scale,
              height: 14 * scale,
              child: Text(
                step.emoji,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            SizedBox(
              width: 54 * scale,
              height: 14 * scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  step.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w700,
                    color: SimulationProgressScreen.textDark,
                    height: 14 / 12,
                  ),
                ),
              ),
            ),
            SizedBox(height: 1 * scale),
            SizedBox(
              width: 54 * scale,
              height: 12 * scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  step.period,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w400,
                    color: SimulationProgressScreen.textLight,
                    height: 12 / 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            Container(
              width: 13 * scale,
              height: 13 * scale,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: SimulationProgressScreen.tagBg,
                shape: BoxShape.circle,
              ),
              child: Text(
                step.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 9 * scale,
                  fontWeight: FontWeight.w600,
                  color: SimulationProgressScreen.themeGreen,
                  height: 11 / 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(3.2 * scale, 6.4 * scale),
      painter: _StepConnectorPainter(scale: scale),
    );
  }
}

class _StepConnectorPainter extends CustomPainter {
  const _StepConnectorPainter({
    required this.scale,
  });

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SimulationProgressScreen.borderGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StepConnectorPainter oldDelegate) {
    return oldDelegate.scale != scale;
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
          color: SimulationProgressScreen.themeGreen,
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
