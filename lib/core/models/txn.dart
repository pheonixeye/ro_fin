import 'enums.dart';
import '../utils/map_utils.dart';

class Txn {
  const Txn({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.dateKey,
    required this.accountId,
    required this.spaceId,
    this.categoryId,
    this.toAccountId,
    this.note = '',
    this.recurringId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TxnType type;
  final int amountMinor;
  final String dateKey;
  final String accountId;
  final String? categoryId;
  final String spaceId;
  final String? toAccountId;
  final String note;
  final String? recurringId;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTransfer => type == TxnType.transfer;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'type': type.code,
        'amountMinor': amountMinor,
        'dateKey': dateKey,
        'accountId': accountId,
        'categoryId': categoryId,
        'spaceId': spaceId,
        'toAccountId': toAccountId,
        'note': note,
        'recurringId': recurringId,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory Txn.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    final category = readString(map, 'categoryId');
    final toAccount = readString(map, 'toAccountId');
    final recurring = readString(map, 'recurringId');
    return Txn(
      id: readString(map, 'id'),
      type: TxnType.fromCode(readString(map, 'type')),
      amountMinor: readInt(map, 'amountMinor'),
      dateKey: readString(map, 'dateKey'),
      accountId: readString(map, 'accountId'),
      categoryId: category.isEmpty ? null : category,
      spaceId: readString(map, 'spaceId'),
      toAccountId: toAccount.isEmpty ? null : toAccount,
      note: readString(map, 'note'),
      recurringId: recurring.isEmpty ? null : recurring,
      createdAt: readDateTime(map, 'createdAt') ?? now,
      updatedAt: readDateTime(map, 'updatedAt') ?? now,
    );
  }

  Txn copyWith({
    TxnType? type,
    int? amountMinor,
    String? dateKey,
    String? accountId,
    String? categoryId,
    String? spaceId,
    String? toAccountId,
    String? note,
    String? recurringId,
    DateTime? updatedAt,
  }) {
    return Txn(
      id: id,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      dateKey: dateKey ?? this.dateKey,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      spaceId: spaceId ?? this.spaceId,
      toAccountId: toAccountId ?? this.toAccountId,
      note: note ?? this.note,
      recurringId: recurringId ?? this.recurringId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
