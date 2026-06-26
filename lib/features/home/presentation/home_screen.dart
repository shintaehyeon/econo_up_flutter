import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../../auth/presentation/login_screen.dart';
import '../../curriculum/presentation/curriculum_roadmap_screen.dart';
import '../../social/presentation/battle_main_screen.dart';
import '../data/home_api.dart';
import 'bill_purchase_center_screen.dart';
import 'heart_recharge_screen.dart';
import 'my_page_screen.dart';
import 'news_feed_screen.dart';
import 'review_quiz_screen.dart';
import 'simulation_quest_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.nickname = 'Econo'});

  final String nickname;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color brandInk = Color(0xFF122711);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color bgGrey = Color(0xFFF7F7F7);
  static const Color textMuted = Color(0xFF6A7282);

  late final ApiClient _client;
  late final HomeApi _homeApi;

  int _currentTabIdx = 0;
  bool _showBillPurchaseCenter = false;
  bool _showHeartRecharge = false;
  HomeData? _home;
  bool _isLoadingHome = true;
  String? _homeError;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken, onUnauthorized: AuthSession.clear);
    _homeApi = HomeApi(_client);
    _loadHome();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadHome() async {
    if (!AuthSession.hasAccessToken) {
      _goToLogin();
      return;
    }
    setState(() {
      _isLoadingHome = true;
      _homeError = null;
    });
    try {
      final data = await _homeApi.home();
      if (!mounted) return;
      setState(() {
        _home = data;
        _isLoadingHome = false;
      });
    } on ApiClientException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 || error.statusCode == 403) {
        _goToLogin();
        return;
      }
      setState(() {
        _homeError = error.message;
        _isLoadingHome = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _homeError = 'Could not load home data.';
        _isLoadingHome = false;
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

  void _setTab(int index) {
    setState(() => _currentTabIdx = index);
    if (index == 0 || index == 1) {
      _loadHome();
    }
  }

  void _setBottomTab(EconoBottomTab tab) {
    switch (tab) {
      case EconoBottomTab.home:
        _setTab(0);
      case EconoBottomTab.learning:
        _setTab(1);
      case EconoBottomTab.connect:
        _setTab(2);
      case EconoBottomTab.battle:
        _setTab(3);
      case EconoBottomTab.my:
        _setTab(4);
    }
  }

  EconoBottomTab get _activeBottomTab {
    return switch (_currentTabIdx) {
      1 => EconoBottomTab.learning,
      2 => EconoBottomTab.connect,
      3 => EconoBottomTab.battle,
      4 => EconoBottomTab.my,
      _ => EconoBottomTab.home,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: contentWidth,
            height: double.infinity,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: _buildCurrentBody(scale)),
                    EconoBottomNavigationBar(
                      activeTab: _activeBottomTab,
                      onTabSelected: _setBottomTab,
                      scale: scale,
                    ),
                  ],
                ),
                if (_showBillPurchaseCenter)
                  BillPurchaseCenterScreen(
                    onClose: () {
                      setState(() => _showBillPurchaseCenter = false);
                      _loadHome();
                    },
                  ),
                if (_showHeartRecharge)
                  HeartRechargeScreen(
                    onClose: () {
                      setState(() => _showHeartRecharge = false);
                      _loadHome();
                    },
                    onOpenBillPurchaseCenter: () {
                      setState(() {
                        _showHeartRecharge = false;
                        _showBillPurchaseCenter = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBody(double scale) {
    if (_currentTabIdx == 2) return NewsFeedScreen(onBottomTabSelected: _setTab);
    if (_currentTabIdx == 3) return BattleMainScreen(onBottomTabSelected: _setTab);
    if (_currentTabIdx == 4) return MyPageScreen(onBottomTabSelected: _setTab, showBottomNavigation: false);
    if (_currentTabIdx == 1) return _buildLearningTab(scale);
    return _buildHomeTab(scale);
  }

  Widget _buildHomeTab(double scale) {
    return RefreshIndicator(
      onRefresh: _loadHome,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 24 * scale),
        children: [
          _buildTopBar(scale),
          SizedBox(height: 18 * scale),
          if (_isLoadingHome) _buildLoading(scale),
          if (_homeError != null) _buildError(scale),
          if (!_isLoadingHome && _homeError == null) ...[
            _buildHero(scale),
            SizedBox(height: 20 * scale),
            _buildQuickActions(scale),
            SizedBox(height: 22 * scale),
            _buildSectionTitle('Continue learning', scale),
            SizedBox(height: 12 * scale),
            ..._categoryCards(scale, limit: 2),
          ],
        ],
      ),
    );
  }

  Widget _buildLearningTab(double scale) {
    return RefreshIndicator(
      onRefresh: _loadHome,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20 * scale, 14 * scale, 20 * scale, 24 * scale),
        children: [
          _buildTopBar(scale),
          SizedBox(height: 20 * scale),
          _buildSectionTitle('Learning categories', scale),
          SizedBox(height: 12 * scale),
          if (_isLoadingHome) _buildLoading(scale),
          if (_homeError != null) _buildError(scale),
          if (!_isLoadingHome && _homeError == null) ...[
            ..._categoryCards(scale),
            _simulationCard(scale),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBar(double scale) {
    final nickname = _home?.nickname.isNotEmpty == true ? _home!.nickname : widget.nickname;
    return Row(
      children: [
        Expanded(
          child: Text(
            '$nickname, welcome back',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w800, color: brandInk),
          ),
        ),
        _assetButton(Icons.favorite_rounded, '${_home?.heartCurrent ?? 0}/${_home?.heartMax ?? 3}', const Color(0xFFFF7C7C), () {
          setState(() => _showHeartRecharge = true);
        }, scale),
        SizedBox(width: 8 * scale),
        _assetButton(Icons.payments_rounded, '${_home?.billBalance ?? 0}', themeGreen, () {
          setState(() => _showBillPurchaseCenter = true);
        }, scale),
      ],
    );
  }

  Widget _assetButton(IconData icon, String label, Color color, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 34 * scale,
        padding: EdgeInsets.symmetric(horizontal: 10 * scale),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
        child: Row(children: [Icon(icon, color: color, size: 18 * scale), SizedBox(width: 4 * scale), Text(label)]),
      ),
    );
  }

  Widget _buildHero(double scale) {
    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16 * scale)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Today streak', style: TextStyle(color: textMuted, fontSize: 13 * scale, fontWeight: FontWeight.w600)),
              SizedBox(height: 6 * scale),
              Text('${_home?.streakDays ?? 0} days', style: TextStyle(fontSize: 28 * scale, fontWeight: FontWeight.w900, color: brandInk)),
              SizedBox(height: 8 * scale),
              Text('Keep one session going and protect your progress.', style: TextStyle(color: textMuted, fontSize: 13 * scale)),
            ]),
          ),
          Icon(Icons.local_fire_department_rounded, size: 54 * scale, color: const Color(0xFFFF6900)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(double scale) {
    return Row(
      children: [
        Expanded(child: _quickCard('Review', 'Today quiz', Icons.replay_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewQuizScreen())), scale)),
        SizedBox(width: 10 * scale),
        Expanded(child: _quickCard('News', _home?.dailyConnect?['title']?.toString() ?? 'Daily Connect', Icons.article_rounded, () => _setTab(2), scale)),
        SizedBox(width: 10 * scale),
        Expanded(child: _quickCard('Simulation', 'Practice quest', Icons.sports_esports_rounded, _openSimulation, scale)),
      ],
    );
  }

  Widget _quickCard(String title, String subtitle, IconData icon, VoidCallback onTap, double scale) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 108 * scale,
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14 * scale)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: themeGreen, size: 24 * scale),
          const Spacer(),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w800, color: brandInk)),
          SizedBox(height: 2 * scale),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11 * scale, color: textMuted)),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Text(title, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w800, color: brandInk));
  }

  List<Widget> _categoryCards(double scale, {int? limit}) {
    final categories = _home?.categories ?? const <HomeCategoryProgress>[];
    final list = limit == null ? categories : categories.take(limit).toList();
    if (list.isEmpty) {
      return [_emptyBox('No learning categories from server yet.', scale)];
    }
    return list.map((category) => Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: _categoryCard(category, scale),
    )).toList();
  }

  Widget _categoryCard(HomeCategoryProgress category, double scale) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CurriculumRoadmapScreen(
              title: category.categoryName.isNotEmpty ? category.categoryName : category.categoryCode,
              categoryCode: category.categoryCode,
            ),
          ),
        );
        _loadHome();
      },
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14 * scale)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(category.categoryName, style: TextStyle(fontSize: 17 * scale, fontWeight: FontWeight.w800, color: brandInk))),
            Text('${category.progressPercent}%', style: TextStyle(fontSize: 13 * scale, color: textMuted, fontWeight: FontWeight.w700)),
          ]),
          SizedBox(height: 12 * scale),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: category.progressPercent.clamp(0, 100) / 100, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation(themeGreen)),
          ),
          SizedBox(height: 10 * scale),
          Text('${category.completedSessionCount}/${category.totalSessionCount} sessions completed', style: TextStyle(color: textMuted, fontSize: 12 * scale)),
        ]),
      ),
    );
  }

  Widget _simulationCard(double scale) {
    return Padding(
      padding: EdgeInsets.only(top: 4 * scale, bottom: 12 * scale),
      child: GestureDetector(
        onTap: _openSimulation,
        child: Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14 * scale)),
          child: Row(children: [
            Container(
              width: 44 * scale,
              height: 44 * scale,
              decoration: BoxDecoration(color: const Color(0xFFEEFFD1), borderRadius: BorderRadius.circular(14 * scale)),
              child: Icon(Icons.sports_esports_rounded, color: const Color(0xFF7BD134), size: 26 * scale),
            ),
            SizedBox(width: 13 * scale),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Simulation quest', style: TextStyle(fontSize: 17 * scale, fontWeight: FontWeight.w800, color: brandInk)),
              SizedBox(height: 3 * scale),
              Text('Practice with scenario screens', style: TextStyle(color: textMuted, fontSize: 12 * scale)),
            ])),
            Icon(Icons.chevron_right_rounded, color: textMuted, size: 26 * scale),
          ]),
        ),
      ),
    );
  }

  Future<void> _openSimulation() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const SimulationQuestListScreen()),
    );
    if (result != null && mounted) {
      _setTab(result);
    }
  }

  Widget _buildLoading(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80 * scale),
      child: const Center(child: CircularProgressIndicator(color: themeGreen)),
    );
  }

  Widget _buildError(double scale) {
    return Column(
      children: [
        _emptyBox(_homeError ?? 'Failed to load.', scale),
        SizedBox(height: 12 * scale),
        ElevatedButton(onPressed: _loadHome, child: const Text('Retry')),
      ],
    );
  }

  Widget _emptyBox(String text, double scale) {
    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14 * scale)),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 14 * scale)),
    );
  }
}
