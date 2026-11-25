import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/csv_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/digits.dart';
import '../../core/utils/l10n.dart';
import '../../core/widgets/common.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _busy = false;
  bool _usePassword = false;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _timestamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}';
  }

  String _formatDateTime(DateTime value, String locale) {
    return normalizeDigits(
      DateFormat.yMMMd(locale).add_Hm().format(value.toLocal()),
    );
  }

  /// Shares [bytes] through the platform sheet. If sharing is unavailable,
  /// saves a copy to the app documents directory and returns that path.
  Future<String?> _shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String subject,
  }) async {
    final tempDirectory = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDirectory.path, fileName));
    await tempFile.writeAsBytes(bytes, flush: true);

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(tempFile.path, mimeType: mimeType)],
          fileNameOverrides: <String>[fileName],
          title: subject,
          subject: subject,
        ),
      );
      return null;
    } catch (_) {
      final documents = await getApplicationDocumentsDirectory();
      final output = File(p.join(documents.path, fileName));
      await output.writeAsBytes(bytes, flush: true);
      return output.path;
    }
  }

  Future<void> _exportBackup() async {
    if (_busy) {
      return;
    }
    final l10n = context.l10n;
    String? password;
    if (_usePassword) {
      final value = _passwordController.text;
      if (value.length < 8) {
        showAppSnack(context, l10n.backupPasswordTooShort);
        return;
      }
      if (value != _confirmController.text) {
        showAppSnack(context, l10n.passwordsDoNotMatch);
        return;
      }
      password = value;
    }

    setState(() => _busy = true);
    try {
      final bytes = await BackupService.createBackup(
        db: ref.read(databaseProvider),
        password: password,
      );
      final fileName = 'rofin-backup-${_timestamp()}.json';
      final savedPath = await _shareBytes(
        bytes: bytes,
        fileName: fileName,
        mimeType: 'application/json',
        subject: l10n.backupFileType,
      );
      await ref.read(settingsProvider.notifier).markBackupNow();
      if (!mounted) {
        return;
      }
      showAppSnack(
        context,
        savedPath == null ? l10n.backupExported : l10n.savedTo(savedPath),
      );
    } catch (_) {
      if (mounted) {
        showAppSnack(context, l10n.backupExportFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<String?> _promptPassword(String prompt) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              prompt,
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.backupPassword,
                prefixIcon: const Icon(Icons.key_outlined),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.of(dialogContext).pop(value);
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text;
              if (value.isNotEmpty) {
                Navigator.of(dialogContext).pop(value);
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  void _showBackupError(BackupException error) {
    if (!mounted) {
      return;
    }
    final l10n = context.l10n;
    final message = switch (error.failure) {
      BackupFailure.invalidFile => l10n.invalidBackup,
      BackupFailure.passwordRequired => l10n.passwordRequired,
      BackupFailure.wrongPassword => l10n.wrongPassword,
    };
    showAppSnack(context, message);
  }

  Future<void> _importBackup() async {
    if (_busy) {
      return;
    }
    final l10n = context.l10n;

    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: l10n.backupFileType,
        type: FileType.any,
      );
      if (picked == null) {
        return;
      }
      final bytes = await picked.readAsBytes();
      Map<String, dynamic>? data;
      try {
        data = await BackupService.readBackup(bytes);
      } on BackupException catch (error) {
        if (error.failure != BackupFailure.passwordRequired) {
          _showBackupError(error);
          return;
        }
        final password = await _promptPassword(l10n.restorePasswordPrompt);
        if (password == null || !mounted) {
          return;
        }
        try {
          data = await BackupService.readBackup(bytes, password: password);
        } on BackupException catch (passwordError) {
          _showBackupError(passwordError);
          return;
        }
      }

      if (!mounted) {
        return;
      }
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.restoreTitle,
        message: l10n.restoreMessage,
        confirmLabel: l10n.import,
        cancelLabel: l10n.cancel,
        destructive: false,
      );
      if (!confirmed || !mounted) {
        return;
      }

      await BackupService.restore(
        db: ref.read(databaseProvider),
        data: data,
      );
      final restoredSettings = ref.read(settingsRepositoryProvider).load();
      ref.read(appLockProvider.notifier).unlockWithoutPrompt();
      if (!mounted) {
        return;
      }
      showAppSnack(context, l10n.restoreSuccess);
      context.go(
        restoredSettings.onboardingComplete ? '/dashboard' : '/onboarding',
      );
    } catch (_) {
      if (mounted) {
        showAppSnack(context, l10n.restoreFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _exportCsv() async {
    if (_busy) {
      return;
    }
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final bytes = CsvService.buildTransactionsCsv(
        transactions: ref.read(transactionsRepositoryProvider).getAll(),
        accounts: ref.read(accountsRepositoryProvider).getAll(),
        categories: ref.read(categoriesRepositoryProvider).getAll(),
        spaces: ref.read(spacesRepositoryProvider).getAll(),
      );
      final fileName = 'rofin-transactions-${_timestamp()}.csv';
      final savedPath = await _shareBytes(
        bytes: bytes,
        fileName: fileName,
        mimeType: 'text/csv',
        subject: l10n.exportCsv,
      );
      if (!mounted) {
        return;
      }
      showAppSnack(
        context,
        savedPath == null ? l10n.csvExported : l10n.savedTo(savedPath),
      );
    } catch (_) {
      if (mounted) {
        showAppSnack(context, l10n.csvExportFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndRestore)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.tealDeep, AppColors.teal],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.backupRestoreHint,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.includeEverything,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.history,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${l10n.lastBackup}: '
                        '${settings.lastBackupAt == null ? l10n.neverBackedUp : _formatDateTime(settings.lastBackupAt!, locale)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.upload_file_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.exportBackup,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.exportBackupHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _usePassword,
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _usePassword = value),
                    secondary: const Icon(Icons.key_outlined),
                    title: Text(l10n.encryptBackup),
                    subtitle: Text(
                      l10n.backupPasswordHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (_usePassword) ...<Widget>[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: l10n.backupPassword,
                        prefixIcon: const Icon(Icons.key_outlined),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? l10n.showAmounts : l10n.hideAmounts,
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: l10n.backupPasswordConfirm,
                        prefixIcon: const Icon(Icons.key_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy ? null : _exportBackup,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.ios_share_outlined),
                    label: Text(l10n.exportBackup),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.backupWarning,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.download_outlined,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.importBackup,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.importBackupHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _importBackup,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(l10n.chooseFile),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.table_chart_outlined,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.exportCsv,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.exportCsvHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _exportCsv,
                    icon: const Icon(Icons.ios_share_outlined),
                    label: Text(l10n.exportCsv),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
