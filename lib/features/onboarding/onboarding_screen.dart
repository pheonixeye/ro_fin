import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency.dart';
import '../../core/utils/l10n.dart';
import '../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  late String _locale;
  late ThemePreference _theme;
  late String _currency;
  late bool _lockEnabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _locale = settings.locale;
    _theme = settings.theme;
    _currency = settings.currencyCode;
    _lockEnabled = settings.lockEnabled;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    await ref.read(settingsProvider.notifier).completeOnboarding(
          locale: _locale,
          theme: _theme,
          currencyCode: _currency,
          lockEnabled: _lockEnabled,
        );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    context.go('/dashboard');
  }

  void _next() {
    if (_page == 0) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'R',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.appName,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    l10n.onboardingStepOf(_page + 1, 2),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (_page + 1) / 2,
                  minHeight: 5,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _page = index),
                children: <Widget>[
                  _WelcomePage(l10n: l10n),
                  _PreferencesPage(
                    locale: _locale,
                    themePreference: _theme,
                    currencyCode: _currency,
                    lockEnabled: _lockEnabled,
                    onLocaleChanged: (value) => setState(() => _locale = value),
                    onThemeChanged: (value) => setState(() => _theme = value),
                    onCurrencyChanged: (value) =>
                        setState(() => _currency = value),
                    onLockChanged: (value) =>
                        setState(() => _lockEnabled = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: <Widget>[
                  FilledButton(
                    onPressed: _saving ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _page == 0
                                ? l10n.onboardingContinue
                                : l10n.getStarted,
                          ),
                  ),
                  if (_page == 1) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      l10n.onboardingNote,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 32,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingTitle,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 34,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),
          _FeatureCard(
            icon: Icons.shield_outlined,
            color: AppColors.teal,
            title: l10n.onboardingFeaturePrivateTitle,
            body: l10n.onboardingFeaturePrivateBody,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.storefront_outlined,
            color: AppColors.gold,
            title: l10n.onboardingFeatureSpacesTitle,
            body: l10n.onboardingFeatureSpacesBody,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.fingerprint,
            color: AppColors.transfer,
            title: l10n.onboardingFeatureSecureTitle,
            body: l10n.onboardingFeatureSecureBody,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesPage extends StatelessWidget {
  const _PreferencesPage({
    required this.locale,
    required this.themePreference,
    required this.currencyCode,
    required this.lockEnabled,
    required this.onLocaleChanged,
    required this.onThemeChanged,
    required this.onCurrencyChanged,
    required this.onLockChanged,
  });

  final String locale;
  final ThemePreference themePreference;
  final String currencyCode;
  final bool lockEnabled;
  final ValueChanged<String> onLocaleChanged;
  final ValueChanged<ThemePreference> onThemeChanged;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<bool> onLockChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.onboardingPreferencesTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingPreferencesBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _FieldLabel(label: l10n.onboardingLanguage),
          Row(
            children: <Widget>[
              Expanded(
                child: _ChoiceCard(
                  selected: locale == 'ar',
                  title: 'العربية',
                  subtitle: 'Arabic',
                  onTap: () => onLocaleChanged('ar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChoiceCard(
                  selected: locale == 'en',
                  title: 'English',
                  subtitle: 'English',
                  onTap: () => onLocaleChanged('en'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _FieldLabel(label: l10n.onboardingTheme),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final option in ThemePreference.values)
                ChoiceChip(
                  label: Text(switch (option) {
                    ThemePreference.system => l10n.themeSystem,
                    ThemePreference.light => l10n.themeLight,
                    ThemePreference.dark => l10n.themeDark,
                  }),
                  selected: themePreference == option,
                  onSelected: (_) => onThemeChanged(option),
                ),
            ],
          ),
          const SizedBox(height: 22),
          _FieldLabel(label: l10n.onboardingCurrency),
          DropdownButtonFormField<String>(
            initialValue: currencyCode,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            items: <DropdownMenuItem<String>>[
              for (final currency in supportedCurrencies)
                DropdownMenuItem<String>(
                  value: currency.code,
                  child: Text(
                    '${currency.name(locale)} · ${currency.code}',
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onCurrencyChanged(value);
              }
            },
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.onboardingLockTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.onboardingLockBody,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: lockEnabled,
                  onChanged: onLockChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: selected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
