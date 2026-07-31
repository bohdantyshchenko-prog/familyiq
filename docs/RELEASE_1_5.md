# FamilyIQ 1.5 — Real Product Core

FamilyIQ 1.5 starts the transition from a visual prototype to an application that owns real user state.

## Delivered

- first-run onboarding screen
- persistent local session
- creation of a named family space
- local domain store for memories, events, projects and notes
- JSON serialization and restoration between launches
- add and remove operations for family entries
- application-wide `FamilyScope`
- loading and authenticated states
- version bump to 1.5.0

## Architecture boundary

The local store is deliberately behind a small application state API. A Supabase implementation can later replace persistence without forcing presentation widgets to own database logic.

## Not claimed as complete

- secure production authentication
- cloud synchronization
- multi-user invitations
- object storage for photos and audio
- production AI responses
- push notifications
- offline conflict resolution

These require configured infrastructure, secrets, migrations and platform credentials. The current release creates the correct product seam without hard-coding credentials into the repository.

## Next engineering slice

1. Connect Supabase Auth.
2. Add database migrations and row-level security.
3. Bind quick-create forms to `FamilyStore`.
4. Render stored entries in Timeline and Projects.
5. Add media upload and retry states.
6. Add repository and integration tests.
