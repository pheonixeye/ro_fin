import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/finance_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/money_text.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late String _monthKey;
  CategoryKind _kind = CategoryKind.expense;

  @override
  void initState() {
    super.initState();
    _monthKey = monthKey(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final spaceId = ref.watch(activeSpaceIdProvider);
    final spaces = ref.watch(sortedSpacesProvider);
    final categories = ref.watch(sortedCategoriesProvider);
    final transactions = ref.watch(transactionsProvider).value ?? const [];

    final totals = FinanceService.monthTotals(
      transactions,
      spaceId: spaceId,
      monthKey: _monthKey,
    );
    final series = FinanceService.monthlySeries(
      transactions: transactions,
      spaceId: spaceId,
      endMonthKey: _monthKey,
      count: 6,
    );
    final categoryTotals = FinanceService.categoryTotals(
      transactions: transactions,
      categories: categories,
      kind: _kind,
      spaceId: spaceId,
      monthKey: _monthKey,
    );
    final spaceName = spaceId == 'all'
        ? l10n.allSpaces
        : spaces
                .where((space) => space.id == spaceId)
                .firstOrNull
                ?.localizedName(locale) ??
            l10n.allSpaces;
    final maxPoint = series.fold<int>(
      0,
      (value, point) => math.max(value, math.max(point.incomeMinor, point.expenseMinor)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: () => setState(
                      () => _monthKey = shiftMonthKey(_monthKey, -1),
                    ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          formatMonthKey(_monthKey, locale),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spaceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.next,
                    onPressed: () => setState(
                      () => _monthKey = shiftMonthKey(_monthKey, 1),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          if (_monthKey != monthKey(DateTime.now())) ...<Widget>[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => setState(
                  () => _monthKey = monthKey(DateTime.now()),
                ),
                icon: const Icon(Icons.today_outlined, size: 18),
                label: Text(l10n.thisMonth),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _SummaryCard(
            totals: totals,
            currencyCode: settings.currencyCode,
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.last6Months,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      _LegendDot(
                        color: AppColors.incomeFor(theme.brightness),
                        label: l10n.income,
                      ),
                      const SizedBox(width: 10),
                      _LegendDot(
                        color: AppColors.expenseFor(theme.brightness),
                        label: l10n.expense,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 190,
                    child: maxPoint == 0
                        ? Center(
                            child: Text(
                              l10n.noReportData,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              maxY: maxPoint * 1.22,
                              minY: 0,
                              alignment: BarChartAlignment.spaceEvenly,
                              groupsSpace: 12,
                              barGroups: <BarChartGroupData>[
                                for (var index = 0;
                                    index < series.length;
                                    index++)
                                  BarChartGroupData(
                                    x: index,
                                    barsSpace: 4,
                                    barRods: <BarChartRodData>[
                                      BarChartRodData(
                                        toY: series[index].incomeMinor.toDouble(),
                                        width: 8,
                                        color: AppColors.incomeFor(
                                          theme.brightness,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      BarChartRodData(
                                        toY:
                                            series[index].expenseMinor.toDouble(),
                                        width: 8,
                                        color: AppColors.expenseFor(
                                          theme.brightness,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                              ],
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval:
                                    math.max(1, maxPoint / 4).toDouble(),
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: theme.colorScheme.outlineVariant,
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(),
                                rightTitles: const AxisTitles(),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 52,
                                    interval:
                                        math.max(1, maxPoint / 4).toDouble(),
                                    getTitlesWidget: (value, meta) {
                                      if (value <= 0) {
                                        return const SizedBox.shrink();
                                      }
                                      return SideTitleWidget(
                                        meta: meta,
                                        space: 6,
                                        child: Text(
                                          formatCompactMoney(
                                            value.round(),
                                            settings.currencyCode,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= series.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return SideTitleWidget(
                                        meta: meta,
                                        space: 8,
                                        child: Text(
                                          formatShortMonthKey(
                                            series[index].monthKey,
                                            locale,
                                          ),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true,
                                  getTooltipColor: (group) =>
                                      theme.colorScheme.inverseSurface,
                                  getTooltipItem: (
                                    group,
                                    groupIndex,
                                    rod,
                                    rodIndex,
                                  ) {
                                    final point = series[group.x];
                                    final isIncome = rodIndex == 0;
                                    final amount = isIncome
                                        ? point.incomeMinor
                                        : point.expenseMinor;
                                    return BarTooltipItem(
                                      '${isIncome ? l10n.income : l10n.expense}\n'
                                      '${formatMoney(amount, settings.currencyCode)}',
                                      theme.textTheme.labelMedium!.copyWith(
                                        color:
                                            theme.colorScheme.onInverseSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            duration: const Duration(milliseconds: 250),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.topCategories,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<CategoryKind>(
                    showSelectedIcon: false,
                    segments: <ButtonSegment<CategoryKind>>[
                      ButtonSegment<CategoryKind>(
                        value: CategoryKind.expense,
                        label: Text(l10n.expense),
                      ),
                      ButtonSegment<CategoryKind>(
                        value: CategoryKind.income,
                        label: Text(l10n.income),
                      ),
                    ],
                    selected: <CategoryKind>{_kind},
                    onSelectionChanged: (selection) =>
                        setState(() => _kind = selection.first),
                  ),
                  const SizedBox(height: 16),
                  if (categoryTotals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text(
                          l10n.noReportDataBody,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    for (var index = 0;
                        index < categoryTotals.length;
                        index++) ...<Widget>[
                      _CategoryRow(
                        total: categoryTotals[index],
                        maxAmount: categoryTotals.first.amountMinor,
                        totalMinor: _kind == CategoryKind.expense
                            ? totals.expenseMinor
                            : totals.incomeMinor,
                        locale: locale,
                        currencyCode: settings.currencyCode,
                      ),
                      if (index < categoryTotals.length - 1)
                        const SizedBox(height: 14),
                    ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.insights_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.monthlyOverview),
              subtitle: Text(
                l10n.reportFor(formatMonthKey(_monthKey, locale)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totals,
    required this.currencyCode,
  });

  final MonthTotals totals;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final netColor = totals.netMinor >= 0
        ? AppColors.incomeFor(brightness)
        : AppColors.expenseFor(brightness);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _SummaryColumn(
                label: l10n.totalIncome,
                color: AppColors.incomeFor(brightness),
                icon: Icons.south_west,
                child: MoneyText(
                  amountMinor: totals.incomeMinor,
                  currencyCode: currencyCode,
                  color: AppColors.incomeFor(brightness),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            _VerticalDivider(color: theme.colorScheme.outlineVariant),
            Expanded(
              child: _SummaryColumn(
                label: l10n.totalExpenses,
                color: AppColors.expenseFor(brightness),
                icon: Icons.north_east,
                child: MoneyText(
                  amountMinor: totals.expenseMinor,
                  currencyCode: currencyCode,
                  color: AppColors.expenseFor(brightness),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            _VerticalDivider(color: theme.colorScheme.outlineVariant),
            Expanded(
              child: _SummaryColumn(
                label: l10n.netResult,
                color: netColor,
                icon: Icons.balance,
                child: MoneyText(
                  amountMinor: totals.netMinor,
                  currencyCode: currencyCode,
                  sign: MoneySign.auto,
                  color: netColor,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({
    required this.label,
    required this.color,
    required this.icon,
    required this.child,
  });

  final String label;
  final Color color;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: child),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: color);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.total,
    required this.maxAmount,
    required this.totalMinor,
    required this.locale,
    required this.currencyCode,
  });

  final CategoryTotal total;
  final int maxAmount;
  final int totalMinor;
  final String locale;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final category = total.category;
    final color = category == null ? AppColors.gold : Color(category.color);
    final name = category?.localizedName(locale) ?? l10n.unknownCategory;
    final ratio = maxAmount <= 0 ? 0.0 : total.amountMinor / maxAmount;
    final percent = totalMinor <= 0
        ? 0
        : ((total.amountMinor / totalMinor) * 100).round();

    return Row(
      children: <Widget>[
        CategoryAvatar(
          iconKey: category?.iconKey ?? 'more',
          colorValue: category?.color ?? AppColors.gold.toARGB32(),
          size: 36,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  MoneyText(
                    amountMinor: total.amountMinor,
                    currencyCode: currencyCode,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0).toDouble(),
                  minHeight: 5,
                  color: color,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Text(
            '$percent%',
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
