import 'package:hive_ce/hive.dart';

import '../models/app_settings.dart';
import '../utils/map_utils.dart';

class SettingsRepository {
  SettingsRepository(this.box);

  static const String settingsKey = 'app';

  final Box<dynamic> box;

  AppSettings load() {
    final raw = box.get(settingsKey);
    if (raw == null) {
      return const AppSettings();
    }
    return AppSettings.fromMap(normalizeMap(raw));
  }

  Future<void> save(AppSettings settings) {
    return box.put(settingsKey, settings.toMap());
  }

  Stream<AppSettings> watch() async* {
    yield load();
    await for (final _ in box.watch()) {
      yield load();
    }
  }
}
