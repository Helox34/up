// lib/modules/challenges/screens/challenge_list_screen.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../services/user_progress_service.dart';

class ChallengeListScreen extends StatefulWidget {
  const ChallengeListScreen({Key? key}) : super(key: key);

  @override
  State<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends State<ChallengeListScreen> {
  final ChallengeService _service = ChallengeService.instance;
  final UserProgressService _userService = UserProgressService.instance;
  List<Challenge> _challenges = [];
  Map<String, dynamic> _userProfile = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    // start profile listener
    await _userService.startListening();
    _userProfile = _userService.currentUserProfile;

    // load challenges: prefer Firestore if available, else assets
    try {
      await _service.loadFromFirestore();
    } catch (e) {
      await _service.loadFromAssets();
    }

    setState(() {
      _challenges = _service.challenges;
      _loading = false;
    });
  }

  void _openDetail(Challenge ch) async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(ch.title),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ch.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text('Typ: ${_enumToString(ch.type)}'),
                Text('Kategoria: ${_enumToString(ch.category)}'),
                Text('Trudność: ${ch.difficulty}'),
                Text('Czas: ${ch.days} dni'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Zamknij'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (res == true) {
      // refresh user profile (may have changed)
      setState(() {
        _userProfile = _userService.currentUserProfile;
      });
    }
  }

  void _join(Challenge ch) async {
    try {
      await _service.joinChallenge(ch.id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dołączyłeś do ${ch.title}'),
            backgroundColor: Colors.green,
          )
      );
      setState(() {
        // Aktualizacja stanu wyzwania
        _challenges = _service.challenges;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  @override
  void dispose() {
    _userService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      );
    }

    return _challenges.isEmpty
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
      itemCount: _challenges.length,
      itemBuilder: (ctx, idx) {
        final ch = _challenges[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  ch.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            title: Text(
              ch.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ch.subtitle),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${ch.days} dni',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.star, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${ch.difficulty}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: ch.isJoined
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Dołączono',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
                : ElevatedButton(
              onPressed: () => _join(ch),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Dołącz',
                style: TextStyle(fontSize: 12),
              ),
            ),
            onTap: () => _openDetail(ch),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  // Pomocnicza funkcja do konwersji enum na string
  String _enumToString(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }
}