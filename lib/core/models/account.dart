import 'enums.dart';
import '../utils/map_utils.dart';

class Account {
  const Account({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.openingBalanceMinor,
    required this.currencyCode,
    required this.color,
    required this.iconKey,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final AccountType type;
  final int openingBalanceMinor;
  final String currencyCode;
  final int color;
  final String iconKey;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;

  String localizedName(String locale) {
    if (locale == 'ar') {
      return nameAr.isEmpty ? nameEn : nameAr;
    }
    return nameEn.isEmpty ? nameAr : nameEn;
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'type': type.code,
        'openingBalanceMinor': openingBalanceMinor,
        'currencyCode': currencyCode,
        'color': color,
        'iconKey': iconKey,
        'archived': archived,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'sortOrder': sortOrder,
      };

  factory Account.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return Account(
      id: readString(map, 'id'),
      nameAr: readString(map, 'nameAr'),
      nameEn: readString(map, 'nameEn'),
      type: AccountType.fromCode(readString(map, 'type')),
      openingBalanceMinor: readInt(map, 'openingBalanceMinor'),
      currencyCode: readString(map, 'currencyCode', 'EGP'),
      color: readInt(map, 'color'),
      iconKey: readString(map, 'iconKey', 'wallet'),
      archived: readBool(map, 'archived'),
      createdAt: readDateTime(map, 'createdAt') ?? now,
      updatedAt: readDateTime(map, 'updatedAt') ?? now,
      sortOrder: readInt(map, 'sortOrder'),
    );
  }

  Account copyWith({
    String? nameAr,
    String? nameEn,
    AccountType? type,
    int? openingBalanceMinor,
    String? currencyCode,
    int? color,
    String? iconKey,
    bool? archived,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Account(
      id: id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      type: type ?? this.type,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      color: color ?? this.color,
      iconKey: iconKey ?? this.iconKey,
      archived: archived ?? this.archived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
