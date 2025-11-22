// lib/modules/challenges/screens/challenge_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../services/progress_helper.dart';
import '../services/user_progress_service.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;
  const ChallengeDetailScreen({Key? key, required this.challenge}) : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeService _service = ChallengeService.instance;
  final UserProgressService _userService = UserProgressService.instance;
  Map<String, dynamic> _userProfile = {};
  double _currentValue = 0.0;
  bool _loading = true;
  String? _errorMessage;

  // LOKALNA FUNKCJA DO OBSŁUGI BŁĘDÓW
  String _getErrorMessage(dynamic error) {
    if (error == null) return 'Nieznany błąd';

    final errorString = error.toString();

    if (errorString.contains('permission-denied')) {
      return 'Brak uprawnień do wykonania tej operacji';
    } else if (errorString.contains('not-found')) {
      return 'Nie znaleziono żądanych danych';
    } else if (errorString.contains('unauthenticated')) {
      return 'Musisz być zalogowany';
    } else if (errorString.contains('network-error') || errorString.contains('network')) {
      return 'Błąd połączenia sieciowego';
    } else if (errorString.contains('already-exists')) {
      return 'Rekord już istnieje';
    } else if (errorString.contains('FirebaseError')) {
      return 'Błąd bazy danych';
    }

    if (errorString.contains('Not authenticated')) {
      return 'Musisz być zalogowany';
    } else if (errorString.contains('Challenge not found')) {
      return 'Wyzwanie nie zostało znalezione';
    }

    return errorString;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _userService.startListening();
      _userProfile = _userService.currentUserProfile;
      final suggested = _suggestCurrent(widget.challenge, _userProfile);
      setState(() {
        _currentValue = suggested;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _loading = false;
      });
    }
  }

  double _suggestCurrent(Challenge ch, Map<String, dynamic> profile) {
    if (ch.id.contains('bench')) return (profile['maxBenchKg'] as num?)?.toDouble() ?? 0.0;
    if (ch.id.contains('squat')) return (profile['maxSquatKg'] as num?)?.toDouble() ?? 0.0;
    if (ch.id.contains('deadlift')) return (profile['maxDeadliftKg'] as num?)?.toDouble() ?? 0.0;
    if (ch.id.contains('pushup') || ch.id.contains('pushups')) return (profile['totalPushups'] as num?)?.toDouble() ?? 0.0;
    return 0.0;
  }

  Future<void> _saveProgress() async {
    try {
      if (!_service.isUserAuthenticated) {
        setState(() {
          _errorMessage = 'Musisz być zalogowany aby zapisać postęp';
        });
        return;
      }

      await _updateUserProfileWithCurrentValue();

      await _service.setUserProgress(widget.challenge.id, {
        'current': _currentValue,
        'progressPct': computeProgressForUserPercent(widget.challenge, _userProfile),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zapisano postęp')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd: ${_getErrorMessage(e)}'))
        );
      }
    }
  }

  Future<void> _updateUserProfileWithCurrentValue() async {
    final updateData = <String, dynamic>{};

    if (widget.challenge.id.contains('bench')) {
      updateData['maxBenchKg'] = _currentValue;
    } else if (widget.challenge.id.contains('squat')) {
      updateData['maxSquatKg'] = _currentValue;
    } else if (widget.challenge.id.contains('deadlift')) {
      updateData['maxDeadliftKg'] = _currentValue;
    } else if (widget.challenge.id.contains('pushup') || widget.challenge.id.contains('pushups')) {
      updateData['totalPushups'] = _currentValue;
    }

    if (updateData.isNotEmpty) {
      await _service.updateUserProfile(updateData);
    }
  }

  double _getMaxSliderValue() {
    if (widget.challenge.target != null) {
      return widget.challenge.target!['reps']?.toDouble() ??
          widget.challenge.target!['weight']?.toDouble() ??
          widget.challenge.target!['percent']?.toDouble() ?? 100.0;
    }
    return 100.0;
  }

  String _getUnit() {
    return widget.challenge.unit ?? 'jednostek';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Ładowanie wyzwania...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.challenge.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _init,
                child: Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      );
    }

    final progress = computeProgressForUserPercent(widget.challenge, _userProfile);

    return Scaffold(
      appBar: AppBar(title: Text(widget.challenge.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nagłówek z opisem
          Text(
              widget.challenge.description,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
          SizedBox(height: 16),

          // Karta z postępem
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Twój postęp:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                    minHeight: 8,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${progress.round()}%'),
                      Text('${_currentValue.toStringAsFixed(1)}/$_getUnit'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Suwak do edycji postępu
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktualizuj postęp:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('${_currentValue.toStringAsFixed(1)} $_getUnit'),
                  Slider(
                    value: _currentValue,
                    min: 0,
                    max: _getMaxSliderValue(),
                    divisions: 100,
                    label: _currentValue.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _currentValue = v),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveProgress,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text('Zapisz postęp'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Poziomy wyzwania
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Poziomy wyzwania:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  SizedBox(height: 12),
                  _buildLevelInfo(),
                ],
              ),
            ),
          ),

          // USUNIĘTO: Informacja o automatycznym śledzeniu
          // Ten komunikat został usunięty zgodnie z życzeniem użytkownika
        ],
      ),
    );
  }

  Widget _buildLevelInfo() {
    return Column(
      children: [
        if (widget.challenge.target != null)
          ListTile(
            leading: Icon(Icons.flag, color: Colors.blue),
            title: Text('Cel wyzwania'),
            subtitle: Text('${_getMaxSliderValue().toStringAsFixed(0)} $_getUnit'),
          ),
        if (widget.challenge.days != null)
          ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.green),
            title: Text('Czas trwania'),
            subtitle: Text('${widget.challenge.days} dni'),
          ),
      ],
    );
  }
}