import 'package:flutter/material.dart';
import 'package:wk_mobile/modules/challenges/screens/challenge_list_screen.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChallengeListScreen(
      primary: Color(0xFFD32F2F),
      muted: Color(0xFF757575),
    );
  }
}
