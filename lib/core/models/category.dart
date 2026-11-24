import 'enums.dart';
import '../utils/map_utils.dart';

class Category {
  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.kind,
    required this.scope,
    required this.iconKey,
    required this.color,
    this.isSystem = false,
    this.archived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final CategoryKind kind;
  final CategoryScope scope;
  final String iconKey;
  final int color;
  final bool isSystem;
  final bool archived;
  final int sortOrder;

  String localizedName(String locale) {
    if (locale == 'ar') {
      return nameAr.isEmpty ? nameEn : nameAr;
    }
    return nameEn.isEmpty ? nameAr : nameEn;
  }

  bool appliesTo(SpaceKind spaceKind) => scope.appliesTo(spaceKind);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'kind': kind.code,
        'scope': scope.code,
        'iconKey': iconKey,
        'color': color,
        'isSystem': isSystem,
        'archived': archived,
        'sortOrder': sortOrder,
      };

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: readString(map, 'id'),
      nameAr: readString(map, 'nameAr'),
      nameEn: readString(map, 'nameEn'),
      kind: CategoryKind.fromCode(readString(map, 'kind')),
      scope: CategoryScope.fromCode(readString(map, 'scope')),
      iconKey: readString(map, 'iconKey', 'more'),
      color: readInt(map, 'color'),
      isSystem: readBool(map, 'isSystem'),
      archived: readBool(map, 'archived'),
      sortOrder: readInt(map, 'sortOrder'),
    );
  }

  Category copyWith({
    String? nameAr,
    String? nameEn,
    CategoryKind? kind,
    CategoryScope? scope,
    String? iconKey,
    int? color,
    bool? archived,
    int? sortOrder,
  }) {
    return Category(
      id: id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      kind: kind ?? this.kind,
      scope: scope ?? this.scope,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      isSystem: isSystem,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
