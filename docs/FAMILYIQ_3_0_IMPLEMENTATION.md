# FamilyIQ 3.0 — Local Life OS Foundation

This release converts the 15-point product plan into explicit code boundaries. It does not claim that every production feature is complete.

## 1. Architecture

Implemented foundations:
- feature-first folders
- domain models independent from Flutter UI
- local application services
- explicit security and storytelling services
- optional cloud gateway remains isolated

Next production work:
- migrate all screens to Riverpod providers and repositories
- typed app-error hierarchy and structured redacted logger
- background task coordinator

## 2. Premium design

Implemented:
- shared spacing, radius and motion tokens
- premium reusable surface
- adaptive max-width container

Next:
- replace legacy one-off card styling
- golden tests for light, dark, tablet and large text
- shared-element and route transitions

## 3. Living Home

Existing 2.4 shell already exposes local metrics, recommendations and recent records. New domain boundaries support weather, child cards, finance goals and journal blocks without coupling them to storage.

## 4. Memory Engine 2.0

Existing search, seasonal summaries and On This Day remain. New journal and photo-grouping services add monthly storytelling foundations.

## 5. Family Graph

Added explicit people, roles, privacy levels and relationship edges. Interactive graph layout and editing UI remain.

## 6. Child OS

Added child domain model with guardians and explicit parental consent for sensitive insights. Health records, school, development and document screens remain future modules. Sensitive inference must stay disabled by default.

## 7. Family Finance

Added local finance-goal model with integer minor units and bounded progress. Banking integrations are intentionally excluded.

## 8. Calendar 2.0

Added calendar domain entry with members, categories and recurrence rule boundary. Drag-and-drop and local notification scheduling remain.

## 9. Family Intelligence

Added deterministic explainable local engine. Every insight contains title, reason, action and priority. It does not pretend to be an LLM.

## 10. Photo Intelligence

Added deterministic local grouping by month. Face recognition and automatic semantic labeling are not included because they require separate privacy review and device ML implementation.

## 11. Family Journal

Added monthly chapter generation with highlights and unfinished projects. PDF rendering and editorial layouts remain.

## 12. Export

Added stable JSON archive generation limited to one family. File-picker UX, ZIP media packaging and import preview remain.

## 13. Accessibility

Design primitives use Material semantics and adaptive width. Required before beta:
- VoiceOver and TalkBack walkthroughs
- minimum 44–48 px targets
- Dynamic Type golden tests
- reduced-motion handling
- high-contrast review

## 14. Performance

Current local architecture avoids network startup. Required before beta:
- paginated timeline
- isolate-based archive encoding for large families
- media thumbnail cache
- startup and frame benchmarks
- 10k-record profiling

## 15. Security

Added secure-storage lock foundation, PIN validation and constant-time comparison. The current lightweight digest is explicitly **not** a production password KDF. Before public release it must be replaced with a platform-backed KDF or vetted cryptographic package, plus biometric authentication, encrypted database, integrity checks, recovery and security audit log.

## Release gate

Do not call FamilyIQ 3.0 production-ready until all of the following pass:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
```

Also required: iOS and Android physical-device tests, accessibility review, local-data migration test and restore-from-backup drill.
