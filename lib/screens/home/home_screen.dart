import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/reward_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = UserRepository();
  bool _busy = false;

  Future<void> _claimDailyLogin() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await _repo.claimDailyLogin();
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.success ? '+${result.coinsAwarded} coins earned' : result.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final goalPct = user.dailyGoal == 0 ? 0.0 : user.todayEarned / user.dailyGoal;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                coins: user.coins,
                initials: user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                child: _TodayStrip(earned: user.todayEarned, goal: user.dailyGoal, pct: goalPct),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    RewardCard(
                      title: 'Playtime Games',
                      subtitle: 'Earn per minute',
                      icon: Icons.videogame_asset_rounded,
                      themeKey: 'gold',
                      badge: 'Recommended',
                      onTap: () {}, // TODO: navigate to Playtime Games list
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Daily Login',
                      subtitle: '10 to 70 coins, Day 1 to 7',
                      icon: Icons.calendar_month_rounded,
                      themeKey: 'violet',
                      buttonLabel: user.hasClaimedLoginToday ? 'Claimed' : 'Claim',
                      onTap: user.hasClaimedLoginToday || _busy ? null : _claimDailyLogin,
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Solve CAPTCHA',
                      subtitle: '10 coins each · ${user.captchaToday}/30 today',
                      icon: Icons.shield_rounded,
                      themeKey: 'blue',
                      progress: user.captchaToday / 30,
                      onTap: () {}, // TODO: push CaptchaScreen
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Math Quiz',
                      subtitle: '10 coins each · ${user.mathToday}/30 today',
                      icon: Icons.calculate_rounded,
                      themeKey: 'rose',
                      progress: user.mathToday / 30,
                      onTap: () {}, // TODO: push MathQuizScreen
                    ),
                    const SizedBox(height: 14),
                    RewardCard(
                      title: 'Watch Videos',
                      subtitle: '10 coins each · ${user.videoToday}/10 today',
                      icon: Icons.play_circle_fill_rounded,
                      themeKey: 'green',
                      progress: user.videoToday / 10,
                      onTap: () {}, // TODO: push VideoScreen
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

class _TodayStrip extends StatelessWidget {
  const _TodayStrip({required this.earned, required this.goal, required this.pct});
  final int earned;
  final int goal;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.12),
        border: Border.all(color: Colors.white.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Today's earnings", style: TextStyle(color: Colors.white70, fontSize: 11.5)),
              Text('+$earned coins', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0, 1),
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold2),
                  ),
                ),
                const SizedBox(height: 5),
                Text('Goal $goal coins', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
