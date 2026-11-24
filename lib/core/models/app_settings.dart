import 'enums.dart';
import '../utils/map_utils.dart';

class AppSettings {
  const AppSettings({
    this.locale = 'ar',
    this.theme = ThemePreference.system,
    this.currencyCode = 'EGP',
    this.activeSpaceId = 'all',
    this.onboardingComplete = false,
    this.lockEnabled = true,
    this.autoLockSeconds = 30,
    this.hideInRecents = true,
    this.lastBackupAt,
    this.schemaVersion = 1,
    this.seedVersion = 0,
  });

  final String locale;
  final ThemePreference theme;
  final String currencyCode;
  final String activeSpaceId;
  final bool onboardingComplete;
  final bool lockEnabled;
  final int autoLockSeconds;
  final bool hideInRecents;
  final DateTime? lastBackupAt;
  final int schemaVersion;
  final int seedVersion;

  bool get isArabic => locale == 'ar';

  Map<String, dynamic> toMap() => <String, dynamic>{
        'locale': locale,
        'theme': theme.code,
        'currencyCode': currencyCode,
        'activeSpaceId': activeSpaceId,
        'onboardingComplete': onboardingComplete,
        'lockEnabled': lockEnabled,
        'autoLockSeconds': autoLockSeconds,
        'hideInRecents': hideInRecents,
        'lastBackupAt': lastBackupAt?.toUtc().toIso8601String(),
        'schemaVersion': schemaVersion,
        'seedVersion': seedVersion,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      locale: readString(map, 'locale', 'ar') == 'en' ? 'en' : 'ar',
      theme: ThemePreference.fromCode(readString(map, 'theme')),
      currencyCode: readString(map, 'currencyCode', 'EGP'),
      activeSpaceId: readString(map, 'activeSpaceId', 'all'),
      onboardingComplete: readBool(map, 'onboardingComplete'),
      lockEnabled: readBool(map, 'lockEnabled', true),
      autoLockSeconds: readInt(map, 'autoLockSeconds', 30),
      hideInRecents: readBool(map, 'hideInRecents', true),
      lastBackupAt: readDateTime(map, 'lastBackupAt'),
      schemaVersion: readInt(map, 'schemaVersion', 1),
      seedVersion: readInt(map, 'seedVersion'),
    );
  }

  AppSettings copyWith({
    String? locale,
    ThemePreference? theme,
    String? currencyCode,
    String? activeSpaceId,
    bool? onboardingComplete,
    bool? lockEnabled,
    int? autoLockSeconds,
    bool? hideInRecents,
    DateTime? lastBackupAt,
    int? schemaVersion,
    int? seedVersion,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      currencyCode: currencyCode ?? this.currencyCode,
      activeSpaceId: activeSpaceId ?? this.activeSpaceId,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
      hideInRecents: hideInRecents ?? this.hideInRecents,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      seedVersion: seedVersion ?? this.seedVersion,
    );
  }
}
