// lib/features/home/presentation/heart_recharge_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeartRechargeScreen extends StatefulWidget {
  const HeartRechargeScreen({
    super.key,
    required this.onClose,
    required this.onOpenBillPurchaseCenter,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenBillPurchaseCenter;

  @override
  State<HeartRechargeScreen> createState() => _HeartRechargeScreenState();
}

class _HeartRechargeScreenState extends State<HeartRechargeScreen> {
  int _heartCount = 1;
  int _billCount = 5;
  bool _isUnlimited = false;

  void _chargeOneHeart() {
    if (_isUnlimited || _heartCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('하트가 이미 가득 찼거나 무제한 상태입니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (_billCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지폐가 부족합니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _heartCount += 1;
      _billCount -= 1;
    });
  }

  void _activateUnlimitedHearts() {
    if (_isUnlimited) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 무제한 상태입니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    if (_billCount < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지폐가 부족합니다.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _isUnlimited = true;
      _heartCount = 3;
      _billCount -= 3;
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
                  // Title: 하트 충전
                  const Center(
                    child: Text(
                      '하트 충전',
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
                  // Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '현재',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 14,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF7C7C),
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isUnlimited
                            ? '3/3 (무제한)'
                            : '$_heartCount/3 · 자동 충전까지 2:14:30',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Option 1
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _chargeOneHeart();
                    },
                    child: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2FFFA),
                        border: Border.all(color: const Color(0xFF00EE94), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '즉시 충전',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                        height: 19 / 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '하트 1개 즉시 충전',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9CA3AF),
                                    height: 14 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '💵 지폐 1개',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.064,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Option 2
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _activateUnlimitedHearts();
                    },
                    child: Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD0D5E0), width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: Color(0xFFFF7C7C),
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '즉시 충전',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                        height: 19 / 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '24시간 동안 무제한 학습',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF9CA3AF),
                                    height: 14 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '💵 지폐 3개',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.064,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Close Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onClose();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '닫기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A7282),
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
}
