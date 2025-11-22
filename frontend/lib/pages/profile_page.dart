import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wkmobile/modules/challenges/widgets/profile_summary.dart';
import 'package:wkmobile/modules/challenges/services/progress_service.dart';
import 'package:wkmobile/modules/challenges/models/challenge.dart';
import 'package:wkmobile/pages/settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _imageLoading = false;
  File? _newProfileImage;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_user!.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (mounted) {
          setState(() {
            if (doc.exists) {
              _userData = doc.data();
              _error = null;
            } else {
              _userData = _getDefaultUserData();
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Błąd ładowania danych użytkownika: $e');
        if (mounted) {
          setState(() {
            _error = 'Brak połączenia z internetem';
            _userData = _getDefaultUserData();
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _userData = _getDefaultUserData();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getDefaultUserData() {
    return {
      'firstName': _user?.displayName?.split(' ').first ?? 'Bartek',
      'lastName': _user?.displayName?.split(' ').last ?? 'Piwowarczyk',
      'username': 'helox',
      'displayName': _user?.displayName ?? 'Bartek Piwowarczyk',
      'avatarUrl': '',
      'workoutCount': 0,
      'totalTime': '0h',
      'weight': 70,
      'height': 175,
      'goal': 'Poprawa kondycji i siły',
    };
  }

  Future<void> _pickProfileImage() async {
    setState(() => _imageLoading = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _newProfileImage = File(image.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      print('Błąd wyboru zdjęcia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas wybierania zdjęcia')),
      );
    } finally {
      setState(() => _imageLoading = false);
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_newProfileImage == null || _user == null) return;

    setState(() => _imageLoading = true);
    try {
      setState(() {
        _userData = {
          ..._userData!,
          'avatarUrl': 'local://${_user!.uid}.jpg',
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zdjęcie profilowe zostało zaktualizowane (lokalnie)')),
      );
    } catch (e) {
      print('Błąd uploadu zdjęcia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas aktualizacji zdjęcia')),
      );
    } finally {
      setState(() {
        _imageLoading = false;
        _newProfileImage = null;
      });
    }
  }

  String _getDisplayName() {
    if (_userData != null) {
      final String firstName = _userData!['firstName']?.toString() ?? '';
      final String lastName = _userData!['lastName']?.toString() ?? '';
      final String username = _userData!['username']?.toString() ?? '';
      final String displayName = _userData!['displayName']?.toString() ?? '';

      if (username.isNotEmpty && username != 'null') {
        return '$firstName "$username" $lastName'.trim();
      } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      } else if (displayName.isNotEmpty) {
        return displayName;
      }
    }
    return _user?.displayName ?? _user?.email?.split('@').first ?? 'Użytkownik';
  }

  String _getAvatarUrl() {
    final url = _userData?['avatarUrl']?.toString() ?? '';
    if (url.startsWith('local://')) {
      return '';
    }
    return url;
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _retryLoadData() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadUserData();
  }

  // Pomocnicze metody dla medali
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

  String _getMedalName(MedalTier tier) {
    switch (tier) {
      case MedalTier.bronze:
        return 'Brązowy';
      case MedalTier.silver:
        return 'Srebrny';
      case MedalTier.gold:
        return 'Złoty';
      case MedalTier.diamond:
        return 'Diamentowy';
      default:
        return 'Brak';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProgressService>(
        builder: (context, progressService, child) {
          final stats = progressService.getStats();
          final earnedMedals = progressService.getEarnedMedals();
          final totalPoints = progressService.getTotalPoints();
          final completedChallenges = progressService.getCompletedChallengesCount();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Komunikat o błędzie
              if (_error != null) ...[
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wifi_off, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _retryLoadData,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade700,
                              side: BorderSide(color: Colors.orange.shade700),
                            ),
                            child: const Text('Spróbuj ponownie'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Nagłówek z awatarem
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _getAvatarUrl().isNotEmpty
                              ? NetworkImage(_getAvatarUrl())
                              : null,
                          child: _getAvatarUrl().isEmpty
                              ? const Icon(Icons.person, size: 48, color: Colors.grey)
                              : null,
                        ),
                        if (_imageLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(48),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _imageLoading ? null : _pickProfileImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Zmień zdjęcie profilowe'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                      _getDisplayName(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (_user?.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _user!.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Karta z punktacją i statystykami
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Punkty',
                            '$totalPoints pkt',
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                          _buildStatItem(
                            'Wyzwania',
                            '$completedChallenges',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatItem(
                            'Postęp',
                            '${(stats['avgProgress'] * 100).toStringAsFixed(0)}%',
                            Icons.trending_up,
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Treningi: ${_userData?['workoutCount'] ?? 0}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Czas: ${_userData?['totalTime'] ?? '0h'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Podsumowanie profilu z ProgressService
              ProfileSummary(
                challenges: progressService.joinedChallenges,
                primary: const Color(0xFFD32F2F),
                muted: const Color(0xFF757575),
              ),

              const SizedBox(height: 20),

              // Zdobyte medale
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Zdobyte Medale',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (earnedMedals.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Brak zdobytych medali',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dołącz do wyzwań i zdobywaj medale!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                          children: earnedMedals.entries.map((entry) {
                            final challenge = progressService.getById(entry.key);
                            final medalTier = entry.value;
                            final medalColor = _getMedalColor(medalTier);

                            return Container(
                              decoration: BoxDecoration(
                                color: medalColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: medalColor, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Text(
                                      _getMedalIcon(medalTier),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            challenge?.title.split(' ').take(2).join(' ') ?? 'Wyzwanie',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: medalColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            _getMedalName(medalTier),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: medalColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Menu profilu
              Card(
                elevation: 4,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: const Text('Ustawienia'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _navigateToSettings,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
}