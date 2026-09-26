import 'package:flutter/material.dart';
import '../../models/reward_tier.dart';
import '../../models/user_model.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/coin_result_dialog.dart';
import '../../widgets/payment_method_card.dart';
import '../../widgets/tier_card.dart';

const _gpImage = 'assets/images/google_play.png';
const _upiImage = 'assets/images/upi_logo.png';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _repo = UserRepository();
  PaymentMethod? _method; // null = show the method-select screen

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
                child: _method == null
                    ? _MethodSelect(onPick: (m) => setState(() => _method = m))
                    : _TierGrid(
                        method: _method!,
                        userCoins: user.coins,
                        onBack: () => setState(() => _method = null),
                        onRedeem: (tier) => _openRedeemSheet(context, _method!, tier),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRedeemSheet(BuildContext context, PaymentMethod method, RewardTier tier) async {
    final controller = TextEditingController();
    final isGp = method == PaymentMethod.googlePlay;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 22, right: 22, top: 22,
          bottom: 22 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Redeem ₹${tier.inr}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              '${isGp ? 'Google Play Gift Card' : 'UPI'} · ${tier.coins} coins will be deducted',
              style: const TextStyle(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: isGp ? 'Email to receive gift card code' : 'Enter your UPI ID (name@bank)',
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm & Redeem'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;
    if (controller.text.trim().isEmpty) return;

    final result = await _repo.redeemReward(
      method: isGp ? 'googlePlay' : 'upi',
      coins: tier.coins,
      inr: tier.inr,
      destination: controller.text.trim(),
    );

    if (!context.mounted) return;
    await showCoinResultDialog(
      context,
      success: result.success,
      coinsAwarded: 0,
      message: result.message,
    );
    if (result.success) setState(() => _method = null);
  }
}

class _MethodSelect extends StatelessWidget {
  const _MethodSelect({required this.onPick});
  final ValueChanged<PaymentMethod> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12, left: 2),
          child: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted)),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PaymentMethodCard(
                imageAsset: _gpImage,
                isGooglePlay: true,
                title: 'Google Play',
                minCoins: RewardTiers.googlePlay.first.coins,
                onTap: () => onPick(PaymentMethod.googlePlay),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PaymentMethodCard(
                imageAsset: _upiImage,
                isGooglePlay: false,
                title: 'UPI',
                minCoins: RewardTiers.upi.first.coins,
                onTap: () => onPick(PaymentMethod.upi),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TierGrid extends StatelessWidget {
  const _TierGrid({
    required this.method,
    required this.userCoins,
    required this.onBack,
    required this.onRedeem,
  });

  final PaymentMethod method;
  final int userCoins;
  final VoidCallback onBack;
  final ValueChanged<RewardTier> onRedeem;

  @override
  Widget build(BuildContext context) {
    final isGp = method == PaymentMethod.googlePlay;
    final tiers = isGp ? RewardTiers.googlePlay : RewardTiers.upi;
    final image = isGp ? _gpImage : _upiImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.line)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Text(isGp ? 'Google Play' : 'UPI', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Choose a reward. The bar fills as you collect coins.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, i) {
            final tier = tiers[i];
            return TierCard(
              tier: tier,
              currentCoins: userCoins,
              imageAsset: image,
              isGooglePlay: isGp,
              onTap: () {
                if (userCoins < tier.coins) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Need ${tier.coins - userCoins} more coins')),
                  );
                  return;
                }
                onRedeem(tier);
              },
            );
          },
        ),
      ],
    );
  }
}
