import 'package:flutter/material.dart';
import '../widgets/achievement_tile.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  bool _loading = false;
  List<dynamic> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadLocalChallenges();
  }

  Future<void> _loadLocalChallenges() async {
    setState(() { _loading = true; });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _challenges = [
        {
          'title': '100 pompek',
          'description': 'Brązowy medal · 100 pompek',
          'icon': '💪',
          'currentProgress': 20,
          'targetProgress': 100,
        },
        {
          'title': '80 kg wyciskania',
          'description': 'Brązowy medal · 80 kg',
          'icon': '🏋️',
          'currentProgress': 0,
          'targetProgress': 80,
        },
        {
          'title': '100 kg przysiadów',
          'description': 'Brązowy medal · 100 kg',
          'icon': '🦵',
          'currentProgress': 0,
          'targetProgress': 100,
        },
        {
          'title': '5 minut plank',
          'description': 'Brązowy medal · 5 minut',
          'icon': '⏱️',
          'currentProgress': 0,
          'targetProgress': 5,
        },
        {
          'title': '20 podciągnięć',
          'description': 'Brązowy medal · 20 podciągnięć',
          'icon': '🙃',
          'currentProgress': 0,
          'targetProgress': 20,
        },
      ];
      _loading = false;
    });
  }

  void _joinChallenge(int index) {
    setState(() {
      _challenges[index]['joined'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dołączyłeś do ${_challenges[index]['title']}'),
        backgroundColor: Colors.green,
      ),
    );
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
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wyzwania'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Osiągnięcia'),
              Tab(text: 'Wyzwania'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
          ),
        ),
        body: TabBarView(
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
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _challenges.length,
              itemBuilder: (context, idx) {
                final c = _challenges[idx];
                final isJoined = c['joined'] == true;
                final progress = c['currentProgress'] / c['targetProgress'];
                final percentage = (progress * 100).toStringAsFixed(0);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  c['icon'] ?? '🎯',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['title'] ?? 'Wyzwanie',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    c['description'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${c['currentProgress']}/${c['targetProgress']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: isJoined
                              ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, size: 16, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Dołączono',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ElevatedButton(
                            onPressed: () => _joinChallenge(idx),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Dołącz'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.home), onPressed: () {}),
              IconButton(icon: const Icon(Icons.people), onPressed: () {}),
              IconButton(icon: const Icon(Icons.fitness_center), onPressed: () {}),
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
              IconButton(icon: const Icon(Icons.person), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}