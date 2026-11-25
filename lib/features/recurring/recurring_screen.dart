import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/account.dart';
import '../../core/models/category.dart';
import '../../core/models/enums.dart';
import '../../core/models/recurring_rule.dart';
import '../../core/models/space.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/recurring_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/l10n.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_text.dart';
import '../../l10n/generated/app_localizations.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  String _frequencyLabel(AppLocalizations l10n, RecurringRule rule) {
    return switch (rule.frequency) {
      RecurringFrequency.weekly => l10n.recurringEveryWeeks(rule.interval),
      RecurringFrequency.monthly => l10n.recurringEveryMonths(rule.interval),
      RecurringFrequency.yearly => l10n.recurringEveryYears(rule.interval),
    };
  }

  Future<void> _postNow(
    BuildContext context,
    WidgetRef ref,
    RecurringRule rule,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.postNow,
      message: l10n.postNowMessage,
      confirmLabel: l10n.postNow,
      destructive: false,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final posted = await const RecurringService().postNow(
      rule: rule,
      rules: ref.read(recurringRepositoryProvider),
      transactions: ref.read(transactionsRepositoryProvider),
    );
    if (!context.mounted) {
      return;
    }
    showAppSnack(
      context,
      posted == null ? l10n.lockError : l10n.recurringPosted(1),
    );
  }

  Future<void> _toggle(
    WidgetRef ref,
    RecurringRule rule,
  ) async {
    await ref.read(recurringRepositoryProvider).put(
          rule.copyWith(
            isActive: !rule.isActive,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    RecurringRule rule,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteRecurringTitle,
      message: l10n.deleteRecurringMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed) {
      return;
    }
    await ref.read(recurringRepositoryProvider).delete(rule.id);
    if (context.mounted) {
      showAppSnack(context, l10n.recurringDeleted);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rules = (ref.watch(recurringProvider).value ?? const <RecurringRule>[])
        .toList()
      ..sort((a, b) {
        if (a.isActive != b.isActive) {
          return a.isActive ? -1 : 1;
        }
        return a.nextDueDateKey.compareTo(b.nextDueDateKey);
      });
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    final spaces = ref.watch(spacesProvider).value ?? const <Space>[];
    final today = dateKey(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringRules),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addRecurring,
            onPressed: () => context.push('/recurring/new'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: rules.isEmpty
          ? EmptyState(
              icon: Icons.event_repeat_outlined,
              title: l10n.noRecurring,
              body: l10n.noRecurringBody,
              actionLabel: l10n.addRecurring,
              onAction: () => context.push('/recurring/new'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: <Widget>[
                for (final rule in rules) ...<Widget>[
                  _RecurringCard(
                    rule: rule,
                    frequencyLabel: _frequencyLabel(l10n, rule),
                    category: categories
                        .where((item) => item.id == rule.categoryId)
                        .firstOrNull,
                    account: accounts
                        .where((item) => item.id == rule.accountId)
                        .firstOrNull,
                    toAccount: accounts
                        .where((item) => item.id == rule.toAccountId)
                        .firstOrNull,
                    space: spaces
                        .where((item) => item.id == rule.spaceId)
                        .firstOrNull,
                    dueToday: rule.nextDueDateKey == today,
                    onTap: () => context.push('/recurring/${rule.id}'),
                    onPostNow: () => _postNow(context, ref, rule),
                    onToggle: () => _toggle(ref, rule),
                    onDelete: () => _delete(context, ref, rule),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                Text(
                  l10n.autoPostHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  const _RecurringCard({
    required this.rule,
    required this.frequencyLabel,
    required this.category,
    required this.account,
    required this.toAccount,
    required this.space,
    required this.dueToday,
    required this.onTap,
    required this.onPostNow,
    required this.onToggle,
    required this.onDelete,
  });

  final RecurringRule rule;
  final String frequencyLabel;
  final Category? category;
  final Account? account;
  final Account? toAccount;
  final Space? space;
  final bool dueToday;
  final VoidCallback onTap;
  final VoidCallback onPostNow;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isTransfer = rule.type == TxnType.transfer;
    final color = switch (rule.type) {
      TxnType.income => AppColors.incomeFor(brightness),
      TxnType.expense => AppColors.expenseFor(brightness),
      TxnType.transfer => AppColors.transferFor(brightness),
    };
    final title = isTransfer
        ? '${account?.localizedName(locale) ?? ''} → '
            '${toAccount?.localizedName(locale) ?? ''}'
        : category?.localizedName(locale) ?? l10n.unknownCategory;
    final subtitle = <String>[
      if (rule.note.trim().isNotEmpty) rule.note.trim(),
      if (!isTransfer && account != null) account!.localizedName(locale),
      if (isTransfer) l10n.transfer,
      if (space != null) space!.localizedName(locale),
    ].join(' · ');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CategoryAvatar(
                iconKey: isTransfer ? 'transfer' : (category?.iconKey ?? 'more'),
                colorValue: isTransfer
                    ? AppColors.transfer.toARGB32()
                    : (category?.color ?? 0xFF64748B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!rule.isActive)
                          TypeBadge(
                            label: l10n.paused,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        else if (!rule.autoPost)
                          TypeBadge(
                            label: l10n.custom,
                            color: AppColors.gold,
                          ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.event_repeat_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            frequencyLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (rule.isActive) ...<Widget>[
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Icon(
                            dueToday
                                ? Icons.notifications_active_outlined
                                : Icons.schedule_outlined,
                            size: 13,
                            color: dueToday
                                ? AppColors.gold
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${l10n.nextDue}: '
                              '${dueToday ? l10n.dueToday : formatDateKey(rule.nextDueDateKey, locale)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: dueToday
                                    ? AppColors.gold
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: dueToday
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  MoneyText(
                    amountMinor: rule.amountMinor,
                    currencyCode: account?.currencyCode,
                    sign: switch (rule.type) {
                      TxnType.income => MoneySign.positive,
                      TxnType.expense => MoneySign.negative,
                      TxnType.transfer => MoneySign.none,
                    },
                    color: color,
                    style: theme.textTheme.titleSmall,
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.edit,
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onTap();
                          break;
                        case 'post':
                          onPostNow();
                          break;
                        case 'toggle':
                          onToggle();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(l10n.edit),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'post',
                        child: ListTile(
                          leading: const Icon(Icons.play_circle_outline),
                          title: Text(l10n.postNow),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: ListTile(
                          leading: Icon(
                            rule.isActive
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                          ),
                          title: Text(
                            rule.isActive ? l10n.paused : l10n.active,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          title: Text(
                            l10n.delete,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
