import 'package:flutter/material.dart';

class SocialSignButtons extends StatelessWidget {
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;
  final VoidCallback? onApple;

  const SocialSignButtons({Key? key, this.onGoogle, this.onFacebook, this.onApple}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onPressed: onGoogle,
            child: const Text('Zaloguj przez Google'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
            ),
            onPressed: onFacebook,
            child: const Text('Zaloguj przez Facebook'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: onApple,
            child: const Text('Zaloguj przez Apple'),
          ),
        ),
      ],
    );
  }
}