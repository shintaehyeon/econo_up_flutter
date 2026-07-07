import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../../curriculum/presentation/stage_complete_screen.dart';
import '../../level_test/presentation/level_test_feedback_screen.dart';
import '../data/learning_api.dart';

class LearningSessionScreen extends StatefulWidget {
  const LearningSessionScreen({
    super.key,
    required this.sessionId,
    required this.categoryTitle,
    this.resume = true,
    this.stageSessionIds = const <int>[],
  });

  final int sessionId;
  final String categoryTitle;
  final bool resume;
  final List<int> stageSessionIds;

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  late final ApiClient _client;
  late final LearningApi _api;
  final TextEditingController _answerTextController = TextEditingController();
  final List<TextEditingController> _answerPartControllers = <TextEditingController>[];

  late int _sessionId;
  late List<int> _stageSessionIds;
  late int _stageSessionIndex;
  int? _attemptId;
  LearningQuestion? _question;
  LearningProgress? _progress;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  final Set<String> _selectedChoiceIds = <String>{};
  List<String> _orderedItemIds = <String>[];

  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color borderGrey = Color(0xFFD0D5E0);

  @override
  void initState() {
    super.initState();
    _sessionId = widget.sessionId;
    _stageSessionIds = widget.stageSessionIds.where((id) => id > 0).toList();
    if (_stageSessionIds.isEmpty || !_stageSessionIds.contains(_sessionId)) {
      _stageSessionIds = <int>[_sessionId];
    }
    _stageSessionIndex = _stageSessionIds.indexOf(_sessionId);
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = LearningApi(_client);
    _answerTextController.addListener(() {
      if (mounted) setState(() {});
    });
    _startAttempt();
  }

  @override
  void dispose() {
    _answerTextController.dispose();
    _disposeAnswerPartControllers();
    _client.close();
    super.dispose();
  }

  Future<void> _startAttempt() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!AuthSession.hasAccessToken) {
      setState(() {
        _isLoading = false;
        _errorMessage = '로그인이 필요해요. 테스트 로그인 후 다시 시도해주세요.';
      });
      return;
    }

    try {
      final result = await _api.startAttempt(_sessionId, resume: widget.resume);
      if (!mounted) return;
      setState(() {
        _attemptId = result.attemptId;
        _progress = result.progress;
        _question = result.question;
        _resetInput(result.question);
        _isLoading = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        _goToLogin();
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = _userFacingMessage(error.message);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '학습 세션을 불러오지 못했어요. 다시 시도해주세요.';
      });
    }
  }

  void _resetInput(LearningQuestion question) {
    _selectedChoiceIds.clear();
    _answerTextController.clear();
    _setAnswerPartControllers(_answerPartCount(question));
    _orderedItemIds = _initialOrder(question);
  }

  List<String> _initialOrder(LearningQuestion question) {
    final payloadItems = question.payload['items'];
    if (payloadItems is List && payloadItems.isNotEmpty) {
      return payloadItems.map((item) {
        if (item is Map && item['id'] != null) return '${item['id']}';
        return '$item';
      }).toList();
    }
    return question.choices.map((choice) => choice.id).where((id) => id.isNotEmpty).toList();
  }

  bool get _canSubmit {
    final question = _question;
    if (question == null || _isSubmitting) return false;
    if (question.isTheoryCard) return true;
    if (question.isChoice) return _selectedChoiceIds.isNotEmpty;
    if (question.isOrdering) return _orderedItemIds.isNotEmpty;
    if (_usesCommaSeparatedParts(question)) {
      return _answerPartControllers.every((controller) => controller.text.trim().isNotEmpty);
    }
    if (question.isNumberInput || question.isTextInput) {
      return _answerTextController.text.trim().isNotEmpty;
    }
    return false;
  }

  Future<void> _submitAnswer() async {
    final attemptId = _attemptId;
    final question = _question;
    if (attemptId == null || question == null || !_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _api.submitAnswer(
        attemptId: attemptId,
        questionId: question.id,
        answer: _answerPayload(question),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showFeedback(result);
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        _goToLogin();
        return;
      }
      setState(() {
        _isSubmitting = false;
        _errorMessage = _userFacingMessage(error.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = '답안을 제출하지 못했어요. 다시 시도해주세요.';
      });
    }
  }

  Map<String, dynamic> _answerPayload(LearningQuestion question) {
    if (question.isTheoryCard) return <String, dynamic>{};
    if (question.isChoice) {
      return {'choiceIds': _selectedChoiceIds.toList()};
    }
    if (question.isOrdering) {
      return {'orderedItemIds': _orderedItemIds};
    }
    if (_usesCommaSeparatedParts(question)) {
      final text = _commaSeparatedAnswerText();
      return {'answerText': text, 'rawText': text, 'text': text};
    }
    if (question.isNumberInput) {
      final raw = _answerTextController.text.trim().replaceAll(',', '');
      final parsed = num.tryParse(raw);
      return parsed == null ? {'answerText': raw, 'rawText': raw} : {'numberValue': parsed};
    }
    final text = _answerTextController.text.trim();
    return {'answerText': text, 'rawText': text, 'text': text};
  }

  void _showFeedback(LearningAnswerResult result) {
    final feedback = result.feedback;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LevelTestFeedbackScreen(
          isCorrect: feedback.isCorrect,
          explanation: _localizeDisplayText(feedback.explanation),
          highlightText: _localizeDisplayText(feedback.highlightText),
          isLastQuestion: result.nextQuestion == null,
          onNext: () => _moveNext(result),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  Future<void> _moveNext(LearningAnswerResult result) async {
    final nextQuestion = result.nextQuestion;
    if (nextQuestion != null) {
      setState(() {
        _progress = result.progress;
        _question = nextQuestion;
        _resetInput(nextQuestion);
      });
      return;
    }
    await _completeAttempt();
  }

  Future<void> _completeAttempt() async {
    final attemptId = _attemptId;
    if (attemptId == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await _api.completeAttempt(attemptId);
      if (!mounted) return;

      final nextSessionId = result.nextSessionId;
      final nextStageSessionId = _nextStageSessionId(nextSessionId);
      if (!result.stageCompleted && nextStageSessionId != null) {
        setState(() {
          _sessionId = nextStageSessionId;
          _stageSessionIndex = _stageSessionIds.indexOf(nextStageSessionId);
          _attemptId = null;
          _question = null;
          _progress = null;
        });
        await _startAttempt();
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StageCompleteScreen(
            categoryTitle: widget.categoryTitle,
            completionMessage: result.stageCompleted ? '${widget.categoryTitle} 스테이지를 완료했어요' : '학습 세션을 완료했어요',
            xpAdded: result.xpGained,
            currentXp: result.xpGained,
            levelProgressRatio: ((result.growth['afterPercent'] as num?)?.toDouble() ?? 0) / 100,
            xpIncreaseText: '+${result.growth['deltaPercent'] ?? 0}%',
            unitProgressText: result.stageCompleted ? '이번 스테이지의 모든 학습을 완료했어요.' : '스테이지 완료까지 계속 학습해보세요.',
            unitCompletionRatio: '${result.growth['afterPercent'] ?? 0}%',
            unitProgressRatio: ((result.growth['afterPercent'] as num?)?.toDouble() ?? 0) / 100,
          ),
        ),
      );
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        _goToLogin();
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = _userFacingMessage(error.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '학습 완료 처리를 하지 못했어요. 다시 시도해주세요.';
      });
    }
  }

  Future<bool> _handleExit() async {
    final attemptId = _attemptId;
    if (attemptId != null) {
      try {
        await _api.exitAttempt(attemptId);
      } catch (_) {
        // The backend keeps the attempt resumable even if this best-effort call fails.
      }
    }
    return true;
  }

  void _goToLogin() {
    AuthSession.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _handleExit() && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: themeGreen));
    }
    if (_errorMessage != null) {
      return _buildError();
    }
    final question = _question;
    if (question == null) {
      return const Center(child: Text('문제가 준비되지 않았어요.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _buildQuestion(question),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildHeader() {
    final progress = _displayProgress();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              if (await _handleExit() && mounted) Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6A7282), size: 20),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(progress.total, (index) {
              final isActive = index < progress.current;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == progress.total - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: isActive ? themeGreen : const Color(0xFFE4E8F0),
                    borderRadius: BorderRadius.circular(16777216),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              '${progress.current}/${progress.total}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textMuted,
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LearningProgress _displayProgress() {
    final progress = _progress ?? const LearningProgress(current: 1, total: 1, answered: 0);
    if (_stageSessionIds.length <= 1 || progress.total > 1) {
      return progress;
    }
    return LearningProgress(
      current: _stageSessionIndex + 1,
      total: _stageSessionIds.length,
      answered: _stageSessionIndex,
    );
  }

  int? _nextStageSessionId(int? backendNextSessionId) {
    if (backendNextSessionId != null && _stageSessionIds.contains(backendNextSessionId)) {
      return backendNextSessionId;
    }
    final nextIndex = _stageSessionIndex + 1;
    if (nextIndex >= 0 && nextIndex < _stageSessionIds.length) {
      return _stageSessionIds[nextIndex];
    }
    return backendNextSessionId;
  }

  Widget _buildQuestion(LearningQuestion question) {
    final prompt = _cleanPrompt(question.prompt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.resource.isNotEmpty) _buildResource(question.resource),
        Text(
          prompt.isEmpty ? '문제를 확인해보세요.' : prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 32),
        if (question.isChoice) _buildChoices(question),
        if (question.isOrdering) _buildOrdering(question),
        if (question.isNumberInput || question.isTextInput) _buildTextAnswer(question),
        if (question.isTheoryCard) _buildTheoryPayload(question),
      ],
    );
  }

  Widget _buildResource(Map<String, dynamic> resource) {
    final text = '${resource['text'] ?? ''}';
    if (text.isEmpty) return const SizedBox.shrink();
    final visual = _buildResourceVisual(text);
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: visual),
    );
  }

  Widget _buildResourceVisual(String text) {
    if (_containsAny(text, const ['OX 버튼'])) {
      return _buildOxVisual();
    }
    if (_containsAny(text, const ['계산기', '숫자 입력 패드', '수식 카드'])) {
      return _buildCalculatorVisual(text);
    }
    if (_containsAny(text, const ['두 바구니', '세 바구니', '네 바구니', '드래그앤드롭', '분류 UI'])) {
      return _buildBasketVisual(text);
    }
    if (_containsAny(text, const ['카드 매칭', '매칭 UI', '쌍 카드'])) {
      return _buildMatchingVisual(text);
    }
    if (_containsAny(text, const ['순서 나열'])) {
      return _buildOrderingVisual(text);
    }
    if (_containsAny(text, const ['화살표 방향', '연쇄 도표', '흐름도', '흐름 도표'])) {
      return _buildFlowVisual(text);
    }
    if (_containsAny(text, const ['파이 차트', '파이차트'])) {
      return _buildPieVisual();
    }
    if (_containsAny(text, const ['막대그래프', '막대차트'])) {
      return _buildBarVisual();
    }
    if (_containsAny(text, const ['게이지', '스펙트럼'])) {
      return _buildGaugeVisual();
    }
    if (_containsAny(text, const ['타임라인', '캘린더'])) {
      return _buildTimelineVisual(text);
    }
    if (_containsAny(text, const ['체크리스트', '목록 카드'])) {
      return _buildChecklistVisual(text);
    }
    if (_containsAny(text, const ['호가창'])) {
      return _buildOrderBookVisual();
    }
    if (_containsAny(text, const ['세계 지도', '나라 지도', '지도'])) {
      return _buildMapVisual(text);
    }
    if (_containsAny(text, const ['vs', 'VS', '비교 도표', '비교 카드', '구조 도표', '공식 카드', '피라미드'])) {
      return _buildComparisonVisual(text);
    }
    if (_containsAny(text, const ['가격표', '돈 위', '돈', '가격'])) {
      return _buildMoneyTagVisual();
    }
    if (_containsAny(text, const ['나무', '뿌리', '기준금리'])) {
      return _buildBaseRateRootVisual();
    }
    if (_containsAny(text, const ['차트', '그래프', '금리 최고점', '터치'])) {
      return _buildChartVisual();
    }
    if (_containsAny(text, const ['빈칸', '괄호', '입력'])) {
      return _buildBlankVisual();
    }
    if (_containsAny(text, const ['일러스트', '아이콘', '도표', '카드 UI'])) {
      return _buildGenericIllustrationVisual(text);
    }
    return _buildResourceTextVisual(text);
  }

  Widget _buildMoneyTagVisual() {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: const Color(0xFFF2FFFA),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 18,
            child: _roundIcon(Icons.payments_rounded, size: 72, iconSize: 42),
          ),
          Positioned(
            right: 16,
            top: 14,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: themeGreen, width: 2),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: themeGreen.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sell_rounded, color: themeGreen, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '가격',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: brandInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Text(
              '돈의 가치를 가격표로 확인해요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseRateRootVisual() {
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      color: const Color(0xFFF8FFFC),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BaseRateRootPainter(color: themeGreen)),
          ),
          Positioned(
            top: 0,
            child: _resourceChip('기준금리', color: themeGreen, foreground: brandInk),
          ),
          Positioned(
            top: 48,
            child: Container(
              width: 18,
              height: 56,
              decoration: BoxDecoration(
                color: themeGreen,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 4,
            child: _resourceChip('예금금리'),
          ),
          Positioned(
            bottom: 0,
            child: _resourceChip('대출금리'),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: _resourceChip('시장금리'),
          ),
        ],
      ),
    );
  }

  Widget _buildChartVisual() {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      color: const Color(0xFFF8FBFF),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _MiniChartPainter(color: themeGreen, gridColor: borderGrey),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '그래프의 흐름을 보고 판단해요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlankVisual() {
    return Container(
      height: 166,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      color: const Color(0xFFF8FBFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 44,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _mockKeyboardRow(const ['1', '2', '3', '4', '5', '6']),
          const SizedBox(height: 6),
          _mockKeyboardRow(const ['7', '8', '9', '0', ',', '완료'], emphasizedLast: true),
          const SizedBox(height: 10),
          const Text(
            '빈칸 3개를 순서대로 입력해요',
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _mockKeyboardRow(List<String> keys, {bool emphasizedLast = false}) {
    return Row(
      children: List.generate(keys.length, (index) {
        final isLast = emphasizedLast && index == keys.length - 1;
        return Expanded(
          child: Container(
            height: 24,
            margin: EdgeInsets.only(right: index == keys.length - 1 ? 0 : 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLast ? themeGreen : Colors.white,
              border: Border.all(color: isLast ? themeGreen : const Color(0xFFE4E8F0)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              keys[index],
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: isLast ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: isLast ? Colors.white : const Color(0xFF6A7282),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOxVisual() {
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      color: const Color(0xFFF2FFFA),
      child: Row(
        children: [
          Expanded(child: _answerTile('O', Icons.circle_outlined, themeGreen)),
          const SizedBox(width: 14),
          Expanded(child: _answerTile('X', Icons.close_rounded, const Color(0xFFFF7C1F))),
        ],
      ),
    );
  }

  Widget _buildCalculatorVisual(String text) {
    final showIcons = text.contains('아이콘') || text.contains('구독');
    return Container(
      height: 172,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: [
          Container(
            width: 112,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  height: 30,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w800, color: brandInk),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      9,
                      (index) => Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index == 8 ? themeGreen : const Color(0xFFF8FBFF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: index == 8 ? Colors.white : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: showIcons
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _miniIconChip(Icons.play_circle_fill_rounded, '구독'),
                      _miniIconChip(Icons.receipt_long_rounded, '결제'),
                      _miniIconChip(Icons.savings_rounded, '저축'),
                      _miniIconChip(Icons.calculate_rounded, '계산'),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('숫자를 입력해 계산해요', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w800, color: brandInk)),
                      SizedBox(height: 8),
                      Text('계산형 문제에서 사용할 보조 리소스입니다.', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: textMuted, height: 1.4)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketVisual(String text) {
    final labels = _extractSlashLabels(text, fallback: const ['A', 'B']);
    return Container(
      height: 154,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FFFC),
      child: Row(
        children: [
          Expanded(child: _basketTile(labels[0])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.drag_indicator_rounded, color: themeGreen, size: 28),
          ),
          Expanded(child: _basketTile(labels.length > 1 ? labels[1] : 'B')),
        ],
      ),
    );
  }

  Widget _buildMatchingVisual(String text) {
    final count = text.contains('4쌍') ? 4 : 3;
    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      color: const Color(0xFFF8FBFF),
      child: Column(
        children: List.generate(count, (index) {
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _miniCard('용어 ${index + 1}')),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.swap_horiz_rounded, color: themeGreen, size: 20),
                ),
                Expanded(child: _miniCard('설명 ${index + 1}')),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderingVisual(String text) {
    final count = text.contains('5개') ? 5 : 4;
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: List.generate(count, (index) {
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w800, color: brandInk),
                    ),
                  ),
                ),
                if (index < count - 1) Icon(Icons.chevron_right_rounded, color: themeGreen, size: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFlowVisual(String text) {
    final labels = _compactResourceText(text)
        .split(RegExp(r'→|/'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .take(4)
        .toList();
    final items = labels.length >= 2 ? labels : const ['원인', '변화', '결과'];
    return Container(
      height: 142,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF2FFFA),
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _miniCard(items[index], selected: index == 0)),
                if (index < items.length - 1) Icon(Icons.arrow_forward_rounded, color: themeGreen, size: 22),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPieVisual() {
    return Container(
      height: 154,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            height: 104,
            child: CustomPaint(painter: _PieChartResourcePainter(color: themeGreen)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legendRow(themeGreen, '핵심 항목'),
                _legendRow(const Color(0xFF7C3AED), '비교 항목'),
                _legendRow(const Color(0xFFFFA866), '기타'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarVisual() {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      color: const Color(0xFFF8FBFF),
      child: CustomPaint(
        painter: _BarChartResourcePainter(color: themeGreen, gridColor: borderGrey),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildGaugeVisual() {
    return Container(
      height: 154,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FFFC),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 96,
            child: CustomPaint(painter: _GaugeResourcePainter(color: themeGreen)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '낮음부터 높음까지 흐름을 읽어요',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w800, color: brandInk, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineVisual(String text) {
    final isCalendar = text.contains('캘린더');
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Row(
                  children: [
                    _roundIcon(isCalendar ? Icons.event_available_rounded : Icons.flag_rounded, size: 34, iconSize: 18),
                    if (index < 3)
                      Expanded(
                        child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 6), color: themeGreen.withValues(alpha: 0.55)),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Text(
            isCalendar ? '일정과 루틴을 순서대로 확인해요' : '시간 흐름에 따라 단계를 따라가요',
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistVisual(String text) {
    return Container(
      height: 154,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FFFC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 10),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: themeGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(child: _miniCard('체크 포인트 ${index + 1}', dense: true)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderBookVisual() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: [
          Expanded(child: _orderBookColumn('매도', const Color(0xFFFF6B6B))),
          const SizedBox(width: 10),
          Expanded(child: _orderBookColumn('매수', themeGreen)),
        ],
      ),
    );
  }

  Widget _buildMapVisual(String text) {
    return Container(
      height: 152,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: [
          _roundIcon(Icons.public_rounded, size: 86, iconSize: 48),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              text.contains('달러') ? '세계 흐름과 통화의 관계를 봐요' : '지역과 경제 지표를 함께 봐요',
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w800, color: brandInk, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonVisual(String text) {
    final labels = _extractSlashLabels(text, fallback: const ['A', 'B']);
    return Container(
      height: 152,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: [
          Expanded(child: _comparisonPanel(labels[0], Icons.account_balance_wallet_rounded)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'VS',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w900, color: textMuted),
            ),
          ),
          Expanded(child: _comparisonPanel(labels.length > 1 ? labels[1] : 'B', Icons.trending_up_rounded)),
        ],
      ),
    );
  }

  Widget _buildGenericIllustrationVisual(String text) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FFFC),
      child: Row(
        children: [
          _roundIcon(_resourceIconFor(text), size: 76, iconSize: 40),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              _compactResourceText(text),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF4B5563), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTextVisual(String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      color: const Color(0xFFF8FBFF),
      child: Row(
        children: [
          _roundIcon(Icons.auto_awesome_rounded, size: 48, iconSize: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _localizeDisplayText(text),
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Color(0xFF4B5563), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, {required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: themeGreen.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: themeGreen, size: iconSize),
    );
  }

  Widget _resourceChip(String label, {Color color = const Color(0xFFF0F2F7), Color foreground = const Color(0xFF4B5563)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color == themeGreen ? const Color(0xFFE9FFF6) : color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color == themeGreen ? themeGreen : foreground,
        ),
      ),
    );
  }

  Widget _answerTile(String label, IconData icon, Color color) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _miniIconChip(IconData icon, String label) {
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: themeGreen, size: 22),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _basketTile(String label) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: themeGreen, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_rounded, color: themeGreen, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w800, color: brandInk, height: 1.25),
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String label, {bool selected = false, bool dense = false}) {
    return Container(
      height: dense ? 32 : 36,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE9FFF6) : Colors.white,
        border: Border.all(color: selected ? themeGreen : borderGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        maxLines: dense ? 1 : 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: dense ? 11 : 10,
          fontWeight: FontWeight.w700,
          color: selected ? themeGreen : const Color(0xFF4B5563),
          height: 1.2,
        ),
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }

  Widget _orderBookColumn(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 8),
          ...List.generate(3, (index) {
            return Container(
              height: 16,
              margin: EdgeInsets.only(bottom: index == 2 ? 0 : 6),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '${(index + 1) * 100}',
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF4B5563)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _comparisonPanel(String label, IconData icon) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: themeGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w800, color: brandInk, height: 1.25),
          ),
        ],
      ),
    );
  }

  List<String> _extractSlashLabels(String text, {required List<String> fallback}) {
    final parenthesized = RegExp(r'\(([^)]+)\)').firstMatch(text)?.group(1) ?? text;
    final labels = parenthesized
        .split(RegExp(r'/|vs|VS|↔|·'))
        .map((part) => part.replaceAll(RegExp(r'두 바구니|세 바구니|네 바구니|비교 도표|비교 카드|UI'), '').trim())
        .where((part) => part.isNotEmpty && part.length <= 12)
        .take(2)
        .toList();
    return labels.length >= 2 ? labels : fallback;
  }

  String _compactResourceText(String text) {
    return _localizeDisplayText(text)
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(' UI', '')
        .replaceAll('일러스트', '')
        .replaceAll('도표', '')
        .replaceAll('터치 인터랙션', '')
        .trim();
  }

  IconData _resourceIconFor(String text) {
    if (text.contains('은행') || text.contains('한국은행')) return Icons.account_balance_rounded;
    if (text.contains('주식') || text.contains('차트')) return Icons.query_stats_rounded;
    if (text.contains('카드')) return Icons.credit_card_rounded;
    if (text.contains('통장') || text.contains('지갑')) return Icons.account_balance_wallet_rounded;
    if (text.contains('세금')) return Icons.receipt_long_rounded;
    if (text.contains('보험')) return Icons.health_and_safety_rounded;
    if (text.contains('환율') || text.contains('달러')) return Icons.currency_exchange_rounded;
    return Icons.auto_awesome_rounded;
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  Widget _buildChoices(LearningQuestion question) {
    final isMultiple = question.allowsMultipleChoice;
    return Column(
      children: question.choices.map((choice) {
        final isSelected = _selectedChoiceIds.contains(choice.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (isMultiple) {
                  isSelected ? _selectedChoiceIds.remove(choice.id) : _selectedChoiceIds.add(choice.id);
                } else {
                  _selectedChoiceIds
                    ..clear()
                    ..add(choice.id);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
                border: Border.all(color: isSelected ? themeGreen : borderGrey, width: isSelected ? 2 : 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${choice.id}. ${_localizeDisplayText(choice.text)}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF0DE593) : const Color(0xFF111827),
                            height: 16 / 14,
                          ),
                        ),
                        if (choice.subtitle != null && choice.subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _localizeDisplayText(choice.subtitle!),
                            style: const TextStyle(fontSize: 10, color: textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSelected ? themeGreen : borderGrey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrdering(LearningQuestion question) {
    final idToText = _orderedItemLabels(question);
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;
        setState(() {
          final item = _orderedItemIds.removeAt(oldIndex);
          _orderedItemIds.insert(newIndex, item);
        });
      },
      children: [
        for (final id in _orderedItemIds)
          Container(
            key: ValueKey(id),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderGrey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _localizeDisplayText(idToText[id] ?? id),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildTextAnswer(LearningQuestion question) {
    if (_usesCommaSeparatedParts(question)) {
      return _buildCommaSeparatedAnswer(question);
    }
    return TextField(
      controller: _answerTextController,
      keyboardType: question.isNumberInput ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
      textInputAction: TextInputAction.done,
      inputFormatters: question.isNumberInput ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]'))] : null,
      onChanged: (_) {
        if (mounted) setState(() {});
      },
      onSubmitted: (_) {
        if (_canSubmit) _submitAnswer();
      },
      decoration: InputDecoration(
        hintText: question.isNumberInput ? '숫자를 입력하세요' : '답을 입력하세요',
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: themeGreen, width: 2)),
      ),
    );
  }

  Widget _buildCommaSeparatedAnswer(LearningQuestion question) {
    final count = _answerPartControllers.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = ((constraints.maxWidth - ((count - 1) * 18)) / count).clamp(62.0, 130.0).toDouble();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                for (var index = 0; index < count; index++) ...[
                  SizedBox(
                    width: fieldWidth,
                    child: TextField(
                      controller: _answerPartControllers[index],
                      textAlign: TextAlign.center,
                      textInputAction: index == count - 1 ? TextInputAction.done : TextInputAction.next,
                      keyboardType: _looksNumericParts(question) ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
                      inputFormatters: _looksNumericParts(question) ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,%-]'))] : null,
                      onChanged: (_) {
                        if (mounted) setState(() {});
                      },
                      onSubmitted: (_) {
                        if (_canSubmit) _submitAnswer();
                      },
                      decoration: InputDecoration(
                        hintText: '${index + 1}',
                        hintStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: borderGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: borderGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: themeGreen, width: 2),
                        ),
                      ),
                    ),
                  ),
                  if (index < count - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        ',',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                          height: 1,
                        ),
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '여러 답은 자동으로 쉼표로 묶어서 제출돼요. 예: ${List.generate(count, (index) => index + 1).join(', ')}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textMuted,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTheoryPayload(LearningQuestion question) {
    const hiddenKeys = {'interactionType', 'action', 'resource', 'choices', 'focusGroup'};
    final values = question.payload.entries
        .where((entry) => !hiddenKeys.contains(entry.key))
        .map((entry) => _localizeDisplayText(entry.value).trim())
        .where((value) => value.isNotEmpty && value.toUpperCase() != 'NEXT')
        .toList();
    if (values.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FFFA),
        border: Border.all(color: themeGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(values.join('\n\n'), style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF4B5563))),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4E8F0), width: 1)),
      ),
      child: ElevatedButton(
        onPressed: _canSubmit ? _submitAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: borderGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                _question?.isTheoryCard == true ? '다음' : '제출',
                style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _userFacingMessage(_errorMessage ?? '문제가 발생했어요. 다시 시도해주세요.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, color: brandInk, height: 1.45),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: AuthSession.hasAccessToken ? _startAttempt : _goToLogin,
            style: ElevatedButton.styleFrom(backgroundColor: themeGreen, foregroundColor: Colors.white),
            child: Text(AuthSession.hasAccessToken ? '다시 시도' : '로그인으로 이동'),
          ),
        ],
      ),
    );
  }

  Map<String, String> _orderedItemLabels(LearningQuestion question) {
    final labels = <String, String>{
      for (final choice in question.choices)
        if (choice.id.isNotEmpty) choice.id: _localizeDisplayText(choice.text),
    };

    final payloadItems = question.payload['items'];
    if (payloadItems is List) {
      for (final item in payloadItems) {
        if (item is Map) {
          final id = '${item['id'] ?? item['value'] ?? item['key'] ?? ''}';
          final text = _localizeDisplayText(item['text'] ?? item['label'] ?? item['title'] ?? id);
          if (id.isNotEmpty) labels[id] = text;
        } else {
          final value = '$item';
          if (value.isNotEmpty) labels[value] = _localizeDisplayText(value);
        }
      }
    }

    return labels;
  }

  void _setAnswerPartControllers(int count) {
    _disposeAnswerPartControllers();
    for (var index = 0; index < count; index++) {
      final controller = TextEditingController();
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      _answerPartControllers.add(controller);
    }
  }

  void _disposeAnswerPartControllers() {
    for (final controller in _answerPartControllers) {
      controller.dispose();
    }
    _answerPartControllers.clear();
  }

  bool _usesCommaSeparatedParts(LearningQuestion question) {
    return _answerPartCount(question) > 1;
  }

  int _answerPartCount(LearningQuestion question) {
    final source = '${question.prompt}\n${question.resource['text'] ?? ''}';
    final markers = RegExp(r'[①②③④⑤⑥⑦⑧⑨]').allMatches(source).map((match) => match.group(0)).toSet();
    if (markers.length > 1) return markers.length.clamp(2, 5);
    return 0;
  }

  bool _looksNumericParts(LearningQuestion question) {
    final prompt = question.prompt;
    return question.isNumberInput || prompt.contains('숫자') || prompt.contains('계산') || prompt.contains('%') || prompt.contains('얼마');
  }

  String _commaSeparatedAnswerText() {
    return _answerPartControllers
        .map((controller) => controller.text.trim())
        .where((value) => value.isNotEmpty)
        .join(', ');
  }

  String _cleanPrompt(String prompt) {
    final hiddenLines = <String>[
      'Choose the correct option for the selection part.',
      'Enter the answer range or value as text.',
      '탭(TEXT)',
      'NEXT',
    ];
    final cleaned = prompt
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !hiddenLines.any((hidden) => line.toUpperCase() == hidden.toUpperCase() || line.contains(hidden)))
        .join('\n');
    return _localizeDisplayText(cleaned);
  }

  String _localizeDisplayText(Object? value) {
    var text = '${value ?? ''}'.trim();
    if (text.isEmpty) return '';

    final replacements = <String, String>{
      'Choose the correct option for the selection part.': '보기 중 알맞은 답을 선택하세요.',
      'Enter the answer range or value as text.': '답을 입력하세요.',
      'Choose the correct option': '알맞은 답을 선택하세요',
      'Enter your answer': '답을 입력하세요',
      'Enter answer': '답을 입력하세요',
      'Submit': '제출',
      'submit': '제출',
      'Next': '다음',
      'NEXT': '다음',
      'TEXT': '텍스트',
      'Text': '텍스트',
      'Session': '세션',
      'Stage': '스테이지',
    };

    for (final entry in replacements.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }
    return text;
  }

  String _userFacingMessage(String message) {
    final text = _localizeDisplayText(message);
    final lower = text.toLowerCase();
    if (lower.contains('not found')) return '연결된 학습 정보를 찾지 못했어요.';
    if (lower.contains('unauthorized') || lower.contains('forbidden')) {
      return '로그인이 필요하거나 접근할 수 없는 학습이에요.';
    }
    if (lower.contains('bad request')) return '요청 정보를 확인하지 못했어요. 다시 시도해주세요.';
    if (RegExp(r'[A-Za-z]{4,}').hasMatch(text)) {
      return '요청을 처리하지 못했어요. 잠시 후 다시 시도해주세요.';
    }
    return text;
  }
}

class _BaseRateRootPainter extends CustomPainter {
  const _BaseRateRootPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final centerX = size.width / 2;
    final startY = 84.0;

    for (final targetX in [size.width * 0.18, size.width * 0.5, size.width * 0.82]) {
      final path = Path()
        ..moveTo(centerX, startY)
        ..quadraticBezierTo((centerX + targetX) / 2, size.height * 0.72, targetX, size.height - 28);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BaseRateRootPainter oldDelegate) => oldDelegate.color != color;
}

class _MiniChartPainter extends CustomPainter {
  const _MiniChartPainter({required this.color, required this.gridColor});

  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final left = 12.0;
    final bottom = size.height - 12;
    canvas.drawLine(Offset(left, 8), Offset(left, bottom), axisPaint);
    canvas.drawLine(Offset(left, bottom), Offset(size.width - 10, bottom), axisPaint);

    final points = <Offset>[
      Offset(left + 18, bottom - 22),
      Offset(left + 58, bottom - 64),
      Offset(left + 104, bottom - 44),
      Offset(left + 152, bottom - 54),
      Offset(left + 196, bottom - 20),
      Offset(left + 244, bottom - 48),
      Offset(left + 288, bottom - 32),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx.clamp(left, size.width - 10).toDouble(), point.dy);
    }
    canvas.drawPath(path, linePaint);
    canvas.drawCircle(points[1], 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniChartPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gridColor != gridColor;
  }
}

class _PieChartResourcePainter extends CustomPainter {
  const _PieChartResourcePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final segments = [
      (color, 0.45),
      (const Color(0xFF7C3AED), 0.32),
      (const Color(0xFFFFA866), 0.23),
    ];
    var start = -math.pi / 2;
    for (final segment in segments) {
      final sweep = math.pi * 2 * segment.$2;
      final paint = Paint()
        ..color = segment.$1
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect.deflate(4), start, sweep, true, paint);
      start += sweep;
    }
    canvas.drawCircle(size.center(Offset.zero), size.shortestSide * 0.26, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PieChartResourcePainter oldDelegate) => oldDelegate.color != color;
}

class _BarChartResourcePainter extends CustomPainter {
  const _BarChartResourcePainter({required this.color, required this.gridColor});

  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.2;
    final barPaint = Paint()..color = color;
    final values = [0.38, 0.7, 0.54, 0.86, 0.62];
    final left = 10.0;
    final bottom = size.height - 16;
    canvas.drawLine(Offset(left, 8), Offset(left, bottom), axisPaint);
    canvas.drawLine(Offset(left, bottom), Offset(size.width - 8, bottom), axisPaint);
    final gap = 12.0;
    final width = (size.width - left - 24 - gap * (values.length - 1)) / values.length;
    for (var i = 0; i < values.length; i++) {
      final height = (bottom - 14) * values[i];
      final x = left + 12 + i * (width + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bottom - height, width, height),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, barPaint..color = i == 3 ? color : color.withValues(alpha: 0.45));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartResourcePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gridColor != gridColor;
  }
}

class _GaugeResourcePainter extends CustomPainter {
  const _GaugeResourcePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.92);
    final radius = size.width * 0.42;
    final bgPaint = Paint()
      ..color = const Color(0xFFE4E8F0)
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);
    canvas.drawArc(rect, math.pi, math.pi * 0.68, false, fgPaint);

    final needleAngle = math.pi + math.pi * 0.68;
    final needleEnd = Offset(
      center.dx + math.cos(needleAngle) * (radius - 8),
      center.dy + math.sin(needleAngle) * (radius - 8),
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = const Color(0xFF4B5563)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 5, Paint()..color = const Color(0xFF4B5563));
  }

  @override
  bool shouldRepaint(covariant _GaugeResourcePainter oldDelegate) => oldDelegate.color != color;
}
