import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDate = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polityka Prywatności'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Polityka Prywatności Aplikacji Workout Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Ostatnia aktualizacja: $currentDate',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Sekcje polityki prywatności
            const _PrivacySection(
              title: '1. Informacje ogólne',
              content: 'Aplikacja Workout Tracker szanuje prywatność użytkowników. Niniejsza polityka prywatności określa, w jaki sposób zbieramy, przetwarzamy i chronimy dane użytkowników.',
            ),

            const _PrivacySection(
              title: '2. Gromadzone dane',
              content: 'Aplikacja gromadzi następujące dane:\n'
                  '• Dane profilowe (imię, nazwisko, pseudonim)\n'
                  '• Dane treningowe (ćwiczenia, postępy, statystyki)\n'
                  '• Dane fizyczne (waga, wzrost, cel treningowy)\n'
                  '• Dane urządzenia (wersja systemu, typ urządzenia)',
            ),

            const _PrivacySection(
              title: '3. Cel gromadzenia danych',
              content: 'Dane są gromadzone w celu:\n'
                  '• Personalizacji doświadczenia użytkownika\n'
                  '• Śledzenia postępów treningowych\n'
                  '• Udostępniania funkcji społecznościowych\n'
                  '• Poprawy działania aplikacji',
            ),

            const _PrivacySection(
              title: '4. Przechowywanie danych',
              content: 'Dane użytkowników są przechowywane w bezpiecznej bazie danych Firebase. Mamy wdrożone odpowiednie środki bezpieczeństwa chroniące przed nieautoryzowanym dostępem.',
            ),

            const _PrivacySection(
              title: '5. Udostępnianie danych',
              content: 'Nie udostępniamy danych osobowych użytkowników stronom trzecim, z wyjątkiem sytuacji wymaganych prawem lub niezbędnych do świadczenia usług.',
            ),

            const _PrivacySection(
              title: '6. Prawa użytkownika',
              content: 'Użytkownik ma prawo do:\n'
                  '• Dostępu do swoich danych\n'
                  '• Sprostowania danych\n'
                  '• Usunięcia konta i danych\n'
                  '• Wycofania zgody na przetwarzanie',
            ),

            const _PrivacySection(
              title: '7. Pliki cookies',
              content: 'Aplikacja może używać plików cookies i podobnych technologii w celu poprawy funkcjonalności i analizy użycia.',
            ),

            const _PrivacySection(
              title: '8. Kontakt',
              content: 'W sprawach związanych z ochroną prywatności prosimy o kontakt: bartlomiejpiwowarczyk5@gmail.com',
            ),

            const SizedBox(height: 20),
            const Text(
              'Korzystając z aplikacji, użytkownik wyraża zgodę na warunki niniejszej polityki prywatności.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final String content;

  const _PrivacySection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}