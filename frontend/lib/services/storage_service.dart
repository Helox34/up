class StorageService {
  Future<String> uploadImage(dynamic file) async {
    // Tymczasowa implementacja - symuluje upload
    print('Uploading image...');
    await Future.delayed(const Duration(seconds: 2));

    // Zwraca fikcyjny URL obrazka
    return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
  }
}