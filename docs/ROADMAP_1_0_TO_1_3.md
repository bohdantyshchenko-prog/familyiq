# FamilyIQ roadmap: 1.0–1.3

## 1.0 — Foundation MVP

Product promise: one trusted place for family planning, memory and shared progress.

Delivered foundation:
- Flutter application shell for mobile, web and desktop targets.
- Home dashboard and Family Pulse.
- Shared timeline.
- Family Brain interaction surface.
- Family profiles and role model.
- Life Projects.
- Light and dark Material 3 design system.
- Creation flow for memories, events, projects and voice stories.

Production completion criteria:
- Supabase authentication and tenant isolation.
- Offline-first local persistence.
- Push notifications.
- Upload pipeline for photos and documents.
- Consent and deletion flows.

## 1.1 — Memory Platform

Scope:
- Memory Engine and “On this day”.
- Albums, tags, places and people.
- Voice memories and transcripts.
- AI-generated stories with source links.
- Family Movie and Family Book foundations.
- Search across memories and metadata.

Quality gates:
- Duplicate detection.
- User-approved face grouping only.
- Original media never modified.
- Export in open formats.

## 1.2 — Family Intelligence

Scope:
- Explainable Daily Brief.
- Weekly review.
- Family Pulse signals.
- Planning recommendations.
- Parenting, travel, food and home assistants as optional modules.
- Recommendation feedback: useful, irrelevant, sensitive.

Guardrails:
- Scores are private guidance, not diagnoses.
- No covert emotional surveillance.
- Sensitive recommendations require explicit data access.
- Every recommendation exposes “Why am I seeing this?”.

## 1.3 — Family Graph

Scope:
- Graph of members, relationships, events, places, memories and projects.
- Relationship timeline.
- Shared-history navigation.
- Context-aware recommendations powered by graph links.
- Role and field-level access policies.
- Trust Center showing data usage and AI sources.

Current repository release includes the product architecture, domain primitives and an interactive Flutter foundation representing 1.0–1.3. Backend, production AI and cloud synchronization remain integration work and must not be represented as complete.
