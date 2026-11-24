import 'dart:convert';
import 'dart:typed_data';

import '../models/account.dart';
import '../models/category.dart';
import '../models/space.dart';
import '../models/txn.dart';
import '../utils/money.dart';

abstract final class CsvService {
  static const List<String> _headers = <String>[
    'Date',
    'Type',
    'Space',
    'Category',
    'Account',
    'To account',
    'Amount',
    'Currency',
    'Note',
  ];

  static Uint8List buildTransactionsCsv({
    required Iterable<Txn> transactions,
    required Iterable<Account> accounts,
    required Iterable<Category> categories,
    required Iterable<Space> spaces,
  }) {
    final accountsById = <String, Account>{
      for (final account in accounts) account.id: account,
    };
    final categoriesById = <String, Category>{
      for (final category in categories) category.id: category,
    };
    final spacesById = <String, Space>{
      for (final space in spaces) space.id: space,
    };

    final rows = transactions.toList()
      ..sort((a, b) {
        final byDate = a.dateKey.compareTo(b.dateKey);
        return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
      });

    final buffer = StringBuffer('\uFEFF');
    buffer.writeln(_headers.map(_escape).join(','));

    for (final txn in rows) {
      final account = accountsById[txn.accountId];
      final toAccount =
          txn.toAccountId == null ? null : accountsById[txn.toAccountId];
      final category =
          txn.categoryId == null ? null : categoriesById[txn.categoryId];
      final space = spacesById[txn.spaceId];
      final currency = account?.currencyCode ?? 'EGP';
      final amount = amountToInput(txn.amountMinor, currency);

      buffer.writeln(
        <String>[
          txn.dateKey,
          txn.type.code,
          space?.nameEn ?? '',
          category?.nameEn ?? '',
          account?.nameEn ?? '',
          toAccount?.nameEn ?? '',
          amount,
          currency,
          txn.note,
        ].map(_escape).join(','),
      );
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  static String _escape(String value) {
    if (!value.contains(',') &&
        !value.contains('"') &&
        !value.contains('\n') &&
        !value.contains('\r')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}
