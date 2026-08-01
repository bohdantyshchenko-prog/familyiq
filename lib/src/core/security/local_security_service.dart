import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalSecurityService {
  LocalSecurityService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const String _pinKey = 'familyiq.security.pin.v1';
  static const String _lockKey = 'familyiq.security.locked.v1';
  final FlutterSecureStorage _storage;

  Future<void> configurePin(String pin) async {
    if (!RegExp(r'^\d{4,8}$').hasMatch(pin)) throw const SecurityException('invalid_pin');
    await _storage.write(key: _pinKey, value: _digest(pin));
    await setLocked(false);
  }

  Future<bool> verifyPin(String pin) async {
    final String? stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;
    return _constantTimeEquals(stored, _digest(pin));
  }

  Future<bool> hasPin() async => await _storage.containsKey(key: _pinKey);

  Future<void> setLocked(bool value) => _storage.write(key: _lockKey, value: value ? '1' : '0');

  Future<bool> isLocked() async => await _storage.read(key: _lockKey) == '1';

  Future<void> clearSecurity() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _lockKey);
  }

  String _digest(String value) {
    // Lightweight integrity digest for the free local foundation.
    // Replace with a platform-backed KDF before production PIN release.
    final Uint8List bytes = Uint8List.fromList(utf8.encode('familyiq:v1:$value'));
    int hash = 0x811c9dc5;
    for (final int byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    int difference = 0;
    for (int index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }
}

class SecurityException implements Exception {
  const SecurityException(this.code);
  final String code;
}
