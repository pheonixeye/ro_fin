import '../models/budget.dart';
import '../models/recurring_rule.dart';
import '../models/txn.dart';

/// How many records point at a space, account, or category.
class ReferenceCounts {
  const ReferenceCounts({
    this.transactions = 0,
    this.budgets = 0,
    this.recurring = 0,
  });

  final int transactions;
  final int budgets;
  final int recurring;

  int get total => transactions + budgets + recurring;

  bool get isUsed => total > 0;
}

/// Pure lookups used before archiving or deleting user data.
abstract final class ReferenceService {
  static ReferenceCounts forSpace({
    required String spaceId,
    required Iterable<Txn> transactions,
    required Iterable<Budget> budgets,
    required Iterable<RecurringRule> recurring,
  }) {
    return ReferenceCounts(
      transactions:
          transactions.where((txn) => txn.spaceId == spaceId).length,
      budgets: budgets.where((budget) => budget.spaceId == spaceId).length,
      recurring: recurring.where((rule) => rule.spaceId == spaceId).length,
    );
  }

  static ReferenceCounts forAccount({
    required String accountId,
    required Iterable<Txn> transactions,
    required Iterable<RecurringRule> recurring,
  }) {
    return ReferenceCounts(
      transactions: transactions
          .where(
            (txn) =>
                txn.accountId == accountId || txn.toAccountId == accountId,
          )
          .length,
      recurring: recurring
          .where(
            (rule) =>
                rule.accountId == accountId ||
                rule.toAccountId == accountId,
          )
          .length,
    );
  }

  static ReferenceCounts forCategory({
    required String categoryId,
    required Iterable<Txn> transactions,
    required Iterable<Budget> budgets,
    required Iterable<RecurringRule> recurring,
  }) {
    return ReferenceCounts(
      transactions:
          transactions.where((txn) => txn.categoryId == categoryId).length,
      budgets:
          budgets.where((budget) => budget.categoryId == categoryId).length,
      recurring:
          recurring.where((rule) => rule.categoryId == categoryId).length,
    );
  }
}
