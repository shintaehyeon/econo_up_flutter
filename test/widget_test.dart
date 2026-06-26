import 'package:econo_up_flutter/features/auth/presentation/login_screen.dart';
import 'package:econo_up_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EconoUpApp renders splash and navigates to login', (WidgetTester tester) async {
    await tester.pumpWidget(const EconoUpApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
