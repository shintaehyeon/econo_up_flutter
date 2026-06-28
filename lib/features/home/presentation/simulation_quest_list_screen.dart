// lib/features/home/presentation/simulation_quest_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../data/simulation_api.dart';
import 'simulation_progress_screen.dart';

class SimulationQuestListScreen extends StatefulWidget {
  const SimulationQuestListScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color iconGrey = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color disabledBg = Color(0xFFF3F3F3);
  static const Color disabledBorder = Color(0xFFE8E8E8);
  static const Color disabledText = Color(0xFFC0C0C0);
  static const Color disabledSubText = Color(0xFFD0D0D0);

  @override
  State<SimulationQuestListScreen> createState() => _SimulationQuestListScreenState();
}

class _SimulationQuestListScreenState extends State<SimulationQuestListScreen> {
  late final ApiClient _client;
  late final SimulationApi _simulationApi;
  List<SimulationSummary> _simulations = const [];
  bool _isLoading = true;
  bool _isStarting = false;
  String? _errorMessage;

  static const Color brandInk = SimulationQuestListScreen.brandInk;
  static const Color iconGrey = SimulationQuestListScreen.iconGrey;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(
      accessTokenProvider: AuthSession.accessToken,
      onUnauthorized: AuthSession.clear,
    );
    _simulationApi = SimulationApi(_client);
    _loadSimulations();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, scale),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: SimulationQuestListScreen.brandInk),
                        )
                      : _errorMessage != null
                          ? _ErrorPanel(message: _errorMessage!, onRetry: _loadSimulations)
                          : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      7 * scale,
                      24 * scale,
                      24 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 28 * scale,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              '해금된 퀘스트',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w700,
                                color: brandInk,
                                height: 19 / 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        for (var i = 0; i < _simulations.length; i++) ...[
                          _SimulationQuestCard(
                            title: _simulations[i].title,
                            subtitle: _subtitleFor(_simulations[i]),
                            emoji: _simulations[i].icon,
                            isUnlocked: _simulations[i].unlocked,
                            scale: scale,
                            onTap: _simulations[i].unlocked
                                ? () => _startSimulation(context, _simulations[i])
                                : HapticFeedback.lightImpact,
                          ),
                          if (i != _simulations.length - 1) SizedBox(height: 12 * scale),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return SizedBox(
      height: 41 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (widget.onBack != null) {
                    widget.onBack!();
                    return;
                  }
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: SizedBox(
                  width: 32 * scale,
                  height: 32 * scale,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28 * scale,
                    color: iconGrey,
                  ),
                ),
              ),
            ),
            Text(
              '시뮬레이션 퀘스트',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: brandInk,
                height: 16 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSimulations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _simulationApi.list();
      if (!mounted) return;
      setState(() {
        _simulations = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '시뮬레이션 목록을 불러오지 못했어요.';
      });
    }
  }

  Future<void> _startSimulation(BuildContext context, SimulationSummary simulation) async {
    if (_isStarting) return;
    HapticFeedback.lightImpact();
    setState(() => _isStarting = true);

    try {
      final attempt = await _simulationApi.start(simulation.id);
      if (!context.mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimulationProgressScreen(
            simulation: simulation,
            attemptId: attempt.attemptId,
          ),
        ),
      );
      if (result is int && context.mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시뮬레이션을 시작하지 못했어요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  String _subtitleFor(SimulationSummary simulation) {
    if (!simulation.unlocked) {
      return simulation.unlockStageId > 0 ? 'Stage ${simulation.unlockStageId} 완료 후' : '잠금';
    }
    if (simulation.status == 'COMPLETED') return '완료됨 · +${simulation.rewardXp} XP';
    return '+${simulation.rewardXp} XP 보상';
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(fontFamily: 'Pretendard')),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('다시 불러오기')),
        ],
      ),
    );
  }
}

class _SimulationQuestCard extends StatelessWidget {
  const _SimulationQuestCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.isUnlocked,
    required this.scale,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final bool isUnlocked;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 69 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : SimulationQuestListScreen.disabledBg,
          border: Border.all(
            color: isUnlocked ? SimulationQuestListScreen.borderGrey : SimulationQuestListScreen.disabledBorder,
            width: 1 * scale,
          ),
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        child: Row(
          children: [
            _QuestIcon(
              emoji: emoji,
              isUnlocked: isUnlocked,
              scale: scale,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: isUnlocked ? SimulationQuestListScreen.textDark : SimulationQuestListScreen.disabledText,
                      height: 19 / 16,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? SimulationQuestListScreen.textMuted : SimulationQuestListScreen.disabledSubText,
                      height: 14 / 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            if (isUnlocked)
              Icon(
                Icons.chevron_right_rounded,
                size: 28 * scale,
                color: SimulationQuestListScreen.iconGrey,
              )
            else
              Opacity(
                opacity: 0.55,
                child: Text(
                  '🔒',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestIcon extends StatelessWidget {
  const _QuestIcon({
    required this.emoji,
    required this.isUnlocked,
    required this.scale,
  });

  final String emoji;
  final bool isUnlocked;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48 * scale,
      height: 48 * scale,
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFF7F7F7) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      alignment: Alignment.center,
      child: isUnlocked
          ? Text(
              emoji,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24 * scale,
                fontWeight: FontWeight.w400,
                height: 32 / 24,
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    emoji,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w500,
                      height: 32 / 24,
                    ),
                  ),
                ),
                Positioned(
                  right: 9 * scale,
                  bottom: 8 * scale,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      '🔒',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
