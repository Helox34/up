// lib/modules/challenges/screens/advanced_statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge.dart';
import 'package:wkmobile/services/progress_service.dart';

class AdvancedStatisticsScreen extends StatefulWidget {
  final Color primary;

  const AdvancedStatisticsScreen({Key? key, required this.primary}) : super(key: key);

  @override
  _AdvancedStatisticsScreenState createState() => _AdvancedStatisticsScreenState();
}

class _AdvancedStatisticsScreenState extends State<AdvancedStatisticsScreen> {
  final ProgressService _progressService = ProgressService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProgressData> _progressHistory = [];
  bool _loading = true;
  String _selectedTimeRange = '30d';

  @override
  void initState() {
    super.initState();
    _loadProgressHistory();
  }

  Future<void> _loadProgressHistory() async {
    // Symulacja danych historycznych
    final mockData = [
      ProgressData(DateTime.now().subtract(const Duration(days: 30)), 0.1),
      ProgressData(DateTime.now().subtract(const Duration(days: 25)), 0.15),
      ProgressData(DateTime.now().subtract(const Duration(days: 20)), 0.22),
      ProgressData(DateTime.now().subtract(const Duration(days: 15)), 0.35),
      ProgressData(DateTime.now().subtract(const Duration(days: 10)), 0.48),
      ProgressData(DateTime.now().subtract(const Duration(days: 5)), 0.62),
      ProgressData(DateTime.now(), 0.75),
    ];

    setState(() {
      _progressHistory = mockData;
      _loading = false;
    });
  }

  Widget _buildProgressTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Postępów',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 == 0) {
                            return Text('Dzień ${value.toInt()}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _progressHistory.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.progress * 100,
                        );
                      }).toList(),
                      isCurved: true,
                      color: widget.primary,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgressChart() {
    final challenges = _progressService.challenges;
    final categoryProgress = <String, double>{};

    for (final category in ChallengeCategory.values) {
      final categoryChallenges = challenges.where((c) => c.category == category);
      if (categoryChallenges.isNotEmpty) {
        final avgProgress = categoryChallenges
            .map((c) => c.progress)
            .reduce((a, b) => a + b) / categoryChallenges.length;
        categoryProgress[_getCategoryName(category)] = avgProgress;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Postęp wg Kategorii',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: categoryProgress.entries.map((entry) {
                    return BarChartGroupData(
                      x: categoryProgress.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value * 100,
                          color: _getCategoryColor(entry.key),
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final category = categoryProgress.keys.elementAt(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionForecast() {
    final completed = _progressService.challenges.where((c) => c.progress >= 1.0).length;
    final total = _progressService.challenges.length;
    final completionRate = total > 0 ? completed / total : 0;

    final daysToCompleteAll = completionRate > 0
        ? ((1 - completionRate) / completionRate * 30).round()
        : 90;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prognoza Ukończenia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildForecastItem('${(completionRate * 100).round()}%', 'Obecne ukończenie'),
                _buildForecastItem('$daysToCompleteAll', 'Dni do celu'),
                _buildForecastItem('${(completionRate * 100 + 10).round()}%', 'Prognoza 30d'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionRate,
              backgroundColor: Colors.grey[200],
              color: widget.primary,
              minHeight: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaawansowane Statystyki'),
        backgroundColor: widget.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProgressTrendChart(),
            const SizedBox(height: 20),
            _buildCategoryProgressChart(),
            const SizedBox(height: 20),
            _buildCompletionForecast(),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Siła': return Colors.red;
      case 'Objętość': return Colors.blue;
      case 'Konsekwencja': return Colors.green;
      case 'Różnorodność': return Colors.orange;
      case 'Wytrzymałość': return Colors.purple;
      case 'Kalistenika': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.strength: return 'Siła';
      case ChallengeCategory.volume: return 'Objętość';
      case ChallengeCategory.consistency: return 'Konsekwencja';
      case ChallengeCategory.variety: return 'Różnorodność';
      case ChallengeCategory.endurance: return 'Wytrzymałość';
      case ChallengeCategory.bodyweight: return 'Kalistenika';
      default: return 'Inne';
    }
  }
}

class ProgressData {
  final DateTime date;
  final double progress;

  ProgressData(this.date, this.progress);
}