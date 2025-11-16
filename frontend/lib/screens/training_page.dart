// lib/pages/training_page.dart
import 'package:flutter/material.dart';
import '../widgets/red_button.dart';

class TrainingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey[850];
    return Scaffold(
      appBar: AppBar(title: Text('Treningi')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            Container(
              height: 180,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: grey, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('45:24', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  RedButton(text: 'Start', onPressed: () {}),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('Plan treningowy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _trainingCard('Trening A', 'Full body | 45 min'),
            _trainingCard('Trening B', 'Cardio | 30 min'),
            _trainingCard('Stretch', 'Rozciąganie | 15 min'),
          ],
        ),
      ),
    );
  }

  Widget _trainingCard(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[300])),
        trailing: Icon(Icons.chevron_right, color: Colors.white),
      ),
    );
  }
}
