import 'package:flutter/material.dart';
import '../models/challenge_model.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<ChallengeModel> challenges = [
    ChallengeModel(
      id: "pushups_100",
      title: "Zrób 100 pompek",
      type: "pushups",
      bronzeGoal: 100,
      silverGoal: 500,
      goldGoal: 1000,
      diamondGoal: 10000,
    ),

    ChallengeModel(
      id: "running_5km",
      title: "Przebiegnij 5 km",
      type: "running",
      bronzeGoal: 5,
      silverGoal: 20,
      goldGoal: 50,
      diamondGoal: 200,
    ),

    ChallengeModel(
      id: "yoga_30days",
      title: "30 dni jogi",
      type: "yoga",
      bronzeGoal: 10,
      silverGoal: 30,
      goldGoal: 90,
      diamondGoal: 300,
    ),
    // (35 wyzwań otrzymasz poniżej w punkcie D!)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wyzwania"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(challenge.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(challenge.levelEmoji, style: const TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: challenge.progressPercent,
                    backgroundColor: Colors.grey[300],
                    color: Colors.red,
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "${challenge.progress} / ${challenge.nextGoal} (${(challenge.progressPercent * 100).toStringAsFixed(1)}%)",
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Podgląd wyzwania"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
