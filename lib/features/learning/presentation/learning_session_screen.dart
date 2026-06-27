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
  });

  final int sessionId;
  final String categoryTitle;
  final bool resume;

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  late final ApiClient _client;
  late final LearningApi _api;
  final TextEditingController _answerTextController = TextEditingController();

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
        _errorMessage = 'Login is required. Use Admin Test Login first.';
      });
      return;
    }

    try {
      final result = await _api.startAttempt(widget.sessionId, resume: widget.resume);
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
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load the learning session. Please try again.';
      });
    }
  }

  void _resetInput(LearningQuestion question) {
    _selectedChoiceIds.clear();
    _answerTextController.clear();
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
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Could not submit the answer. Please try again.';
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
    if (question.isNumberInput) {
      final raw = _answerTextController.text.trim().replaceAll(',', '');
      final parsed = num.tryParse(raw);
      return parsed == null ? {'answerText': raw} : {'numberValue': parsed};
    }
    return {'answerText': _answerTextController.text.trim()};
  }

  void _showFeedback(LearningAnswerResult result) {
    final feedback = result.feedback;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LevelTestFeedbackScreen(
          isCorrect: feedback.isCorrect,
          explanation: feedback.explanation,
          highlightText: feedback.highlightText,
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
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not complete the session. Please try again.';
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
      return const Center(child: Text('No question is available.'));
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
    final progress = _progress ?? const LearningProgress(current: 1, total: 1, answered: 0);
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

  Widget _buildQuestion(LearningQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.resource.isNotEmpty) _buildResource(question.resource),
        Text(
          question.prompt,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Color(0xFF4B5563), height: 1.45),
      ),
    );
  }

  Widget _buildChoices(LearningQuestion question) {
    final isMultiple = question.type == 'MULTIPLE_CHOICE';
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
                          '${choice.id}. ${choice.text}',
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
                          Text(choice.subtitle!, style: const TextStyle(fontSize: 10, color: textMuted)),
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
    final idToText = <String, String>{
      for (final choice in question.choices) choice.id: choice.text,
    };
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
            child: Text(idToText[id] ?? id, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildTextAnswer(LearningQuestion question) {
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
        hintText: question.isNumberInput ? 'Enter a number' : 'Enter your answer',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: themeGreen, width: 2)),
      ),
    );
  }

  Widget _buildTheoryPayload(LearningQuestion question) {
    final values = question.payload.values.where((value) => '$value'.trim().isNotEmpty).map((value) => '$value').toList();
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
                _question?.isTheoryCard == true ? 'Continue' : 'Submit',
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
            _errorMessage ?? 'Something went wrong. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, color: brandInk, height: 1.45),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: AuthSession.hasAccessToken ? _startAttempt : _goToLogin,
            style: ElevatedButton.styleFrom(backgroundColor: themeGreen, foregroundColor: Colors.white),
            child: Text(AuthSession.hasAccessToken ? 'Retry' : 'Go to login'),
          ),
        ],
      ),
    );
  }
}
