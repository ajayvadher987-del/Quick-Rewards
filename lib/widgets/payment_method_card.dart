import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The "Payment Method" tile shown on the first Wallet screen — a
/// logo image (Google Play or UPI), a name, and the minimum coins
/// needed. Tapping opens that method's list of reward tiers.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.imageAsset,
    required this.isGooglePlay,
    required this.title,
    required this.minCoins,
    required this.onTap,
  });

  final String imageAsset;
  final bool isGooglePlay;
  final String title;
  final int minCoins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.line),
            boxShadow: const [BoxShadow(color: Color(0x121E1450), blurRadius: 16, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: isGooglePlay
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1FDBA0), Color(0xFF0A7F66)],
                          )
                        : null,
                    color: isGooglePlay ? null : Colors.white,
                  ),
                  padding: EdgeInsets.all(isGooglePlay ? 10 : 0),
                  child: isGooglePlay
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Image.asset(imageAsset, fit: BoxFit.contain)),
                            const SizedBox(height: 6),
                            const Text(
                              'Google Play',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        )
                      : Image.asset(imageAsset, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Min: ${_fmt(minCoins)}', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formats a number with Indian-style comma grouping for values under
/// 1 lakh (e.g. 10500 -> "10,500"), which covers every tier we have.
String _fmt(int n) {
  final str = n.toString();
  if (str.length <= 3) return str;
  final last3 = str.substring(str.length - 3);
  final rest = str.substring(0, str.length - 3);
  return '$rest,$last3';
}

