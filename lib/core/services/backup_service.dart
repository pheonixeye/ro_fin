import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../database/app_database.dart';

enum BackupFailure {
  invalidFile,
  passwordRequired,
  wrongPassword,
}

class BackupException implements Exception {
  const BackupException(this.failure, [this.details]);

  final BackupFailure failure;
  final Object? details;

  @override
  String toString() => 'BackupException(${failure.name}, $details)';
}

/// Builds and restores the plain JSON payload used by Rofin backups.
///
/// A backup contains the raw Hive maps so it can be restored without any
/// code-generation or database-specific serialization.
abstract final class BackupService {
  static const String format = 'rofin-backup';
  static const int version = 1;
  static const int _iterations = 120000;
  static const int _keyBits = 256;

  static Map<String, dynamic> collectData(AppDatabase db) {
    return <String, dynamic>{
      'settings': _plain(db.settingsBox.toMap()),
      'spaces': _plain(db.spacesBox.toMap()),
      'accounts': _plain(db.accountsBox.toMap()),
      'categories': _plain(db.categoriesBox.toMap()),
      'transactions': _plain(db.transactionsBox.toMap()),
      'budgets': _plain(db.budgetsBox.toMap()),
      'recurring': _plain(db.recurringBox.toMap()),
    };
  }

  static Future<Uint8List> createBackup({
    required AppDatabase db,
    String? password,
  }) async {
    final data = collectData(db);
    final root = <String, dynamic>{
      'format': format,
      'version': version,
      'app': 'rofin',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    if (password == null || password.isEmpty) {
      root['encrypted'] = false;
      root['data'] = data;
    } else {
      final salt = _randomBytes(16);
      final key = await _deriveKey(password, salt);
      final cipher = AesGcm.with256bits();
      final box = await cipher.encrypt(
        utf8.encode(jsonEncode(data)),
        secretKey: key,
      );
      root.addAll(<String, dynamic>{
        'encrypted': true,
        'kdf': 'pbkdf2-sha256',
        'iterations': _iterations,
        'salt': base64Encode(salt),
        'nonce': base64Encode(box.nonce),
        'cipherText': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      });
    }

    final encoder = const JsonEncoder.withIndent('  ');
    return Uint8List.fromList(utf8.encode(encoder.convert(root)));
  }

  static Future<Map<String, dynamic>> readBackup(
    Uint8List bytes, {
    String? password,
  }) async {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (error) {
      throw BackupException(BackupFailure.invalidFile, error);
    }
    if (decoded is! Map) {
      throw const BackupException(BackupFailure.invalidFile);
    }
    final root = Map<String, dynamic>.from(decoded);
    if (root['format'] != format) {
      throw const BackupException(BackupFailure.invalidFile);
    }

    if (root['encrypted'] == true) {
      if (password == null || password.isEmpty) {
        throw const BackupException(BackupFailure.passwordRequired);
      }
      try {
        final salt = base64Decode(root['salt'] as String);
        final nonce = base64Decode(root['nonce'] as String);
        final cipherText = base64Decode(root['cipherText'] as String);
        final mac = base64Decode(root['mac'] as String);
        final key = await _deriveKey(password, salt);
        final clear = await AesGcm.with256bits().decrypt(
          SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
          secretKey: key,
        );
        final data = jsonDecode(utf8.decode(clear));
        if (data is! Map) {
          throw const BackupException(BackupFailure.invalidFile);
        }
        return Map<String, dynamic>.from(data);
      } on BackupException {
        rethrow;
      } on SecretBoxAuthenticationError catch (error) {
        throw BackupException(BackupFailure.wrongPassword, error);
      } catch (error) {
        throw BackupException(BackupFailure.wrongPassword, error);
      }
    }

    final data = root['data'];
    if (data is! Map) {
      throw const BackupException(BackupFailure.invalidFile);
    }
    return Map<String, dynamic>.from(data);
  }

  static Future<void> restore({
    required AppDatabase db,
    required Map<String, dynamic> data,
  }) async {
    final snapshot = collectData(db);
    try {
      await _replace(db, data);
    } catch (_) {
      await _replace(db, snapshot);
      rethrow;
    }
  }

  static Future<void> _replace(
    AppDatabase db,
    Map<String, dynamic> data,
  ) async {
    final boxes = <String, dynamic>{
      'settings': db.settingsBox,
      'spaces': db.spacesBox,
      'accounts': db.accountsBox,
      'categories': db.categoriesBox,
      'transactions': db.transactionsBox,
      'budgets': db.budgetsBox,
      'recurring': db.recurringBox,
    };

    for (final entry in boxes.entries) {
      final box = entry.value;
      await box.clear();
      final raw = data[entry.key];
      if (raw is Map) {
        final values = <String, dynamic>{
          for (final item in raw.entries)
            item.key.toString(): _plain(item.value),
        };
        if (values.isNotEmpty) {
          await box.putAll(values);
        }
      }
    }
  }

  static Future<SecretKey> _deriveKey(String password, List<int> salt) {
    final kdf = Pbkdf2.hmacSha256(iterations: _iterations, bits: _keyBits);
    return kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static Object? _plain(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString(): _plain(entry.value),
      };
    }
    if (value is Iterable) {
      return value.map(_plain).toList(growable: false);
    }
    return value.toString();
  }
}
