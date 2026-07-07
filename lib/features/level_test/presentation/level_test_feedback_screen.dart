import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LevelTestFeedbackScreen extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final String highlightText;
  final bool isLastQuestion;
  final VoidCallback onNext;
  final bool showRewardImpact;

  const LevelTestFeedbackScreen({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.highlightText,
    required this.isLastQuestion,
    required this.onNext,
    this.showRewardImpact = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = isCorrect ? const Color(0xFF0DE593) : const Color(0xFFFF7C1F);
    final Color bgColor = isCorrect ? const Color(0xFFF2FFFA) : const Color(0xFFFFF6F2);
    final String title = isCorrect ? '정답!' : '오답!';
    final IconData icon = isCorrect ? Icons.check_rounded : Icons.close_rounded;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Top Alert Box
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: mainColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: mainColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 11),
              
              // Explanation Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      '💡 해설',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      explanation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 1.43,
                      ),
                    ),
                    if (highlightText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        highlightText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.44,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!showRewardImpact)
                const SizedBox(height: 77)
              else if (isCorrect) ...[
                Container(
                  width: double.infinity,
                  height: 77,
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 79,
                    height: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FFFA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+10 XP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0DE593),
                        height: 15 / 14,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 77,
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 79,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6F2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFFF7C1F),
                              size: 12,
                            ),
                            SizedBox(width: 3),
                            Text(
                              '-1',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF7C1F),
                                height: 15 / 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '하트는 유닛당 카운트 됩니다.',
                        style: TextStyle(
                          fontFamily: 'Noto Sans KR',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFF7C1F),
                          height: 12 / 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              
              // Bottom Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00EE94),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context); // Pop feedback screen
                    onNext(); // Trigger next question
                  },
                  child: Text(
                    isLastQuestion ? '결과 확인하기 🎉' : (isCorrect ? '다음 문제' : '계속 하기'),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
