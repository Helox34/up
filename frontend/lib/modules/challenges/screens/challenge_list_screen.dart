// lib/modules/challenges/screens/challenge_list_screen.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../services/user_progress_service.dart';
import '../widgets/challenge_card.dart';
import 'challenge_detail_screen.dart';

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
    // Tymczasowe rozwiązanie - prostsza wersja bez ChallengeDetailScreen
    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(ch.title)),
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
                Text('Typ: ${ch.type}'),
                Text('Kategoria: ${ch.category}'),
                Text('Trudność: ${ch.difficulty}'),
                Text('Czas: ${ch.days} dni'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
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
          SnackBar(content: Text('Dołączyłeś do ${ch.title}'))
      );
      setState(() {
        // Aktualizacja stanu wyzwania
        _challenges = _service.challenges;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e'))
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
    final primary = Theme.of(context).colorScheme.primary;
    final muted = Colors.grey;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyzwania'),
      ),
      body: _challenges.isEmpty
          ? const Center(
        child: Text('Brak dostępnych wyzwań'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _challenges.length,
        itemBuilder: (ctx, idx) {
          final ch = _challenges[idx];
          return ChallengeCard(
            challenge: ch,
            userProfile: _userProfile,
            primary: primary,
            muted: muted,
            onTap: () => _openDetail(ch),
            onPrimaryAction: () => ch.isJoined ? _openDetail(ch) : _join(ch),
          );
        },
      ),
    );
  }
}