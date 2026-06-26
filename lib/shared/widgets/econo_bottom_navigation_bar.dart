import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EconoBottomTab { home, learning, connect, battle, my }

class EconoBottomNavigationBar extends StatelessWidget {
  const EconoBottomNavigationBar({
    super.key,
    required this.activeTab,
    this.onTabSelected,
    this.scale = 1,
  });

  final EconoBottomTab activeTab;
  final ValueChanged<EconoBottomTab>? onTabSelected;
  final double scale;

  static const Color activeColor = Color(0xFF626262);
  static const Color inactiveColor = Color(0xFFBCBCBC);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final items = const [
      _BottomTabItem(tab: EconoBottomTab.home, label: 'Home', icon: Icons.home_rounded),
      _BottomTabItem(tab: EconoBottomTab.learning, label: 'Learn', icon: Icons.school_rounded),
      _BottomTabItem(tab: EconoBottomTab.connect, label: 'Connect', icon: Icons.article_rounded, width: 68),
      _BottomTabItem(tab: EconoBottomTab.battle, label: 'Battle', icon: Icons.sports_martial_arts_rounded),
      _BottomTabItem(tab: EconoBottomTab.my, label: 'My', icon: Icons.person_rounded),
    ];

    return Container(
      width: double.infinity,
      height: 77 * scale,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(8 * scale, 8 * scale, 8 * scale, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          final isActive = item.tab == activeTab;
          return item.copyWith(
            color: isActive ? activeColor : inactiveColor,
            scale: scale,
            onTap: () {
              HapticFeedback.lightImpact();
              onTabSelected?.call(item.tab);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _BottomTabItem extends StatelessWidget {
  const _BottomTabItem({
    required this.tab,
    required this.label,
    required this.icon,
    this.color = EconoBottomNavigationBar.inactiveColor,
    this.scale = 1,
    this.width = 56,
    this.onTap,
  });

  final EconoBottomTab tab;
  final String label;
  final IconData icon;
  final Color color;
  final double scale;
  final double width;
  final VoidCallback? onTap;

  _BottomTabItem copyWith({required Color color, required double scale, required VoidCallback onTap}) {
    return _BottomTabItem(
      tab: tab,
      label: label,
      icon: icon,
      color: color,
      scale: scale,
      width: width,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width * scale,
        height: 60 * scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 27 * scale),
            SizedBox(height: 4 * scale),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11 * scale,
                fontWeight: FontWeight.w600,
                color: color,
                height: 14 / 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}