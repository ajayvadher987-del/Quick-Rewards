import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a short "ad" screen before the coin result. This is a
/// PLACEHOLDER — it does not show a real advertisement. Swap the body
/// of this function for a real interstitial ad SDK call (e.g.
/// google_mobile_ads) once you have an AdMob account and ad unit IDs;
/// everywhere in the app that calls this function will then show real
/// ads without any other code changes.
Future<void> showPlaceholderAd(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PlaceholderAdDialog(),
  );
}

class _PlaceholderAdDialog extends StatefulWidget {
  const _PlaceholderAdDialog();
  @override
  State<_PlaceholderAdDialog> createState() => _PlaceholderAdDialogState();
}

class _PlaceholderAdDialogState extends State<_PlaceholderAdDialog> {
  int _secondsLeft = 3;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        Navigator.of(context).pop();
        return;
      }
      setState(() => _secondsLeft--);
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141026),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ondemand_video_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text('Ad placeholder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
              'Real ads go here once AdMob is connected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Text('$_secondsLeft', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28)),
          ],
        ),
      ),
    );
  }
}
