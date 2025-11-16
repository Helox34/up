// lib/modules/challenges/screens/challenge_list_screen.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../widgets/challenge_card.dart';
import 'package:wkmobile/services/progress_service.dart';
import 'package:wkmobile/services/achievement_service.dart';
import 'challenge_detail_screen.dart';

class ChallengeListScreen extends StatefulWidget {
  final Color primary;
  final Color muted;

  const ChallengeListScreen({Key? key, required this.primary, required this.muted}) : super(key: key);

  @override
  _ChallengeListScreenState createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  final ProgressService _service = ProgressService.instance;
  final AchievementService _achievementService = AchievementService.instance;
  List<Challenge> _filteredChallenges = [];
  ChallengeCategory? _selectedCategory;
  bool _showJoinedOnly = false;
  bool _showUnlockedOnly = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.initializeChallenges();
    setState(() {
      _filteredChallenges = _service.unlockedChallenges;
      _loading = false;
    });
  }

  void _filterChallenges(ChallengeCategory? category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _toggleShowJoined() {
    setState(() {
      _showJoinedOnly = !_showJoinedOnly;
      _applyFilters();
    });
  }

  void _toggleShowUnlocked() {
    setState(() {
      _showUnlockedOnly = !_showUnlockedOnly;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = _service.challenges;

    // Filtruj po odblokowaniu
    if (_showUnlockedOnly) {
      filtered = filtered.where((c) => c.isUnlocked).toList();
    }

    // Filtruj po dołączeniu
    if (_showJoinedOnly) {
      filtered = filtered.where((c) => c.isJoined).toList();
    }

    // Filtruj po kategorii
    if (_selectedCategory != null) {
      filtered = filtered.where((c) => c.category == _selectedCategory).toList();
    }

    setState(() {
      _filteredChallenges = filtered;
    });
  }

  void _openDetail(Challenge c) async {
    final updated = await Navigator.of(context).push<Challenge>(
      MaterialPageRoute(builder: (_) => ChallengeDetailScreen(challenge: c, primary: widget.primary)),
    );
    if (updated != null) {
      setState(() {
        _filteredChallenges = _service.getChallengesByCategory(_selectedCategory);
      });
    }
  }

  void _joinChallenge(Challenge c) {
    _service.joinChallenge(c.id);
    setState(() {
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dołączyłeś do wyzwania: ${c.title}')),
    );
  }

  void _completeChallenge(Challenge c) {
    _service.completeChallenge(c.id);
    setState(() {
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ukończyłeś wyzwanie: ${c.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final stats = _service.getStats();
    final userStats = _service.getUserStats();
    final medals = _achievementService.userMedals;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Banner z statystykami
            _buildStatsBanner(stats, userStats, medals),

            // Filtry
            _buildFilters(),

            // Lista wyzwań
            Expanded(
              child: _filteredChallenges.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filteredChallenges.length,
                itemBuilder: (context, idx) {
                  final c = _filteredChallenges[idx];
                  return ChallengeCard(
                    challenge: c,
                    onTap: () => _openDetail(c),
                    onPrimaryAction: c.isJoined
                        ? () => _completeChallenge(c)
                        : () => _joinChallenge(c),
                    primary: widget.primary,
                    muted: widget.muted,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBanner(Map<String, dynamic> stats, Map<String, dynamic> userStats, Map<String, int> medals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [widget.primary, widget.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Górny wiersz - podstawowe statystyki
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('${userStats['completedCount']}', 'Ukończone'),
              _buildStatItem('${userStats['activeCount']}', 'Aktywne'),
              _buildStatItem('${userStats['medals']}', 'Medale'),
            ],
          ),

          SizedBox(height: 12),

          // Wiersz z medalami
          _buildMedalsRow(medals),

          SizedBox(height: 12),

          // Pasek postępu
          LinearProgressIndicator(
            value: stats['avgProgress'],
            backgroundColor: Colors.white.withOpacity(0.3),
            color: Colors.white,
          ),
          SizedBox(height: 4),
          Text(
            'Średni postęp: ${(stats['avgProgress'] * 100).round()}%',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalsRow(Map<String, int> medals) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMedalItem('🥉', medals['bronze'] ?? 0),
        _buildMedalItem('🥈', medals['silver'] ?? 0),
        _buildMedalItem('🥇', medals['gold'] ?? 0),
        _buildMedalItem('💎', medals['diamond'] ?? 0),
      ],
    );
  }

  Widget _buildMedalItem(String icon, int count) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20)),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Przyciski filtrowania
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                label: Text(_showUnlockedOnly ? 'Tylko odblokowane' : 'Wszystkie'),
                selected: _showUnlockedOnly,
                onSelected: (_) => _toggleShowUnlocked(),
              ),
              FilterChip(
                label: Text(_showJoinedOnly ? 'Tylko dołączone' : 'Wszystkie'),
                selected: _showJoinedOnly,
                onSelected: (_) => _toggleShowJoined(),
              ),
            ],
          ),
        ),

        // Filtry kategorii
        _buildCategoryFilters(),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Wszystkie', null),
            ...ChallengeCategory.values.map((category) {
              return _buildFilterChip(_getCategoryName(category), category);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ChallengeCategory? category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: _selectedCategory == category,
        onSelected: (selected) => _filterChallenges(selected ? category : null),
        backgroundColor: Colors.white,
        selectedColor: widget.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: _selectedCategory == category ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Brak wyzwań',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            _showUnlockedOnly
                ? 'Odblokuj więcej wyzwań poprzez ukończenie aktualnych'
                : 'Wybierz inne filtry lub kategorię',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.strength:
        return 'Siła';
      case ChallengeCategory.volume:
        return 'Objętość';
      case ChallengeCategory.consistency:
        return 'Konsekwencja';
      case ChallengeCategory.variety:
        return 'Różnorodność';
      case ChallengeCategory.endurance:
        return 'Wytrzymałość';
      case ChallengeCategory.bodyweight:
        return 'Kalistenika';
      default:
        return 'Inne';
    }
  }
}