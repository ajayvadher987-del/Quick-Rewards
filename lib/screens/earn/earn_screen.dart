import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/reward_card.dart';
import 'scratch_screen.dart';
import 'spin_screen.dart';
import 'math_quiz_screen.dart';

/// Earn tab — matches the "Earn Options" section of the mockup:
/// Daily Spin, Scratch Card, App Tasks/Offers, Surveys, Daily Missions,
/// and the three social-follow tasks.
///
/// Wiring status (see backend/functions/index.js):
///   [done] Daily Spin, Scratch Card, Daily Mission (opens inside Math Quiz)
///   [todo] Offers, Surveys, WhatsApp/Telegram/YouTube — their Cloud
///      Functions aren't written yet. Tapping shows a "coming soon"
///      note instead of awarding coins, so nothing here can be
///      mistaken for working when it isn't.
class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});

  void _notWiredYet(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: backend not wired yet — coming in a later step.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = UserRepository();
    return StreamBuilder<UserModel>(
      stream: repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(coins: user.coins, initials: user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    RewardCard(
                      title: 'Daily Spin',
                      subtitle: 'Win 5 to 25 coins · ${user.spinToday}/10',
                      icon: Icons.donut_large_rounded,
                      themeKey: 'gold',
                      progress: user.spinToday / 10,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpinScreen())),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Scratch Card',
                      subtitle: '${user.scratchCards} card${user.scratchCards == 1 ? '' : 's'} available',
                      icon: Icons.card_giftcard_rounded,
                      themeKey: 'violet',
                      badge: user.scratchCards > 0 ? '${user.scratchCards} New' : null,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScratchScreen())),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'App Tasks / Offers',
                      subtitle: 'Install apps and earn',
                      icon: Icons.apps_rounded,
                      themeKey: 'blue',
                      onTap: () => _notWiredYet(context, 'Offers'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Surveys',
                      subtitle: 'Share opinions and earn',
                      icon: Icons.fact_check_rounded,
                      themeKey: 'rose',
                      onTap: () => _notWiredYet(context, 'Surveys'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Daily Mission',
                      subtitle: 'Solve 50 CAPTCHAs = 100 bonus coins',
                      icon: Icons.track_changes_rounded,
                      themeKey: 'green',
                      buttonLabel: 'Open',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MathQuizScreen())),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'WhatsApp Channel',
                      subtitle: 'Join and earn 25 coins',
                      icon: Icons.chat_rounded,
                      themeKey: 'green',
                      buttonLabel: 'Join',
                      onTap: () => _notWiredYet(context, 'WhatsApp task'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Telegram',
                      subtitle: 'Join and earn 25 coins',
                      icon: Icons.send_rounded,
                      themeKey: 'blue',
                      buttonLabel: 'Join',
                      onTap: () => _notWiredYet(context, 'Telegram task'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'YouTube Subscribe',
                      subtitle: 'Subscribe and earn 25 coins',
                      icon: Icons.play_circle_fill_rounded,
                      themeKey: 'rose',
                      buttonLabel: 'Subscribe',
                      onTap: () => _notWiredYet(context, 'YouTube task'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
