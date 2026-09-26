import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small reusable "result" popup shown after any coin-earning action
/// (spin, scratch, quiz, etc). Keeps that feedback consistent everywhere.
Future<void> showCoinResultDialog(
  BuildContext context, {
  required bool success,
  required int coinsAwarded,
  required String message,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: success ? const Color(0xFFD5F5E3) : const Color(0xFFFFE3E1),
              ),
              child: Icon(
                success ? Icons.check_rounded : Icons.close_rounded,
                color: success ? const Color(0xFF17A363) : const Color(0xFFE5453D),
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            if (success && coinsAwarded > 0)
              Text('+$coinsAwarded coins', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
