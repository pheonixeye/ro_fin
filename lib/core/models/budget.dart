import '../utils/map_utils.dart';

class Budget {
  const Budget({
    required this.id,
    required this.spaceId,
    required this.monthKey,
    required this.amountMinor,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String spaceId;
  final String? categoryId;
  final String monthKey;
  final int amountMinor;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOverall => categoryId == null;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'spaceId': spaceId,
        'categoryId': categoryId,
        'monthKey': monthKey,
        'amountMinor': amountMinor,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory Budget.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    final category = readString(map, 'categoryId');
    return Budget(
      id: readString(map, 'id'),
      spaceId: readString(map, 'spaceId'),
      categoryId: category.isEmpty ? null : category,
      monthKey: readString(map, 'monthKey'),
      amountMinor: readInt(map, 'amountMinor'),
      createdAt: readDateTime(map, 'createdAt') ?? now,
      updatedAt: readDateTime(map, 'updatedAt') ?? now,
    );
  }

  Budget copyWith({
    String? spaceId,
    String? categoryId,
    String? monthKey,
    int? amountMinor,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id,
      spaceId: spaceId ?? this.spaceId,
      categoryId: categoryId ?? this.categoryId,
      monthKey: monthKey ?? this.monthKey,
      amountMinor: amountMinor ?? this.amountMinor,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
