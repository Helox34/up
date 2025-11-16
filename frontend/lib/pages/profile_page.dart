import 'package:flutter/material.dart';
import 'package:wkmobile/modules/challenges/widgets/profile_summary.dart';
import 'package:wkmobile/services/progress_service.dart';
import 'package:wkmobile/modules/challenges/models/challenge.dart'; // Dodaj ten import

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Użytkownik Demo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),

        /// 👉 TU umieszczamy ProfileSummary z cast
        ProfileSummary(
          challenges: ProgressService.instance.challenges.cast<Challenge>(),
          primary: const Color(0xFFD32F2F),
          muted: const Color(0xFF757575),
        ),

        const SizedBox(height: 20),
        const Card(
          child: ListTile(
            title: Text('Statystyki'),
            subtitle: Text('Treningi: 12\nCzas: 15h'),
          ),
        ),

        const Card(
          child: ListTile(
            title: Text('Osiągnięcia'),
            subtitle: Text('3 medale'),
          ),
        ),

        const Card(
          child: ListTile(
            title: Text('Ustawienia prywatności'),
          ),
        ),
      ],
    );
  }
}