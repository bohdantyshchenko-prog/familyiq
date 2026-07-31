# FamilyIQ 1.9 — Free Local-First Core

This release improves the product without requiring Supabase, OpenAI, paid storage or push infrastructure.

## Delivered

### Local reliability
- versioned local record schema;
- atomic-style primary and backup copies in SharedPreferences;
- automatic recovery from a damaged primary payload;
- soft deletion and record versions for future synchronization;
- deterministic ordering and tenant filtering;
- limits for title, note, record count and backup size.

### Data portability
- human-readable JSON export;
- validated JSON import;
- family-bound imports to prevent accidental cross-family mixing;
- duplicate ID rejection;
- schema and product checks before accepting a backup.

### Demo quality
- deterministic offline seed data;
- useful memories, events, projects and traditions without external services;
- no network dependency and no fake claim of cloud synchronization.

### Testing
- round-trip backup test;
- cross-family import rejection test;
- duplicate record rejection test.

## Free mode boundary

The application can be developed and tested without paid services using:
- local onboarding;
- SharedPreferences persistence;
- deterministic demo records;
- local JSON backup and restore;
- theme and locale persistence;
- Flutter widget and unit tests;
- GitHub Actions on the repository allowance.

## Recommended next free improvements

1. Bind all create forms and Timeline screens to `LocalEntryStore`.
2. Add visible export/import controls using the platform share and file picker APIs.
3. Move every remaining hard-coded screen string into localization.
4. Add golden tests for light and dark themes.
5. Add accessibility tests at 200% text scale and narrow phone widths.
6. Add a local rule-based Family Brain for useful offline suggestions.

## Not claimed complete

- cloud synchronization;
- multi-user collaboration;
- real push notifications;
- server-side AI;
- encrypted cloud media;
- production account recovery.
