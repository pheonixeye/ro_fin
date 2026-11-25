import 'package:flutter_test/flutter_test.dart';
import 'package:rofin/core/models/account.dart';
import 'package:rofin/core/models/enums.dart';
import 'package:rofin/core/models/txn.dart';
import 'package:rofin/core/services/finance_service.dart';

Account _account({
  required String id,
  int openingBalanceMinor = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return Account(
    id: id,
    nameAr: id,
    nameEn: id,
    type: AccountType.cash,
    openingBalanceMinor: openingBalanceMinor,
    currencyCode: 'EGP',
    color: 0xFF000000,
    iconKey: 'wallet',
    createdAt: now,
    updatedAt: now,
  );
}

Txn _txn({
  required String id,
  required TxnType type,
  required int amountMinor,
  required String accountId,
  String? toAccountId,
  String spaceId = 'space_personal',
  String dateKey = '2026-11-10',
  String? categoryId,
}) {
  final now = DateTime(2026, 11, 10);
  return Txn(
    id: id,
    type: type,
    amountMinor: amountMinor,
    dateKey: dateKey,
    accountId: accountId,
    spaceId: spaceId,
    toAccountId: toAccountId,
    categoryId: categoryId,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('accountBalance', () {
    test('adds income and subtracts expenses', () {
      final cash = _account(id: 'cash', openingBalanceMinor: 10000);
      final transactions = <Txn>[
        _txn(
          id: 't1',
          type: TxnType.income,
          amountMinor: 50000,
          accountId: 'cash',
        ),
        _txn(
          id: 't2',
          type: TxnType.expense,
          amountMinor: 12500,
          accountId: 'cash',
        ),
        _txn(
          id: 't3',
          type: TxnType.expense,
          amountMinor: 999,
          accountId: 'other',
        ),
      ];

      expect(
        FinanceService.accountBalance(cash, transactions),
        10000 + 50000 - 12500,
      );
    });

    test('transfers move money between accounts', () {
      final cash = _account(id: 'cash', openingBalanceMinor: 100000);
      final bank = _account(id: 'bank');
      final transfer = _txn(
        id: 'transfer',
        type: TxnType.transfer,
        amountMinor: 25000,
        accountId: 'cash',
        toAccountId: 'bank',
      );

      expect(FinanceService.accountBalance(cash, <Txn>[transfer]), 75000);
      expect(FinanceService.accountBalance(bank, <Txn>[transfer]), 25000);
    });
  });

  group('monthTotals', () {
    test('ignores transfers and other spaces', () {
      final transactions = <Txn>[
        _txn(
          id: 'income',
          type: TxnType.income,
          amountMinor: 50000,
          accountId: 'cash',
        ),
        _txn(
          id: 'expense',
          type: TxnType.expense,
          amountMinor: 20000,
          accountId: 'cash',
        ),
        _txn(
          id: 'transfer',
          type: TxnType.transfer,
          amountMinor: 10000,
          accountId: 'cash',
          toAccountId: 'bank',
        ),
        _txn(
          id: 'business',
          type: TxnType.income,
          amountMinor: 90000,
          accountId: 'cash',
          spaceId: 'space_business',
        ),
        _txn(
          id: 'old',
          type: TxnType.income,
          amountMinor: 70000,
          accountId: 'cash',
          dateKey: '2026-10-01',
        ),
      ];

      final totals = FinanceService.monthTotals(
        transactions,
        spaceId: 'space_personal',
        monthKey: '2026-11',
      );

      expect(totals.incomeMinor, 50000);
      expect(totals.expenseMinor, 20000);
      expect(totals.netMinor, 30000);
      expect(totals.isEmpty, isFalse);
    });

    test('all spaces include both personal and business', () {
      final transactions = <Txn>[
        _txn(
          id: 'personal',
          type: TxnType.income,
          amountMinor: 50000,
          accountId: 'cash',
        ),
        _txn(
          id: 'business',
          type: TxnType.income,
          amountMinor: 90000,
          accountId: 'cash',
          spaceId: 'space_business',
        ),
      ];

      final totals = FinanceService.monthTotals(
        transactions,
        spaceId: 'all',
        monthKey: '2026-11',
      );

      expect(totals.incomeMinor, 140000);
      expect(totals.expenseMinor, 0);
    });
  });

  group('totalBalance', () {
    test('sums active accounts only', () {
      final accounts = <Account>[
        _account(id: 'cash', openingBalanceMinor: 10000),
        _account(id: 'bank', openingBalanceMinor: 25000),
        _account(id: 'archived', openingBalanceMinor: 999999)
            .copyWith(archived: true),
      ];
      final transactions = <Txn>[
        _txn(
          id: 'expense',
          type: TxnType.expense,
          amountMinor: 5000,
          accountId: 'cash',
        ),
      ];

      expect(FinanceService.totalBalance(accounts, transactions), 30000);
    });
  });
}
