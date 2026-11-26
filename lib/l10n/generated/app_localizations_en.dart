// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Rofin';

  @override
  String get appTagline =>
      'Your money, personal and business, in one private place.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get editSpace => 'Edit space';

  @override
  String get add => 'Add';

  @override
  String get addSpace => 'Add space';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get apply => 'Apply';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading…';

  @override
  String get optional => 'Optional';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisMonth => 'This month';

  @override
  String get currency => 'Currency';

  @override
  String get total => 'Total';

  @override
  String get unknown => 'Unknown';

  @override
  String get custom => 'Custom';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get transactions => 'Transactions';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get accounts => 'Accounts';

  @override
  String get categories => 'Categories';

  @override
  String get budgets => 'Budgets';

  @override
  String get recurring => 'Recurring';

  @override
  String get backup => 'Backup';

  @override
  String get backupAndRestore => 'Backup & restore';

  @override
  String get about => 'About';

  @override
  String get onboarding => 'Welcome';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get expense => 'Expense';

  @override
  String get transfer => 'Transfer';

  @override
  String get transfers => 'Transfers';

  @override
  String get balance => 'Balance';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get net => 'Net';

  @override
  String get netThisMonth => 'Net this month';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get incomeThisMonth => 'Income this month';

  @override
  String get expensesThisMonth => 'Expenses this month';

  @override
  String get amount => 'Amount';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get accountBalance => 'Account balance';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get repeatEvery => 'Repeat every';

  @override
  String recurringEveryWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String recurringEveryMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String recurringEveryYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count years',
      one: 'Every year',
    );
    return '$_temp0';
  }

  @override
  String get postNow => 'Post now';

  @override
  String get postNowMessage =>
      'This adds the transaction today and moves the next due date forward.';

  @override
  String recurringPosted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Posted $count transactions',
      one: 'Posted 1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get overBudget => 'Over budget';

  @override
  String get budgetProgress => 'Budget progress';

  @override
  String ofBudget(String spent, String budget) {
    return '$spent of $budget';
  }

  @override
  String get personal => 'Personal';

  @override
  String get business => 'Business';

  @override
  String get allSpaces => 'All spaces';

  @override
  String get space => 'Space';

  @override
  String get spaceKind => 'Space type';

  @override
  String get spaceKindHint =>
      'Choose whether this space is for your personal life or your business.';

  @override
  String get spaceNameAr => 'Space name in Arabic';

  @override
  String get spaceNameEn => 'Space name in English';

  @override
  String get spaceSaved => 'Space saved';

  @override
  String get spaces => 'Spaces';

  @override
  String get spacesHint =>
      'Separate your personal life from your business without mixing the numbers.';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get transactionDetails => 'Transaction details';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get noTransactionsBody =>
      'Add your first income, expense, or transfer to see it here.';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get viewAll => 'View all';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get filterByType => 'Filter by type';

  @override
  String get allTypes => 'All types';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'What was this for?';

  @override
  String get date => 'Date';

  @override
  String get account => 'Account';

  @override
  String get fromAccount => 'From account';

  @override
  String get toAccount => 'To account';

  @override
  String get category => 'Category';

  @override
  String get selectAccount => 'Select an account';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get selectSpace => 'Select a space';

  @override
  String get selectDate => 'Select a date';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String get deleteTransactionMessage =>
      'This transaction will be permanently removed. This cannot be undone.';

  @override
  String get transactionSaved => 'Transaction saved';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transferHint =>
      'Transfers move money between your accounts. They are not income or expenses — use them for owner draws or moving cash.';

  @override
  String get amountHint => '0.00';

  @override
  String get incomeShort => 'Income';

  @override
  String get expenseShort => 'Expense';

  @override
  String get transferShort => 'Transfer';

  @override
  String get searchHint => 'Search by note, category, or account';

  @override
  String resultsCount(int count) {
    return '$count results';
  }

  @override
  String transactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get noResults => 'No matches';

  @override
  String get noResultsBody => 'Try a different search or clear the filters.';

  @override
  String get addAccount => 'Add account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountNameAr => 'Name in Arabic';

  @override
  String get accountNameEn => 'Name in English';

  @override
  String get accountType => 'Account type';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeWallet => 'Wallet';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accountColor => 'Color';

  @override
  String get accountIcon => 'Icon';

  @override
  String get archiveAccount => 'Archive account';

  @override
  String get archiveAccountMessage =>
      'Archived accounts stay in your history but are hidden from new transactions.';

  @override
  String get archived => 'Archived';

  @override
  String get active => 'Active';

  @override
  String get noAccounts => 'No accounts yet';

  @override
  String get noAccountsBody =>
      'Add a cash box, bank account, or wallet to start tracking balances.';

  @override
  String get accountSaved => 'Account saved';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountMessage =>
      'Transactions linked to this account will keep their history but will show no account. This cannot be undone.';

  @override
  String get defaultAccount => 'Default account';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryNameAr => 'Name in Arabic';

  @override
  String get categoryNameEn => 'Name in English';

  @override
  String get categoryKind => 'Type';

  @override
  String get categoryScope => 'Applies to';

  @override
  String get scopePersonal => 'Personal only';

  @override
  String get scopeBusiness => 'Business only';

  @override
  String get scopeBoth => 'Both spaces';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get noCategoriesBody =>
      'Add a category so your transactions are easier to understand.';

  @override
  String get categorySaved => 'Category saved';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteCategoryMessage =>
      'Transactions in this category will keep their history but will show as uncategorized. This cannot be undone.';

  @override
  String get systemCategory => 'Built-in category';

  @override
  String get systemCategoryHint =>
      'Built-in categories cannot be deleted, but you can edit their names.';

  @override
  String get customCategory => 'Custom category';

  @override
  String get monthlyBudgets => 'Monthly budgets';

  @override
  String get addBudget => 'Add budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get overallBudget => 'Overall budget';

  @override
  String get categoryBudget => 'Category budget';

  @override
  String get noBudgets => 'No budgets for this month';

  @override
  String get noBudgetsBody => 'Set a monthly limit to keep spending in check.';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get deleteBudgetTitle => 'Delete budget?';

  @override
  String get deleteBudgetMessage =>
      'The spending history stays untouched. This cannot be undone.';

  @override
  String budgetFor(String month) {
    return 'Budget for $month';
  }

  @override
  String get selectMonth => 'Select month';

  @override
  String get monthlyBudgetHint =>
      'Budgets reset every month. You can set one overall limit or limits per category.';

  @override
  String get budgetAlreadyExists =>
      'A budget already exists for this space, month, and category.';

  @override
  String budgetsForSpace(String space) {
    return 'Budgets for $space';
  }

  @override
  String get recurringRules => 'Recurring rules';

  @override
  String get addRecurring => 'Add recurring rule';

  @override
  String get editRecurring => 'Edit recurring rule';

  @override
  String get noRecurring => 'No recurring rules';

  @override
  String get noRecurringBody =>
      'Add rent, salaries, or subscriptions once and Rofin will post them for you.';

  @override
  String get frequency => 'Frequency';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get interval => 'Every';

  @override
  String get dayOfMonth => 'Day of month';

  @override
  String get nextDue => 'Next due';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get autoPost => 'Post automatically';

  @override
  String get autoPostHint =>
      'Rofin posts the transaction when it is due. You can turn this off and post manually.';

  @override
  String get paused => 'Paused';

  @override
  String get recurringSaved => 'Recurring rule saved';

  @override
  String get recurringDeleted => 'Recurring rule deleted';

  @override
  String get deleteRecurringTitle => 'Delete recurring rule?';

  @override
  String get deleteRecurringMessage =>
      'Future transactions will not be posted. Past transactions stay. This cannot be undone.';

  @override
  String get dueToday => 'Due today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get reportsOverview => 'Reports overview';

  @override
  String get sixMonthTrend => 'Last 6 months';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get incomeByCategory => 'Income by category';

  @override
  String get topCategories => 'Top categories';

  @override
  String get noReportData => 'Nothing to report yet';

  @override
  String get noReportDataBody =>
      'Add some transactions for this month to see your report.';

  @override
  String get totalIncome => 'Total income';

  @override
  String get totalExpenses => 'Total expenses';

  @override
  String get netResult => 'Net result';

  @override
  String reportFor(String month) {
    return 'Report for $month';
  }

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportCsvHint =>
      'Download a spreadsheet of every transaction for accounting or analysis.';

  @override
  String get csvExported => 'CSV exported';

  @override
  String get csvExportFailed => 'Could not export CSV';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get currencyLabel => 'Base currency';

  @override
  String get currencyHint => 'Used for totals, budgets, and new accounts.';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockHint =>
      'Ask for your device PIN, pattern, or biometrics when opening Rofin.';

  @override
  String get autoLock => 'Auto-lock';

  @override
  String get lockImmediately => 'Immediately';

  @override
  String get lockAfter30s => 'After 30 seconds';

  @override
  String get lockAfter1m => 'After 1 minute';

  @override
  String get lockAfter5m => 'After 5 minutes';

  @override
  String get lockNow => 'Lock now';

  @override
  String get hideInRecents => 'Hide in app switcher';

  @override
  String get hideInRecentsHint =>
      'Hides Rofin in recent apps and blocks screenshots. You can still take manual backups.';

  @override
  String get deviceAuthUnavailable => 'Device lock unavailable';

  @override
  String get deviceAuthUnavailableHint =>
      'Set a PIN, pattern, or biometric lock on your device to use app lock.';

  @override
  String get data => 'Data';

  @override
  String get manageAccounts => 'Accounts';

  @override
  String get manageCategories => 'Categories';

  @override
  String get manageBudgets => 'Budgets';

  @override
  String get manageRecurring => 'Recurring';

  @override
  String get backupRestore => 'Backup & restore';

  @override
  String get backupRestoreHint =>
      'Export a private copy of all your data, or restore one.';

  @override
  String get resetData => 'Reset all data';

  @override
  String get resetDataTitle => 'Reset all data?';

  @override
  String get resetDataMessage =>
      'Every account, transaction, budget, and setting will be deleted from this device. This cannot be undone.';

  @override
  String get resetDataConfirm => 'Reset';

  @override
  String get dataReset => 'All data reset';

  @override
  String get aboutRofin => 'About Rofin';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyHint =>
      'Rofin works fully offline. Your data stays on this device, encrypted at rest. No account, no cloud, no tracking.';

  @override
  String get madeWith => 'Made for the job and the business.';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get onboardingTitle => 'One private place for all your money';

  @override
  String get onboardingSubtitle =>
      'Track your salary and your business without mixing them up — and without sending your data anywhere.';

  @override
  String get onboardingFeaturePrivateTitle => 'Offline by design';

  @override
  String get onboardingFeaturePrivateBody =>
      'Everything is stored on your device in an encrypted database. No cloud account required.';

  @override
  String get onboardingFeatureSpacesTitle => 'Personal and business, together';

  @override
  String get onboardingFeatureSpacesBody =>
      'Keep separate books, shared accounts, and clear reports for each side of your life.';

  @override
  String get onboardingFeatureSecureTitle => 'Locked with your device';

  @override
  String get onboardingFeatureSecureBody =>
      'Open Rofin with your fingerprint, face, or device PIN. Nothing else to remember.';

  @override
  String get onboardingPreferencesTitle => 'Make it yours';

  @override
  String get onboardingPreferencesBody =>
      'Choose how Rofin looks and speaks. You can change all of this later in Settings.';

  @override
  String get onboardingLanguage => 'Language';

  @override
  String get onboardingCurrency => 'Currency';

  @override
  String get onboardingTheme => 'Theme';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingNote =>
      'Your data never leaves this device unless you export a backup.';

  @override
  String get onboardingWelcome => 'Welcome to Rofin';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingLockTitle => 'Protect Rofin';

  @override
  String get onboardingLockBody =>
      'Use your device lock to keep your finances private. You can turn this off later.';

  @override
  String get enableAppLock => 'Enable app lock';

  @override
  String get notNow => 'Not now';

  @override
  String get onboardingDone => 'You\'re all set';

  @override
  String get lockTitle => 'Rofin is locked';

  @override
  String get lockSubtitle =>
      'Unlock with your device PIN, pattern, or biometrics.';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlocking => 'Unlocking…';

  @override
  String get unlockPrompt => 'Unlock Rofin to continue';

  @override
  String get lockError => 'Could not unlock. Try again.';

  @override
  String get lockUnavailable => 'Device lock is not available on this device.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get appLocked => 'Rofin locked';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupHint =>
      'Save a complete copy of your data. Keep it somewhere safe.';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupHint =>
      'Restore from a Rofin backup file. This replaces everything on this device.';

  @override
  String get encryptBackup => 'Encrypt with a password';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupPasswordTooShort => 'Use at least 8 characters.';

  @override
  String get backupPasswordHint =>
      'Use at least 8 characters. You will need it to restore.';

  @override
  String get backupPasswordConfirm => 'Confirm password';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get exportWithoutPassword => 'Export without a password';

  @override
  String get backupExported => 'Backup exported';

  @override
  String get backupExportFailed => 'Could not export backup';

  @override
  String get restoreTitle => 'Restore backup?';

  @override
  String get restoreMessage =>
      'This will replace all accounts, transactions, budgets, and settings on this device.';

  @override
  String get restorePasswordPrompt =>
      'Enter the password used when this backup was created.';

  @override
  String get restoreSuccess => 'Backup restored';

  @override
  String get restoreFailed => 'Could not restore backup';

  @override
  String get invalidBackup => 'This file is not a valid Rofin backup.';

  @override
  String get wrongPassword => 'Wrong password or damaged backup.';

  @override
  String get passwordRequired => 'Enter the backup password.';

  @override
  String get lastBackup => 'Last backup';

  @override
  String get neverBackedUp => 'Never';

  @override
  String get shareBackup => 'Share backup';

  @override
  String get includeEverything =>
      'Includes accounts, transactions, categories, budgets, recurring rules, and settings.';

  @override
  String get backupWarning =>
      'A backup is not encrypted unless you set a password. Store it safely.';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get saving => 'Saving…';

  @override
  String savedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get chooseFile => 'Choose file';

  @override
  String get backupFileType => 'Rofin backup';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get amountMustBePositive => 'Amount must be greater than zero';

  @override
  String get selectDifferentAccounts => 'Choose two different accounts';

  @override
  String get nameRequired => 'Enter a name in at least one language';

  @override
  String get deleteCannotUndo => 'This cannot be undone.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get overview => 'Overview';

  @override
  String get monthlyOverview => 'Monthly overview';

  @override
  String get seeAll => 'See all';

  @override
  String get unknownCategory => 'Uncategorized';

  @override
  String get noSpace => 'No space';

  @override
  String get allTransactions => 'All transactions';

  @override
  String get summary => 'Summary';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get month => 'Month';

  @override
  String get ownerDrawHint => 'Owner draws are transfers, not expenses.';

  @override
  String get unlockWithDevice => 'Unlock with device';

  @override
  String get backToDashboard => 'Back to dashboard';

  @override
  String get archiveSpace => 'Archive space';

  @override
  String get unarchiveSpace => 'Restore space';

  @override
  String get spaceArchived => 'Space archived';

  @override
  String get spaceRestored => 'Space restored';

  @override
  String get deleteSpaceTitle => 'Delete space?';

  @override
  String get deleteSpaceMessage =>
      'The space will be removed. Transactions, budgets, and recurring rules in it keep their history but will no longer belong to a space. Consider archiving instead.';

  @override
  String get spaceDeleted => 'Space deleted';

  @override
  String get spaceInUseTitle => 'Space is still in use';

  @override
  String spaceInUseMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count records use this space. Archive it instead to keep your history tidy.',
      one: 'One record uses this space. Archive it instead to keep your history tidy.',
    );
    return '$_temp0';
  }

  @override
  String get lastSpaceRequired => 'Keep at least one active space.';

  @override
  String get spaceSystemProtected =>
      'Built-in spaces can be archived but not deleted.';

  @override
  String get archiveCategory => 'Archive category';

  @override
  String get unarchiveCategory => 'Restore category';

  @override
  String get categoryArchived => 'Category archived';

  @override
  String get categoryRestored => 'Category restored';

  @override
  String get deleteCategoryInUseTitle => 'Category is still in use';

  @override
  String deleteCategoryInUseMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count records use this category. Archive it instead so past entries stay labeled.',
      one: 'One record uses this category. Archive it instead so past entries stay labeled.',
    );
    return '$_temp0';
  }

  @override
  String get accountArchived => 'Account archived';

  @override
  String get deleteAccountInUseTitle => 'Account is still in use';

  @override
  String deleteAccountInUseMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count records use this account. Archive it instead to keep your history intact.',
      one: 'One record uses this account. Archive it instead to keep your history intact.',
    );
    return '$_temp0';
  }

  @override
  String get licenses => 'Open source licenses';
}
