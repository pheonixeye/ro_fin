import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Rofin'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your money, personal and business, in one private place.'**
  String get appTagline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupAndRestore;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @onboarding.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboarding;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get net;

  /// No description provided for @netThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Net this month'**
  String get netThisMonth;

  /// No description provided for @incomeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Income this month'**
  String get incomeThisMonth;

  /// No description provided for @expensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Expenses this month'**
  String get expensesThisMonth;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account balance'**
  String get accountBalance;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get overBudget;

  /// No description provided for @budgetProgress.
  ///
  /// In en, this message translates to:
  /// **'Budget progress'**
  String get budgetProgress;

  /// No description provided for @ofBudget.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {budget}'**
  String ofBudget(String spent, String budget);

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @allSpaces.
  ///
  /// In en, this message translates to:
  /// **'All spaces'**
  String get allSpaces;

  /// No description provided for @space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get space;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get transactionDetails;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first income, expense, or transfer to see it here.'**
  String get noTransactionsBody;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactions;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get filterByType;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'What was this for?'**
  String get noteHint;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get toAccount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get selectAccount;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @selectSpace.
  ///
  /// In en, this message translates to:
  /// **'Select a space'**
  String get selectSpace;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get saveTransaction;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'This transaction will be permanently removed. This cannot be undone.'**
  String get deleteTransactionMessage;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get transactionSaved;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @transferHint.
  ///
  /// In en, this message translates to:
  /// **'Transfers move money between your accounts. They are not income or expenses — use them for owner draws or moving cash.'**
  String get transferHint;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @incomeShort.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeShort;

  /// No description provided for @expenseShort.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseShort;

  /// No description provided for @transferShort.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferShort;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by note, category, or account'**
  String get searchHint;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(int count);

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noResults;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear the filters.'**
  String get noResultsBody;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @accountNameAr.
  ///
  /// In en, this message translates to:
  /// **'Name in Arabic'**
  String get accountNameAr;

  /// No description provided for @accountNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name in English'**
  String get accountNameEn;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @accountTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// No description provided for @accountTypeWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get accountTypeWallet;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @accountColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get accountColor;

  /// No description provided for @accountIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get accountIcon;

  /// No description provided for @archiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Archive account'**
  String get archiveAccount;

  /// No description provided for @archiveAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Archived accounts stay in your history but are hidden from new transactions.'**
  String get archiveAccountMessage;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccounts;

  /// No description provided for @noAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'Add a cash box, bank account, or wallet to start tracking balances.'**
  String get noAccountsBody;

  /// No description provided for @accountSaved.
  ///
  /// In en, this message translates to:
  /// **'Account saved'**
  String get accountSaved;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Transactions linked to this account will keep their history but will show no account. This cannot be undone.'**
  String get deleteAccountMessage;

  /// No description provided for @defaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Default account'**
  String get defaultAccount;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryNameAr.
  ///
  /// In en, this message translates to:
  /// **'Name in Arabic'**
  String get categoryNameAr;

  /// No description provided for @categoryNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name in English'**
  String get categoryNameEn;

  /// No description provided for @categoryKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get categoryKind;

  /// No description provided for @categoryScope.
  ///
  /// In en, this message translates to:
  /// **'Applies to'**
  String get categoryScope;

  /// No description provided for @scopePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal only'**
  String get scopePersonal;

  /// No description provided for @scopeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business only'**
  String get scopeBusiness;

  /// No description provided for @scopeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both spaces'**
  String get scopeBoth;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategories;

  /// No description provided for @noCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Add a category so your transactions are easier to understand.'**
  String get noCategoriesBody;

  /// No description provided for @categorySaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get categorySaved;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Transactions in this category will keep their history but will show as uncategorized. This cannot be undone.'**
  String get deleteCategoryMessage;

  /// No description provided for @systemCategory.
  ///
  /// In en, this message translates to:
  /// **'Built-in category'**
  String get systemCategory;

  /// No description provided for @systemCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Built-in categories cannot be deleted, but you can edit their names.'**
  String get systemCategoryHint;

  /// No description provided for @customCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom category'**
  String get customCategory;

  /// No description provided for @monthlyBudgets.
  ///
  /// In en, this message translates to:
  /// **'Monthly budgets'**
  String get monthlyBudgets;

  /// No description provided for @addBudget.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get addBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudget;

  /// No description provided for @overallBudget.
  ///
  /// In en, this message translates to:
  /// **'Overall budget'**
  String get overallBudget;

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Category budget'**
  String get categoryBudget;

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets for this month'**
  String get noBudgets;

  /// No description provided for @noBudgetsBody.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit to keep spending in check.'**
  String get noBudgetsBody;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetSaved;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'The spending history stays untouched. This cannot be undone.'**
  String get deleteBudgetMessage;

  /// No description provided for @budgetFor.
  ///
  /// In en, this message translates to:
  /// **'Budget for {month}'**
  String budgetFor(String month);

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// No description provided for @monthlyBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Budgets reset every month. You can set one overall limit or limits per category.'**
  String get monthlyBudgetHint;

  /// No description provided for @budgetsForSpace.
  ///
  /// In en, this message translates to:
  /// **'Budgets for {space}'**
  String budgetsForSpace(String space);

  /// No description provided for @recurringRules.
  ///
  /// In en, this message translates to:
  /// **'Recurring rules'**
  String get recurringRules;

  /// No description provided for @addRecurring.
  ///
  /// In en, this message translates to:
  /// **'Add recurring rule'**
  String get addRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring rule'**
  String get editRecurring;

  /// No description provided for @noRecurring.
  ///
  /// In en, this message translates to:
  /// **'No recurring rules'**
  String get noRecurring;

  /// No description provided for @noRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'Add rent, salaries, or subscriptions once and Rofin will post them for you.'**
  String get noRecurringBody;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get interval;

  /// No description provided for @dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get dayOfMonth;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get nextDue;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @autoPost.
  ///
  /// In en, this message translates to:
  /// **'Post automatically'**
  String get autoPost;

  /// No description provided for @autoPostHint.
  ///
  /// In en, this message translates to:
  /// **'Rofin posts the transaction when it is due. You can turn this off and post manually.'**
  String get autoPostHint;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @recurringSaved.
  ///
  /// In en, this message translates to:
  /// **'Recurring rule saved'**
  String get recurringSaved;

  /// No description provided for @recurringDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recurring rule deleted'**
  String get recurringDeleted;

  /// No description provided for @deleteRecurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring rule?'**
  String get deleteRecurringTitle;

  /// No description provided for @deleteRecurringMessage.
  ///
  /// In en, this message translates to:
  /// **'Future transactions will not be posted. Past transactions stay. This cannot be undone.'**
  String get deleteRecurringMessage;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @reportsOverview.
  ///
  /// In en, this message translates to:
  /// **'Reports overview'**
  String get reportsOverview;

  /// No description provided for @sixMonthTrend.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get sixMonthTrend;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get spendingByCategory;

  /// No description provided for @incomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by category'**
  String get incomeByCategory;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get topCategories;

  /// No description provided for @noReportData.
  ///
  /// In en, this message translates to:
  /// **'Nothing to report yet'**
  String get noReportData;

  /// No description provided for @noReportDataBody.
  ///
  /// In en, this message translates to:
  /// **'Add some transactions for this month to see your report.'**
  String get noReportDataBody;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get totalExpenses;

  /// No description provided for @netResult.
  ///
  /// In en, this message translates to:
  /// **'Net result'**
  String get netResult;

  /// No description provided for @reportFor.
  ///
  /// In en, this message translates to:
  /// **'Report for {month}'**
  String reportFor(String month);

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @csvExported.
  ///
  /// In en, this message translates to:
  /// **'CSV exported'**
  String get csvExported;

  /// No description provided for @csvExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export CSV'**
  String get csvExportFailed;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get currencyLabel;

  /// No description provided for @currencyHint.
  ///
  /// In en, this message translates to:
  /// **'Used for totals, budgets, and new accounts.'**
  String get currencyHint;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockHint.
  ///
  /// In en, this message translates to:
  /// **'Ask for your device PIN, pattern, or biometrics when opening Rofin.'**
  String get appLockHint;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLock;

  /// No description provided for @lockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockImmediately;

  /// No description provided for @lockAfter30s.
  ///
  /// In en, this message translates to:
  /// **'After 30 seconds'**
  String get lockAfter30s;

  /// No description provided for @lockAfter1m.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get lockAfter1m;

  /// No description provided for @lockAfter5m.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get lockAfter5m;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @hideInRecents.
  ///
  /// In en, this message translates to:
  /// **'Hide in app switcher'**
  String get hideInRecents;

  /// No description provided for @hideInRecentsHint.
  ///
  /// In en, this message translates to:
  /// **'Hides Rofin in recent apps and blocks screenshots. You can still take manual backups.'**
  String get hideInRecentsHint;

  /// No description provided for @deviceAuthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Device lock unavailable'**
  String get deviceAuthUnavailable;

  /// No description provided for @deviceAuthUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Set a PIN, pattern, or biometric lock on your device to use app lock.'**
  String get deviceAuthUnavailableHint;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get manageAccounts;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get manageCategories;

  /// No description provided for @manageBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get manageBudgets;

  /// No description provided for @manageRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get manageRecurring;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Export a private copy of all your data, or restore one.'**
  String get backupRestoreHint;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get resetData;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all data?'**
  String get resetDataTitle;

  /// No description provided for @resetDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Every account, transaction, budget, and setting will be deleted from this device. This cannot be undone.'**
  String get resetDataMessage;

  /// No description provided for @resetDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetDataConfirm;

  /// No description provided for @dataReset.
  ///
  /// In en, this message translates to:
  /// **'All data reset'**
  String get dataReset;

  /// No description provided for @aboutRofin.
  ///
  /// In en, this message translates to:
  /// **'About Rofin'**
  String get aboutRofin;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyHint.
  ///
  /// In en, this message translates to:
  /// **'Rofin works fully offline. Your data stays on this device, encrypted at rest. No account, no cloud, no tracking.'**
  String get privacyHint;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made for the job and the business.'**
  String get madeWith;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSaved;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'One private place for all your money'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your salary and your business without mixing them up — and without sending your data anywhere.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingFeaturePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline by design'**
  String get onboardingFeaturePrivateTitle;

  /// No description provided for @onboardingFeaturePrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored on your device in an encrypted database. No cloud account required.'**
  String get onboardingFeaturePrivateBody;

  /// No description provided for @onboardingFeatureSpacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal and business, together'**
  String get onboardingFeatureSpacesTitle;

  /// No description provided for @onboardingFeatureSpacesBody.
  ///
  /// In en, this message translates to:
  /// **'Keep separate books, shared accounts, and clear reports for each side of your life.'**
  String get onboardingFeatureSpacesBody;

  /// No description provided for @onboardingFeatureSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked with your device'**
  String get onboardingFeatureSecureTitle;

  /// No description provided for @onboardingFeatureSecureBody.
  ///
  /// In en, this message translates to:
  /// **'Open Rofin with your fingerprint, face, or device PIN. Nothing else to remember.'**
  String get onboardingFeatureSecureBody;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get onboardingPreferencesTitle;

  /// No description provided for @onboardingPreferencesBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how Rofin looks and speaks. You can change all of this later in Settings.'**
  String get onboardingPreferencesBody;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get onboardingCurrency;

  /// No description provided for @onboardingTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get onboardingTheme;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onboardingNote.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves this device unless you export a backup.'**
  String get onboardingNote;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rofin'**
  String get onboardingWelcome;

  /// No description provided for @onboardingStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(int current, int total);

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect Rofin'**
  String get onboardingLockTitle;

  /// No description provided for @onboardingLockBody.
  ///
  /// In en, this message translates to:
  /// **'Use your device lock to keep your finances private. You can turn this off later.'**
  String get onboardingLockBody;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable app lock'**
  String get enableAppLock;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @onboardingDone.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set'**
  String get onboardingDone;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Rofin is locked'**
  String get lockTitle;

  /// No description provided for @lockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with your device PIN, pattern, or biometrics.'**
  String get lockSubtitle;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlocking.
  ///
  /// In en, this message translates to:
  /// **'Unlocking…'**
  String get unlocking;

  /// No description provided for @unlockPrompt.
  ///
  /// In en, this message translates to:
  /// **'Unlock Rofin to continue'**
  String get unlockPrompt;

  /// No description provided for @lockError.
  ///
  /// In en, this message translates to:
  /// **'Could not unlock. Try again.'**
  String get lockError;

  /// No description provided for @lockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Device lock is not available on this device.'**
  String get lockUnavailable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Rofin locked'**
  String get appLocked;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Save a complete copy of your data. Keep it somewhere safe.'**
  String get exportBackupHint;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @importBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Restore from a Rofin backup file. This replaces everything on this device.'**
  String get importBackupHint;

  /// No description provided for @encryptBackup.
  ///
  /// In en, this message translates to:
  /// **'Encrypt with a password'**
  String get encryptBackup;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @backupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters. You will need it to restore.'**
  String get backupPasswordHint;

  /// No description provided for @backupPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupPasswordConfirm;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @exportWithoutPassword.
  ///
  /// In en, this message translates to:
  /// **'Export without a password'**
  String get exportWithoutPassword;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported'**
  String get backupExported;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export backup'**
  String get backupExportFailed;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreTitle;

  /// No description provided for @restoreMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace all accounts, transactions, budgets, and settings on this device.'**
  String get restoreMessage;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get restoreSuccess;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore backup'**
  String get restoreFailed;

  /// No description provided for @invalidBackup.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid Rofin backup.'**
  String get invalidBackup;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password or damaged backup.'**
  String get wrongPassword;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the backup password.'**
  String get passwordRequired;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackup;

  /// No description provided for @neverBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get neverBackedUp;

  /// No description provided for @shareBackup.
  ///
  /// In en, this message translates to:
  /// **'Share backup'**
  String get shareBackup;

  /// No description provided for @includeEverything.
  ///
  /// In en, this message translates to:
  /// **'Includes accounts, transactions, categories, budgets, recurring rules, and settings.'**
  String get includeEverything;

  /// No description provided for @backupWarning.
  ///
  /// In en, this message translates to:
  /// **'A backup is not encrypted unless you set a password. Store it safely.'**
  String get backupWarning;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @savedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String savedTo(String path);

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @backupFileType.
  ///
  /// In en, this message translates to:
  /// **'Rofin backup'**
  String get backupFileType;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero'**
  String get amountMustBePositive;

  /// No description provided for @selectDifferentAccounts.
  ///
  /// In en, this message translates to:
  /// **'Choose two different accounts'**
  String get selectDifferentAccounts;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name in at least one language'**
  String get nameRequired;

  /// No description provided for @deleteCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteCannotUndo;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @monthlyOverview.
  ///
  /// In en, this message translates to:
  /// **'Monthly overview'**
  String get monthlyOverview;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get unknownCategory;

  /// No description provided for @noSpace.
  ///
  /// In en, this message translates to:
  /// **'No space'**
  String get noSpace;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get allTransactions;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6Months;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @ownerDrawHint.
  ///
  /// In en, this message translates to:
  /// **'Owner draws are transfers, not expenses.'**
  String get ownerDrawHint;

  /// No description provided for @unlockWithDevice.
  ///
  /// In en, this message translates to:
  /// **'Unlock with device'**
  String get unlockWithDevice;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to dashboard'**
  String get backToDashboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
