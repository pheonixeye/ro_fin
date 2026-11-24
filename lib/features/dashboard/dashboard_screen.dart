import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/finance_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hideAmounts = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final data = ref.watch(dashboardDataProvider);
    final balances = ref.watch(accountBalancesProvider);
    final now = DateTime.now();
    final currentMonth = monthKey(now);
    final activeSpace = data.spaces
        .where((space) => space.id == data.activeSpaceId)
        .firstOrNull;

    final greeting = switch (now.hour) {
      < 12 => l10n.goodMorning,
      < 17 => l10n.goodAfternoon,
      _ => l10n.goodEvening,
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              greeting,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${l10n.appName} · ${formatMonthKey(currentMonth, locale)}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        actions: <Widget>[
          if (settings.lockEnabled)
            IconButton(
              tooltip: l10n.lockNow,
              onPressed: () =>
                  ref.read(appLockProvider.notifier).lock(),
              icon: const Icon(Icons.lock_outline),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        children: <Widget>[
          _SpaceFilter(
            selectedSpaceId: settings.activeSpaceId,
            onChanged: (spaceId) =>
                ref.read(settingsProvider.notifier).setActiveSpace(spaceId),
          ),
          const SizedBox(height: 16),
          _BalanceCard(
            totalBalanceMinor: data.totalBalanceMinor,
            monthTotals: data.monthTotals,
            hidden: _hideAmounts,
            onToggleHidden: () =>
                setState(() => _hideAmounts = !_hideAmounts),
            spaceLabel: activeSpace?.localizedName(locale) ?? l10n.allSpaces,
            spaceColor: activeSpace == null
                ? AppColors.gold
                : Color(activeSpace.color),
            accountsCount: data.accounts.length,
            accountsLabel: l10n.accounts,
            totalBalanceLabel: l10n.totalBalance,
            netLabel: l10n.netThisMonth,
            showLabel: l10n.showAmounts,
            hideLabel: l10n.hideAmounts,
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricCard(
                  label: l10n.incomeThisMonth,
                  icon: Icons.south_west,
                  color: AppColors.incomeFor(theme.brightness),
                  child: MoneyText(
                    amountMinor: data.monthTotals.incomeMinor,
                    hidden: _hideAmounts,
                    color: AppColors.incomeFor(theme.brightness),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: l10n.expensesThisMonth,
                  icon: Icons.north_east,
                  color: AppColors.expenseFor(theme.brightness),
                  child: MoneyText(
                    amountMinor: data.monthTotals.expenseMinor,
                    hidden: _hideAmounts,
                    color: AppColors.expenseFor(theme.brightness),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _QuickActions(
            onIncome: () => context.push('/transaction/new?type=income'),
            onExpense: () => context.push('/transaction/new?type=expense'),
            onTransfer: () => context.push('/transaction/new?type=transfer'),
            onAccounts: () => context.push('/accounts'),
          ),
          if (balances.isNotEmpty) ...<Widget>[
            const SizedBox(height: 26),
            SectionTitle(
              title: l10n.accounts,
              actionLabel: l10n.seeAll,
              onAction: () => context.push('/accounts'),
            ),
            SizedBox(
              height: 102,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: balances.length > 6 ? 6 : balances.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = balances[index];
                  return _AccountChip(
                    name: item.account.localizedName(locale),
                    type: item.account.type,
                    color: Color(item.account.color),
                    iconKey: item.account.iconKey,
                    balance: MoneyText(
                      amountMinor: item.balanceMinor,
                      currencyCode: item.account.currencyCode,
                      hidden: _hideAmounts,
                      style: theme.textTheme.titleSmall,
                    ),
                    onTap: () => context.push('/accounts'),
                  );
                },
              ),
            ),
          ],
          if (data.budgetProgress.isNotEmpty) ...<Widget>[
            const SizedBox(height: 26),
            SectionTitle(
              title: l10n.budgets,
              actionLabel: l10n.seeAll,
              onAction: () => context.push('/budgets'),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    for (final progress
                        in data.budgetProgress.take(3)) ...<Widget>[
                      _BudgetRow(
                        progress: progress,
                        hidden: _hideAmounts,
                        locale: locale,
                        currencyCode: settings.currencyCode,
                      ),
                      if (progress != data.budgetProgress.take(3).last)
                        const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (data.expenseCategories.isNotEmpty) ...<Widget>[
            const SizedBox(height: 26),
            SectionTitle(
              title: l10n.spendingByCategory,
              actionLabel: l10n.seeAll,
              onAction: () => context.go('/reports'),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _CategoryBreakdown(
                  totals: data.expenseCategories.take(4).toList(),
                  totalMinor: data.monthTotals.expenseMinor,
                  hidden: _hideAmounts,
                  locale: locale,
                ),
              ),
            ),
          ],
          const SizedBox(height: 26),
          SectionTitle(
            title: l10n.recentTransactions,
            actionLabel: l10n.seeAll,
            onAction: () => context.go('/transactions'),
          ),
          if (data.recentTransactions.isEmpty)
            Card(
              child: EmptyState(
                compact: true,
                icon: Icons.receipt_long_outlined,
                title: l10n.noTransactions,
                body: l10n.noTransactionsBody,
                actionLabel: l10n.addTransaction,
                onAction: () => context.push('/transaction/new'),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    for (var index = 0;
                        index < data.recentTransactions.length;
                        index++) ...<Widget>[
                      TransactionTile(
                        txn: data.recentTransactions[index],
                        showSpace: data.activeSpaceId == 'all',
                        onTap: () => context.push(
                          '/transaction/${data.recentTransactions[index].id}',
                        ),
                      ),
                      if (index < data.recentTransactions.length - 1)
                        Divider(
                          indent: 58,
                          color: theme.colorScheme.outlineVariant,
                        ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpaceFilter extends ConsumerWidget {
  const _SpaceFilter({
    required this.selectedSpaceId,
    required this.onChanged,
  });

  final String selectedSpaceId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final spaces = ref.watch(sortedSpacesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          ChoiceChip(
            label: Text(l10n.allSpaces),
            selected: selectedSpaceId == 'all',
            onSelected: (_) => onChanged('all'),
          ),
          for (final space in spaces) ...<Widget>[
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: Icon(
                space.kind == SpaceKind.business
                    ? Icons.storefront_outlined
                    : Icons.person_outline,
                size: 16,
              ),
              label: Text(space.localizedName(locale)),
              selected: selectedSpaceId == space.id,
              onSelected: (_) => onChanged(space.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.totalBalanceMinor,
    required this.monthTotals,
    required this.hidden,
    required this.onToggleHidden,
    required this.spaceLabel,
    required this.spaceColor,
    required this.accountsCount,
    required this.accountsLabel,
    required this.totalBalanceLabel,
    required this.netLabel,
    required this.showLabel,
    required this.hideLabel,
  });

  final int totalBalanceMinor;
  final MonthTotals monthTotals;
  final bool hidden;
  final VoidCallback onToggleHidden;
  final String spaceLabel;
  final Color spaceColor;
  final int accountsCount;
  final String accountsLabel;
  final String totalBalanceLabel;
  final String netLabel;
  final String showLabel;
  final String hideLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final netColor = monthTotals.netMinor >= 0
        ? AppColors.incomeDark
        : AppColors.expenseDark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[AppColors.tealDeep, const Color(0xFF0A2B28)]
              : <Color>[AppColors.tealDeep, AppColors.teal],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.teal.withValues(alpha: isDark ? 0.18 : 0.24),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: spaceColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            spaceLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onToggleHidden,
                      tooltip: hidden ? showLabel : hideLabel,
                      icon: Icon(
                        hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  totalBalanceLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: MoneyText(
                    amountMinor: totalBalanceMinor,
                    hidden: hidden,
                    color: Colors.white,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Icon(
                      monthTotals.netMinor >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 18,
                      color: netColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      netLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MoneyText(
                      amountMinor: monthTotals.netMinor,
                      hidden: hidden,
                      sign: MoneySign.auto,
                      color: netColor,
                      style: theme.textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$accountsCount $accountsLabel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
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
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onIncome,
    required this.onExpense,
    required this.onTransfer,
    required this.onAccounts,
  });

  final VoidCallback onIncome;
  final VoidCallback onExpense;
  final VoidCallback onTransfer;
  final VoidCallback onAccounts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _QuickAction(
              icon: Icons.south_west,
              label: l10n.incomeShort,
              color: AppColors.incomeFor(theme.brightness),
              onTap: onIncome,
            ),
          ),
          Expanded(
            child: _QuickAction(
              icon: Icons.north_east,
              label: l10n.expenseShort,
              color: AppColors.expenseFor(theme.brightness),
              onTap: onExpense,
            ),
          ),
          Expanded(
            child: _QuickAction(
              icon: Icons.swap_horiz,
              label: l10n.transferShort,
              color: AppColors.transferFor(theme.brightness),
              onTap: onTransfer,
            ),
          ),
          Expanded(
            child: _QuickAction(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.accounts,
              color: AppColors.gold,
              onTap: onAccounts,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.name,
    required this.type,
    required this.color,
    required this.iconKey,
    required this.balance,
    required this.onTap,
  });

  final String name;
  final AccountType type;
  final Color color;
  final String iconKey;
  final Widget balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 156,
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        AppIcons.forKey(iconKey),
                        size: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: balance,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.progress,
    required this.hidden,
    required this.locale,
    required this.currencyCode,
  });

  final BudgetProgress progress;
  final bool hidden;
  final String locale;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = progress.isOver
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final name = progress.category?.localizedName(locale) ?? l10n.overallBudget;
    final spent = hidden
        ? '••••'
        : formatMoney(progress.spentMinor, currencyCode);
    final budget = hidden
        ? '••••'
        : formatMoney(progress.budget.amountMinor, currencyCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Text(
              l10n.ofBudget(spent, budget),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.ratio.clamp(0.0, 1.0).toDouble(),
            minHeight: 7,
            color: color,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.totals,
    required this.totalMinor,
    required this.hidden,
    required this.locale,
  });

  final List<CategoryTotal> totals;
  final int totalMinor;
  final bool hidden;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = totals.isEmpty ? 1 : totals.first.amountMinor;
    return Column(
      children: <Widget>[
        for (var index = 0; index < totals.length; index++) ...<Widget>[
          _CategoryRow(
            total: totals[index],
            maxAmount: maxAmount,
            totalMinor: totalMinor,
            hidden: hidden,
            locale: locale,
          ),
          if (index < totals.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.total,
    required this.maxAmount,
    required this.totalMinor,
    required this.hidden,
    required this.locale,
  });

  final CategoryTotal total;
  final int maxAmount;
  final int totalMinor;
  final bool hidden;
  final String locale;

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
          colorValue: category?.color ?? 0xFF64748B,
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
                    hidden: hidden,
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
