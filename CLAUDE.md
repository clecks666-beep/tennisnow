# CLAUDE.md — tennisnow Control System

> This file controls how this project evolves. Read it before every task.
> Priority order for EVERY decision: **1) User experience → 2) Clarity → 3) Maintainability → 4) Performance → 5) Technical elegance.**
> Above all of these sits the **product north star**: tennisnow turns *real tennis improvement* into a **game you want to keep playing**. Every feature must feed that.
> If a rule here ever blocks doing the right thing for the user, surface the conflict — do not silently break the rule.

---

## 1. PROJECT UNDERSTANDING

**What it is:** `tennisnow` is a native, cross-platform mobile app (iOS + Android, store-ready). It is a **gamified tennis improvement & motivation app** for hobby and club players. It is NOT a data-storage app and NOT a plain stats tracker — it turns the work of getting better at tennis into a **living, game-like progression** of your real skills.

**The product in one sentence:** *Log your tennis → watch your game level up.* Your sessions feed a **Player Profile** — a set of real tennis skills (serve, forehand, backhand, spin, power, endurance, tactics, …) that grow, unlock badges, build streaks, and visibly progress over time, the way an RPG character levels up — except every point is **earned by real play**.

**The core loop (this is the product):**
> Play → log the session in seconds → your skills, XP, level, streaks & badges update → see your game grow → feel the pull to come back and level up further.

**Distinctive value (two pillars, protect both):**
1. **Gamified progression of real skills** — improvement is made *visible, motivating and game-like* (skills, levels, XP, badges, streaks, quests, a Player Profile / radar). This is the spine of the app — see the ★ section below.
2. **Performance ↔ the human & gear side** — it connects how you played with **mood/mental state, physical feeling, and equipment** (incl. stringing), so players see *why* they play well, not just *how*. Mental and physical skills are first-class citizens of the skill model.

**Target users:**
- **Hobby player** — casual; wants a satisfying sense of growth and a reason to keep going, with minimal effort.
- **Club player** — competitive; cares about skill trends, match craft, equipment correlation, and (soon) comparing with others.

**Core workflows:**
1. **Log a session** (match or training) — must feel instant (target < 30s). Logging is what *earns* progression.
2. **Capture context & skills** — feeling/mental state, equipment, and (optionally, fast) which skills you worked on / how they felt.
3. **See your progression** — Player Profile (skills + level + XP), trends, streaks, badges, equipment correlation.
4. **Stay motivated** — meaningful, earned game mechanics that pull the player back without nagging.

**Planned direction — COMMUNITY (future, architect for it now):** leaderboards, friends, head-to-head challenges, shareable Player Cards, clubs/ladders, seasons. We do **not** build these yet, but the gamification model and data must be **community-ready** (see §2) so they drop in without a rewrite. Design every score/skill/profile as if it will one day be compared with other players.

**Explicitly OUT of the current build:** the community features above, plus coaching marketplace, payments, cloud accounts/multi-device sync. These are **future**; architecture must accommodate them WITHOUT a rewrite — but we do not build them now.

---

## ★ GAMIFICATION — THE TENNIS SKILL MODEL (THE HEART OF THE PRODUCT)

> This is the spine of tennisnow. Read it before designing ANY feature. Every feature must answer:
> **"How does this feed the Player Profile / skill progression / motivation loop — and is it community-ready?"**
> If a feature feeds none of these, it probably doesn't belong.

### A. The vision
The player has a **Player Profile** that grows like a game character built entirely from *real* tennis. Logging is the gameplay; progression is the reward. It must feel like a genuine tennis game (skills you recognise from the court) — never like cheap points bolted onto a spreadsheet.

### B. The Tennis Skill Model (the canonical taxonomy)
Skills are grouped into categories. This is the reference vocabulary — reuse these names; extend the model deliberately (and update this list + `memory.md.txt` when you do). Each skill has a **rating** (target representation: 0–100, shown as a level/tier) derived from the player's self-assessments over time, **recency-weighted** so it reflects current form.

- **Strokes (Schläge):** Serve (Aufschlag) · Return (Rückschlag) · Forehand (Vorhand) · Backhand (Rückhand) · Volley · Smash/Overhead (Schmetterball) · Slice · Lob · Drop shot (Stoppball).
- **Shot qualities (Schlag-Eigenschaften):** Power (Schlaghärte) · Spin (Topspin/Slice) · Placement/Accuracy (Präzision) · Consistency (Konstanz).
- **Physical (Physis):** Endurance/Stamina (Ausdauer) · Speed & Footwork (Schnelligkeit/Beinarbeit) · Agility (Beweglichkeit) · Strength (Kraft).
- **Mental (Mental):** Focus/Concentration (Konzentration) · Composure under pressure (Nervenstärke) · Confidence (Selbstvertrauen) · Tactics/Court IQ (Taktik).
- **Match craft (Matchstärke):** serve-game strength, break points, tiebreaks, clutch/closing — derived over time from match results + ratings.
- **Equipment synergy:** how racket & stringing (tension kg, string, freshness) correlate with performance — already feeds "Performance by equipment"; evolves into gear-based skill insight.

Model it as a small **pure-domain catalog** (one source of truth, like `BadgeCatalog`): `Skill { id, name, category }`, a `SkillCategory` enum, and `SkillRating` (recency-weighted aggregate). Keep it Flutter-free; map icons/labels in presentation.

### C. Progression mechanics (the game systems)
- **XP & Player Level** — every logged session grants XP (base + bonuses for matches, context completeness, streak, working a focus skill). XP rolls up into an overall **level + title** (e.g. Rookie → Rallyer → Club Contender → …).
- **Skill ratings** — updated when the player (optionally, fast) tags "what I worked on" and rates it. Recency-weighted so current form shows. Never required to save a session.
- **Streaks** — consistency rewards (already built; pure `StreakCalculator`, grace day).
- **Badges/Achievements** — milestones across volume, streaks, skills ("Serve level 5"), variety, comebacks (already built as `BadgeCatalog`; expand toward skill-based).
- **Quests / Challenges** — short, optional focus goals ("3 backhand-focus trainings this week"); seasonal later. Build only when they clearly add pull, never nagging.
- **Player Profile / radar** — the visual centrepiece: a spider/radar of skill categories + level + recent gains. This is where progression becomes *felt*.

### D. Principles — gamification DONE RIGHT (guardrails)
1. **Logging stays sacred & fast** (do-not-break #1). Skill tagging/rating is optional, quick, and never blocks Save.
2. **Earned & honest.** Progress reflects real logged effort and the player's own assessment. No fake dopamine, no inflated numbers, no pay-to-win, no manipulative streak-shaming. State only what the data supports.
3. **Real tennis semantics.** Attributes map to how players actually think about their game. The model must feel credible to a club player.
4. **Meaningful, not noisy** (do-not-break, §4). Celebrate level-ups/skill gains with light, native, *occasional* feedback — never spammy notifications or constant badges.
5. **The human side is part of the game.** Mood/feeling and mental skills are first-class — never reduce the player to raw output.
6. **Community-ready from day one** (§2). Every skill/XP/level/badge is computed in a way that could later be compared, ranked, or shared — stable ids, server-recomputable scoring, no single-user-only assumptions.

### E. How EXISTING code aligns (and should evolve)
- `features/gamification` (streak + badges) is the seed of this system → grows into XP/levels/quests.
- `features/progress` (stats, trend, performance-by-equipment) → becomes the analytics that feed skill ratings + the Player Profile.
- `session_logging` → the gameplay input; the optional "skills worked on" capture plugs in here **without** slowing the quick-log path.
- `equipment` → feeds equipment-synergy skill insight.
- `settings` → home for profile/personalization; future community/account settings.
Prefer **derived-not-stored** for progression where feasible (compute from sessions), persisting only what derivation can't reconstruct (e.g. explicit skill self-ratings, unlocked-badge timestamps).

---

## 2. ARCHITECTURE RULES

**Stack (locked — see `docs/decisions.md`):** Flutter + Dart · Riverpod (state) · go_router (navigation) · Drift/SQLite (local persistence). **Local-first, sync-ready, community-ready.**

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
    domain/       # domain shared across features (e.g. Rating, SessionType — and the Skill model)
    data/         # shared infra: the app database (Drift, synced domain data) + device-local prefs (shared_preferences, NOT synced)
```

**Cross-feature rule:** a feature must not import another feature's **internals** (its `data/` or `domain/`). Shared data/domain lives in `shared/`. A feature **may** compose another feature's **public presentation surface** — an exported widget or Riverpod provider (e.g. Progress embeds gamification's `GamificationStrip`). Keep such public widgets self-contained. The **Skill model** is cross-cutting → it lives in `shared/domain`. Navigation tabs are branches of the `StatefulShellRoute` in `app/router.dart`; full-screen/detail flows (logging, achievements, profile) are top-level routes pushed above the shell.

**Dependency rule (do not break):** `presentation → domain ← data`. Domain depends on NOTHING (no Flutter, no DB, no packages-with-side-effects). Dependencies point inward only. UI never touches the database directly — always through a repository interface.

**Data flow:** UI → Riverpod controller → repository (interface) → datasource (Drift). Results flow back as immutable domain entities. No business logic in widgets. **Scoring/skill/XP logic is PURE domain** (testable, no I/O) — like `StreakCalculator`/`BadgeCatalog`.

**Sync-ready invariant (do not break):** every persisted entity carries `id` (UUID v4, generated client-side), `createdAt`, `updatedAt`, and a soft-delete flag. This makes a future cloud-sync repository a drop-in addition, not a migration.

**Community-ready invariant (do not break):** design all gamification & profile data to survive becoming multi-user and comparable:
- Stable client UUIDs everywhere (already required) so records can later belong to a user/account.
- **Progression scoring lives in pure, deterministic domain functions** (same input → same output, injectable clock) so a server could recompute/verify the same XP/level/skill numbers — no trust-the-client-only logic, no scoring buried in widgets.
- Keep a clean seam for a future `userId`/owner on shareable entities; don't hardcode "there is exactly one local player."
- Never bake single-device assumptions into scores (e.g. don't store a level as an opaque number you can't re-derive).

**Schema migrations (do not break):** the app has real on-device data. ANY Drift schema change MUST bump `schemaVersion` and add an additive step to the `MigrationStrategy` — never drop/recreate. See ADR-006.

---

## 3. CODING RULES

- **Naming:** files `snake_case.dart`; types `PascalCase`; members/vars `camelCase`; providers end in `Provider`; repository interfaces are nouns (`SessionRepository`), impls are prefixed (`DriftSessionRepository`).
- **Immutability:** domain entities and state objects are immutable (`copyWith`). No mutable global state.
- **Reusability first:** before writing UI, check `design_system/` and the feature's existing widgets. Before writing logic, check `core/` and `shared/`. **Never create a one-off when a reusable component fits — extend the reusable one.** For progression, reuse the catalog/pure-function pattern (`BadgeCatalog`, `StreakCalculator`) — don't invent a parallel scoring system.
- **Errors:** no silent failures. Return typed results / throw typed errors; the UI must render a real state for every failure (see UX rules).
- **No magic values:** colors, sizes, strings-with-meaning, durations, **and game constants (XP amounts, level thresholds, weights)** come from `design_system/` tokens or `core/constants` / a dedicated balancing constants file — never scattered literals.
- **Anti-patterns (forbidden):** business logic in widgets · DB calls from UI · `setState` for app/business state (use Riverpod) · giant "util" dumping grounds · copy-pasted widgets · hard-coded colors/sizes · scoring logic in widgets · TODOs left in shipped flows without tracking.

---

## 4. UX RULES (CRITICAL — this is the product)

- **Logging is sacred.** The single most important UX is logging a session fast. Every change must keep the quick-log path at the absolute minimum taps with smart defaults. **Gamification capture (skills worked on, etc.) is always optional and never blocks Save.** If a feature adds friction to logging, redesign it.
- **Progression must be felt.** After logging, the player should *see* what they earned — XP gained, a skill nudged up, a streak kept, a badge unlocked — with immediate, tasteful feedback. Make growth visible; make the next goal obvious.
- **Minimal friction:** sensible defaults everywhere; never ask for data the app can infer or default. Optional context (feeling/equipment/skills) must never block saving a session.
- **Intuitive flows:** a new user must understand the loop (play → log → level up) without a manual. Onboarding shows the game fast and avoids the empty-app problem.
- **Always show real states:** every screen handles **loading / empty / error / success** explicitly. Empty states are motivating and guide the next action — for progression, an empty profile should sell the game ("log your first session to start leveling your serve"), never a blank screen.
- **Feedback always:** every user action gives immediate, clear feedback (saved, undoable, progressed). Optimistic UI for logging.
- **Motivation, not noise:** gamification must feel meaningful and earned. Never gimmicky, never nagging, no spammy notifications. Celebrate occasionally and honestly.

---

## 5. DESIGN RULES

- **One visual source of truth:** all colors, spacing, typography, radii, shadows, and base components live in `design_system/`. Screens compose these — they never define their own.
- **Consistency mandatory:** reuse components; identical interactions look and behave identically across the app. Progression visuals (skill bars, level chips, badges, radar, XP) become **reusable design-system components** — never one-off per screen.
- **No visual chaos:** no one-off styles, no inline magic numbers, no ad-hoc colors.
- **Complete states:** every component visually defines its loading/empty/error/disabled/active states.
- **App-like & fast:** smooth, native-feeling motion. Progression moments (level-up, skill gain) deserve polished, *restrained* micro-animations — celebratory but never janky, blocking, or web-view-ish.

---

## 6. PERFORMANCE RULES

- **Offline-first:** the app works fully without network (you log at the court). Network is an enhancement, never a requirement now.
- **Efficient rendering:** const constructors where possible; granular Riverpod providers to avoid wide rebuilds; lazy lists (`ListView.builder`) for history.
- **Efficient data:** push filtering/aggregation for trends & skill scoring into SQL (Drift) where it's set-based; keep inherently-sequential logic (streaks, recency weighting) in bounded, pure Dart. Don't load more than a screen needs.
- **No hidden waste:** no rebuild storms, no per-frame allocations in hot paths, no redundant DB reads. Recompute progression reactively from streams, not on a timer.

---

## 7. SECURITY & PRIVACY RULES

- **Safe defaults:** all data is on-device now; nothing leaves the phone without explicit user action.
- **Sensitive data:** mental-state/feeling data is personal — treat it with care, never log it to analytics/console, never expose it off-device without consent. When community/sharing arrives, sharing a Player Card must be **opt-in and granular** — never silently publish feelings, notes, or raw history.
- **Validation:** validate all user input at the domain boundary (value objects enforce invariants).
- **Future auth & community:** when cloud accounts/community arrive, design for least-privilege and per-user data isolation from day one of that work; assume scores may be server-verified.
- **Store compliance:** keep iOS/Android privacy declarations accurate as data handling evolves.

---

## 8. DEVELOPMENT WORKFLOW

**BEFORE changes**
- Read this file (especially the ★ section) and `memory.md.txt`.
- Ask the gamification question: *how does this feed the Player Profile / progression / motivation, and is it community-ready?*
- Check for an existing solution: reusable widget (`design_system/`), shared logic (`core/`, `shared/`), existing repository/provider, existing catalog/pure-function. Reuse/extend before creating.
- Confirm the change respects the dependency rule, the sync-ready invariant, and the community-ready invariant.

**DURING changes**
- Follow existing patterns; keep the core log-session flow fast; keep scoring pure & deterministic.
- Handle all four UI states; give user feedback; make earned progression visible.
- Keep domain pure; keep design tokens & game constants centralized.

**AFTER changes**
- Update `CLAUDE.md` if a **rule** changed — and keep the ★ skill model current when the model grows.
- Update `memory.md.txt` if something was **learned** (pitfall, insight, recurring mistake, important constraint, progression-balancing decision).
- Add to `docs/decisions.md` if a **significant/irreversible decision** was made.
- Do NOT store temporary tasks, logs, or progress in any of these files.

---

## 9. DO-NOT-BREAK RULES

1. **The fast log-session flow** — never regress its speed or simplicity; gamification capture stays optional.
2. **Gamification is the core, done right** — every feature feeds the Player Profile / progression / motivation loop; progression is **earned, honest, meaningful, never gimmicky or nagging**; the tennis skill model is the shared vocabulary (★ section).
3. **The dependency rule** — domain stays pure; UI never touches the DB directly; scoring/skill logic is pure domain, never in widgets.
4. **The sync-ready entity invariant** (id/createdAt/updatedAt/soft-delete) — preserves the future cloud path.
5. **The community-ready invariant** — deterministic, re-derivable scoring + stable ids + a clean owner seam, so multiplayer/community drops in without a rewrite.
6. **The design system as the single visual source of truth** — no one-off styles; progression visuals are reusable components.
7. **Every screen handles loading/empty/error/success** — no dead-end blank states; empty progression states sell the game.
8. **Offline-first** — the core loop must work with no network.
9. **Scope discipline** — architect for community/accounts/sync now, but BUILD the single-player gamified loop first; do not build community features yet.
```
