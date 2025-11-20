import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wkmobile/services/units_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unitsService = Provider.of<UnitsService>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ustawienia Jednostek
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jednostki',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Jednostki wagi
                  Row(
                    children: [
                      const Text('Waga:'),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('kg'),
                        selected: unitsService.weightUnit == 'kg',
                        onSelected: (selected) {
                          if (selected) {
                            unitsService.setWeightUnit('kg');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('lb'),
                        selected: unitsService.weightUnit == 'lb',
                        onSelected: (selected) {
                          if (selected) {
                            unitsService.setWeightUnit('lb');
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Jednostki długości
                  Row(
                    children: [
                      const Text('Wzrost:'),
                      const Spacer(),
                      ChoiceChip(
                        label: const Text('cm'),
                        selected: unitsService.heightUnit == 'cm',
                        onSelected: (selected) {
                          if (selected) {
                            unitsService.setHeightUnit('cm');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('in'),
                        selected: unitsService.heightUnit == 'in',
                        onSelected: (selected) {
                          if (selected) {
                            unitsService.setHeightUnit('in');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Diagram mięśni
          Card(
            child: ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Diagram mięśni'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to muscle diagram
              },
            ),
          ),

          const SizedBox(height: 16),

          // Powiadomienia
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Powiadomienia'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to notifications
              },
            ),
          ),

          const SizedBox(height: 16),

          // Polityka prywatności
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Polityka prywatności'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to privacy policy
              },
            ),
          ),

          const SizedBox(height: 16),

          // Warunki użytkowania
          Card(
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Warunki użytkowania'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to terms of use
              },
            ),
          ),

          const SizedBox(height: 16),

          // Wsparcie
          Card(
            child: ListTile(
              leading: const Icon(Icons.support),
              title: const Text('Wsparcie'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to support
              },
            ),
          ),

          const SizedBox(height: 24),

          // Przywróć zakupy
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Restore purchase logic
              },
              child: const Text('Przywróć zakupy'),
            ),
          ),

          const SizedBox(height: 16),

          // Ratuj dane i Wyloguj
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Rescue data logic
                  },
                  child: const Text('Ratuj dane'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutMessage(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Wyloguj'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Wersja aplikacji
          Center(
            child: Text(
              'Wersja: 3.1.33',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funkcja wylogowania będzie dostępna wkrótce')),
    );
  }
}