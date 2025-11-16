import 'package:flutter/material.dart';
import '../models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;
  final Color primary;
  final Color muted;

  const ChallengeCard({
    Key? key,
    required this.challenge,
    required this.onTap,
    required this.onPrimaryAction,
    required this.primary,
    required this.muted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icon / avatar placeholder replicating the mockup look
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                child: Center(
                    child: Text(challenge.title[0],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: primary))),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title, style: TextStyle(fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text(challenge.subtitle, style: TextStyle(color: muted)),
                    SizedBox(height: 10),
                    LinearProgressIndicator(value: challenge.progress, backgroundColor: Colors.grey[200], color: primary),
                  ],
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                child: Text(challenge.progress > 0 ? 'Kontynuuj' : 'Dołącz'),
              )
            ],
          ),
        ),
      ),
    );
  }
}