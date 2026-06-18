import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_personal_app/features/dashboard/presentation/widgets/savings_ring.dart';

void main() {
  group('SavingsRing widget', () {
    Widget buildWidget({int current = 0, int goal = 100000}) {
      return MaterialApp(
        home: Scaffold(
          body: SavingsRing(
            currentAmount: current,
            goalAmount: goal,
          ),
        ),
      );
    }

    testWidgets('displays percentage text', (tester) async {
      await tester.pumpWidget(buildWidget(current: 50000, goal: 100000));
      await tester.pumpAndSettle();

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('displays 0% when no progress', (tester) async {
      await tester.pumpWidget(buildWidget(current: 0, goal: 100000));
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('displays 100% when goal is met', (tester) async {
      await tester.pumpWidget(buildWidget(current: 100000, goal: 100000));
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('displays section title', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ahorro del mes'), findsOneWidget);
    });

    testWidgets('displays formatted amounts', (tester) async {
      await tester.pumpWidget(buildWidget(current: 135000, goal: 200000));
      await tester.pumpAndSettle();

      expect(find.text('\$1,350.00'), findsOneWidget);
      expect(find.text('de \$2,000.00'), findsOneWidget);
    });

    testWidgets('handles zero goal gracefully', (tester) async {
      await tester.pumpWidget(buildWidget(current: 0, goal: 0));
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
    });
  });
}
