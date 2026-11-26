import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/hive_list_repository.dart';
import '../database/seed_service.dart';
import '../database/settings_repository.dart';
import '../models/account.dart';
import '../models/app_settings.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/enums.dart';
import '../models/recurring_rule.dart';
import '../models/space.dart';
import '../models/txn.dart';
import '../security/auth_service.dart';
import '../services/finance_service.dart';
import '../utils/date_utils.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase must be provided by the bootstrap.');
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider).settingsBox);
});

final spacesRepositoryProvider = Provider<HiveListRepository<Space>>((ref) {
  final db = ref.watch(databaseProvider);
  return HiveListRepository<Space>(
    box: db.spacesBox,
    fromMap: Space.fromMap,
    toMap: (space) => space.toMap(),
    idOf: (space) => space.id,
  );
});

final accountsRepositoryProvider = Provider<HiveListRepository<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return HiveListRepository<Account>(
    box: db.accountsBox,
    fromMap: Account.fromMap,
    toMap: (account) => account.toMap(),
    idOf: (account) => account.id,
  );
});

final categoriesRepositoryProvider =
    Provider<HiveListRepository<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return HiveListRepository<Category>(
    box: db.categoriesBox,
    fromMap: Category.fromMap,
    toMap: (category) => category.toMap(),
    idOf: (category) => category.id,
  );
});

final transactionsRepositoryProvider =
    Provider<HiveListRepository<Txn>>((ref) {
  final db = ref.watch(databaseProvider);
  return HiveListRepository<Txn>(
    box: db.transactionsBox,
    fromMap: Txn.fromMap,
    toMap: (txn) => txn.toMap(),
    idOf: (txn) => txn.id,
  );
});

final budgetsRepositoryProvider = Provider<HiveListRepository<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  return HiveListRepository<Budget>(
    box: db.budgetsBox,
    fromMap: Budget.fromMap,
    toMap: (budget) => budget.toMap(),
    idOf: (budget) => budget.id,
  );
});

final recurringRepositoryProvider =
    Provider<HiveListRepository<RecurringRule>>((ref) {
  final db = ref.watch(databaseProvider);
  return HiveListRepository<RecurringRule>(
    box: db.recurringBox,
    fromMap: RecurringRule.fromMap,
    toMap: (rule) => rule.toMap(),
    idOf: (rule) => rule.id,
  );
});

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repository = ref.watch(settingsRepositoryProvider);
    final subscription = repository.box.watch().listen((_) {
      state = repository.load();
    });
    ref.onDispose(subscription.cancel);
    return repository.load();
  }

  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  Future<void> _save(AppSettings next) async {
    state = next;
    await _repository.save(next);
  }

  Future<void> setLocale(String locale) {
    return _save(state.copyWith(locale: locale == 'en' ? 'en' : 'ar'));
  }

  Future<void> setTheme(ThemePreference theme) {
    return _save(state.copyWith(theme: theme));
  }

  Future<void> setCurrency(String currencyCode) {
    return _save(state.copyWith(currencyCode: currencyCode));
  }

  Future<void> setActiveSpace(String spaceId) {
    return _save(state.copyWith(activeSpaceId: spaceId));
  }

  Future<void> setLockEnabled(bool enabled) {
    return _save(state.copyWith(lockEnabled: enabled));
  }

  Future<void> setAutoLockSeconds(int seconds) {
    return _save(state.copyWith(autoLockSeconds: seconds));
  }

  Future<void> setHideInRecents(bool enabled) {
    return _save(state.copyWith(hideInRecents: enabled));
  }

  Future<void> completeOnboarding({
    required String locale,
    required ThemePreference theme,
    required String currencyCode,
    required bool lockEnabled,
  }) async {
    final previous = state;
    final next = state.copyWith(
      locale: locale,
      theme: theme,
      currencyCode: currencyCode,
      lockEnabled: lockEnabled,
      onboardingComplete: true,
      seedVersion: SeedService.currentSeedVersion,
    );
    await _save(next);

    // The first-run seed uses the default currency. If the user picked a
    // different one during onboarding, relabel the untouched starter accounts.
    if (previous.currencyCode != currencyCode) {
      final accountsRepository = ref.read(accountsRepositoryProvider);
      final transactions = ref.read(transactionsRepositoryProvider).getAll();
      if (transactions.isEmpty) {
        final now = DateTime.now();
        final accounts = accountsRepository.getAll().map(
              (account) => account.copyWith(
                currencyCode: currencyCode,
                updatedAt: now,
              ),
            );
        await accountsRepository.putAll(accounts);
      }
    }
  }

  Future<void> markBackupNow() {
    return _save(state.copyWith(lastBackupAt: DateTime.now()));
  }

  Future<void> resetAll() async {
    final db = ref.read(databaseProvider);
    await db.clearAll();
    final fresh = const AppSettings();
    await _repository.save(fresh);
    await SeedService.ensureSeeded(
      spacesBox: db.spacesBox,
      accountsBox: db.accountsBox,
      categoriesBox: db.categoriesBox,
      currencyCode: fresh.currencyCode,
    );
    await _save(fresh.copyWith(seedVersion: SeedService.currentSeedVersion));
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final localeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider.select((settings) => settings.locale));
});

final themePreferenceProvider = Provider<ThemePreference>((ref) {
  return ref.watch(settingsProvider.select((settings) => settings.theme));
});

final currencyCodeProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider.select((settings) => settings.currencyCode));
});

final activeSpaceIdProvider = Provider<String>((ref) {
  final selected = ref.watch(
    settingsProvider.select((settings) => settings.activeSpaceId),
  );
  if (selected == 'all') {
    return 'all';
  }
  final spaces = ref.watch(spacesProvider).value;
  if (spaces == null) {
    return selected;
  }
  final exists = spaces.any(
    (space) => space.id == selected && !space.archived,
  );
  return exists ? selected : 'all';
});

final spacesProvider = StreamProvider<List<Space>>((ref) {
  return ref.watch(spacesRepositoryProvider).watchAll();
});

final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAll();
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAll();
});

final transactionsProvider = StreamProvider<List<Txn>>((ref) {
  return ref.watch(transactionsRepositoryProvider).watchAll();
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetsRepositoryProvider).watchAll();
});

final recurringProvider = StreamProvider<List<RecurringRule>>((ref) {
  return ref.watch(recurringRepositoryProvider).watchAll();
});

final sortedSpacesProvider = Provider<List<Space>>((ref) {
  final spaces = ref.watch(spacesProvider).value ?? const <Space>[];
  final list = spaces.where((space) => !space.archived).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return list;
});

final sortedAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
  final list = accounts.where((account) => !account.archived).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return list;
});

final sortedCategoriesProvider = Provider<List<Category>>((ref) {
  final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
  final list = categories.where((category) => !category.archived).toList()
    ..sort((a, b) {
      final byKind = a.kind.index.compareTo(b.kind.index);
      return byKind != 0 ? byKind : a.sortOrder.compareTo(b.sortOrder);
    });
  return list;
});

final sortedTransactionsProvider = Provider<List<Txn>>((ref) {
  final transactions =
      ref.watch(transactionsProvider).value ?? const <Txn>[];
  final list = transactions.toList()
    ..sort((a, b) {
      final byDate = b.dateKey.compareTo(a.dateKey);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
  return list;
});

final accountBalancesProvider = Provider<List<AccountBalance>>((ref) {
  final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
  final transactions =
      ref.watch(transactionsProvider).value ?? const <Txn>[];
  return FinanceService.accountBalances(accounts, transactions);
});

final currentMonthTotalsProvider = Provider<MonthTotals>((ref) {
  final spaceId = ref.watch(activeSpaceIdProvider);
  final transactions =
      ref.watch(transactionsProvider).value ?? const <Txn>[];
  return FinanceService.monthTotals(
    transactions,
    spaceId: spaceId,
    monthKey: monthKey(DateTime.now()),
  );
});

class DashboardData {
  const DashboardData({
    required this.totalBalanceMinor,
    required this.monthTotals,
    required this.recentTransactions,
    required this.expenseCategories,
    required this.series,
    required this.budgetProgress,
    required this.accounts,
    required this.spaces,
    required this.categories,
    required this.activeSpaceId,
  });

  final int totalBalanceMinor;
  final MonthTotals monthTotals;
  final List<Txn> recentTransactions;
  final List<CategoryTotal> expenseCategories;
  final List<MonthPoint> series;
  final List<BudgetProgress> budgetProgress;
  final List<Account> accounts;
  final List<Space> spaces;
  final List<Category> categories;
  final String activeSpaceId;
}

final dashboardDataProvider = Provider<DashboardData>((ref) {
  final settings = ref.watch(settingsProvider);
  final accounts = ref.watch(sortedAccountsProvider);
  final spaces = ref.watch(sortedSpacesProvider);
  final categories = ref.watch(sortedCategoriesProvider);
  final transactions = ref.watch(sortedTransactionsProvider);
  final budgets = ref.watch(budgetsProvider).value ?? const <Budget>[];
  final now = DateTime.now();
  final currentMonth = monthKey(now);
  final spaceId = settings.activeSpaceId;

  final scopedTransactions = FinanceService.forSpace(
    transactions,
    spaceId,
  ).toList();

  final recent = scopedTransactions.take(6).toList(growable: false);

  final totals = FinanceService.monthTotals(
    transactions,
    spaceId: spaceId,
    monthKey: currentMonth,
  );

  final categoryTotals = FinanceService.categoryTotals(
    transactions: transactions,
    categories: categories,
    kind: CategoryKind.expense,
    spaceId: spaceId,
    monthKey: currentMonth,
  );

  final series = FinanceService.monthlySeries(
    transactions: transactions,
    spaceId: spaceId,
    endMonthKey: currentMonth,
    count: 6,
  );

  final progress = FinanceService.budgetProgress(
    budgets: budgets,
    categories: categories,
    transactions: transactions,
    spaceId: spaceId,
    monthKey: currentMonth,
  );

  return DashboardData(
    totalBalanceMinor: FinanceService.totalBalance(accounts, transactions),
    monthTotals: totals,
    recentTransactions: recent,
    expenseCategories: categoryTotals,
    series: series,
    budgetProgress: progress,
    accounts: accounts,
    spaces: spaces,
    categories: categories,
    activeSpaceId: spaceId,
  );
});

enum LockStatus { locked, unlocking, unlocked }

class LockState {
  const LockState(
    this.status, {
    this.failure,
  });

  final LockStatus status;
  final AuthOutcome? failure;

  bool get isLocked => status == LockStatus.locked;
  bool get isUnlocking => status == LockStatus.unlocking;
}

class AppLockController extends Notifier<LockState> {
  @override
  LockState build() {
    final settings = ref.read(settingsProvider);
    final shouldLock = settings.onboardingComplete && settings.lockEnabled;
    return LockState(
      shouldLock ? LockStatus.locked : LockStatus.unlocked,
    );
  }

  Future<void> unlock() async {
    if (state.status == LockStatus.unlocking) {
      return;
    }
    final auth = ref.read(authServiceProvider);
    if (auth.isPreviewBypass) {
      state = const LockState(LockStatus.unlocked);
      return;
    }
    state = const LockState(LockStatus.unlocking);
    final outcome = await auth.authenticate(
      'Unlock Rofin to continue',
    );
    if (outcome == AuthOutcome.success) {
      state = const LockState(LockStatus.unlocked);
    } else {
      state = LockState(LockStatus.locked, failure: outcome);
    }
  }

  void lock() {
    final settings = ref.read(settingsProvider);
    if (!settings.onboardingComplete || !settings.lockEnabled) {
      return;
    }
    state = const LockState(LockStatus.locked);
  }

  void unlockWithoutPrompt() {
    state = const LockState(LockStatus.unlocked);
  }
}

final appLockProvider =
    NotifierProvider<AppLockController, LockState>(AppLockController.new);
