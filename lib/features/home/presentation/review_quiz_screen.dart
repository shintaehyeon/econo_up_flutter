// lib/features/home/presentation/review_quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'review_quiz_complete_screen.dart';

class ReviewQuizScreen extends StatefulWidget {
  const ReviewQuizScreen({super.key});

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color borderGrey = Color(0xFFD0D5E0);

  @override
  State<ReviewQuizScreen> createState() => _ReviewQuizScreenState();
}

class _ReviewQuizScreenState extends State<ReviewQuizScreen> {
  int _currentIndex = 1;
  int? _selectedIndex;

  static const List<_ReviewQuestion> _questions = [
    _ReviewQuestion(
      eyebrow: '금리가 오를 때',
      title: '예금 이자는?',
      meta: '기준금리 기초 · Stage 1',
      answers: ['오른다', '내려간다'],
    ),
    _ReviewQuestion(
      eyebrow: '물가가 계속 오르면',
      title: '돈의 가치는?',
      meta: '인플레이션 기초 · Stage 1',
      answers: ['낮아진다', '높아진다'],
    ),
    _ReviewQuestion(
      eyebrow: '분산 투자의 목적은',
      title: '위험을?',
      meta: '투자 기초 · Stage 1',
      answers: ['줄인다', '키운다'],
    ),
    _ReviewQuestion(
      eyebrow: '저축을 먼저 하면',
      title: '소비 관리는?',
      meta: '저축 기초 · Stage 1',
      answers: ['쉬워진다', '어려워진다'],
    ),
    _ReviewQuestion(
      eyebrow: '예산을 세우면',
      title: '지출 흐름을?',
      meta: '소비 기초 · Stage 1',
      answers: ['확인할 수 있다', '숨길 수 있다'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;
    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(scale),
                  SizedBox(height: 42 * scale),
                  _buildProgress(scale),
                  SizedBox(height: 34 * scale),
                  _buildCategoryPill(scale),
                  SizedBox(height: 116 * scale),
                  Text(
                    question.eyebrow,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w400,
                      color: ReviewQuizScreen.textMuted,
                      height: 28 / 20,
                    ),
                  ),
                  Text(
                    question.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.w700,
                      color: ReviewQuizScreen.textDark,
                      height: 38 / 28,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    question.meta,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      color: ReviewQuizScreen.textMuted,
                      height: 20 / 14,
                    ),
                  ),
                  SizedBox(height: 166 * scale),
                  _buildAnswerButton(question.answers[0], 0, scale),
                  SizedBox(height: 12 * scale),
                  _buildAnswerButton(question.answers[1], 1, scale),
                  const Spacer(),
                  _buildStreakBanner(scale),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return SizedBox(
      height: 64 * scale,
      child: Row(
        children: [
          Text(
            '복습 퀴즈',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24 * scale,
              fontWeight: FontWeight.w700,
              color: ReviewQuizScreen.brandInk,
              height: 32 / 24,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: SizedBox(
              width: 32 * scale,
              height: 32 * scale,
              child: Icon(
                Icons.close_rounded,
                color: const Color(0xFF6A7282),
                size: 30 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(double scale) {
    return Column(
      children: [
        Row(
          children: List.generate(_questions.length, (index) {
            final isActive = index <= _currentIndex;
            return Expanded(
              child: Container(
                height: 4 * scale,
                margin: EdgeInsets.only(right: index == _questions.length - 1 ? 0 : 8 * scale),
                decoration: BoxDecoration(
                  color: isActive ? ReviewQuizScreen.themeGreen : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(16777216),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 29 * scale),
        Text(
          '${_currentIndex + 1}/${_questions.length}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: ReviewQuizScreen.textMuted,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPill(double scale) {
    return Center(
      child: Container(
        height: 50 * scale,
        padding: EdgeInsets.symmetric(horizontal: 28 * scale),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF2FFFA),
          borderRadius: BorderRadius.circular(16777216),
        ),
        child: Text(
          '경제 상식 · 금리',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: ReviewQuizScreen.themeGreen,
            height: 20 / 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String text, int index, double scale) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = index;
        });

        Future<void>.delayed(const Duration(milliseconds: 120), () {
          if (!mounted) {
            return;
          }

          if (_currentIndex == _questions.length - 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewQuizCompleteScreen(),
              ),
            );
            return;
          }

          setState(() {
            _currentIndex += 1;
            _selectedIndex = null;
          });
        });
      },
      child: Container(
        height: 60 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(
            color: isSelected ? ReviewQuizScreen.themeGreen : ReviewQuizScreen.borderGrey,
            width: isSelected ? 2 * scale : 1 * scale,
          ),
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
            color: ReviewQuizScreen.textDark,
            height: 26 / 18,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBanner(double scale) {
    return Container(
      height: 52 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EB),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 18 * scale,
                color: const Color(0xFFFF6900),
              ),
              SizedBox(width: 4 * scale),
              Text(
                '14일 연속 학습 중!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: ReviewQuizScreen.brandInk,
                  height: 24 / 18,
                ),
              ),
            ],
          ),
          Text(
            '오늘도 퀴즈 풀고 연속 학습 유지하자!',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12 * scale,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A7282),
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewQuestion {
  const _ReviewQuestion({
    required this.eyebrow,
    required this.title,
    required this.meta,
    required this.answers,
  });

  final String eyebrow;
  final String title;
  final String meta;
  final List<String> answers;
}
