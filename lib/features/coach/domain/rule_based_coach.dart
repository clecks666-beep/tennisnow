import '../../../shared/domain/skill/skill_catalog.dart';
import 'coach_context.dart';
import 'coach_insight.dart';

/// The deterministic, offline, zero-token coach (CLAUDE.md §6 offline-first, §11
/// cost rule: don't spend tokens where local logic gives the same honest value).
///
/// It is the always-available fallback behind the AI coach: it reads the same
/// pre-aggregated [CoachContext] an LLM would, and produces an honest,
/// data-grounded [CoachInsight] — never inventing claims the numbers don't
/// support (§11 honesty / §7). When a live model is wired in, it speaks only
/// when reachable and falls back to this; the player always gets a read.
class RuleBasedCoach {
  RuleBasedCoach._();

  static CoachInsight insight(CoachContext ctx) {
    if (ctx.isEmpty) {
      return const CoachInsight(
        headline: 'Your game starts with one session',
        body: 'Log your first match or practice and your coach starts reading '
            'your form, your streak and the skills to work on next.',
        source: CoachSource.rule,
      );
    }

    return CoachInsight(
      headline: _headline(ctx),
      body: _body(ctx),
      basis: _basis(ctx),
      focusSkillId: ctx.weakestSkill?.skillId,
      source: CoachSource.rule,
    );
  }

  static String _headline(CoachContext ctx) {
    if (ctx.streakCurrent >= 3) {
      return '${ctx.streakCurrent}-day streak — consistency is becoming your edge.';
    }
    final winRate = ctx.winRate;
    if (winRate != null && ctx.ratedMatchCount >= 3) {
      final pct = (winRate * 100).round();
      return "You're winning $pct% of your matches right now.";
    }
    final avg = ctx.avgPerformance;
    if (avg != null) {
      return "You're playing around ${avg.toStringAsFixed(1)}/5 lately.";
    }
    final n = ctx.totalSessions;
    return "$n ${n == 1 ? 'session' : 'sessions'} in — you're building a base.";
  }

  static String _body(CoachContext ctx) {
    final parts = <String>[];

    // Direction of form — only when there's enough signal to be honest.
    final delta = ctx.performanceTrendDelta;
    if (delta != null && delta >= 0.5) {
      parts.add('Your recent sessions are trending up.');
    } else if (delta != null && delta <= -0.5) {
      parts.add('Your last few sessions dipped a little — a focused, '
          'low-pressure session is a good reset.');
    }

    // The human side (CLAUDE.md pillar 2) — only when notably low.
    if (ctx.avgEnergy != null && ctx.avgEnergy! < 2.5) {
      parts.add('Your energy has been low lately; rest may matter as much as reps.');
    } else if (ctx.avgMood != null && ctx.avgMood! < 2.5) {
      parts.add('Mood has dipped — keep sessions light and fun for a bit.');
    }

    // The concrete next step.
    final weak = ctx.weakestSkill;
    if (weak != null) {
      final name = SkillCatalog.byId(weak.skillId)?.name ?? 'a weaker skill';
      parts.add("Next time, put a little focus on your $name — it's your "
          'lowest-rated skill right now.');
    } else {
      parts.add('Tag the skills you work on after a session to unlock a '
          'sharper, skill-by-skill read of your game.');
    }

    return parts.join(' ');
  }

  static List<String> _basis(CoachContext ctx) {
    final basis = <String>[];
    final n = ctx.totalSessions;
    basis.add("$n ${n == 1 ? 'session' : 'sessions'}");

    final winRate = ctx.winRate;
    if (winRate != null && ctx.ratedMatchCount >= 3) {
      basis.add('win rate ${(winRate * 100).round()}%');
    }
    if (ctx.streakCurrent >= 3) {
      basis.add('${ctx.streakCurrent}-day streak');
    }
    final weak = ctx.weakestSkill;
    if (weak != null) {
      final name = SkillCatalog.byId(weak.skillId)?.name;
      if (name != null) basis.add('lowest: $name');
    }
    return basis;
  }
}
