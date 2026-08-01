# FamilyIQ 2.2–2.4

## 2.2 — Deep Local Product

- real local search by text, type and year
- calendar occurrence engine
- seasonal summaries
- “On this day” memories
- explainable offline recommendations
- child privacy policy and parental-consent boundaries
- local project-stage domain model with computed progress and budget

## 2.3 — Media & Storytelling Foundation

- local media manifest for images and video
- strict ownership validation
- unsafe path rejection
- captions and optional music labels
- schema prepared for local albums, slideshows and family stories

Media bytes are not yet copied into application storage. The manifest is the safe metadata boundary required before that step.

## 2.4 — Quality Product Shell

- new six-tab product shell
- premium Home
- Memory Engine
- real Calendar tab
- Life Projects
- Offline Family Brain
- Family and child profiles
- visible Trust Center
- expanded create flow for memories, events, projects, traditions and child entries
- accessibility-compatible Material controls and clamped app text scaling inherited from the application root

## Free-mode boundary

No Supabase, OpenAI, cloud media storage, paid push provider or subscription is required.

## Validation commands

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
```

## Remaining before public beta

- copy selected media into application-managed local storage
- visible archive file picker for export/import
- replace deterministic project progress with persisted stages
- migrate every visible string to localization keys
- golden tests on small phone, large phone and tablet
- VoiceOver/TalkBack manual pass
- real local-notification scheduling
- performance profiling with large local archives
