// lib/modules/challenges/screens/challenge_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../services/progress_service.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  final ProgressService _service = ProgressService();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    try {
      await _service.initialize();
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Błąd ładowania wyzwań: $e');
      setState(() {
        _error = 'Błąd ładowania danych';
        _loading = false;
      });
    }
  }

  void _openDetail(Challenge ch) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(ch.title),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: _buildChallengeDetail(ch),
        ),
      ),
    );
  }

  Widget _buildChallengeDetail(Challenge ch) {
    final currentLevel = ch.currentLevel;
    final medalColor = _getMedalColor(ch.currentTier);
    final dynamicDifficulty = ch.dynamicDifficulty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: medalColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: medalColor, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      _getMedalIcon(ch.currentTier),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ch.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${currentLevel.tier.displayName} medal • ${ch.currentTarget.toStringAsFixed(0)} ${ch.unit}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(dynamicDifficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getDifficultyColor(dynamicDifficulty)),
                  ),
                  child: Text(
                    'Poziom: $dynamicDifficulty',
                    style: TextStyle(
                      color: _getDifficultyColor(dynamicDifficulty),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            ch.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          const Text(
            'Twój postęp:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ch.progress,
            backgroundColor: Colors.grey[300],
            color: ch.progress > 0 ? medalColor : Colors.grey[400],
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ch.currentProgressValue.toStringAsFixed(0)}/${ch.currentTarget.toStringAsFixed(0)} ${ch.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(ch.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: ch.progress > 0 ? medalColor : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Poziomy wyzwania:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...ch.levels.map((level) => _buildLevelTile(level, ch)).toList(),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'To wyzwanie jest zawsze aktywne. System automatycznie śledzi Twój progres!',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zamknij'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTile(ChallengeLevel level, Challenge challenge) {
    final isCurrent = level.tier == challenge.currentTier;
    final isCompleted = level.isCompleted;
    final medalColor = _getMedalColor(level.tier);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isCurrent ? medalColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: medalColor),
          ),
          child: Center(
            child: Text(
              _getMedalIcon(level.tier),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        title: Text(
          '${level.tier.displayName} medal',
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? medalColor : null,
          ),
        ),
        subtitle: Text(level.description),
        trailing: isCompleted
            ? Icon(Icons.check_circle, color: Colors.green)
            : isCurrent
            ? Icon(Icons.radio_button_checked, color: medalColor)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey),
      ),
    );
  }

  void _retryLoadData() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _initAll();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Consumer<ProgressService>(
        builder: (context, service, child) {
          if (_loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Ładowanie wyzwań...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (_error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryLoadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }

          final challenges = service.challenges;

          return challenges.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Brak dostępnych wyzwań',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: challenges.length,
            itemBuilder: (ctx, idx) {
              final ch = challenges[idx];
              return _buildChallengeCard(ch);
            },
          );
        },
      ),
    );
  }

  Widget _buildChallengeCard(Challenge ch) {
    final currentLevel = ch.currentLevel;
    final medalColor = _getMedalColor(ch.currentTier);
    final dynamicDifficulty = ch.dynamicDifficulty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: medalColor, width: 2),
          ),
          child: Center(
            child: Text(
              _getMedalIcon(ch.currentTier),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ch.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${currentLevel.tier.displayName} medal • ${ch.currentTarget.toStringAsFixed(0)} ${ch.unit}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: _getDifficultyColor(dynamicDifficulty)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    dynamicDifficulty,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDifficultyColor(dynamicDifficulty),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // PASEK POSTĘPU - ZAWSZE WIDOCZNY
            LinearProgressIndicator(
              value: ch.progress,
              backgroundColor: Colors.grey[300],
              color: ch.progress > 0 ? medalColor : Colors.grey[400],
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '${ch.currentProgressValue.toStringAsFixed(0)}/${ch.currentTarget.toStringAsFixed(0)} ${ch.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(ch.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: ch.progress > 0 ? medalColor : Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (ch.canLevelUp) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward, size: 12, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Gotowy do awansu!',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: medalColor),
          ),
          child: Text(
            dynamicDifficulty,
            style: TextStyle(
              fontSize: 12,
              color: medalColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _openDetail(ch),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Color _getMedalColor(MedalTier tier) {
    switch (tier) {
      case MedalTier.bronze:
        return const Color(0xFFCD7F32);
      case MedalTier.silver:
        return const Color(0xFFC0C0C0);
      case MedalTier.gold:
        return const Color(0xFFFFD700);
      case MedalTier.diamond:
        return const Color(0xFFB9F2FF);
      default:
        return Colors.grey;
    }
  }

  String _getMedalIcon(MedalTier tier) {
    switch (tier) {
      case MedalTier.bronze:
        return '🥉';
      case MedalTier.silver:
        return '🥈';
      case MedalTier.gold:
        return '🥇';
      case MedalTier.diamond:
        return '💎';
      default:
        return '🏆';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'bardzo łatwy':
        return Colors.green;
      case 'łatwy':
        return Colors.lightGreen;
      case 'średni':
        return Colors.orange;
      case 'trudny':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _enumToString(dynamic enumValue) {
    final string = enumValue.toString().split('.').last;
    switch (string) {
      case 'proficiency':
        return 'Zaawansowanie';
      case 'specialization':
        return 'Specjalizacja';
      case 'streak':
        return 'Ciąg';
      case 'activity':
        return 'Aktywność';
      case 'exercise':
        return 'Ćwiczenie';
      case 'endurance':
        return 'Wytrzymałość';
      case 'strength':
        return 'Siła';
      case 'volume':
        return 'Objętość';
      case 'consistency':
        return 'Konsekwencja';
      case 'variety':
        return 'Różnorodność';
      case 'bodyweight':
        return 'Ćwiczenia z ciężarem ciała';
      default:
        return string;
    }
  }
}