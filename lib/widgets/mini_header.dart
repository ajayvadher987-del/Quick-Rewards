import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The lightweight header used on task screens (CAPTCHA, Math Quiz,
/// Spin, Scratch) — back arrow, title, and just the coin pill. Unlike
/// [AppHeader] there's no logo or "today's earnings" strip here; the
/// mockup only shows the coin count in the corner on these screens.
class MiniHeader extends StatelessWidget implements PreferredSizeWidget {
  const MiniHeader({super.key, required this.title, required this.coins});

  final String title;
  final int coins;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      titleSpacing: 0,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: AppColors.ink)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: AppColors.heroGradient,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
                child: const Icon(Icons.bolt, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 7),
              Text('$coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
