import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Applies Android's FLAG_SECURE so Rofin is hidden from the app switcher and
/// cannot be captured in screenshots. Other platforms are a no-op.
abstract final class SecureScreenService {
  static const MethodChannel _channel = MethodChannel('rofin/security');

  static Future<void> apply({required bool enabled}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('setSecureFlag', <String, dynamic>{
        'enabled': enabled,
      });
    } on MissingPluginException {
      // Widget tests and previews do not register the Android channel.
    } on PlatformException catch (error) {
      debugPrint('Could not update secure screen flag: $error');
    }
  }
}
