import 'enums.dart';
import '../utils/map_utils.dart';

class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.accountId,
    required this.spaceId,
    this.categoryId,
    this.toAccountId,
    this.note = '',
    required this.frequency,
    this.interval = 1,
    required this.dayOfMonth,
    required this.startDateKey,
    required this.nextDueDateKey,
    this.endDateKey,
    this.isActive = true,
    this.autoPost = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TxnType type;
  final int amountMinor;
  final String accountId;
  final String spaceId;
  final String? categoryId;
  final String? toAccountId;
  final String note;
  final RecurringFrequency frequency;
  final int interval;
  final int dayOfMonth;
  final String startDateKey;
  final String nextDueDateKey;
  final String? endDateKey;
  final bool isActive;
  final bool autoPost;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'type': type.code,
        'amountMinor': amountMinor,
        'accountId': accountId,
        'spaceId': spaceId,
        'categoryId': categoryId,
        'toAccountId': toAccountId,
        'note': note,
        'frequency': frequency.code,
        'interval': interval,
        'dayOfMonth': dayOfMonth,
        'startDateKey': startDateKey,
        'nextDueDateKey': nextDueDateKey,
        'endDateKey': endDateKey,
        'isActive': isActive,
        'autoPost': autoPost,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory RecurringRule.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    final category = readString(map, 'categoryId');
    final toAccount = readString(map, 'toAccountId');
    final endDate = readString(map, 'endDateKey');
    return RecurringRule(
      id: readString(map, 'id'),
      type: TxnType.fromCode(readString(map, 'type')),
      amountMinor: readInt(map, 'amountMinor'),
      accountId: readString(map, 'accountId'),
      spaceId: readString(map, 'spaceId'),
      categoryId: category.isEmpty ? null : category,
      toAccountId: toAccount.isEmpty ? null : toAccount,
      note: readString(map, 'note'),
      frequency: RecurringFrequency.fromCode(readString(map, 'frequency')),
      interval: readInt(map, 'interval', 1).clamp(1, 365),
      dayOfMonth: readInt(map, 'dayOfMonth', 1).clamp(1, 31),
      startDateKey: readString(map, 'startDateKey'),
      nextDueDateKey: readString(map, 'nextDueDateKey'),
      endDateKey: endDate.isEmpty ? null : endDate,
      isActive: readBool(map, 'isActive', true),
      autoPost: readBool(map, 'autoPost', true),
      createdAt: readDateTime(map, 'createdAt') ?? now,
      updatedAt: readDateTime(map, 'updatedAt') ?? now,
    );
  }

  RecurringRule copyWith({
    TxnType? type,
    int? amountMinor,
    String? accountId,
    String? spaceId,
    String? categoryId,
    String? toAccountId,
    String? note,
    RecurringFrequency? frequency,
    int? interval,
    int? dayOfMonth,
    String? startDateKey,
    String? nextDueDateKey,
    String? endDateKey,
    bool? isActive,
    bool? autoPost,
    DateTime? updatedAt,
  }) {
    return RecurringRule(
      id: id,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      accountId: accountId ?? this.accountId,
      spaceId: spaceId ?? this.spaceId,
      categoryId: categoryId ?? this.categoryId,
      toAccountId: toAccountId ?? this.toAccountId,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDateKey: startDateKey ?? this.startDateKey,
      nextDueDateKey: nextDueDateKey ?? this.nextDueDateKey,
      endDateKey: endDateKey ?? this.endDateKey,
      isActive: isActive ?? this.isActive,
      autoPost: autoPost ?? this.autoPost,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
