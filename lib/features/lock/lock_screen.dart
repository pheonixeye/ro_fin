import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers/app_providers.dart';
import '../../core/security/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/l10n.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final state = ref.read(appLockProvider);
      if (state.status == LockStatus.locked) {
        ref.read(appLockProvider.notifier).unlock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lock = ref.watch(appLockProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocking = lock.status == LockStatus.unlocking;

    final errorText = switch (lock.failure) {
      AuthOutcome.unavailable => l10n.lockUnavailable,
      AuthOutcome.lockedOut ||
      AuthOutcome.failed =>
        l10n.lockError,
      _ => null,
    };

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.tealDeep,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? <Color>[
                    AppColors.night,
                    const Color(0xFF0D2B28),
                    AppColors.night,
                  ]
                : <Color>[
                    AppColors.tealDeep,
                    AppColors.teal,
                    const Color(0xFF0B4F49),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      l10n.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.lockTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.lockSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (errorText != null) ...<Widget>[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          errorText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.tealDeep,
                          minimumSize: const Size.fromHeight(54),
                        ),
                        onPressed: isUnlocking
                            ? null
                            : () => ref
                                .read(appLockProvider.notifier)
                                .unlock(),
                        icon: isUnlocking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.fingerprint),
                        label: Text(
                          isUnlocking ? l10n.unlocking : l10n.unlock,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.privacyHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
