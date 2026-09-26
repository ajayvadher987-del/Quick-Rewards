import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Placeholder used by screens that haven't been built yet in this
/// step-by-step build. Swap each one out as we get to it.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded, size: 40, color: AppColors.muted),
            const SizedBox(height: 12),
            Text('$title — coming in the next step', style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
