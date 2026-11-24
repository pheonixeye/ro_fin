import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Keeps the Hive encryption key outside of the database itself.
///
/// On Android and iOS the key lives in the platform keystore. On desktop
/// previews where a keyring is unavailable, debug builds fall back to a file
/// so the UI can still be developed. Release mobile builds never fall back.
class SecureKeyStore {
  SecureKeyStore({
    FlutterSecureStorage? storage,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                resetOnError: false,
                migrateOnAlgorithmChange: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const String _keyName = 'rofin_hive_key_v1';
  static const String _fallbackFileName = '.rofin_hive_key';

  final FlutterSecureStorage _storage;

  Future<Uint8List> loadOrCreate() async {
    final existing = await _read();
    if (existing != null) {
      final decoded = base64Decode(existing);
      if (decoded.length == 32) {
        return Uint8List.fromList(decoded);
      }
      throw StateError('Rofin encryption key has an invalid length.');
    }

    final generated = Uint8List.fromList(Hive.generateSecureKey());
    await _write(base64Encode(generated));
    return generated;
  }

  Future<String?> _read() async {
    try {
      return await _storage.read(key: _keyName);
    } catch (error, stack) {
      if (_canUseDesktopFallback) {
        debugPrint('Secure storage unavailable, using debug key file: $error');
        debugPrintStack(stackTrace: stack);
        return _readFallback();
      }
      rethrow;
    }
  }

  Future<void> _write(String value) async {
    try {
      await _storage.write(key: _keyName, value: value);
    } catch (error) {
      if (_canUseDesktopFallback) {
        debugPrint('Secure storage unavailable, writing debug key file: $error');
        await _writeFallback(value);
        return;
      }
      rethrow;
    }
  }

  bool get _canUseDesktopFallback {
    if (!kDebugMode || kIsWeb) {
      return false;
    }
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  Future<File> _fallbackFile() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return File(p.join(directory.path, _fallbackFileName));
  }

  Future<String?> _readFallback() async {
    final file = await _fallbackFile();
    if (!await file.exists()) {
      return null;
    }
    return (await file.readAsString()).trim();
  }

  Future<void> _writeFallback(String value) async {
    final file = await _fallbackFile();
    await file.writeAsString(value, flush: true);
  }
}
