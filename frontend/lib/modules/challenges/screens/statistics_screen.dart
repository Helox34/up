// lib/modules/challenges/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/challenge.dart';
import 'package:wkmobile/services/progress_service.dart';

class StatisticsScreen extends StatefulWidget {
  final Color primary;

  const StatisticsScreen({Key? key, required this.primary}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ProgressService _progressService = ProgressService.instance;
  List<Challenge> _completedChallenges = [];
  List<Challenge> _inProgressChallenges = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final allChallenges = _progressService.challenges;
    _completedChallenges = allChallenges.where((c) => c.progress >= 1.0).toList();
    _inProgressChallenges = allChallenges.where((c) => c.progress > 0 && c.progress < 1.0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _progressService.getStats();

    return Scaffold(
      appBar: AppBar(
        title: Text('Statystyki'),
        backgroundColor: widget.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kafelki statystyk
            _buildStatsGrid(stats),
            SizedBox(height: 24),

            // Wykres postępów
            _buildProgressChart(),
            SizedBox(height: 24),

            // Rozkład według kategorii
            _buildCategoryDistribution(),
            SizedBox(height: 24),

            // Lista ukończonych wyzwań
            _buildCompletedChallenges(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Ukończone',
          '${stats['completed']}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'W toku',
          '${_inProgressChallenges.length}',
          Icons.timelapse,
          Colors.orange,
        ),
        _buildStatCard(
          'Skuteczność',
          '${(stats['completionRate'] * 100).round()}%',
          Icons.trending_up,
          Colors.blue,
        ),
        _buildStatCard(
          'Średni postęp',
          '${(stats['avgProgress'] * 100).round()}%',
          Icons.bar_chart,
          widget.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    final challenges = _progressService.challenges.where((c) => c.progress > 0).toList();

    final series = [
      charts.Series<Challenge, String>(
        id: 'Progress',
        domainFn: (Challenge challenge, _) => challenge.title.length > 15
            ? '${challenge.title.substring(0, 15)}...'
            : challenge.title,
        measureFn: (Challenge challenge, _) => challenge.progress * 100,
        colorFn: (Challenge challenge, _) => charts.ColorUtil.fromDartColor(widget.primary),
        data: challenges,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Postęp wyzwań',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: charts.BarChart(
                series,
                animate: true,
                vertical: false,
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelRotation: 45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    final challenges = _progressService.challenges;
    final categoryCounts = Map<ChallengeCategory, int>();

    for (final category in ChallengeCategory.values) {
      categoryCounts[category] = challenges.where((c) => c.category == category).length;
    }

    final data = categoryCounts.entries.map((entry) {
      return _ChartData(
        _getCategoryName(entry.key),
        entry.value.toDouble(),
        _getCategoryColor(entry.key),
      );
    }).toList();

    final series = [
      charts.Series<_ChartData, String>(
        id: 'Categories',
        domainFn: (_ChartData data, _) => data.category,
        measureFn: (_ChartData data, _) => data.count,
        colorFn: (_ChartData data, _) => charts.ColorUtil.fromDartColor(data.color),
        data: data,
        labelAccessorFn: (_ChartData data, _) => '${data.count}',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rozkład kategorii',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: charts.PieChart(
                series,
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcWidth: 60,
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.inside,
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

  Widget _buildCompletedChallenges() {
    if (_completedChallenges.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.emoji_events, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'Brak ukończonych wyzwań',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ukończone wyzwania',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ..._completedChallenges.map((challenge) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check, color: Colors.green),
              ),
              title: Text(challenge.title),
              subtitle: Text('Ukończono: ${challenge.target.values.first} ${challenge.unit}'),
              trailing: Chip(
                label: Text('100%'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.strength:
        return Colors.red;
      case ChallengeCategory.volume:
        return Colors.blue;
      case ChallengeCategory.consistency:
        return Colors.green;
      case ChallengeCategory.variety:
        return Colors.orange;
      case ChallengeCategory.endurance:
        return Colors.purple;
      case ChallengeCategory.bodyweight:
        return Colors.teal;
      default:
        return Colors.grey;
    }
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

class _ChartData {
  final String category;
  final double count;
  final Color color;

  _ChartData(this.category, this.count, this.color);
}