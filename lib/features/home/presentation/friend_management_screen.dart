// lib/features/home/presentation/friend_management_screen.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/econo_bottom_navigation_bar.dart';

class FriendManagementScreen extends StatefulWidget {
  const FriendManagementScreen({
    super.key,
    this.onBack,
    this.onBottomTabSelected,
    this.showBottomNavigation = true,
  });

  final VoidCallback? onBack;
  final ValueChanged<int>? onBottomTabSelected;
  final bool showBottomNavigation;

  static const Color brandInk = Color(0xFF122711);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textButton = Color(0xFF4B5563);
  static const Color iconGrey = Color(0xFF6A7282);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color chipGrey = Color(0xFFF0F2F7);
  static const Color surfaceGrey = Color(0xFFF3F4F6);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color selectedBg = Color(0xFFF2FFFA);
  static const Color fireOrange = Color(0xFFFF6900);

  static const List<_FriendItem> _friends = [
    _FriendItem(name: '김준서', description: '골드 리그 · 14일 연속', streak: true),
    _FriendItem(name: '박태현', description: '실버 리그 · 5일 연속'),
    _FriendItem(name: '이수아', description: '브론즈 리그 · 오늘 미접속'),
  ];

  @override
  State<FriendManagementScreen> createState() => _FriendManagementScreenState();
}

class _FriendManagementScreenState extends State<FriendManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _appliedQuery = '';

  static const Color brandInk = FriendManagementScreen.brandInk;
  static const Color textDark = FriendManagementScreen.textDark;
  static const Color textButton = FriendManagementScreen.textButton;
  static const Color iconGrey = FriendManagementScreen.iconGrey;
  static const Color borderGrey = FriendManagementScreen.borderGrey;
  static const Color chipGrey = FriendManagementScreen.chipGrey;
  static const Color surfaceGrey = FriendManagementScreen.surfaceGrey;
  static const Color themeGreen = FriendManagementScreen.themeGreen;
  static const Color selectedBg = FriendManagementScreen.selectedBg;

  List<_FriendItem> get _visibleFriends {
    final query = _appliedQuery.trim();
    if (query.isEmpty) {
      return FriendManagementScreen._friends;
    }
    return FriendManagementScreen._friends
        .where((friend) => friend.name.contains(query))
        .toList(growable: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  29 * scale,
                  24 * scale,
                  24 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchCard(scale),
                    SizedBox(height: 12 * scale),
                    _buildFriendsSection(context, scale),
                    SizedBox(height: 12 * scale),
                    _buildRequestsSection(scale),
                  ],
                ),
              ),
            ),
            if (widget.showBottomNavigation)
              EconoBottomNavigationBar(
                activeTab: EconoBottomTab.my,
                onTabSelected: (tab) => widget.onBottomTabSelected?.call(_indexForBottomTab(tab)),
                scale: scale,
              ),
          ],
        ),
      ),
    );

    if (!widget.showBottomNavigation) {
      return ColoredBox(color: Colors.white, child: content);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: content),
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
                    size: 26 * scale,
                    color: iconGrey,
                  ),
                ),
              ),
            ),
            Text(
              '친구 관리',
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

  Widget _buildSearchCard(double scale) {
    return Container(
      height: 73 * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 13 * scale,
                  color: iconGrey,
                ),
                SizedBox(width: 2 * scale),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _applySearch(),
                    textInputAction: TextInputAction.search,
                    cursorColor: themeGreen,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '닉네임으로 친구 찾기',
                    ),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: textDark,
                      height: 14 / 12,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          _SmallPillButton(
            label: '검색',
            width: 56,
            backgroundColor: surfaceGrey,
            textColor: iconGrey,
            scale: scale,
            onTap: _applySearch,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsSection(BuildContext context, double scale) {
    final friends = _visibleFriends;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(text: '친구 목록 ${friends.length}명', scale: scale),
        SizedBox(height: 10 * scale),
        for (var i = 0; i < friends.length; i++) ...[
          _FriendCard(
            item: friends[i],
            scale: scale,
            onDelete: () => _showDeleteDialog(context),
          ),
          if (i != friends.length - 1) SizedBox(height: 10 * scale),
        ],
      ],
    );
  }

  void _applySearch() {
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _appliedQuery = _searchController.text;
    });
  }

  Widget _buildRequestsSection(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(text: '받은 친구 요청 1개', scale: scale),
        SizedBox(height: 10 * scale),
        Container(
          height: 73 * scale,
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: selectedBg,
            border: Border.all(color: themeGreen, width: 1 * scale),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Row(
            children: [
              _Avatar(scale: scale),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _FriendTextBlock(
                  name: '경제마스터',
                  description: '친구 요청 보냄',
                  scale: scale,
                ),
              ),
              SizedBox(width: 8 * scale),
              Row(
                children: [
                  _SmallPillButton(
                    label: '거절',
                    width: 49.18,
                    backgroundColor: chipGrey,
                    textColor: textButton,
                    scale: scale,
                    onTap: HapticFeedback.lightImpact,
                  ),
                  SizedBox(width: 5 * scale),
                  _SmallPillButton(
                    label: '수락',
                    width: 49.18,
                    backgroundColor: themeGreen,
                    textColor: textButton,
                    scale: scale,
                    onTap: HapticFeedback.lightImpact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final scale = (screenWidth / 447.0).clamp(0.0, 1.0).toDouble();

        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: FriendDeleteConfirmDialog(scale: scale),
        );
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.scale,
  });

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28 * scale,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: FriendManagementScreen.brandInk,
            height: 19 / 16,
            letterSpacing: -0.439453 * scale,
          ),
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.item,
    required this.scale,
    required this.onDelete,
  });

  final _FriendItem item;
  final double scale;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73 * scale,
      padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 18 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FriendManagementScreen.borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          _Avatar(scale: scale),
          SizedBox(width: 8 * scale),
          Expanded(
            child: _FriendTextBlock(
              name: item.name,
              description: item.description,
              showFire: item.streak,
              scale: scale,
            ),
          ),
          SizedBox(width: 8 * scale),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
            child: SizedBox(
              width: 28 * scale,
              height: 28 * scale,
              child: Icon(
                Icons.delete_outline_rounded,
                size: 22 * scale,
                color: FriendManagementScreen.iconGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTextBlock extends StatelessWidget {
  const _FriendTextBlock({
    required this.name,
    required this.description,
    required this.scale,
    this.showFire = false,
  });

  final String name;
  final String description;
  final double scale;
  final bool showFire;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40 * scale,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: FriendManagementScreen.textDark,
              height: 20 / 16,
            ),
          ),
          SizedBox(height: 3 * scale),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: FriendManagementScreen.textMuted,
                    height: 14 / 12,
                  ),
                ),
              ),
              if (showFire) ...[
                SizedBox(width: 2 * scale),
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 15 * scale,
                  color: FriendManagementScreen.fireOrange,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40 * scale,
      height: 40 * scale,
      decoration: const BoxDecoration(
        color: FriendManagementScreen.surfaceGrey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SmallPillButton extends StatelessWidget {
  const _SmallPillButton({
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double width;
  final Color backgroundColor;
  final Color textColor;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width * scale,
      height: 22.58 * scale,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(width * scale, 22.58 * scale),
          backgroundColor: backgroundColor,
          shape: StadiumBorder(),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11 * scale,
            fontWeight: FontWeight.w500,
            color: textColor,
            height: 13 / 11,
          ),
        ),
      ),
    );
  }
}

class FriendDeleteConfirmDialog extends StatelessWidget {
  const FriendDeleteConfirmDialog({
    super.key,
    required this.scale,
  });

  final double scale;

  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color buttonText = Color(0xFF4B5563);
  static const Color borderGrey = Color(0xFFD0D5E0);
  static const Color themeGreen = Color(0xFF00EE94);
  static const Color cancelBg = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 335 * scale,
      height: 222 * scale,
      padding: EdgeInsets.fromLTRB(34 * scale, 22 * scale, 34 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey, width: 1 * scale),
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 266 * scale,
            height: 109 * scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30 * scale,
                  height: 31.67 * scale,
                  child: CustomPaint(
                    painter: _SadFacePainter(color: themeGreen),
                  ),
                ),
                SizedBox(height: 14 * scale),
                SizedBox(
                  width: 266 * scale,
                  height: 49 * scale,
                  child: Column(
                    children: [
                      Text(
                        '정말 삭제하시겠습니까?',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 18 * scale,
                          height: 26 / 18,
                          color: textDark,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        '한번 삭제하면 돌릴 수 없습니다.',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 13 * scale,
                          height: 16 / 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 21 * scale),
          SizedBox(
            width: 266 * scale,
            height: 38 * scale,
            child: Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: '취소',
                    backgroundColor: cancelBg,
                    textColor: buttonText,
                    fontWeight: FontWeight.w500,
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _DialogButton(
                    label: '삭제',
                    backgroundColor: themeGreen,
                    textColor: buttonText,
                    fontWeight: FontWeight.w700,
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.fontWeight,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38 * scale,
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.fromHeight(38 * scale),
          backgroundColor: backgroundColor,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: fontWeight,
            fontSize: 10 * scale,
            height: 13 / 10,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _SadFacePainter extends CustomPainter {
  const _SadFacePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const viewportWidth = 30.0;
    const viewportHeight = 31.67;
    final unit = math.min(size.width / viewportWidth, size.height / viewportHeight);
    final origin = Offset(
      (size.width - viewportWidth * unit) / 2,
      (size.height - viewportHeight * unit) / 2,
    );
    Offset p(double x, double y) => origin + Offset(x * unit, y * unit);
    double u(double value) => value * unit;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = u(3.33)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final tearEdge = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = u(0.95)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final faceRect = Rect.fromCircle(
      center: p(15.05, 15.35),
      radius: u(13.30),
    );
    canvas.drawArc(
      faceRect,
      -math.pi * 1.08,
      math.pi * 1.86,
      false,
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: p(10.30, 10.85),
          width: u(2.55),
          height: u(4.25),
        ),
        Radius.circular(u(1.30)),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: p(19.55, 10.85),
          width: u(2.55),
          height: u(4.25),
        ),
        Radius.circular(u(1.30)),
      ),
      fill,
    );

    final mouth = Path()
      ..moveTo(p(14.70, 18.90).dx, p(14.70, 18.90).dy)
      ..cubicTo(
        p(18.60, 17.95).dx,
        p(18.60, 17.95).dy,
        p(23.20, 20.40).dx,
        p(23.20, 20.40).dy,
        p(23.70, 24.25).dx,
        p(23.70, 24.25).dy,
      );
    canvas.drawPath(mouth, stroke);

    final tear = Path()
      ..moveTo(p(7.50, 16.67).dx, p(7.50, 16.67).dy)
      ..cubicTo(
        p(5.35, 19.45).dx,
        p(5.35, 19.45).dy,
        p(3.33, 22.85).dx,
        p(3.33, 22.85).dy,
        p(3.33, 24.45).dx,
        p(3.33, 24.45).dy,
      )
      ..cubicTo(
        p(3.33, 26.95).dx,
        p(3.33, 26.95).dy,
        p(5.18, 28.34).dx,
        p(5.18, 28.34).dy,
        p(7.50, 28.34).dx,
        p(7.50, 28.34).dy,
      )
      ..cubicTo(
        p(9.86, 28.34).dx,
        p(9.86, 28.34).dy,
        p(11.66, 26.88).dx,
        p(11.66, 26.88).dy,
        p(11.66, 24.35).dx,
        p(11.66, 24.35).dy,
      )
      ..cubicTo(
        p(11.66, 22.72).dx,
        p(11.66, 22.72).dy,
        p(9.70, 19.42).dx,
        p(9.70, 19.42).dy,
        p(7.50, 16.67).dx,
        p(7.50, 16.67).dy,
      )
      ..close();
    canvas.drawPath(tear, tearEdge);
    canvas.drawPath(tear, fill);
  }

  @override
  bool shouldRepaint(covariant _SadFacePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _FriendItem {
  const _FriendItem({
    required this.name,
    required this.description,
    this.streak = false,
  });

  final String name;
  final String description;
  final bool streak;
}
