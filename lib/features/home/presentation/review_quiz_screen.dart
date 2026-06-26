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
  LearningFeedback? _feedback;
  int? _selectedIndex;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken, onUnauthorized: AuthSession.clear);
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
      _error = null;
      _feedback = null;
      _selectedIndex = null;
      _textController.clear();
    });
    try {
      final today = await _api.today();
      if (!mounted) return;
      setState(() {
        _today = today;
        _question = today.question;
        _isLoading = false;
      });
      if (today.question == null) {
        await _completeReview();
      }
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load review quiz.';
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    });
  }

  Future<void> _submitChoice(int index) async {
    final question = _question;
    final today = _today;
    if (question == null || today == null || _isSubmitting) return;
    setState(() => _selectedIndex = index);
    await _submitAnswer({'choiceIds': [question.choices[index].id]});
  }

  Future<void> _submitTyped() async {
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
    final question = _question;
    final today = _today;
    if (question == null || today == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    try {
      final result = await _api.submitAnswer(reviewSetId: today.reviewSetId, questionId: question.id, answer: answer);
      if (!mounted) return;
      setState(() {
        _feedback = result.feedback;
        _isSubmitting = false;
      });
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      if (result.nextQuestion == null) {
        await _completeReview();
      } else {
        setState(() {
          _question = result.nextQuestion;
          _today = ReviewToday(reviewSetId: today.reviewSetId, status: today.status, progress: result.progress, question: result.nextQuestion);
          _feedback = null;
          _selectedIndex = null;
          _textController.clear();
        });
      }
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _error = error.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not submit answer.';
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReviewQuizCompleteScreen()));
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
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 24 * scale),
              child: _buildBody(scale),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(double scale) {
    if (_isLoading) {
      return Column(children: [_buildHeader(scale), const Expanded(child: Center(child: CircularProgressIndicator(color: ReviewQuizScreen.themeGreen)))]);
    }
    if (_error != null) {
      return Column(children: [_buildHeader(scale), Expanded(child: Center(child: Text(_error!, textAlign: TextAlign.center))), ElevatedButton(onPressed: _loadToday, child: const Text('Retry'))]);
    }
    final question = _question;
    if (question == null) {
      return Column(children: [_buildHeader(scale), const Expanded(child: Center(child: Text('No review question for today.')))]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(scale),
        SizedBox(height: 28 * scale),
        _buildProgress(scale),
        SizedBox(height: 38 * scale),
        Text(question.type, textAlign: TextAlign.center, style: TextStyle(fontSize: 14 * scale, color: ReviewQuizScreen.textMuted, fontWeight: FontWeight.w700)),
        SizedBox(height: 18 * scale),
        Text(question.prompt, textAlign: TextAlign.center, style: TextStyle(fontSize: 25 * scale, fontWeight: FontWeight.w800, color: ReviewQuizScreen.textDark, height: 1.25)),
        if (question.resource['text'] != null) ...[
          SizedBox(height: 16 * scale),
          Text('${question.resource['text']}', textAlign: TextAlign.center, style: TextStyle(fontSize: 14 * scale, color: ReviewQuizScreen.textMuted)),
        ],
        SizedBox(height: 36 * scale),
        Expanded(child: _buildAnswerArea(question, scale)),
        if (_feedback != null) _buildFeedback(scale),
      ],
    );
  }

  Widget _buildHeader(double scale) {
    return SizedBox(
      height: 64 * scale,
      child: Row(children: [
        Text('Review quiz', style: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.w800, color: ReviewQuizScreen.brandInk)),
        const Spacer(),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Color(0xFF6A7282))),
      ]),
    );
  }

  Widget _buildProgress(double scale) {
    final progress = _today?.progress;
    final total = progress?.total ?? 1;
    final answered = progress?.answered ?? 0;
    return Column(children: [
      LinearProgressIndicator(
        value: total <= 0 ? 0 : answered / total,
        minHeight: 6 * scale,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: const AlwaysStoppedAnimation(ReviewQuizScreen.themeGreen),
      ),
      SizedBox(height: 14 * scale),
      Text('${(progress?.current ?? 1).clamp(1, total)}/$total', style: TextStyle(color: ReviewQuizScreen.textMuted, fontSize: 15 * scale)),
    ]);
  }

  Widget _buildAnswerArea(LearningQuestion question, double scale) {
    if (question.isChoice) {
      return ListView.separated(
        itemCount: question.choices.length,
        separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
        itemBuilder: (context, index) => _answerButton(question.choices[index].text, index, scale),
      );
    }
    return Column(children: [
      TextField(
        controller: _textController,
        keyboardType: question.isNumberInput ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: question.isNumberInput ? 'Enter a number' : 'Enter your answer',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale)),
        ),
      ),
      SizedBox(height: 14 * scale),
      SizedBox(
        height: 52 * scale,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitTyped,
          style: ElevatedButton.styleFrom(backgroundColor: ReviewQuizScreen.themeGreen, foregroundColor: Colors.white),
          child: Text(_isSubmitting ? 'Checking...' : 'Submit'),
        ),
      ),
    ]);
  }

  Widget _answerButton(String text, int index, double scale) {
    final selected = _selectedIndex == index;
    return GestureDetector(
      onTap: _isSubmitting ? null : () => _submitChoice(index),
      child: Container(
        constraints: BoxConstraints(minHeight: 60 * scale),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(color: selected ? ReviewQuizScreen.themeGreen : ReviewQuizScreen.borderGrey, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10 * scale),
        ),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 17 * scale, fontWeight: FontWeight.w700, color: ReviewQuizScreen.textDark)),
      ),
    );
  }

  Widget _buildFeedback(double scale) {
    final feedback = _feedback!;
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: feedback.isCorrect ? const Color(0xFFF2FFFA) : const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Text(
        '${feedback.isCorrect ? 'Correct' : 'Try again'}  ${feedback.explanation}',
        style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.w700, color: ReviewQuizScreen.brandInk),
      ),
    );
  }
}
