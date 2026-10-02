import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ad_placeholder.dart';
import '../../widgets/mini_header.dart';

/// Daily Spin. The prize is decided by spinWheel() on the server —
/// this screen just animates the wheel to land on whatever value the
/// server already returned, so the wheel can never disagree with the
/// coins actually credited.
class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> with SingleTickerProviderStateMixin {
  final _repo = UserRepository();
  late final AnimationController _controller;
  late Animation<double> _rotation;
  double _currentAngle = 0;
  bool _spinning = false;

  static const _values = [5, 10, 15, 20, 25];
  static const _colors = [AppColors.violet3, Color(0xFFF59E0B), Color(0xFF2563EB), Color(0xFFE11D48), Color(0xFF059669)];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);

    await showPlaceholderAd(context);
    final result = await _repo.spinWheel();
    if (!mounted) return;

    if (!result.success) {
      setState(() => _spinning = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    final wedgeIndex = _values.indexOf(result.coinsAwarded);
    final wedgeAngle = 2 * pi / _values.length;
    // Land the pointer (fixed at top) in the middle of the winning
    // wedge, plus several full extra spins for a satisfying animation.
    final targetAngle = -(wedgeIndex * wedgeAngle + wedgeAngle / 2) + (2 * pi * 6);

    _rotation = Tween<double>(begin: _currentAngle, end: _currentAngle + targetAngle)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..reset()
      ..forward().whenComplete(() {
        _currentAngle = (_currentAngle + targetAngle) % (2 * pi);
        if (mounted) setState(() => _spinning = false);
      });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final atLimit = user.spinToday >= 10;

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: MiniHeader(title: 'Daily Spin', coins: user.coins),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text('${user.spinToday}/10 spins used today', style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 24),
                SizedBox(
                  width: 270,
                  height: 270,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => Transform.rotate(
                          angle: _rotation.value,
                          child: child,
                        ),
                        child: CustomPaint(
                          size: const Size(270, 270),
                          painter: _WheelPainter(values: _values, colors: _colors),
                        ),
                      ),
                      Positioned(
                        top: -6,
                        child: Icon(Icons.arrow_drop_down, size: 46, color: AppColors.ink),
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.bolt, color: Color(0xFFF0A020), size: 30),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (atLimit || _spinning) ? null : _spin,
                      child: Text(atLimit ? 'No spins left today' : (_spinning ? 'Spinning…' : 'Spin')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({required this.values, required this.colors});
  final List<int> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final wedgeAngle = 2 * pi / values.length;

    for (int i = 0; i < values.length; i++) {
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * wedgeAngle - pi / 2, wedgeAngle, true, paint);

      final labelAngle = i * wedgeAngle + wedgeAngle / 2 - pi / 2;
      final labelOffset = Offset(center.dx + cos(labelAngle) * radius * 0.62, center.dy + sin(labelAngle) * radius * 0.62);
      final tp = TextPainter(
        text: TextSpan(text: '${values[i]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelOffset - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.drawCircle(center, radius, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0xFFF0A020));
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
