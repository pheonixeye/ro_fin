import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/security/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/digits.dart';
import '../../core/utils/l10n.dart';
import '../../core/widgets/common.dart';
import '../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const String _version = '0.1.0';

  bool _busy = false;

  Future<void> _setLocale(String locale) async {
    await ref.read(settingsProvider.notifier).setLocale(locale);
  }

  Future<void> _setTheme(ThemePreference theme) async {
    await ref.read(settingsProvider.notifier).setTheme(theme);
  }

  Future<void> _setCurrency(String code) async {
    await ref.read(settingsProvider.notifier).setCurrency(code);
  }

  Future<void> _setLockEnabled(bool value) async {
    if (_busy) {
      return;
    }
    if (!value) {
      await ref.read(settingsProvider.notifier).setLockEnabled(false);
      return;
    }

    final l10n = context.l10n;
    final auth = ref.read(authServiceProvider);
    if (auth.isPreviewBypass) {
      await ref.read(settingsProvider.notifier).setLockEnabled(true);
      return;
    }
    final canUse = await auth.canUseDeviceAuth();
    if (!mounted) {
      return;
    }
    if (!canUse) {
      await _showDeviceAuthUnavailable();
      return;
    }

    setState(() => _busy = true);
    final outcome = await auth.authenticate(l10n.unlockPrompt);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (outcome == AuthOutcome.success) {
      await ref.read(settingsProvider.notifier).setLockEnabled(true);
      if (mounted) {
        showAppSnack(context, l10n.settingsSaved);
      }
    } else if (outcome == AuthOutcome.unavailable) {
      await _showDeviceAuthUnavailable();
    }
  }

  Future<void> _showDeviceAuthUnavailable() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deviceAuthUnavailable),
        content: Text(l10n.deviceAuthUnavailableHint),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseLanguage() async {
    final l10n = context.l10n;
    final selected = await _showChoiceSheet<String>(
      title: l10n.language,
      selected: ref.read(settingsProvider).locale,
      choices: <_Choice<String>>[
        _Choice<String>(
          value: 'ar',
          label: l10n.arabic,
          subtitle: 'العربية',
          icon: Icons.translate,
        ),
        _Choice<String>(
          value: 'en',
          label: l10n.english,
          subtitle: 'English',
          icon: Icons.language,
        ),
      ],
    );
    if (selected != null) {
      await _setLocale(selected);
    }
  }

  Future<void> _chooseCurrency() async {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final selected = await _showChoiceSheet<String>(
      title: l10n.currency,
      selected: ref.read(settingsProvider).currencyCode,
      choices: <_Choice<String>>[
        for (final currency in supportedCurrencies)
          _Choice<String>(
            value: currency.code,
            label: currency.name(locale),
            subtitle: '${currency.code} · ${currency.symbol}',
            icon: Icons.payments_outlined,
          ),
      ],
    );
    if (selected != null) {
      await _setCurrency(selected);
    }
  }

  Future<void> _chooseAutoLock() async {
    final l10n = context.l10n;
    final selected = await _showChoiceSheet<int>(
      title: l10n.autoLock,
      selected: ref.read(settingsProvider).autoLockSeconds,
      choices: <_Choice<int>>[
        _Choice<int>(
          value: 0,
          label: l10n.lockImmediately,
          icon: Icons.lock_clock,
        ),
        _Choice<int>(
          value: 30,
          label: l10n.lockAfter30s,
          icon: Icons.timer_outlined,
        ),
        _Choice<int>(
          value: 60,
          label: l10n.lockAfter1m,
          icon: Icons.timer_outlined,
        ),
        _Choice<int>(
          value: 300,
          label: l10n.lockAfter5m,
          icon: Icons.timer_outlined,
        ),
      ],
    );
    if (selected != null) {
      await ref.read(settingsProvider.notifier).setAutoLockSeconds(selected);
    }
  }

  Future<T?> _showChoiceSheet<T>({
    required String title,
    required T selected,
    required List<_Choice<T>> choices,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: choices.length > 8 ? 0.7 : 0.5,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(title, style: theme.textTheme.titleLarge),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: choices.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final choice = choices[index];
                      final isSelected = choice.value == selected;
                      return ListTile(
                        leading: Icon(
                          choice.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(choice.label),
                        subtitle: choice.subtitle == null
                            ? null
                            : Text(choice.subtitle!),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () => Navigator.of(context).pop(choice.value),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resetData() async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.resetDataTitle,
      message: l10n.resetDataMessage,
      confirmLabel: l10n.resetDataConfirm,
    );
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _busy = true);
    await ref.read(settingsProvider.notifier).resetAll();
    ref.read(appLockProvider.notifier).unlockWithoutPrompt();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    showAppSnack(context, l10n.dataReset);
    context.go('/onboarding');
  }

  void _showAbout() {
    final l10n = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: _version,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text(
          'R',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      children: <Widget>[
        const SizedBox(height: 8),
        Text(l10n.appTagline),
        const SizedBox(height: 10),
        Text(l10n.madeWith),
      ],
    );
  }

  String _autoLockLabel(AppLocalizations l10n, int seconds) {
    return switch (seconds) {
      0 => l10n.lockImmediately,
      30 => l10n.lockAfter30s,
      60 => l10n.lockAfter1m,
      300 => l10n.lockAfter5m,
      _ => l10n.lockAfter30s,
    };
  }

  String _formatDateTime(DateTime value, String locale) {
    return normalizeDigits(
      DateFormat.yMMMd(locale).add_Hm().format(value.toLocal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final accounts = ref.watch(accountsProvider).value?.length ?? 0;
    final categories = ref.watch(categoriesProvider).value?.length ?? 0;
    final spaces = ref.watch(spacesProvider).value?.length ?? 0;
    final budgets = ref.watch(budgetsProvider).value?.length ?? 0;
    final recurring = ref.watch(recurringProvider).value?.length ?? 0;
    final currency = currencyFor(settings.currencyCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.tealDeep, AppColors.teal],
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'R',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.appTagline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.appearance),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(l10n.language),
                  subtitle: Text(settings.locale == 'ar' ? l10n.arabic : l10n.english),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _chooseLanguage,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(l10n.currency),
                  subtitle: Text(
                    '${currency.name(locale)} · ${currency.code}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _chooseCurrency,
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.contrast,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l10n.theme,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemePreference>(
                          showSelectedIcon: false,
                          segments: <ButtonSegment<ThemePreference>>[
                            ButtonSegment<ThemePreference>(
                              value: ThemePreference.system,
                              label: Text(l10n.themeSystem),
                            ),
                            ButtonSegment<ThemePreference>(
                              value: ThemePreference.light,
                              label: Text(l10n.themeLight),
                            ),
                            ButtonSegment<ThemePreference>(
                              value: ThemePreference.dark,
                              label: Text(l10n.themeDark),
                            ),
                          ],
                          selected: <ThemePreference>{settings.theme},
                          onSelectionChanged: (selection) =>
                              _setTheme(selection.first),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.security),
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile.adaptive(
                  value: settings.lockEnabled,
                  onChanged: _busy ? null : _setLockEnabled,
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(l10n.appLock),
                  subtitle: Text(
                    l10n.appLockHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                if (settings.lockEnabled) ...<Widget>[
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l10n.autoLock),
                    subtitle: Text(
                      _autoLockLabel(l10n, settings.autoLockSeconds),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _chooseAutoLock,
                  ),
                ],
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant,
                ),
                SwitchListTile.adaptive(
                  value: settings.hideInRecents,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setHideInRecents(value),
                  secondary: const Icon(Icons.visibility_off_outlined),
                  title: Text(l10n.hideInRecents),
                  subtitle: Text(
                    l10n.hideInRecentsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                if (settings.lockEnabled) ...<Widget>[
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.lockNow),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(appLockProvider.notifier).lock();
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.overview),
          Card(
            child: Column(
              children: <Widget>[
                _ManageTile(
                  icon: Icons.workspaces_outline,
                  title: l10n.spaces,
                  count: spaces,
                  onTap: () => context.push('/spaces'),
                ),
                _divider(theme),
                _ManageTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.accounts,
                  count: accounts,
                  onTap: () => context.push('/accounts'),
                ),
                _divider(theme),
                _ManageTile(
                  icon: Icons.category_outlined,
                  title: l10n.categories,
                  count: categories,
                  onTap: () => context.push('/categories'),
                ),
                _divider(theme),
                _ManageTile(
                  icon: Icons.savings_outlined,
                  title: l10n.budgets,
                  count: budgets,
                  onTap: () => context.push('/budgets'),
                ),
                _divider(theme),
                _ManageTile(
                  icon: Icons.event_repeat_outlined,
                  title: l10n.recurring,
                  count: recurring,
                  onTap: () => context.push('/recurring'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.data),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.cloud_off_outlined),
                  title: Text(l10n.backupAndRestore),
                  subtitle: Text(
                    settings.lastBackupAt == null
                        ? l10n.neverBackedUp
                        : '${l10n.lastBackup}: '
                            '${_formatDateTime(settings.lastBackupAt!, locale)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/backup'),
                ),
                _divider(theme),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    l10n.resetData,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(
                    l10n.deleteCannotUndo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: _busy ? null : _resetData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.about),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutRofin),
                  subtitle: Text(l10n.version(_version)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAbout,
                ),
                _divider(theme),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.licenses),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appName,
                    applicationVersion: _version,
                  ),
                ),
                _divider(theme),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.privacyHint,
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
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              l10n.madeWith,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.colorScheme.outlineVariant,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  const _ManageTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _Choice<T> {
  const _Choice({
    required this.value,
    required this.label,
    required this.icon,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData icon;
}
