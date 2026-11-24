import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import '../../core/models/enums.dart';
import '../../core/models/space.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/finance_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/common.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late String _monthKey;

  @override
  void initState() {
    super.initState();
    _monthKey = monthKey(DateTime.now());
  }

  Future<void> _openEditor({Budget? budget}) async {
    final settings = ref.read(settingsProvider);
    final spaces = ref.read(sortedSpacesProvider);
    final spaceId = budget?.spaceId ??
        (settings.activeSpaceId == 'all'
            ? (spaces.isNotEmpty ? spaces.first.id : 'space_personal')
            : settings.activeSpaceId);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _BudgetEditorSheet(
        budget: budget,
        monthKey: budget?.monthKey ?? _monthKey,
        initialSpaceId: spaceId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final spaces = ref.watch(sortedSpacesProvider);
    final categories = ref.watch(sortedCategoriesProvider);
    final budgets = ref.watch(budgetsProvider).value ?? const <Budget>[];
    final transactions = ref.watch(transactionsProvider).value ?? const [];
    final spaceId = settings.activeSpaceId;

    final progress = FinanceService.budgetProgress(
      budgets: budgets,
      categories: categories,
      transactions: transactions,
      spaceId: spaceId,
      monthKey: _monthKey,
    );
    final totalBudget = progress.fold<int>(
      0,
      (sum, item) => sum + item.budget.amountMinor,
    );
    final totalSpent = progress.fold<int>(
      0,
      (sum, item) => sum + item.spentMinor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgets),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addBudget,
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
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
                        Text(
                          spaceId == 'all'
                              ? l10n.allSpaces
                              : spaces
                                      .where((space) => space.id == spaceId)
                                      .firstOrNull
                                      ?.localizedName(locale) ??
                                  l10n.allSpaces,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(
                      () => _monthKey = shiftMonthKey(_monthKey, 1),
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          if (progress.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryTile(
                    label: l10n.total,
                    value: formatMoney(
                      totalBudget,
                      settings.currencyCode,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    label: l10n.spent,
                    value: formatMoney(
                      totalSpent,
                      settings.currencyCode,
                    ),
                    color: AppColors.expenseFor(theme.brightness),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          if (progress.isEmpty)
            Card(
              child: EmptyState(
                icon: Icons.savings_outlined,
                title: l10n.noBudgets,
                body: l10n.noBudgetsBody,
                actionLabel: l10n.addBudget,
                onAction: () => _openEditor(),
              ),
            )
          else
            for (final item in progress) ...<Widget>[
              _BudgetCard(
                progress: item,
                locale: locale,
                currencyCode: settings.currencyCode,
                showSpace: spaceId == 'all',
                space: spaces
                    .where((space) => space.id == item.budget.spaceId)
                    .firstOrNull,
                onTap: () => _openEditor(budget: item.budget),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 12),
          Text(
            l10n.monthlyBudgetHint,
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.progress,
    required this.locale,
    required this.currencyCode,
    required this.showSpace,
    required this.space,
    required this.onTap,
  });

  final BudgetProgress progress;
  final String locale;
  final String currencyCode;
  final bool showSpace;
  final Space? space;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final category = progress.category;
    final color = progress.isOver
        ? theme.colorScheme.error
        : (progress.ratio >= 0.8
            ? AppColors.gold
            : theme.colorScheme.primary);
    final name = category?.localizedName(locale) ?? l10n.overallBudget;
    final percent = (progress.ratio * 100).clamp(0, 999).round();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CategoryAvatar(
                    iconKey: category?.iconKey ?? 'chart',
                    colorValue: category?.color ?? AppColors.gold.toARGB32(),
                    size: 38,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        if (showSpace && space != null) ...<Widget>[
                          const SizedBox(height: 4),
                          SpacePill(
                            label: space!.localizedName(locale),
                            color: Color(space!.color),
                            icon: space!.kind == SpaceKind.business
                                ? Icons.storefront_outlined
                                : Icons.person_outline,
                          ),
                        ],
                      ],
                    ),
                  ),
                  TypeBadge(
                    label: progress.isOver ? l10n.overBudget : '$percent%',
                    color: color,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Text(
                    l10n.ofBudget(
                      formatMoney(progress.spentMinor, currencyCode),
                      formatMoney(progress.budget.amountMinor, currencyCode),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    progress.isOver
                        ? formatMoney(-progress.remainingMinor, currencyCode)
                        : formatMoney(progress.remainingMinor, currencyCode),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: progress.isOver
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress.ratio.clamp(0.0, 1.0).toDouble(),
                  minHeight: 8,
                  color: color,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetEditorSheet extends ConsumerStatefulWidget {
  const _BudgetEditorSheet({
    required this.monthKey,
    required this.initialSpaceId,
    this.budget,
  });

  final Budget? budget;
  final String monthKey;
  final String initialSpaceId;

  @override
  ConsumerState<_BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends ConsumerState<_BudgetEditorSheet> {
  static const Uuid _uuid = Uuid();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  bool _saving = false;
  String? _duplicateError;
  late String _spaceId;
  late String _categoryId;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    _spaceId = budget?.spaceId ?? widget.initialSpaceId;
    _categoryId = budget?.categoryId ?? '';
    if (budget != null) {
      final settings = ref.read(settingsProvider);
      _amountController.text = amountToInput(
        budget.amountMinor,
        settings.currencyCode,
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<Category> _categoriesForSpace(String spaceId) {
    final spaces = ref.read(sortedSpacesProvider);
    final space = spaces.where((item) => item.id == spaceId).firstOrNull;
    final kind = space?.kind ?? SpaceKind.personal;
    final categories = ref.read(sortedCategoriesProvider);
    return categories
        .where(
          (category) =>
              category.kind == CategoryKind.expense &&
              category.appliesTo(kind),
        )
        .toList(growable: false);
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final settings = ref.read(settingsProvider);
    final amount = parseMoneyToMinor(
      _amountController.text,
      settings.currencyCode,
    );
    if (amount == null || amount <= 0) {
      return;
    }

    final budgets = ref.read(budgetsProvider).value ?? const <Budget>[];
    final duplicate = budgets.any(
      (budget) =>
          budget.id != widget.budget?.id &&
          budget.spaceId == _spaceId &&
          budget.monthKey == widget.monthKey &&
          budget.categoryId == (_categoryId.isEmpty ? null : _categoryId),
    );
    if (duplicate) {
      setState(() => _duplicateError = context.l10n.budgetAlreadyExists);
      return;
    }

    setState(() {
      _saving = true;
      _duplicateError = null;
    });
    final now = DateTime.now();
    final budget = Budget(
      id: widget.budget?.id ?? 'budget_${_uuid.v4()}',
      spaceId: _spaceId,
      categoryId: _categoryId.isEmpty ? null : _categoryId,
      monthKey: widget.monthKey,
      amountMinor: amount,
      createdAt: widget.budget?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(budgetsRepositoryProvider).put(budget);
    if (!mounted) {
      return;
    }
    showAppSnack(context, context.l10n.budgetSaved);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final budget = widget.budget;
    if (budget == null) {
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteBudgetTitle,
      message: l10n.deleteBudgetMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(budgetsRepositoryProvider).delete(budget.id);
    if (!mounted) {
      return;
    }
    showAppSnack(context, l10n.budgetDeleted);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final spaces = ref.watch(sortedSpacesProvider);
    final settings = ref.watch(settingsProvider);
    final categories = _categoriesForSpace(_spaceId);

    if (_categoryId.isNotEmpty &&
        !categories.any((category) => category.id == _categoryId)) {
      _categoryId = '';
    }

    return SheetScaffold(
      title: widget.budget == null ? l10n.addBudget : l10n.editBudget,
      trailing: widget.budget == null
          ? null
          : IconButton(
              tooltip: l10n.delete,
              onPressed: _saving ? null : _delete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.budgetFor(formatMonthKey(widget.monthKey, locale)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _spaceId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.space,
                prefixIcon: const Icon(Icons.workspaces_outline),
              ),
              items: <DropdownMenuItem<String>>[
                for (final space in spaces)
                  DropdownMenuItem<String>(
                    value: space.id,
                    child: Text(space.localizedName(locale)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _spaceId = value;
                    _categoryId = '';
                    _duplicateError = null;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.category,
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(l10n.overallBudget),
                ),
                for (final category in categories)
                  DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.localizedName(locale)),
                  ),
              ],
              onChanged: (value) => setState(() {
                _categoryId = value ?? '';
                _duplicateError = null;
              }),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountController,
              autofocus: widget.budget == null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.,٠-٩۰-۹]'),
                ),
                LengthLimitingTextInputFormatter(18),
              ],
              decoration: InputDecoration(
                labelText: l10n.budgetAmount,
                prefixIcon: const Icon(Icons.savings_outlined),
                prefixText: '${currencySymbol(settings.currencyCode)}  ',
                errorText: _duplicateError,
              ),
              validator: (value) {
                final amount = parseMoneyToMinor(
                  value ?? '',
                  settings.currencyCode,
                );
                if (amount == null) {
                  return l10n.invalidAmount;
                }
                if (amount <= 0) {
                  return l10n.amountMustBePositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
