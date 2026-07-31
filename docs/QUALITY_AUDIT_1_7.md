# FamilyIQ 1.7 — Quality and security audit

## Reviewed areas

### Mobile architecture
Previous state: 8.5/10.

Main findings:
- Supabase implementation existed without an explicit repository contract.
- Provider boundaries were present but not yet consistently enforced.
- Cloud errors leaked implementation-specific exception types into future UI code.
- Media and AI inputs lacked client-side limits.

Changes:
- introduced `FamilyRepository` as the application-facing contract;
- made `FamilyCloudGateway` implement that contract;
- added normalized inputs, pagination limits and typed domain failures;
- removed unsafe `currentUser!` usage;
- added accessible text-scale limits and centralized app localization.

Target after this slice: 9.1/10 foundation. Feature-level controllers and offline conflict resolution remain future work.

### Backend foundation
Previous state: 8.5/10.

Main findings:
- family creation and owner membership were not transactional;
- several owner-only mutations lacked policies;
- storage object policies were missing;
- no immutable audit-event foundation;
- common tenant queries lacked indexes.

Changes:
- added transactional `create_family_space` RPC;
- added owner checks and member/invitation/family mutation policies;
- added private Storage read/upload/delete policies scoped by path family ID;
- added audit events and indexes;
- added automatic `updated_at` handling.

Target after this slice: 9.2/10 foundation. Invitation acceptance, abuse controls and backup drills remain required.

### Localization
Previous state: 8/10.

Changes:
- added Ukrainian, Russian and English locale support;
- added deterministic locale fallback to Ukrainian;
- connected Material, Widgets and Cupertino localization delegates;
- created a centralized string access layer.

Target after this slice: 9/10 foundation. Remaining hardcoded screen strings should be migrated incrementally.

### Light theme
Previous state: 8/10.

Changes:
- warmer canvas and surface hierarchy;
- stronger light-theme card separation without heavy shadows;
- consistent inputs, navigation, bottom sheets and app bars;
- improved focus borders and selected navigation typography;
- maintained dark-theme compatibility.

Target after this slice: 9/10.

### Security
Critical findings fixed:
- Family Brain previously trusted the caller-provided family ID.
- Edge Function did not authenticate the user or verify membership.
- raw provider errors could be returned to clients.
- prompt size and request method were unrestricted.
- storage RLS was incomplete.

Changes:
- validates JWT and active family membership before AI requests;
- validates method, UUID and prompt size;
- applies a 30-second provider timeout and output limit;
- returns stable error codes with request IDs instead of raw internals;
- adds CORS configuration;
- keeps OpenAI credentials server-side;
- adds database and Storage policies, audit events and restricted security-definer functions.

## Remaining production gates

1. Add automated RLS tests against a disposable Supabase project.
2. Add rate limiting for auth, invitations, uploads and AI.
3. Add bot protection and breached-password controls.
4. Add secure account export/deletion workflows.
5. Add dependency and secret scanning in CI.
6. Configure mobile certificate pinning only after an operational rotation plan exists.
7. Complete a threat model for child profiles and emergency access.
