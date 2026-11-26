import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aims_diabetes/widgets/common/app_logo.dart';

void main() {
  testWidgets('AppLogo widget renders with different variants', (WidgetTester tester) async {
    // Test horizontal logo (default)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(height: 40),
        ),
      ),
    );
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Test onDark factory constructor
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo.onDark(height: 40),
        ),
      ),
    );
    expect(find.byType(AppLogo), findsOneWidget);

    // Test symbol factory constructor
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo.symbol(size: 32),
        ),
      ),
    );
    expect(find.byType(AppLogo), findsOneWidget);
  });
}
