import 'package:flutter/material.dart';

class AchievementTile extends StatelessWidget {
  final String title;
  final String level;

  const AchievementTile({super.key, required this.title, required this.level});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star, color: Colors.amber),
      title: Text(title),
      subtitle: Text('Poziom: $level'),
    );
  }
}
