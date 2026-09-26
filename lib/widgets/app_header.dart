import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The purple hero header with the app logo, animated coin pill and
/// avatar — matches the mockup's `.hero` bar. [coins] should come from
/// a live Firestore stream in the real app (see UserRepository).
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.coins,
    required this.initials,
    this.onAvatarTap,
    this.child,
  });

  final int coins;
  final String initials;
  final VoidCallback? onAvatarTap;
  final Widget? child; // e.g. the "today's earnings" strip on Home

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: AppColors.goldGradient,
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                    children: [
                      TextSpan(text: 'Quick '),
                      TextSpan(text: 'Rewards', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              _CoinPill(coins: coins),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppColors.gold1, AppColors.violet3]),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.violet2,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 5, 13, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(.16),
        border: Border.all(color: Colors.white.withOpacity(.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
            child: const Icon(Icons.bolt, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 7),
          Text(
            '$coins',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
