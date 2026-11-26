import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'core/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapApp());
}

/// Opens the database before showing the app, and offers a way out when the
/// encrypted boxes cannot be read (for example after a keyring reset).
class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<AppBootstrap> _bootstrap;

  @override
  void initState() {
    super.initState();
    _bootstrap = AppBootstrap.create();
  }

  Future<AppBootstrap> _resetAndBootstrap() async {
    try {
      await Hive.close();
    } catch (_) {
      // Some boxes never opened; deleting from disk still clears the rest.
    }
    await Hive.deleteFromDisk();
    return AppBootstrap.create();
  }

  void _reset() {
    setState(() => _bootstrap = _resetAndBootstrap());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppBootstrap>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          debugPrint('Rofin failed to start: $error');
          return StartupErrorApp(error: error, onReset: _reset);
        }
        final bootstrap = snapshot.data;
        if (bootstrap == null) {
          return const _StartupSplash();
        }
        return ProviderScope(
          overrides: <Override>[
            databaseProvider.overrideWithValue(bootstrap.database),
          ],
          child: const RofinApp(),
        );
      },
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      home: const Scaffold(
        backgroundColor: Color(0xFF0F766E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF7F2E8)),
        ),
      ),
    );
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    this.onReset,
  });

  final Object error;
  final VoidCallback? onReset;

  bool get _isArabic => PlatformDispatcher.instance.locale.languageCode == 'ar';

  String get _title => _isArabic
      ? 'تعذّر على روفن فتح قاعدة البيانات المشفّرة'
      : 'Rofin could not open its encrypted database';

  String get _body => _isArabic
      ? 'لم يعد مفتاح التشفير على هذا الجهاز مطابقاً لبياناتك المحفوظة. '
          'قد يحدث هذا بعد إعادة تثبيت التطبيق أو استعادة الجهاز. '
          'إذا كانت لديك نسخة احتياطية، أعد ضبط التطبيق ثم استعدها من '
          'الإعدادات ← النسخ الاحتياطي والاستعادة.'
      : 'The encryption key on this device no longer matches your saved '
          'data. This can happen after reinstalling the app or restoring the '
          'device. If you have a backup, reset the app and restore it from '
          'Settings → Backup & restore.';

  Future<void> _confirmReset(BuildContext context) async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _isArabic ? 'إعادة ضبط البيانات المحلية؟' : 'Reset local data?',
        ),
        content: Text(
          _isArabic
              ? 'سيتم حذف كل المساحات والحسابات والمعاملات والميزانيات '
                  'والقواعد المتكررة على هذا الجهاز. لا يمكن التراجع عن ذلك. '
                  'تأكد من وجود نسخة احتياطية أولاً.'
              : 'All spaces, accounts, transactions, budgets, and recurring '
                  'rules on this device will be deleted. This cannot be '
                  'undone. Make sure you have a backup first.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_isArabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              _isArabic ? 'حذف وإعادة الضبط' : 'Delete and reset',
            ),
          ),
        ],
      ),
    );
    if (reset == true) {
      onReset?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5EEAD4),
          brightness: Brightness.dark,
        ),
      ),
      home: Builder(
        builder: (context) => Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _body,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    if (onReset != null)
                      FilledButton.icon(
                        onPressed: () => _confirmReset(context),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(
                          _isArabic
                              ? 'إعادة ضبط البيانات المحلية'
                              : 'Reset local data',
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _isArabic ? 'تفاصيل تقنية' : 'Technical details',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
