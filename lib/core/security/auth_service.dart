import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

enum AuthOutcome {
  success,
  canceled,
  unavailable,
  lockedOut,
  failed,
}

class AuthService {
  AuthService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  bool get isPlatformSupported {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isMacOS;
  }

  /// Linux previews cannot use local_auth. Debug builds are allowed to open
  /// without a device prompt so the rest of the app can be developed.
  bool get isPreviewBypass => kDebugMode && !isPlatformSupported;

  Future<bool> canUseDeviceAuth() async {
    if (!isPlatformSupported) {
      return false;
    }
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<AuthOutcome> authenticate(String reason) async {
    if (!isPlatformSupported) {
      return AuthOutcome.unavailable;
    }
    try {
      final success = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
      return success ? AuthOutcome.success : AuthOutcome.canceled;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.authInProgress ||
        LocalAuthExceptionCode.userRequestedFallback =>
          AuthOutcome.canceled,
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
        LocalAuthExceptionCode.uiUnavailable =>
          AuthOutcome.unavailable,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          AuthOutcome.lockedOut,
        _ => AuthOutcome.failed,
      };
    } catch (_) {
      return AuthOutcome.failed;
    }
  }
}
