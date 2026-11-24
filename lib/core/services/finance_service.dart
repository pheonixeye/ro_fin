import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/enums.dart';
import '../models/txn.dart';
import '../utils/date_utils.dart';

class MonthTotals {
  const MonthTotals({
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final int incomeMinor;
  final int expenseMinor;

  int get netMinor => incomeMinor - expenseMinor;
  bool get isEmpty => incomeMinor == 0 && expenseMinor == 0;
}

class AccountBalance {
  const AccountBalance({
    required this.account,
    required this.balanceMinor,
  });

  final Account account;
  final int balanceMinor;
}

class CategoryTotal {
  const CategoryTotal({
    required this.categoryId,
    required this.amountMinor,
    this.category,
  });

  final String categoryId;
  final int amountMinor;
  final Category? category;
}

class MonthPoint {
  const MonthPoint({
    required this.monthKey,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final String monthKey;
  final int incomeMinor;
  final int expenseMinor;

  int get netMinor => incomeMinor - expenseMinor;
}

class BudgetProgress {
  const BudgetProgress({
    required this.budget,
    required this.spentMinor,
    this.category,
  });

  final Budget budget;
  final int spentMinor;
  final Category? category;

  int get remainingMinor => budget.amountMinor - spentMinor;
  double get ratio {
    if (budget.amountMinor <= 0) {
      return 0;
    }
    return spentMinor / budget.amountMinor;
  }

  bool get isOver => spentMinor > budget.amountMinor;
}

abstract final class FinanceService {
  static bool isAllSpaces(String spaceId) => spaceId == 'all';

  static Iterable<Txn> forSpace(Iterable<Txn> transactions, String spaceId) {
    if (isAllSpaces(spaceId)) {
      return transactions;
    }
    return transactions.where((txn) => txn.spaceId == spaceId);
  }

  static Iterable<Txn> forMonth(Iterable<Txn> transactions, String monthKey) {
    return transactions.where((txn) => txn.dateKey.startsWith(monthKey));
  }

  static int accountBalance(Account account, Iterable<Txn> transactions) {
    var balance = account.openingBalanceMinor;
    for (final txn in transactions) {
      if (txn.type == TxnType.transfer) {
        if (txn.accountId == account.id) {
          balance -= txn.amountMinor;
        }
        if (txn.toAccountId == account.id) {
          balance += txn.amountMinor;
        }
        continue;
      }
      if (txn.accountId != account.id) {
        continue;
      }
      balance += txn.type == TxnType.income
          ? txn.amountMinor
          : -txn.amountMinor;
    }
    return balance;
  }

  static List<AccountBalance> accountBalances(
    Iterable<Account> accounts,
    Iterable<Txn> transactions, {
    bool includeArchived = false,
  }) {
    final list = accounts
        .where((account) => includeArchived || !account.archived)
        .map(
          (account) => AccountBalance(
            account: account,
            balanceMinor: accountBalance(account, transactions),
          ),
        )
        .toList()
      ..sort((a, b) => a.account.sortOrder.compareTo(b.account.sortOrder));
    return list;
  }

  static int totalBalance(
    Iterable<Account> accounts,
    Iterable<Txn> transactions,
  ) {
    var total = 0;
    for (final account in accounts) {
      if (account.archived) {
        continue;
      }
      total += accountBalance(account, transactions);
    }
    return total;
  }

  static MonthTotals monthTotals(
    Iterable<Txn> transactions, {
    required String spaceId,
    required String monthKey,
  }) {
    var income = 0;
    var expense = 0;
    for (final txn in forMonth(forSpace(transactions, spaceId), monthKey)) {
      if (txn.type == TxnType.income) {
        income += txn.amountMinor;
      } else if (txn.type == TxnType.expense) {
        expense += txn.amountMinor;
      }
    }
    return MonthTotals(incomeMinor: income, expenseMinor: expense);
  }

  static List<CategoryTotal> categoryTotals({
    required Iterable<Txn> transactions,
    required Iterable<Category> categories,
    required CategoryKind kind,
    required String spaceId,
    required String monthKey,
  }) {
    final byId = <String, int>{};
    for (final txn in forMonth(forSpace(transactions, spaceId), monthKey)) {
      if (txn.type != (kind == CategoryKind.income ? TxnType.income : TxnType.expense)) {
        continue;
      }
      final categoryId = txn.categoryId ?? 'uncategorized';
      byId[categoryId] = (byId[categoryId] ?? 0) + txn.amountMinor;
    }

    final byCategoryId = <String, Category>{
      for (final category in categories) category.id: category,
    };

    final totals = byId.entries
        .map(
          (entry) => CategoryTotal(
            categoryId: entry.key,
            amountMinor: entry.value,
            category: byCategoryId[entry.key],
          ),
        )
        .toList()
      ..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
    return totals;
  }

  static List<MonthPoint> monthlySeries({
    required Iterable<Txn> transactions,
    required String spaceId,
    required String endMonthKey,
    int count = 6,
  }) {
    final months = lastMonthKeys(endMonthKey, count);
    return months.map((month) {
      final totals = monthTotals(
        transactions,
        spaceId: spaceId,
        monthKey: month,
      );
      return MonthPoint(
        monthKey: month,
        incomeMinor: totals.incomeMinor,
        expenseMinor: totals.expenseMinor,
      );
    }).toList(growable: false);
  }

  static int budgetSpentMinor({
    required Budget budget,
    required Iterable<Txn> transactions,
  }) {
    var spent = 0;
    for (final txn in forMonth(forSpace(transactions, budget.spaceId), budget.monthKey)) {
      if (txn.type != TxnType.expense) {
        continue;
      }
      if (budget.categoryId != null && txn.categoryId != budget.categoryId) {
        continue;
      }
      spent += txn.amountMinor;
    }
    return spent;
  }

  static List<BudgetProgress> budgetProgress({
    required Iterable<Budget> budgets,
    required Iterable<Category> categories,
    required Iterable<Txn> transactions,
    required String spaceId,
    required String monthKey,
  }) {
    final categoryById = <String, Category>{
      for (final category in categories) category.id: category,
    };
    final list = budgets
        .where(
          (budget) =>
              budget.monthKey == monthKey &&
              (isAllSpaces(spaceId) || budget.spaceId == spaceId),
        )
        .map(
          (budget) => BudgetProgress(
            budget: budget,
            spentMinor: budgetSpentMinor(
              budget: budget,
              transactions: transactions,
            ),
            category: budget.categoryId == null
                ? null
                : categoryById[budget.categoryId],
          ),
        )
        .toList()
      ..sort((a, b) {
        if (a.budget.categoryId == null && b.budget.categoryId != null) {
          return -1;
        }
        if (a.budget.categoryId != null && b.budget.categoryId == null) {
          return 1;
        }
        return b.ratio.compareTo(a.ratio);
      });
    return list;
  }

  static int currentMonthExpense({
    required Iterable<Txn> transactions,
    required String spaceId,
  }) {
    return monthTotals(
      transactions,
      spaceId: spaceId,
      monthKey: monthKey(DateTime.now()),
    ).expenseMinor;
  }
}
