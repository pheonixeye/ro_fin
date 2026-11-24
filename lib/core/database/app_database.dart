import 'dart:typed_data';

import 'package:hive_ce/hive.dart';

class AppDatabase {
  AppDatabase._({
    required this.settingsBox,
    required this.spacesBox,
    required this.accountsBox,
    required this.categoriesBox,
    required this.transactionsBox,
    required this.budgetsBox,
    required this.recurringBox,
  });

  static const settingsBoxName = 'rofin_settings';
  static const spacesBoxName = 'rofin_spaces';
  static const accountsBoxName = 'rofin_accounts';
  static const categoriesBoxName = 'rofin_categories';
  static const transactionsBoxName = 'rofin_transactions';
  static const budgetsBoxName = 'rofin_budgets';
  static const recurringBoxName = 'rofin_recurring';

  final Box<dynamic> settingsBox;
  final Box<dynamic> spacesBox;
  final Box<dynamic> accountsBox;
  final Box<dynamic> categoriesBox;
  final Box<dynamic> transactionsBox;
  final Box<dynamic> budgetsBox;
  final Box<dynamic> recurringBox;

  static Future<AppDatabase> open(Uint8List key) async {
    final cipher = HiveAesCipher(key);
    final opened = <Box<dynamic>>[];
    try {
      final settings = await Hive.openBox<dynamic>(
        settingsBoxName,
        encryptionCipher: cipher,
      );
      opened.add(settings);
      final spaces = await Hive.openBox<dynamic>(
        spacesBoxName,
        encryptionCipher: cipher,
      );
      opened.add(spaces);
      final accounts = await Hive.openBox<dynamic>(
        accountsBoxName,
        encryptionCipher: cipher,
      );
      opened.add(accounts);
      final categories = await Hive.openBox<dynamic>(
        categoriesBoxName,
        encryptionCipher: cipher,
      );
      opened.add(categories);
      final transactions = await Hive.openBox<dynamic>(
        transactionsBoxName,
        encryptionCipher: cipher,
      );
      opened.add(transactions);
      final budgets = await Hive.openBox<dynamic>(
        budgetsBoxName,
        encryptionCipher: cipher,
      );
      opened.add(budgets);
      final recurring = await Hive.openBox<dynamic>(
        recurringBoxName,
        encryptionCipher: cipher,
      );
      opened.add(recurring);

      return AppDatabase._(
        settingsBox: settings,
        spacesBox: spaces,
        accountsBox: accounts,
        categoriesBox: categories,
        transactionsBox: transactions,
        budgetsBox: budgets,
        recurringBox: recurring,
      );
    } catch (_) {
      for (final box in opened) {
        await box.close();
      }
      rethrow;
    }
  }

  List<Box<dynamic>> get allBoxes => <Box<dynamic>>[
    settingsBox,
    spacesBox,
    accountsBox,
    categoriesBox,
    transactionsBox,
    budgetsBox,
    recurringBox,
  ];

  Future<void> clearAll() async {
    for (final box in allBoxes) {
      await box.clear();
    }
  }

  Future<void> close() async {
    for (final box in allBoxes) {
      await box.close();
    }
  }
}
