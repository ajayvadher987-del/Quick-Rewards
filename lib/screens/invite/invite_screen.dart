import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/coin_result_dialog.dart';

/// Invite tab — referral code, shareable link, the coin split, and a
/// one-time "enter a friend's code" box for people who signed up
/// without following a link.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _repo = UserRepository();
  final _codeController = TextEditingController();
  bool _applying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied')));
    }
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _applying) return;
    setState(() => _applying = true);
    final result = await _repo.applyReferralCode(code);
    setState(() => _applying = false);
    if (!mounted) return;
    await showCoinResultDialog(context, success: result.success, coinsAwarded: result.coinsAwarded, message: result.message);
    if (result.success) _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: _repo.watchUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final link = 'https://quickrewards.app/r/${user.referralCode}';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(coins: user.coins, initials: user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: AppColors.heroGradient,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invite Friends',
                                    style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                                SizedBox(height: 6),
                                Text('Invite new friends and earn coins',
                                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: AppColors.goldGradient),
                            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _Label('Your referral code'),
                    _CopyBox(text: user.referralCode.isEmpty ? '—' : user.referralCode, onCopy: () => _copy(user.referralCode, 'Code')),
                    const SizedBox(height: 16),

                    _Label('Your referral link'),
                    _CopyBox(text: link, small: true, onCopy: () => _copy(link, 'Link')),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(child: _GainTile(label: 'You get', value: 300)),
                        const SizedBox(width: 12),
                        Expanded(child: _GainTile(label: 'Friend gets', value: 200)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    ElevatedButton(
                      onPressed: () => Share.share('Join Quick Rewards and get 200 coins free! $link'),
                      child: const Text('Share with friends'),
                    ),

                    if (!user.referralApplied) ...[
                      const SizedBox(height: 28),
                      _Label('Have a friend\'s code?'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter code',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.line)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _applying ? null : _applyCode,
                            child: Text(_applying ? '...' : 'Apply'),
                          ),
                        ],
                      ),
                    ],
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.muted, fontSize: 13)),
      );
}

class _CopyBox extends StatelessWidget {
  const _CopyBox({required this.text, required this.onCopy, this.small = false});
  final String text;
  final VoidCallback onCopy;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA58BF5), width: 1.4, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: small ? 14 : 17, letterSpacing: small ? 0 : 1.2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onCopy,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            child: const Text('Copy', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _GainTile extends StatelessWidget {
  const _GainTile({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.goldGradient),
                child: const Icon(Icons.bolt, color: Colors.white, size: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
