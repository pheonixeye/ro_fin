import 'package:flutter_test/flutter_test.dart';
import 'package:rofin/core/models/budget.dart';
import 'package:rofin/core/models/enums.dart';
import 'package:rofin/core/models/recurring_rule.dart';
import 'package:rofin/core/models/txn.dart';
import 'package:rofin/core/services/reference_service.dart';

void main() {
  final now = DateTime.utc(2026, 11, 1);

  Txn txn({
    required String id,
    String spaceId = 'space-1',
    String accountId = 'account-1',
    String? categoryId,
    String? toAccountId,
  }) {
    return Txn(
      id: id,
      type: toAccountId == null ? TxnType.expense : TxnType.transfer,
      amountMinor: 1000,
      dateKey: '2026-11-01',
      accountId: accountId,
      spaceId: spaceId,
      categoryId: categoryId,
      toAccountId: toAccountId,
      createdAt: now,
      updatedAt: now,
    );
  }

  Budget budget({
    required String id,
    String spaceId = 'space-1',
    String? categoryId,
  }) {
    return Budget(
      id: id,
      spaceId: spaceId,
      categoryId: categoryId,
      monthKey: '2026-11',
      amountMinor: 5000,
      createdAt: now,
      updatedAt: now,
    );
  }

  RecurringRule rule({
    required String id,
    String spaceId = 'space-1',
    String accountId = 'account-1',
    String? categoryId,
    String? toAccountId,
  }) {
    return RecurringRule(
      id: id,
      type: toAccountId == null ? TxnType.expense : TxnType.transfer,
      amountMinor: 1000,
      accountId: accountId,
      spaceId: spaceId,
      categoryId: categoryId,
      toAccountId: toAccountId,
      frequency: RecurringFrequency.monthly,
      dayOfMonth: 1,
      startDateKey: '2026-11-01',
      nextDueDateKey: '2026-12-01',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ReferenceService.forSpace', () {
    test('counts every kind of record that points at the space', () {
      final counts = ReferenceService.forSpace(
        spaceId: 'space-1',
        transactions: <Txn>[
          txn(id: 't1'),
          txn(id: 't2', spaceId: 'space-2'),
        ],
        budgets: <Budget>[
          budget(id: 'b1'),
          budget(id: 'b2', spaceId: 'space-2'),
        ],
        recurring: <RecurringRule>[
          rule(id: 'r1'),
          rule(id: 'r2', spaceId: 'space-2'),
        ],
      );

      expect(counts.transactions, 1);
      expect(counts.budgets, 1);
      expect(counts.recurring, 1);
      expect(counts.total, 3);
      expect(counts.isUsed, isTrue);
    });

    test('reports no usage for a clean space', () {
      final counts = ReferenceService.forSpace(
        spaceId: 'space-1',
        transactions: <Txn>[],
        budgets: <Budget>[],
        recurring: <RecurringRule>[],
      );

      expect(counts.isUsed, isFalse);
      expect(counts.total, 0);
    });
  });

  group('ReferenceService.forAccount', () {
    test('counts transfers into the account as usage', () {
      final counts = ReferenceService.forAccount(
        accountId: 'account-1',
        transactions: <Txn>[
          txn(id: 't1'),
          txn(id: 't2', accountId: 'account-2', toAccountId: 'account-1'),
          txn(id: 't3', accountId: 'account-2'),
        ],
        recurring: <RecurringRule>[
          rule(id: 'r1'),
          rule(id: 'r2', accountId: 'account-2', toAccountId: 'account-1'),
        ],
      );

      expect(counts.transactions, 2);
      expect(counts.recurring, 2);
      expect(counts.total, 4);
    });
  });

  group('ReferenceService.forCategory', () {
    test('counts transactions, budgets, and rules for the category', () {
      final counts = ReferenceService.forCategory(
        categoryId: 'category-1',
        transactions: <Txn>[
          txn(id: 't1', categoryId: 'category-1'),
          txn(id: 't2', categoryId: 'category-2'),
          txn(id: 't3'),
        ],
        budgets: <Budget>[
          budget(id: 'b1', categoryId: 'category-1'),
          budget(id: 'b2'),
        ],
        recurring: <RecurringRule>[
          rule(id: 'r1', categoryId: 'category-1'),
        ],
      );

      expect(counts.transactions, 1);
      expect(counts.budgets, 1);
      expect(counts.recurring, 1);
      expect(counts.isUsed, isTrue);
    });
  });
}
