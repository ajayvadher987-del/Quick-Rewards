import 'package:flutter/material.dart';
import '../models/reward_tier.dart';
import '../theme/app_theme.dart';

/// One reward option inside the tier grid — logo, ₹ pill, coin
/// progress, and a thin bar. Greyed out (but still tappable, to show
/// "need X more coins") when the user doesn't have enough yet.
class TierCard extends StatelessWidget {
  const TierCard({
    super.key,
    required this.tier,
    required this.currentCoins,
    required this.imageAsset,
    required this.isGooglePlay,
    required this.onTap,
  });

  final RewardTier tier;
  final int currentCoins;
  final String imageAsset;
  final bool isGooglePlay;
  final VoidCallback onTap;

  bool get unlocked => currentCoins >= tier.coins;

  @override
  Widget build(BuildContext context) {
    final pct = (currentCoins / tier.coins).clamp(0.0, 1.0);

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.line),
              boxShadow: const [BoxShadow(color: Color(0x121E1450), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.7,
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
                    ),
                    padding: EdgeInsets.all(isGooglePlay ? 8 : 0),
                    child: isGooglePlay
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Image.asset(imageAsset, fit: BoxFit.contain)),
                              const SizedBox(height: 4),
                              const Text('Google Play',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                            ],
                          )
                        : Image.asset(imageAsset, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE4E3EC)),
                  ),
                  child: Text('₹ ${tier.inr}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 9),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 10),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${_fmt(currentCoins)}/${_fmt(tier.coins)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E4F0),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF6D76E8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmt(int n) {
  final str = n.toString();
  if (str.length <= 3) return str;
  final last3 = str.substring(str.length - 3);
  final rest = str.substring(0, str.length - 3);
  return '$rest,$last3';
}
