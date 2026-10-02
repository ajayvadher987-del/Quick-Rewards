import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';

/// Scratch Card. The prize is decided the moment the card is tapped
/// (useScratchCard() call to the server) — scratching is purely a
/// visual reveal of an amount that's already been credited, matching
/// the "server decides, client only animates" pattern used elsewhere.
class ScratchScreen extends StatefulWidget {
  const ScratchScreen({super.key});

  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  final _repo = UserRepository();
  int? _prize;
  bool _revealing = false;
  bool _revealed = false;
  final List<Offset> _scratchPoints = [];

  Future<void> _startScratchCard() async {
    if (_revealing || _prize != null) return;
    setState(() => _revealing = true);
    final result = await _repo.useScratchCard();
    if (!mounted) return;
    setState(() {
      _revealing = false;
      if (result.success) {
        _prize = result.coinsAwarded;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      }
    });
  }

  void _onPan(Offset localPos) {
    if (_prize == null || _revealed) return;
    setState(() => _scratchPoints.add(localPos));
    if (_scratchPoints.length > 60) _checkRevealed();
  }

  void _checkRevealed() {
    // Simple heuristic: once enough scratch strokes have been made,
    // consider the card revealed and clear the overlay.
    if (_scratchPoints.length > 55 && !_revealed) {
      setState(() => _revealed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();

        return Scaffold(
          backgroundColor: AppColors.bg,
          appBar: AppBar(
            backgroundColor: AppColors.bg,
            elevation: 0,
            title: const Text('Scratch Card', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: AppColors.heroGradient),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.bolt, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text('${user.coins}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('${user.scratchCards} card${user.scratchCards == 1 ? '' : 's'} available', style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 28),
                  if (user.scratchCards <= 0 && _prize == null)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No Scratch Cards yet.\nSolve 25 CAPTCHAs or 25 Math Quizzes to earn one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _prize == null ? _startScratchCard : null,
                      onPanUpdate: (details) => _onPan(details.localPosition),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(colors: [Color(0xFFFFF3C4), Color(0xFFFFD76A)]),
                          boxShadow: [BoxShadow(color: const Color(0xFFD97706).withOpacity(.3), blurRadius: 24, offset: const Offset(0, 14))],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: _revealing
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      _prize == null ? '' : '+$_prize\ncoins',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF7A4A00)),
                                    ),
                            ),
                            if (_prize != null && !_revealed)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _ScratchOverlayPainter(points: _scratchPoints),
                                ),
                              ),
                            if (_prize == null && !_revealing)
                              const Center(
                                child: Text('Tap to open', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7A4A00))),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_prize != null && !_revealed)
                    const Text('Scratch with your finger to reveal', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                  if (_revealed)
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _prize = null;
                        _revealed = false;
                        _scratchPoints.clear();
                      }),
                      child: const Text('Done'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Paints an opaque "foil" layer with holes punched out wherever the
/// user has scratched, using BlendMode.clear inside a saveLayer.
class _ScratchOverlayPainter extends CustomPainter {
  _ScratchOverlayPainter({required this.points});
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    final foil = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFC9B8FF), Color(0xFF5B2BD9)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)), foil);

    final erase = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 24, erase);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratchOverlayPainter oldDelegate) => true;
}
