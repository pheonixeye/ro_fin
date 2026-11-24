// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'روفن';

  @override
  String get appTagline => 'أموالك الشخصية والعملية في مكان واحد خاص.';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get done => 'تم';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get skip => 'تخطي';

  @override
  String get close => 'إغلاق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get search => 'بحث';

  @override
  String get clear => 'مسح';

  @override
  String get all => 'الكل';

  @override
  String get none => 'بدون';

  @override
  String get apply => 'تطبيق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get optional => 'اختياري';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get currency => 'العملة';

  @override
  String get total => 'الإجمالي';

  @override
  String get unknown => 'غير معروف';

  @override
  String get custom => 'مخصص';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get transactions => 'المعاملات';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get accounts => 'الحسابات';

  @override
  String get categories => 'الفئات';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get recurring => 'المتكررة';

  @override
  String get backup => 'النسخ الاحتياطي';

  @override
  String get backupAndRestore => 'النسخ والاستعادة';

  @override
  String get about => 'حول';

  @override
  String get onboarding => 'مرحباً';

  @override
  String get income => 'الدخل';

  @override
  String get expenses => 'المصروفات';

  @override
  String get expense => 'مصروف';

  @override
  String get transfer => 'تحويل';

  @override
  String get transfers => 'التحويلات';

  @override
  String get balance => 'الرصيد';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get net => 'الصافي';

  @override
  String get netThisMonth => 'صافي هذا الشهر';

  @override
  String get incomeThisMonth => 'دخل هذا الشهر';

  @override
  String get expensesThisMonth => 'مصروفات هذا الشهر';

  @override
  String get amount => 'المبلغ';

  @override
  String get openingBalance => 'الرصيد الافتتاحي';

  @override
  String get accountBalance => 'رصيد الحساب';

  @override
  String get spent => 'المصروف';

  @override
  String get remaining => 'المتبقي';

  @override
  String get overBudget => 'تجاوزت الميزانية';

  @override
  String get budgetProgress => 'تقدم الميزانية';

  @override
  String ofBudget(String spent, String budget) {
    return '$spent من $budget';
  }

  @override
  String get personal => 'شخصي';

  @override
  String get business => 'العمل';

  @override
  String get allSpaces => 'كل المساحات';

  @override
  String get space => 'المساحة';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get editTransaction => 'تعديل المعاملة';

  @override
  String get transactionDetails => 'تفاصيل المعاملة';

  @override
  String get noTransactions => 'لا توجد معاملات بعد';

  @override
  String get noTransactionsBody => 'أضف أول دخل أو مصروف أو تحويل ليظهر هنا.';

  @override
  String get recentTransactions => 'أحدث المعاملات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get searchTransactions => 'ابحث في المعاملات';

  @override
  String get filterByType => 'تصفية حسب النوع';

  @override
  String get allTypes => 'كل الأنواع';

  @override
  String get note => 'ملاحظة';

  @override
  String get noteHint => 'ما سبب هذه المعاملة؟';

  @override
  String get date => 'التاريخ';

  @override
  String get account => 'الحساب';

  @override
  String get fromAccount => 'من حساب';

  @override
  String get toAccount => 'إلى حساب';

  @override
  String get category => 'الفئة';

  @override
  String get selectAccount => 'اختر حساباً';

  @override
  String get selectCategory => 'اختر فئة';

  @override
  String get selectSpace => 'اختر مساحة';

  @override
  String get selectDate => 'اختر تاريخاً';

  @override
  String get saveTransaction => 'حفظ المعاملة';

  @override
  String get deleteTransactionTitle => 'حذف المعاملة؟';

  @override
  String get deleteTransactionMessage =>
      'ستُحذف هذه المعاملة نهائياً. لا يمكن التراجع عن ذلك.';

  @override
  String get transactionSaved => 'تم حفظ المعاملة';

  @override
  String get transactionDeleted => 'تم حذف المعاملة';

  @override
  String get transferHint =>
      'التحويلات تنقل المال بين حساباتك. ليست دخلاً أو مصروفاً — استخدمها لسحب المالك أو نقل النقد.';

  @override
  String get amountHint => '0.00';

  @override
  String get incomeShort => 'دخل';

  @override
  String get expenseShort => 'مصروف';

  @override
  String get transferShort => 'تحويل';

  @override
  String get searchHint => 'ابحث بالملاحظة أو الفئة أو الحساب';

  @override
  String resultsCount(int count) {
    return '$count نتيجة';
  }

  @override
  String transactionsCount(int count) {
    return '$count معاملة';
  }

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get noResultsBody => 'جرّب بحثاً آخر أو امسح عوامل التصفية.';

  @override
  String get addAccount => 'إضافة حساب';

  @override
  String get editAccount => 'تعديل الحساب';

  @override
  String get accountNameAr => 'الاسم بالعربية';

  @override
  String get accountNameEn => 'الاسم بالإنجليزية';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get accountTypeCash => 'نقدي';

  @override
  String get accountTypeBank => 'بنكي';

  @override
  String get accountTypeCard => 'بطاقة';

  @override
  String get accountTypeWallet => 'محفظة';

  @override
  String get accountTypeOther => 'أخرى';

  @override
  String get accountColor => 'اللون';

  @override
  String get accountIcon => 'الأيقونة';

  @override
  String get archiveAccount => 'أرشفة الحساب';

  @override
  String get archiveAccountMessage =>
      'تبقى الحسابات المؤرشفة في سجلك لكنها تختفي من المعاملات الجديدة.';

  @override
  String get archived => 'مؤرشف';

  @override
  String get active => 'نشط';

  @override
  String get noAccounts => 'لا توجد حسابات بعد';

  @override
  String get noAccountsBody =>
      'أضف صندوقاً نقدياً أو حساباً بنكياً أو محفظة لتبدأ متابعة الأرصدة.';

  @override
  String get accountSaved => 'تم حفظ الحساب';

  @override
  String get accountDeleted => 'تم حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف الحساب؟';

  @override
  String get deleteAccountMessage =>
      'ستحتفظ المعاملات المرتبطة بهذا الحساب بسجلها لكنها لن تعرض حساباً. لا يمكن التراجع عن ذلك.';

  @override
  String get defaultAccount => 'الحساب الافتراضي';

  @override
  String get addCategory => 'إضافة فئة';

  @override
  String get editCategory => 'تعديل الفئة';

  @override
  String get categoryNameAr => 'الاسم بالعربية';

  @override
  String get categoryNameEn => 'الاسم بالإنجليزية';

  @override
  String get categoryKind => 'النوع';

  @override
  String get categoryScope => 'تنطبق على';

  @override
  String get scopePersonal => 'شخصي فقط';

  @override
  String get scopeBusiness => 'العمل فقط';

  @override
  String get scopeBoth => 'كلتا المساحتين';

  @override
  String get noCategories => 'لا توجد فئات بعد';

  @override
  String get noCategoriesBody => 'أضف فئة لتصبح معاملاتك أوضح.';

  @override
  String get categorySaved => 'تم حفظ الفئة';

  @override
  String get categoryDeleted => 'تم حذف الفئة';

  @override
  String get deleteCategoryTitle => 'حذف الفئة؟';

  @override
  String get deleteCategoryMessage =>
      'ستحتفظ المعاملات في هذه الفئة بسجلها لكنها ستظهر بدون فئة. لا يمكن التراجع عن ذلك.';

  @override
  String get systemCategory => 'فئة مدمجة';

  @override
  String get systemCategoryHint =>
      'لا يمكن حذف الفئات المدمجة، لكن يمكنك تعديل أسمائها.';

  @override
  String get customCategory => 'فئة مخصصة';

  @override
  String get monthlyBudgets => 'الميزانيات الشهرية';

  @override
  String get addBudget => 'إضافة ميزانية';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get overallBudget => 'ميزانية إجمالية';

  @override
  String get categoryBudget => 'ميزانية فئة';

  @override
  String get noBudgets => 'لا توجد ميزانيات لهذا الشهر';

  @override
  String get noBudgetsBody => 'حدد سقفاً شهرياً للحفاظ على إنفاقك تحت السيطرة.';

  @override
  String get budgetAmount => 'مبلغ الميزانية';

  @override
  String get budgetSaved => 'تم حفظ الميزانية';

  @override
  String get budgetDeleted => 'تم حذف الميزانية';

  @override
  String get deleteBudgetTitle => 'حذف الميزانية؟';

  @override
  String get deleteBudgetMessage =>
      'سجل الإنفاق لن يتأثر. لا يمكن التراجع عن ذلك.';

  @override
  String budgetFor(String month) {
    return 'ميزانية $month';
  }

  @override
  String get selectMonth => 'اختر الشهر';

  @override
  String get monthlyBudgetHint =>
      'تتجدد الميزانيات كل شهر. يمكنك وضع سقف إجمالي أو سقوف لكل فئة.';

  @override
  String budgetsForSpace(String space) {
    return 'ميزانيات $space';
  }

  @override
  String get recurringRules => 'القواعد المتكررة';

  @override
  String get addRecurring => 'إضافة قاعدة متكررة';

  @override
  String get editRecurring => 'تعديل القاعدة المتكررة';

  @override
  String get noRecurring => 'لا توجد قواعد متكررة';

  @override
  String get noRecurringBody =>
      'أضف الإيجار أو الرواتب أو الاشتراكات مرة واحدة وسيسجلها روفن تلقائياً.';

  @override
  String get frequency => 'التكرار';

  @override
  String get weekly => 'أسبوعياً';

  @override
  String get monthly => 'شهرياً';

  @override
  String get yearly => 'سنوياً';

  @override
  String get interval => 'كل';

  @override
  String get dayOfMonth => 'يوم الشهر';

  @override
  String get nextDue => 'الاستحقاق القادم';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get autoPost => 'تسجيل تلقائي';

  @override
  String get autoPostHint =>
      'يسجل روفن المعاملة عند استحقاقها. يمكنك إيقاف ذلك وتسجيلها يدوياً.';

  @override
  String get paused => 'متوقفة';

  @override
  String get recurringSaved => 'تم حفظ القاعدة المتكررة';

  @override
  String get recurringDeleted => 'تم حذف القاعدة المتكررة';

  @override
  String get deleteRecurringTitle => 'حذف القاعدة المتكررة؟';

  @override
  String get deleteRecurringMessage =>
      'لن تُسجل المعاملات المستقبلية. تبقى المعاملات السابقة. لا يمكن التراجع عن ذلك.';

  @override
  String get dueToday => 'مستحقة اليوم';

  @override
  String get upcoming => 'القادمة';

  @override
  String get reportsOverview => 'نظرة عامة على التقارير';

  @override
  String get sixMonthTrend => 'آخر 6 أشهر';

  @override
  String get spendingByCategory => 'الإنفاق حسب الفئة';

  @override
  String get incomeByCategory => 'الدخل حسب الفئة';

  @override
  String get topCategories => 'أعلى الفئات';

  @override
  String get noReportData => 'لا توجد بيانات بعد';

  @override
  String get noReportDataBody => 'أضف بعض المعاملات لهذا الشهر لعرض تقريرك.';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get totalExpenses => 'إجمالي المصروفات';

  @override
  String get netResult => 'النتيجة الصافية';

  @override
  String reportFor(String month) {
    return 'تقرير $month';
  }

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get csvExported => 'تم تصدير CSV';

  @override
  String get csvExportFailed => 'تعذر تصدير CSV';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'السمة';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get currencyLabel => 'العملة الأساسية';

  @override
  String get currencyHint =>
      'تُستخدم للإجماليات والميزانيات والحسابات الجديدة.';

  @override
  String get security => 'الأمان';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockHint => 'اطلب رمز جهازك أو نمطه أو بصمتك عند فتح روفن.';

  @override
  String get autoLock => 'القفل التلقائي';

  @override
  String get lockImmediately => 'فوراً';

  @override
  String get lockAfter30s => 'بعد 30 ثانية';

  @override
  String get lockAfter1m => 'بعد دقيقة';

  @override
  String get lockAfter5m => 'بعد 5 دقائق';

  @override
  String get lockNow => 'اقفل الآن';

  @override
  String get hideInRecents => 'إخفاء في مبدل التطبيقات';

  @override
  String get hideInRecentsHint =>
      'يخفي روفن في التطبيقات الحديثة ويمنع لقطات الشاشة. يمكنك أخذ نسخ احتياطية يدوياً.';

  @override
  String get deviceAuthUnavailable => 'قفل الجهاز غير متاح';

  @override
  String get deviceAuthUnavailableHint =>
      'اضبط رمزاً أو نمطاً أو قفلاً حيوياً على جهازك لاستخدام قفل التطبيق.';

  @override
  String get data => 'البيانات';

  @override
  String get manageAccounts => 'الحسابات';

  @override
  String get manageCategories => 'الفئات';

  @override
  String get manageBudgets => 'الميزانيات';

  @override
  String get manageRecurring => 'المتكررة';

  @override
  String get backupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupRestoreHint => 'صدّر نسخة خاصة من كل بياناتك أو استعد نسخة.';

  @override
  String get resetData => 'مسح كل البيانات';

  @override
  String get resetDataTitle => 'مسح كل البيانات؟';

  @override
  String get resetDataMessage =>
      'سيتم حذف كل حساب ومعاملة وميزانية وإعداد من هذا الجهاز. لا يمكن التراجع عن ذلك.';

  @override
  String get resetDataConfirm => 'مسح';

  @override
  String get dataReset => 'تم مسح كل البيانات';

  @override
  String get aboutRofin => 'حول روفن';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyHint =>
      'يعمل روفن دون اتصال بالكامل. تبقى بياناتك على هذا الجهاز ومشفرة. لا حساب، لا سحابة، لا تتبع.';

  @override
  String get madeWith => 'صُنع للوظيفة والعمل.';

  @override
  String get settingsSaved => 'تم الحفظ';

  @override
  String get onboardingTitle => 'مكان واحد خاص لكل أموالك';

  @override
  String get onboardingSubtitle =>
      'تابع راتبك وعملك دون خلط بينهما — ودون إرسال بياناتك إلى أي مكان.';

  @override
  String get onboardingFeaturePrivateTitle => 'يعمل دون اتصال';

  @override
  String get onboardingFeaturePrivateBody =>
      'كل شيء محفوظ على جهازك في قاعدة بيانات مشفرة. لا حاجة لحساب سحابي.';

  @override
  String get onboardingFeatureSpacesTitle => 'الشخصي والعمل معاً';

  @override
  String get onboardingFeatureSpacesBody =>
      'احتفظ بدفاتر منفصلة وحسابات مشتركة وتقارير واضحة لكل جانب من حياتك.';

  @override
  String get onboardingFeatureSecureTitle => 'محمي بقفل جهازك';

  @override
  String get onboardingFeatureSecureBody =>
      'افتح روفن ببصمتك أو وجهك أو رمز جهازك. لا شيء آخر لتتذكره.';

  @override
  String get onboardingPreferencesTitle => 'اجعله على ذوقك';

  @override
  String get onboardingPreferencesBody =>
      'اختر شكل روفن ولغته. يمكنك تغيير كل ذلك لاحقاً من الإعدادات.';

  @override
  String get onboardingLanguage => 'اللغة';

  @override
  String get onboardingCurrency => 'العملة';

  @override
  String get onboardingTheme => 'السمة';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get onboardingNote =>
      'لا تغادر بياناتك هذا الجهاز إلا إذا صدّرت نسخة احتياطية.';

  @override
  String get onboardingWelcome => 'مرحباً بك في روفن';

  @override
  String onboardingStepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingLockTitle => 'احمِ روفن';

  @override
  String get onboardingLockBody =>
      'استخدم قفل جهازك للحفاظ على خصوصية أموالك. يمكنك إيقاف ذلك لاحقاً.';

  @override
  String get enableAppLock => 'تفعيل قفل التطبيق';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get onboardingDone => 'كل شيء جاهز';

  @override
  String get lockTitle => 'روفن مقفل';

  @override
  String get lockSubtitle => 'افتح القفل برمز جهازك أو نمطه أو بصمتك.';

  @override
  String get unlock => 'فتح القفل';

  @override
  String get unlocking => 'جارٍ فتح القفل…';

  @override
  String get unlockPrompt => 'افتح قفل روفن للمتابعة';

  @override
  String get lockError => 'تعذر فتح القفل. حاول مرة أخرى.';

  @override
  String get lockUnavailable => 'قفل الجهاز غير متاح على هذا الجهاز.';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get appLocked => 'روفن مقفل';

  @override
  String get exportBackup => 'تصدير نسخة احتياطية';

  @override
  String get exportBackupHint =>
      'احفظ نسخة كاملة من بياناتك. احتفظ بها في مكان آمن.';

  @override
  String get importBackup => 'استيراد نسخة احتياطية';

  @override
  String get importBackupHint =>
      'استعد من ملف نسخة روفن. سيستبدل كل شيء على هذا الجهاز.';

  @override
  String get encryptBackup => 'تشفير بكلمة مرور';

  @override
  String get backupPassword => 'كلمة مرور النسخة';

  @override
  String get backupPasswordHint =>
      'استخدم 8 أحرف على الأقل. ستحتاجها للاستعادة.';

  @override
  String get backupPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get exportWithoutPassword => 'تصدير بدون كلمة مرور';

  @override
  String get backupExported => 'تم تصدير النسخة الاحتياطية';

  @override
  String get backupExportFailed => 'تعذر تصدير النسخة الاحتياطية';

  @override
  String get restoreTitle => 'استعادة النسخة الاحتياطية؟';

  @override
  String get restoreMessage =>
      'سيستبدل هذا كل الحسابات والمعاملات والميزانيات والإعدادات على هذا الجهاز.';

  @override
  String get restoreSuccess => 'تمت استعادة النسخة الاحتياطية';

  @override
  String get restoreFailed => 'تعذر استعادة النسخة الاحتياطية';

  @override
  String get invalidBackup => 'هذا الملف ليس نسخة روفن صالحة.';

  @override
  String get wrongPassword => 'كلمة مرور خاطئة أو نسخة تالفة.';

  @override
  String get passwordRequired => 'أدخل كلمة مرور النسخة الاحتياطية.';

  @override
  String get lastBackup => 'آخر نسخة احتياطية';

  @override
  String get neverBackedUp => 'أبداً';

  @override
  String get shareBackup => 'مشاركة النسخة';

  @override
  String get includeEverything =>
      'تشمل الحسابات والمعاملات والفئات والميزانيات والقواعد المتكررة والإعدادات.';

  @override
  String get backupWarning =>
      'النسخة غير مشفرة ما لم تضع كلمة مرور. احفظها بأمان.';

  @override
  String get export => 'تصدير';

  @override
  String get import => 'استيراد';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String savedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get chooseFile => 'اختر ملفاً';

  @override
  String get backupFileType => 'نسخة روفن';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get invalidAmount => 'أدخل مبلغاً صالحاً';

  @override
  String get amountMustBePositive => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String get selectDifferentAccounts => 'اختر حسابين مختلفين';

  @override
  String get nameRequired => 'أدخل اسماً بلغة واحدة على الأقل';

  @override
  String get deleteCannotUndo => 'لا يمكن التراجع عن ذلك.';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get monthlyOverview => 'ملخص الشهر';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get unknownCategory => 'بدون فئة';

  @override
  String get noSpace => 'بدون مساحة';

  @override
  String get allTransactions => 'كل المعاملات';

  @override
  String get summary => 'الملخص';

  @override
  String get last3Months => 'آخر 3 أشهر';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get month => 'الشهر';

  @override
  String get ownerDrawHint => 'سحب المالك تحويل وليس مصروفاً.';

  @override
  String get unlockWithDevice => 'افتح بقفل الجهاز';

  @override
  String get backToDashboard => 'العودة للرئيسية';
}
