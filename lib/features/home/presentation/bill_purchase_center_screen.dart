// lib/features/home/presentation/bill_purchase_center_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BillPurchaseCenterScreen extends StatefulWidget {
  const BillPurchaseCenterScreen({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  State<BillPurchaseCenterScreen> createState() => _BillPurchaseCenterScreenState();
}

class _BillPurchaseCenterScreenState extends State<BillPurchaseCenterScreen> {
  int _selectedIdx = 0; // 0: 5개, 1: 10개, 2: 20개
  int _billCount = 5;

  Widget _buildStackedBillIcon(int count) {
    if (count == 1) {
      return SvgPicture.string(
        '''<svg width="29" height="29" viewBox="0 0 29 29" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M2.53516 5.73242H26.6195V21.7886H2.53516V5.73242ZM14.5773 9.74648C15.6419 9.74648 16.6629 10.1694 17.4157 10.9222C18.1685 11.6749 18.5914 12.6959 18.5914 13.7605C18.5914 14.8251 18.1685 15.8461 17.4157 16.5989C16.6629 17.3517 15.6419 17.7746 14.5773 17.7746C13.5127 17.7746 12.4917 17.3517 11.739 16.5989C10.9862 15.8461 10.5633 14.8251 10.5633 13.7605C10.5633 12.6959 10.9862 11.6749 11.739 10.9222C12.4917 10.1694 13.5127 9.74648 14.5773 9.74648ZM7.88723 8.40846C7.88723 9.11819 7.60529 9.79885 7.10344 10.3007C6.60158 10.8026 5.92092 11.0845 5.21119 11.0845V16.4366C5.92092 16.4366 6.60158 16.7185 7.10344 17.2204C7.60529 17.7222 7.88723 18.4029 7.88723 19.1126H21.2674C21.2674 18.4029 21.5493 17.7222 22.0512 17.2204C22.5531 16.7185 23.2337 16.4366 23.9434 16.4366V11.0845C23.2337 11.0845 22.5531 10.8026 22.0512 10.3007C21.5493 9.79885 21.2674 9.11819 21.2674 8.40846H7.88723Z" fill="#00EE94"/>
</svg>''',
        width: 29,
        height: 29,
      );
    } else if (count == 2) {
      return SvgPicture.string(
        '''<svg width="35" height="29" viewBox="0 75 35 29" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M4 83.5H28.0843V99.5562H4V83.5ZM16.0422 87.5141C17.1068 87.5141 18.1277 87.937 18.8805 88.6897C19.6333 89.4425 20.0562 90.4635 20.0562 91.5281C20.0562 92.5927 19.6333 93.6137 18.8805 94.3665C18.1277 95.1193 17.1068 95.5422 16.0422 95.5422C14.9776 95.5422 13.9566 95.1193 13.2038 94.3665C12.451 93.6137 12.0281 92.5927 12.0281 91.5281C12.0281 90.4635 12.451 89.4425 13.2038 88.6897C13.9566 87.937 14.9776 87.5141 16.0422 87.5141ZM9.35207 86.176C9.35207 86.8858 9.07013 87.5664 8.56828 88.0683C8.06643 88.5701 7.38576 88.8521 6.67604 88.8521V94.2041C7.38576 94.2041 8.06643 94.4861 8.56828 94.9879C9.07013 95.4898 9.35207 96.1705 9.35207 96.8802H22.7323C22.7323 96.1705 23.0142 95.4898 23.516 94.9879C24.0179 94.4861 24.6986 94.2041 25.4083 94.2041V88.8521C24.6986 88.8521 24.0179 88.5701 23.516 88.0683C23.0142 88.0683 22.0512 87.2204 22.0512 86.176H9.35207Z" fill="#00EE94"/>
<path d="M8.58398 83.75V80H31.0766V95H26.8593" stroke="#00EE94" stroke-width="2.5"/>
</svg>''',
        width: 35,
        height: 29,
      );
    } else {
      return SvgPicture.string(
        '''<svg width="35" height="29" viewBox="0 0 35 29" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M1 11.5H25.0843V27.5562H1V11.5ZM13.0422 15.5141C14.1068 15.5141 15.1277 15.937 15.8805 16.6897C16.6333 17.4425 17.0562 18.4635 17.0562 19.5281C17.0562 20.5927 16.6333 21.6137 15.8805 22.3665C15.1277 23.1193 14.1068 23.5422 13.0422 23.5422C11.9776 23.5422 10.9566 23.1193 10.2038 22.3665C9.45102 21.6137 9.02811 20.5927 9.02811 19.5281C9.02811 18.4635 9.45102 17.4425 10.2038 16.6897C10.9566 15.937 11.9776 15.5141 13.0422 15.5141ZM6.35207 14.176C6.35207 14.8858 6.07013 15.5664 5.56828 16.0683C5.06643 16.5701 4.38576 16.8521 3.67604 16.8521V22.2041C4.38576 22.2041 5.06643 22.4861 5.56828 22.9879C6.07013 23.4898 6.35207 24.1705 6.35207 24.8802H19.7323C19.7323 24.1705 20.0142 23.4898 20.516 22.9879C21.0179 22.4861 21.6986 22.2041 22.4083 22.2041V16.8521C21.6986 16.8521 21.0179 16.5701 20.516 16.0683C20.0142 15.5664 19.7323 14.8858 19.7323 14.176H6.35207Z" fill="#00EE94"/>
<path d="M5.58398 11.75V8H28.0766V23H23.8593" stroke="#00EE94" stroke-width="2.5"/>
<path d="M9.58398 6.75V3H32.0766V18H27.8593" stroke="#00EE94" stroke-width="2.5"/>
</svg>''',
        width: 35,
        height: 29,
      );
    }
  }

  void _handlePayment() {
    int addedBills = 0;
    if (_selectedIdx == 0) addedBills = 5;
    if (_selectedIdx == 1) addedBills = 10;
    if (_selectedIdx == 2) addedBills = 20;

    setState(() {
      _billCount += addedBills;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('지폐 $addedBills개가 성공적으로 충전되었습니다!'),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        widget.onClose();
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
                  // Title: 지폐 충전
                  const Center(
                    child: Text(
                      '지폐 충전',
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
                  // Subtitle: 현재 보유: 💵 _billCount개
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '현재 보유:',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF),
                          height: 16 / 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.payments_rounded,
                        color: Color(0xFF00EE94),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_billCount개',
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
                  // Option 1: 5개
                  _buildOptionCard(
                    idx: 0,
                    countText: '5개',
                    priceText: '5,000원',
                    stackCount: 1,
                  ),
                  const SizedBox(height: 10),
                  // Option 2: 10개
                  _buildOptionCard(
                    idx: 1,
                    countText: '10개',
                    priceText: '9,000원 (10% 할인)',
                    stackCount: 2,
                  ),
                  const SizedBox(height: 10),
                  // Option 3: 20개
                  _buildOptionCard(
                    idx: 2,
                    countText: '20개',
                    priceText: '16,000원 (20% 할인)',
                    stackCount: 3,
                  ),
                  const SizedBox(height: 20),
                  // Bottom Button: 결제하기
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _handlePayment();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00EE94),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '결제하기',
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

  Widget _buildOptionCard({
    required int idx,
    required String countText,
    required String priceText,
    required int stackCount,
  }) {
    final isSelected = _selectedIdx == idx;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIdx = idx;
        });
      },
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFFA) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00EE94) : const Color(0xFFD0D5E0),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildStackedBillIcon(stackCount),
                const SizedBox(width: 12),
                Text(
                  countText,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 19 / 16,
                  ),
                ),
              ],
            ),
            Text(
              priceText,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF00EE94) : const Color(0xFF9CA3AF),
                letterSpacing: 0.064,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
