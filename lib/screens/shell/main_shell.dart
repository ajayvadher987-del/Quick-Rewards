import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import '../earn/earn_screen.dart';
import '../invite/invite_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';

/// Hosts the 5 main tabs — Home, Earn, Invite, Wallet, Profile — behind
/// one floating bottom nav bar, matching the mockup's `nav` element.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.card_giftcard_rounded, label: 'Earn'),
    (icon: Icons.person_add_alt_1_rounded, label: 'Invite'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  final _screens = const [
    HomeScreen(),
    EarnScreen(),
    InviteScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(color: Color(0x332E1382), blurRadius: 30, offset: Offset(0, 14)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final active = i == _index;
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: active ? const Color(0xFFECE3FF) : Colors.transparent,
                      ),
                      child: Icon(
                        tab.icon,
                        size: 22,
                        color: active ? AppColors.violet2 : const Color(0xFF77748F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active ? AppColors.violet2 : const Color(0xFF77748F),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
