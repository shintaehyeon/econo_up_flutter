// lib/features/home/presentation/interest_area_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InterestAreaSettingsScreen extends StatefulWidget {
  const InterestAreaSettingsScreen({
    super.key,
    this.onBack,
    this.onBottomTabSelected,
    this.showBottomNavigation = true,
  });

  final VoidCallback? onBack;
  final ValueChanged<int>? onBottomTabSelected;
  final bool showBottomNavigation;

  @override
  State<InterestAreaSettingsScreen> createState() => _InterestAreaSettingsScreenState();
}

class _InterestAreaSettingsScreenState extends State<InterestAreaSettingsScreen> {
  final List<String> _selectedIds = ['economy', 'saving'];

  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: 'economy', label: '📊 경제 상식'),
    _CategoryItem(id: 'saving', label: '💰 저축'),
    _CategoryItem(id: 'stock', label: '📈 주식'),
    _CategoryItem(id: 'real_estate', label: '🏠 부동산'),
    _CategoryItem(id: 'tax', label: '🧾 세금'),
  ];

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('관심 분야가 저장되었습니다.'),
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (widget.onBack != null) {
          widget.onBack!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth.clamp(0.0, 447.0);

    return Center(
      child: Container(
        width: contentWidth,
        height: double.infinity,
        color: const Color(0xFFCFCFCF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 63,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Title: 관심 분야 수정
                  const Center(
                    child: Text(
                      '관심 분야 수정',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E2A3A),
                        height: 28 / 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Subtitle: 홈 화면에 표시할 학습 카테고리
                  const Center(
                    child: Text(
                      '홈 화면에 표시할 학습 카테고리',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                        height: 16 / 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Category Grid
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildCategoryButton(_categories[0])),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCategoryButton(_categories[1])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildCategoryButton(_categories[2])),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCategoryButton(_categories[3])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryButton(_categories[4], isFullWidth: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bottom Button: 저장
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _saveSettings();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00EE94),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 51),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(_CategoryItem item, {bool isFullWidth = false}) {
    final isSelected = _selectedIds.contains(item.id);
    final selectedOrder = isSelected ? _selectedIds.indexOf(item.id) + 1 : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _toggleCategory(item.id);
      },
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (selectedOrder != null) ...[
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF00EE94),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$selectedOrder',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 16 / 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              item.label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
                height: 16 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}
