import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../community_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedActivity;
  File? _selectedImage;
  bool _loading = false;

  final List<String> _activityTypes = [
    'Bieganie',
    'Jazda na rowerze',
    'Pływanie',
    'Siłownia',
    'Joga',
    'Wspinaczka',
    'Sporty drużynowe',
    'Inne'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utwórz post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Wybór typu aktywności
            DropdownButtonFormField<String>(
              value: _selectedActivity,
              decoration: const InputDecoration(
                labelText: 'Typ aktywności',
                border: OutlineInputBorder(),
              ),
              items: _activityTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedActivity = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wybierz typ aktywności';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Podsumowanie
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Podsumowanie (np. dystans, czas)',
                border: OutlineInputBorder(),
                hintText: '5km w 25 minut',
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź podsumowanie';
                }
                if (value.length < 5) {
                  return 'Podsumowanie musi mieć co najmniej 5 znaków';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Opis
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalnie)',
                border: OutlineInputBorder(),
                hintText: 'Opisz swoją aktywność...',
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Wybór zdjęcia
            _buildImageSection(),
            const SizedBox(height: 24),

            // Przycisk publikacji
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white, // 👈 BIAŁY TEKST
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Opublikuj post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zdjęcie (opcjonalnie)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Wybierz zdjęcie'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Zrób zdjęcie'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final communityProvider = Provider.of<CommunityProvider>(context, listen: false);

      // Tutaj możesz dodać logikę uploadu zdjęcia jeśli _selectedImage != null
      String? imageUrl;
      if (_selectedImage != null) {
        // TODO: Zaimplementuj upload zdjęcia do Firebase Storage
        // imageUrl = await _uploadImage(_selectedImage!);
      }

      await communityProvider.createPost(
        activityType: _selectedActivity!,
        summary: _summaryController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageUrl,
      );

      // Powrót do poprzedniego ekranu po sukcesie
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post został opublikowany!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // TODO: Zaimplementuj metodę uploadu zdjęcia
  // Future<String> _uploadImage(File image) async {
  //   // Implementacja uploadu do Firebase Storage
  // }

  @override
  void dispose() {
    _summaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}