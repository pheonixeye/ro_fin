import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/models/enums.dart';
import 'core/providers/app_providers.dart';
import 'core/security/secure_screen_service.dart';
import 'core/theme/app_theme.dart';
import 'features/lock/lock_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'router/app_router.dart';

class RofinApp extends ConsumerWidget {
  const RofinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    ref.listen<bool>(
      settingsProvider.select((value) => value.hideInRecents),
      (previous, next) {
        SecureScreenService.apply(enabled: next);
      },
    );

    final themeMode = switch (settings.theme) {
      ThemePreference.system => ThemeMode.system,
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Rofin',
      locale: Locale(settings.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: AppTheme.light(settings.locale),
      darkTheme: AppTheme.dark(settings.locale),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 250),
      routerConfig: router,
      builder: (context, child) {
        return LockGate(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      SecureScreenService.apply(
        enabled: ref.read(settingsProvider).hideInRecents,
      );
      final lock = ref.read(appLockProvider);
      if (lock.status == LockStatus.locked) {
        ref.read(appLockProvider.notifier).unlock();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = ref.read(settingsProvider);
    if (!settings.onboardingComplete || !settings.lockEnabled) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      if (settings.autoLockSeconds == 0) {
        ref.read(appLockProvider.notifier).lock();
      } else {
        _pausedAt = DateTime.now();
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (settings.autoLockSeconds == 0) {
        if (ref.read(appLockProvider).status == LockStatus.locked) {
          ref.read(appLockProvider.notifier).unlock();
        }
        return;
      }
      if (pausedAt == null) {
        return;
      }
      final elapsed = DateTime.now().difference(pausedAt).inSeconds;
      if (elapsed >= settings.autoLockSeconds) {
        ref.read(appLockProvider.notifier).lock();
        ref.read(appLockProvider.notifier).unlock();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lock = ref.watch(appLockProvider);
    final shouldShowLock = settings.onboardingComplete &&
        settings.lockEnabled &&
        lock.status != LockStatus.unlocked;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (shouldShowLock) const LockScreen(),
      ],
    );
  }
}
