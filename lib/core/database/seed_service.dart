import '../models/account.dart';
import '../models/category.dart';
import '../models/enums.dart';
import '../models/space.dart';
import '../utils/date_utils.dart';

class SeedService {
  static const int currentSeedVersion = 1;

  static List<Space> defaultSpaces() => const <Space>[
        Space(
          id: 'space_personal',
          nameAr: 'شخصي',
          nameEn: 'Personal',
          kind: SpaceKind.personal,
          color: 0xFF0F766E,
          iconKey: 'person',
          isSystem: true,
          sortOrder: 0,
        ),
        Space(
          id: 'space_business',
          nameAr: 'العمل',
          nameEn: 'Business',
          kind: SpaceKind.business,
          color: 0xFFC8A24A,
          iconKey: 'store',
          isSystem: true,
          sortOrder: 1,
        ),
      ];

  static List<Account> defaultAccounts(String currencyCode) {
    final now = DateTime.now();
    return <Account>[
      Account(
        id: 'account_cash',
        nameAr: 'نقداً',
        nameEn: 'Cash',
        type: AccountType.cash,
        openingBalanceMinor: 0,
        currencyCode: currencyCode,
        color: 0xFF0F766E,
        iconKey: 'cash',
        createdAt: now,
        updatedAt: now,
        sortOrder: 0,
      ),
      Account(
        id: 'account_bank',
        nameAr: 'بنك',
        nameEn: 'Bank',
        type: AccountType.bank,
        openingBalanceMinor: 0,
        currencyCode: currencyCode,
        color: 0xFF3B6EA8,
        iconKey: 'bank',
        createdAt: now,
        updatedAt: now,
        sortOrder: 1,
      ),
    ];
  }

  static List<Category> defaultCategories() {
    var order = 0;
    Category category({
      required String id,
      required String ar,
      required String en,
      required CategoryKind kind,
      required CategoryScope scope,
      required String icon,
      required int color,
    }) {
      return Category(
        id: id,
        nameAr: ar,
        nameEn: en,
        kind: kind,
        scope: scope,
        iconKey: icon,
        color: color,
        isSystem: true,
        sortOrder: order++,
      );
    }

    return <Category>[
      // Personal expenses
      category(
        id: 'cat_groceries',
        ar: 'بقالة',
        en: 'Groceries',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'groceries',
        color: 0xFF2E8B57,
      ),
      category(
        id: 'cat_dining',
        ar: 'مطاعم',
        en: 'Dining',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'restaurant',
        color: 0xFFD97706,
      ),
      category(
        id: 'cat_transport',
        ar: 'مواصلات',
        en: 'Transport',
        kind: CategoryKind.expense,
        scope: CategoryScope.both,
        icon: 'car',
        color: 0xFF3B6EA8,
      ),
      category(
        id: 'cat_housing',
        ar: 'سكن',
        en: 'Housing',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'home',
        color: 0xFF7C3AED,
      ),
      category(
        id: 'cat_utilities',
        ar: 'فواتير',
        en: 'Utilities',
        kind: CategoryKind.expense,
        scope: CategoryScope.both,
        icon: 'bolt',
        color: 0xFFCA8A04,
      ),
      category(
        id: 'cat_health',
        ar: 'صحة',
        en: 'Health',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'health',
        color: 0xFFDC2626,
      ),
      category(
        id: 'cat_education',
        ar: 'تعليم',
        en: 'Education',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'school',
        color: 0xFF2563EB,
      ),
      category(
        id: 'cat_shopping',
        ar: 'تسوق',
        en: 'Shopping',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'shopping',
        color: 0xFFDB2777,
      ),
      category(
        id: 'cat_subscriptions',
        ar: 'اشتراكات',
        en: 'Subscriptions',
        kind: CategoryKind.expense,
        scope: CategoryScope.both,
        icon: 'subscriptions',
        color: 0xFF0891B2,
      ),
      category(
        id: 'cat_family',
        ar: 'عائلة',
        en: 'Family',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'family',
        color: 0xFF9333EA,
      ),
      category(
        id: 'cat_charity',
        ar: 'صدقة',
        en: 'Charity',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'charity',
        color: 0xFF059669,
      ),
      category(
        id: 'cat_other_personal_expense',
        ar: 'أخرى',
        en: 'Other',
        kind: CategoryKind.expense,
        scope: CategoryScope.personal,
        icon: 'more',
        color: 0xFF64748B,
      ),

      // Business expenses
      category(
        id: 'cat_supplies',
        ar: 'مستلزمات',
        en: 'Supplies',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'inventory',
        color: 0xFF0F766E,
      ),
      category(
        id: 'cat_inventory',
        ar: 'مخزون',
        en: 'Inventory',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'inventory',
        color: 0xFF115E59,
      ),
      category(
        id: 'cat_business_rent',
        ar: 'إيجار العمل',
        en: 'Business rent',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'store',
        color: 0xFF7C3AED,
      ),
      category(
        id: 'cat_business_utilities',
        ar: 'مرافق العمل',
        en: 'Business utilities',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'bolt',
        color: 0xFFCA8A04,
      ),
      category(
        id: 'cat_salaries',
        ar: 'رواتب',
        en: 'Salaries',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'people',
        color: 0xFF2563EB,
      ),
      category(
        id: 'cat_marketing',
        ar: 'تسويق',
        en: 'Marketing',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'campaign',
        color: 0xFFDB2777,
      ),
      category(
        id: 'cat_shipping',
        ar: 'نقل وشحن',
        en: 'Shipping',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'truck',
        color: 0xFF0891B2,
      ),
      category(
        id: 'cat_equipment',
        ar: 'معدات',
        en: 'Equipment',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'tools',
        color: 0xFF475569,
      ),
      category(
        id: 'cat_maintenance',
        ar: 'صيانة',
        en: 'Maintenance',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'build',
        color: 0xFFB45309,
      ),
      category(
        id: 'cat_taxes',
        ar: 'ضرائب',
        en: 'Taxes',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'tax',
        color: 0xFF991B1B,
      ),
      category(
        id: 'cat_fees',
        ar: 'رسوم',
        en: 'Fees',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'receipt',
        color: 0xFF64748B,
      ),
      category(
        id: 'cat_other_business_expense',
        ar: 'أخرى',
        en: 'Other',
        kind: CategoryKind.expense,
        scope: CategoryScope.business,
        icon: 'more',
        color: 0xFF64748B,
      ),

      // Personal income
      category(
        id: 'cat_salary',
        ar: 'راتب',
        en: 'Salary',
        kind: CategoryKind.income,
        scope: CategoryScope.personal,
        icon: 'salary',
        color: 0xFF15803D,
      ),
      category(
        id: 'cat_freelance',
        ar: 'عمل حر',
        en: 'Freelance',
        kind: CategoryKind.income,
        scope: CategoryScope.personal,
        icon: 'work',
        color: 0xFF0F766E,
      ),
      category(
        id: 'cat_gifts',
        ar: 'هدايا',
        en: 'Gifts',
        kind: CategoryKind.income,
        scope: CategoryScope.personal,
        icon: 'gift',
        color: 0xFFDB2777,
      ),
      category(
        id: 'cat_investment',
        ar: 'استثمار',
        en: 'Investment',
        kind: CategoryKind.income,
        scope: CategoryScope.personal,
        icon: 'chart',
        color: 0xFF2563EB,
      ),
      category(
        id: 'cat_other_personal_income',
        ar: 'أخرى',
        en: 'Other',
        kind: CategoryKind.income,
        scope: CategoryScope.personal,
        icon: 'more',
        color: 0xFF64748B,
      ),

      // Business income
      category(
        id: 'cat_sales',
        ar: 'مبيعات',
        en: 'Sales',
        kind: CategoryKind.income,
        scope: CategoryScope.business,
        icon: 'store',
        color: 0xFF15803D,
      ),
      category(
        id: 'cat_services',
        ar: 'خدمات',
        en: 'Services',
        kind: CategoryKind.income,
        scope: CategoryScope.business,
        icon: 'work',
        color: 0xFF0F766E,
      ),
      category(
        id: 'cat_online_sales',
        ar: 'مبيعات أونلاين',
        en: 'Online sales',
        kind: CategoryKind.income,
        scope: CategoryScope.business,
        icon: 'online',
        color: 0xFF2563EB,
      ),
      category(
        id: 'cat_other_business_income',
        ar: 'أخرى',
        en: 'Other',
        kind: CategoryKind.income,
        scope: CategoryScope.business,
        icon: 'more',
        color: 0xFF64748B,
      ),
    ];
  }

  static Future<void> ensureSeeded({
    required dynamic spacesBox,
    required dynamic accountsBox,
    required dynamic categoriesBox,
    required String currencyCode,
  }) async {
    if (spacesBox.isEmpty) {
      await spacesBox.putAll(<String, Map<String, dynamic>>{
        for (final space in defaultSpaces()) space.id: space.toMap(),
      });
    }
    if (accountsBox.isEmpty) {
      await accountsBox.putAll(<String, Map<String, dynamic>>{
        for (final account in defaultAccounts(currencyCode))
          account.id: account.toMap(),
      });
    }
    if (categoriesBox.isEmpty) {
      await categoriesBox.putAll(<String, Map<String, dynamic>>{
        for (final category in defaultCategories())
          category.id: category.toMap(),
      });
    }
  }

  static String todayKey() => dateKey(DateTime.now());
}
