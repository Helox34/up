import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  final StorageService _storage = StorageService();

  String? imageUrl;

  Future<void> _uploadImage() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final url = await _storage.uploadProfileImage(uid);
    setState(() {
      imageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profil użytkownika")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(imageUrl!), radius: 50)
                : const CircleAvatar(radius: 50, child: Icon(Icons.person)),
            const SizedBox(height: 20),
            Text(user?.email ?? "Nieznany użytkownik"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text("Zmień zdjęcie profilowe"),
            ),
          ],
        ),
      ),
    );
  }
}
