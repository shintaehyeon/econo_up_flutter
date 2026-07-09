import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../../learning/presentation/learning_session_screen.dart';
import '../data/curriculum_api.dart';
import 'widgets/unlock_bottom_sheet.dart';

class StageMapScreen extends StatefulWidget {
  const StageMapScreen({
    super.key,
    required this.unitName,
    required this.unitTitle,
    required this.unitSubtitle,
    required this.category,
    required this.stages,
    this.unitId,
  });

  final String unitName;
  final String unitTitle;
  final String unitSubtitle;
  final String category;
  final List<StageListItem> stages;
  final int? unitId;

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color bgGrey = Color(0xFFF7F7F7);

  late final ApiClient _client;
  late final CurriculumApi _api;
  int? _openingStageId;

  Color get themeColor {
    if (widget.category == '저축') return const Color(0xFF00DAEE);
    if (widget.category == '주식') return const Color(0xFFFFA866);
    if (widget.category == '부동산') return const Color(0xFF7C3AED);
    if (widget.category == '세금') return const Color(0xFFFF455D);
    return const Color(0xFF00EE94);
  }

  Color get playColor {
    if (widget.category == '저축') return const Color(0xFF00BECF);
    if (widget.category == '주식') return const Color(0xFFFF8B3D);
    if (widget.category == '부동산') return const Color(0xFF7C3AED);
    if (widget.category == '세금') return const Color(0xFFFF455D);
    return const Color(0xFF1DDC83);
  }

  Color get completedNodeShadowColor {
    if (widget.category == '저축') return const Color(0x6600DAEE);
    if (widget.category == '주식') return const Color(0x66FFA866);
    if (widget.category == '부동산') return const Color(0x667C3AED);
    if (widget.category == '세금') return const Color(0x66FF455D);
    return const Color(0x6600EE94);
  }

  String get _headerTitle => widget.unitName;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _api = CurriculumApi(_client);
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMainContent(contentWidth)),
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.learning),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6A7282),
                size: 20,
              ),
            ),
          ),
          Text(
            _headerTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: brandInk,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(double contentWidth) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Center(
        child: Container(
          width: contentWidth,
          color: bgGrey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildUnitCard(),
              const SizedBox(height: 18),
              Container(
                width: 390,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    widget.stages.isEmpty
                        ? _buildEmptyCard()
                        : Column(children: _buildStageNodes()),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitCard() {
    final completedCount =
        widget.stages.where((stage) => stage.state == StageListState.completed).length;
    final totalCount = widget.stages.length;

    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: themeColor.withValues(alpha: 0.45), width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.unitName,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: themeColor,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.unitTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: brandInk,
              height: 1.25,
            ),
          ),
          if (widget.unitSubtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.unitSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textMuted,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            totalCount == 0 ? '스테이지 정보 없음' : '$completedCount/$totalCount 스테이지 완료',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: themeColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '아직 연결된 스테이지가 없어요.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
      ),
    );
  }

  List<Widget> _buildStageNodes() {
    final children = <Widget>[];

    for (var i = 0; i < widget.stages.length; i++) {
      final stage = widget.stages[i];
      final isLeftNode = i % 2 == 0;

      children.add(_buildStageRow(stage, isLeftNode));

      if (i < widget.stages.length - 1) {
        final nextStage = widget.stages[i + 1];
        final isGreenLine =
            stage.state == StageListState.completed &&
            nextStage.state != StageListState.locked;
        children.add(_buildConnector(isGreenLine));
      }
    }

    return children;
  }

  Widget _buildConnector(bool isGreenLine) {
    return SizedBox(
      width: 350,
      height: 38,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (_) {
            return Container(
              width: 2,
              height: 6,
              decoration: BoxDecoration(
                color: isGreenLine ? themeColor : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStageRow(StageListItem stage, bool isLeftNode) {
    const nodeSize = 60.0;
    final nodeWidget = _buildNodeWidget(stage, nodeSize);
    final cardWidget = _buildCardWidget(stage);

    return SizedBox(
      width: 350,
      height: 112,
      child: Align(
        alignment: Alignment.center,
        child: isLeftNode
            ? Row(
                children: [
                  nodeWidget,
                  const SizedBox(width: 12),
                  Expanded(child: cardWidget),
                ],
              )
            : Row(
                children: [
                  Expanded(child: cardWidget),
                  const SizedBox(width: 12),
                  nodeWidget,
                ],
              ),
      ),
    );
  }

  Widget _buildNodeWidget(StageListItem stage, double size) {
    if (stage.state == StageListState.completed) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor,
              boxShadow: [
                BoxShadow(
                  color: completedNodeShadowColor,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '✓',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (stage.state == StageListState.active) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _DashedCirclePainter(color: themeColor, strokeWidth: 2),
          child: Center(
            child: Icon(
              _openingStageId == stage.id ? Icons.more_horiz_rounded : Icons.play_arrow_rounded,
              color: playColor,
              size: 24,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE5E7EB),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.lock_rounded,
        color: Color(0xFFCACACA),
        size: 18,
      ),
    );
  }

  Widget _buildCardWidget(StageListItem stage) {
    final isCompleted = stage.state == StageListState.completed;
    final isActive = stage.state == StageListState.active;
    final isOpening = _openingStageId == stage.id;

    final badgeBg =
        isActive || isCompleted ? themeColor.withValues(alpha: 0.15) : const Color(0xFFF0F0F0);
    final badgeText =
        isActive || isCompleted ? themeColor : const Color(0xFF9CA3AF);
    final titleColor =
        isActive || isCompleted ? brandInk : const Color(0xFFC4C4C4);
    final subtitleColor =
        isActive || isCompleted ? textMuted : const Color(0xFFD0D0D0);
    final cardBg =
        stage.state == StageListState.locked ? const Color(0xFFF3F4F6) : Colors.white;

    return GestureDetector(
      onTap: isOpening ? null : () => _handleStageTap(stage),
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          border:
              isActive
                  ? Border.all(color: themeColor, width: 1.5)
                  : Border.all(color: const Color(0xFFF0F0F0), width: 1),
          boxShadow:
              stage.state == StageListState.locked
                  ? null
                  : const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '스테이지 ${stage.sequence}',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeText,
                            height: 1.0,
                          ),
                        ),
                      ),
                      if (stage.isCompleted) ...[
                        const SizedBox(width: 6),
                        Text(
                          '완료',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusText(stage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            if (isOpening)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: themeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusText(StageListItem stage) {
    return switch (stage.state) {
      StageListState.completed => '다시 학습하기',
      StageListState.active => '학습 시작',
      StageListState.locked => '이전 스테이지 완료 후 해금',
    };
  }

  Future<void> _handleStageTap(StageListItem stage) async {
    if (stage.state == StageListState.locked) {
      HapticFeedback.lightImpact();
      await UnlockBottomSheet.show(
        context,
        category: widget.category,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
      );
      return;
    }

    final unitId = widget.unitId;
    if (unitId == null || stage.id <= 0) {
      HapticFeedback.lightImpact();
      _showMessage('학습 연결 정보가 없어 시작할 수 없어요.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _openingStageId = stage.id;
    });

    try {
      final result = await _api.stageMap(unitId: unitId, stageId: stage.id);
      if (!mounted) return;

      final playableSessions = _playableSessions(result.sessions);
      if (playableSessions.isEmpty) {
        _showMessage('이 스테이지에 연결된 학습 세션이 없어요.');
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => StageSessionListScreen(
                category: widget.category,
                stage: stage,
                sessions: playableSessions,
                themeColor: themeColor,
                playColor: playColor,
              ),
        ),
      );
    } on ApiClientException catch (error) {
      if (!mounted) return;
      _showMessage(_localizeCurriculumText(error.message));
    } catch (_) {
      if (!mounted) return;
      _showMessage('학습 세션을 불러오지 못했어요.');
    } finally {
      if (mounted) {
        setState(() {
          _openingStageId = null;
        });
      }
    }
  }

  List<CurriculumSession> _playableSessions(List<CurriculumSession> sessions) {
    return sessions.where((session) => session.status != 'LOCKED').toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class StageListItem {
  const StageListItem({
    required this.id,
    required this.sequence,
    required this.title,
    required this.status,
  });

  final int id;
  final int sequence;
  final String title;
  final String status;

  bool get isCompleted => status == 'COMPLETED';

  StageListState get state {
    if (status == 'COMPLETED') return StageListState.completed;
    if (status == 'LOCKED') return StageListState.locked;
    return StageListState.active;
  }
}

enum StageListState {
  completed,
  active,
  locked,
}

String _localizeCurriculumText(Object? value) {
  var text = '${value ?? ''}'.trim();
  if (text.isEmpty) return '';

  final replacements = <String, String>{
    'Choose the correct option for the selection part.': '보기 중 알맞은 답을 선택하세요.',
    'Enter the answer range or value as text.': '답을 입력하세요.',
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
  if (RegExp(r'[A-Za-z]{4,}').hasMatch(text)) {
    if (text.toLowerCase().contains('not found')) return '연결된 학습 정보를 찾지 못했어요.';
    return '요청을 처리하지 못했어요. 잠시 후 다시 시도해주세요.';
  }
  return text;
}

class StageSessionListScreen extends StatelessWidget {
  const StageSessionListScreen({
    super.key,
    required this.category,
    required this.stage,
    required this.sessions,
    required this.themeColor,
    required this.playColor,
  });

  final String category;
  final StageListItem stage;
  final List<CurriculumSession> sessions;
  final Color themeColor;
  final Color playColor;

  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color bgGrey = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 448.0);
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: Container(
                    width: contentWidth,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: Column(
                      children: [
                        _buildStageSummary(),
                        const SizedBox(height: 18),
                        ...List.generate(sessions.length, (index) {
                          return _buildSessionCard(context, sessions[index], index);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const EconoBottomNavigationBar(activeTab: EconoBottomTab.learning),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF6A7282),
                size: 20,
              ),
            ),
          ),
          Text(
            '스테이지 ${stage.sequence}',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: brandInk,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSummary() {
    final completedCount = sessions.where((session) => session.status == 'COMPLETED').length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1.5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            stage.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: brandInk,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedCount/${sessions.length} 세션 완료',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: themeColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, CurriculumSession session, int index) {
    final isCompleted = session.status == 'COMPLETED';
    final isLocked = session.status == 'LOCKED';
    final sessionIds = sessions.where((item) => item.status != 'LOCKED').map((item) => item.id).toList();
    final label = _sessionTypeLabel(session.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningSessionScreen(
                      sessionId: session.id,
                      categoryTitle: category,
                      stageSessionIds: sessionIds,
                    ),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isLocked ? const Color(0xFFF3F4F6) : Colors.white,
            border: Border.all(
              color: isCompleted ? themeColor : const Color(0xFFE4E8F0),
              width: isCompleted ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isLocked
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted ? themeColor : themeColor.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCompleted ? Icons.check_rounded : _sessionIcon(session.type),
                  color: isCompleted ? Colors.white : themeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '세션 ${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _sessionTitle(session, index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isLocked ? const Color(0xFFC4C4C4) : brandInk,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                color: isLocked ? const Color(0xFFC4C4C4) : const Color(0xFF6A7282),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sessionTitle(CurriculumSession session, int index) {
    final title = session.title.trim();
    if (title.isEmpty || title == '탭(Next)' || title == '탭(TEXT)') {
      return '${_sessionTypeLabel(session.type)} 문제 ${index + 1}';
    }
    return _localizeCurriculumText(title
        .replaceAll('탭(Next)', '개념 학습')
        .replaceAll('탭(TEXT)', '개념 학습'));
  }

  String _sessionTypeLabel(String type) {
    return switch (type) {
      'THEORY' => '이론',
      'TERM_MATCH' => '용어',
      'DRILL' => '드릴',
      'CONNECTION' => '연결',
      'DATA' => '데이터',
      _ => '문제',
    };
  }

  IconData _sessionIcon(String type) {
    return switch (type) {
      'THEORY' => Icons.menu_book_rounded,
      'TERM_MATCH' => Icons.style_rounded,
      'DRILL' => Icons.edit_note_rounded,
      'CONNECTION' => Icons.account_tree_rounded,
      'DATA' => Icons.query_stats_rounded,
      _ => Icons.star_rounded,
    };
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
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
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
