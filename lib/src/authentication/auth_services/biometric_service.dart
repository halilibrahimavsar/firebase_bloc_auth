import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinCodeKey = 'pin_code';

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Biometric Check Error: $e');
      return false;
    }
  }

  /// Check if biometrics are available
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('Biometric Availability Error: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get Biometrics Error: $e');
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        // authMessages: const <AuthMessages>[
        //   AndroidAuthMessages(
        //     signInTitle: 'Biometric Authentication',
        //     cancelButton: 'Cancel',
        //     biometricHint: 'Verify identity',
        //   ),
        //   IOSAuthMessages(
        //     cancelButton: 'Cancel',
        //     goToSettingsButton: 'Settings',
        //     goToSettingsDescription:
        //         'Please set up your biometric authentication.',
        //     lockOut:
        //         'Biometric authentication is disabled. Please try again later.',
        //   ),
        // ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint('Authentication Error: $e');
      return false;
    }
  }

  /// Check if biometric is enabled for this user
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _biometricEnabledKey);
  }

  /// Save PIN code
  Future<void> savePinCode(String pin) async {
    await _secureStorage.write(key: _pinCodeKey, value: pin);
  }

  /// Get saved PIN code
  Future<String?> getPinCode() async {
    return await _secureStorage.read(key: _pinCodeKey);
  }

  /// Check if PIN code is set
  Future<bool> isPinCodeSet() async {
    final pin = await _secureStorage.read(key: _pinCodeKey);
    return pin != null && pin.isNotEmpty;
  }

  /// Verify PIN code
  Future<bool> verifyPinCode(String inputPin) async {
    final savedPin = await _secureStorage.read(key: _pinCodeKey);
    return savedPin == inputPin;
  }

  /// Delete PIN code
  Future<void> deletePinCode() async {
    await _secureStorage.delete(key: _pinCodeKey);
  }

  /// Clear all security settings
  Future<void> clearAllSecuritySettings() async {
    await _secureStorage.deleteAll();
  }
}
