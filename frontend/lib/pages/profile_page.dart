import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wkmobile/modules/challenges/widgets/profile_summary.dart';
import 'package:wkmobile/services/progress_service.dart';
import 'package:wkmobile/modules/challenges/models/challenge.dart';
import 'package:wkmobile/modules/profile/pages/edit_profile_page.dart';
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
            .get();

        if (mounted) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Błąd ładowania danych użytkownika: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
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
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_user!.uid}.jpg');

      await storageRef.putFile(_newProfileImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({'avatarUrl': imageUrl});

      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zdjęcie profilowe zostało zaktualizowane')),
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
      final String firstName = _userData!['firstName'] ?? '';
      final String lastName = _userData!['lastName'] ?? '';
      final String username = _userData!['username'] ?? '';

      if (username.isNotEmpty) {
        return '$firstName "$username" $lastName';
      } else {
        return '$firstName $lastName';
      }
    }
    return _user?.displayName ?? 'Użytkownik Demo';
  }

  String _getAvatarUrl() {
    return _userData?['avatarUrl'] ?? '';
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Awatar i nazwa użytkownika z możliwością zmiany zdjęcia
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

                // Przycisk zmiany zdjęcia
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

          // ProfileSummary
          ProfileSummary(
            challenges: ProgressService.instance.challenges.cast<Challenge>(),
            primary: const Color(0xFFD32F2F),
            muted: const Color(0xFF757575),
          ),

          const SizedBox(height: 20),

          // Statystyki
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statystyki'),
              subtitle: _userData != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Treningi: ${_userData!['workoutCount'] ?? 0}'),
                  Text('Czas: ${_userData!['totalTime'] ?? '0h'}'),
                  if (_userData!['weight'] != null)
                    Text('Waga: ${_userData!['weight']} kg'),
                  if (_userData!['height'] != null)
                    Text('Wzrost: ${_userData!['height']} cm'),
                ],
              )
                  : const Text('Treningi: 0\nCzas: 0h'),
            ),
          ),

          const SizedBox(height: 10),

          // Karta z przyciskami Edytuj Profil i Ustawienia
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edytuj Profil'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToEditProfile,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Ustawienia'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}