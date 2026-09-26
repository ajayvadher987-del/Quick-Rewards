/// A single redeemable reward: `coins` required for `inr` rupees.
class RewardTier {
  final int coins;
  final int inr;
  const RewardTier(this.coins, this.inr);
}

/// Matches the coin/₹ values from the UI mockup exactly — change these
/// numbers here only; every screen reads from this single source.
class RewardTiers {
  RewardTiers._();

  static const googlePlay = [
    RewardTier(10500, 100),
    RewardTier(21000, 200),
    RewardTier(31500, 300),
    RewardTier(42000, 400),
    RewardTier(52500, 500),
  ];

  static const upi = [
    RewardTier(12500, 100),
    RewardTier(25000, 200),
    RewardTier(36000, 300),
    RewardTier(50000, 400),
    RewardTier(60000, 500),
  ];
}

enum PaymentMethod { googlePlay, upi }
