import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ad_placeholder.dart';
import '../../widgets/mini_header.dart';

class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  final _repo = UserRepository();
  String? _question;
  String? _challengeId;
  List<int> _options = const [];
  bool _loading = true;
  bool _submitting = false;
  bool _claimingMission = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  Future<void> _loadChallenge() async {
    setState(() => _loading = true);
    final data = await _repo.generateMathChallenge();
    if (!mounted) return;
    setState(() {
      _question = data['question'] as String?;
      _challengeId = data['challengeId'] as String?;
      _options = (data['options'] as List).map((e) => e as int).toList();
      _loading = false;
    });
  }

  Future<void> _pick(int value) async {
    if (_challengeId == null || _submitting) return;
    setState(() => _submitting = true);
    await showPlaceholderAd(context);
    final result = await _repo.submitMathQuiz(value, _challengeId!);
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    await _loadChallenge();
  }

  Future<void> _claimMission() async {
    setState(() => _claimingMission = true);
    final result = await _repo.claimCaptchaMission();
    if (!mounted) return;
    setState(() => _claimingMission = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final atLimit = user.mathToday >= 100;

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: MiniHeader(title: 'Math Quiz', coins: user.coins),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${user.mathToday}/100 today', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFF6DD), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFF8DE9B))),
                              child: const Text('+10', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (user.mathToday / 100).clamp(0, 1),
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE6E1F6),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFF0A020)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user.captchaToday >= 50) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Daily Mission: 50 CAPTCHAs done!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          ElevatedButton(
                            onPressed: user.captchaMissionClaimed || _claimingMission ? null : _claimMission,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.violet2, padding: const EdgeInsets.symmetric(horizontal: 14)),
                            child: Text(user.captchaMissionClaimed ? 'Claimed' : '+100'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (atLimit)
                    const Expanded(
                      child: Center(
                        child: Text('Daily Math Quiz limit reached — come back tomorrow.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
                      ),
                    )
                  else if (_loading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFE6EEFF), Color(0xFFD3E1FF)]),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFBCD0FB)),
                      ),
                      child: Text(
                        _question ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.4,
                      children: _options.map((opt) {
                        return OutlinedButton(
                          onPressed: _submitting ? null : () => _pick(opt),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE0DBF2), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: Text('$opt', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF3A1F92))),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text('Every 25 quizzes = 1 Scratch Card', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
