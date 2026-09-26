import 'package:flutter/material.dart';
import '../../models/transaction_entry.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';

class MyRewardsScreen extends StatelessWidget {
  const MyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = UserRepository();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('My Rewards'), backgroundColor: AppColors.bg),
      body: StreamBuilder<List<RedemptionEntry>>(
        stream: repo.watchRedemptions(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const Center(child: Text('No redemptions yet', style: TextStyle(color: AppColors.muted)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = items[i];
              final isGp = r.method == 'googlePlay';
              final statusColor = switch (r.status) {
                'paid' => const Color(0xFF047857),
                'rejected' => const Color(0xFFD1323A),
                _ => const Color(0xFFA16207),
              };
              final statusBg = switch (r.status) {
                'paid' => const Color(0xFFD5F5E3),
                'rejected' => const Color(0xFFFFE3E1),
                _ => const Color(0xFFFFF3CF),
              };
              return ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF1ECFF), borderRadius: BorderRadius.circular(14)),
                  child: Icon(isGp ? Icons.videogame_asset_rounded : Icons.account_balance_wallet_rounded, color: AppColors.violet2),
                ),
                title: Text('${isGp ? 'Google Play' : 'UPI'} · ₹${r.inr}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${r.coinsSpent} coins spent'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    r.status[0].toUpperCase() + r.status.substring(1),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
