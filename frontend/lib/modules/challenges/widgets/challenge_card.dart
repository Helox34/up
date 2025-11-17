// lib/modules/challenges/widgets/challenge_card.dart
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/progress_helper.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final Map<String, dynamic> userProfile;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryAction;
  final Color primary;
  final Color muted;

  const ChallengeCard({
    Key? key,
    required this.challenge,
    required this.userProfile,
    this.onTap,
    this.onPrimaryAction,
    required this.primary,
    required this.muted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = computeProgressForUserPercent(challenge, userProfile);
    final markers = computeMarkersPercent(challenge, userProfile);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primary.withOpacity(0.12),
                ),
                child: Center(child: Text(challenge.icon, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(challenge.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(challenge.subtitle, style: TextStyle(color: muted)),
                ]),
              ),
              ElevatedButton(
                onPressed: onPrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(challenge.isJoined ? 'Kontynuuj' : 'Dołącz'),
              ),
            ]),
            const SizedBox(height: 12),
            buildProgressBarWithMarkers(
                context: context, progressPercent: progress, markersPercent: markers, fillColor: primary),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${progress.round()}% - ${_statusFromProgress(progress)}', style: TextStyle(color: muted)),
              Row(children: [
                if (challenge.levels.isNotEmpty) Text('Lvl: ${challenge.levels.length}', style: TextStyle(color: muted)),
                const SizedBox(width: 8),
                if (challenge.isUnlocked)
                  Icon(Icons.lock_open, color: primary, size: 18)
                else
                  Icon(Icons.lock, color: Colors.grey, size: 18),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }

  String _statusFromProgress(double p) {
    if (p <= 0) return 'not started';
    if (p >= 100) return 'completed';
    return 'in progress';
  }

  Widget buildProgressBarWithMarkers({
    required BuildContext context,
    required double progressPercent,
    required List<double> markersPercent,
    Color background = const Color(0xFFF1F3F5),
    Color fillColor = Colors.red,
  }) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;
      final markerWidgets = <Widget>[];
      for (int i = 0; i < markersPercent.length; i++) {
        final left = (width * (markersPercent[i] / 100)).clamp(0.0, width);
        final emoji = i == 0 ? '🥉' : i == 1 ? '🥈' : i == 2 ? '🥇' : '💎';
        markerWidgets.add(Positioned(
          left: left - 10,
          top: -8,
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
          ]),
        ));
      }

      return SizedBox(
        height: 44,
        child: Stack(children: [
          Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8))),
          Container(height: 12, width: width * (progressPercent / 100), decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(8))),
          ...markerWidgets,
        ]),
      );
    });
  }
}
