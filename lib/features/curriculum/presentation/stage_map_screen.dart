import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../../auth/presentation/login_screen.dart';
import '../../learning/presentation/learning_session_screen.dart';
import '../data/curriculum_api.dart';
import 'widgets/unlock_bottom_sheet.dart';

class StageMapScreen extends StatefulWidget {
  final int unitId;
  final int stageId;
  final String stageName;
  final String unitName;
  final String category;
  final String? categoryCode;

  const StageMapScreen({
    super.key,
    required this.unitId,
    required this.stageId,
    required this.stageName,
    required this.unitName,
    required this.category,
    this.categoryCode,
  });

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color bgGrey = Color(0xFFF7F7F7);

  late final ApiClient _client;
  late final CurriculumApi _api;

  StageMapResult? _stageMap;
  bool _isLoading = true;
  String? _errorMessage;

  Color get themeColor => widget.categoryCode == 'SAVING' ? const Color(0xFF00DAEE) : const Color(0xFF00EE94);
  Color get playColor => widget.categoryCode == 'SAVING' ? const Color(0xFF00BECF) : const Color(0xFF1DDC83);
  Color get completedNodeShadowColor => widget.categoryCode == 'SAVING' ? const Color(0x6600DAEE) : const Color(0x6600EE94);
  Color get topSummaryBorderColor => widget.categoryCode == 'SAVING' ? const Color(0x4D00DAEE) : const Color(0x4D01EE94);
  Color get topSummaryShadowColor => widget.categoryCode == 'SAVING' ? const Color(0x1400DAEE) : const Color(0x1400EE94);
  Color get questCardBgColor => widget.categoryCode == 'SAVING' ? const Color(0x0D00DAEE) : const Color(0x0D00EE94);
  Color get questCardBorderColor => widget.categoryCode == 'SAVING' ? const Color(0x6600DAEE) : const Color(0x6600EE94);

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = CurriculumApi(_client);
    _loadStageMap();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadStageMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (!AuthSession.hasAccessToken) {
      setState(() {
        _isLoading = false;
        _errorMessage = '로그인이 필요합니다. 개발 테스트는 ECONOUP_ACCESS_TOKEN 값을 넣어 실행해주세요.';
      });
      return;
    }

    try {
      final result = await _api.stageMap(unitId: widget.unitId, stageId: widget.stageId);
      if (!mounted) return;
      setState(() {
        _stageMap = result;
        _isLoading = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
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
        _errorMessage = '스테이지 세션을 불러오지 못했습니다.';
      });
    }
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

  List<SessionData> get _sessions {
    final sessions = _stageMap?.sessions ?? const <CurriculumSession>[];
    return List.generate(sessions.length, (index) {
      final session = sessions[index];
      return SessionData(
        id: session.id,
        sequence: index + 1,
        type: _displayType(session.type),
        title: session.title,
        state: _sessionState(session.status),
      );
    });
  }

  String _displayType(String type) {
    return switch (type) {
      'THEORY' || 'THEORY_CARD' => '이론',
      'QUIZ' || 'SINGLE_CHOICE' || 'MULTIPLE_CHOICE' => '퀴즈',
      'DRILL' || 'ORDERING' || 'NUMBER_INPUT' => '훈련',
      _ => type.isEmpty ? '학습' : type,
    };
  }

  SessionState _sessionState(String status) {
    if (status == 'COMPLETED') return SessionState.completed;
    if (status == 'LOCKED') return SessionState.locked;
    return SessionState.active;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);
    final cardWidth = (contentWidth - 32).clamp(0.0, 416.0);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent(contentWidth, cardWidth)),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double contentWidth, double cardWidth) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: themeColor));
    }
    if (_errorMessage != null) {
      return _buildError();
    }
    if (_sessions.isEmpty) {
      return const Center(child: Text('세션 데이터가 없습니다.'));
    }
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Center(
        child: Container(
          width: contentWidth,
          color: bgGrey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopSummaryCard(cardWidth),
              const SizedBox(height: 16),
              Container(
                width: 390,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: _buildTimelineNodes()),
              ),
              const SizedBox(height: 24),
              _buildSimulationQuestCard(cardWidth),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final stageTitle = '${_stageMap?.stage['title'] ?? widget.stageName}';
    return Container(
      width: double.infinity,
      height: 41,
      color: bgGrey,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6A7282), size: 20),
            ),
          ),
          Text(
            stageTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w600, color: brandInk, height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummaryCard(double width) {
    final unitTitle = '${_stageMap?.unit['title'] ?? widget.unitName}';
    final stageTitle = '${_stageMap?.stage['title'] ?? widget.stageName}';
    return Container(
      width: width,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: topSummaryBorderColor, width: 1),
        boxShadow: [BoxShadow(color: topSummaryShadowColor, blurRadius: 10, offset: const Offset(0, 2))],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(unitTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w400, color: textMuted, height: 1.45, letterSpacing: 0.06)),
          const SizedBox(height: 2),
          Text(stageTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, color: brandInk, height: 1.45, letterSpacing: -0.23)),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineNodes() {
    final children = <Widget>[];
    final sessions = _sessions;
    for (int i = 0; i < sessions.length; i++) {
      final session = sessions[i];
      final isLeftNode = i % 2 == 0;
      children.add(_buildSessionRow(session, isLeftNode));
      if (i < sessions.length - 1) {
        final nextSession = sessions[i + 1];
        final isGreenLine = session.state == SessionState.completed && nextSession.state != SessionState.locked;
        children.add(
          Container(
            width: 350,
            height: 38,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (_) {
                  return Container(width: 2, height: 6, decoration: BoxDecoration(color: isGreenLine ? themeColor : const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(16777216)));
                }),
              ),
            ),
          ),
        );
      }
    }
    return children;
  }

  Widget _buildSessionRow(SessionData session, bool isLeftNode) {
    final nodeSize = session.sequence == 1 ? 60.0 : 56.0;
    final nodeWidget = _buildNodeWidget(session, nodeSize);
    final cardWidget = _buildCardWidget(session);
    return SizedBox(
      width: 350,
      height: session.sequence == 1 ? 69 : 67,
      child: Row(
        children: isLeftNode
            ? [nodeWidget, const SizedBox(width: 12), Expanded(child: cardWidget)]
            : [Expanded(child: cardWidget), const SizedBox(width: 12), nodeWidget],
      ),
    );
  }

  Widget _buildNodeWidget(SessionData session, double size) {
    if (session.state == SessionState.completed) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: themeColor, boxShadow: [BoxShadow(color: completedNodeShadowColor, blurRadius: 14, offset: const Offset(0, 4))]),
            alignment: Alignment.center,
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
          ),
          Positioned(
            right: size == 60 ? -4 : -2,
            top: size == 60 ? -4 : -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: themeColor, width: 2), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))]),
              alignment: Alignment.center,
              child: Icon(Icons.check_rounded, color: themeColor, size: 12),
            ),
          ),
        ],
      );
    }
    if (session.state == SessionState.active) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))]),
        child: CustomPaint(
          painter: _DashedCirclePainter(color: themeColor, strokeWidth: 2),
          child: Center(child: Icon(Icons.play_arrow_rounded, color: playColor, size: 24)),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE5E7EB), boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))]),
      alignment: Alignment.center,
      child: const Icon(Icons.lock_rounded, color: Color(0xFFCACACA), size: 18),
    );
  }

  Widget _buildCardWidget(SessionData session) {
    final isCompleted = session.state == SessionState.completed;
    final isActive = session.state == SessionState.active;
    final badgeBg = isCompleted || isActive ? themeColor.withValues(alpha: 0.15) : const Color(0xFFF0F0F0);
    final badgeText = isCompleted || isActive ? themeColor : const Color(0xFF9CA3AF);
    final titleColor = isCompleted || isActive ? textMuted : const Color(0xFFC4C4C4);
    final descColor = isCompleted || isActive ? brandInk : const Color(0xFF9CA3AF);
    final cardBg = isCompleted || isActive ? Colors.white : const Color(0xFFF3F4F6);
    final cardBorder = isCompleted || isActive ? Border.all(color: const Color(0xFFF0F0F0), width: 1) : null;
    final cardShadow = isCompleted || isActive ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))] : null;

    return GestureDetector(
      onTap: () => _handleSessionTap(session),
      child: Container(
        constraints: BoxConstraints(minHeight: session.sequence == 1 ? 69 : 67),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: cardBg, border: cardBorder, boxShadow: cardShadow, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(16777216)),
                  alignment: Alignment.center,
                  child: Text(session.type, style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: badgeText, height: 1.1)),
                ),
                const SizedBox(width: 6),
                Text('Session ${session.sequence}', style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w400, color: titleColor, height: 1.5, letterSpacing: 0.11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: descColor, height: 1.5)),
          ],
        ),
      ),
    );
  }

  void _handleSessionTap(SessionData session) {
    if (session.state == SessionState.locked) {
      HapticFeedback.lightImpact();
      UnlockBottomSheet.show(context, category: widget.category);
      return;
    }
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningSessionScreen(sessionId: session.id, categoryTitle: widget.category, resume: true),
      ),
    ).then((_) => _loadStageMap());
  }

  Widget _buildSimulationQuestCard(double width) {
    final unlocked = _stageMap?.simulationCta['unlocked'] == true;
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 65),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: questCardBgColor, border: Border.all(color: questCardBorderColor, width: 1), borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('시뮬레이션 퀘스트', style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: brandInk, height: 1.5)),
          const SizedBox(height: 2),
          Text(unlocked ? '지금 도전할 수 있어요' : '스테이지 완료 후 잠금 해제', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w400, color: textMuted, height: 1.45, letterSpacing: 0.06)),
        ],
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
          Text(_errorMessage ?? '오류가 발생했습니다.', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, color: brandInk, height: 1.45)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: AuthSession.hasAccessToken ? _loadStageMap : _goToLogin,
            style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.white),
            child: Text(AuthSession.hasAccessToken ? '다시 시도' : '로그인하러 가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return EconoBottomNavigationBar(
      activeTab: EconoBottomTab.learning,
      onTabSelected: (tab) {
        if (tab != EconoBottomTab.learning) Navigator.pop(context, _indexForBottomTab(tab));
      },
    );
  }

  int _indexForBottomTab(EconoBottomTab tab) {
    switch (tab) {
      case EconoBottomTab.home:
        return 0;
      case EconoBottomTab.learning:
        return 1;
      case EconoBottomTab.connect:
        return 2;
      case EconoBottomTab.battle:
        return 3;
      case EconoBottomTab.my:
        return 4;
    }
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class SessionData {
  final int id;
  final int sequence;
  final String type;
  final String title;
  final SessionState state;

  SessionData({required this.id, required this.sequence, required this.type, required this.title, required this.state});
}

enum SessionState { completed, active, locked }