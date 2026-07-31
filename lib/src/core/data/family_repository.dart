import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FamilyRepository {
  User? get currentUser;
  Stream<AuthState> get authChanges;

  Future<void> signUp({required String email, required String password, required String displayName});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<List<Map<String, dynamic>>> loadEntries(String familyId);
  Future<Map<String, dynamic>> createEntry({
    required String familyId,
    required String type,
    required String title,
    required String note,
  });
  Future<void> deleteEntry(String id);
  Future<String> uploadMedia({required String familyId, required String fileName, required Uint8List bytes});
  Future<String> askFamilyBrain({required String prompt, required String familyId});
}

class FamilyRepositoryException implements Exception {
  const FamilyRepositoryException(this.code, [this.cause]);

  final String code;
  final Object? cause;

  @override
  String toString() => 'FamilyRepositoryException($code)';
}
