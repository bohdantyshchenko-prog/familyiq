import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyCloudGateway {
  FamilyCloudGateway(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({required String email, required String password, required String displayName}) async {
    final AuthResponse response = await _client.auth.signUp(email: email, password: password, data: <String, Object?>{'display_name': displayName});
    final User? user = response.user;
    if (user != null) {
      await _client.from('profiles').upsert(<String, Object?>{'id': user.id, 'display_name': displayName});
    }
  }

  Future<void> signIn({required String email, required String password}) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();

  Future<List<Map<String, dynamic>>> loadEntries(String familyId) async =>
      List<Map<String, dynamic>>.from(await _client.from('family_entries').select().eq('family_id', familyId).order('created_at', ascending: false));

  Future<Map<String, dynamic>> createEntry({
    required String familyId,
    required String type,
    required String title,
    required String note,
  }) async {
    final User user = currentUser!;
    return Map<String, dynamic>.from(await _client.from('family_entries').insert(<String, Object?>{
      'family_id': familyId,
      'author_id': user.id,
      'type': type,
      'title': title,
      'note': note,
    }).select().single());
  }

  Future<void> deleteEntry(String id) => _client.from('family_entries').delete().eq('id', id);

  Future<String> uploadMedia({required String familyId, required String fileName, required Uint8List bytes}) async {
    final String path = '$familyId/${DateTime.now().microsecondsSinceEpoch}_$fileName';
    await _client.storage.from('family-media').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: false));
    return path;
  }

  Future<String> askFamilyBrain({required String prompt, required String familyId}) async {
    final FunctionResponse response = await _client.functions.invoke('family-brain', body: <String, Object?>{'prompt': prompt, 'familyId': familyId});
    final Object? data = response.data;
    if (data is Map && data['answer'] is String) return data['answer'] as String;
    throw StateError('Family Brain returned an invalid response.');
  }
}
