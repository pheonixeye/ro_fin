import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/account.dart';
import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/l10n.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/common.dart';
import '../../l10n/generated/app_localizations.dart';

class AccountEditorScreen extends ConsumerStatefulWidget {
  const AccountEditorScreen({super.key, this.accountId});

  final String? accountId;

  @override
  ConsumerState<AccountEditorScreen> createState() =>
      _AccountEditorScreenState();
}

class _AccountEditorScreenState extends ConsumerState<AccountEditorScreen> {
  static const Uuid _uuid = Uuid();
  static const List<int> _colors = <int>[
    0xFF0F766E,
    0xFF3B6EA8,
    0xFF7C3AED,
    0xFFC8A24A,
    0xFFDB2777,
    0xFF15803D,
    0xFFC2410C,
    0xFF64748B,
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();
  final TextEditingController _openingController = TextEditingController();

  Account? _existing;
  bool _missing = false;
  bool _saving = false;
  String? _nameError;
  late String _currencyCode;
  late AccountType _type;
  late String _iconKey;
  late int _color;
  late bool _archived;

  bool get _isEditing => _existing != null;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _currencyCode = settings.currencyCode;
    _type = AccountType.cash;
    _iconKey = 'cash';
    _color = _colors.first;
    _archived = false;

    if (widget.accountId != null) {
      _existing = ref.read(accountsRepositoryProvider).getById(
            widget.accountId!,
          );
      _missing = _existing == null;
    }

    final existing = _existing;
    if (existing != null) {
      _currencyCode = existing.currencyCode;
      _type = existing.type;
      _iconKey = existing.iconKey;
      _color = existing.color;
      _archived = existing.archived;
      _nameArController.text = existing.nameAr;
      _nameEnController.text = existing.nameEn;
      _openingController.text = amountToInput(
        existing.openingBalanceMinor,
        _currencyCode,
      );
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _openingController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final nameAr = _nameArController.text.trim();
    final nameEn = _nameEnController.text.trim();
    if (nameAr.isEmpty && nameEn.isEmpty) {
      setState(() => _nameError = context.l10n.nameRequired);
      return;
    }
    setState(() {
      _nameError = null;
      _saving = true;
    });

    final opening = parseMoneyToMinor(
      _openingController.text,
      _currencyCode,
    );
    if (opening == null) {
      setState(() => _saving = false);
      return;
    }
    final now = DateTime.now();
    final accounts = ref.read(accountsRepositoryProvider).getAll();
    final account = Account(
      id: _existing?.id ?? 'account_${_uuid.v4()}',
      nameAr: nameAr,
      nameEn: nameEn,
      type: _type,
      openingBalanceMinor: opening,
      currencyCode: _currencyCode,
      color: _color,
      iconKey: _iconKey,
      archived: _archived,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
      sortOrder: _existing?.sortOrder ?? accounts.length,
    );

    await ref.read(accountsRepositoryProvider).put(account);
    if (!mounted) {
      return;
    }
    showAppSnack(context, context.l10n.accountSaved);
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
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(accountsRepositoryProvider).delete(existing.id);
    if (!mounted) {
      return;
    }
    showAppSnack(context, l10n.accountDeleted);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_missing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.accounts)),
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
        title: Text(_isEditing ? l10n.editAccount : l10n.addAccount),
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
            TextFormField(
              controller: _nameArController,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: l10n.accountNameAr,
                prefixIcon: const Icon(Icons.language_outlined),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameEnController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.accountNameEn,
                prefixIcon: const Icon(Icons.text_fields_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.accountType,
                prefixIcon: const Icon(Icons.account_balance_outlined),
              ),
              items: <DropdownMenuItem<AccountType>>[
                for (final type in AccountType.values)
                  DropdownMenuItem<AccountType>(
                    value: type,
                    child: Text(_typeLabel(l10n, type)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _openingController,
              textInputAction: TextInputAction.done,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  RegExp(r'[-0-9.,٠-٩۰-۹]'),
                ),
                LengthLimitingTextInputFormatter(18),
              ],
              decoration: InputDecoration(
                labelText: l10n.openingBalance,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                prefixText: '${currencySymbol(_currencyCode)}  ',
              ),
              validator: (value) {
                if (parseMoneyToMinor(value ?? '', _currencyCode) == null) {
                  return l10n.invalidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _Label(text: l10n.accountIcon),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final key in AppIcons.accountKeys)
                  _IconChoice(
                    icon: AppIcons.forKey(key),
                    selected: _iconKey == key,
                    color: Color(_color),
                    onTap: () => setState(() => _iconKey = key),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _Label(text: l10n.accountColor),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final colorValue in _colors)
                  _ColorChoice(
                    color: Color(colorValue),
                    selected: _color == colorValue,
                    onTap: () => setState(() => _color = colorValue),
                  ),
              ],
            ),
            if (_isEditing) ...<Widget>[
              const SizedBox(height: 18),
              Card(
                child: SwitchListTile.adaptive(
                  value: _archived,
                  onChanged: (value) => setState(() => _archived = value),
                  title: Text(l10n.archiveAccount),
                  subtitle: Text(
                    l10n.archiveAccountMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: const Icon(Icons.archive_outlined),
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

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : theme.colorScheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? color : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 20, color: Colors.white)
            : null,
      ),
    );
  }
}
