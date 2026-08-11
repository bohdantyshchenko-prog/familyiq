# FamilyIQ 4.0

FamilyIQ is a privacy-first, local-first family life operating system built with Flutter.

The 4.0 release is the definitive offline production baseline. It works without Supabase, OpenAI, paid storage, subscriptions, push providers, or any other external service.

## Product scope

- premium six-tab mobile experience;
- Home with cinematic family hero and Family Pulse;
- family history and memory timeline;
- local calendar and events;
- Life Projects;
- Family Graph and Trust Center;
- child records with privacy constraints;
- explainable offline Family IQ recommendations;
- seasonal summaries and family storytelling;
- local creation, reading, deletion, search, and filtering;
- local backup recovery and JSON archive foundation;
- Ukrainian, Russian, and English localization foundation;
- light and dark themes;
- responsive phone and wide-screen layouts.

## Privacy and cost model

All core data is stored locally on the device. External integrations are optional and disabled when configuration is absent. No API key is required to run the application.

## Run

```bash
flutter pub get
flutter run
```

## Quality gates

```bash
dart format lib test
flutter analyze --fatal-warnings
flutter test --coverage
```

GitHub Actions also performs secret scanning with Gitleaks.

## Release boundary

FamilyIQ 4.0 is the final code baseline for the free local product. App Store and Google Play publication still require owner-controlled platform work: signing identities, bundle identifiers, final icons, screenshots, privacy and support URLs, and physical-device acceptance testing.

## Product principles

- privacy before engagement;
- local operation by default;
- explainable recommendations;
- explicit child-data safeguards;
- user-controlled export and deletion;
- no covert emotional surveillance;
- no false claims about unavailable cloud or AI services.
