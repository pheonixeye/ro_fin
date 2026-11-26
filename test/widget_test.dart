import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rofin/core/providers/app_providers.dart';
import 'package:rofin/core/widgets/money_text.dart';
import 'package:rofin/main.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [currencyCodeProvider.overrideWithValue('EGP')],
    child: MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

String _textOf(WidgetTester tester) {
  return tester.widget<Text>(find.byType(Text)).data ?? '';
}

void main() {
  testWidgets('MoneyText formats minor units with a positive sign', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const MoneyText(
          amountMinor: 123450,
          sign: MoneySign.positive,
        ),
      ),
    );

    final text = _textOf(tester);
    expect(text, startsWith('+'));
    expect(text, contains('1,234.50'));
  });

  testWidgets('MoneyText hides amounts when requested', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const MoneyText(
          amountMinor: 123450,
          sign: MoneySign.negative,
          hidden: true,
        ),
      ),
    );

    expect(find.text('••••'), findsOneWidget);
  });

  testWidgets('MoneyText uses the negative sign for expenses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const MoneyText(
          amountMinor: 5000,
          sign: MoneySign.negative,
        ),
      ),
    );

    final text = _textOf(tester);
    expect(text, startsWith('−'));
    expect(text, contains('50.00'));
  });

  testWidgets('startup error screen offers a confirmed reset', (
    WidgetTester tester,
  ) async {
    var resetCalled = false;
    await tester.pumpWidget(
      StartupErrorApp(
        error: 'HiveError: bad key',
        onReset: () => resetCalled = true,
      ),
    );

    expect(
      find.text('Rofin could not open its encrypted database'),
      findsOneWidget,
    );
    expect(find.text('Reset local data'), findsOneWidget);

    await tester.tap(find.text('Reset local data'));
    await tester.pumpAndSettle();
    expect(find.text('Reset local data?'), findsOneWidget);
    expect(resetCalled, isFalse);

    await tester.tap(find.text('Delete and reset'));
    await tester.pumpAndSettle();
    expect(resetCalled, isTrue);
  });
}
