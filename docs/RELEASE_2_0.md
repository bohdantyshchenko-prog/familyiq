# FamilyIQ 2.0 — Local Connected Product

## Purpose

Version 2.0 connects the visible product screens to the versioned local data layer. It remains fully usable without Supabase, OpenAI, paid storage or push services.

## Delivered

- lifecycle-safe local application controller
- automatic deterministic demo seed on first launch
- real local counts on the dashboard
- Timeline bound to saved memories
- Projects bound to saved projects
- Events bound to saved events
- functional create form for memory, event and project records
- pull-to-refresh
- soft deletion with confirmation
- profile record count and local-mode status
- stable family isolation using the family space identifier
- free onboarding and session persistence

## Data behavior

Records are written through `LocalEntryStore`, which provides a versioned schema, primary and backup copies, validation, family isolation and soft deletion. The controller is deliberately independent from Supabase so a future cloud repository can be added without replacing the UI.

## Honest limitations

- photos and binary media are not yet persisted locally
- export/import services are not yet exposed through visible file pickers
- existing screens still contain untranslated Russian strings
- Family Brain remains offline and rule-based until a paid or self-hosted model is configured
- CI and physical-device testing must pass before a store release

## Validation

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
```
