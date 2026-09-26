import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_entry.dart';
import '../../services/user_repository.dart';
import '../../theme/app_theme.dart';

class AccountHistoryScreen extends StatelessWidget {
  const AccountHistoryScreen({super.key});

  static const _icons = {
    'calendar': Icons.calendar_month_rounded,
    'shield': Icons.shield_rounded,
    'calc': Icons.calculate_rounded,
    'video': Icons.play_circle_fill_rounded,
    'spin': Icons.donut_large_rounded,
    'invite': Icons.person_add_alt_1_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
    'coin': Icons.bolt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final repo = UserRepository();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Account History'), backgroundColor: AppColors.bg),
      body: StreamBuilder<List<TransactionEntry>>(
        stream: repo.watchTransactions(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const Center(child: Text('No activity yet', style: TextStyle(color: AppColors.muted)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = items[i];
              final positive = t.amount >= 0;
              return ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF1ECFF), borderRadius: BorderRadius.circular(14)),
                  child: Icon(_icons[t.icon] ?? Icons.bolt_rounded, color: AppColors.violet2, size: 22),
                ),
                title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t.createdAt != null ? DateFormat('d MMM, h:mm a').format(t.createdAt!) : ''),
                trailing: Text(
                  '${positive ? '+' : ''}${t.amount}',
                  style: TextStyle(fontWeight: FontWeight.w800, color: positive ? const Color(0xFF059669) : const Color(0xFFD1323A)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
