import 'package:uuid/uuid.dart';

import '../database/hive_list_repository.dart';
import '../models/enums.dart';
import '../models/recurring_rule.dart';
import '../models/txn.dart';
import '../utils/date_utils.dart';

/// Posts due recurring transactions and advances each rule's next due date.
///
/// Runs at startup and whenever the recurring screen refreshes. Each posted
/// transaction is saved before the rule is advanced, so an interrupted run
/// cannot silently skip a payment.
class RecurringService {
  const RecurringService();

  static const Uuid _uuid = Uuid();

  Future<int> runDue({
    required HiveListRepository<RecurringRule> rules,
    required HiveListRepository<Txn> transactions,
    DateTime? today,
  }) async {    final now = today ?? DateTime.now();
    final todayKey = dateKey(now);
    var postedCount = 0;

    for (final rule in rules.getAll()) {
      if (!rule.isActive || !rule.autoPost) {
        continue;
      }

      final startKey = rule.nextDueDateKey.isEmpty
          ? rule.startDateKey
          : rule.nextDueDateKey;
      if (startKey.isEmpty) {
        continue;
      }

      var due = parseDateKey(startKey);
      var changed = false;
      var guard = 0;

      while (dateKey(due).compareTo(todayKey) <= 0 && guard < 60) {
        guard++;
        final dueKey = dateKey(due);

        if (rule.endDateKey != null && dueKey.compareTo(rule.endDateKey!) > 0) {
          break;
        }
        if (rule.accountId.isEmpty ||
            (rule.type == TxnType.transfer && (rule.toAccountId ?? '').isEmpty)) {
          break;
        }

        final nowStamp = DateTime.now();
        final transaction = Txn(
          id: _uuid.v4(),
          type: rule.type,
          amountMinor: rule.amountMinor,
          dateKey: dueKey,
          accountId: rule.accountId,
          categoryId: rule.categoryId,
          spaceId: rule.spaceId,
          toAccountId: rule.toAccountId,
          note: rule.note,
          recurringId: rule.id,
          createdAt: nowStamp,
          updatedAt: nowStamp,
        );
        await transactions.put(transaction);
        postedCount++;
        due = _nextDate(rule, due);
        changed = true;
      }

      if (changed) {
        final nextKey = dateKey(due);
        final expired = rule.endDateKey != null &&
            nextKey.compareTo(rule.endDateKey!) > 0;
        await rules.put(
          rule.copyWith(
            nextDueDateKey: nextKey,
            isActive: expired ? false : rule.isActive,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }

    return postedCount;
  }

  /// Posts one transaction for [rule] today and advances its next due date.
  ///
  /// This is the manual path for rules with automatic posting turned off.
  Future<Txn?> postNow({
    required RecurringRule rule,
    required HiveListRepository<RecurringRule> rules,
    required HiveListRepository<Txn> transactions,
    DateTime? today,
  }) async {
    if (rule.accountId.isEmpty ||
        (rule.type == TxnType.transfer && (rule.toAccountId ?? '').isEmpty)) {
      return null;
    }

    final now = today ?? DateTime.now();
    final todayKey = dateKey(now);
    final stamp = DateTime.now();
    final transaction = Txn(
      id: _uuid.v4(),
      type: rule.type,
      amountMinor: rule.amountMinor,
      dateKey: todayKey,
      accountId: rule.accountId,
      categoryId: rule.categoryId,
      spaceId: rule.spaceId,
      toAccountId: rule.toAccountId,
      note: rule.note,
      recurringId: rule.id,
      createdAt: stamp,
      updatedAt: stamp,
    );
    await transactions.put(transaction);

    var due = parseDateKey(
      rule.nextDueDateKey.isEmpty ? rule.startDateKey : rule.nextDueDateKey,
    );
    var guard = 0;
    do {
      due = _nextDate(rule, due);
      guard++;
    } while (dateKey(due).compareTo(todayKey) <= 0 && guard < 60);

    final nextKey = dateKey(due);
    final expired =
        rule.endDateKey != null && nextKey.compareTo(rule.endDateKey!) > 0;
    await rules.put(
      rule.copyWith(
        nextDueDateKey: nextKey,
        isActive: expired ? false : rule.isActive,
        updatedAt: DateTime.now(),
      ),
    );
    return transaction;
  }

  DateTime _nextDate(RecurringRule rule, DateTime due) {
    final interval = rule.interval < 1 ? 1 : rule.interval;
    return switch (rule.frequency) {
      RecurringFrequency.weekly => addDays(due, 7 * interval),
      RecurringFrequency.monthly => addMonthsClamped(
          due,
          interval,
          preferredDay: rule.dayOfMonth,
        ),
      RecurringFrequency.yearly => _addYears(due, interval, rule.dayOfMonth),
    };
  }

  DateTime _addYears(DateTime date, int years, int preferredDay) {
    final targetYear = date.year + years;
    final targetMonth = date.month;
    final maxDay = daysInMonth(targetYear, targetMonth);
    return DateTime(
      targetYear,
      targetMonth,
      preferredDay.clamp(1, maxDay),
    );
  }
}
