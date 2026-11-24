String readString(Map<String, dynamic> map, String key, [String fallback = '']) {
  final value = map[key];
  return value is String ? value : fallback;
}

int readInt(Map<String, dynamic> map, String key, [int fallback = 0]) {
  final value = map[key];
  return value is num ? value.toInt() : fallback;
}

bool readBool(Map<String, dynamic> map, String key, [bool fallback = false]) {
  final value = map[key];
  return value is bool ? value : fallback;
}

double readDouble(Map<String, dynamic> map, String key, [double fallback = 0]) {
  final value = map[key];
  return value is num ? value.toDouble() : fallback;
}

DateTime? readDateTime(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  return null;
}

Map<String, dynamic> readMap(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<String> readStringList(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is List) {
    return value.whereType<String>().toList(growable: false);
  }
  return const <String>[];
}

Map<String, dynamic> normalizeMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}
