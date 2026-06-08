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
- **Quests / Challenges** — short, optional weekly focus goals; **built** (`features/quests`, see ★E). Seasonal/expanded later. Build only when they clearly add pull, never nagging.
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
- `session_logging` → the gameplay input; the optional "skills worked on" capture is **built** (`features/skills`): an optional sheet on the log form persists per-session skill self-ratings (1–5), recency-weighted into per-skill `SkillScore`s (in `shared/domain/skill`).
- `features/player_profile` → the **Player Profile is built as a gamified "character sheet"** (★ centrepiece): a `/profile` screen with the **level + title + XP** hero (`PlayerLevelCard`) and live **streak** (`StreakBanner`) on top, then the skill-category **radar** (`SkillRadarChart`), a category breakdown, the **next badge** (`NextBadgeCard`) and top skills. Every number is pure-derived: category aggregation, `overall`, and the honest **edge / work-on-next** read (`PlayerProfileBuilder.strongest` / `.focus`) are all deterministic, testable functions over `SkillScore`s — the "work on next" nudge is derived from the radar shape (prefers an untouched category, else the weakest), never invented. The screen **composes only public surfaces** — gamification's `PlayerLevelCard` / `StreakBanner` / `NextBadgeCard` (a new reusable progression visual, §5) + `gamificationProvider`, and skills' scores provider/summary — never internals (§2). Tagging skills also grants an **XP bonus** (`GameBalance.xpPerSkillSession`, per skill-tagged session — honest, non-farmable). The profile also has an **avatar hero** (always visible, even pre-first-session): a **DiceBear `adventurer`** SVG character the player customises (skin/hair/eyes/mouth/background) via a live editor sheet. `AvatarConfig` (pure `shared/domain/avatar`) builds a deterministic API URL; `AvatarWidget` (design-system) renders it with `flutter_svg`; `avatarConfigProvider` persists it in `AppPreferences` (cosmetic, device-local). Rendered at runtime from params — **no avatar image assets, no Replicate, no build step** (a layered-PNG/Replicate avatar pipeline was tried and abandoned for unfixable layer-alignment — see `memory.md.txt`). Cosmetic options are **gated by player level** (`AvatarOption.unlockLevel`, tiers in `GameBalance`) so customisation is an earned reward — gating is a **pure function of the level** (read from `gamificationProvider`), so nothing is persisted (level derives from monotonic XP → unlocks are permanent, derived-not-stored, community-ready). **Skin tones are never gated** (identity, not a reward); locked options are shown with their level requirement, never hidden.
- **Felt-moments are built**: after a save, the player sees what they earned (XP, level-up, new badge) via one tasteful, non-blocking SnackBar — celebratory only on a real level-up/badge, otherwise a quiet "+XP" (★/§4/§5: progression must be felt, but meaningful not noisy). The diff is a pure `ProgressionDelta`; the cross-feature reward seam is the public `ProgressionReward` (`progressionRewardProvider`) so `session_logging` triggers rewards without importing gamification internals — reuse this seam for any feature that needs felt rewards.
- `features/quests` → **Weekly Quests are built**: a "This week's quests" card on the Progress tab shows 3 small, optional, achievable weekly goals — log 3 sessions, work this week's **rotating focus skill** in 2 sessions, and note mood/energy in 2 sessions (hits the streak, skill-model and human-side pillars; no match requirement, so a training-only player can complete them all). Fully **derived-not-stored**: the board is a pure, deterministic `WeeklyQuests.boardFor(now, sessions, skillTags)` over existing data (no new table, no schema bump, injected clock, server-recomputable). Quests grant **no separate XP** on purpose — completing one just means you did the logging that already levels you up, so progression stays honest and un-farmable (★D). Felt via goal-gradient progress bars + an on-brand "done" state, never an extra notification. The reusable `AppProgressBar` (design-system) backs any goal bar.
- `features/coach` → **the first realization of the AI intelligence layer (§11)**: a `CoachCard` on the Progress tab gives one honest, data-grounded read — headline + forward note + explainability "basis" chips + a focus skill — derived from a compact, pre-aggregated `CoachContext` (the exact minimal payload a future LLM receives; §11 cost rule). Built offline-first: `RuleBasedCoach` is a deterministic, zero-token coach that ALWAYS works; a live model is a later drop-in behind the same `coachInsightProvider` (try the model when reachable, else fall back) — `CoachInsight.source` (rule|ai) keeps the UI honest (never fakes a model, §7/§11). The coach **domain** uses only primitives + the shared `SkillScore` model (dependency rule §2); the adapter that maps the public session-stats / trend / skill / gamification providers into `CoachContext` lives in the presentation layer.
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

---

## 10. PREMIUM PRODUCT DESIGN, UX & QUALITY STANDARDS

### Höchste Priorität

Dieses Projekt soll nicht nur technisch funktionieren.

Das Ziel ist die Entwicklung eines Produkts, das sowohl technisch als auch visuell auf höchstem Niveau umgesetzt wird.

Design, User Experience und wahrgenommene Qualität haben dieselbe Priorität wie Funktionalität, Stabilität, Sicherheit und Codequalität.

Eine technisch korrekte, aber durchschnittlich aussehende Lösung gilt nicht als abgeschlossen.

---

### Grundsatz

Arbeite nicht wie ein Entwickler, der Funktionen implementiert.

Arbeite wie ein erfahrenes Produktteam bestehend aus:

* Product Designern
* UX Designern
* Frontend Spezialisten
* Software Architekten
* Produktmanagern

Jede Entscheidung soll die Qualität des Endprodukts erhöhen.

---

### Premium-Produkt Standard

Jede Seite, jede Komponente und jede Interaktion soll sich wie ein modernes Premium-Produkt anfühlen.

Die Anwendung soll wirken, als wäre sie von einem professionellen Team entwickelt worden und nicht wie ein internes Entwickler-Tool.

Ziel ist kein durchschnittliches Design.

Ziel ist ein modernes, professionelles und hochwertiges Nutzererlebnis.

Jede Oberfläche soll wirken, als wäre sie mehrfach überarbeitet, getestet und optimiert worden.

---

### Homepage Standard

Die Homepage ist kein technischer Einstiegspunkt.

Die Homepage ist ein Verkaufs-, Vertrauens- und Begeisterungsinstrument.

Die Homepage muss:

* modern wirken
* professionell wirken
* Vertrauen erzeugen
* Kompetenz ausstrahlen
* hochwertig wirken
* visuell beeindrucken
* die wichtigsten Vorteile sofort kommunizieren

Jeder Besucher soll innerhalb weniger Sekunden verstehen:

* Was das Produkt macht
* Warum es besser ist
* Warum er es nutzen sollte

Die Homepage soll sich auf Premium-Niveau bewegen.

---

### Design First

Vor jeder UI-Implementierung prüfen:

* Ist dies die attraktivste Lösung?
* Ist dies die intuitivste Lösung?
* Ist dies die hochwertigste Lösung?
* Ist dies die modernste Lösung?
* Würde ein professionelles SaaS-Unternehmen dies veröffentlichen?

Wenn nicht: weiter optimieren.

Funktionierende Lösungen mit schlechtem UX gelten nicht als fertig.

---

### Entscheidungsregel bei mehreren Lösungen

Wenn mehrere technisch korrekte Lösungen möglich sind, darf die Entscheidung nicht ausschließlich anhand der Implementierungsgeschwindigkeit oder technischen Einfachheit getroffen werden.

Bewerte jede Lösung zusätzlich nach:

* User Experience
* Designqualität
* Professionalität
* Konsistenz
* Wartbarkeit
* Skalierbarkeit
* wahrgenommener Produktqualität

Bevorzuge die Lösung mit der höchsten Gesamtqualität für den Endanwender.

---

### Premium statt Minimum

Implementiere niemals die kleinstmögliche Lösung nur weil sie funktioniert.

Suche stattdessen nach der Lösung mit dem besten Verhältnis aus:

* Qualität
* Benutzerfreundlichkeit
* Wartbarkeit
* visueller Wirkung
* langfristiger Skalierbarkeit

Das Ziel ist nicht: "Es funktioniert."

Das Ziel ist: "Es fühlt sich professionell an."

---

### Design als Wettbewerbsvorteil

Das Design ist kein dekorativer Zusatz.

Das Design ist ein zentraler Bestandteil des Produkts.

Jede neue Funktion muss nicht nur technisch korrekt umgesetzt werden, sondern auch:

* optisch überzeugen
* Vertrauen schaffen
* hochwertig wirken
* intuitiv nutzbar sein

Designentscheidungen sollen aktiv zur wahrgenommenen Qualität des Produkts beitragen.

---

### Design Exploration Pflicht

Bei jeder größeren UI-Änderung:

1. Mindestens drei Lösungsansätze evaluieren
2. Vor- und Nachteile bewerten
3. Beste UX auswählen
4. Beste visuelle Qualität auswählen
5. Beste langfristige Wartbarkeit auswählen

Die erste funktionierende Lösung darf nicht automatisch verwendet werden.

---

### Design-System Pflicht

Vermeide:

* uneinheitliche Buttons
* uneinheitliche Farben
* uneinheitliche Abstände
* uneinheitliche Schriftgrößen
* uneinheitliche Komponenten

Bevorzuge:

* wiederverwendbare Komponenten
* konsistente Designregeln
* klare visuelle Hierarchien
* saubere Layoutsysteme
* einheitliche Interaktionsmuster

---

### Buttons

Buttons müssen:

* klar erkennbar sein
* hochwertig wirken
* konsistente Größen verwenden
* eindeutige Hover States besitzen
* eindeutige Active States besitzen
* eindeutige Disabled States besitzen

Buttons dürfen niemals generisch oder lieblos wirken.

---

### Typografie

Typografie ist ein Kernelement des Designs.

Achte auf:

* moderne Schriftarten
* klare Lesbarkeit
* konsistente Größen
* ausreichende Kontraste
* klare Hierarchie

Vermeide typografische Unruhe.

---

### Layout

Layouts müssen:

* großzügig wirken
* ausreichend Weißraum besitzen
* logisch gruppiert sein
* auf allen Bildschirmgrößen funktionieren

Vermeide:

* überladene Oberflächen
* zu enge Abstände
* chaotische Anordnungen

---

### Animationen

Animationen sind Teil der User Experience.

Animationen dürfen nicht zufällig eingesetzt werden.

Sie müssen:

* Orientierung schaffen
* Interaktionen verdeutlichen
* Qualität vermitteln
* Modernität vermitteln
* die Anwendung lebendig wirken lassen

Bevorzuge:

* subtile Bewegungen
* sanfte Übergänge
* hochwertige Hover States
* Mikrointeraktionen
* animierte Zustandswechsel
* hochwertige Ladezustände
* elegante Seitenübergänge
* flüssige Bewegungen

Vermeide:

* aufdringliche Effekte
* unnötige Bewegungen
* visuelles Chaos

---

### Visuelle Qualität

Achte besonders auf:

* Typografie
* Weißraum
* Farbkontraste
* Hierarchie
* Lesbarkeit
* Konsistenz
* Komponentendesign

Alle Elemente müssen wie aus einem Guss wirken.

---

### Komponentenqualität

Buttons, Inputs, Modals, Tabellen, Cards und Navigationen müssen:

* hochwertig aussehen
* professionell wirken
* konsistent gestaltet sein
* moderne Interaktionsmuster verwenden
* visuelles Feedback geben

Generische Standard-UI ist nicht akzeptabel.

---

### UX Excellence

Reduziere konsequent:

* Klicks
* Reibung
* Verwirrung
* unnötige Entscheidungen
* unnötige Eingaben

Maximiere:

* Klarheit
* Geschwindigkeit
* Effizienz
* Vertrauen
* Freude bei der Nutzung

---

### Mobile Premium Experience

Mobile ist gleichwertig zu Desktop.

Keine Funktion darf sich auf Mobile wie eine abgespeckte Version anfühlen.

Die mobile Erfahrung muss denselben Qualitätsstandard erfüllen.

---

### Benchmark-Prinzip

Vergleiche wichtige Oberflächen gedanklich mit modernen Premium-Produkten.

Orientiere dich an den Qualitätsstandards führender SaaS-, Finanz-, Analyse- und Produktivitätsanwendungen.

Übernimm keine Designs direkt.

Übernimm die Qualitätsansprüche.

---

### Liebe zum Detail

Achte auf Details.

Dazu gehören insbesondere:

* perfekte Abstände
* visuelle Balance
* konsistente Komponenten
* hochwertige Hover States
* saubere Übergänge
* sinnvolle Animationen
* präzise Typografie
* hochwertige Ladezustände
* klare Fehlermeldungen
* durchdachte Micro-Interactions

Kleine Details summieren sich zur wahrgenommenen Produktqualität.

---

### Finale Qualitätsfrage

Vor Abschluss jeder UI-Änderung beantworten:

* Würde diese Oberfläche in einem professionellen SaaS-Produkt bestehen?
* Würde sie in einem Design-Showcase positiv auffallen?
* Wirkt sie modern?
* Wirkt sie hochwertig?
* Wirkt sie vertrauenswürdig?
* Wirkt sie professionell?
* Würde ein zahlender Kunde sie als hochwertig wahrnehmen?

Falls nicht: weiter verbessern.

---

### Goldener Standard

Die Anwendung soll nicht wirken, als wäre sie von einer KI generiert worden.

Sie soll wirken, als hätte ein erfahrenes Team aus:

* Senior Product Designern
* UX Spezialisten
* Frontend Engineers
* Produktmanagern

mehrere Iterationen investiert, um das bestmögliche Ergebnis zu erzielen.

Jede neue Oberfläche soll dieses Niveau anstreben.

---

### Endziel

Das Projekt soll nicht wie ein funktionierendes Tool wirken.

Es soll wie ein professionelles, kommerzielles Premium-Produkt wirken.

Jede Entscheidung soll dazu beitragen, die Anwendung visuell, funktional und emotional auf ein möglichst hohes Niveau zu bringen.

Wenn mehrere technisch gleichwertige Lösungen existieren, bevorzuge immer die Lösung mit der besseren User Experience, höheren visuellen Qualität, professionelleren Außenwirkung und höheren wahrgenommenen Produktqualität.

---

## 11. AI-FIRST ARCHITECTURE & INTELLIGENCE LAYER

> **Übergeordnete Kostenregel (gilt für ALLES in diesem Abschnitt):**
> KI ist mächtig, aber nicht gratis. **Jeder API-Aufruf kostet Tokens und damit echtes Geld.**
> KI wird **nur dort eingesetzt, wo sie echten, spürbaren Mehrwert liefert** — niemals dekorativ, niemals "weil man es kann".
> Die **Token-/API-Kosten sind bei jeder KI-Nutzung maximal zu berücksichtigen — spare ein, wo immer möglich**, ohne die Ergebnisqualität an den Stellen zu opfern, an denen KI echten Nutzen bringt.
> AI-First heißt **intelligent-first**, nicht **teuer-first**: die beste Lösung ist die, die mit minimalen Tokens maximalen Nutzen erzeugt.

### Grundprinzip

Diese Anwendung ist konsequent AI-First.

Künstliche Intelligenz ist kein optionales Zusatzfeature und kein nachträglicher Komfortlayer.

KI ist ein zentraler Bestandteil der Produktarchitektur, der Produktlogik, der Nutzererfahrung und der Wertschöpfung der Anwendung.

Die Anwendung soll nicht nur Daten speichern, anzeigen oder verwalten.

Sie soll Daten verstehen, interpretieren, bewerten, verdichten, personalisieren und in konkrete, relevante Erkenntnisse, Empfehlungen und nächste Schritte übersetzen.

Überall dort, wo KI echten Mehrwert liefern kann, ist KI aktiv und bevorzugt einzusetzen — **stets unter maximaler Beachtung der Token-/API-Kosten (siehe Kostenregel oben).**

---

### Verbindliche Entscheidungsregel

Bei jeder neuen Funktion, jedem neuen Modul, jeder Auswertung, jedem UI-Bereich, jeder Nutzerinteraktion und jeder Produktentscheidung ist zuerst zu prüfen:

- Kann KI diese Funktion intelligenter machen?
- Kann KI hier Erkenntnisse statt nur Rohdaten liefern?
- Kann KI hier Personalisierung ermöglichen?
- Kann KI hier Kontext verstehen statt starre Regeln auszuführen?
- Kann KI hier bessere Empfehlungen, Bewertungen oder Erklärungen erzeugen?
- Kann KI hier manuelle Interpretation, starre Logik oder statische Inhalte ersetzen?

Wenn die Antwort **ja** ist, dann ist eine KI-basierte oder KI-gestützte Lösung **bevorzugt umzusetzen** — sofern der Nutzen die Token-/API-Kosten rechtfertigt.

Nicht zuerst hardcoden und später KI ergänzen.

Zuerst prüfen, ob KI die bessere Architekturentscheidung ist.

**Gegenfrage immer mitstellen:** Rechtfertigt der Mehrwert die Tokenkosten? Lässt sich derselbe Nutzen mit weniger/kürzerem Kontext, kleinerem Modell, Caching oder seltenerem Aufruf erreichen? Wenn ja, ist die sparsamere Variante zu wählen.

---

### AI vor Hardcoding

Bevor Regeln, Inhalte, Hinweise, Bewertungen oder Auswertungen fest implementiert werden, ist immer zu prüfen, ob diese durch KI besser, flexibler, personalisierter und kontextbezogener erzeugt werden können.

Dies gilt insbesondere für:

- Analysen
- Bewertungen
- Empfehlungen
- Erklärungen
- Hinweise
- Zusammenfassungen
- Motivation
- Coaching
- Interpretationen
- Mustererkennung
- Verhaltensanalysen
- Trendanalysen
- Priorisierungen
- Optimierungsvorschläge
- Nutzerfeedback
- kontextbezogene UI-Inhalte

Starre Logik ist nur dann zu bevorzugen, wenn:

- deterministisches Verhalten zwingend notwendig ist
- rechtliche, sicherheitsrelevante oder compliancekritische Vorgaben dies erfordern
- die KI an dieser Stelle keinen echten Mehrwert schafft
- eine feste Business-Regel technisch oder fachlich zwingend ist
- **eine deterministische/lokale Berechnung dasselbe Ergebnis ohne Tokenkosten liefert** (dann ist die kostenfreie Lösung Pflicht — z. B. Streak, XP, Level, Skill-Score bleiben pure Domain-Logik, kein KI-Call)

In allen anderen Fällen gilt:

**dynamisch, intelligent, datenbasiert und KI-gestützt vor statisch und hart codiert — bei gleichzeitig sparsamstem Tokeneinsatz.**

---

### Rolle der KI im Produkt

Die KI ist die zentrale Intelligenzschicht der Anwendung.

Sie soll nicht nur Texte erzeugen, sondern aktiv Bedeutung aus Daten ableiten und den Nutzer intelligent unterstützen.

Die KI darf und soll verwendet werden für:

- Analysen
- Bewertungen
- Interpretationen
- Empfehlungen
- Zusammenfassungen
- Coaching
- Motivation
- Personalisierung
- Mustererkennung
- Verhaltensanalyse
- Trendanalyse
- Stärken-/Schwächen-Erkennung
- Risikoerkennung
- Priorisierung
- Entscheidungsunterstützung
- Optimierungsvorschläge
- nächste sinnvolle Schritte
- kontextbezogene Hilfestellung
- domänenspezifische Erkenntnisse

Die KI ist damit nicht Dekoration, sondern ein aktiver funktionaler Bestandteil des Produkts.

---

### Dynamische Inhalte statt statischer Inhalte

Wo immer sinnvoll, sind statische Inhalte zu vermeiden.

Vermeide insbesondere:

- fest codierte Tipps
- fest codierte Empfehlungen
- fest codierte Analysen
- fest codierte Erklärungen
- fest codierte Motivationssprüche
- fest codierte Coaching-Inhalte
- generische Standardhinweise ohne Datenbezug
- starre Textbausteine für komplexe Einschätzungen

Bevorzuge stattdessen:

- dynamisch generierte Inhalte
- datenbasierte Inhalte
- kontextabhängige Inhalte
- nutzerspezifische Inhalte
- verlaufsbezogene Inhalte
- situationsabhängige Inhalte
- priorisierte Inhalte auf Basis realer Signale
- adaptive Inhalte abhängig vom Verhalten, Zustand und Verlauf

Die Anwendung soll Inhalte nicht einfach anzeigen.

Sie soll relevante Inhalte intelligent erzeugen.

**Kostenbewusst dabei:** dynamische KI-Inhalte werden nur (neu) generiert, wenn sich die zugrunde liegenden Daten relevant geändert haben. Ergebnisse werden zwischengespeichert (cachen) und wiederverwendet, statt bei jedem Screen-Aufbau erneut die API zu rufen.

---

### Daten verstehen statt nur anzeigen

Die Anwendung darf Daten nicht nur speichern, tabellarisch anzeigen oder visualisieren.

Die KI soll vorhandene Daten aktiv interpretieren und daraus verwertbare Erkenntnisse ableiten.

Dazu gehören insbesondere:

- Auffälligkeiten erkennen
- Muster erkennen
- Trends erkennen
- Entwicklungen bewerten
- Zusammenhänge herstellen
- Stärken und Schwächen identifizieren
- Verbesserungspotenziale erkennen
- Risiken sichtbar machen
- Ursachen vermuten und begründen
- sinnvolle nächste Schritte empfehlen
- komplexe Daten verständlich erklären

Das Produkt soll nicht bei Zahlen enden.

Es soll ihre Bedeutung liefern.

**Kostenbewusst dabei:** der KI wird verdichteter, vorab aggregierter Kontext übergeben (z. B. fertige Aggregate/Trends aus SQL, nicht die rohe Session-Historie). Vor-Aggregation in der Domain spart Tokens und verbessert die Antwortqualität.

---

### Explainability als Standard

Jede wichtige KI-Aussage soll nachvollziehbar, begründet und verständlich sein.

Wenn möglich, soll die KI zusätzlich angeben:

- auf welche Daten sie sich stützt
- welche Kennzahlen relevant waren
- welche Muster erkannt wurden
- warum eine bestimmte Einschätzung entsteht
- welche Faktoren die Bewertung beeinflussen
- welche Unsicherheiten oder Datenlücken bestehen

Die KI soll nicht nur Antworten liefern.

Sie soll ihre Einschätzung transparent machen.

Explainability ist kein optionales Extra, sondern Qualitätsstandard.

---

### Personalisierung als Kernanforderung

Antworten, Einschätzungen, Empfehlungen und Coaching-Inhalte sollen möglichst auf Basis individueller Nutzerdaten entstehen.

Generische Standardantworten sind zu vermeiden, sobald nutzerbezogene Daten, Verlauf, Kontext oder Verhalten verfügbar sind.

Bevorzuge:

- personalisierte Antworten
- kontextbezogene Analysen
- verlaufsbezogene Bewertungen
- datenbasierte Priorisierung
- individualisierte Empfehlungen
- adaptive Feedback-Logik
- auf den aktuellen Zustand des Nutzers zugeschnittene Inhalte

Die Anwendung soll den Nutzer nicht allgemein ansprechen.

Sie soll den konkreten Nutzer in seiner konkreten Situation verstehen.

---

### Psychologie- und Coaching-Layer

Die KI darf und soll psychologische Unterstützung im Rahmen des Produktzwecks bereitstellen, sofern dies sinnvoll ist.

Mögliche Anwendungsfelder:

- Motivation
- Fokus
- Selbstreflexion
- Routinen
- Gewohnheiten
- mentale Stärke
- Disziplin
- Verhaltensanalyse
- Frustrationsmuster
- Leistungsblockaden
- Selbststeuerung
- Konsequenz und Umsetzung

Diese Inhalte dürfen nicht generisch oder oberflächlich sein.

Sie sollen:

- personalisiert
- datenbasiert
- situationsabhängig
- verständlich
- konkret
- hilfreich
- handlungsorientiert

sein.

Die KI soll nicht nur beschreiben, sondern gezielt unterstützen.

---

### Domänenspezifische Intelligenz

Die KI soll domänenspezifische Muster, Bewertungen und Empfehlungen aus realen Nutzerdaten ableiten.

#### Beispiel: Tennis-App

Die KI soll anhand vorhandener Daten eigenständig:

- Spielmuster erkennen
- Leistung bewerten
- Stärken identifizieren
- Schwächen identifizieren
- mentale Muster erkennen
- Verbesserungspotenziale erkennen
- Trainingsschwerpunkte empfehlen
- Matchanalysen erzeugen
- psychologische Hinweise liefern
- motivierende Hinweise liefern
- konkrete Trainingsimpulse ableiten

Diese Inhalte dürfen nicht starr hinterlegt sein.

Sie sollen aus echten Nutzerdaten, echten Verläufen und echten Mustern entstehen.

#### Beispiel: Trading Journal

Die KI soll anhand vorhandener Trading-Daten eigenständig:

- Verhaltensmuster erkennen
- Fehler analysieren
- emotionale Muster erkennen
- Risikoverhalten bewerten
- Disziplin bewerten
- Stärken identifizieren
- Schwächen identifizieren
- Coaching-Feedback erzeugen
- Verbesserungsmöglichkeiten priorisieren
- Zusammenfassungen erstellen
- konkrete nächste Verhaltensverbesserungen empfehlen

Diese Erkenntnisse sollen datenbasiert und intelligent entstehen, nicht primär aus starren Regeln.

---

### API-First AI Architecture

Alle KI-Funktionen müssen über eine zentrale AI/API-Schicht laufen.

Vermeide ausdrücklich:

- verstreute KI-Logik im Frontend
- direkt in UI-Komponenten eingebettete Modellaufrufe
- doppelte oder inkonsistente Prompt-Definitionen
- unstrukturierte KI-Nutzung an vielen Stellen
- providerabhängige KI-Logik tief im Produktcode
- schwer austauschbare Modellkopplungen

Die Architektur muss so aufgebaut sein, dass:

- Modelle austauschbar bleiben
- KI-Provider austauschbar bleiben
- Prompts zentral verwaltet werden
- Prompt-Versionen kontrollierbar sind
- Kontexte zentral aufgebaut werden
- Logging und Monitoring zentral möglich sind
- AI-Features testbar und erweiterbar bleiben
- zukünftige Erweiterungen einfach integriert werden können
- KI-Funktionalität nicht an einzelne UI-Elemente gebunden ist

Die KI gehört in eine zentrale, kontrollierte Intelligenzschicht.

Nicht verteilt und unkoordiniert in die Oberfläche.

**Kostensteuerung gehört in genau diese zentrale Schicht** — sie ist die einzige Stelle, an der Tokenverbrauch kontrolliert, gemessen und optimiert werden kann. Dort verbindlich:

- **Modellwahl nach Aufgabe:** das kleinste/günstigste Modell, das die Aufgabe gut löst (z. B. Haiku für einfache Klassifikation/Zusammenfassung, größeres Modell nur für echte Analysetiefe). Nicht pauschal das teuerste Modell.
- **Prompt-Caching** für stabile System-/Kontextanteile nutzen, um wiederholte Eingabe-Tokens zu sparen.
- **Kontext minimieren:** nur die wirklich relevanten, vorab aggregierten Daten übergeben — keine rohen, ungefilterten Datenmengen.
- **Output begrenzen:** `max_tokens` und strukturierte, knappe Ausgaben statt unnötig langer Freitexte.
- **Ergebnisse cachen & wiederverwenden;** Re-Generierung nur bei relevanter Datenänderung, nicht bei jedem Rebuild/Screen-Aufruf.
- **Aufrufe bündeln/entprellen** statt viele kleine Calls; redundante Aufrufe vermeiden.
- **Tokenverbrauch zentral loggen/monitoren**, um teure Pfade sichtbar zu machen und gezielt zu optimieren.

---

### Qualitätsanforderungen an KI-Ausgaben

Jede KI-Ausgabe soll nach Möglichkeit folgende Eigenschaften erfüllen:

- relevant
- datenbasiert
- kontextbezogen
- personalisiert
- verständlich
- begründet
- strukturiert
- nützlich
- umsetzbar
- konsistent
- priorisiert
- fachlich sinnvoll

Wenn keine ausreichende Datenbasis vorhanden ist, soll die KI dies transparent machen.

Keine künstliche Sicherheit vortäuschen.

Keine leeren Phrasen.

Keine generischen Fülltexte.

Keine unbegründeten Aussagen.

Lieber klare Einschränkung als scheinpräzise Beliebigkeit.

**Kostenbewusst dabei:** kurz, strukturiert und umsetzbar schlägt lang und ausschweifend — knappe, dichte Ausgaben sind nicht nur bessere UX, sondern sparen auch Output-Tokens.

---

### Zukunftsregel für neue Features

Jedes neue Feature ist aktiv darauf zu prüfen, ob KI den Nutzen erhöhen kann.

Pflichtfragen bei jeder Erweiterung:

- Kann KI hier Erkenntnisse liefern?
- Kann KI hier Personalisierung ermöglichen?
- Kann KI hier Kontext verstehen?
- Kann KI hier dynamische Inhalte erzeugen?
- Kann KI hier manuelle Interpretation reduzieren?
- Kann KI hier Coaching, Bewertung oder Handlungsempfehlungen liefern?
- Kann KI hier den Nutzer wirksamer begleiten?
- Kann KI hier aus Daten echten Mehrwert erzeugen?
- **Rechtfertigt der erwartete Mehrwert die Token-/API-Kosten — und ist es der sparsamste Weg, ihn zu erreichen?**

Wenn ja, muss KI in Konzeption, Datenmodell, Architektur und UX aktiv berücksichtigt werden.

KI darf nicht nachträglich „aufgesetzt" werden.

Sie ist von Anfang an mitzudenken — **und ebenso von Anfang an kostenbewusst zu dimensionieren.**

---

### Zielbild

Die Anwendung soll nicht nur Informationen verwalten.

Die Anwendung soll Informationen verstehen.

Die Anwendung soll nicht nur Daten sammeln.

Die Anwendung soll aus Daten Erkenntnisse erzeugen.

Die Anwendung soll nicht nur berichten, was passiert ist.

Die Anwendung soll erklären, warum es passiert ist, was es bedeutet und was als Nächstes sinnvoll ist.

Die Anwendung soll den Nutzer aktiv unterstützen, coachen, analysieren, begleiten und verbessern.

Die KI ist dabei die zentrale Analyse-, Bewertungs-, Coaching-, Personalisierungs- und Intelligenzschicht des Produkts — **eingesetzt mit Augenmaß, nur wo sie echten Mehrwert schafft, und stets so token- und kostensparend wie möglich.**

---

## 12. Research-Driven Growth, Usability, Adoption & Ethical Retention

For every feature, flow, screen, component, onboarding step, form, dashboard, CTA, empty state, notification, settings page, landing page, pricing interaction, activation mechanic, and retention decision, always research and apply current, evidence-based usability, UX, and behavioral-design best practices from reputable web sources.

Use reputable sources such as:

- Nielsen Norman Group (NN/g)
- Material Design / Google Design
- Baymard Institute
- GOV.UK Design System / Service Manual
- WCAG / W3C
- official behavioral-science sources
- academic or highly credible UX / psychology resources

Primary objective:
Design the product so that it reaches, converts, activates, satisfies, and retains as many users as possible through excellent usability, clarity, speed, usefulness, accessibility, and trust.

Always optimize for:

- maximum discoverability
- maximum clarity
- minimum friction
- fastest possible time-to-value
- strongest first-use experience
- highest onboarding completion
- highest activation rate
- highest repeat usage
- highest feature adoption
- strongest sustainable retention
- high trust and perceived product quality
- excellent mobile usability
- excellent accessibility

Always think across the full product lifecycle:

1. acquisition
2. first impression
3. onboarding
4. activation
5. first success / first value moment
6. repeat value
7. habit formation through genuine usefulness
8. retention
9. deeper feature adoption
10. referral / advocacy

For every task, feature, or UX decision, identify:

- the user's core goal
- the fastest path to value
- likely confusion points
- likely friction points
- likely abandonment points
- moments where motivation drops
- moments where trust can increase
- opportunities to create momentum and confidence

Then improve the experience using proven usability and psychology principles such as:

- visibility of system status
- immediate and clear feedback
- real-world language and familiar mental models
- recognition rather than recall
- progressive disclosure
- strong visual hierarchy
- scannable layouts
- clear information scent
- obvious next actions
- sensible defaults
- low-friction input patterns
- reduced cognitive load
- fewer unnecessary choices
- error prevention
- easy recovery and undo
- contextual guidance
- meaningful empty states
- visible progress and progress reinforcement
- confidence-building interactions
- useful product education in context

When optimizing for growth, activation, and retention, use ethical behavioral design:

- reduce effort required for meaningful actions
- make the value of the next step obvious
- place prompts at the right moment
- reinforce successful actions with immediate feedback
- use progress, completion, micro-wins, and momentum to keep users moving
- help users reach their first meaningful outcome as fast as possible
- create repeat-usage loops around real user benefit
- increase autonomy, competence, confidence, and trust
- make the product rewarding because it is useful, fast, clear, and satisfying

Always look for opportunities to improve:

- signup conversion
- onboarding completion
- activation rate
- time to first value
- task success rate
- feature discoverability
- repeat sessions
- user retention
- user satisfaction
- trust
- perceived quality
- referral likelihood
- support-ticket reduction
- mobile completion rate

For every UX recommendation, briefly explain:

1. which user problem, friction point, or growth bottleneck it solves
2. which usability principle it improves
3. which psychological or behavioral mechanism it uses
4. how it increases conversion, activation, retention, satisfaction, or trust
5. why it is ethical and user-beneficial

Always prefer:

- shorter paths to value
- less confusion
- less user effort
- clearer decisions
- stronger guidance
- cleaner interfaces
- better mobile ergonomics
- higher accessibility
- more visible outcomes
- more confidence-building interactions
- contextual help instead of overload
- sustainable retention through genuine product value

When uncertainty exists:

- do not guess blindly
- search for evidence
- state the hypothesis clearly
- propose an experiment or A/B test
- define measurable success metrics
- recommend the highest-upside option with the lowest unnecessary friction

Hard rules:

- Do not output generic UX advice.
- Output concrete, modern, product-specific recommendations tailored to the exact audience, use case, device context, and business goal.
- Do not preserve mediocre UX if a significantly better version is possible.
- Think like a top-tier product designer, UX researcher, conversion optimizer, and behavioral design strategist at the same time.

Ethics guardrail:
Never use dark patterns, deception, coercion, fake urgency, fake scarcity, misleading countdowns, hidden costs, forced continuity, hard-to-cancel flows, manipulative consent, misleading nudges, confirmshaming, or intentionally harmful addiction mechanics.
Optimize for long-term trust, user benefit, product quality, and sustainable retention.
