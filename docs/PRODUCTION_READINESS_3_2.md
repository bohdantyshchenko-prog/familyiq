# FamilyIQ 3.2 Production Candidate

FamilyIQ 3.2 is a local-first production candidate. It is intentionally usable without Supabase, OpenAI, paid storage, subscriptions, or push infrastructure.

## Implemented production safeguards

- guarded application bootstrap
- release-safe fallback screen for uncaught Flutter UI failures
- local-first persistence with backup recovery
- family-scoped records
- soft deletion and versioned records
- input limits for titles and notes
- secret scanning through Gitleaks
- static analysis and automated tests in GitHub Actions
- accessibility semantics for primary navigation and creation action
- empty, loading, and local-offline states
- responsive layouts for narrow and wide screens
- no OpenAI key in the client

## Required green release gates

The release must not be merged or tagged until all checks pass:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test --coverage
```

GitHub Actions must also pass secret scanning.

## Manual mobile acceptance

Test on at least one current iPhone and one current Android device:

1. Complete onboarding.
2. Create memory, event, project, tradition, and child record.
3. Restart the application and confirm persistence.
4. Delete a record and confirm it remains deleted after restart.
5. Test all six navigation destinations.
6. Test text scaling at 100%, 130%, and 160%.
7. Test VoiceOver and TalkBack focus order.
8. Test offline launch and use.
9. Test low-storage behavior and recovery from malformed local data.
10. Confirm no personal content is printed to production logs.

## Store blockers not represented as complete

The following still require platform-owner configuration before App Store or Google Play submission:

- final app icon and launch screen
- iOS bundle identifier and signing profile
- Android application ID and signing key
- privacy policy URL and support URL
- App Store privacy labels and Play Data Safety form
- screenshots for supported device sizes
- real device accessibility sign-off
- encrypted local database if highly sensitive health or financial data is enabled
- biometric lock implementation and reviewed key derivation

## Release decision

The branch may be considered code-ready only after CI is green. Store-ready status requires the manual and platform-specific gates above. This distinction prevents a visually complete build from being misrepresented as a fully approved public release.
