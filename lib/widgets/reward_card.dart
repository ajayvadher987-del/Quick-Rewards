import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The premium earning-option card — matches the "box" style from the
/// UI mockup: tinted background, gradient icon tile, ₹/coin label,
/// optional progress bar, and a pill-shaped action button.
class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeKey,
    this.buttonLabel = 'Start',
    this.progress,
    this.badge,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String themeKey; // one of AppColors.tileThemes keys
  final String buttonLabel;
  final double? progress; // 0..1, null = no progress bar
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.tileThemes[themeKey]!;
    final tint = Color.lerp(colors.first, Colors.white, 0.85)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: colors.first.withOpacity(.35)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint, Colors.white],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(.25),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(colors: colors),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const _MiniCoin(),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4A4663),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 140,
                          height: 6,
                          child: LinearProgressIndicator(
                            value: progress!.clamp(0, 1),
                            backgroundColor: Colors.black.withOpacity(.08),
                            valueColor: AlwaysStoppedAnimation(colors.last),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 13),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(colors: colors),
                        boxShadow: [
                          BoxShadow(
                            color: colors.last.withOpacity(.5),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 86,
                height: 86,
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(-0.1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withOpacity(.5),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCoin extends StatelessWidget {
  const _MiniCoin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldGradient,
      ),
      child: const Icon(Icons.bolt, color: Colors.white, size: 12),
    );
  }
}
