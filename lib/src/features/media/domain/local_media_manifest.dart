import 'dart:convert';

class LocalMediaItem {
  const LocalMediaItem({
    required this.id,
    required this.familyId,
    required this.entryId,
    required this.localPath,
    required this.mimeType,
    required this.createdAt,
    this.caption = '',
    this.musicLabel,
  });

  final String id;
  final String familyId;
  final String entryId;
  final String localPath;
  final String mimeType;
  final DateTime createdAt;
  final String caption;
  final String? musicLabel;

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'entryId': entryId,
        'localPath': localPath,
        'mimeType': mimeType,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'caption': caption,
        'musicLabel': musicLabel,
      };
}

class LocalMediaManifest {
  const LocalMediaManifest({this.maxItems = 5000});

  final int maxItems;

  String encode(List<LocalMediaItem> items) {
    if (items.length > maxItems) throw const FormatException('Media item limit exceeded');
    _validate(items);
    return jsonEncode(<String, Object?>{
      'schemaVersion': 1,
      'items': items.map((LocalMediaItem item) => item.toJson()).toList(growable: false),
    });
  }

  void _validate(List<LocalMediaItem> items) {
    final Set<String> ids = <String>{};
    for (final LocalMediaItem item in items) {
      if (!ids.add(item.id)) throw const FormatException('Duplicate media id');
      if (item.familyId.trim().isEmpty || item.entryId.trim().isEmpty) {
        throw const FormatException('Invalid media ownership');
      }
      if (item.localPath.trim().isEmpty || item.localPath.contains('..')) {
        throw const FormatException('Unsafe local media path');
      }
      if (!item.isImage && !item.isVideo) throw const FormatException('Unsupported media type');
      if (item.caption.length > 1000) throw const FormatException('Media caption is too long');
    }
  }
}
