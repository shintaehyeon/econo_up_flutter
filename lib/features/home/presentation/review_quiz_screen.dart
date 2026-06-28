// lib/features/home/presentation/review_quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../../learning/data/learning_api.dart';
import '../data/review_api.dart';
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
  late final ApiClient _client;
  late final ReviewApi _api;
  final TextEditingController _textController = TextEditingController();

  ReviewToday? _today;
  LearningQuestion? _question;
  int? _selectedIndex;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = ReviewApi(_client);
    _loadToday();
  }

  @override
  void dispose() {
    _textController.dispose();
    _client.close();
    super.dispose();
  }

  Future<void> _loadToday() async {
    if (!AuthSession.hasAccessToken) {
      _goToLogin();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
      _selectedIndex = null;
      _textController.clear();
    });

    try {
      final today = await _api.today();
      if (!mounted) return;
      if (today.question == null) {
        _today = today;
        await _completeReview();
        return;
      }
      setState(() {
        _today = today;
        _question = today.question;
        _isLoading = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _errorText = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = '복습 퀴즈를 불러오지 못했어요.';
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });
  }

  Future<void> _submitChoice(int index) async {
    final question = _question;
    if (question == null || _isSubmitting || index >= question.choices.length) return;
    setState(() => _selectedIndex = index);
    await _submitAnswer({'choiceIds': [question.choices[index].id]});
  }

  Future<void> _submitTypedAnswer() async {
    final question = _question;
    if (question == null || _isSubmitting) return;
    final value = _textController.text.trim();
    if (value.isEmpty) return;
    if (question.isNumberInput) {
      await _submitAnswer({'numberValue': num.tryParse(value.replaceAll(',', '')) ?? value});
    } else {
      await _submitAnswer({'answerText': value});
    }
  }

  Future<void> _submitAnswer(Map<String, dynamic> answer) async {
    final today = _today;
    final question = _question;
    if (today == null || question == null) return;

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);

    try {
      final result = await _api.submitAnswer(
        reviewSetId: today.reviewSetId,
        questionId: question.id,
        answer: answer,
      );
      if (!mounted) return;

      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      if (result.nextQuestion == null) {
        await _completeReview();
        return;
      }

      setState(() {
        _today = ReviewToday(
          reviewSetId: today.reviewSetId,
          status: today.status,
          progress: result.progress,
          question: result.nextQuestion,
        );
        _question = result.nextQuestion;
        _selectedIndex = null;
        _textController.clear();
        _isSubmitting = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _errorText = error.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = '답안을 제출하지 못했어요.';
        _isSubmitting = false;
      });
    }
  }

  Future<void> _completeReview() async {
    final today = _today;
    if (today != null) {
      try {
        await _api.complete(today.reviewSetId);
      } catch (_) {}
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReviewQuizCompleteScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 0),
              child: _buildBody(scale),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double scale) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(scale),
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: ReviewQuizScreen.themeGreen)),
          ),
        ],
      );
    }

    if (_errorText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(scale),
          Expanded(
            child: Center(
              child: Text(
                _errorText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: ReviewQuizScreen.textMuted,
                ),
              ),
            ),
          ),
          _buildRetryButton(scale),
          SizedBox(height: 24 * scale),
        ],
      );
    }

    final question = _question;
    if (question == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(scale),
          const Expanded(child: Center(child: Text('오늘 복습할 문제가 없어요.'))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(scale),
        SizedBox(height: 42 * scale),
        _buildProgress(scale),
        SizedBox(height: 34 * scale),
        _buildCategoryPill(question, scale),
        SizedBox(height: 96 * scale),
        Text(
          _eyebrowText(question),
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
          _titleText(question),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
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
          _metaText(question),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w400,
            color: ReviewQuizScreen.textMuted,
            height: 20 / 14,
          ),
        ),
        const Spacer(),
        _buildAnswerArea(question, scale),
        SizedBox(height: 24 * scale),
        _buildStreakBanner(scale),
        SizedBox(height: 24 * scale),
      ],
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
    final progress = _today?.progress;
    final current = (progress?.current ?? 1).clamp(1, progress?.total ?? 5);
    final total = progress?.total ?? 5;

    return Column(
      children: [
        Row(
          children: List.generate(total, (index) {
            final isActive = index < current;
            return Expanded(
              child: Container(
                height: 4 * scale,
                margin: EdgeInsets.only(right: index == total - 1 ? 0 : 8 * scale),
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
          '$current/$total',
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

  Widget _buildCategoryPill(LearningQuestion question, double scale) {
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
          _categoryText(question),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  Widget _buildAnswerArea(LearningQuestion question, double scale) {
    if (question.isTheoryCard) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isSubmitting ? null : () => _submitAnswer(const {}),
        child: Container(
          height: 60 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isSubmitting ? const Color(0xFFE5E7EB) : ReviewQuizScreen.themeGreen,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Text(
            _isSubmitting ? '확인 중...' : '다음으로',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 26 / 18,
            ),
          ),
        ),
      );
    }

    if (question.isChoice) {
      final choices = question.choices.take(4).toList();
      return Column(
        children: [
          for (int index = 0; index < choices.length; index++) ...[
            _buildAnswerButton(choices[index].text, index, scale),
            if (index != choices.length - 1) SizedBox(height: 12 * scale),
          ],
        ],
      );
    }

    return Column(
      children: [
        TextField(
          controller: _textController,
          enabled: !_isSubmitting,
          keyboardType: question.isNumberInput ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: question.isNumberInput ? '숫자를 입력해주세요' : '답을 입력해주세요',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10 * scale)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: ReviewQuizScreen.themeGreen, width: 2 * scale),
            ),
          ),
        ),
        SizedBox(height: 12 * scale),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _isSubmitting ? null : _submitTypedAnswer,
          child: Container(
            height: 52 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isSubmitting ? const Color(0xFFE5E7EB) : ReviewQuizScreen.themeGreen,
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Text(
              _isSubmitting ? '확인 중...' : '제출하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(String text, int index, double scale) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isSubmitting ? null : () => _submitChoice(index),
      child: Container(
        constraints: BoxConstraints(minHeight: 60 * scale),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
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
          textAlign: TextAlign.center,
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

  Widget _buildRetryButton(double scale) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _loadToday,
      child: Container(
        height: 52 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ReviewQuizScreen.themeGreen,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Text(
          '다시 불러오기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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

  String _eyebrowText(LearningQuestion question) {
    final resourceText = '${question.resource['text'] ?? ''}'.trim();
    if (resourceText.isNotEmpty && resourceText.length < 30) return resourceText;
    final stageTitle = '${question.resource['stageTitle'] ?? ''}'.trim();
    return stageTitle.isEmpty ? '다시 풀어볼 문제' : stageTitle;
  }

  String _titleText(LearningQuestion question) {
    final prompt = question.prompt.trim();
    if (prompt.isEmpty) return '문제를 확인해주세요';
    return prompt;
  }

  String _metaText(LearningQuestion question) {
    final stageTitle = '${question.resource['stageTitle'] ?? ''}'.trim();
    return stageTitle.isEmpty ? '복습 퀴즈' : '복습 · $stageTitle';
  }

  String _categoryText(LearningQuestion question) {
    final categoryCode = '${question.resource['categoryCode'] ?? ''}'.toUpperCase();
    final stageTitle = '${question.resource['stageTitle'] ?? ''}'.trim();
    final category = switch (categoryCode) {
      'ECONOMY' => '경제 상식',
      'SAVING' => '저축',
      'STOCK' => '주식',
      'REAL_ESTATE' => '부동산',
      'TAX' => '세금',
      _ => '경제 상식',
    };
    return stageTitle.isEmpty ? category : '$category · $stageTitle';
  }
}
