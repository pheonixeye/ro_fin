import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../utils/money.dart';

enum MoneySign { none, auto, positive, negative }

class MoneyText extends ConsumerWidget {
  const MoneyText({
    super.key,
    required this.amountMinor,
    this.currencyCode,
    this.sign = MoneySign.none,
    this.color,
    this.style,
    this.withSymbol = true,
    this.hidden = false,
  });

  final int amountMinor;
  final String? currencyCode;
  final MoneySign sign;
  final Color? color;
  final TextStyle? style;
  final bool withSymbol;
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCurrency = ref.watch(currencyCodeProvider);
    final currency = currencyCode ?? baseCurrency;
    final text = hidden
        ? '••••'
        : formatMoney(
            amountMinor.abs(),
            currency,
            withSymbol: withSymbol,
          );

    final prefix = hidden
        ? ''
        : switch (sign) {
            MoneySign.none => '',
            MoneySign.auto => amountMinor < 0 ? '−' : '+',
            MoneySign.positive => '+',
            MoneySign.negative => '−',
          };

    final effectiveColor = color ??
        switch (sign) {
          MoneySign.positive => AppColors.incomeFor(Theme.of(context).brightness),
          MoneySign.negative => AppColors.expenseFor(Theme.of(context).brightness),
          _ => null,
        };

    return Text(
      '$prefix$text',
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: effectiveColor,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      textDirection: TextDirection.ltr,
    );
  }
}
