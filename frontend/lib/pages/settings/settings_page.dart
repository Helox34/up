import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wkmobile/services/units_service.dart';
import 'package:wkmobile/modules/profile/pages/edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _selectedWeightUnit;
  String? _selectedHeightUnit;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final unitsService = Provider.of<UnitsService>(context, listen: false);
    _selectedWeightUnit = unitsService.weightUnit;
    _selectedHeightUnit = unitsService.heightUnit;
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();

      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wylogowano pomyślnie')),
      );
    } catch (e) {
      print('Błąd wylogowania: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd podczas wylogowania')),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wylogowanie'),
        content: const Text('Czy na pewno chcesz się wylogować?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Wyloguj'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  void _saveUnitChanges(BuildContext context) {
    final unitsService = Provider.of<UnitsService>(context, listen: false);

    if (_selectedWeightUnit != null) {
      unitsService.setWeightUnit(_selectedWeightUnit!);
    }

    if (_selectedHeightUnit != null) {
      unitsService.setHeightUnit(_selectedHeightUnit!);
    }

    setState(() {
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zmiany zostały zapisane')),
    );
  }

  void _onWeightUnitChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedWeightUnit = newValue;
        _hasChanges = true;
      });
    }
  }

  void _onHeightUnitChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedHeightUnit = newValue;
        _hasChanges = true;
      });
    }
  }

  void _showMedalSystemInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Medali',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMedalInfoRow('🥉', 'Brązowy - 1 punkt'),
            _buildMedalInfoRow('🥈', 'Srebrny - 2 punkty'),
            _buildMedalInfoRow('🥇', 'Złoty - 3 punkty'),
            _buildMedalInfoRow('💎', 'Diamentowy - 4 punkty'),
            const SizedBox(height: 12),
            Text(
              'Każde wyzwanie ma 4 poziomy. Po osiągnięciu celu awansujesz na wyższy poziom!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zamknij'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedalInfoRow(String icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitsService = Provider.of<UnitsService>(context, listen: true);

    if (!_hasChanges) {
      _selectedWeightUnit = unitsService.weightUnit;
      _selectedHeightUnit = unitsService.heightUnit;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Edytuj Profil
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text(
                'Edytuj Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _navigateToEditProfile(context),
            ),
          ),

          const SizedBox(height: 24),

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
                  const SizedBox(height: 20),

                  // Jednostki wagi
                  const Text(
                    'Waga:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedWeightUnit,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'kg',
                          child: Text('kg'),
                        ),
                        DropdownMenuItem(
                          value: 'lbs',
                          child: Text('lbs'),
                        ),
                      ],
                      onChanged: _onWeightUnitChanged,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Jednostki długości
                  const Text(
                    'Wzrost:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedHeightUnit,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'cm',
                          child: Text('cm'),
                        ),
                        DropdownMenuItem(
                          value: 'in',
                          child: Text('in'),
                        ),
                      ],
                      onChanged: _onHeightUnitChanged,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Przycisk Zapisz zmiany
                  if (_hasChanges)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveUnitChanges(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Zapisz zmiany',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // System Medali
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('System Medali'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showMedalSystemInfo(context),
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

          const SizedBox(height: 32),

          // Przycisk Wyloguj
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Wyloguj',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}