import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class FamilyStore extends ChangeNotifier {
  FamilyStore({
    SharedPreferences? preferences,
    FlutterSecureStorage? secureStorage,
  })  : _providedPreferences = preferences,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'familyiq.session';
  static const String _userKey = 'familyiq.user';
  static const String _familyKey = 'familyiq.family';
  static const String _emailKey = 'familyiq.email';
  static const String _userIdKey = 'familyiq.user_id';
  static const String _familyIdKey = 'familyiq.family_id';
  static const String _memberSinceKey = 'familyiq.member_since';
  static const String _pinKey = 'familyiq.local_pin';

  final SharedPreferences? _providedPreferences;
  final FlutterSecureStorage _secureStorage;
  final Uuid _uuid = const Uuid();

  bool initialized = false;
  bool signedIn = false;
  bool hasAccount = false;
  bool pinConfigured = false;
  String userName = '';
  String familyName = '';
  String email = '';
  String userId = '';
  String familyId = '';
  DateTime? memberSince;

  Future<SharedPreferences> get _preferences async =>
      _providedPreferences ?? SharedPreferences.getInstance();

  String get initials {
    final List<String> parts = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'FI';
    return parts.take(2).map((String value) => value.characters.first.toUpperCase()).join();
  }

  Future<void> initialize() async {
    final SharedPreferences prefs = await _preferences;
    userName = prefs.getString(_userKey)?.trim() ?? '';
    familyName = prefs.getString(_familyKey)?.trim() ?? '';
    email = prefs.getString(_emailKey)?.trim().toLowerCase() ?? '';
    userId = prefs.getString(_userIdKey)?.trim() ?? '';
    familyId = prefs.getString(_familyIdKey)?.trim() ?? '';
    memberSince = _parseDate(prefs.getString(_memberSinceKey));

    final bool legacySession = prefs.getBool(_sessionKey) ?? false;
    final bool hasLegacyProfile = userName.isNotEmpty || familyName.isNotEmpty || legacySession;

    if (hasLegacyProfile && (userId.isEmpty || familyId.isEmpty)) {
      userName = userName.isEmpty ? 'Пользователь' : userName;
      familyName = familyName.isEmpty ? 'Моя семья' : familyName;
      userId = userId.isEmpty ? _uuid.v4() : userId;
      // Old local records used the visible family name as their familyId.
      // Reusing it here keeps existing data visible after the account migration.
      familyId = familyId.isEmpty ? familyName : familyId;
      memberSince ??= DateTime.now().toUtc();
      await _persistProfile(prefs);
    }

    hasAccount = userId.isNotEmpty && familyId.isNotEmpty;
    signedIn = hasAccount && legacySession;
    try {
      pinConfigured = (await _secureStorage.read(key: _pinKey))?.isNotEmpty ?? false;
    } catch (_) {
      pinConfigured = false;
    }
    initialized = true;
    notifyListeners();
  }

  Future<String?> createAccount({
    required String name,
    required String family,
    required String emailAddress,
    required String pin,
  }) async {
    final String normalizedName = name.trim();
    final String normalizedFamily = family.trim();
    final String normalizedEmail = emailAddress.trim().toLowerCase();
    final String? validationError = _validateCredentials(
      name: normalizedName,
      family: normalizedFamily,
      emailAddress: normalizedEmail,
      pin: pin,
      requireProfile: true,
    );
    if (validationError != null) return validationError;

    try {
      await _secureStorage.write(key: _pinKey, value: pin);
    } catch (_) {
      return 'secure_storage_failed';
    }

    userName = normalizedName;
    familyName = normalizedFamily;
    email = normalizedEmail;
    userId = _uuid.v4();
    familyId = _uuid.v4();
    memberSince = DateTime.now().toUtc();

    final SharedPreferences prefs = await _preferences;
    await _persistProfile(prefs);
    await prefs.setBool(_sessionKey, true);
    hasAccount = true;
    pinConfigured = true;
    signedIn = true;
    notifyListeners();
    return null;
  }

  Future<String?> signIn({required String emailAddress, required String pin}) async {
    if (!hasAccount) return 'account_not_found';
    final String normalizedEmail = emailAddress.trim().toLowerCase();
    if (normalizedEmail != email || !_isValidPin(pin)) return 'invalid_credentials';

    String? storedPin;
    try {
      storedPin = await _secureStorage.read(key: _pinKey);
    } catch (_) {
      return 'secure_storage_failed';
    }
    if (storedPin == null || storedPin.isEmpty) return 'pin_not_configured';
    if (storedPin != pin) return 'invalid_credentials';

    final SharedPreferences prefs = await _preferences;
    await prefs.setBool(_sessionKey, true);
    pinConfigured = true;
    signedIn = true;
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    if (!pinConfigured) return;
    final SharedPreferences prefs = await _preferences;
    await prefs.setBool(_sessionKey, false);
    signedIn = false;
    notifyListeners();
  }

  Future<String?> updateProfile({required String name, required String family}) async {
    final String normalizedName = name.trim();
    final String normalizedFamily = family.trim();
    if (normalizedName.length < 2 || normalizedName.length > 80) return 'invalid_name';
    if (normalizedFamily.length < 2 || normalizedFamily.length > 100) return 'invalid_family';

    userName = normalizedName;
    familyName = normalizedFamily;
    final SharedPreferences prefs = await _preferences;
    await _persistProfile(prefs);
    notifyListeners();
    return null;
  }

  Future<String?> changePin({required String currentPin, required String newPin}) async {
    if (!_isValidPin(newPin)) return 'invalid_pin';
    String? storedPin;
    try {
      storedPin = await _secureStorage.read(key: _pinKey);
    } catch (_) {
      return 'secure_storage_failed';
    }

    if (storedPin != null && storedPin.isNotEmpty) {
      if (storedPin != currentPin) return 'invalid_credentials';
      if (currentPin == newPin) return 'same_pin';
    }

    try {
      await _secureStorage.write(key: _pinKey, value: newPin);
    } catch (_) {
      return 'secure_storage_failed';
    }
    pinConfigured = true;
    notifyListeners();
    return null;
  }

  Future<void> _persistProfile(SharedPreferences prefs) async {
    await prefs.setString(_userKey, userName);
    await prefs.setString(_familyKey, familyName);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_familyIdKey, familyId);
    if (memberSince != null) {
      await prefs.setString(_memberSinceKey, memberSince!.toUtc().toIso8601String());
    }
  }

  String? _validateCredentials({
    required String name,
    required String family,
    required String emailAddress,
    required String pin,
    required bool requireProfile,
  }) {
    if (requireProfile && (name.length < 2 || name.length > 80)) return 'invalid_name';
    if (requireProfile && (family.length < 2 || family.length > 100)) return 'invalid_family';
    if (!_looksLikeEmail(emailAddress)) return 'invalid_email';
    if (!_isValidPin(pin)) return 'invalid_pin';
    return null;
  }

  bool _looksLikeEmail(String value) {
    final int at = value.indexOf('@');
    final int dot = value.lastIndexOf('.');
    return at > 0 && dot > at + 1 && dot < value.length - 1 && !value.contains(' ');
  }

  bool _isValidPin(String value) => RegExp(r'^\d{6}$').hasMatch(value);

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }
}

class FamilyScope extends InheritedNotifier<FamilyStore> {
  const FamilyScope({required FamilyStore store, required super.child, super.key})
      : super(notifier: store);

  static FamilyStore of(BuildContext context) {
    final FamilyScope? scope = context.dependOnInheritedWidgetOfExactType<FamilyScope>();
    assert(scope != null, 'FamilyScope is missing above this context');
    return scope!.notifier!;
  }
}
