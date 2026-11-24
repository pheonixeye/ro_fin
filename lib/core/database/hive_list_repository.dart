import 'package:hive_ce/hive.dart';

import '../utils/map_utils.dart';

typedef FromMap<T> = T Function(Map<String, dynamic> map);
typedef ToMap<T> = Map<String, dynamic> Function(T item);
typedef IdOf<T> = String Function(T item);

class HiveListRepository<T> {
  HiveListRepository({
    required this.box,
    required this.fromMap,
    required this.toMap,
    required this.idOf,
  });

  final Box<dynamic> box;
  final FromMap<T> fromMap;
  final ToMap<T> toMap;
  final IdOf<T> idOf;

  List<T> getAll() {
    final items = <T>[];
    for (final raw in box.values) {
      try {
        items.add(fromMap(normalizeMap(raw)));
      } catch (_) {
        // Skip malformed records instead of taking the whole list down.
      }
    }
    return items;
  }

  T? getById(String id) {
    final raw = box.get(id);
    if (raw == null) {
      return null;
    }
    try {
      return fromMap(normalizeMap(raw));
    } catch (_) {
      return null;
    }
  }

  Stream<List<T>> watchAll() async* {
    yield getAll();
    await for (final _ in box.watch()) {
      yield getAll();
    }
  }

  Future<void> put(T item) => box.put(idOf(item), toMap(item));

  Future<void> putAll(Iterable<T> items) async {
    final values = <String, Map<String, dynamic>>{
      for (final item in items) idOf(item): toMap(item),
    };
    await box.putAll(values);
  }

  Future<void> delete(String id) => box.delete(id);

  Future<void> clear() => box.clear();

  int get length => box.length;
}
