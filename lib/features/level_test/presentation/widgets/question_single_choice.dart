import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionSingleChoice extends StatelessWidget {
  final Map<String, dynamic> currentQ;
  final String? selectedAnswer;
  final bool isAnswered;
  final ValueChanged<String> onAnswerSelected;
  final String? correctAnswer;

  const QuestionSingleChoice({
    super.key,
    required this.currentQ,
    required this.selectedAnswer,
    required this.isAnswered,
    required this.onAnswerSelected,
    this.correctAnswer,
  });

  String _getCircleNumber(String choiceId) {
    switch (choiceId.toUpperCase()) {
      case 'A':
      case '1':
        return '①';
      case 'B':
      case '2':
        return '②';
      case 'C':
      case '3':
        return '③';
      case 'D':
      case '4':
        return '④';
      default:
        return choiceId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final choicesList = currentQ['choices'] as List;
    final bool isDrillStyle = choicesList.any((c) => (c as Map).containsKey('subtitle') && c['subtitle'] != null);

    return Column(
      children: [
        if (currentQ['resourceTitle'] != null &&
            currentQ['resourceText'] != null) ...[
          Text(
            currentQ['resourceTitle'] as String,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111827),
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            currentQ['resourceText'] as String,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
              height: 20 / 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
        Text(
          currentQ['subtitle'] as String,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDrillStyle ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
            height: 16 / 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          currentQ['prompt'] as String,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: isDrillStyle ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            height: (isDrillStyle ? 26 / 18 : 24 / 20),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (currentQ['categoryText'] != null)
          Text(
            currentQ['categoryText'] as String,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9CA3AF),
              height: 13 / 10,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 32),
        Column(
          children: List.generate((currentQ['choices'] as List).length, (
            choiceIdx,
          ) {
            final choice =
                (currentQ['choices'] as List)[choiceIdx] as Map<String, dynamic>;
            final choiceId = choice['id']!;
            final choiceText = choice['text']!;
            final choiceSubtitle = choice['subtitle'];
            final isSelected = selectedAnswer == choiceId;

            Color btnBg = const Color(0xFFFFFFFF);
            Color borderCol = const Color(0xFFD0D5E0);
            double borderW = 1.0;
            Color txtCol = isDrillStyle ? const Color(0xFF111827) : const Color(0xFF4B5563);
            FontWeight txtWeight = isDrillStyle ? FontWeight.w600 : FontWeight.w500;

            if (isAnswered) {
              if (choiceId == (correctAnswer ?? currentQ['answer'])) {
                btnBg = const Color(0xFFF2FFFA);
                borderCol = const Color(0xFF00EE94);
                borderW = 2.0;
                if (!isDrillStyle) {
                  txtCol = const Color(0xFF0DE593);
                  txtWeight = FontWeight.w700;
                }
              } else if (isSelected) {
                btnBg = const Color(0xFFFFF5F5);
                borderCol = const Color(0xFFEF4444);
                borderW = 2.0;
                if (!isDrillStyle) {
                  txtCol = const Color(0xFFEF4444);
                  txtWeight = FontWeight.w700;
                }
              }
            } else if (isSelected) {
              btnBg = const Color(0xFFF2FFFA);
              borderCol = const Color(0xFF00EE94);
              borderW = 2.0;
              if (!isDrillStyle) {
                txtCol = const Color(0xFF0DE593);
                txtWeight = FontWeight.w700;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: isAnswered
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onAnswerSelected(choiceId);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: btnBg,
                    border: Border.all(color: borderCol, width: borderW),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isDrillStyle
                                  ? '$choiceId. $choiceText'
                                  : '${_getCircleNumber(choiceId)} $choiceText',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: isDrillStyle ? 14 : 13,
                                fontWeight: txtWeight,
                                color: txtCol,
                                height: 16 / (isDrillStyle ? 14 : 13),
                              ),
                            ),
                            if (choiceSubtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                choiceSubtitle,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF9CA3AF),
                                  height: 14 / 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00EE94)
                              : const Color(0xFFD0D5E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
