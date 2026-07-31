# FamilyIQ architecture

## Principles

1. Privacy and consent are product features, not legal afterthoughts.
2. A family is a tenant. Every persisted record carries a `family_id`.
3. Features own their domain, data and presentation layers.
4. Offline edits are queued and reconciled deterministically.
5. AI never receives more context than the user-approved task requires.
6. AI output stores provenance, model version and user feedback.
7. The Family Graph is a projection of canonical records, not a second source of truth.

## Target structure

```text
lib/src/
  app.dart
  core/
    auth/
    data/
    domain/
    privacy/
    sync/
    theme/
  features/
    family/
    graph/
    home/
    intelligence/
    memories/
    projects/
    search/
    shell/
    trust_center/
```

Each feature should evolve toward:

```text
feature/
  data/
  domain/
  presentation/
```

## Backend boundary

Recommended initial backend: Supabase/PostgreSQL.

Core tables:
- families
- family_members
- member_permissions
- memories
- memory_assets
- events
- projects
- project_steps
- graph_edges
- ai_conversations
- ai_recommendations
- audit_events

Row-level security must ensure that a user can only read a family record when an active membership and matching permission exist.

## Sync

- Client-generated UUIDs.
- `created_at`, `updated_at`, `deleted_at` and `version` on syncable records.
- Soft deletion until every authorized device acknowledges the tombstone.
- Last-write-wins only for simple scalar fields.
- Merge policies for lists, project steps and timeline entries.

## AI architecture

AI requests pass through a server-side orchestration layer. The mobile client must never ship a provider secret.

Request pipeline:
1. Authenticate user and family membership.
2. Resolve consented context.
3. Redact unnecessary identifiers.
4. Execute the requested capability.
5. Validate output against capability schema.
6. Store provenance and explanation.
7. Return the minimum required result.

## Security baseline

- TLS in transit and managed encryption at rest.
- Secure device token storage.
- Short-lived access tokens and refresh rotation.
- Immutable security audit trail.
- Rate limits on invitations, search and AI.
- Account export and deletion.
- No child profiling for advertising.
- Separate emergency-access design review before implementation.

## Testing strategy

- Domain unit tests.
- Repository contract tests.
- Widget tests for critical flows.
- Integration tests for onboarding, invitation, memory creation and deletion.
- RLS tests executed against an isolated backend project.
- Accessibility checks for text scale, contrast and screen readers.
