import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../models/enums.dart';
import '../models/txn.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import '../utils/l10n.dart';
import 'category_avatar.dart';
import 'money_text.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.txn,
    this.onTap,
    this.showSpace = false,
    this.showDate = true,
  });

  final Txn txn;
  final VoidCallback? onTap;
  final bool showSpace;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final spaces = ref.watch(spacesProvider).value ?? const [];

    final category = categories.where((item) => item.id == txn.categoryId).firstOrNull;
    final account = accounts.where((item) => item.id == txn.accountId).firstOrNull;
    final toAccount = accounts
        .where((item) => item.id == txn.toAccountId)
        .firstOrNull;
    final space = spaces.where((item) => item.id == txn.spaceId).firstOrNull;

    final isTransfer = txn.type == TxnType.transfer;
    final brightness = Theme.of(context).brightness;
    final accent = switch (txn.type) {
      TxnType.income => AppColors.incomeFor(brightness),
      TxnType.expense => AppColors.expenseFor(brightness),
      TxnType.transfer => AppColors.transferFor(brightness),
    };

    final title = isTransfer
        ? '${account?.localizedName(locale) ?? l10n.noSpace} → ${toAccount?.localizedName(locale) ?? ''}'
        : (category?.localizedName(locale) ?? l10n.unknownCategory);

    final subtitleParts = <String>[
      if (txn.note.trim().isNotEmpty) txn.note.trim(),
      if (!isTransfer && account != null) account.localizedName(locale),
      if (isTransfer) l10n.transfer,
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
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
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        if (showSpace && space != null) ...<Widget>[
                          SpacePill(
                            label: space.localizedName(locale),
                            color: Color(space.color),
                            icon: space.kind == SpaceKind.business
                                ? Icons.storefront_outlined
                                : Icons.person_outline,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            subtitleParts.isEmpty
                                ? l10n.unknownCategory
                                : subtitleParts.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  MoneyText(
                    amountMinor: txn.amountMinor,
                    currencyCode: account?.currencyCode,
                    sign: switch (txn.type) {
                      TxnType.income => MoneySign.positive,
                      TxnType.expense => MoneySign.negative,
                      TxnType.transfer => MoneySign.none,
                    },
                    color: accent,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (showDate) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      formatDateKey(txn.dateKey, locale),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
