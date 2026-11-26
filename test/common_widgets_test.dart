import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aims_diabetes/core/theme/app_theme.dart';
import 'package:aims_diabetes/widgets/common/primary_button.dart';
import 'package:aims_diabetes/widgets/common/app_text_field.dart';
import 'package:aims_diabetes/widgets/common/status_pill.dart';
import 'package:aims_diabetes/widgets/common/state_views.dart';

Widget _wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PrimaryButton', () {
    testWidgets('Renders text and handles tap in normal state', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapWithTheme(
        PrimaryButton(
          text: 'Submit',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator and ignores tap when loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapWithTheme(
        PrimaryButton(
          text: 'Loading Test',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Test'), findsNothing);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('Does not invoke callback when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrapWithTheme(
        PrimaryButton(
          text: 'Disabled Test',
          isEnabled: false,
          onPressed: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Disabled Test'));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });

  group('AppTextField', () {
    testWidgets('Renders label, hint, and accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrapWithTheme(
        AppTextField(
          label: 'Email Address',
          hintText: 'Enter your email',
          controller: controller,
        ),
      ));

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('Toggles password visibility when isPassword is true', (tester) async {
      await tester.pumpWidget(_wrapWithTheme(
        const AppTextField(
          label: 'Password',
          isPassword: true,
        ),
      ));

      final textFieldFinder = find.byType(EditableText);
      final initialEditable = tester.widget<EditableText>(textFieldFinder);
      expect(initialEditable.obscureText, isTrue);

      // Tap password visibility toggle
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      final updatedEditable = tester.widget<EditableText>(textFieldFinder);
      expect(updatedEditable.obscureText, isFalse);
    });

    testWidgets('Runs validation correctly', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(_wrapWithTheme(
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Required Field',
            validator: (v) => (v == null || v.isEmpty) ? 'Field cannot be empty' : null,
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Field cannot be empty'), findsOneWidget);
    });
  });

  group('StatusPill', () {
    testWidgets('Renders label with different semantic types', (tester) async {
      await tester.pumpWidget(_wrapWithTheme(
        const Column(
          children: [
            StatusPill(label: 'In Range', type: StatusPillType.success),
            StatusPill(label: 'Elevated', type: StatusPillType.warning),
            StatusPill(label: 'High', type: StatusPillType.danger),
          ],
        ),
      ));

      expect(find.text('In Range'), findsOneWidget);
      expect(find.text('Elevated'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });
  });

  group('StateViews', () {
    testWidgets('SkeletonLoader renders items', (tester) async {
      await tester.pumpWidget(_wrapWithTheme(
        const SkeletonLoader(itemCount: 3),
      ));

      expect(find.byType(SkeletonLoader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('ErrorState shows message and triggers onRetry callback', (tester) async {
      var retried = false;
      await tester.pumpWidget(_wrapWithTheme(
        ErrorState(
          message: 'Failed to load readings',
          onRetry: () => retried = true,
        ),
      ));

      expect(find.text('Failed to load readings'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('EmptyState shows title, message, and triggers action button', (tester) async {
      var actionTriggered = false;
      await tester.pumpWidget(_wrapWithTheme(
        EmptyState(
          title: 'No logs yet',
          message: 'Add your first reading to get started',
          buttonLabel: '+ Add Reading',
          onPressed: () => actionTriggered = true,
        ),
      ));

      expect(find.text('No logs yet'), findsOneWidget);
      expect(find.text('Add your first reading to get started'), findsOneWidget);
      expect(find.text('+ Add Reading'), findsOneWidget);

      await tester.tap(find.text('+ Add Reading'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });
  });
}
