import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_personal_app/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FinanceApp()),
    );
    expect(find.text('Finanzas Personales'), findsOneWidget);
  });
}
