// lib/services/achievement_service.dart
import 'package:wkmobile/modules/challenges/models/challenge.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  static AchievementService get instance => _instance;

  final Map<String, int> _userMedals = {
    'bronze': 0,
    'silver': 0,
    'gold': 0,
    'diamond': 0,
  };

  Map<String, int> get userMedals => Map.from(_userMedals);

  int get totalMedals => _userMedals.values.reduce((a, b) => a + b);

  void unlockMedal(String challengeId, String medalType) {
    if (medalType != 'none') {
      _userMedals[medalType] = (_userMedals[medalType] ?? 0) + 1;
      print('🎖️ Odblokowano medal: $medalType za wyzwanie $challengeId');
      _printMedalStats();
    }
  }

  void _printMedalStats() {
    print('📊 Statystyki medali:');
    _userMedals.forEach((type, count) {
      print('   $type: $count');
    });
    print('   Łącznie: $totalMedals medali');
  }

  String getMedalIcon(String medalType) {
    switch (medalType) {
      case 'bronze': return '🥉';
      case 'silver': return '🥈';
      case 'gold': return '🥇';
      case 'diamond': return '💎';
      default: return '🏆';
    }
  }

  String getMedalName(String medalType) {
    switch (medalType) {
      case 'bronze': return 'Brązowy';
      case 'silver': return 'Srebrny';
      case 'gold': return 'Złoty';
      case 'diamond': return 'Diamentowy';
      default: return 'Medal';
    }
  }
}