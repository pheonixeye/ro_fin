import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/category.dart';
import '../../core/models/enums.dart';
import '../../core/models/recurring_rule.dart';
import '../../core/models/space.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/common.dart';

class RecurringEditorScreen extends ConsumerStatefulWidget {
  const RecurringEditorScreen({super.key, this.ruleId});

  final String? ruleId;

  @override
  ConsumerState<RecurringEditorScreen> createState() =>
      _RecurringEditorScreenState();
}

class _RecurringEditorScreenState extends ConsumerState<RecurringEditorScreen> {
  static const Uuid _uuid = Uuid();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _intervalController =
      TextEditingController(text: '1');
  final TextEditingController _dayController = TextEditingController();

  RecurringRule? _existing;
  bool _missing = false;
  bool _saving = false;
  late TxnType _type;
  late String _spaceId;
  String? _accountId;
  String? _toAccountId;
  String _categoryId = '';
  late RecurringFrequency _frequency;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _autoPost;
  late bool _isActive;
  late String _currencyCode;

  bool get _isEditing => _existing != null;
  bool get _isTransfer => _type == TxnType.transfer;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _currencyCode = settings.currencyCode;
    final accounts = ref.read(sortedAccountsProvider);
    final spaces = ref.read(sortedSpacesProvider);

    if (widget.ruleId != null) {
      _existing = ref.read(recurringRepositoryProvider).getById(widget.ruleId!);
      _missing = _existing == null;
    }

    final existing = _existing;
    if (existing != null) {
      _type = existing.type;
      _spaceId = existing.spaceId;
      _accountId = existing.accountId;
      _toAccountId = existing.toAccountId;
      _categoryId = existing.categoryId ?? '';
      _frequency = existing.frequency;
      _startDate = parseDateKey(existing.startDateKey);
      _endDate =
          existing.endDateKey == null ? null : parseDateKey(existing.endDateKey!);
      _autoPost = existing.autoPost;
      _isActive = existing.isActive;
      _intervalController.text = existing.interval.toString();
      _dayController.text = existing.dayOfMonth.toString();
      _amountController.text = amountToInput(
        existing.amountMinor,
        _currencyCode,
      );
      _noteController.text = existing.note;
    } else {
      _type = TxnType.expense;
      _spaceId = settings.activeSpaceId == 'all'
          ? (spaces.isNotEmpty ? spaces.first.id : 'space_personal')
          : settings.activeSpaceId;
      _accountId = accounts.isNotEmpty ? accounts.first.id : null;
      _frequency = RecurringFrequency.monthly;
      _startDate = DateTime.now();
      _autoPost = true;
      _isActive = true;
      _dayController.text = DateTime.now().day.toString();
    }

    if (_accountId != null &&
        !accounts.any((account) => account.id == _accountId)) {
      _accountId = accounts.isNotEmpty ? accounts.first.id : null;
    }
    if (_toAccountId != null &&
        !accounts.any((account) => account.id == _toAccountId)) {
      _toAccountId = null;
    }
    final categories = ref.read(sortedCategoriesProvider);
    if (_categoryId.isNotEmpty &&
        !categories.any((category) => category.id == _categoryId)) {
      _categoryId = '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _intervalController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  Space? get _selectedSpace {
    final spaces = ref.read(sortedSpacesProvider);
    return spaces.where((space) => space.id == _spaceId).firstOrNull;
  }

  List<Category> get _filteredCategories {
    final categories = ref.read(sortedCategoriesProvider);
    final spaceKind = _selectedSpace?.kind ?? SpaceKind.personal;
    final kind =
        _type == TxnType.income ? CategoryKind.income : CategoryKind.expense;
    return categories
        .where(
          (category) =>
              category.kind == kind && category.appliesTo(spaceKind),
        )
        .toList(growable: false);
  }

  void _setType(TxnType type) {
    setState(() {
      _type = type;
      if (type == TxnType.transfer) {
        _categoryId = '';
      } else {
        _toAccountId = null;
      }
    });
  }

  void _setSpace(String spaceId) {
    setState(() {
      _spaceId = spaceId;
      final stillValid =
          _filteredCategories.any((category) => category.id == _categoryId);
      if (!stillValid) {
        _categoryId = '';
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _startDate = picked;
      if (_endDate != null && _endDate!.isBefore(picked)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_accountId == null) {
      return;
    }
    final amount = parseMoneyToMinor(
      _amountController.text,
      _currencyCode,
    );
    if (amount == null || amount <= 0) {
      return;
    }
    if (_isTransfer &&
        (_toAccountId == null || _toAccountId == _accountId)) {
      return;
    }

    final interval = int.tryParse(_intervalController.text) ?? 1;
    final dayOfMonth = _frequency == RecurringFrequency.weekly
        ? _startDate.day
        : int.tryParse(_dayController.text) ?? _startDate.day;
    final startKey = dateKey(_startDate);
    final existing = _existing;
    var nextDueKey = existing?.nextDueDateKey ?? startKey;
    if (nextDueKey.isEmpty) {
      nextDueKey = startKey;
    }
    if (existing == null ||
        (existing.startDateKey != startKey &&
            nextDueKey.compareTo(startKey) < 0)) {
      nextDueKey = startKey;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final rule = RecurringRule(
      id: existing?.id ?? 'rule_${_uuid.v4()}',
      type: _type,
      amountMinor: amount,
      accountId: _accountId!,
      spaceId: _spaceId,
      categoryId: _isTransfer || _categoryId.isEmpty ? null : _categoryId,
      toAccountId: _isTransfer ? _toAccountId : null,
      note: _noteController.text.trim(),
      frequency: _frequency,
      interval: interval.clamp(1, 365).toInt(),
      dayOfMonth: dayOfMonth.clamp(1, 31).toInt(),
      startDateKey: startKey,
      nextDueDateKey: nextDueKey,
      endDateKey: _endDate == null ? null : dateKey(_endDate!),
      isActive: _isActive,
      autoPost: _autoPost,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(recurringRepositoryProvider).put(rule);
    if (!mounted) {
      return;
    }
    showAppSnack(context, context.l10n.recurringSaved);
    context.pop();
  }

  Future<void> _delete() async {
    final existing = _existing;
    if (existing == null) {
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteRecurringTitle,
      message: l10n.deleteRecurringMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(recurringRepositoryProvider).delete(existing.id);
    if (!mounted) {
      return;
    }
    showAppSnack(context, l10n.recurringDeleted);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = context.localeCode;
    final accounts = ref.watch(sortedAccountsProvider);
    final spaces = ref.watch(sortedSpacesProvider);
    final categories = _filteredCategories;

    if (_missing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.recurringRules)),
        body: EmptyState(
          icon: Icons.search_off,
          title: l10n.noResults,
          body: l10n.noResultsBody,
          actionLabel: l10n.backToDashboard,
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editRecurring : l10n.addRecurring),
        actions: <Widget>[
          if (_isEditing)
            IconButton(
              tooltip: l10n.delete,
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: <Widget>[
            SegmentedButton<TxnType>(
              showSelectedIcon: false,
              segments: <ButtonSegment<TxnType>>[
                ButtonSegment<TxnType>(
                  value: TxnType.expense,
                  label: Text(l10n.expenseShort),
                ),
                ButtonSegment<TxnType>(
                  value: TxnType.income,
                  label: Text(l10n.incomeShort),
                ),
                ButtonSegment<TxnType>(
                  value: TxnType.transfer,
                  label: Text(l10n.transferShort),
                ),
              ],
              selected: <TxnType>{_type},
              onSelectionChanged: (selection) => _setType(selection.first),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _amountController,
              autofocus: !_isEditing,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.,٠-٩۰-۹]'),
                ),
                LengthLimitingTextInputFormatter(18),
              ],
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                labelText: l10n.amount,
                hintText: l10n.amountHint,
                prefixText: '${currencySymbol(_currencyCode)}  ',
                prefixStyle: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              validator: (value) {
                final minor = parseMoneyToMinor(
                  value ?? '',
                  _currencyCode,
                );
                if (minor == null) {
                  return l10n.invalidAmount;
                }
                if (minor <= 0) {
                  return l10n.amountMustBePositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _Label(text: l10n.space),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final space in spaces)
                  ChoiceChip(
                    avatar: Icon(
                      space.kind == SpaceKind.business
                          ? Icons.storefront_outlined
                          : Icons.person_outline,
                      size: 16,
                    ),
                    label: Text(space.localizedName(locale)),
                    selected: _spaceId == space.id,
                    onSelected: (_) => _setSpace(space.id),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _accountId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: _isTransfer ? l10n.fromAccount : l10n.account,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
              items: <DropdownMenuItem<String>>[
                for (final account in accounts)
                  DropdownMenuItem<String>(
                    value: account.id,
                    child: Text(account.localizedName(locale)),
                  ),
              ],
              onChanged: (value) => setState(() => _accountId = value),
              validator: (value) => value == null ? l10n.selectAccount : null,
            ),
            if (_isTransfer) ...<Widget>[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.toAccount,
                  prefixIcon: const Icon(Icons.arrow_forward_outlined),
                ),
                items: <DropdownMenuItem<String>>[
                  for (final account in accounts)
                    DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(account.localizedName(locale)),
                    ),
                ],
                onChanged: (value) => setState(() => _toAccountId = value),
                validator: (value) {
                  if (value == null) {
                    return l10n.selectAccount;
                  }
                  if (value == _accountId) {
                    return l10n.selectDifferentAccounts;
                  }
                  return null;
                },
              ),
            ],
            if (!_isTransfer) ...<Widget>[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey<String>('category_${_type.name}_$_spaceId'),
                initialValue: _categoryId.isEmpty ? '' : _categoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: '',
                    child: Text(l10n.none),
                  ),
                  for (final category in categories)
                    DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            AppIcons.forKey(category.iconKey),
                            size: 18,
                            color: Color(category.color),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.localizedName(locale),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _categoryId = value ?? ''),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.note,
                hintText: l10n.noteHint,
                prefixIcon: const Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 22),
            _Label(text: l10n.frequency),
            SegmentedButton<RecurringFrequency>(
              showSelectedIcon: false,
              segments: <ButtonSegment<RecurringFrequency>>[
                ButtonSegment<RecurringFrequency>(
                  value: RecurringFrequency.weekly,
                  label: Text(l10n.weekly),
                ),
                ButtonSegment<RecurringFrequency>(
                  value: RecurringFrequency.monthly,
                  label: Text(l10n.monthly),
                ),
                ButtonSegment<RecurringFrequency>(
                  value: RecurringFrequency.yearly,
                  label: Text(l10n.yearly),
                ),
              ],
              selected: <RecurringFrequency>{_frequency},
              onSelectionChanged: (selection) =>
                  setState(() => _frequency = selection.first),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _intervalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: l10n.repeatEvery,
                      prefixIcon: const Icon(Icons.repeat),
                    ),
                    validator: (value) {
                      final interval = int.tryParse(value ?? '');
                      if (interval == null || interval < 1) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                ),
                if (_frequency != RecurringFrequency.weekly) ...<Widget>[
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _dayController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.dayOfMonth,
                        prefixIcon: const Icon(Icons.event_outlined),
                      ),
                      validator: (value) {
                        final day = int.tryParse(value ?? '');
                        if (day == null || day < 1 || day > 31) {
                          return l10n.requiredField;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.startDate,
                  prefixIcon: const Icon(Icons.event_available_outlined),
                ),
                child: Text(
                  formatDateKey(dateKey(_startDate), locale),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickEndDate,
              borderRadius: BorderRadius.circular(16),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.endDate,
                  prefixIcon: const Icon(Icons.event_busy_outlined),
                  suffixIcon: _endDate == null
                      ? null
                      : IconButton(
                          tooltip: l10n.clear,
                          onPressed: () => setState(() => _endDate = null),
                          icon: const Icon(Icons.close),
                        ),
                ),
                child: Text(
                  _endDate == null
                      ? l10n.optional
                      : formatDateKey(dateKey(_endDate!), locale),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _endDate == null
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: SwitchListTile.adaptive(
                value: _autoPost,
                onChanged: (value) => setState(() => _autoPost = value),
                title: Text(l10n.autoPost),
                subtitle: Text(
                  l10n.autoPostHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                secondary: const Icon(Icons.autorenew),
              ),
            ),
            if (_isEditing) ...<Widget>[
              const SizedBox(height: 10),
              Card(
                child: SwitchListTile.adaptive(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: Text(l10n.active),
                  subtitle: Text(
                    _isActive ? l10n.recurring : l10n.paused,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: Icon(
                    _isActive
                        ? Icons.play_circle_outline
                        : Icons.pause_circle_outline,
                  ),
                ),
              ),
            ],
            if (_isTransfer) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.transfer.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.transfer.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.transfer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.transferHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 9),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
