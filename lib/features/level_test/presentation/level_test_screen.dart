// lib/features/level_test/presentation/level_test_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'level_test_result_screen.dart';
import 'level_test_feedback_screen.dart';

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10)));

    Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0; // Reset for next metric if any
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LevelTestScreen extends StatefulWidget {
  final String nickname;

  const LevelTestScreen({
    super.key,
    this.nickname = '경제왕',
  });

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
  bool _isCorrect = false;
  int _score = 0;

  // 5 high-quality finance/economics questions
  // 실제 로컬 시연을 위해, 방금 주신 캡처본(기획안)과 동일한 문항 2개만 임시로 넣습니다.
  // 추후 API 연동 시 이 배열은 비우거나 서버 데이터로 교체하시면 됩니다.
  final List<Map<String, dynamic>> _questions = [
    {
      'type': 'MULTIPLE_CHOICE',
      'id': 'q_demo_01',
      'categoryText': '경제 상식 · 금리',
      'prompt': '금리가 오르면 일반적으로\n채권 가격은 어떻게 될까요?',
      'subtitle': '',
      'choices': [
        {'id': 'A', 'text': '오른다'},
        {'id': 'B', 'text': '내려간다'},
        {'id': 'C', 'text': '변화 없다'},
        {'id': 'D', 'text': '알 수 없다'},
      ],
      'answer': 'B',
      'explanation': '금리↓ → 기존 채권의 이자가 상대적으로\n매력적 → 채권 수요↑ → 채권 가격↑',
      'highlightText': '금리와 채권 가격은 반대로 움직인다.',
    },
    {
      'type': 'REORDER',
      'id': 'q_demo_02',
      'subtitle': '드래그해서 올바른 순서로 나열하세요',
      'prompt': '기준금리 인상 → 소비 감소 과정',
      'choices': [
        {'id': 'A', 'text': 'A. 기준금리 인상'},
        {'id': 'B', 'text': 'B. 대출 이자 부담↑'},
        {'id': 'C', 'text': 'C. 시중금리 상승'},
        {'id': 'D', 'text': 'D. 가처분소득↓'},
        {'id': 'E', 'text': 'E. 소비 감소'},
      ],
      'initialOrder': ['A', 'B', 'C', 'D', 'E'],
      'answer': ['A', 'C', 'B', 'D', 'E'],
      'explanation': '기준금리가 인상되면 시중금리가 오르고, 대출 이자 부담이 커지면서 가처분소득이 줄어 소비가 감소하게 됩니다.',
      'highlightText': '',
    },
  ];

  @override
  void dispose() {
    _baseRateController.dispose();
    super.dispose();
  }

  String getAlphabetLetter(int index) {
    switch (index) {
      case 0:
        return 'A.';
      case 1:
        return 'B.';
      case 2:
        return 'C.';
      case 3:
        return 'D.';
      default:
        return '';
    }
  }

  void _submitAnswer() {
    if (_isAnswered) return;

    final currentQ = _questions[_currentIdx];
    final String type = currentQ['type'];

    bool isCorrect = false;
    List<String> selectedIds = [];

    if (type == 'MULTIPLE_CHOICE') {
      if (_selectedAnswer == null) return;
      isCorrect = _selectedAnswer == currentQ['answer'];
      selectedIds = [_selectedAnswer!];
    } else if (type == 'MATCHING') {
      final targets = currentQ['targetDescriptions'] as List<String>;
      if (_matchingAnswers.length != targets.length) return;

      final correctMapping = currentQ['correctMapping'] as Map<String, String>;
      isCorrect = true;
      for (var target in targets) {
        if (_matchingAnswers[target] != correctMapping[target]) {
          isCorrect = false;
          break;
        }
      }
      selectedIds = _matchingAnswers.values.toList();
    } else if (type == 'REORDER') {
      isCorrect = true;
      final answer = List<String>.from(currentQ['answer'] as List);
      for (int i = 0; i < answer.length; i++) {
        if (_reorderList[i] != answer[i]) {
          isCorrect = false;
          break;
        }
      }
      selectedIds = _reorderList;
    } else if (type == 'GRAPH_INPUT') {
      final textAns = _baseRateController.text.trim();
      final bool isTextCorrect = textAns == currentQ['answerText'] || textAns == '${currentQ['answerText']}0' || textAns == '${currentQ['answerText']}%';
      final bool isGraphCorrect = _selectedGraphIndex == currentQ['highestIndex'];
      isCorrect = isTextCorrect && isGraphCorrect;
      selectedIds = [_selectedGraphIndex.toString(), textAns];
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score += 20; 
      }
    });

    final attemptPayload = {
      "questionId": currentQ['id'],
      "answer": {
        "choiceIds": selectedIds
      }
    };
    debugPrint('Submitting answer to level test: $attemptPayload');

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LevelTestFeedbackScreen(
          isCorrect: isCorrect,
          explanation: currentQ['explanation'] as String? ?? '',
          highlightText: currentQ['highlightText'] as String? ?? '',
          isLastQuestion: _currentIdx == _questions.length - 1,
          onNext: _nextQuestion,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

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

  void _finishTest() {
    debugPrint('Completing level test with score: $_score');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LevelTestResultScreen(
          score: _score,
          nickname: widget.nickname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6A7282), size: 20),
            onPressed: () => Navigator.pop(context),
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
      );
    }

    final currentQ = _questions[_currentIdx];
    final totalQuestions = _questions.length;
    final type = currentQ['type'];

    return Scaffold(
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
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
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
                          margin: EdgeInsets.only(right: idx == totalQuestions - 1 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF00EE94) : const Color(0xFFE4E8F0),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Builder(
                  builder: (context) {
                    if (type == 'MULTIPLE_CHOICE') {
                      return _buildMultipleChoiceContent(currentQ);
                    } else if (type == 'MATCHING') {
                      return _buildMatchingContent(currentQ);
                    } else if (type == 'REORDER') {
                      return _buildReorderContent(currentQ);
                    } else if (type == 'GRAPH_INPUT') {
                      return _buildGraphInputContent(currentQ);
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
    );
  }

  Widget _buildMultipleChoiceContent(Map<String, dynamic> currentQ) {
    return Column(
      children: [
        if (currentQ['resourceTitle'] != null && currentQ['resourceText'] != null) ...[
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
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B5563),
            height: 16 / 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          currentQ['prompt'] as String,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 24 / 20,
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
          children: List.generate((currentQ['choices'] as List).length, (choiceIdx) {
            final choice = (currentQ['choices'] as List)[choiceIdx] as Map<String, String>;
            final choiceId = choice['id']!;
            final choiceText = choice['text']!;
            final choiceSubtitle = choice['subtitle'];
            final isSelected = _selectedAnswer == choiceId;

            Color btnBg = const Color(0xFFFFFFFF);
            Color borderCol = const Color(0xFFD0D5E0);
            double borderW = 1.0;
            Color txtCol = const Color(0xFF111827);
            Color circleCol = const Color(0xFFD0D5E0);

            if (_isAnswered) {
              if (choiceId == currentQ['answer']) {
                btnBg = const Color(0xFFF2FFFA);
                borderCol = const Color(0xFF00EE94);
                borderW = 2.0;
                circleCol = const Color(0xFF00EE94);
              } else if (isSelected) {
                btnBg = const Color(0xFFFFF5F5);
                borderCol = const Color(0xFFEF4444);
                borderW = 2.0;
                circleCol = const Color(0xFFEF4444);
              }
            } else if (isSelected) {
              btnBg = const Color(0xFFF2FFFA);
              borderCol = const Color(0xFF00EE94);
              borderW = 2.0;
              circleCol = const Color(0xFF00EE94);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: _isAnswered
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedAnswer = choiceId;
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                              '${getAlphabetLetter(choiceIdx)} $choiceText',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: txtCol,
                                height: 16 / 14,
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
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: circleCol,
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

  Widget _buildMatchingContent(Map<String, dynamic> currentQ) {
    final draggables = currentQ['draggableItems'] as List<String>;
    final targets = currentQ['targetDescriptions'] as List<String>;

    // Filter out items that are already matched
    final availableDraggables = draggables.where((item) => !_matchingAnswers.containsValue(item)).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          currentQ['prompt'] as String,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
            height: 16 / 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Draggable Cards Row
        Row(
          children: [
            Expanded(child: _buildDraggableItem(draggables[0], availableDraggables.contains(draggables[0]))),
            const SizedBox(width: 7),
            Expanded(child: _buildDraggableItem(draggables[1], availableDraggables.contains(draggables[1]))),
          ],
        ),
        
        const SizedBox(height: 30),

        // Drag Targets (Dashed Slots)
        Row(
          children: [
            Expanded(child: _buildDragTarget(targets[0])),
            const SizedBox(width: 7),
            Expanded(child: _buildDragTarget(targets[1])),
          ],
        ),

        const SizedBox(height: 8),

        // Descriptions Row
        Row(
          children: [
            Expanded(child: _buildDescriptionCard(targets[0])),
            const SizedBox(width: 7),
            Expanded(child: _buildDescriptionCard(targets[1])),
          ],
        ),
      ],
    );
  }

  Widget _buildDraggableItem(String text, bool isAvailable) {
    if (!isAvailable) {
      // Return an empty placeholder if it's already dragged
      return const SizedBox(height: 51);
    }

    final card = Container(
      height: 51,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
          height: 16 / 14,
        ),
      ),
    );

    return Draggable<String>(
      data: text,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: 196, // Fixed width for feedback to look similar
            child: card,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: card,
      ),
      child: card,
    );
  }

  Widget _buildDragTarget(String targetDesc) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        HapticFeedback.lightImpact();
        setState(() {
          // If another target has this draggable, clear it
          _matchingAnswers.removeWhere((key, value) => value == details.data);
          _matchingAnswers[targetDesc] = details.data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final droppedItem = _matchingAnswers[targetDesc];

        if (droppedItem != null) {
          // Show the dropped card, make it tappable to remove
          return GestureDetector(
            onTap: _isAnswered
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _matchingAnswers.remove(targetDesc);
                    });
                  },
            child: Container(
              height: 51,
              decoration: BoxDecoration(
                color: _isAnswered ? const Color(0xFFF2FFFA) : Colors.white,
                border: Border.all(color: _isAnswered ? const Color(0xFF00EE94) : const Color(0xFF00EE94), width: _isAnswered ? 2 : 1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                droppedItem,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isAnswered ? const Color(0xFF0DE593) : const Color(0xFF111827),
                  height: 16 / 14,
                ),
              ),
            ),
          );
        }

        // Dashed Empty Slot
        return CustomPaint(
          painter: DashedRectPainter(
            color: const Color(0xFFD0D5E0),
            strokeWidth: 1.0,
            gap: 4.0,
          ),
          child: Container(
            height: 51,
            alignment: Alignment.center,
          ),
        );
      },
    );
  }

  Widget _buildReorderContent(Map<String, dynamic> currentQ) {
    final choices = currentQ['choices'] as List;
    final Map<String, String> idToText = {
      for (var choice in choices) (choice as Map<String, String>)['id']!: choice['text']!
    };

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (int oldIndex, int newIndex) {
          if (_isAnswered) return;
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String item = _reorderList.removeAt(oldIndex);
            _reorderList.insert(newIndex, item);
          });
        },
        children: [
          for (int i = 0; i < _reorderList.length; i++)
            Container(
              key: ValueKey(_reorderList[i]),
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD0D5E0), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      '⠿',
                      style: TextStyle(
                        fontFamily: 'Noto Sans KR',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        idToText[_reorderList[i]] ?? '',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          height: 16 / 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGraphInputContent(Map<String, dynamic> currentQ) {
    final points = currentQ['graphPoints'] as List<double>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Graph Container
        Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('5%', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                    Text('3%', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                    Text('1%', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                // Graph area
                Expanded(
                  child: Stack(
                    children: [
                      // X & Y Axis Lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: AxisPainter(),
                        ),
                      ),
                      // Line Graph
                      Positioned.fill(
                        child: GestureDetector(
                          onTapDown: _isAnswered ? null : (details) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box == null) return;
                            final width = box.size.width; // Actually need the layout builder for exact width, but we can just use details.localPosition
                            final dx = details.localPosition.dx;
                            // Width is roughly Expanded width
                            // We have points.length points.
                            // approximate
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                onTapDown: _isAnswered ? null : (details) {
                                  final double stepX = constraints.maxWidth / (points.length - 1);
                                  final dx = details.localPosition.dx;
                                  final int index = (dx / stepX).round();
                                  if (index >= 0 && index < points.length) {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _selectedGraphIndex = index;
                                    });
                                  }
                                },
                                child: CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight),
                                  painter: GraphLinePainter(
                                    points: points,
                                    selectedIndex: _selectedGraphIndex,
                                    isAnswered: _isAnswered,
                                    correctIndex: currentQ['highestIndex'],
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                      // Tooltip
                      if (_selectedGraphIndex != null)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double stepX = constraints.maxWidth / (points.length - 1);
                            final double x = _selectedGraphIndex! * stepX;
                            final double y = (1 - points[_selectedGraphIndex!]) * constraints.maxHeight;
                            return Positioned(
                              left: x - 25, // center tooltip
                              top: y - 28,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2FFFA),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '최고점!',
                                  style: TextStyle(
                                    color: Color(0xFF0DE593),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Input Title
        const Text(
          '현재 기준금리를 입력하세요',
          style: TextStyle(
            fontFamily: 'Noto Sans KR',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        // TextField
        TextField(
          controller: _baseRateController,
          enabled: !_isAnswered,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD0D5E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD0D5E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00EE94), width: 2),
            ),
            hintText: '입력해주세요 (예: 3.5)',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          onChanged: (val) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String text) {
    return Container(
      height: 71,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Noto Sans KR',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4B5563),
          height: 14 / 12,
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
        canSubmit = _selectedGraphIndex != null && _baseRateController.text.trim().isNotEmpty;
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
            onPressed: canSubmit ? _submitAnswer : null,
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
            child: Text(
              currentQ['type'] == 'MULTIPLE_CHOICE' ? '정답 확인' : '다음',
              style: const TextStyle(
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

class AxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE4E8F0)
      ..strokeWidth = 1.0;
    
    // Y-axis line
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);
    
    // X-axis line
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GraphLinePainter extends CustomPainter {
  final List<double> points;
  final int? selectedIndex;
  final bool isAnswered;
  final int correctIndex;

  GraphLinePainter({
    required this.points,
    required this.selectedIndex,
    required this.isAnswered,
    required this.correctIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF00EE94)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      final double y = (1 - points[i]) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, linePaint);

    // Draw selected circle
    if (selectedIndex != null) {
      final double x = selectedIndex! * stepX;
      final double y = (1 - points[selectedIndex!]) * size.height;
      
      Color circleColor = const Color(0xFF00EE94);
      if (isAnswered && selectedIndex != correctIndex) {
        circleColor = const Color(0xFFEF4444); // wrong selection
      }

      final circlePaint = Paint()
        ..color = circleColor
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(Offset(x, y), 6.0, circlePaint);
    }
    
    // If answered correctly, or if we want to show correct answer on wrong
    if (isAnswered && selectedIndex != correctIndex) {
      final double x = correctIndex * stepX;
      final double y = (1 - points[correctIndex]) * size.height;
      final correctPaint = Paint()
        ..color = const Color(0xFF00EE94)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6.0, correctPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GraphLinePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.isAnswered != isAnswered;
  }
}

