import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  Future<void> _launchExternalShop() async {
    final Uri url = Uri.parse('https://wkdzik.pl');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sklep'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 64, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Sklep WK Dzik',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Wybierz sposób przeglądania sklepu:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wewnętrzny sklep - w budowie')),
                );
              },
              icon: const Icon(Icons.smartphone),
              label: const Text('Wewnętrzny sklep (wkrótce)'),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _launchExternalShop,
              icon: const Icon(Icons.language),
              label: const Text('Otwórz stronę sklepu w przeglądarce'),
            ),
          ],
        ),
      ),
    );
  }
}