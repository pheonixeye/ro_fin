import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/account.dart';
import '../../core/models/category.dart';
import '../../core/models/enums.dart';
import '../../core/models/txn.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TxnType? _typeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Txn> _filtered(
    List<Txn> transactions,
    String spaceId,
    List<Category> categories,
    List<Account> accounts,
    String currencyCode,
  ) {
    final query = _query.trim().toLowerCase();
    final categoriesById = <String, Category>{
      for (final category in categories) category.id: category,
    };
    final accountsById = <String, Account>{
      for (final account in accounts) account.id: account,
    };

    return transactions.where((txn) {
      if (spaceId != 'all' && txn.spaceId != spaceId) {
        return false;
      }
      if (_typeFilter != null && txn.type != _typeFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final category = categoriesById[txn.categoryId];
      final account = accountsById[txn.accountId];
      final haystack = <String>[
        txn.note,
        if (category != null) category.nameAr,
        if (category != null) category.nameEn,
        if (account != null) account.nameAr,
        if (account != null) account.nameEn,
        amountToInput(txn.amountMinor, currencyCode),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  String _dateLabel(String key) {
    final l10n = context.l10n;
    final now = DateTime.now();
    if (key == dateKey(now)) {
      return l10n.today;
    }
    if (key == dateKey(now.subtract(const Duration(days: 1)))) {
      return l10n.yesterday;
    }
    return formatDateKey(key, context.localeCode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final spaceId = ref.watch(activeSpaceIdProvider);
    final transactions = ref.watch(sortedTransactionsProvider);
    final spaces = ref.watch(sortedSpacesProvider);
    final categories = ref.watch(sortedCategoriesProvider);
    final accounts = ref.watch(sortedAccountsProvider);

    final filtered = _filtered(
      transactions,
      spaceId,
      categories,
      accounts,
      settings.currencyCode,
    );

    final groups = <String, List<Txn>>{};
    for (final txn in filtered) {
      groups.putIfAbsent(txn.dateKey, () => <Txn>[]).add(txn);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactions),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.reports,
            onPressed: () => context.go('/reports'),
            icon: const Icon(Icons.insights_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clear,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.allSpaces),
                  selected: spaceId == 'all',
                  onSelected: (_) => ref
                      .read(settingsProvider.notifier)
                      .setActiveSpace('all'),
                ),
                for (final space in spaces) ...<Widget>[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(space.localizedName(context.localeCode)),
                    selected: spaceId == space.id,
                    onSelected: (_) => ref
                        .read(settingsProvider.notifier)
                        .setActiveSpace(space.id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.allTypes),
                  selected: _typeFilter == null,
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.income),
                  selected: _typeFilter == TxnType.income,
                  onSelected: (_) =>
                      setState(() => _typeFilter = TxnType.income),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.expense),
                  selected: _typeFilter == TxnType.expense,
                  onSelected: (_) =>
                      setState(() => _typeFilter = TxnType.expense),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(l10n.transfer),
                  selected: _typeFilter == TxnType.transfer,
                  onSelected: (_) =>
                      setState(() => _typeFilter = TxnType.transfer),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
            child: Row(
              children: <Widget>[
                Text(
                  l10n.transactionsCount(filtered.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_query.isNotEmpty || _typeFilter != null)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                        _typeFilter = null;
                      });
                    },
                    child: Text(l10n.clear),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: transactions.isEmpty
                        ? Icons.receipt_long_outlined
                        : Icons.search_off,
                    title: transactions.isEmpty
                        ? l10n.noTransactions
                        : l10n.noResults,
                    body: transactions.isEmpty
                        ? l10n.noTransactionsBody
                        : l10n.noResultsBody,
                    actionLabel: transactions.isEmpty
                        ? l10n.addTransaction
                        : l10n.clear,
                    onAction: transactions.isEmpty
                        ? () => context.push('/transaction/new')
                        : () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _typeFilter = null;
                            });
                          },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final entry = groups.entries.elementAt(index);
                      final dayTransactions = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    _dateLabel(entry.key),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    l10n.transactionsCount(dayTransactions.length),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: <Widget>[
                                    for (var txnIndex = 0;
                                        txnIndex < dayTransactions.length;
                                        txnIndex++) ...<Widget>[
                                      TransactionTile(
                                        txn: dayTransactions[txnIndex],
                                        showSpace: spaceId == 'all',
                                        onTap: () => context.push(
                                          '/transaction/${dayTransactions[txnIndex].id}',
                                        ),
                                      ),
                                      if (txnIndex <
                                          dayTransactions.length - 1)
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
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
