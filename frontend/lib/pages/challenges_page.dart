// language: dart
import 'package:flutter/material.dart';
import '../widgets/achievement_tile.dart';
import '../services/api_service.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  bool _loading = true;
  List<dynamic> _challenges = [];

  @override
  void initState() {
    super.initState();
    _fetchChallenges();
  }

  Future<void> _fetchChallenges() async {
    setState(() { _loading = true; });
    try {
      final c = await ApiService.fetchChallenges();
      setState(() { _challenges = c; });
    } catch (e) {
      // fallback: sample
      setState(() {
        _challenges = [
          {'title': '30 dni biegania', 'description': 'Codziennie biegaj 20 min'},
          {'title': '100 pompek', 'description': '100 pompek w ciągu dnia'}
        ];
      });
    } finally { setState(() { _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final sampleAchievements = [
      {'title': 'Pierwszy trening', 'level': 'bronze'},
      {'title': '5 dni z rzędu', 'level': 'silver'},
      {'title': 'Miesięczny streak', 'level': 'gold'},
      {'title': 'Mistrz tygodnia', 'level': 'diamond'},
    ];

    return DefaultTabController(
      length: 2,
      initialIndex: 1, // default open to Wyzwania (po prawej)
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Osiągnięcia'),
              Tab(text: 'Wyzwania'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Achievements
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sampleAchievements.length,
                  itemBuilder: (context, idx) {
                    final a = sampleAchievements[idx];
                    return AchievementTile(title: a['title']!, level: a['level']!);
                  },
                ),
                // Challenges
                _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _challenges.length,
                  itemBuilder: (context, idx) {
                    final c = _challenges[idx];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.flag),
                        title: Text(c['title'] ?? 'Wyzwanie'),
                        subtitle: Text(c['description'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dołączyłeś do wyzwania')),
                            );
                          },
                          child: const Text('Dołącz'),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
