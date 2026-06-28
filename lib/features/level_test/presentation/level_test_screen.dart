// lib/features/level_test/presentation/level_test_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../../learning/data/learning_api.dart';
import '../data/level_test_api.dart';
import 'level_test_result_screen.dart';

class LevelTestScreen extends StatefulWidget {
  final String nickname;

  const LevelTestScreen({super.key, this.nickname = '경제왕'});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  static const Color _brandInk = Color(0xFF122711);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF9CA3AF);
  static const Color _themeGreen = Color(0xFF00EE94);
  static const Color _borderGrey = Color(0xFFD0D5E0);

  late final ApiClient _client;
  late final LevelTestApi _api;
  final TextEditingController _textController = TextEditingController();

  LevelTestStart? _test;
  LearningQuestion? _question;
  int _current = 1;
  int _total = 5;
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
    _api = LevelTestApi(_client);
    _startLevelTest();
  }

  @override
  void dispose() {
    _textController.dispose();
    _client.close();
    super.dispose();
  }

  Future<void> _startLevelTest() async {
    if (!AuthSession.hasAccessToken) {
      _goToLogin();
      return;
    }

    setState(() {
      _isLoading = true;
      _isSubmitting = false;
      _errorText = null;
      _selectedIndex = null;
      _textController.clear();
    });

    try {
      final test = await _api.create(questionCount: 5);
      if (!mounted) return;
      setState(() {
        _test = test;
        _question = test.firstQuestion;
        _current = 1;
        _total = test.questionCount <= 0 ? 5 : test.questionCount;
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
        _errorText = '레벨 테스트를 불러오지 못했어요.';
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
    final test = _test;
    final question = _question;
    if (test == null || question == null) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final result = await _api.submitAnswer(
        testId: test.testId,
        questionId: question.id,
        answer: answer,
      );
      if (!mounted) return;

      if (result.nextQuestion == null) {
        await _completeLevelTest(test.testId);
        return;
      }

      setState(() {
        _question = result.nextQuestion;
        _current = (result.progress.answered + 1).clamp(1, _total);
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

  Future<void> _completeLevelTest(int testId) async {
    try {
      final result = await _api.complete(testId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LevelTestResultScreen(
            score: result.scorePercent,
            nickname: widget.nickname,
            correctCount: result.correctCount,
            totalCount: result.totalCount,
            resultTitle: result.resultTitle,
            recommendedCategoryCode: result.recommendedCategoryCode,
          ),
        ),
      );
    } on ApiClientException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = '레벨 테스트 결과를 저장하지 못했어요.';
        _isSubmitting = false;
      });
    }
  }

  Future<bool> _showExitDialog() async {
    HapticFeedback.lightImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: _borderGrey),
          ),
          child: SizedBox(
            width: 335,
            height: 222,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(34, 22, 34, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 266,
                    height: 108,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 266,
                          height: 32,
                          child: Text(
                            '😢',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Noto Sans KR',
                              fontWeight: FontWeight.w400,
                              fontSize: 32,
                              height: 38 / 32,
                              color: _textDark,
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        SizedBox(
                          width: 266,
                          height: 62,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 266,
                                height: 26,
                                child: Text(
                                  '벌써 가시려고요?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    height: 26 / 18,
                                    color: _textDark,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                width: 266,
                                height: 32,
                                child: Text(
                                  '지금까지 배운 내용이 저장되지 않을 수 있어요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    height: 16 / 13,
                                    color: _textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 266,
                    height: 38,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 129,
                          height: 38,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(129, 38),
                              backgroundColor: const Color(0xFFF0F2F7),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              '나가기',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                height: 13 / 10,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 129,
                          height: 38,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(129, 38),
                              backgroundColor: _themeGreen,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              '계속 학습',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                height: 13 / 10,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth / 447.0;

    return WillPopScope(
      onWillPop: _showExitDialog,
      child: Scaffold(
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
            child: Center(child: CircularProgressIndicator(color: _themeGreen)),
          ),
        ],
      );
    }

    if (_errorText != null && _question == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(scale),
          Expanded(child: Center(child: _buildErrorText(scale))),
          _buildPrimaryButton('다시 불러오기', scale, _startLevelTest),
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
          const Expanded(child: Center(child: Text('레벨 테스트 문항이 없습니다.'))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(scale),
        SizedBox(height: 22 * scale),
        _buildProgress(scale),
        SizedBox(height: 28 * scale),
        _buildCategoryPill(question, scale),
        SizedBox(height: 36 * scale),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPrompt(question, scale),
                SizedBox(height: 22 * scale),
                if (_resourceText(question).isNotEmpty) _buildResourceCard(question, scale),
                if (_resourceText(question).isNotEmpty) SizedBox(height: 24 * scale),
                _buildAnswerArea(question, scale),
                if (_errorText != null) ...[
                  SizedBox(height: 14 * scale),
                  _buildErrorText(scale),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 20 * scale),
      ],
    );
  }

  Widget _buildHeader(double scale) {
    return SizedBox(
      height: 64 * scale,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final navigator = Navigator.of(context);
              final shouldPop = await _showExitDialog();
              if (shouldPop && mounted) navigator.pop();
            },
            child: SizedBox(
              width: 32 * scale,
              height: 32 * scale,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF6A7282),
                size: 20 * scale,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '레벨 테스트',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
                color: _brandInk,
                height: 28 / 20,
              ),
            ),
          ),
          SizedBox(width: 32 * scale),
        ],
      ),
    );
  }

  Widget _buildProgress(double scale) {
    return Column(
      children: [
        Row(
          children: List.generate(_total, (idx) {
            final isActive = idx < _current;
            return Expanded(
              child: Container(
                height: 4 * scale,
                margin: EdgeInsets.only(right: idx == _total - 1 ? 0 : 8 * scale),
                decoration: BoxDecoration(
                  color: isActive ? _themeGreen : const Color(0xFFE4E8F0),
                  borderRadius: BorderRadius.circular(16777216),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 14 * scale),
        Text(
          '$_current/$_total',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12 * scale,
            fontWeight: FontWeight.w400,
            color: _textMuted,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPill(LearningQuestion question, double scale) {
    return Center(
      child: Container(
        height: 48 * scale,
        constraints: BoxConstraints(maxWidth: 260 * scale),
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
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
            color: _themeGreen,
            height: 20 / 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPrompt(LearningQuestion question, double scale) {
    return Text(
      question.prompt.isEmpty ? '문제를 확인해주세요' : question.prompt,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: question.prompt.length > 80 ? 18 * scale : 24 * scale,
        fontWeight: FontWeight.w700,
        color: _textDark,
        height: 1.45,
      ),
    );
  }

  Widget _buildResourceCard(LearningQuestion question, double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: _borderGrey),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Text(
        _resourceText(question),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13 * scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4B5563),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildAnswerArea(LearningQuestion question, double scale) {
    if (question.isTheoryCard) {
      return _buildPrimaryButton(_isSubmitting ? '확인 중...' : '다음으로', scale, _isSubmitting ? null : () => _submitAnswer(const {}));
    }

    if (question.isChoice) {
      return Column(
        children: [
          for (int index = 0; index < question.choices.length; index++) ...[
            _buildChoiceButton(question.choices[index].text, index, scale),
            if (index != question.choices.length - 1) SizedBox(height: 12 * scale),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          enabled: !_isSubmitting,
          keyboardType: question.isNumberInput ? TextInputType.number : TextInputType.text,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: question.isNumberInput ? '숫자를 입력해주세요' : '답을 입력해주세요',
            hintStyle: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14 * scale,
              color: _textMuted,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: const BorderSide(color: _borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: const BorderSide(color: _borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scale),
              borderSide: BorderSide(color: _themeGreen, width: 2 * scale),
            ),
          ),
        ),
        SizedBox(height: 14 * scale),
        _buildPrimaryButton(_isSubmitting ? '확인 중...' : '제출하기', scale, _isSubmitting ? null : _submitTypedAnswer),
      ],
    );
  }

  Widget _buildChoiceButton(String text, int index, double scale) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isSubmitting ? null : () => _submitChoice(index),
      child: Container(
        constraints: BoxConstraints(minHeight: 64 * scale),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 12 * scale),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(
            color: isSelected ? _themeGreen : _borderGrey,
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
            color: _textDark,
            height: 26 / 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, double scale, VoidCallback? onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFD0D5E0) : _themeGreen,
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: _isSubmitting && onTap == null
            ? SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 20 / 16,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorText(double scale) {
    return Text(
      _errorText ?? '',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 13 * scale,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFF455D),
        height: 1.45,
      ),
    );
  }

  String _resourceText(LearningQuestion question) {
    return '${question.resource['text'] ?? ''}'.trim();
  }

  String _categoryText(LearningQuestion question) {
    final categoryCode = '${question.resource['categoryCode'] ?? ''}'.toUpperCase();
    final unitTitle = '${question.resource['unitTitle'] ?? ''}'.trim();
    final stageTitle = '${question.resource['stageTitle'] ?? ''}'.trim();
    final category = switch (categoryCode) {
      'ECONOMY' => '경제 상식',
      'SAVING' => '저축',
      'STOCK' => '주식',
      'REAL_ESTATE' => '부동산',
      'TAX' => '세금',
      _ => '경제 상식',
    };
    if (unitTitle.isNotEmpty) return '$category · $unitTitle';
    if (stageTitle.isNotEmpty) return '$category · $stageTitle';
    return category;
  }
}
