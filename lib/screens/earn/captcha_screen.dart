import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ad_placeholder.dart';
import '../../widgets/mini_header.dart';

/// Solve CAPTCHA task. The puzzle text and its correct answer are
/// generated server-side (generateCaptchaChallenge) — the app never
/// knows the answer, it just displays the puzzle and forwards
/// whatever the user types to submitCaptcha for checking.
class CaptchaScreen extends StatefulWidget {
  const CaptchaScreen({super.key});

  @override
  State<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  final _repo = UserRepository();
  final _controller = TextEditingController();
  String? _puzzle;
  String? _challengeId;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  Future<void> _loadChallenge() async {
    setState(() => _loading = true);
    final data = await _repo.generateCaptchaChallenge();
    if (!mounted) return;
    setState(() {
      _puzzle = data['puzzle'] as String?;
      _challengeId = data['challengeId'] as String?;
      _loading = false;
      _controller.clear();
    });
  }

  Future<void> _submit() async {
    if (_challengeId == null || _submitting) return;
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;

    setState(() => _submitting = true);
    // Ad plays BEFORE we know the result — matches "complete task, see
    // an ad, then get coins" from the mockup.
    await showPlaceholderAd(context);
    final result = await _repo.submitCaptcha(answer, _challengeId!);
    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    await _loadChallenge();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final atLimit = user.captchaToday >= 100;

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: MiniHeader(title: 'Solve CAPTCHA', coins: user.coins),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProgressCard(done: user.captchaToday, total: 100, coinsEach: 10),
                  const SizedBox(height: 24),
                  if (atLimit)
                    const _DoneForToday(message: 'Daily CAPTCHA limit reached — come back tomorrow.')
                  else if (_loading)
                    const Expanded(child: Center(child: CircularProgressIndicator()))
                  else ...[
                    _CaptchaBox(text: _puzzle ?? ''),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: 'Type the code',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.line)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _submitting ? null : _loadChallenge,
                            child: const Text('New code'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            child: Text(_submitting ? '...' : 'Submit'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Every 25 CAPTCHAs = 1 Scratch Card', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
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

/// Renders the puzzle text with a slight random rotation per letter —
/// a simple visual "distortion" without needing an actual generated
/// image from the server.
class _CaptchaBox extends StatelessWidget {
  const _CaptchaBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final rnd = Random(text.hashCode);
    final colors = [AppColors.violet2, const Color(0xFFE11D48), const Color(0xFF059669), const Color(0xFF2563EB), const Color(0xFFD97706)];
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFFF0EAFF), Color(0xFFE3DAFC)]),
        border: Border.all(color: const Color(0xFFD9CCFB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: text.split('').asMap().entries.map((e) {
          final angle = (rnd.nextDouble() - 0.5) * 0.5;
          return Transform.rotate(
            angle: angle,
            child: Text(
              e.value,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: colors[e.key % colors.length]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total, required this.coinsEach});
  final int done;
  final int total;
  final int coinsEach;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done/$total today', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF6DD), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFF8DE9B))),
                child: Text('+$coinsEach', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (done / total).clamp(0, 1),
              minHeight: 8,
              backgroundColor: const Color(0xFFE6E1F6),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF0A020)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneForToday extends StatelessWidget {
  const _DoneForToday({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
