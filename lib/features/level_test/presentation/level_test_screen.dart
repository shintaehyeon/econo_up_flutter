// lib/features/level_test/presentation/level_test_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'level_test_result_screen.dart';
import 'level_test_feedback_screen.dart';
import '../data/level_test_mock_data.dart';

import 'widgets/question_single_choice.dart';
import 'widgets/question_matching.dart';
import 'widgets/question_reorder.dart';
import 'widgets/question_graph_input.dart';

class LevelTestScreen extends StatefulWidget {
  final String nickname;

  const LevelTestScreen({super.key, this.nickname = '경제왕'});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  int _currentIdx = 0;

  // State for MULTIPLE_CHOICE
  String? _selectedAnswer;

  // State for MATCHING
  Map<String, String> _matchingAnswers = {};

  // State for REORDER
  List<String> _reorderList = []; // target -> draggable

  // State for GRAPH_INPUT
  int? _selectedGraphIndex;
  final TextEditingController _baseRateController = TextEditingController();

  bool _isAnswered = false;
  bool _isLoading = false;
  int _score = 0;

  // Private correct answers for Mock API grading
  static const Map<String, dynamic> _correctAnswers = {
    'q_demo_01': 'B',
    'q_demo_02': {
      '금리 인상 선호\n물가 안정 우선': '매파',
      '금리 인하 선호\n경기 부양 우선': '비둘기파',
    },
    'q_demo_03': ['A', 'C', 'B', 'D', 'E'],
    'q_demo_04': 'B',
    'q_demo_05': {
      'highestIndex': 1,
      'answerText': '3.5',
    },
  };

  // 5 high-quality finance/economics questions
  // 분리된 목업 파일에서 데이터를 가져옵니다. 백엔드 API 연동 시 이 부분을 교체하면 됩니다.
  final List<Map<String, dynamic>> _questions = List.from(levelTestMockData);

  @override
  void initState() {
    super.initState();
    _baseRateController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _baseRateController.dispose();
    super.dispose();
  }



  Future<void> _submitAnswer() async {
    if (_isAnswered || _isLoading) return;

    final currentQ = _questions[_currentIdx];
    final String type = currentQ['type'];

    // 1. Validate answer selected
    bool hasAnswer = false;
    if (type == 'MULTIPLE_CHOICE') {
      hasAnswer = _selectedAnswer != null;
    } else if (type == 'MATCHING') {
      final targets = currentQ['targetDescriptions'] as List<String>;
      hasAnswer = _matchingAnswers.length == targets.length;
    } else if (type == 'REORDER') {
      hasAnswer = _reorderList.isNotEmpty;
    } else if (type == 'GRAPH_INPUT') {
      hasAnswer = _selectedGraphIndex != null &&
          _baseRateController.text.trim().isNotEmpty;
    }
    if (!hasAnswer) return;

    // 2. Set loading state
    setState(() {
      _isLoading = true;
    });

    // 3. Construct JSON Payload according to API spec (Section 9.2)
    final String questionId = currentQ['id'];
    Map<String, dynamic> answerPayload;
    if (type == 'MULTIPLE_CHOICE') {
      answerPayload = {
        "choiceIds": [_selectedAnswer!],
      };
    } else if (type == 'MATCHING') {
      answerPayload = {
        "matchingPairs": _matchingAnswers,
      };
    } else if (type == 'REORDER') {
      answerPayload = {
        "orderedItemIds": _reorderList,
      };
    } else if (type == 'GRAPH_INPUT') {
      answerPayload = {
        "highestIndex": _selectedGraphIndex,
        "answerText": _baseRateController.text.trim(),
      };
    } else {
      answerPayload = {};
    }

    final attemptPayload = {
      "questionId": questionId,
      "answer": answerPayload,
    };
    debugPrint('Submitting answer to level test Mock API: $attemptPayload');

    // 4. Async delay (Mock Network latency: 800ms)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // 5. Evaluate correctness (Mocking Server-side Evaluation)
    bool isCorrect = false;
    if (type == 'MULTIPLE_CHOICE') {
      isCorrect = _selectedAnswer == _correctAnswers[questionId];
    } else if (type == 'MATCHING') {
      final correctMapping = _correctAnswers[questionId] as Map<String, String>;
      isCorrect = true;
      for (var target in correctMapping.keys) {
        if (_matchingAnswers[target] != correctMapping[target]) {
          isCorrect = false;
          break;
        }
      }
    } else if (type == 'REORDER') {
      final correctOrder = _correctAnswers[questionId] as List<String>;
      isCorrect = _reorderList.length == correctOrder.length;
      if (isCorrect) {
        for (int i = 0; i < correctOrder.length; i++) {
          if (_reorderList[i] != correctOrder[i]) {
            isCorrect = false;
            break;
          }
        }
      }
    } else if (type == 'GRAPH_INPUT') {
      final correctGraph = _correctAnswers[questionId] as Map<String, dynamic>;
      final bool isGraphCorrect =
          _selectedGraphIndex == correctGraph['highestIndex'];
      final textAns = _baseRateController.text.trim();
      final String correctText = correctGraph['answerText'] as String;
      final bool isTextCorrect = textAns == correctText ||
          textAns == '${correctText}0' ||
          textAns == '$correctText%';
      isCorrect = isGraphCorrect && isTextCorrect;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = false;
      _isAnswered = true;
      if (isCorrect) {
        _score += 20;
      }
    });

    String generatedHighlight = currentQ['highlightText'] as String? ?? '';
    if (generatedHighlight.isEmpty && !isCorrect) {
      if (type == 'MULTIPLE_CHOICE') {
        final choices = currentQ['choices'] as List<dynamic>?;
        if (choices != null) {
          Map<String, dynamic>? correctChoice;
          final correctAnswerId = _correctAnswers[questionId];
          for (var c in choices) {
            if (c['id'] == correctAnswerId) {
              correctChoice = c as Map<String, dynamic>;
              break;
            }
          }
          if (correctChoice != null) {
            generatedHighlight =
                '정답은 ${correctChoice['id']}. ${correctChoice['text']} 입니다.';
          }
        }
      }
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LevelTestFeedbackScreen(
              isCorrect: isCorrect,
              explanation: currentQ['explanation'] as String? ?? '',
              highlightText: generatedHighlight,
              isLastQuestion: _currentIdx == _questions.length - 1,
              onNext: _nextQuestion,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _nextQuestion() {
    HapticFeedback.lightImpact();
    if (_currentIdx < _questions.length - 1) {
      setState(() {
        _currentIdx++;
        _selectedAnswer = null;
        _isAnswered = false;
        _matchingAnswers.clear();
        _reorderList.clear();
        _selectedGraphIndex = null;
        _baseRateController.clear();

        final nextQ = _questions[_currentIdx];
        if (nextQ['type'] == 'REORDER') {
          _reorderList = List<String>.from(nextQ['initialOrder'] as List);
        }
      });
    } else {
      _finishTest();
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
            side: const BorderSide(color: Color(0xFFD0D5E0)),
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
                              color: Color(0xFF111827),
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
                                    color: Color(0xFF111827),
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
                                    color: Color(0xFF9CA3AF),
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
                              backgroundColor: const Color(0xFF00EE94),
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

  void _finishTest() {
    debugPrint('Completing level test with score: $_score');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LevelTestResultScreen(score: _score, nickname: widget.nickname),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return WillPopScope(
        onWillPop: _showExitDialog,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6A7282),
                size: 20,
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final shouldPop = await _showExitDialog();
                if (shouldPop && mounted) navigator.pop();
              },
            ),
          ),
          body: const Center(
            child: Text(
              '문항을 불러오는 중입니다...',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                color: Color(0xFF6A7282),
              ),
            ),
          ),
        ),
      );
    }

    final currentQ = _questions[_currentIdx];
    final totalQuestions = _questions.length;
    final type = currentQ['type'];

    return WillPopScope(
      onWillPop: _showExitDialog,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top App Bar & Progress Bar Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        final shouldPop = await _showExitDialog();
                        if (shouldPop && mounted) navigator.pop();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF6A7282),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: List.generate(totalQuestions, (idx) {
                        bool isActive = idx <= _currentIdx;
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(
                              right: idx == totalQuestions - 1 ? 0 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF00EE94)
                                  : const Color(0xFFE4E8F0),
                              borderRadius: BorderRadius.circular(16777216),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        '${_currentIdx + 1}/$totalQuestions',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Builder(
                    builder: (context) {
                      if (type == 'MULTIPLE_CHOICE') {
                        return QuestionSingleChoice(
                          currentQ: currentQ,
                          selectedAnswer: _selectedAnswer,
                          isAnswered: _isAnswered,
                          onAnswerSelected: (val) {
                            setState(() => _selectedAnswer = val);
                          },
                        );
                      } else if (type == 'MATCHING') {
                        return QuestionMatching(
                          currentQ: currentQ,
                          matchingAnswers: _matchingAnswers,
                          isAnswered: _isAnswered,
                          onMatchingChanged: (val) {
                            setState(() => _matchingAnswers = val);
                          },
                        );
                      } else if (type == 'REORDER') {
                        return QuestionReorder(
                          currentQ: currentQ,
                          reorderList: _reorderList,
                          isAnswered: _isAnswered,
                          onReorderChanged: (val) {
                            setState(() => _reorderList = val);
                          },
                        );
                      } else if (type == 'GRAPH_INPUT') {
                        return QuestionGraphInput(
                          currentQ: currentQ,
                          selectedGraphIndex: _selectedGraphIndex,
                          baseRateController: _baseRateController,
                          isAnswered: _isAnswered,
                          onGraphIndexSelected: (val) {
                            setState(() => _selectedGraphIndex = val);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              // 3. Bottom Action Section (Answer Check / Next Banner)
              _buildBottomActionSection(currentQ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionSection(Map<String, dynamic> currentQ) {
    if (!_isAnswered) {
      bool canSubmit = false;
      if (currentQ['type'] == 'MULTIPLE_CHOICE') {
        canSubmit = _selectedAnswer != null;
      } else if (currentQ['type'] == 'MATCHING') {
        canSubmit = _matchingAnswers.length == 2;
      } else if (currentQ['type'] == 'REORDER') {
        canSubmit = _reorderList.isNotEmpty;
      } else if (currentQ['type'] == 'GRAPH_INPUT') {
        canSubmit =
            _selectedGraphIndex != null &&
            _baseRateController.text.trim().isNotEmpty;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE4E8F0), width: 1)),
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 24),
          child: ElevatedButton(
            onPressed: (canSubmit && !_isLoading) ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00EE94),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD0D5E0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '제출',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
