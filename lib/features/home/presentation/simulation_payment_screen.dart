// lib/features/home/presentation/simulation_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../data/simulation_api.dart';
import 'simulation_loan_screen.dart';

class SimulationPaymentScreen extends StatefulWidget {
  const SimulationPaymentScreen({
    super.key,
    required this.attemptId,
    this.onBottomTabSelected,
    this.initialPaymentAmount = '',
  });

  final int attemptId;
  final ValueChanged<int>? onBottomTabSelected;
  final String initialPaymentAmount;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textButton = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color lineGrey = Color(0xFFD9DDE6);
  static const Color inactiveProgress = Color(0xFFE4E8F0);
  static const Color inputBg = Color(0xFFF3F4F6);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color selectedBg = Color(0xFFF2FFFA);

  static const List<_PaymentMethod> _methods = [
    _PaymentMethod(
      title: '🏦 은행 계좌이체',
      subtitle: '가장 일반적. 계약 당일 즉시 처리.',
      selected: true,
    ),
    _PaymentMethod(
      title: '💳 가상계좌 입금',
      subtitle: '분양사에서 발급. 수수료 없음.',
      selected: false,
    ),
    _PaymentMethod(
      title: '🤝 자기앞수표',
      subtitle: '대면 계약 시 사용. 사전 발급 필요.',
      selected: false,
    ),
  ];

  @override
  State<SimulationPaymentScreen> createState() => _SimulationPaymentScreenState();
}

class _SimulationPaymentScreenState extends State<SimulationPaymentScreen> {
  late final TextEditingController _paymentAmountController;
  late final FocusNode _paymentAmountFocusNode;

  @override
  void initState() {
    super.initState();
    _paymentAmountController = TextEditingController(text: widget.initialPaymentAmount);
    _paymentAmountFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _paymentAmountFocusNode.dispose();
    super.dispose();
  }

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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      18 * scale,
                      24 * scale,
                      14 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SituationCard(scale: scale),
                        SizedBox(height: 14 * scale),
                        _CalculationSection(scale: scale),
                        SizedBox(height: 10 * scale),
                        _AmountInput(
                          scale: scale,
                          controller: _paymentAmountController,
                          focusNode: _paymentAmountFocusNode,
                          onInputTap: _focusPaymentAmount,
                        ),
                        SizedBox(height: 12 * scale),
                        _PaymentMethodSection(scale: scale),
                        SizedBox(height: 14 * scale),
                        _HintCard(scale: scale),
                        SizedBox(height: 6 * scale),
                        _PrimaryActionButton(
                          label: '납부 완료! 다음 단계로 →',
                          scale: scale,
                          onTap: _submitAndContinue,
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

  void _focusPaymentAmount() {
    HapticFeedback.lightImpact();
    _paymentAmountFocusNode.requestFocus();
    _paymentAmountController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _paymentAmountController.text.length,
    );
  }

  Future<void> _submitAndContinue() async {
    HapticFeedback.lightImpact();
    final value = _parseManwon(_paymentAmountController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계약금을 만원 단위 숫자로 입력해주세요. 예: 4200')),
      );
      return;
    }

    final client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    final api = SimulationApi(client);
    try {
      final data = await api.submitAnswer(
        attemptId: widget.attemptId,
        stepNo: 3,
        answer: {'numberValue': value},
      );
      final feedback = _asMap(data['feedback']);
      if (feedback['correct'] != true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('계산값을 다시 확인해주세요.')),
        );
        return;
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SimulationLoanScreen(attemptId: widget.attemptId),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시뮬레이션 답안 저장에 실패했어요.')),
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
                    '3 / 5단계',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: SimulationPaymentScreen.textLight,
                      height: 16 / 12,
                    ),
                  ),
                  Text(
                    '계약금 납부',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: SimulationPaymentScreen.textLight,
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
                        color: i < 3 ? SimulationPaymentScreen.themeGreen : SimulationPaymentScreen.inactiveProgress,
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
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
}

class _SituationCard extends StatelessWidget {
  const _SituationCard({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94 * scale,
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        16 * scale,
        12 * scale,
        14 * scale,
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
            color: SimulationPaymentScreen.themeGreen.withValues(alpha: 0.12),
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
              color: SimulationPaymentScreen.themeGreen,
              height: 14 / 12,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            '계약서 서명 완료!\n이제 계약금을 납부해야 합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationPaymentScreen.textDark,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculationSection extends StatelessWidget {
  const _CalculationSection({
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
              '계약금 직접 계산해보기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: SimulationPaymentScreen.brandInk,
                height: 19 / 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        Container(
          height: 97 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 14 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: SimulationPaymentScreen.borderGrey,
              width: 1 * scale,
            ),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalculationRow(label: '분양가', value: '4억 2,000만원', scale: scale),
              SizedBox(height: 10 * scale),
              _CalculationRow(label: '계약금 비율', value: '10%', scale: scale),
              SizedBox(height: 10 * scale),
              _CalculationRow(
                label: '납부해야 할 계약금',
                value: '분양가 4.2억 × 10% = 4,200만원',
                scale: scale,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalculationRow extends StatelessWidget {
  const _CalculationRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 113 * scale,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: SimulationPaymentScreen.textMuted,
              height: 14 / 12,
            ),
          ),
        ),
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: SimulationPaymentScreen.textDark,
                height: 14 / 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.onInputTap,
  });

  final double scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onInputTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: 34 * scale,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: SimulationPaymentScreen.lineGrey,
                    width: 1 * scale,
                  ),
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                cursorColor: SimulationPaymentScreen.themeGreen,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: SimulationPaymentScreen.textDark,
                  height: 20 / 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: '계약금을 입력하세요',
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: SimulationPaymentScreen.textLight,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 6 * scale),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onInputTap,
            child: Container(
              width: 42 * scale,
              height: 20 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SimulationPaymentScreen.inputBg,
                borderRadius: BorderRadius.circular(40 * scale),
              ),
              child: Text(
                '입력',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: SimulationPaymentScreen.textMuted,
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

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
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
              '🎯 계약금 납부 방법을 선택하세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: SimulationPaymentScreen.themeGreen,
                height: 18 / 12,
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        for (var i = 0; i < SimulationPaymentScreen._methods.length; i++) ...[
          _PaymentMethodCard(
            method: SimulationPaymentScreen._methods[i],
            scale: scale,
          ),
          if (i != SimulationPaymentScreen._methods.length - 1) SizedBox(height: 8 * scale),
        ],
      ],
    );
  }
}

class _PaymentMethod {
  const _PaymentMethod({
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final bool selected;
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.scale,
  });

  final _PaymentMethod method;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: HapticFeedback.lightImpact,
      child: Container(
        height: 49 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: method.selected ? SimulationPaymentScreen.selectedBg : Colors.white,
          border: Border.all(
            color: method.selected ? SimulationPaymentScreen.themeGreen : SimulationPaymentScreen.borderGrey,
            width: method.selected ? 2 * scale : 1 * scale,
          ),
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 17 * scale,
              child: Text(
                method.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: SimulationPaymentScreen.textButton,
                  height: 17 / 14,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 11 * scale,
              child: Text(
                method.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w600,
                  color: SimulationPaymentScreen.textLight,
                  height: 11 / 10,
                ),
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
      height: 54 * scale,
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      decoration: BoxDecoration(
        color: SimulationPaymentScreen.selectedBg,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '✅ 계좌이체 선택!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: SimulationPaymentScreen.themeGreen,
              height: 18 / 12,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            '영수증(이체 확인증)은 반드시 보관하세요.',
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11 * scale,
              fontWeight: FontWeight.w400,
              color: SimulationPaymentScreen.textMuted,
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
          color: SimulationPaymentScreen.themeGreen,
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
