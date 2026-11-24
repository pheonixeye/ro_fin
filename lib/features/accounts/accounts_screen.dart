import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/account.dart';
import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/finance_service.dart';
import '../../core/utils/l10n.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_text.dart';
import '../../l10n/generated/app_localizations.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final transactions = ref.watch(transactionsProvider).value ?? const [];
    final balances = FinanceService.accountBalances(
      accounts,
      transactions,
      includeArchived: true,
    );
    final total = FinanceService.totalBalance(accounts, transactions);
    final active = balances
        .where((item) => !item.account.archived)
        .toList(growable: false);
    final archived = balances
        .where((item) => item.account.archived)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addAccount,
            onPressed: () => context.push('/account/new'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: accounts.isEmpty
          ? EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.noAccounts,
              body: l10n.noAccountsBody,
              actionLabel: l10n.addAccount,
              onAction: () => context.push('/account/new'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.totalBalance,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      MoneyText(
                        amountMinor: total,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final item in active) ...<Widget>[
                  _AccountCard(
                    account: item.account,
                    balanceMinor: item.balanceMinor,
                    locale: locale,
                  ),
                  const SizedBox(height: 10),
                ],
                if (archived.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  SectionTitle(title: l10n.archived),
                  for (final item in archived) ...<Widget>[
                    _AccountCard(
                      account: item.account,
                      balanceMinor: item.balanceMinor,
                      locale: locale,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({
    required this.account,
    required this.balanceMinor,
    required this.locale,
  });

  final Account account;
  final int balanceMinor;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/account/${account.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            children: <Widget>[
              CategoryAvatar(
                iconKey: account.iconKey,
                colorValue: account.color,
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
                            account.localizedName(locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (account.archived) ...<Widget>[
                          const SizedBox(width: 8),
                          TypeBadge(
                            label: l10n.archived,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _typeLabel(l10n, account.type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MoneyText(
                amountMinor: balanceMinor,
                currencyCode: account.currencyCode,
                style: theme.textTheme.titleSmall,
              ),
              PopupMenuButton<String>(
                tooltip: l10n.edit,
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      context.push('/account/${account.id}');
                      break;
                    case 'archive':
                      await ref.read(accountsRepositoryProvider).put(
                            account.copyWith(
                              archived: !account.archived,
                              updatedAt: DateTime.now(),
                            ),
                          );
                      break;
                    case 'delete':
                      final confirmed = await showConfirmDialog(
                        context,
                        title: l10n.deleteAccountTitle,
                        message: l10n.deleteAccountMessage,
                        confirmLabel: l10n.delete,
                      );
                      if (confirmed) {
                        await ref
                            .read(accountsRepositoryProvider)
                            .delete(account.id);
                        if (context.mounted) {
                          showAppSnack(context, l10n.accountDeleted);
                        }
                      }
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
                    value: 'archive',
                    child: ListTile(
                      leading: Icon(
                        account.archived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                      ),
                      title: Text(
                        account.archived ? l10n.active : l10n.archiveAccount,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.cash => l10n.accountTypeCash,
      AccountType.bank => l10n.accountTypeBank,
      AccountType.card => l10n.accountTypeCard,
      AccountType.wallet => l10n.accountTypeWallet,
      AccountType.other => l10n.accountTypeOther,
    };
  }
}
