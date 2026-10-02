import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../shell/main_shell.dart';

/// The 3-slide "Earn coins / Quick tasks / Redeem your way" intro,
/// shown once right after the user signs in for the first time. See
/// [OnboardingGate] below for the "show only once" logic.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.title, required this.body});
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(
      icon: Icons.card_giftcard_rounded,
      title: 'Earn coins every day',
      body: 'Daily login, quizzes, videos and games.\nSimple tasks that add up.',
    ),
    _Slide(
      icon: Icons.shield_rounded,
      title: 'Quick and easy tasks',
      body: 'Solve CAPTCHAs, answer quizzes and\nspin the wheel. Every task takes a minute.',
    ),
    _Slide(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Redeem your way',
      body: 'Cash out with UPI or a Google Play Gift\nCard once you reach ₹100.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Skip', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(42), gradient: AppColors.goldGradient),
                            child: Icon(s.icon, color: Colors.white, size: 60),
                          ),
                          const SizedBox(height: 32),
                          Text(s.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          Text(s.body, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: active ? AppColors.gold2 : Colors.white.withOpacity(.35),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold2, foregroundColor: const Color(0xFF3A2400)),
                    child: Text(_index == _slides.length - 1 ? 'Get started' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decides whether to show onboarding or go straight to [MainShell] —
/// shown exactly once per device install, right after a successful
/// sign-in (see AuthGate).
class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then((p) => p.getBool('onboarding_seen') ?? false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return snapshot.data! ? const MainShell() : const OnboardingScreen();
      },
    );
  }
}
