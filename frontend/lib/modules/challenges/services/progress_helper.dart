// lib/modules/challenges/services/progress_helper.dart
import '../models/challenge.dart';

double _levelAbsolute(LevelDef level, Map<String, dynamic> userProfile) {
  if (level.target != null) return level.target!;
  if (level.targetMultiplier != null) {
    final bw = (userProfile['bodyWeightKg'] as num?)?.toDouble() ?? 0.0;
    return level.targetMultiplier! * bw;
  }
  return 0.0;
}

/// progressPercent 0..100 relative to highest level (diamond)
double computeProgressForUserPercent(Challenge ch, Map<String, dynamic> userProfile) {
  if (ch.levels.isEmpty) {
    // fallback to legacy target/current (assume single value)
    if (ch.target.isNotEmpty && ch.current.isNotEmpty) {
      final t = (ch.target.values.first as num?)?.toDouble() ?? 1.0;
      final c = (ch.current.values.first as num?)?.toDouble() ?? 0.0;
      if (t == 0) return 0.0;
      return ((c / t) * 100.0).clamp(0.0, 100.0);
    }
    return 0.0;
  }

  final highest = ch.levels.last;
  final highestAbs = _levelAbsolute(highest, userProfile);
  if (highestAbs == 0) return 0.0;

  // current mapping
  double userCurrent = 0.0;
  // check typical ids and profile fields
  if (ch.id.contains('bench')) {
    userCurrent = (userProfile['maxBenchKg'] as num?)?.toDouble() ?? 0.0;
  } else if (ch.id.contains('squat')) {
    userCurrent = (userProfile['maxSquatKg'] as num?)?.toDouble() ?? 0.0;
  } else if (ch.id.contains('deadlift')) {
    userCurrent = (userProfile['maxDeadliftKg'] as num?)?.toDouble() ?? 0.0;
  } else if (ch.id.contains('ohp')) {
    userCurrent = (userProfile['maxOHPKg'] as num?)?.toDouble() ?? 0.0;
  } else if (ch.id.contains('pushup') || ch.id.contains('pushups')) {
    userCurrent = (userProfile['totalPushups'] as num?)?.toDouble() ?? 0.0;
  } else {
    userCurrent = (userProfile['max'] as num?)?.toDouble() ?? 0.0;
  }

  final p = (userCurrent / highestAbs) * 100.0;
  return p.clamp(0.0, 100.0);
}

List<double> computeMarkersPercent(Challenge ch, Map<String, dynamic> userProfile) {
  if (ch.levels.isEmpty) {
    return ch.target.isNotEmpty
        ? [((ch.target.values.first as num?)?.toDouble() ?? 0.0)]
        : [];
  }
  final highestAbs = _levelAbsolute(ch.levels.last, userProfile);
  if (highestAbs == 0) {
    return ch.levels.map((_) => 0.0).toList();
  }
  return ch.levels.map((l) {
    final abs = _levelAbsolute(l, userProfile);
    return ((abs / highestAbs) * 100.0).clamp(0.0, 100.0);
  }).toList();
}
