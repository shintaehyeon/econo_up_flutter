import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/econo_bottom_navigation_bar.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/my_page_api.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({
    super.key,
    this.onBottomTabSelected,
    this.onOpenSettings,
    this.showBottomNavigation = true,
  });

  final ValueChanged<int>? onBottomTabSelected;
  final VoidCallback? onOpenSettings;
  final bool showBottomNavigation;

  static const Color brandInk = Color(0xFF122711);
  static const Color textMuted = Color(0xFF6A7282);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color borderGrey = Color(0xFFD0D5E0);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late final ApiClient _client;
  late final MyPageApi _api;

  MyPageData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = ApiClient(accessTokenProvider: AuthSession.accessToken, onUnauthorized: AuthSession.clear);
    _api = MyPageApi(_client);
    _load();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _load() async {
    if (!AuthSession.hasAccessToken) {
      _goToLogin();
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.summary();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
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
        _error = 'Could not load my page.';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);
    final scale = contentWidth >= 390 ? 1.0 : contentWidth / 390.0;

    final content = Center(
      child: SizedBox(
        width: contentWidth,
        height: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: RefreshIndicator(onRefresh: _load, child: _buildScroll(scale))),
          if (widget.showBottomNavigation)
            EconoBottomNavigationBar(activeTab: EconoBottomTab.my, onTabSelected: (tab) => widget.onBottomTabSelected?.call(_indexFor(tab)), scale: scale),
        ]),
      ),
    );

    if (!widget.showBottomNavigation) {
      return ColoredBox(color: Colors.white, child: content);
    }
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(bottom: false, child: content));
  }

  Widget _buildScroll(double scale) {
    return ListView(padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 24 * scale), children: [
      _header(scale),
      SizedBox(height: 18 * scale),
      if (_isLoading) Padding(padding: EdgeInsets.only(top: 120 * scale), child: const Center(child: CircularProgressIndicator(color: MyPageScreen.themeGreen))),
      if (_error != null) _errorBox(scale),
      if (!_isLoading && _error == null && _data != null) ...[
        _profileCard(_data!, scale),
        SizedBox(height: 14 * scale),
        _statsCard(_data!, scale),
        SizedBox(height: 18 * scale),
        _characters(_data!, scale),
        SizedBox(height: 18 * scale),
        _calendar(_data!, scale),
      ],
    ]);
  }

  Widget _header(double scale) {
    return Row(children: [
      Text('My page', style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, color: MyPageScreen.brandInk)),
      const Spacer(),
      IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget.onOpenSettings?.call();
        },
        icon: const Icon(Icons.settings_rounded, color: MyPageScreen.textMuted),
      ),
    ]);
  }

  Widget _profileCard(MyPageData data, double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: _cardDecoration(scale),
      child: Row(children: [
        CircleAvatar(radius: 34 * scale, backgroundColor: const Color(0xFFF2FFFA), child: Icon(Icons.person_rounded, color: MyPageScreen.themeGreen, size: 36 * scale)),
        SizedBox(width: 14 * scale),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.nickname.isEmpty ? 'Econo learner' : data.nickname, style: TextStyle(fontSize: 19 * scale, fontWeight: FontWeight.w900, color: MyPageScreen.brandInk)),
          SizedBox(height: 4 * scale),
          Text('Equipped: ${data.equippedCharacterId.isEmpty ? 'none' : data.equippedCharacterId}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: MyPageScreen.textMuted, fontSize: 12 * scale)),
        ])),
      ]),
    );
  }

  Widget _statsCard(MyPageData data, double scale) {
    return Row(children: [
      Expanded(child: _stat('Streak', '${data.streakDays}', Icons.local_fire_department_rounded, const Color(0xFFFF6900), scale)),
      SizedBox(width: 10 * scale),
      Expanded(child: _stat('League', data.leagueTier.isEmpty ? '-' : data.leagueTier, Icons.emoji_events_rounded, const Color(0xFFF59E0B), scale)),
      SizedBox(width: 10 * scale),
      Expanded(child: _stat('Crowns', '${data.crowns}', Icons.workspace_premium_rounded, MyPageScreen.themeGreen, scale)),
    ]);
  }

  Widget _stat(String label, String value, IconData icon, Color color, double scale) {
    return Container(
      padding: EdgeInsets.all(13 * scale),
      decoration: _cardDecoration(scale),
      child: Column(children: [
        Icon(icon, color: color, size: 24 * scale),
        SizedBox(height: 8 * scale),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, color: MyPageScreen.brandInk)),
        SizedBox(height: 2 * scale),
        Text(label, style: TextStyle(fontSize: 11 * scale, color: MyPageScreen.textMuted)),
      ]),
    );
  }

  Widget _characters(MyPageData data, double scale) {
    return _section('Characters', data.characters.isEmpty ? [const Text('No character data from server yet.')] : data.characters.map((character) {
      final name = '${character['name'] ?? character['characterId'] ?? character['id'] ?? 'Character'}';
      final level = '${character['level'] ?? character['growthLevel'] ?? '-'}';
      return ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.auto_awesome_rounded, color: MyPageScreen.themeGreen), title: Text(name), trailing: Text('Lv $level'));
    }).toList(), scale);
  }

  Widget _calendar(MyPageData data, double scale) {
    final days = data.calendar.take(14).toList();
    return _section('Learning records', [
      Wrap(
        spacing: 6 * scale,
        runSpacing: 6 * scale,
        children: days.isEmpty
            ? [const Text('No learning record data from server yet.')]
            : days.map((day) {
                final completed = day['completed'] == true || day['learned'] == true;
                return Container(width: 18 * scale, height: 18 * scale, decoration: BoxDecoration(color: completed ? MyPageScreen.themeGreen : const Color(0xFFE4E8F0), borderRadius: BorderRadius.circular(4 * scale)));
              }).toList(),
      ),
    ], scale);
  }

  Widget _section(String title, List<Widget> children, double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: _cardDecoration(scale),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w900, color: MyPageScreen.brandInk)),
        SizedBox(height: 10 * scale),
        ...children,
      ]),
    );
  }

  Widget _errorBox(double scale) => Column(children: [Text(_error!, textAlign: TextAlign.center), SizedBox(height: 12 * scale), ElevatedButton(onPressed: _load, child: const Text('Retry'))]);

  BoxDecoration _cardDecoration(double scale) => BoxDecoration(color: Colors.white, border: Border.all(color: MyPageScreen.borderGrey), borderRadius: BorderRadius.circular(14 * scale));

  int _indexFor(EconoBottomTab tab) {
    return switch (tab) {
      EconoBottomTab.home => 0,
      EconoBottomTab.learning => 1,
      EconoBottomTab.connect => 2,
      EconoBottomTab.battle => 3,
      EconoBottomTab.my => 4,
    };
  }
}