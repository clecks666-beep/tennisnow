# Decision Log (ADRs) — tennisnow

Lightweight record of **significant or hard-to-reverse** decisions only.
Format per entry: Context → Decision → Rationale → Consequences → Status.
Do not log trivial or easily reversible choices here.

---

## ADR-001 — Local-first, sync-ready data strategy
- **Status:** Accepted (2026-06-06)
- **Context:** v1 centers on a fast personal logging loop. Cloud accounts add cost, login friction, and no core value yet, but future club/event/multi-device features will need sync.
- **Decision:** Store all data on-device in v1. Make the schema sync-ready: every entity has `id` (client UUID v4), `createdAt`, `updatedAt`, and a soft-delete flag.
- **Rationale:** Removes logging friction (the #1 product risk), works offline at the court, is private and cheap, while keeping a non-breaking path to add a cloud-sync repository later.
- **Consequences:** No auth/backend in v1. The sync-ready invariant is mandatory for every persisted entity. Cloud sync is a future additive layer, not a migration.

## ADR-002 — Flutter + Dart as the cross-platform stack
- **Status:** Accepted (2026-06-06)
- **Context:** Must be store-ready on iOS and Android, feel app-like and fast, and lean on charts/animation for trends and motivation. Solo/clean-foundation context.
- **Decision:** Build with Flutter + Dart (single codebase).
- **Rationale:** One codebase for both stores, strong performance and consistent UI, mature charting/animation ecosystem, proven store track record. Avoids ~2x cost of separate Swift+Kotlin codebases.
- **Consequences:** Team works in Dart. Platform-specific needs handled via plugins/channels when required.

## ADR-003 — Riverpod · go_router · Drift/SQLite
- **Status:** Accepted (2026-06-06)
- **Context:** Need testable state management, structured navigation, and persistence that supports trend analytics.
- **Decision:** Riverpod for state, go_router for navigation, Drift (SQLite) for local persistence.
- **Rationale:** Riverpod is compile-safe, granular, and testable; go_router fits declarative deep-linkable navigation; Drift gives real relational queries so trend aggregation runs in SQL rather than Dart loops, and pairs cleanly with the sync-ready schema.
- **Consequences:** Aggregation/filtering for trends belongs in SQL. Providers kept granular to avoid wide rebuilds.

## ADR-004 — Feature-first architecture with a pure domain layer
- **Status:** Accepted (2026-06-06)
- **Context:** "Clean long-term foundation" was the explicit priority; the app must extend to clubs/events/sync without rewrites.
- **Decision:** Organize by feature, each split into domain/data/presentation. Domain is pure (no Flutter, no I/O). Dependencies point inward; UI talks to repository interfaces, never the DB.
- **Rationale:** Isolates business rules, enables testing and reuse, and makes future features and a cloud datasource swap-in additions rather than refactors.
- **Consequences:** More upfront structure than a flat MVP, accepted deliberately. The dependency rule and design-system-as-single-source-of-truth are enforced (see CLAUDE.md §9).

## ADR-005 — Device-local UI preferences via shared_preferences (separate from Drift)
- **Status:** Accepted (2026-06-06)
- **Context:** Onboarding needs a "seen" flag. Such flags describe how the app behaves on a specific device and must NOT sync across devices, unlike domain data.
- **Decision:** Store device-local UI preferences in `shared_preferences` (via `AppPreferences` in `shared/data`), kept entirely separate from the Drift domain database.
- **Rationale:** Keeps the sync-ready Drift schema for domain data only; avoids a DB migration for a non-domain flag; uses the standard, store-safe mechanism. Per-device UX state should never sync, so this separation is correct by design.
- **Consequences:** `main()` loads SharedPreferences before first frame and injects it via `sharedPreferencesProvider`. Future device-local settings (e.g. theme) extend `AppPreferences`; anything that must sync stays in Drift.

## ADR-006 — Versioned Drift schema with migrations
- **Status:** Accepted (2026-06-06)
- **Context:** The Equipment feature added a table — the first schema change after real users (web testers) had a v1 database. Dropping/recreating would destroy their data.
- **Decision:** Bump `schemaVersion` on every schema change and implement an additive `MigrationStrategy` (`onCreate: createAll`, `onUpgrade` applies incremental steps). v1→v2 creates the `equipment_items` table. Equipment chosen on a session is stored denormalized as the equipment **name** on `sessions.equipment` (no sessions migration); a future `equipmentId` FK is the clean upgrade when correlation analytics are built.
- **Rationale:** Protects on-device data (and the future cloud-sync path); keeps the sacred log flow and existing queries untouched.
- **Consequences:** ANY future schema change MUST bump the version and add a migration step (now a CLAUDE.md rule). Renaming equipment does not rewrite past sessions' stored names — acceptable for v1, revisited with the FK.

## ADR-007 — Gamification-first product direction + community-ready architecture
- **Status:** Accepted (2026-06-07)
- **Context:** The product is being explicitly oriented around gamification: logging real tennis should make a "game" of real skills level up (serve, forehand, backhand, spin, power, endurance, tactics, equipment synergy, …), RPG-like but always earned. Community features (leaderboards, friends, challenges, shareable Player Cards, clubs) are the planned future direction.
- **Decision:** Make gamification the product spine, codified in CLAUDE.md's ★ section: a canonical **Tennis Skill Model** (pure-domain catalog in `shared/domain`), a **Player Profile** (skills + XP + level + radar), and progression systems (XP/levels, recency-weighted skill ratings, streaks, badges, optional quests). Adopt a **community-ready invariant**: all scoring is pure & deterministic (server-recomputable), with stable client UUIDs and a clean future owner/`userId` seam — so multiplayer/community drops in without a rewrite. Keep **derive-not-store** as the default for progression.
- **Rationale:** Motivation/retention is the core value; expressing improvement as a credible, earned tennis game is the differentiator. Deterministic, re-derivable scoring is the cheapest way to stay both offline-first now and community-capable later.
- **Consequences:** Every feature must answer "how does this feed the Player Profile / progression / motivation, and is it community-ready?" Scoring logic stays in pure domain (never widgets), with game constants centralized. Guardrails are mandatory: logging stays sacred & fast (skill capture optional), progression must be earned/honest/non-nagging, the human/mental side stays first-class, sharing (later) is opt-in & granular. Community features are architected for but NOT built yet (build the single-player gamified loop first).
