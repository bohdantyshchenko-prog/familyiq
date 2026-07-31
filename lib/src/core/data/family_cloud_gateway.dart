import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'family_repository.dart';

class FamilyCloudGateway implements FamilyRepository {
  FamilyCloudGateway(this._client);

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  @override
  Future<void> signUp({required String email, required String password, required String displayName}) async {
    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: <String, Object?>{'display_name': displayName.trim()},
      );
      final User? user = response.user;
      if (user != null) {
        await _client.from('profiles').upsert(<String, Object?>{
          'id': user.id,
          'display_name': displayName.trim(),
        });
      }
    } on AuthException catch (error) {
      throw FamilyRepositoryException('sign_up_failed', error);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email.trim().toLowerCase(), password: password);
    } on AuthException catch (error) {
      throw FamilyRepositoryException('sign_in_failed', error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (error) {
      throw FamilyRepositoryException('sign_out_failed', error);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadEntries(String familyId) async {
    try {
      final data = await _client
          .from('family_entries')
          .select()
          .eq('family_id', familyId)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (error) {
      throw FamilyRepositoryException('load_entries_failed', error);
    }
  }

  @override
  Future<Map<String, dynamic>> createEntry({
    required String familyId,
    required String type,
    required String title,
    required String note,
  }) async {
    final User? user = currentUser;
    if (user == null) throw const FamilyRepositoryException('authentication_required');
    final String normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty || normalizedTitle.length > 160) {
      throw const FamilyRepositoryException('invalid_title');
    }

    try {
      final data = await _client.from('family_entries').insert(<String, Object?>{
        'family_id': familyId,
        'author_id': user.id,
        'type': type,
        'title': normalizedTitle,
        'note': note.trim(),
      }).select().single();
      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (error) {
      throw FamilyRepositoryException('create_entry_failed', error);
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await _client.from('family_entries').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw FamilyRepositoryException('delete_entry_failed', error);
    }
  }

  @override
  Future<String> uploadMedia({required String familyId, required String fileName, required Uint8List bytes}) async {
    if (bytes.isEmpty || bytes.lengthInBytes > 25 * 1024 * 1024) {
      throw const FamilyRepositoryException('invalid_media_size');
    }
    final String safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final String path = '$familyId/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    try {
      await _client.storage.from('family-media').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: false, cacheControl: '3600'),
          );
      return path;
    } on StorageException catch (error) {
      throw FamilyRepositoryException('upload_failed', error);
    }
  }

  @override
  Future<String> askFamilyBrain({required String prompt, required String familyId}) async {
    final String normalizedPrompt = prompt.trim();
    if (normalizedPrompt.isEmpty || normalizedPrompt.length > 2000) {
      throw const FamilyRepositoryException('invalid_prompt');
    }
    try {
      final FunctionResponse response = await _client.functions.invoke(
        'family-brain',
        body: <String, Object?>{'prompt': normalizedPrompt, 'familyId': familyId},
      );
      final Object? data = response.data;
      if (response.status == 200 && data is Map && data['answer'] is String) {
        return data['answer'] as String;
      }
      throw const FamilyRepositoryException('invalid_ai_response');
    } on FunctionException catch (error) {
      throw FamilyRepositoryException('ai_request_failed', error);
    }
  }
}
