import 'package:flutter/material.dart';

class SocialSignButtons extends StatelessWidget {
  final Future<void> Function()? onGoogle;
  final Future<void> Function()? onFacebook;
  final Future<void> Function()? onApple;
  final bool isLoading;

  const SocialSignButtons({
    Key? key,
    this.onGoogle,
    this.onFacebook,
    this.onApple,
    this.isLoading = false,
  }) : super(key: key);

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
            onPressed: isLoading ? null : onGoogle,
            child: isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Zaloguj przez Google'),
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
            onPressed: isLoading ? null : onFacebook,
            child: isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Zaloguj przez Facebook'),
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
            onPressed: isLoading ? null : onApple,
            child: isLoading
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Zaloguj przez Apple'),
          ),
        ),
      ],
    );
  }
}