# CLAUDE.md — tennisnow Control System

> This file controls how this project evolves. Read it before every task.
> Priority order for EVERY decision: **1) User experience → 2) Clarity → 3) Maintainability → 4) Performance → 5) Technical elegance.**
> If a rule here ever blocks doing the right thing for the user, surface the conflict — do not silently break the rule.

---

## 1. PROJECT UNDERSTANDING

**What it is:** `tennisnow` is a native, cross-platform mobile app (iOS + Android, store-ready) that is a **personal tennis companion** for hobby and club players. It is NOT a data-storage app — it is a **tennis improvement & motivation app**.

**The core loop (this is the product):**
> Play → log the session in seconds → see performance & feeling trends over time → stay motivated via lightweight gamification → come back.

**Distinctive value:** it connects **performance** with the **human side** — mood/mental state, physical feeling, and equipment — so players see *why* they play well, not just *how* they played.

**Target users:**
- **Hobby player** — casual, wants progress and a sense of growth with minimal effort.
- **Club player** — more competitive, cares about trends, matches, equipment correlation.

**Core workflows (v1):**
1. **Log a session** (match or training) — must feel instant (target < 30s).
2. **Capture context** — feeling/mental state + equipment used.
3. **View progress** — history + simple trends correlating performance with feeling/equipment.
4. **Motivation loop** — streaks, milestones, badges (lightweight, meaningful).

**Explicitly OUT of v1:** clubs, leagues, tournaments, events, social/matchmaking, chat, coaching marketplace, payments, cloud accounts/multi-device sync. These are **future**, and the architecture must accommodate them WITHOUT a rewrite — but we do not build them now.

---

## 2. ARCHITECTURE RULES

**Stack (locked — see `docs/decisions.md`):** Flutter + Dart · Riverpod (state) · go_router (navigation) · Drift/SQLite (local persistence). **Local-first, sync-ready.**

**Structure — feature-first + clean layering:**
```
lib/
  app/            # app shell (HomeShell bottom-nav), router, theme wiring, bootstrap
  core/           # cross-cutting: errors, result types, utils, constants, extensions
  design_system/  # tokens (color/spacing/typography), reusable widgets, theme — THE single visual source of truth
  features/
    <feature>/
      domain/         # entities, value objects, repository INTERFACES, pure logic (no Flutter, no I/O)
      data/           # repository implementations, datasources, DB models + mappers
      presentation/   # screens, widgets, Riverpod controllers/providers
  shared/
    domain/       # domain shared across features (e.g. the Rating value object)
    data/         # shared persistence infra: the app database + its provider (used by multiple features)
```

**Cross-feature rule:** features must not import another feature's internals. Anything two features both need (e.g. the database) lives in `shared/`. Navigation tabs are branches of the `StatefulShellRoute` in `app/router.dart`; full-screen flows (e.g. logging) are top-level routes pushed above the shell.

**Dependency rule (do not break):** `presentation → domain ← data`. Domain depends on NOTHING (no Flutter, no DB, no packages-with-side-effects). Dependencies point inward only. UI never touches the database directly — always through a repository interface.

**Data flow:** UI → Riverpod controller → repository (interface) → datasource (Drift). Results flow back as immutable domain entities. No business logic in widgets.

**Sync-ready invariant (do not break):** every persisted entity carries `id` (UUID v4, generated client-side), `createdAt`, `updatedAt`, and a soft-delete flag. This makes a future cloud-sync repository a drop-in addition, not a migration.

---

## 3. CODING RULES

- **Naming:** files `snake_case.dart`; types `PascalCase`; members/vars `camelCase`; providers end in `Provider`; repository interfaces are nouns (`SessionRepository`), impls are prefixed (`DriftSessionRepository`).
- **Immutability:** domain entities and state objects are immutable (`copyWith`). No mutable global state.
- **Reusability first:** before writing UI, check `design_system/` and the feature's existing widgets. Before writing logic, check `core/` and `shared/`. **Never create a one-off when a reusable component fits — extend the reusable one.**
- **Errors:** no silent failures. Return typed results / throw typed errors; the UI must render a real state for every failure (see UX rules).
- **No magic values:** colors, sizes, strings-with-meaning, and durations come from `design_system/` tokens or `core/constants`.
- **Anti-patterns (forbidden):** business logic in widgets · DB calls from UI · `setState` for app/business state (use Riverpod) · giant "util" dumping grounds · copy-pasted widgets · hard-coded colors/sizes · TODOs left in shipped flows without tracking.

---

## 4. UX RULES (CRITICAL — this is the product)

- **Logging is sacred.** The single most important UX is logging a session fast. Every change must keep the quick-log path at the absolute minimum taps with smart defaults. If a feature adds friction to logging, redesign it.
- **Minimal friction:** sensible defaults everywhere; never ask for data the app can infer or default. Optional context (feeling/equipment) must never block saving a session.
- **Intuitive flows:** a new user must understand the core loop without a manual. Onboarding shows value fast and avoids the empty-app problem.
- **Always show real states:** every screen handles **loading / empty / error / success** explicitly. Empty states are motivating and guide the next action — never a blank screen.
- **Feedback always:** every user action gives immediate, clear feedback (saved, undoable, progressed). Optimistic UI for logging.
- **Motivation, not noise:** gamification must feel meaningful and earned. Never gimmicky, never nagging.

---

## 5. DESIGN RULES

- **One visual source of truth:** all colors, spacing, typography, radii, shadows, and base components live in `design_system/`. Screens compose these — they never define their own.
- **Consistency mandatory:** reuse components; identical interactions look and behave identically across the app.
- **No visual chaos:** no one-off styles, no inline magic numbers, no ad-hoc colors.
- **Complete states:** every component visually defines its loading/empty/error/disabled/active states.
- **App-like & fast:** smooth, native-feeling motion; no janky or web-view feel.

---

## 6. PERFORMANCE RULES

- **Offline-first:** the app works fully without network (you log at the court). Network is an enhancement, never a requirement in v1.
- **Efficient rendering:** const constructors where possible; granular Riverpod providers to avoid wide rebuilds; lazy lists (`ListView.builder`) for history.
- **Efficient data:** push filtering/aggregation for trends into SQL (Drift), not Dart loops over full tables. Don't load more than a screen needs.
- **No hidden waste:** no rebuild storms, no per-frame allocations in hot paths, no redundant DB reads.

---

## 7. SECURITY & PRIVACY RULES

- **Safe defaults:** all data is on-device in v1; nothing leaves the phone without explicit user action.
- **Sensitive data:** mental-state/feeling data is personal — treat it with care, never log it to analytics/console, never expose it off-device without consent.
- **Validation:** validate all user input at the domain boundary (value objects enforce invariants).
- **Future auth:** when cloud accounts arrive, design for least-privilege and per-user data isolation from day one of that work.
- **Store compliance:** keep iOS/Android privacy declarations accurate as data handling evolves.

---

## 8. DEVELOPMENT WORKFLOW

**BEFORE changes**
- Read this file and `memory.md.txt`.
- Check for an existing solution: reusable widget (`design_system/`), shared logic (`core/`, `shared/`), existing repository/provider. Reuse/extend before creating.
- Confirm the change respects the dependency rule and the sync-ready invariant.

**DURING changes**
- Follow existing patterns; keep the core log-session flow fast.
- Handle all four UI states; give user feedback.
- Keep domain pure; keep design tokens centralized.

**AFTER changes**
- Update `CLAUDE.md` if a **rule** changed.
- Update `memory.md.txt` if something was **learned** (pitfall, insight, recurring mistake, important constraint).
- Add to `docs/decisions.md` if a **significant/irreversible decision** was made.
- Do NOT store temporary tasks, logs, or progress in any of these files.

---

## 9. DO-NOT-BREAK RULES

1. **The fast log-session flow** — never regress its speed or simplicity.
2. **The dependency rule** — domain stays pure; UI never touches the DB directly.
3. **The sync-ready entity invariant** (id/createdAt/updatedAt/soft-delete) — preserves the future cloud path.
4. **The design system as the single visual source of truth** — no one-off styles.
5. **Every screen handles loading/empty/error/success** — no dead-end blank states.
6. **Offline-first** — the core loop must work with no network.
7. **MVP scope discipline** — architect for clubs/events/sync later, but do not build them now.
```
