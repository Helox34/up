import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wkmobile/services/units_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthday;

  final List<String> _genders = ['Mężczyzna', 'Kobieta', 'Inne'];

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

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _firstNameController.text = data['firstName'] ?? '';
            _lastNameController.text = data['lastName'] ?? '';
            _usernameController.text = data['username'] ?? '';
            _goalController.text = data['goal'] ?? '';
            _heightController.text = data['height']?.toString() ?? '';
            _weightController.text = data['weight']?.toString() ?? '';
            _selectedGender = data['gender'];

            if (data['birthday'] != null) {
              _selectedBirthday = DateTime.parse(data['birthday']);
            }
          });
        }
      } catch (e) {
        print('Błąd ładowania danych: $e');
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    try {
      // Dodaj zabezpieczenie przed null
      final unitsService = Provider.of<UnitsService>(context, listen: false);

      double? weight = double.tryParse(_weightController.text);
      double? height = double.tryParse(_heightController.text);

      await _firestore.collection('users').doc(_user!.uid).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'gender': _selectedGender,
        'birthday': _selectedBirthday?.toIso8601String(),
        'goal': _goalController.text,
        'weight': weight,
        'height': height,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil został zaktualizowany')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas zapisywania: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Zabezpieczenie przed null w UnitsService
    final unitsService = Provider.of<UnitsService>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Nagłówek z przyciskiem zmiany zdjęcia
            GestureDetector(
              onTap: () {
                // Logika zmiany zdjęcia
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Zmień zdjęcie profilowe',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Imię i Nazwisko
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'Imię',
                    hint: 'Bartek',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Nazwisko',
                    hint: 'Piwowarczyk',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Nazwa użytkownika
            _buildTextField(
              controller: _usernameController,
              label: 'Nazwa użytkownika*',
              hint: 'helox',
            ),

            const SizedBox(height: 16),

            // Płeć
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Płeć',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),

            const SizedBox(height: 16),

            // Data urodzenia
            GestureDetector(
              onTap: () => _selectBirthday(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Data urodzenia',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _selectedBirthday != null
                        ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                        : 'Wybierz datę',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cel
            _buildTextField(
              controller: _goalController,
              label: 'Twój cel',
              hint: 'Co chcesz osiągnąć?',
            ),

            const SizedBox(height: 24),

            // Waga i Wzrost
            const Text(
              'Wzrost (cm)    Waga (kg)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Numeryczna klawiatura dla wzrostu i wagi
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '175',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '70',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Przycisk zapisz
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
      ],
    );
  }
}