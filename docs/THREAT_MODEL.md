# FamilyIQ threat model

## Assets
- family membership and roles
- private memories, photos, audio and documents
- child profiles and development data
- invitation tokens and sessions
- AI prompts, context and generated responses
- export and deletion requests

## Trust boundaries
1. Flutter device and local cache.
2. Supabase Auth and PostgreSQL.
3. Private Storage bucket.
4. Edge Functions.
5. External AI provider.
6. Email, push and deep-link providers.

## Primary threats and controls

### Cross-family data access
Controls: `family_id` on tenant records, RLS on every tenant table, membership checks in RPCs and Edge Functions, private storage paths, automated RLS verification.

### Privilege escalation
Controls: owner-only role mutation, server-side invitation acceptance, immutable owner transfer audit, no role claims trusted from the client.

### Lost or stolen device
Controls: short-lived access tokens, secure platform storage for refresh credentials, remote session revocation, local cache minimization and biometric app lock before production.

### Invitation abuse
Controls: hashed single-use tokens, expiry, rate limits, email normalization, owner-only issuance and audit events.

### Media abuse
Controls: private bucket, content-type allow-list, byte limits, sanitized names, malware scanning before sharing and signed short-lived download URLs.

### AI data leakage
Controls: server-side membership verification, minimum-context selection, identifier redaction, prompt-size limits, no provider keys in Flutter, stable error responses and request IDs.

### Child-data misuse
Controls: no advertising profiles, no public discovery, guardian-controlled sharing, age-appropriate consent, restricted exports and a separate child-safety review before launch.

### Account deletion gaps
Controls: verified export, staged deletion, tombstones for sync, storage cleanup jobs and auditable completion.

## Required release gates
- Flutter analyze and tests pass.
- Secret scanning passes.
- RLS verification passes against an isolated project.
- Dependency vulnerabilities reviewed.
- Export and deletion integration tests pass.
- Child-profile threat review approved.
