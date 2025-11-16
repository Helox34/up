// lib/modules/challenges/screens/challenge_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import 'package:wkmobile/services/progress_service.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;
  final Color primary;

  const ChallengeDetailScreen({
    Key? key,
    required this.challenge,
    required this.primary,
  }) : super(key: key);

  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late Challenge _challenge;
  final ProgressService _progressService = ProgressService.instance;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
  }

  void _updateProgress() {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateDialog(
        challenge: _challenge,
        onProgressUpdated: (newValue) {
          _progressService.updateChallengeProgress(_challenge.id, newValue);
          setState(() {
            _challenge = _challenge.copyWith(
              current: {..._challenge.current, _challenge.current.keys.first: newValue},
              progress: _calculateProgress(_challenge.target.values.first as num, newValue),
            );
          });
        },
      ),
    );
  }

  double _calculateProgress(num target, num current) {
    return (current / target).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _challenge.current.values.first;
    final targetValue = _challenge.target.values.first;
    final progress = _challenge.progress;

    return Scaffold(
      appBar: AppBar(
        title: Text(_challenge.title),
        backgroundColor: widget.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: widget.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          _challenge.icon,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _challenge.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _challenge.subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Chip(
                            label: Text(
                              _challenge.difficulty,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _getDifficultyColor(_challenge.difficulty),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Opis
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opis wyzwania',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(_challenge.description),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Postęp
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Twój postęp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Wskaźnik postępu
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      color: widget.primary,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% ukończone',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Statystyki
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Aktualnie', '$currentValue ${_challenge.unit}'),
                        _buildStatCard('Cel', '$targetValue ${_challenge.unit}'),
                        _buildStatCard('Pozostało', '${targetValue - currentValue} ${_challenge.unit}'),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Przycisk aktualizacji
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProgress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Aktualizuj postęp',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Informacje dodatkowe
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informacje',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Kategoria', _getCategoryName(_challenge.category)),
                    _buildInfoRow('Typ', _getTypeName(_challenge.type)),
                    _buildInfoRow('Czas trwania', '${_challenge.days} dni'),
                    _buildInfoRow('Data rozpoczęcia', 'Dzisiaj'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Łatwy':
        return Colors.green;
      case 'Średni':
        return Colors.orange;
      case 'Trudny':
        return Colors.red;
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

  String _getTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.proficiency:
        return 'Maksymalne obciążenie';
      case ChallengeType.specialization:
        return 'Specjalizacja';
      case ChallengeType.streak:
        return 'Pasa i postęp';
      case ChallengeType.activity:
        return 'Aktywność';
      case ChallengeType.exercise:
        return 'Ćwiczenie';
      case ChallengeType.endurance:
        return 'Wytrzymałość';
      default:
        return 'Inne';
    }
  }
}

// Dialog do aktualizacji postępu
class ProgressUpdateDialog extends StatefulWidget {
  final Challenge challenge;
  final Function(num) onProgressUpdated;

  const ProgressUpdateDialog({
    Key? key,
    required this.challenge,
    required this.onProgressUpdated,
  }) : super(key: key);

  @override
  _ProgressUpdateDialogState createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<ProgressUpdateDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.challenge.current.values.first.toString();
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = widget.challenge.current.values.first;
    final targetValue = widget.challenge.target.values.first;

    return AlertDialog(
      title: Text('Aktualizuj postęp - ${widget.challenge.title}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktualna wartość: $currentValue ${widget.challenge.unit}'),
            Text('Cel: $targetValue ${widget.challenge.unit}'),
            SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nowa wartość (${widget.challenge.unit})',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź wartość';
                }
                final numValue = num.tryParse(value);
                if (numValue == null) {
                  return 'Wprowadź poprawną liczbę';
                }
                if (numValue < 0) {
                  return 'Wartość nie może być ujemna';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newValue = num.parse(_controller.text);
              widget.onProgressUpdated(newValue);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Postęp zaktualizowany!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Text('Zapisz'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}