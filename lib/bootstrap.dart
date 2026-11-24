import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/database/app_database.dart';
import 'core/database/hive_list_repository.dart';
import 'core/database/seed_service.dart';
import 'core/database/settings_repository.dart';
import 'core/models/app_settings.dart';
import 'core/models/recurring_rule.dart';
import 'core/models/txn.dart';
import 'core/security/secure_key_store.dart';
import 'core/services/recurring_service.dart';

class AppBootstrap {
  const AppBootstrap({
    required this.database,
    required this.settings,
  });

  final AppDatabase database;
  final AppSettings settings;

  static Future<AppBootstrap> create() async {
    await Hive.initFlutter();

    final key = await SecureKeyStore().loadOrCreate();
    final database = await AppDatabase.open(key);
    final settingsRepository = SettingsRepository(database.settingsBox);
    var settings = settingsRepository.load();

    await SeedService.ensureSeeded(
      spacesBox: database.spacesBox,
      accountsBox: database.accountsBox,
      categoriesBox: database.categoriesBox,
      currencyCode: settings.currencyCode,
    );

    if (settings.seedVersion != SeedService.currentSeedVersion) {
      settings = settings.copyWith(
        seedVersion: SeedService.currentSeedVersion,
      );
      await settingsRepository.save(settings);
    }

    final recurringRepository = HiveListRepository<RecurringRule>(
      box: database.recurringBox,
      fromMap: RecurringRule.fromMap,
      toMap: (rule) => rule.toMap(),
      idOf: (rule) => rule.id,
    );
    final transactionsRepository = HiveListRepository<Txn>(
      box: database.transactionsBox,
      fromMap: Txn.fromMap,
      toMap: (txn) => txn.toMap(),
      idOf: (txn) => txn.id,
    );

    try {
      await const RecurringService().runDue(
        rules: recurringRepository,
        transactions: transactionsRepository,
      );
    } catch (error, stack) {
      debugPrint('Could not post recurring transactions: $error');
      debugPrintStack(stackTrace: stack);
    }

    return AppBootstrap(database: database, settings: settings);
  }
}
