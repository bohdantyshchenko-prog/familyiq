import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyEntry {
  const FamilyEntry({required this.id, required this.type, required this.title, required this.note, required this.createdAt});

  final String id;
  final String type;
  final String title;
  final String note;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'type': type,
        'title': title,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FamilyEntry.fromJson(Map<String, Object?> json) => FamilyEntry(
        id: json['id']! as String,
        type: json['type']! as String,
        title: json['title']! as String,
        note: json['note']! as String,
        createdAt: DateTime.parse(json['createdAt']! as String),
      );
}

class FamilyStore extends ChangeNotifier {
  static const String _sessionKey = 'familyiq.session';
  static const String _entriesKey = 'familyiq.entries';
  static const String _familyKey = 'familyiq.family';

  bool initialized = false;
  bool signedIn = false;
  String userName = 'Богдан';
  String familyName = 'Семья Тищенко';
  final List<FamilyEntry> entries = <FamilyEntry>[];

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    signedIn = prefs.getBool(_sessionKey) ?? false;
    familyName = prefs.getString(_familyKey) ?? familyName;
    final String? encoded = prefs.getString(_entriesKey);
    if (encoded != null) {
      final List<Object?> values = jsonDecode(encoded) as List<Object?>;
      entries
        ..clear()
        ..addAll(values.map((Object? value) => FamilyEntry.fromJson((value! as Map<Object?, Object?>).cast<String, Object?>())));
    }
    initialized = true;
    notifyListeners();
  }

  Future<void> signIn({required String name, required String family}) async {
    userName = name.trim().isEmpty ? 'Богдан' : name.trim();
    familyName = family.trim().isEmpty ? 'Моя семья' : family.trim();
    signedIn = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setString(_familyKey, familyName);
    notifyListeners();
  }

  Future<void> signOut() async {
    signedIn = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
    notifyListeners();
  }

  Future<void> addEntry({required String type, required String title, required String note}) async {
    entries.insert(
      0,
      FamilyEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        title: title.trim(),
        note: note.trim(),
        createdAt: DateTime.now(),
      ),
    );
    await _persistEntries();
    notifyListeners();
  }

  Future<void> removeEntry(String id) async {
    entries.removeWhere((FamilyEntry entry) => entry.id == id);
    await _persistEntries();
    notifyListeners();
  }

  Future<void> _persistEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, jsonEncode(entries.map((FamilyEntry entry) => entry.toJson()).toList()));
  }
}

class FamilyScope extends InheritedNotifier<FamilyStore> {
  const FamilyScope({required FamilyStore store, required super.child, super.key}) : super(notifier: store);

  static FamilyStore of(BuildContext context) {
    final FamilyScope? scope = context.dependOnInheritedWidgetOfExactType<FamilyScope>();
    assert(scope != null, 'FamilyScope is missing above this context');
    return scope!.notifier!;
  }
}
