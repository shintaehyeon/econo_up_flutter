// lib/features/home/presentation/simulation_settlement_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../data/simulation_api.dart';
import 'simulation_complete_screen.dart';

class SimulationSettlementScreen extends StatefulWidget {
  const SimulationSettlementScreen({
    super.key,
    required this.attemptId,
    this.onBottomTabSelected,
    this.initialSalePriceManwon = 42000,
    this.initialAcquisitionTaxRate = 1.5,
  });

  final int attemptId;
  final ValueChanged<int>? onBottomTabSelected;
  final int initialSalePriceManwon;
  final double initialAcquisitionTaxRate;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textButton = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color inactiveProgress = Color(0xFFE4E8F0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color selectedBg = Color(0xFFF2FFFA);
  static const Color orange = Color(0xFFFF7C1F);

  static const List<_PaymentStatus> _paymentStatuses = [
    _PaymentStatus(label: '계약금 (10%)', amount: '4,200만원', completed: true),
    _PaymentStatus(label: '중도금 (60%)', amount: '2억 5,200만원', completed: true),
    _PaymentStatus(label: '잔금 (30%) ← 지금!', amount: '1억 2,600만원', completed: false),
  ];

  static const List<String> _registrationSteps = [
    '법무사\n선임',
    '등기 신청\n서류 준비',
    '등기소\n접수',
    '소유권\n이전 완료',
  ];

  @override
  State<SimulationSettlementScreen> createState() => _SimulationSettlementScreenState();
}

class _SimulationSettlementScreenState extends State<SimulationSettlementScreen> {
  late final TextEditingController _expectedTaxController;
  late final FocusNode _expectedTaxFocusNode;

  @override
  void initState() {
    super.initState();
    _expectedTaxController = TextEditingController();
    _expectedTaxFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _expectedTaxController.dispose();
    _expectedTaxFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;
    final bottomButtonGap = screenHeight < 870 ? 28.0 : 62.0;

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
                        _PaymentStatusSection(scale: scale),
                        SizedBox(height: 20 * scale),
                        _TaxCalculationSection(
                          scale: scale,
                          salePriceText: _formatManwon(widget.initialSalePriceManwon.toDouble()),
                          taxRateText: '1주택 기준 1~3%',
                          expectedTaxController: _expectedTaxController,
                          expectedTaxFocusNode: _expectedTaxFocusNode,
                          expectedTaxHintText: '예: 약 $_calculatedExpectedTaxText',
                        ),
                        SizedBox(height: 20 * scale),
                        _RegistrationProcessSection(scale: scale),
                        SizedBox(height: bottomButtonGap * scale),
                        _PrimaryActionButton(
                          label: '잔금 납부 & 등기 완료! →',
                          scale: scale,
                          onTap: _submitAndComplete,
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
    final tabIndex = _indexForBottomTab(tab);
    if (widget.onBottomTabSelected != null) {
      widget.onBottomTabSelected!(tabIndex);
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

  String get _calculatedExpectedTaxText {
    final estimatedTaxManwon = widget.initialSalePriceManwon * widget.initialAcquisitionTaxRate / 100;
    return _formatManwon(estimatedTaxManwon);
  }

  Future<void> _submitAndComplete() async {
    HapticFeedback.lightImpact();
    final value = _parseManwon(_expectedTaxController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예상 취득세를 만원 단위 숫자로 입력해주세요. 예: 630')),
      );
      return;
    }

    final client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    final api = SimulationApi(client);
    try {
      final answerData = await api.submitAnswer(
        attemptId: widget.attemptId,
        stepNo: 5,
        answer: {'numberValue': value},
      );
      final feedback = _asMap(answerData['feedback']);
      if (feedback['correct'] != true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('취득세 계산값을 다시 확인해주세요.')),
        );
        return;
      }

      final completeData = await api.complete(widget.attemptId);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SimulationCompleteScreen(
            xpGained: _asInt(completeData['xpGained'], fallback: 200),
            badge: '${completeData['badge'] ?? '내 집 마련 완료'}',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시뮬레이션 완료 저장에 실패했어요.')),
      );
    } finally {
      client.close();
    }
  }

  int? _parseManwon(String text) {
    final normalized = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  static String _formatManwon(double value) {
    final rounded = value.round();
    if (rounded >= 10000) {
      final eok = rounded ~/ 10000;
      final manwon = rounded % 10000;
      if (manwon == 0) {
        return '$eok억원';
      }
      return '$eok억 ${_formatNumber(manwon)}만원';
    }
    return '${_formatNumber(rounded)}만원';
  }

  static String _formatNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
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
                    '5 / 5단계',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: SimulationSettlementScreen.textLight,
                      height: 16 / 12,
                    ),
                  ),
                  Text(
                    '잔금 & 등기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: SimulationSettlementScreen.textLight,
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
                        color: SimulationSettlementScreen.themeGreen,
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
            color: SimulationSettlementScreen.themeGreen.withValues(alpha: 0.12),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '상황 2028년 3월 — 입주 2주 전',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: SimulationSettlementScreen.themeGreen,
              height: 14 / 12,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            '드디어 입주일이 다가왔습니다.\n잔금을 납부하고 소유권을 등기해야 합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationSettlementScreen.textDark,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusSection extends StatelessWidget {
  const _PaymentStatusSection({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TitledSection(
      title: '전체 납부 현황',
      scale: scale,
      child: Container(
        height: 93 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: SimulationSettlementScreen.borderGrey,
            width: 1 * scale,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < SimulationSettlementScreen._paymentStatuses.length; i++) ...[
              _PaymentStatusRow(
                status: SimulationSettlementScreen._paymentStatuses[i],
                scale: scale,
              ),
              if (i != SimulationSettlementScreen._paymentStatuses.length - 1) SizedBox(height: 11 * scale),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusRow extends StatelessWidget {
  const _PaymentStatusRow({
    required this.status,
    required this.scale,
  });

  final _PaymentStatus status;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final labelColor = status.completed ? SimulationSettlementScreen.themeGreen : SimulationSettlementScreen.orange;

    return SizedBox(
      height: 15 * scale,
      child: Row(
        children: [
          Expanded(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: labelColor,
                height: 14 / 12,
              ),
            ),
          ),
          Text(
            status.amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationSettlementScreen.textDark,
              height: 14 / 12,
            ),
          ),
          SizedBox(width: 12 * scale),
          SizedBox(
            width: 12 * scale,
            child: Text(
              status.completed ? '✓' : '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                color: SimulationSettlementScreen.themeGreen,
                height: 15 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxCalculationSection extends StatelessWidget {
  const _TaxCalculationSection({
    required this.scale,
    required this.salePriceText,
    required this.taxRateText,
    required this.expectedTaxController,
    required this.expectedTaxFocusNode,
    required this.expectedTaxHintText,
  });

  final double scale;
  final String salePriceText;
  final String taxRateText;
  final TextEditingController expectedTaxController;
  final FocusNode expectedTaxFocusNode;
  final String expectedTaxHintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 18 * scale,
          child: Center(
            child: Text(
              '🎯 취득세를 직접 계산해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: SimulationSettlementScreen.themeGreen,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        Container(
          height: 107 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 18 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: SimulationSettlementScreen.borderGrey,
              width: 1 * scale,
            ),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TaxInfoRow(
                label: '분양가',
                value: salePriceText,
                scale: scale,
              ),
              SizedBox(height: 11 * scale),
              _TaxInfoRow(
                label: '취득세율',
                value: taxRateText,
                scale: scale,
              ),
              SizedBox(height: 11 * scale),
              _TaxInputRow(
                label: '예상 취득세',
                controller: expectedTaxController,
                focusNode: expectedTaxFocusNode,
                hintText: expectedTaxHintText,
                scale: scale,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaxInfoRow extends StatelessWidget {
  const _TaxInfoRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 214 * scale,
      height: 16 * scale,
      child: Row(
        children: [
          SizedBox(
            width: 84 * scale,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationSettlementScreen.textMuted,
                height: 14 / 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationSettlementScreen.textDark,
                height: 14 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxInputRow extends StatelessWidget {
  const _TaxInputRow({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.scale,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 214 * scale,
      height: 14 * scale,
      child: Row(
        children: [
          SizedBox(
            width: 84 * scale,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationSettlementScreen.textMuted,
                height: 14 / 12,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,억만원약\s]')),
              ],
              cursorColor: SimulationSettlementScreen.themeGreen,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationSettlementScreen.textDark,
                height: 14 / 12,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: SimulationSettlementScreen.textLight,
                  height: 14 / 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationProcessSection extends StatelessWidget {
  const _RegistrationProcessSection({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TitledSection(
      title: '소유권 등기 절차',
      scale: scale,
      child: Container(
        height: 69 * scale,
        padding: EdgeInsets.fromLTRB(
          10 * scale,
          8 * scale,
          18 * scale,
          8 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          border: Border.all(
            color: SimulationSettlementScreen.borderGrey,
            width: 1 * scale,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < SimulationSettlementScreen._registrationSteps.length; i++) ...[
              _RegistrationStepItem(
                number: i + 1,
                label: SimulationSettlementScreen._registrationSteps[i],
                scale: scale,
              ),
              if (i != SimulationSettlementScreen._registrationSteps.length - 1) ...[
                SizedBox(width: 10 * scale),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14 * scale,
                  color: SimulationSettlementScreen.borderGrey,
                ),
                SizedBox(width: 10 * scale),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RegistrationStepItem extends StatelessWidget {
  const _RegistrationStepItem({
    required this.number,
    required this.label,
    required this.scale,
  });

  final int number;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52 * scale,
      height: 53 * scale,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18 * scale,
            height: 18 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SimulationSettlementScreen.selectedBg,
              borderRadius: BorderRadius.circular(999 * scale),
            ),
            child: Text(
              number.toString(),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10 * scale,
                fontWeight: FontWeight.w600,
                color: SimulationSettlementScreen.themeGreen,
                height: 12 / 10,
              ),
            ),
          ),
          SizedBox(height: 3 * scale),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            strutStyle: StrutStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              height: 14 / 12,
              forceStrutHeight: true,
            ),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationSettlementScreen.textButton,
              height: 14 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitledSection extends StatelessWidget {
  const _TitledSection({
    required this.title,
    required this.scale,
    required this.child,
  });

  final String title;
  final double scale;
  final Widget child;

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
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: SimulationSettlementScreen.brandInk,
                height: 19 / 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        child,
      ],
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
          color: SimulationSettlementScreen.themeGreen,
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

class _PaymentStatus {
  const _PaymentStatus({
    required this.label,
    required this.amount,
    required this.completed,
  });

  final String label;
  final String amount;
  final bool completed;
}
