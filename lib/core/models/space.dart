import 'enums.dart';
import '../utils/map_utils.dart';

class Space {
  const Space({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.kind,
    required this.color,
    required this.iconKey,
    this.isSystem = false,
    this.archived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final SpaceKind kind;
  final int color;
  final String iconKey;
  final bool isSystem;
  final bool archived;
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
        'kind': kind.code,
        'color': color,
        'iconKey': iconKey,
        'isSystem': isSystem,
        'archived': archived,
        'sortOrder': sortOrder,
      };

  factory Space.fromMap(Map<String, dynamic> map) {
    return Space(
      id: readString(map, 'id'),
      nameAr: readString(map, 'nameAr'),
      nameEn: readString(map, 'nameEn'),
      kind: SpaceKind.fromCode(readString(map, 'kind')),
      color: readInt(map, 'color'),
      iconKey: readString(map, 'iconKey', 'person'),
      isSystem: readBool(map, 'isSystem'),
      archived: readBool(map, 'archived'),
      sortOrder: readInt(map, 'sortOrder'),
    );
  }

  Space copyWith({
    String? nameAr,
    String? nameEn,
    bool? archived,
    int? sortOrder,
  }) {
    return Space(
      id: id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      kind: kind,
      color: color,
      iconKey: iconKey,
      isSystem: isSystem,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
