import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/coin_result_dialog.dart';
import '../../widgets/reward_card.dart';

/// Earn tab — matches the "Earn Options" section of the mockup:
/// Daily Spin, Scratch Card, App Tasks/Offers, Surveys, Daily Missions,
/// and the three social-follow tasks.
///
/// Wiring status (see backend/functions/index.js):
///   [done] Daily Spin      - fully wired to the `spinWheel` Cloud Function
///   [todo] Everything else - UI is real, but its Cloud Function isn't
///      written yet. Tapping shows a "coming soon" note instead of
///      awarding coins, so nothing here can be mistaken for working
///      when it isn't.
class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  final _repo = UserRepository();
  bool _spinning = false;

  Future<void> _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    final result = await _repo.spinWheel();
    setState(() => _spinning = false);
    if (!mounted) return;
    showCoinResultDialog(
      context,
      success: result.success,
      coinsAwarded: result.coinsAwarded,
      message: result.message,
    );
  }

  void _notWiredYet(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: backend not wired yet — coming in a later step.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
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
                      buttonLabel: _spinning ? 'Spinning…' : 'Spin',
                      onTap: user.spinToday >= 10 || _spinning ? null : _spin,
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Scratch Card',
                      subtitle: '${user.scratchCards} card${user.scratchCards == 1 ? '' : 's'} available',
                      icon: Icons.card_giftcard_rounded,
                      themeKey: 'violet',
                      badge: user.scratchCards > 0 ? '${user.scratchCards} New' : null,
                      onTap: () => _notWiredYet('Scratch Card'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'App Tasks / Offers',
                      subtitle: 'Install apps and earn',
                      icon: Icons.apps_rounded,
                      themeKey: 'blue',
                      onTap: () => _notWiredYet('Offers'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Surveys',
                      subtitle: 'Share opinions and earn',
                      icon: Icons.fact_check_rounded,
                      themeKey: 'rose',
                      onTap: () => _notWiredYet('Surveys'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Daily Missions',
                      subtitle: '3 offers = 100 coins',
                      icon: Icons.track_changes_rounded,
                      themeKey: 'green',
                      onTap: () => _notWiredYet('Daily Missions'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'WhatsApp Channel',
                      subtitle: 'Join and earn 25 coins',
                      icon: Icons.chat_rounded,
                      themeKey: 'green',
                      buttonLabel: 'Join',
                      onTap: () => _notWiredYet('WhatsApp task'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Telegram',
                      subtitle: 'Join and earn 25 coins',
                      icon: Icons.send_rounded,
                      themeKey: 'blue',
                      buttonLabel: 'Join',
                      onTap: () => _notWiredYet('Telegram task'),
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'YouTube Subscribe',
                      subtitle: 'Subscribe and earn 25 coins',
                      icon: Icons.play_circle_fill_rounded,
                      themeKey: 'rose',
                      buttonLabel: 'Subscribe',
                      onTap: () => _notWiredYet('YouTube task'),
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
